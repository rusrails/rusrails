Несколько баз данных с Active Record
====================================

Это руководство раскрывает использование нескольких баз данных в вашем приложении на Rails.

После прочтения этого руководства, вы узнаете:

* Как настроить приложение для нескольких баз данных.
* Как работает автоматическое переключение соединений.
* Как использовать горизонтальный шардинг для нескольких баз данных.
* Какие особенности уже поддерживаются, а какие пока еще разрабатываются.

--------------------------------------------------------------------------------

По мере роста популярности и использования приложения, вам будет нужно масштабировать приложения для поддержки новых пользователей и их данных. Одно из направлений, в котором приложение может быть масштабировано, находится на уровне базы данных. Теперь в Rails есть поддержка нескольких баз данных, поэтому вам не нужно хранить все данные в одном месте.

В настоящее время поддерживаются следующие особенности:

* Несколько пишущих баз данных и реплики для каждой
* Автоматическое переключение соединения для модели, с которой вы работаете
* Автоматическое переключение между пишущей базой и репликой, в зависимости от метода HTTP и последних записей
* Задания Rails для создания, удаления, миграции и взаимодействия с несколькими базами данных

Следующие особенности (пока) не поддерживаются:

* Нагрузочная балансировка реплик

## Настройка приложения
Хотя Rails старается сделать максимум работы за вас, все же требуется несколько шагов, чтобы подготовить приложение к нескольким базам данных.

Предположим, у нас есть приложение с одной пишущей базой данных, и мы хотим добавить новую базу данных для нескольких новых таблиц. Имя новой базы данных будет "animals".

`database.yml` выглядит так:

```yaml
production:
  database: my_primary_database
  adapter: mysql2
  username: root
  password: <%= ENV['ROOT_PASSWORD'] %>
```

Давайте добавим реплику для первой конфигурации, и вторую базу данных с именем animals, а также реплику для нее. Для этого нам нужно изменить конфигурацию `database.yml` из 2-уровневой в 3-уровневую.

Если предоставлена конфигурация primary, она будет использована как конфигурация "по умолчанию". Если нет конфигурации с именем `"primary"`, Rails использует первую конфигурацию как "по умолчанию" для каждой среды. Конфигурации по умолчанию будут использовать имена файлов Rails по умолчанию. Например, основные конфигурации будут использовать `schema.rb` для файла схемы, в то время как все остальные записи будут использовать имена файлов `[CONFIGURATION_NAMESPACE]_schema.rb`.

```yaml
production:
  primary:
    database: my_primary_database
    username: root
    password: <%= ENV['ROOT_PASSWORD'] %>
    adapter: mysql2
  primary_replica:
    database: my_primary_database
    username: root_readonly
    password: <%= ENV['ROOT_READONLY_PASSWORD'] %>
    adapter: mysql2
    replica: true
  animals:
    database: my_animals_database
    username: animals_root
    password: <%= ENV['ANIMALS_ROOT_PASSWORD'] %>
    adapter: mysql2
    migrations_paths: db/animals_migrate
  animals_replica:
    database: my_animals_database
    username: animals_readonly
    password: <%= ENV['ANIMALS_READONLY_PASSWORD'] %>
    adapter: mysql2
    replica: true
```

При использовании нескольких баз данных есть ряд важных настроек.

Во-первых, имя базы данных для `primary` и `primary_replica` должно быть тем же самым, так как они содержат те же самые данные. То же самое для `animals` и `animals_replica`.

Во-вторых, имя пользователя для пишущей базы и реплики должно быть различным, и права пользователя реплики базы данных должны быть установлены только для чтения, но не для записи.

При использовании реплики базы данных нужно добавить запись `replica: true` для реплики в `database.yml`. Это нужно, потому что в противном случае Rails не сможет узнать, какая из них реплика, а какая пишущая. Rails не будет запускать определенные задачи, такие как миграции, на репликах.

Наконец, для новой пишущей базы данных необходимо установить в `migrations_paths` директорию, в которой вы будете хранить миграции для этой базы данных. Мы рассмотрим `migrations_paths` позже в этом руководстве.

Теперь, когда у нас есть новая база данных, давайте настроим модель соединения. Чтобы использовать новую базу данных, нам нужно создать новый абстрактный класс и соединить с базами данных животных.

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals, reading: :animals_replica }
end
```

Затем нужно обновить `ApplicationRecord`, чтобы он знал о нашей реплике.

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary_replica }
end
```

