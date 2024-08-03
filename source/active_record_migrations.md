Миграции Active Record
======================

Миграции - это особенность Active Record, позволяющая [развивать схему вашей базы данных время от времени](https://en.wikipedia.org/wiki/Schema_migration). Вместо того, чтобы записывать модификации схемы на чистом SQL, миграции позволяют использовать предметно-ориентированный язык (DSL) на Ruby для описания изменений в ваших таблицах.

После прочтения этого руководства, вы узнаете:

* Какие генераторы можно использовать для создания миграций.
* Какие методы Active Record обеспечивают взаимодействие с вашей базой данных.
* Как изменить существующие миграции и обновить вашу схему.
* Как миграции связаны со `schema.rb`
* Как поддерживать ссылочную целостность.

Обзор миграций
--------------

Миграции - это удобный способ [развивать схему вашей базы данных время от времени](https://en.wikipedia.org/wiki/Schema_migration) воспроизводимым образом. Они используют Ruby [DSL](https://en.wikipedia.org/wiki/Domain-specific_language), чтобы вам не нужно нужно писать [SQL](https://en.wikipedia.org/wiki/SQL) вручную, позволяя вашей схеме быть независимой от базы данных. Мы рекомендуем вам прочитать руководства по [основам Active Record](/active-record-basics) и [связям Active Record](/active-record-associations), чтобы узнать больше о некоторых концепциях, упомянутых здесь.

Каждую миграцию можно рассматривать как новую 'версию' базы данных. Схема изначально ничего не содержит, а каждая миграция модифицирует ее, добавляя или убирая таблицы, столбцы или индексы. Active Record знает, как обновлять вашу схему со временем, перенося ее из определенной точки в прошлом в последнюю версию. Подробнее о том, как Rails определяет, какую миграцию запускать из всей хронологии, можно узнать [здесь](#rails-migration-version-control).

Active Record обновляет ваш файл `db/schema.rb`, чтобы он соответствовал актуальной структуре вашей базы данных. Вот пример миграции:

```ruby
# db/migrate/20240502100843_create_products.rb
class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

Эта миграция добавляет таблицу `products` со строковым столбцом `name` и текстовым столбцом `description`. Первичный ключ, названный `id`, также будет неявно добавлен по умолчанию, так как это первичный ключ по умолчанию для всех моделей Active Record. Макрос `timestamps` добавляет два столбца, `created_at` и `updated_at`. Эти специальные столбцы автоматически управляются Active Record, если существуют.

```ruby
# db/schema.rb
ActiveRecord::Schema[8.0].define(version: 2024_05_02_100843) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
```

Мы определили изменение, которое мы хотим, чтобы произошло при движении вперед во времени. До запуска этой миграции таблицы нет. После запуска - таблица будет существовать. Active Record также знает, как обратить эту миграцию; если мы откатываем эту миграцию, он удалит таблицу. О том, как откатить миграции, можно прочитать [здесь](#rolling-back).

После того, как вы определили изменения, которые хотите применить к базе данных в будущем, важно учитывать возможность отката миграции. Хотя Active Record может управлять последовательным применением миграций, гарантируя создание таблицы, концепция обратной операции становится критически важной. Обратимые миграции не только создают таблицу при применении, но также обеспечивают возможность ее безопасного удаления. В случае отмены вышеупомянутой миграции, Active Record интеллектуально обрабатывает удаление таблицы, поддерживая согласованность базы данных на протяжении всего процесса.  О том, как сделать миграцию обратимой, можно прочитать [здесь](#using-reversible).

(generating-migration-files) Генерация файлов миграции
------------------------------------------------------

### Создание отдельной миграции

Миграции хранятся как файлы в каталоге `db/migrate`, по одному на каждый класс миграции.

Имя файла имеет формат `YYYYMMDDHHMMSS_create_products.rb`, оно содержит временную метку UTC, идентифицирующую миграцию, за которой следует подчеркивание и затем название миграции. Название класса миграции (с использованием CamelCase) должно совпадать с последней частью имени файла.

Например, `20240502100843_create_products.rb` должен определять класс `CreateProducts`, а `20240502101659_add_details_to_products.rb` должен определять класс `AddDetailsToProducts`. Rails использует эту временную метку, чтобы определить, какую миграцию следует запустить и в каком порядке, поэтому если вы копируете миграцию из другого приложения или сами генерируете файл, учитывайте ее положение в порядке выполнения. Подробнее о том, как используются временные метки, можно прочитать в разделе [Контроль версий миграций Rails](#rails-migration-version-control).

При генерации миграции Active Record автоматически добавляет текущую временную метку к имени файла миграции. Например, выполнение команды ниже создаст пустой файл миграции, имя файла которого будет состоять из временной метки, добавленной перед подчеркнутым названием миграции.

```bash
$ bin/rails generate migration AddPartNumberToProducts
```

```ruby
# db/migrate/20240502101659_add_part_number_to_products.rb
class AddPartNumberToProducts < ActiveRecord::Migration[8.0]
  def change
  end
end
```

Генератор умеет намного больше, чем просто добавлять временную метку к имени файла. Основываясь на соглашениях об именах и дополнительных (необязательных) аргументах, он также может начать формировать структуру миграции.

В следующих разделах будут описаны различные способы создания миграций на основе соглашений и дополнительных аргументов.

### Создание новой таблицы

При создании новой таблицы в базе данных вы можете использовать миграцию в формате "CreateXXX", за которым следует список названий столбцов и их типов. Это позволит создать файл миграции, который настроит таблицу с указанными столбцами.

```bash
$ bin/rails generate migration CreateProducts name:string part_number:string
```

сгенерирует

```ruby
class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :part_number

      t.timestamps
    end
  end
end
```

Сгенерированный файл с его содержимым является лишь отправной точкой. Вы можете добавлять или удалять из него элементы по своему усмотрению, редактируя файл `db/migrate/YYYYMMDDHHMMSS_create_products.rb`.

### (adding-new-columns) Добавление столбцов

Когда вы хотите добавить новый столбец в существующую таблицу в своей базе данных, вы можете использовать миграцию с форматом "AddColumnToTable", за которым следует список имен и типов столбцов. Это приведет к созданию файла миграции, содержащего соответствующие инструкции [`add_column`][].

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string
```

Это сгенерирует следующую миграцию:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :part_number, :string
  end
end
```

Если вы хотите добавить индекс на новый столбец, это также можно сделать.

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string:index
```

Это сгенерирует необходимые выражения `add_column` and [`add_index`][]:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```

Вы **не** ограничены одним магически генерируемым столбцом. Например:

```bash
$ bin/rails generate migration AddDetailsToProducts part_number:string price:decimal
```

Это сгенерирует миграцию схемы, добавляющую два дополнительных столбца в таблице `products`.

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :part_number, :string
    add_column :products, :price, :decimal
  end
end
```

### Удаление столбцов

Аналогично, если название миграции имеет вид "RemoveColumnFromTable" и за ним следует список имен и типов столбцов, то будет создана миграция, содержащая соответствующие инструкции [`remove_column`][].

```bash
$ bin/rails generate migration RemovePartNumberFromProducts part_number:string
```

Это сгенерирует подходящее выражение [`remove_column`][]:

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration[8.0]
  def change
    remove_column :products, :part_number, :string
  end
end
```

### Создание связей

Связи Active Record используются для определения отношений между различными моделями в вашем приложении. Это позволяет моделям взаимодействовать друг с другом через эти связи, упрощая работу с связанными данными. Чтобы узнать больше о связях, обратитесь к руководству [Связи (ассоциации) Active Record](/active-record-associations).

Одним из распространенных вариантов использования связей является создание ссылок внешних ключей между таблицами. Генератор поддерживает типы столбцов, такие как `references`, для облегчения этого процесса. [Ссылки (references)](#references) - это сокращение для создания столбцов, индексов, внешних ключей или даже столбцов для полиморфных связей.

Например,

```bash
$ bin/rails generate migration CreateProducts name:string part_number:string
```

генерирует следующий вызов [`add_reference`][]:

```ruby
class AddUserRefToProducts < ActiveRecord::Migration[8.0]
  def change
    add_reference :products, :user, null: false, foreign_key: true
  end
end
```

Вышеописанная миграция создает внешний ключ `user_id` в таблице `products`. Этот внешний ключ ссылается на столбец `id` в таблице `users`.  Помимо этого, миграция создает индекс для столбца `user_id`. Схема выглядит следующим образом:

```ruby
  create_table "products", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_products_on_user_id"
  end
```

`belongs_to` - это псевдоним для `references`, поэтому вышесказанное можно было бы переписать следующим образом:

```bash
$ bin/rails generate migration AddUserRefToProducts user:belongs_to
```

для создания миграции и схемы, аналогичной приведенной выше.

Существует также генератор, который будет производить объединение таблиц, если `JoinTable` является частью названия.

```bash
$ bin/rails generate migration CreateJoinTableUserProduct user product
```

Сгенерирует следующую миграцию:

```ruby
class CreateJoinTableUserProduct < ActiveRecord::Migration[8.0]
  def change
    create_join_table :users, :products do |t|
      # t.index [:user_id, :product_id]
      # t.index [:product_id, :user_id]
    end
  end
end
```

[`add_column`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column
[`add_index`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index
[`add_reference`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference
[`remove_column`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_column

### Другие генераторы, создающие миграции

Помимо генератора `migration`, генераторы `model`, `resource` и `scaffold` также могут создавать миграции, необходимые для добавления новой модели. Эти миграции будут автоматически содержать инструкции по созданию соответствующей таблицы.  При указании необходимых столбцов Rails также добавит инструкции для их создания в миграцию. Например, выполнение команды:

```bash
$ bin/rails generate model Product name:string description:text
```

Это создаст миграцию, которая выглядит так

```ruby
class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

Можно определить сколько угодно пар имя_столбца/тип.

### Передача модификаторов

При генерации миграций вы можете напрямую указывать часто используемые [модификаторы типов](#column-modifiers) в командной строке. Эти модификаторы, заключенные в фигурные скобки и следующие за типом поля, позволяют настраивать характеристики ваших столбцов базы данных без необходимости последующего ручного редактирования файла миграции.

К примеру, запуск:

```bash
$ bin/rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
```

создаст миграцию, которая выглядит как эта:

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 2
    add_reference :products, :supplier, polymorphic: true
  end
end
```

TIP: Для получения дополнительной помощи по генераторам выполните команду `bin/rails generate --help`. В качестве альтернативы вы также можете выполнить `bin/rails generate model --help` или `bin/rails generate migration --help` для получения помощи по конкретным генераторам.

Обновление миграций
-------------------

После того, как вы создадите файл миграции с помощью одного из генераторов из предыдущего [раздела](#generating-migration-files), вы можете отредактировать созданный файл миграции в папке `db/migrate` для определения дальнейших изменений, которые вы хотите внести в схему своей базы данных.

### Создание таблицы

Метод [`create_table`][] один из самых фундаментальных типов миграций, но в большинстве случаев, он будет сгенерирован для вас генератором модели, ресурса или скаффолда. Обычное использование такое

```ruby
create_table :products do |t|
  t.string :name
end
```

Это создаст таблицу `products` со столбцом `name`.

#### Связи

При создании таблицы для модели, имеющей связь, вы можете использовать тип `:references` для создания столбца с внешним ключом. Например:

```ruby
create_table :products do |t|
  t.references :category
end
```

Эта команда создаст столбец `category_id`. В качестве альтернативы вы можете использовать `belongs_to` - это псевдоним для `references`.

```ruby
create_table :products do |t|
  t.belongs_to :category
end
```

Вы также можете указать тип столбца и создание индекса, используя опцию [`:polymorphic`](/active-record-associations#polymorphic-associations):

```ruby
create_table :taggings do |t|
  t.references :taggable, polymorphic: true
end
```

Эта команда создаст столбцы `taggable_id`, `taggable_type`, а также соответствующие индексы.

#### Первичные ключи

По умолчанию `create_table` неявно создаст первичный ключ, названный `id`. Вы можете изменить имя столбца с помощью опции `:primary_key`, как показано ниже.

```ruby
class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, primary_key: "user_id" do |t|
      t.string :username
      t.string :email
      t.timestamps
    end
  end
end
```

Это приведет к следующей схеме:

```ruby
create_table "users", primary_key: "user_id", force: :cascade do |t|
  t.string "username"
  t.string "email"
  t.datetime "created_at", precision: 6, null: false
  t.datetime "updated_at", precision: 6, null: false
end
```

Вы также можете передать массив в `:primary_key` для составного первичного ключа. Подробнее о составных первичных ключах [здесь](/active-record-composite-primary-keys) (TODO).

```ruby
class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, primary_key: [:id, :name] do |t|
      t.string :name
      t.string :email
      t.timestamps
    end
  end
end
```

Если вы вообще не хотите использовать первичный ключ, вы можете передать опцию `id: false`.

```ruby
class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: false do |t|
      t.string :username
      t.string :email
      t.timestamps
    end
  end
end
```

#### Опции базы данных

Если нужно передать базе данных специфичные опции, вы можете поместить фрагмент `SQL` в опцию `:options`. Например:

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

Это добавит `ENGINE=BLACKHOLE` к SQL выражению, используемому для создания таблицы.

Можно создать индекс на созданные столбцы внутри блока `create_table`, передав `index: true` или хэш опций в опцию `:index`:

```ruby
create_table :users do |t|
  t.string :name, index: true
  t.string :email, index: { unique: true, name: 'unique_emails' }
end
```

[`create_table`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_table

#### Комментарии

Можно передать опцию `:comment` с любым описанием для таблицы, которое будет сохранено в самой базе данных, и может быть просмотрено с помощью инструментов администрирования базы данных, таких как MySQL Workbench или PgAdmin III. Комментарии могут помочь членам команды лучше понять модель данных и сгенерировать документацию в приложениях с большими базами данных. В настоящее время комментарии поддерживают только адаптеры MySQL и PostgreSQL.

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :price, :decimal, precision: 8, scale: 2, comment: "The price of the product in USD"
    add_column :products, :stock_quantity, :integer, comment: "The current stock quantity of the product"
  end
end
```

### Создание соединительной таблицы

Метод миграции [`create_join_table`][] создает соединительную таблицу [HABTM (has and belongs to many, многие ко многим)](/active-record-associations#the-has-and-belongs-to-many-association). Обычное использование будет таким:

```ruby
create_join_table :products, :categories
```

Эта миграция создаст таблицу `categories_products` с двумя столбцами по имени `category_id` и `product_id`.

У этих столбцов есть опция `:null`, установленная в `false` по умолчанию, что означает, что вы **обязаны** предоставлять значение, чтобы сохранить запись в эту таблицу. Это может быть переопределено опцией `:column_options`:

```ruby
create_join_table :products, :categories, column_options: { null: true }
```

По умолчанию, имя соединительной таблицы получается как соединение первых двух аргументов, переданных в create_join_table, в алфавитном порядке. В данном случае таблица будет названа `categories_products`.

Чтобы настроить имя таблицы, передайте опцию `:table_name`:

```ruby
create_join_table :products, :categories, table_name: :categorization
```

Это создаст соединительную таблицу, названную `categorization`.

А также, `create_join_table` принимает блок, который можно использовать для добавления индексов (которые по умолчанию не создаются) или любых выбранных вами дополнительных столбцов:

```ruby
create_join_table :products, :categories do |t|
  t.index :product_id
  t.index :category_id
end
```

[`create_join_table`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_join_table

### Изменение таблиц

Если хотите изменить существующую таблицу, имеется [`change_table`][].

Он используется подобно `create_table`, но у объекта, передаваемого в блок, есть доступ к ряду специальных функций, например:

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

Эта миграция удалит столбцы `description` и `name`, создаст новый строковый столбец `part_number` и добавит индекс на него. Наконец, он переименует столбец `upccode` на `upc_code`.

[`change_table`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table

### Изменение столбцов

Подобно методам `remove_column` и `add_column`, которые мы раскрыли [ранее](#adding-columns), Rails предоставляет метод миграции [`change_column`][].

```ruby
change_column :products, :part_number, :text
```

Он меняет тип столбца `part_number` в таблице `products` на `:text`.

NOTE: Команда `change_column` — **необратима**. Для того, чтобы гарантировать безопасный откат вашей миграции, вам потребуется предоставить собственную миграцию `reversible`. Подробнее об обратимых миграциях можно прочитать [здесь](#using-reversible).

Кроме `change_column`, методы [`change_column_null`][] и [`change_column_default`][] используются чтобы изменить ограничение null или значение столбца по умолчанию.

```ruby
change_column_default :products, :approved, from: true, to: false
```

Эта команда изменяет значение по умолчанию для поля `:approved` с true на false. Это изменение коснется только будущих записей, существующие записи останутся без изменений. Для изменения ограничения NULL используйте команду [`change_column_default`][].

```ruby
change_column_null :products, :name, false
```

Эта команда устанавливает для поля `:name` в таблице продуктов значение `NOT NULL`. Это изменение также применяется к существующим записям, поэтому вам необходимо убедиться, что все существующие записи имеют поле `:name` со значением `NOT NULL`.

При установке ограничению null `true`, это означает, что столбец будет принимать значение null, в противном случае будет применено ограничение `NOT NULL`, и должно быть передано значение, чтобы запись была сохранена в базу данных.

NOTE: Также можно написать предыдущую миграцию `change_column_default` как `change_column_default :products, :approved, false`, но, в отличие от предыдущего примера, это сделало бы вашу миграцию необратимой.

[`change_column`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column
[`change_column_default`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_default
[`change_column_null`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_null

### (column-modifiers) Модификаторы столбца

Модификаторы столбца могут быть применены при создании или изменении столбца:

* `comment`      Добавляет комментарий для столбца.
* `collation`    Указывает сопоставление для столбца `string` или `text`.
* `default`      Позволяет установить значение по умолчанию для столбца. Отметьте, что если вы используете динамическое значение (такое как дату), значение по умолчанию будет вычислено лишь один раз (т.е. на дату, когда миграция будет применена). Используйте `nil` для `NULL`.
* `limit`        Устанавливает максимальное количество символов для столбца `string` и максимальное количество байт для столбцов `text/binary/integer`.
* `null`         Позволяет или запрещает значения `NULL` в столбце.
* `precision`    Определяет точность для столбцов `decimal/numeric/datetime/time`.
* `scale`        Определяет масштаб для столбцов `decimal` и `numeric`, определяющий количество цифр после запятой.

NOTE: Для `add_column` или `change_column` нет опций для добавления индексов. Их нужно добавить отдельно с помощью `add_index`.

Некоторые адаптеры могут поддерживать дополнительные опции; за подробностями обратитесь к документации API конкретных адаптеров.

NOTE: При генерации миграции с помощью командной строки нельзя указать `null` и `default`.

### (References) Ссылки

Метод `add_reference` позволяет создавать правильно названный столбец, служащий соединение между одной или многими связями.

```ruby
add_reference :users, :role
```

Эта миграция добавит внешний ключ  с названием `role_id` в таблицу пользователей. `role_id` будет ссылаться на столбец `id` в таблице `roles`. Кроме того, она создаст индекс для столбца `role_id`, если не будет явно указано не делать этого с помощью опции `index: false`.

INFO: Подробности смотрите в руководстве [Связи (ассоциации) Active Record][].

Метод `add_belongs_to` это псевдоним `add_reference`.

```ruby
add_belongs_to :taggings, :taggable, polymorphic: true
```

Опция polymorphic создаст два столбца в таблице taggings. которые можно использовать для полиморфных связей: `taggable_type` и `taggable_id`.

Внешний ключ можно создать с помощью опции `foreign_key`.

```ruby
add_reference :users, :role, foreign_key: true
```

Больше опций `add_reference` в [документации API](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference).

Ссылки также можно убрать:

```ruby
remove_reference :products, :user, foreign_key: true, index: false
```

### (foreign-keys) Внешние ключи

Хотя это и не требуется, вы можете захотеть добавить ограничения внешнего ключа для [обеспечения ссылочной целостности](#active-record-and-referential-integrity).

```ruby
add_foreign_key :articles, :authors
```

Вызов [`add_foreign_key`][] добавляет новое ограничение в таблицу `articles`. Это ограничение гарантирует, что существует строка в таблице `authors`, в которой столбец `id` соответствует `articles.author_id`, чтобы гарантировать, что все рецензенты, указанные в таблице статей, являются действительными авторами, перечисленными в таблице авторов.

NOTE: При использовании `references` в миграции вы создаете новый столбец в таблице. При этом у вас появится возможность добавить внешний ключ к этому столбцу с помощью `foreign_key: true`. Однако, если вы хотите добавить внешний ключ к существующему столбцу, вы можете использовать `add_foreign_key`.

Если название столбца таблицы, к которой мы добавляем внешний ключ, невозможно
вывести из названия таблицы ссылаемого первичного ключа, то для определения
названия столбца можно использовать опцию `:column`. Кроме того, можно
использовать опцию `:primary_key`, если ссылаемый первичный ключ не имеет
названия `:id`.

Например, чтобы добавить внешний ключ на `articles.reviewer`, ссылающийся на `authors.email`:

```ruby
add_foreign_key :articles, :authors, column: :reviewer, primary_key: :email
```

Это добавит ограничение на таблицу `articles`, гарантирующее, что существует запись в таблице `authors`, в которой столбец `email` соответствует полю `articles.reviewer`.

`add_foreign_key` поддерживает несколько других опций, таких как `name`, `on_delete`, `if_not_exists`, `validate` и `deferrable`.

Внешний ключ также можно убрать с помощью [`remove_foreign_key`][]:

```ruby
# позволим Active Record выяснить имя столбца
remove_foreign_key :accounts, :branches

# уберем внешний ключ для определенного столбца
remove_foreign_key :accounts, column: :owner_id
```

NOTE: Active Record поддерживает внешние ключи только для отдельных столбцов. Чтобы использовать составные внешние ключи, требуются `execute` и `structure.sql`. Смотрите [Выгрузка схемы](#schema-dumping-and-you)

### Составные первичные ключи

Иногда значения одного столбца недостаточно для уникальной идентификации каждой строки таблицы, но комбинация двух или более столбцов *может* однозначно идентифицировать ее. Это может быть актуально при использовании устаревшей схемы базы данных без единого столбца `id` в качестве первичного ключа или при изменении схем для шардинга или многопользовательской архитектуры.

Вы можете создать таблицу с составным первичным ключом, передав опцию `:primary_key` в метод `create_table` со значением в виде массива:

```ruby
class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products, primary_key: [:customer_id, :product_sku] do |t|
      t.integer :customer_id
      t.string :product_sku
      t.text :description
    end
  end
end
```

INFO: Для таблиц с составными первичными ключами необходимо передавать массивы значений вместо идентификаторов типа integer во многих методах. Также смотри руководство [TODO: Active Record Composite Primary Keys](/active_record_composite_primary_keys) для получения дополнительной информации.

### Выполнение SQL

Если предоставленных хелперов Active Record недостаточно, вы можете использовать метод [`execute`][] для выполнения команд SQL. Например,

```ruby
class UpdateProductPrices < ActiveRecord::Migration[8.0]
  def up
    execute "UPDATE products SET price = 'free'"
  end

  def down
    execute "UPDATE products SET price = 'original_price' WHERE price = 'free';"
  end
end
```

В этом примере мы обновляем столбец `price` таблицы products на значение 'free' для всех записей.

WARNING: К прямому изменению данных в миграциях следует подходить с осторожностью. Рассмотрите, является ли это лучшим подходом для вашего случая использования, и учитывайте потенциальные недостатки, такие как повышенная сложность и накладные расходы на обслуживание, риски для целостности данных и переносимости базы данных. Вы можете прочитать больше о миграциях данных [здесь](#data-migrations).

Больше подробностей и примеров отдельных методов содержится в документации по API.

В частности, документация для [`ActiveRecord::ConnectionAdapters::SchemaStatements`][], который обеспечивает методы, доступные в методах `up`, `down` и `change`.

Методы, доступные у объекта, переданного методом `create_table`, смотрите в [`ActiveRecord::ConnectionAdapters::TableDefinition`][].

И для объекта, вкладываемого в `change_table`, смотрите в [`ActiveRecord::ConnectionAdapters::Table`][].

[`execute`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/DatabaseStatements.html#method-i-execute
[`ActiveRecord::ConnectionAdapters::SchemaStatements`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html
[`ActiveRecord::ConnectionAdapters::TableDefinition`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html
[`ActiveRecord::ConnectionAdapters::Table`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Table.html

### Использование метода `change`

Метод `change` это основной метод написания миграций. Он работает в большинстве случаев, в которых Active Record знает, как обратить действия миграции автоматически.  Ниже некоторые действия, которые поддерживает `change`:

* [`add_check_constraint`][]
* [`add_column`][]
* [`add_foreign_key`][]
* [`add_index`][]
* [`add_reference`][]
* [`add_timestamps`][]
* [`change_column_comment`][] (необходимо предоставить опции `:from` и `:to`)
* [`change_column_default`][] (необходимо предоставить опции `:from` и `:to`)
* [`change_column_null`][]
* [`change_table_comment`][] (необходимо предоставить опции `:from` и `:to`)
* [`create_join_table`][]
* [`create_table`][]
* `disable_extension`
* [`drop_join_table`][]
* [`drop_table`][] (необходимо предоставить опции создания таблицы и блок)
* `enable_extension`
* [`remove_check_constraint`][] (необходимо предоставить изначальное выражение ограничения)
* [`remove_column`][] (необходимо предоставить изначальный тип и опции столбца)
* [`remove_columns`][] (необходимо предоставить изначальный тип и опции столбца)
* [`remove_foreign_key`][] (необходимо предоставить другую таблицу и изначальные опции)
* [`remove_index`][] (необходимо предоставить столбцы и изначальные опции)
* [`remove_reference`][] (необходимо предоставить изначальные опции)
* [`remove_timestamps`][] (необходимо предоставить изначальные опции)
* [`rename_column`][]
* [`rename_index`][]
* [`rename_table`][]

[`change_table`][] также является обратимым, когда блок вызывает только обратимые операции, подобные перечисленным.

Если необходимо использовать любые другие методы, следует использовать `reversible` или написать методы `up` и `down` вместо использования метода `change`.

[`add_check_constraint`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_check_constraint
[`add_foreign_key`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key
[`add_timestamps`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_timestamps
[`change_column_comment`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_comment
[`change_table_comment`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table_comment
[`drop_join_table`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_join_table
[`drop_table`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_table
[`remove_check_constraint`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_check_constraint
[`remove_foreign_key`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key
[`remove_index`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_index
[`remove_reference`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_reference
[`remove_timestamps`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_timestamps
[`rename_column`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_column
[`remove_columns`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_columns
[`rename_index`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_index
[`rename_table`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_table

### (using-reversible) Использование `reversible`

Если вы хотите, чтобы миграция выполняла что-то, что Active Record не умеет отменять, вы можете использовать `reversible` для указания действий при запуске миграции и при ее отмене.

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[8.0]
  def change
    reversible do |direction|
      change_table :products do |t|
        direction.up   { t.change :price, :string }
        direction.down { t.change :price, :integer }
      end
    end
  end
end
```

Эта миграция изменит тип столбца `price` на строку или обратно на целое число при отмене миграции. Обратите внимание на блок, передаваемый соответственно `direction.up` и `direction.down`.

В качестве альтернативы, вы можете использовать `up` и `down` вместо `change`:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[8.0]
  def up
    change_table :products do |t|
      t.change :price, :string
    end
  end

  def down
    change_table :products do |t|
      t.change :price, :integer
    end
  end
end
```

Кроме того, `reversible` полезен при выполнении сырых SQL-запросов или операций с базой данных, для которых нет прямого эквивалента в методах ActiveRecord. Вы можете использовать [`reversible`][] для указания действий при запуске миграции и при ее отмене. Например:

```ruby
class ExampleMigration < ActiveRecord::Migration[8.0]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end

    reversible do |direction|
      direction.up do
        # создадим представление distributors
        execute <<-SQL
          CREATE VIEW distributors_view AS
          SELECT id, zipcode
          FROM distributors;
        SQL
      end
      direction.down do
        execute <<-SQL
          DROP VIEW distributors_view;
        SQL
      end
    end

    add_column :users, :address, :string
  end
end
```

Использование `reversible` гарантирует, что инструкции выполнятся в правильном порядке. Если предыдущий пример миграции откатывается, `down` блок начнёт выполнятся после того как столбец `users.address` будет удалён и перед тем как произойдёт удаление таблицы `distributors`.

[`reversible`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-reversible

### Использование методов `up`/`down`

Вы также можете использовать старый стиль миграций используя `up` и `down` методы, вместо `change`.
Метод `up` должен описывать изменения, которые необходимо внести в схему, а метод `down` миграции должен обращать изменения, внесенные методом `up`. Другими словами, схема базы данных должна остаться неизменной после выполнения `up`, а затем `down`.

Например, если создать таблицу в методе `up`, ее следует удалить в методе `down`. Разумно производить отмену изменений в полностью противоположном порядке тому, в котором они сделаны в методе `up`. Тогда пример из раздела про `reversible` будет эквивалентен:

```ruby
class ExampleMigration < ActiveRecord::Migration[8.0]
  def up
    create_table :distributors do |t|
      t.string :zipcode
    end

    # создадим представление distributors
    execute <<-SQL
      CREATE VIEW distributors_view AS
      SELECT id, zipcode
      FROM distributors;
    SQL

    add_column :users, :address, :string
  end

  def down
    remove_column :users, :address

    execute <<-SQL
      DROP VIEW distributors_view;
    SQL

    drop_table :distributors
  end
end
```

### Вызов ошибки, чтобы предотвратить откат

Иногда ваша миграция будет делать что-то, что просто необратимо; к примеру, может уничтожить некоторые данные.

В таких случаях следует вызвать `ActiveRecord::IrreversibleMigration` из вашего метода `down`.

```ruby
class IrreversibleMigrationExample < ActiveRecord::Migration[8.0]
  def up
    drop_table :example_table
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration cannot be reverted because it destroys data."
  end
end
```

Если кто-либо попытается откатить вашу миграцию, будет отображена ошибка, что это не может быть выполнено.

### (reverting-previous-migrations) Возвращение к предыдущим миграциям

Вы можете использовать возможность Active Record, чтобы откатить миграции с помощью метода [`revert`][]:

```ruby
require_relative "20121212123456_example_migration"

class FixupExampleMigration < ActiveRecord::Migration[8.0]
  def change
    revert ExampleMigration

    create_table(:apples) do |t|
      t.string :variety
    end
  end
end
```

Метод `revert` также может принимать блок. Это может быть полезно для отката выбранной части предыдущих миграций.

Для примера, давайте представим, что `ExampleMigration` закоммичена, а позже мы решили, что представление Distributors больше не нужно.

```ruby
class DontUseDistributorsViewMigration < ActiveRecord::Migration[8.0]
  def change
    revert do
      # скопированный код из ExampleMigration
      create_table :distributors do |t|
        t.string :zipcode
      end
      reversible do |direction|
        direction.up do
          # создадим представление distributors
          execute <<-SQL
            CREATE VIEW distributors_view AS
            SELECT id, zipcode
            FROM distributors;
          SQL
        end
        direction.down do
          execute <<-SQL
            DROP VIEW distributors_view;
          SQL
        end
      end

      # Остальные части миграции не трогаем
    end
  end
end
```

Подобная миграция также может быть написана без использования `revert`, но это бы привело к ещё нескольким шагам:

1. Изменить порядок следования `create table` и `reversible`.
2. Заменить `create_table` на `drop_table`.
3. Наконец, изменить `up` на `down` и наоборот.

Обо всём этом уже позаботился `revert`.

[`revert`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-revert

Запуск миграций
---------------

Rails предоставляет ряд команд для запуска определенных наборов миграций.

Самая первая миграция, относящаяся к команде rails, которую будем использовать, это `bin/rails db:migrate`. В своей основной форме она всего лишь запускает метод `change` или `up` для всех миграций, которые еще не были запущены. Если таких миграций нет, она выходит. Она запустит эти миграции в порядке, основанном на дате миграции.

Заметьте, что запуск команды `db:migrate` также вызывает команду `db:schema:dump`, которая обновляет ваш файл `db/schema.rb` в соответствии со структурой вашей базы данных.

Если вы определите целевую версию, Active Record запустит требуемые миграции (методы up, down или change), пока не достигнет требуемой версии. Версия это числовой префикс у файла миграции. Например, чтобы мигрировать к версии 20240428000000, запустите:

```bash
$ bin/rails db:migrate VERSION=20240428000000
```

Если версия 20240428000000 больше текущей версии (т.е. миграция вперед) это запустит метод `change` (или `up`) для всех миграций до и включая 20240428000000, но не выполнит какие-либо поздние миграции. Если миграция назад, это запустит метод `down` для всех миграций до, но не включая, 20240428000000.

### (rolling-back) Откат

Обычная задача - это откатить последнюю миграцию. Например, вы сделали ошибку и хотите исправить ее. Можно отследить версию предыдущей миграции и произвести миграцию до нее, но можно поступить проще, запустив:

```bash
$ bin/rails db:rollback
```

Это вернёт ситуацию к последней миграции, или обратив метод `change`, или запустив метод `down`. Если нужно отменить несколько миграций, можно указать параметр `STEP`:

```bash
$ bin/rails db:rollback STEP=3
```

Будут отменены 3 последних миграции.

В некоторых случаях, когда вы изменяете локальную миграцию и хотите отменить эту конкретную миграцию перед повторным запуском, вы можете использовать команду `db:migrate:redo`. Как и в случае с командой `db:rollback`, вы можете использовать параметр `STEP`, если вам нужно вернуться более чем на одну версию назад, например:

```bash
$ bin/rails db:migrate:redo STEP=3
```

NOTE: Вы можете получить тот же результат, используя `db:migrate`. Однако они существуют для удобства, чтобы вам не нужно было явно указывать версию для миграции.

#### Транзакции

В базах данных, поддерживающих транзакции DDL, изменение схемы в одной транзакции обертывает каждую миграцию в транзакцию.

INFO: Транзакция гарантирует, что если миграция завершается сбоем на полпути, любые успешно примененные изменения будут откатаны, сохраняя согласованность базы данных. Это означает, что либо все операции в транзакции выполняются успешно, либо ни одна из них не выполняется, предотвращая оставление базы данных в несогласованном состоянии в случае возникновения ошибки во время транзакции.

Если база данных не поддерживает транзакции DDL с операторами изменения схемы, то при сбое миграции ее успешные части не будут откатаны. Вам придется отменить изменения вручную.

Однако есть запросы, которые нельзя выполнить внутри транзакции, и в этих случаях вы можете отключить автоматические транзакции с помощью `disable_ddl_transaction!`:

```ruby
class ChangeEnum < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    execute "ALTER TYPE model_size ADD VALUE 'new_value'"
  end
end
```

NOTE: Помните, что вы все равно можете открывать свои собственные транзакции, даже если находитесь в миграции с self.disable_ddl_transaction!.

### Настройка базы данных

Команда `bin/rails db:setup` создаст базу данных, загрузит схему и инициализирует ее с помощью данных seed.

### Подготовка базы данных

Команда `bin/rails db:prepare` похожа на `bin/rails db:setup`, но она работает идемпотентно, поэтому ее можно безопасно вызывать несколько раз, но она будет выполнять необходимые задачи только один раз.

* Если база данных еще не создана, команда будет работать как `bin/rails db:setup`.
* Если база данных существует, но таблицы не созданы, команда загрузит схему, запустит все ожидающие миграции, сохранит обновленную схему и, наконец, загрузит начальные данные. Вы можете прочитать больше о начальных данных [здесь](#migrations-and-seed-data)
* Если существуют как база данных, так и таблицы, но начальные данные не были загружены, команда загрузит только начальные данные.
* Если база данных, таблицы и начальные данные уже установлены, команда ничего не будет делать.

NOTE: После того, как база данных, таблицы и начальные данные будут установлены, команда не будет пытаться перезагрузить начальные данные, даже если ранее загруженные начальные данные или существующий файл начальных данных были изменены или удалены. Чтобы перезагрузить начальные данные, вы можете вручную запустить `bin/rails db:seed`.

### Сброс базы данных

Команда `bin/rails db:reset` удалит базу данных и установит ее заново. Функционально это эквивалентно `bin/rails db:drop db:setup`.

NOTE. Это не то же самое, что запуск всех миграций. Будет использовано только текущее содержимое файла `db/schema.rb` или `db/structure.sql`. Если миграцию откатить невозможно, `bin/rails db:reset` может не помочь вам. Подробнее о выгрузке схемы смотрите раздел [Выгрузка схемы][].

[Выгрузка схемы]: #schema-dumping-and-you

### Запуск определенных миграций

Если необходимо запустить определённую миграцию вверх или вниз, это делают команды `db:migrate:up` и `db:migrate:down`. Просто укажите подходящую версию и у соответствующей миграции будет вызван метод `change`, `up` или `down`, например:

```bash
$ bin/rails db:migrate:up VERSION=20240428000000
```

При запуске этой команды, будет выполнен метод `change` (или метод `up`) для миграции с версией "20240428000000".

Сначала эта команда проверит, существует ли миграция, или она уже была выполнена, и, если так, ничего не будет сделано.

Если указанная версия не существует, Rails выдаст исключение.

```bash
$ bin/rails db:migrate VERSION=00000000000000
rails aborted!
ActiveRecord::UnknownMigrationVersionError:

No migration with version number 00000000000000.
```

### Запуск миграций в различных средах

По умолчанию запуск `bin/rails db:migrate` запустится в окружении `development`.

Для запуска миграций в другом окружении, его можно указать, используя переменную среды `RAILS_ENV` при запуске команды. Например, для запуска миграций в среде `test`, следует запустить:

```bash
$ bin/rails db:migrate RAILS_ENV=test
```

### Изменение вывода результата запущенных миграций

По умолчанию миграции говорят нам только то, что они делают, и сколько времени это заняло. Миграция, создающая таблицу и добавляющая индекс, выдаст что-то наподобие этого:

```
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

Некоторые методы в миграциях позволяют вам все это контролировать:

| Метод                   | Назначение
| ----------------------- |-----------
| [`suppress_messages`][] | Принимает блок как аргумент и запрещает любой вывод, сгенерированный этим блоком.
| [`say`][]               | Принимает сообщение как аргумент и выводит его как есть. Может быть передан второй булевый аргумент для указания, нужен отступ или нет.
| [`say_with_time`][]     | Выводит текст вместе с продолжительностью выполнения блока. Если блок возвращает число, предполагается, что это количество затронутых строк.

Например, возьмем следующую миграцию:

```ruby
class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    suppress_messages do
      create_table :products do |t|
        t.string :name
        t.text :description
        t.timestamps
      end
    end

    say "Created a table"

    suppress_messages { add_index :products, :name }
    say "and an index!", true

    say_with_time 'Waiting for a while' do
      sleep 10
      250
    end
  end
end
```

Это сгенерирует следующий результат:

```
==  CreateProducts: migrating =================================================
-- Created a table
   -> and an index!
-- Waiting for a while
   -> 10.0013s
   -> 250 rows
==  CreateProducts: migrated (10.0054s) =======================================
```

Если хотите, чтобы Active Record ничего не выводил, запуск `bin/rails db:migrate VERBOSE=false` запретит любой вывод.

[`say`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say
[`say_with_time`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say_with_time
[`suppress_messages`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-suppress_messages

### (rails-migration-version-control) Контроль версий миграций Rails

Rails отслеживает, какие миграции были запущены, через таблицу `schema_migrations` в базе данных. Когда вы запускаете миграцию, Rails вставляет строку в таблицу `schema_migrations` с номером версии миграции, хранящимся в столбце `version`. Это позволяет Rails определить, какие миграции уже были применены к базе данных.

Например, если у вас есть файл миграции с именем 20240428000000_create_users.rb, Rails извлечет номер версии (20240428000000) из имени файла и вставит его в таблицу schema_migrations после успешного выполнения миграции.

Вы можете просмотреть содержимое таблицы schema_migrations непосредственно в вашем инструменте управления базами данных или с помощью консоли Rails:

```irb
rails dbconsole
```

Затем, в консоли базы данных, вы можете запросить таблицу schema_migrations:

```sql
SELECT * FROM schema_migrations;
```

Это покажет вам список всех номеров версий миграций, которые были применены к базе данных. Rails использует эту информацию для определения того, какие миграции необходимо запустить при выполнении команд rails db:migrate или rails db:migrate:up.

Изменение существующих миграций
-------------------------------

Периодически вы будете делать ошибки при написании миграции. Если вы уже запустили миграцию, вы не сможете просто отредактировать миграцию и запустить ее снова: Rails посчитает, что он уже выполнял миграцию, и ничего не сделает при запуске `bin/rails db:migrate`. Вы должны откатить миграцию (например, с помощью `bin/rails db:rollback`), отредактировать миграцию и затем запустить `bin/rails db:migrate` для запуска исправленной версии.

В целом, редактирование существующих миграций, уже отправленных в систему контроля версий, не хорошая идея. Вы создадите дополнительную работу себе и своим коллегам, и вызовете море головной боли, если существующая версия миграции уже была запущена в production. Вместо этого, следует написать новую миграцию, выполняющую требуемые изменения.

Однако, редактирование только что сгенерированной миграции, которая еще не была оправлена в систему контроля версий (или, хотя бы, не ушла дальше вашей рабочей машины) это нормально.

Метод `revert` может быть очень полезным при написании новой миграции для возвращения предыдущей миграции в целом или какой-то ее части (смотрите [Возвращение к предыдущим миграциям][]).

[Возвращение к предыдущим миграциям]: #reverting-previous-migrations

(Schema Dumping and You) Выгрузка схемы
---------------------------------------

### Для чего нужны файлы схемы?

Миграции, какими бы не были они мощными, не являются авторитетным источником для схемы базы данных. **База данных остается источником истины.**

По умолчанию Rails генерирует `db/schema.rb`, которая пытается охватить текущее состояние схемы базы данных.

Она имеет тенденцию быть более быстрой и менее подверженной ошибкам, связанным с созданием нового экземпляра базы данных приложения, загружая файл схемы через `bin/rails db:schema:load`, чем при повторном воспроизведении всей истории миграций. [Старые миграции][] могут работать неправильно, если эти миграции используют изменения внешних зависимостей или полагаются на код приложения, который развивается отдельно от этих миграций.

TIP: Файлы схемы также полезны, если необходимо быстро посмотреть, какие атрибуты есть у объекта Active Record. Эта информация не содержится в коде модели и часто распределена по нескольким миграциям, но собрана воедино в файле схемы.

[Старые миграции]: #old-migrations

### Типы выгрузок схемы

Формат выгрузки схемы, сгенерированный Rails, управляется настройкой [`config.active_record.schema_format`][], определенной в `config/application.rb`. Форматом по умолчанию является `:ruby`, но также альтернативно может быть установлен в `:sql`.

#### Использование схемы по умолчанию `:ruby`

Когда выбрано `:ruby`, тогда схема хранится в `db/schema.rb`. Посмотрев в этот файл, можно увидеть, что он очень похож на одну большую миграцию:

```ruby
ActiveRecord::Schema[8.0].define(version: 2008_09_06_171750) do
  create_table "authors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "part_number"
  end
end
```

Во многих случаях этого достаточно. Этот файл создается путем проверки базы данных и описывает свою структуру, используя `create_table`, `add_index` и так далее.

#### Использование выгрузки схемы `:sql`

Однако, `db/schema.rb` не может описать все, что может поддерживать база данных, например триггеры, последовательности, хранимые процедуры и так далее.

В то время как в миграциях можно выполнить произвольные выражения SQL, эти выражения не смогут быть воспроизведены выгрузчиком схемы.

Если используете подобные особенности, необходимо установить формат схемы как `:sql`, чтобы получить точный файл схемы, который будет полезен для создания новых экземпляров базы данных.

Когда формат схемы установлен в `:sql`, структура базы данных будет выгружена с помощью инструмента, предназначенного для этой базы данных в `db/structure.sql`. Например, для PostgreSQL используется утилита `pg_dump`. Для MySQL и MariaDB этот файл будет содержать результат `SHOW CREATE TABLE` для разных таблиц.

Чтобы загрузить схему из `db/structure.sql`, запустите `bin/rails db:structure:load`. Загрузка этого файла осуществляется путем выполнения содержащихся в нем выражений SQL. По определению создастся точная копия структуры базы данных.

[`config.active_record.schema_format`]:
    configuring.html#config-active-record-schema-format

### Выгрузки схем и управление версиями

Поскольку файлы схемы обычно используются для создания новых баз данных, настоятельно рекомендуется проверять файл схемы в системе управления версиями.

Конфликты слияния могут возникать в файле схемы, когда две ветки модифицируют схему. Для разрешения этих конфликтов, запустите `bin/rails db:migrate`, чтобы восстановить файл схемы.

INFO: Вновь сгенерированные приложения Rails уже будут иметь папку миграций, включенную в дерево git, поэтому все, что вам нужно, это убедиться, что для любых добавленных миграций, вы добавили и зафиксировали их.

(Active Record and Referential Integrity) Active Record и ссылочная целостность
-------------------------------------------------------------------------------

Паттерн Active Record предлагает, что логика в основном должна быть в моделях, а не в базе данных. Соответственно, особенности, такие как триггеры или ограничения, которые делегируют часть логики обратно в базу данных, не всегда предпочтительны.

Валидации, такие как `validates :foreign_key, uniqueness: true`, это один из способов, которым ваши модели могут соблюдать ссылочную целостность. Опция `:dependent` в связях позволяет моделям автоматически уничтожать дочерние объекты при уничтожении родителя. Подобно всему, что работает на уровне приложения, это не может гарантировать ссылочной целостности, таким образом кто-то может добавить еще и [внешние ключи как ограничители ссылочной целостности][] в базе данных.

На практике внешние ключи и уникальные индексы обычно считаются более безопасными при принудительном применении на уровне базы данных. Хотя Active Record не предоставляет прямой поддержки работы с этими функциями уровня базы данных, вы все равно можете использовать метод execute для выполнения произвольных SQL-команд.

Стоит подчеркнуть, что хотя паттерн Active Record подчеркивает сохранение логики в моделях, пренебрежение реализацией внешних ключей и уникальных ограничений на уровне базы данных может потенциально привести к проблемам целостности данных. Поэтому рекомендуется дополнять паттерн AR ограничениями на уровне базы данных в соответствующих случаях. Эти ограничения должны иметь свои четко определенные аналоги в вашем коде с использованием связей и валидаций для обеспечения целостности данных как на уровне приложения, так и на уровне базы данных.

[внешние ключи как ограничители ссылочной целостности]: #foreign-keys

(migrations-and-seed-data) Миграции и сиды
------------------------------------------

Основным назначением миграции Rails является запуск команд, последовательно модифицирующих схему. Миграции также могут быть использованы для добавления или модифицирования данных. Это полезно для существующей базы данных, которую нельзя удалить и пересоздать, такой как база данных на production.

```ruby
class AddInitialProducts < ActiveRecord::Migration[8.0]
  def up
    5.times do |i|
      Product.create(name: "Product ##{i}", description: "A product.")
    end
  end

  def down
    Product.delete_all
  end
end
```

Чтобы добавить изначальные данные в базу данных после создания, в Rails имеется встроенная особенность 'seeds', которая ускоряет процесс. Это особенно полезно при частой перезагрузке базы данных в средах разработки и тестирования, или для настройки изначальных данных в production.

Чтобы начать пользоваться этой особенностью, откройте `db/seeds.rb` и добавьте некоторый код Ruby, а затем запустите `bin/rails db:seed`.

NOTE: Код тут должен быть идемпотентным, чтобы запускаться в любой момент в любом окружении.

```ruby
["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
  MovieGenre.find_or_create_by!(name: genre_name)
end
```

В основном, это более чистый способ настроить базу данных для пустого приложения.

(Old Migrations) Старые миграции
--------------------------------

`db/schema.rb` или `db/structure.sql` это снимок текущего состояния вашей базы данных и авторитетный источник для восстановления этой базы данных. Поэтому возможно удалить или обрезать старые файлы миграций.

Когда вы удалите файлы миграций в директории `db/migrate/`, любая среда, в которой `bin/rails db:migrate` была запущена, когда эти файлы еще существовали, будет хранить ссылки на временные метки миграций во внутренней таблице Rails по имени `schema_migrations`. Подробнее о ней можно прочитать в разделе [Контроль версий миграций Rails](#rails-migration-version-control).

Если вы запустите команду `bin/rails db:migrate:status`, которая отображает статус
(up или down) каждой миграции, вы увидите `********** NO FILE **********`, отображенный рядом с каждым удаленным файлом миграции, который однажды был запущен в указанной среде, но больше не найден в директории `db/migrate/`.

### Миграции из engine

При работе с миграциями из [Engines][], следует учитывать одно предостережение. Задачи Rake для установки миграций из engine являются идемпотентными, что означает, что они получат тот же результат, вне зависимости, сколько раз они были вызваны. Миграции, присутствующие в родительском приложении благодаря предыдущим установками, пропускаются, а отсутствующие копируются с новой временной меткой. Если вы удалите старые миграции engine и запустите задачу установки заново, вы получите новые файлы с новыми временными метками, и `db:migrate` попытается запустить их снова.

Поэтому, вы, в основном, захотите оставить миграции, пришедшие из engine. У них есть специальный комментарий, наподобие:

Поэтому, как правило, вам захочется сохранить миграции, пришедшие из engine. В них есть специальный комментарий, наподобие:

```ruby
# This migration comes from blorgh (originally 20210621082949)
```

[Engine]: /engines

## Разное

### Использование UUID вместо ID для первичных ключей

По умолчанию Rails использует автоматически увеличивающиеся целые числа в качестве первичных ключей для записей базы данных. Однако есть сценарии, в которых использование универсальных уникальных идентификаторов (UUID) в качестве первичных ключей может быть выгодным, особенно в распределенных системах или при необходимости интеграции с внешними сервисами. UUID предоставляют глобально уникальный идентификатор без необходимости полагаться на централизованный источник для генерации идентификаторов.

#### Включение UUID в Rails

Перед использованием UUID в вашем приложении Rails необходимо убедиться, что ваша база данных поддерживает их хранение. Кроме того, может потребоваться настроить адаптер базы данных для работы с UUID.

NOTE: Если вы используете версию PostgreSQL более раннюю, чем 13, вам может потребоваться включить расширение pgcrypto для доступа к функции `gen_random_uuid()`.

1. Конфигурация Rails

    В конфигурационном файле вашего приложения Rails (`config/application.rb`) добавьте следующую строку для настройки Rails на генерацию UUID в качестве первичных ключей по умолчанию:

    ```ruby
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end
    ```

    Этот параметр указывает Rails использовать UUID в качестве типа первичного ключа по умолчанию для моделей ActiveRecord.

2. Добавление ссылок с UUID:

    При создании связей между моделями с использованием ссылок убедитесь, что вы указываете тип данных как :uuid для поддержания согласованности с типом первичного ключа. Например:

    ``` ruby
    create_table :posts, id: :uuid do |t|
      t.references :author, type: :uuid, foreign_key: true
      # другие столбцы...
      t.timestamps
    end
    ```

    В этом примере столбец `author_id` в таблице posts ссылается на столбец `id` таблицы authors. Явно задав тип `:uuid`, вы гарантируете, что столбец внешнего ключа соответствует типу данных первичного ключа, на который он ссылается. Отрегулируйте синтаксис в соответствии с другими связями и базами данных.

3. Изменения миграции

    При генерации миграций для ваших моделей вы заметите, что она указывает id как тип `uuid:`:

    ```bash
      $ bin/rails g migration CreateAuthors
    ```

    ```ruby
    class CreateAuthors < ActiveRecord::Migration[8.0]
      def change
        create_table :authors, id: :uuid do |t|
          t.timestamps
        end
      end
    end
    ```

    что приводит к следующей схеме:

    ```ruby
    create_table "authors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end
    ```

    В этой миграции столбец `id` определен как первичный ключ UUID со значением по умолчанию, генерируемым функцией `gen_random_uuid()`.

UUID гарантированно уникальны глобально в разных системах, что делает их подходящими для распределенных архитектур. Они также упрощают интеграцию с внешними системами или API, предоставляя уникальный идентификатор, который не зависит от централизованной генерации идентификаторов, и в отличие от автоматически увеличивающихся целых чисел, UUID не раскрывают информацию о общем количестве записей в таблице, что может быть полезно для целей безопасности.

Однако UUID также могут влиять на производительность из-за своего размера и их труднее индексировать. UUID будут иметь худшую производительность для записи и чтения по сравнению с целочисленными первичными ключами и внешними ключами.

NOTE: Поэтому важно оценить компромиссы и учитывать конкретные требования вашего приложения перед принятием решения об использовании UUID в качестве первичных ключей.

### (data-migrations) Миграции данных

Миграции данных подразумевают преобразование или перемещение данных внутри вашей базы данных. В Rails обычно не рекомендуется выполнять миграции данных с помощью файлов миграций. Вот почему:

- **Разделение ответственности**: Изменения схемы и изменения данных имеют разные жизненные циклы и цели. Изменения схемы изменяют структуру вашей базы данных, а изменения данных изменяют ее содержимое.
- **Сложность отката**: Откат изменений данных может быть сложным для безопасного и предсказуемого выполнения.
- **Производительность**: Миграции данных могут выполняться долгое время и блокировать ваши таблицы, что влияет на производительность и доступность приложения.

Вместо этого рассмотрите использование гема [`maintenance_tasks`](https://github.com/Shopify/maintenance_tasks). Этот гем предоставляет фреймворк для создания и управления миграциями данных и другими задачами обслуживания безопасным и удобным способом, не вмешиваясь в миграции схемы.
