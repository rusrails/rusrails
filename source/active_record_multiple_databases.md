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

* Автоматическое переключение для горизонтального шардинга
* Соединение между кластерами
* Нагрузочная балансировка реплик
* Выгрузка кэшей схемы для нескольких баз данных

## Настройка приложения
Хотя Rails старается сделать максимум работы за вас, все же требуется несколько шагов, чтобы подготовить приложение к нескольким базам данных.

Предположим, у нас есть приложение с одной пишущей базой данных, и мы хотим добавить новую базу данных для нескольких новых таблиц. Имя новой базы данных будет "animals".

`database.yml` выглядит так:

```yaml
production:
  database: my_primary_database
  user: root
  adapter: mysql
```

Давайте добавим реплику для первой конфигурации, и вторую базу данных с именем animals, а также реплику для нее. Для этого нам нужно изменить конфигурацию `database.yml` из 2-уровневой в 3-уровневую.

Если предоставлена конфигурация primary, она будет использована как конфигурация "по умолчанию". Если нет конфигурации с именем "primary", Rails использует первую конфигурацию для среды. Конфигурации по умолчанию будут использовать имена файлов Rails по умолчанию. Например, основные конфигурации будут использовать `schema.rb` для файла схемы, в то время как все остальные записи будут использовать имена файлов `[CONFIGURATION_NAMESPACE]_schema.rb`.

```yaml
production:
  primary:
    database: my_primary_database
    user: root
    adapter: mysql
  primary_replica:
    database: my_primary_database
    user: root_readonly
    adapter: mysql
    replica: true
  animals:
    database: my_animals_database
    user: animals_root
    adapter: mysql
    migrations_paths: db/animals_migrate
  animals_replica:
    database: my_animals_database
    user: animals_readonly
    adapter: mysql
    replica: true
```

При использовании нескольких баз данных есть ряд важных настроек.

Во-первых, имя базы данных для `primary` и `primary_replica` должно быть тем же самым, так как они содержат те же самые данные. То же самое для `animals` и `animals_replica`.

Во-вторых, имя пользователя для пишущей базы и реплики должно быть различным, и права пользователя реплики должны быть установлены только для чтения, но не для записи.

При использовании реплики базы данных нужно добавить запись `replica: true` для реплики в `database.yml`. Это нужно, потому что в противном случае Rails не сможет узнать, какая из них реплика, а какая пишущая.

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

```
class PrimaryApplicationRecord < ActiveRecord::Base
  self.primary_abstract_class
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
rails db:rollback                        # Rolls the schema back to the previous version (specify steps w/ STEP=n)
rails db:rollback:animals                # Rollback animals database for current environment (specify steps w/ STEP=n)
rails db:rollback:primary                # Rollback primary database for current environment (specify steps w/ STEP=n)
rails db:schema:dump                     # Creates a database schema file (either db/schema.rb or db/structure.sql  ...
rails db:schema:dump:animals             # Creates a database schema file (either db/schema.rb or db/structure.sql  ...
rails db:schema:dump:primary             # Creates a db/schema.rb file that is portable against any DB supported  ...
rails db:schema:load                     # Loads a database schema file (either db/schema.rb or db/structure.sql  ...
rails db:schema:load:animals             # Loads a database schema file (either db/schema.rb or db/structure.sql  ...
rails db:schema:load:primary             # Loads a database schema file (either db/schema.rb or db/structure.sql  ...
```

Запуск команды `bin/rails db:create` создаст и основную базу, и базу животных. Отметьте, что нет команды для создания пользователей, и вам нужно это сделать вручную для поддержки пользователей только для чтения в репликах. Если нужно создать базу животных, можно выполнить `bin/rails db:create:animals`.

## Генераторы и миграции

Миграции для разных баз данных должны находиться в своих папках с приставленным именем ключа базы данных в конфигурации.

Также нужно установить `migrations_paths` в конфигурациях базы данных, чтобы сообщить Rails, где искать миграции.