При использовании по-другому названного класса в вашем приложении необходимо вместо этого установить `primary_abstract_class`, таким образом Rails будет знать, с каким классом должен делиться соединением `ActiveRecord::Base`.

```ruby
class PrimaryApplicationRecord < ActiveRecord::Base
  self.primary_abstract_class = true
end
```

Классы, соединяющиеся к primary/primary_replica могут наследоваться от вашего основного абстрактного класса, как в стандартных приложениях Rails:

```ruby
class Person < ApplicationRecord
end
```

По умолчанию Rails ожидает, что роли базы данных будут `writing` и `reading` для основной и реплики соответственно. Если у вас существующая система, у вас уже могут быть настроенные роли, которые вы не хотите менять. В этом случае можно настроить новое имя роли в конфигурации приложения.

```ruby
config.active_record.writing_role = :default
config.active_record.reading_role = :readonly
```

Важно, что нужно соединяться с базой данных в единственной модели, а затем наследоваться от этой модели, а не соединять несколько отдельных моделей с той же самой базой данных. У клиентов базы данных есть ограничение на количество доступных открытых соединений, и, если вы сделаете так, это умножит количество соединений, так как Rails использует имя класса модели в качестве имени спецификации соединения.

Теперь, когда у нас есть `database.yml`, и настроена новая модель, пришло время создать базы данных. Rails 6.0 поставляется со всеми задачами rails, нужными для использования нескольких баз данных в Rails.

Можно запустить `bin/rails -T` для просмотра всех заданий, которые можно выполнить. Вы должны увидеть следующее:

```bash
$ bin/rails -T
rails db:create                          # Creates the database from DATABASE_URL or config/database.yml for the ...
rails db:create:animals                  # Create animals database for current environment
rails db:create:primary                  # Create primary database for current environment
rails db:drop                            # Drops the database from DATABASE_URL or config/database.yml for the cu...
rails db:drop:animals                    # Drop animals database for current environment
rails db:drop:primary                    # Drop primary database for current environment
rails db:migrate                         # Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog)
rails db:migrate:animals                 # Migrate animals database for current environment
rails db:migrate:primary                 # Migrate primary database for current environment
rails db:migrate:status                  # Display status of migrations
rails db:migrate:status:animals          # Display status of migrations for animals database
rails db:migrate:status:primary          # Display status of migrations for primary database
rails db:reset                           # Drops and recreates all databases from their schema for the current environment and loads the seeds
rails db:reset:animals                   # Drops and recreates the animals database from its schema for the current environment and loads the seeds
rails db:reset:primary                   # Drops and recreates the primary database from its schema for the current environment and loads the seeds
rails db:rollback                        # Rolls the schema back to the previous version (specify steps w/ STEP=n)
rails db:rollback:animals                # Rollback animals database for current environment (specify steps w/ STEP=n)
rails db:rollback:primary                # Rollback primary database for current environment (specify steps w/ STEP=n)
rails db:schema:dump                     # Creates a database schema file (either db/schema.rb or db/structure.sql  ...
rails db:schema:dump:animals             # Creates a database schema file (either db/schema.rb or db/structure.sql  ...
rails db:schema:dump:primary             # Creates a db/schema.rb file that is portable against any DB supported  ...
rails db:schema:load                     # Loads a database schema file (either db/schema.rb or db/structure.sql  ...
rails db:schema:load:animals             # Loads a database schema file (either db/schema.rb or db/structure.sql  ...
rails db:schema:load:primary             # Loads a database schema file (either db/schema.rb or db/structure.sql  ...
rails db:setup                           # Creates all databases, loads all schemas, and initializes with the seed data (use db:reset to also drop all databases first)
rails db:setup:animals                   # Creates the animals database, loads the schema, and initializes with the seed data (use db:reset:animals to also drop the database first)
rails db:setup:primary                   # Creates the primary database, loads the schema, and initializes with the seed data (use db:reset:primary to also drop the database first)
```

Запуск команды `bin/rails db:create` создаст и основную базу, и базу животных. Отметьте, что нет команды для создания пользователей базы данных, и вам нужно это сделать вручную для поддержки пользователей только для чтения в репликах. Если нужно создать базу животных, можно выполнить `bin/rails db:create:animals`.

## Соединение с базами данных без управления схемой и миграциями

Если вы хотите соединиться с внешней базой данных без каких-либо задач управления базой данных, таких как управление схемой, миграции, сиды, и т.д., можно установить для базы данных конфигурационную настройку `database_tasks: false`. По умолчанию она установлена как true.

```yaml
production:
  primary:
    database: my_database
    adapter: mysql2
  animals:
    database: my_animals_database
    adapter: mysql2
    database_tasks: false
```

## Генераторы и миграции

Миграции для разных баз данных должны находиться в своих папках с приставленным именем ключа базы данных в конфигурации.

Также нужно установить `migrations_paths` в конфигурациях базы данных, чтобы сообщить Rails, где искать миграции.

Например, для базы данных `animals` миграции будут искаться в директории `db/animals_migrate`, а `primary` в `db/migrate`. Генераторы Rails теперь принимают опцию `--database`, чтобы файл был сгенерирован в правильной директории. Команда может быть запущена следующим образом:

```bash
$ bin/rails generate migration CreateDogs name:string --database animals
```

При использовании генераторов Rails, генераторы скаффолда или модели сгенерируют вам абстрактный класс. Просто передайте ключ базы данных в командной строке.

```bash
$ bin/rails generate scaffold Dog name:string --database animals
```

Будет создан класс с именем базы данных плюс `Record`. В данном примере база данных `Animals`, поэтому получаем `AnimalsRecord`:

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals }
end
```

Сгенерированная модель будет автоматически унаследована от `AnimalsRecord`.

```ruby
class Dog < AnimalsRecord
end
```

Note: Так как Rails не знает, какая база данных является репликой для пишущей базы, необходимо это добавить в абстрактный класс по завершении.

Rails сгенерирует новый класс единожды. Он не будет переписан новыми скаффолдами или удален при удалении скаффолда.

Если у вас уже есть абстрактный класс, и его имя отличается от `AnimalsRecord`, можно передать опцию `--parent` для обозначения, что нужен иной абстрактный класс:

```bash
$ bin/rails generate scaffold Dog name:string --database animals --parent Animals::Record
```

Это пропустит генерацию `AnimalsRecord`, так как вы обозначили Rails, что хотите использовать другой родительский класс.

## Активация автоматического переключения роли

Наконец, чтобы использовать реплику только для чтения, нужно активировать промежуточную программу для автоматического переключения.

Автоматическое переключение позволяет приложению переключаться с пишущей базы на реплику или с реплики на пишущую, основываясь на методе HTTP, и того, была ли недавно запись запрашивающим пользователем.

Если приложение получает запрос POST, PUT, DELETE или PATCH, приложение автоматически будет писать в пишущую базу данных. За указанное время после записи, приложение будет читать из основной базы. Для запроса GET или HEAD приложение будет читать из реплики, если нет недавней записи.

Чтобы активировать промежуточную программу автоматического переключения соединений, можно запустить генератор автоматического переключения:

```
$ bin/rails g active_record:multi_db
```

А затем раскомментируйте следующие строчки.

```ruby
Rails.application.configure do
  config.active_record.database_selector = { delay: 2.seconds }
  config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
end
```

Rails гарантирует "чтение ваших собственных записей" и пошлет ваши запросы GET или HEAD в пишущую базу, если они в пределах диапазона `delay`. По умолчанию задержка установлена 2 секунды. Ее следует изменить на основе инфраструктуры вашей базы данных. Rails не гарантирует "чтение недавних записей" для других пользователей в пределах диапазона задержки и пошлет запросы GET и HEAD в реплику, если эти пользователи не писали недавно.

Автоматическое переключение соединения в Rails относительно примитивное и специально не делает слишком многого. Целью этой системы является демонстрация, как осуществить автоматическое переключение соединения, достаточно гибкое, чтобы быть настроенным разработчиками приложения.

Настройка в Rails позволяет легко изменить, как выполняется переключение и на каких параметрах оно базируется. Скажем, вы хотите использовать куки вместо сессии, чтобы решить, когда поменять соединение. Можно написать свой класс:

```ruby
class MyCookieResolver
  # код вашего класса для куки
end
```

И затем передать его в промежуточные программы:

```ruby
config.active_record.database_selector = { delay: 2.seconds }
config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
config.active_record.database_resolver_context = MyCookieResolver
```

## Использование ручного переключения соединения

Имеется ряд случаев, когда хочется, чтобы приложение соединялось с пишущей базой или репликой, и автоматического переключения не достаточно. Например, вы знаете, что для определенного запроса нужно всегда отправлять запрос к реплике, даже если это в запросе POST.

Для этого Rails предоставляет метод `connected_to`, который переключит на нужное вам соединение.

```ruby
ActiveRecord::Base.connected_to(role: :reading) do
  # весь код в этом блоке будет соединен с ролью reading