Например, для базы данных `animals` миграции будут искаться в директории `db/animals_migrate`, а `primary` в `db/migrate`. Генераторы Rails теперь принимают опцию `--database`, чтобы файл был сгенерирован в правильной директории. Команда может быть запущена следующим образом:

```bash
$ bin/rails generate migration CreateDogs name:string --database animals
```

При использовании генераторов Rails, генераторы скаффолда или модели сгенерируют вам абстрактный класс. Просто передайте ключ базы данных в командной строке

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

## Активация автоматического переключения соединения

Наконец, чтобы использовать реплику только для чтения, нужно активировать промежуточную программу для автоматического переключения.

Автоматическое переключение позволяет приложению переключаться с пишущей базы на реплику или с реплики на пишущую, основываясь на методе HTTP, и того, была ли недавно запись.

Если приложение получает запрос POST, PUT, DELETE или PATCH, приложение автоматически будет писать в пишущую базу данных. За указанное время после записи, приложение будет читать из основной базы. Для запроса GET или HEAD приложение будет читать из реплики, если нет недавней записи.

Чтобы активировать промежуточную программу автоматического переключения соединений, добавьте или откомментируйте следующие строчки в конфигурации приложения.

```ruby
config.active_record.database_selector = { delay: 2.seconds }
config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
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

## Горизонтальный шардинг

Горизонтальный шардинг — это когда вы разделяете вашу базу данных для уменьшения количества записей на каждом сервере баз данных, но поддерживаете ту же самую схему для всех "shard". Это обычно называется "multi-tenant sharding".

API для поддержки горизонтального шардинга в Rails похож на API для нескольких баз данных / вертикального шардинга, существующего с Rails 6.0.

Шарды объявляются в трех-уровневой конфигурации наподобие:

```yaml
production:
  primary:
    database: my_primary_database
    adapter: mysql
  primary_replica:
    database: my_primary_database
    adapter: mysql
    replica: true
  primary_shard_one:
    database: my_primary_shard_one
    adapter: mysql
  primary_shard_one_replica:
    database: my_primary_shard_one
    adapter: mysql
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

## Гранулированное переключение соединения с базой данных

В Rails 6.1 возможно переключать соединения для одной базы данных вместо глобального для всех баз данных. Чтобы использовать эту особенность, нужно сперва установить `config.active_record.legacy_connection_handling` в `false` в конфигурации приложения. Большинству приложений не нужны другие изменения, так как у публичных API то же самое поведение.

С `legacy_connection_handling` установленным в false, любой абстрактный класс будет способен переключать соединения, не затрагивая другие соединения. Это полезно для переключения запросов `AnimalsRecord` на чтение из реплики, в то время как запросы `ApplicationRecord` идут в основную базу.

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

## Предостережения

### Автоматическое переключение для горизонтального шардинга

Хотя Rails теперь поддерживает API для соединения и переключения соединений шардов, он пока еще не поддерживает стратегию автоматического переключения. Любое переключение шарда должно быть выполнено вручную с помощью промежуточной программы или `around_action`.

### Нагрузочная балансировка реплик

Rails также не поддерживает автоматическую нагрузочную балансировку реплик. Это очень зависит от вашей инфраструктуры. В будущем может быть будет реализована базовая, примитивная нагрузочная балансировка, но для масштабирования приложения должно быть что-то, что управляет вашим приложением вне Rails.

### Соединения между базами данных

Приложения не могут соединять несколько таблиц из разных баз данных. В настоящее время в приложениях нужно вручную написать два select и разделить сами joins. В будущих версиях Rails будет разделять joins за вас.

### Кэш схемы

Если вы используете кэш схемы и несколько баз данных, вам необходимо написать инициализатор, загружающий кэш схемы из вашего приложения. Эта проблема не была решена в Rails 6.0, но есть надежда, что она будет решена в следующей версии.