end
```

"role" в вызове `connected_to` ищет соединения, связанные с обработчиком этого соединения (или роли). Обработчик соединения `reading` содержит все соединения, связанные с помощью `connects_to` с именем роли `reading`.

Отметьте, что `connected_to` с ролью будет искать существующее соединение и переключать с помощью указанного имени соединения. Это означает, что, если вы передали неизвестную роль, наподобие `connected_to(role: :nonexistent)`, то получите ошибку, сообщающую `ActiveRecord::ConnectionNotEstablished (No connection pool with 'AnimalsBase' found for the 'nonexistent' role.)`

Если хотите, чтобы Rails убедился, что любые выполняемые запросы только читают, передайте `prevent_writes: true`. Это только предотвратит запросы, выглядящие как запись, от отправления в базу данных. Вы также должны настроить свою реплику базы данных запускаться в режиме только для чтения.

```ruby
ActiveRecord::Base.connected_to(role: :reading, prevent_writes: true) do
  # Rails проверит каждый запрос, чтобы убедиться, что он читает
end
```

## Горизонтальный шардинг

Горизонтальный шардинг — это когда вы разделяете вашу базу данных для уменьшения количества записей на каждом сервере баз данных, но поддерживаете ту же самую схему для всех "shard". Это обычно называется "multi-tenant sharding".

API для поддержки горизонтального шардинга в Rails похож на API для нескольких баз данных / вертикального шардинга, существующего с Rails 6.0.

Шарды объявляются в трех-уровневой конфигурации наподобие:

```yaml
production:
  primary:
    database: my_primary_database
    adapter: mysql2
  primary_replica:
    database: my_primary_database
    adapter: mysql2
    replica: true
  primary_shard_one:
    database: my_primary_shard_one
    adapter: mysql2
  primary_shard_one_replica:
    database: my_primary_shard_one
    adapter: mysql2
    replica: true
```

Затем модели соединяются с помощью ключа `shards` в API `connects_to`:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    shard_one: { writing: :primary_shard_one, reading: :primary_shard_one_replica }
  }
end
```

Затем в моделях можно вручную переключать соединения с помощью API `connected_to`. При использования шардинга должны быть переданы обе `role` и `shard`:

```ruby
ActiveRecord::Base.connected_to(role: :writing, shard: :default) do
  @id = Person.create! # Создаст запись в shard default
end

ActiveRecord::Base.connected_to(role: :writing, shard: :shard_one) do
  Person.find(@id) # Не найдет запись, не существует, так как было создано
                   # в shard default
end
```

API горизонтального шардинга также поддерживает чтение из реплик. Можно переключить роли и шард с помощью API `connected_to`.

```ruby
ActiveRecord::Base.connected_to(role: :reading, shard: :shard_one) do
  Person.first # Ищет запись в реплике shard one
end
```

## Активизация автоматического переключения шарда

Приложения могут автоматически переключать шарды для запроса с помощью предоставленной промежуточной программы.

Промежуточная программа `ShardSelector` предоставляет фреймворк для автоматического переключения шардов. Rails предоставляет базовый фреймворк для определения, на какой шард переключиться, и позволяет по необходимости писать в приложениях пользовательские стратегии для переключения.

`ShardSelector` принимает ряд опций (в настоящее время поддерживается только `lock`), которые могут быть использованы промежуточной программой для изменения поведения. `lock` по умолчанию true, и запретит запросу переключать шарды пока внутри блока. Если `lock` false, то переключение шарда будет разрешено.
Для шардинга, основанного на tenant, `lock` должен всегда быть true для предотвращения кода приложения от ошибочного переключения между tenant.

Тот же генератор, что и для выбора базы данных, может быть использован для генерации файла для автоматического переключения шарда:

```
$ bin/rails g active_record:multi_db
```

Затем в файле раскомментируйте следующее:

```ruby
Rails.application.configure do
  config.active_record.shard_selector = { lock: true }
  config.active_record.shard_resolver = ->(request) { Tenant.find_by!(host: request.host).shard }
end
```

Приложения должны представить код для resolver, так как он зависит от определенных моделей приложения. Пример resolver может выглядеть так:

```ruby
config.active_record.shard_resolver = ->(request) {
  subdomain = request.subdomain
  tenant = Tenant.find_by_subdomain!(subdomain)
  tenant.shard
}
```

## Гранулированное переключение соединения с базой данных

В Rails 6.1 возможно переключать соединения для одной базы данных вместо глобального для всех баз данных.

С гранулированным переключением соединения с базой данных, любой абстрактный класс будет способен переключать соединения, не затрагивая другие соединения. Это полезно для переключения запросов `AnimalsRecord` на чтение из реплики, в то время как запросы `ApplicationRecord` идут в основную базу.

```ruby
AnimalsRecord.connected_to(role: :reading) do
  Dog.first # Читает из animals_replica
  Person.first  # Читает из primary
end
```

Также возможно гранулировано менять соединения для шардов.

```ruby
AnimalsRecord.connected_to(role: :reading, shard: :shard_one) do
  Dog.first # Прочитает из shard_one_replica. Если не существует соединения
  #  для shard_one_replica, будет вызвана ошибка ConnectionNotEstablished
  Person.first # Прочитает из основной пишущей базы
end
```

Чтоб переключить только основной кластер базы данных, используйте `ApplicationRecord`:

```ruby
ApplicationRecord.connected_to(role: :reading, shard: :shard_one) do
  Person.first # Читает из primary_shard_one_replica
  Dog.first # Читает из animals_primary
end
```

`ActiveRecord::Base.connected_to` поддерживает возможность переключать соединения глобально.

### Управление связями с соединением между базами данных

Начиная с Rails 7.0+, в Active Record есть опция управления связями, которое выполнит соединение между несколькими базами данных. Если у вас есть связи "has many through" или "has one through", в которых вы хотите отключить соединение, и выполнить 2 или более запросов, передайте опцию `disable_joins: true`.

Например:

```ruby
class Dog < AnimalsRecord
  has_many :treats, through: :humans, disable_joins: true
  has_many :humans

  has_one :home
  has_one :yard, through: :home, disable_joins: true
end

class Home
  belongs_to :dog
  has_one :yard
end

class Yard
  belongs_to :home
end
```

Ранее вызовы `@dog.treats` без `disable_joins` или `@dog.yard` без `disable_joins` вызвали бы ошибку, так как базы данных не могли управлять соединениями между кластерами. С помощью опции `disable_joins`, Rails сгенерирует несколько запросов select, чтобы избежать попытки соединения между кластерами. Для вышеприведенной связи, `@dog.treats`. он сгенерирует следующий SQL:

```sql
SELECT "humans"."id" FROM "humans" WHERE "humans"."dog_id" = ?  [["dog_id", 1]]
SELECT "treats".* FROM "treats" WHERE "treats"."human_id" IN (?, ?, ?)  [["human_id", 1], ["human_id", 2], ["human_id", 3]]
```

В то время как `@dog.yard` сгенерирует следующий SQL:

```sql
SELECT "home"."id" FROM "homes" WHERE "homes"."dog_id" = ? [["dog_id", 1]]
SELECT "yards".* FROM "yards" WHERE "yards"."home_id" = ? [["home_id", 1]]
```

Есть ряд важных вещей, которые нужно знать об этой опции:

1) Может быть влияние на производительность, сейчас будут выполняться два или более запросов (в зависимости от связи) вместо соединения. Если выборка для `humans` возвратит большое количество ID, в выборку для `treats` может быть послано слишком много ID.
2) Поскольку мы больше не выполняем соединения, запросы с сортировкой или лимитом теперь сортируются в памяти, так как упорядочивание из одной таблицы не может быть применено к другой таблице.
3) Эта настройка должна быть добавлена ко всем связям, где вы хотите отключить соединение. Rails не может угадать это, так как загрузка связей ленивая, и чтобы загрузить `treats` in `@dog.treats` Rails уже нужно знать, какой SQL должен быть сгенерирован.

### Кэширование схемы

Если вы хотите загрузить кэш схемы для каждой базы данных, вам нужно установить `schema_cache_path` в каждой конфигурации базы данных и установить `config.active_record.lazily_load_schema_cache = true` в конфигурации приложения. Отметьте, что это лениво загрузит кэш при установлении соединений с базами данных.

## Предостережения

### Нагрузочная балансировка реплик

Rails также не поддерживает автоматическую нагрузочную балансировку реплик. Это очень зависит от вашей инфраструктуры. В будущем может быть будет реализована базовая, примитивная нагрузочная балансировка, но для масштабирования приложения должно быть что-то, что управляет вашим приложением вне Rails.
