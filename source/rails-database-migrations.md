Миграции Active Record
======================

Миграции - это особенность Active Record, позволяющая наращивать схему вашей базы данных со временем. Вместо того, чтобы записывать изменения схемы на чистом SQL, миграции позволяют использовать простой Ruby DSL для описания изменений в ваших таблицах.

После прочтения этого руководства, вы узнаете о:

* Генераторах, используемых для их создания
* Методах Active Record обеспечивающих взаимодействие с Вашей базой данных
* Задачи Rake, воздействующие на миграции и вашу схему
* Как миграции связаны со `schema.rb`

Обзор миграций
--------------

Миграции - это удобный способ изменять схему вашей базы данных всё время неизменным и простым образом. Они используют Ruby DSL. Поэтому вам не нужно писать SQL вручную, позволяя вашей схеме быть независимой от базы данных.

Каждую миграцию можно рассматривать как новую 'версию' базы данных. Схема изначально ничего не содержит, а каждая миграция изменяет ее, добавляя или убирая таблицы, столбцы или записи. Active Record знает, как обновлять вашу схему со временем, перенося ее из определенной точки в прошлом в последнюю версию. Active Record также обновляет ваш файл `db/schema.rb`, чтобы он соответствовал текущей структуре вашей базы данных.

Вот пример миграции:

```ruby
class CreateProducts < ActiveRecord::Migration
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

Отметьте, что мы определили изменение, которое мы хотим, чтобы произошло при движении вперед во времени. До запуска этой миграции таблицы нет. После - таблица будет существовать. Active Record также знает, как обратить эту миграцию: если мы откатываем эту миграцию, он удалит таблицу.

В базах данных, поддерживающих транзакции с выражениями, изменяющими схему, миграции оборачиваются в транзакцию. Если база данных это не поддерживает, и миграция проваливается, части, которые прошли успешно, не будут откаченны назад. Вам нужно произвести откат вручную.

Если хотите миграцию для чего-то, что Active Record не знает, как обратить, вы можете использовать `reversible`:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :products do |t|
        dir.up   { t.change :price, :string }
        dir.down { t.change :price, :integer }
      end
    end
  end
end
```

С другой стороны, можно использовать `up` и `down` вместо `change`:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration
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

Создание миграции
-----------------

### Создание автономной миграции

Миграции хранятся как файлы в директории `db/migrate`, один файл на каждый класс. Имя файла имеет вид `YYYYMMDDHHMMSS_create_products.rb`, это означает, что временная метка UTC идентифицирует миграцию, затем идет знак подчеркивания, затем идет имя миграции, где слова разделены подчеркиваниями. Имя класса миграции содержит буквенную часть названия файла, но уже в формате CamelCase (т.е. слова пишутся слитно, каждое слово начинается с большой буквы). Например, `20080906120000_create_products.rb` должен определять класс `CreateProducts`, а `20080906120001_add_details_to_products.rb` должен определять `AddDetailsToProducts`. Rails использует эту метку, чтобы определить, какая миграция должна быть запущена и в каком порядке, так что если вы копируете миграции из другого приложения или генерируете файл сами, будьте боле бдительны.

Конечно, вычисление временных меток не забавно, поэтому Active Record предоставляет генератор для управления этим:

```bash
$ rails generate migration AddPartNumberToProducts
```

Это создат пустую, но правильно названную миграцию:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration
  def change
  end
end
```

Если имя миграции имеет форму "AddXXXToYYY" или "RemoveXXXFromYYY" и далее следует перечень имен столбцов и их типов, то в миграции будут созданы соответствующие выражения `add_column` и `remove_column`.

```bash
$ rails generate migration AddPartNumberToProducts part_number:string
```

создаст

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration
  def change
    add_column :products, :part_number, :string
  end
end
```

Аналогично,

```bash
$ rails generate migration RemovePartNumberFromProducts part_number:string
```

создаст

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration
  def change
    remove_column :products, :part_number, :string
  end
end
```

Вы не ограничены одним создаваемым столбцом. Например

```bash
$ rails generate migration AddDetailsToProducts part_number:string price:decimal
```

создаст

```ruby
class AddDetailsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :part_number, :string
    add_column :products, :price, :decimal
  end
end
```

Как всегда, то, что было сгенерировано, является всего лишь стартовой точкой. Вы можете добавлять и убирать строки, как считаете нужным, отредактировав файл `db/migrate/YYYYMMDDHHMMSS_add_details_to_products.rb`.

Также генератор принимает такой тип столбца, как `references` (или его псевдоним `belongs_to`). Например

```bash
$ rails generate migration AddUserRefToProducts user:references
```

создаст

```ruby
class AddUserRefToProducts < ActiveRecord::Migration
  def change
    add_reference :products, :user, index: true
  end
end
```

Эта миграция создаст столбец `user_id` и соответствующий индекс.

Существует также генератор, который будет производить объединение таблиц, если `JoinTable` является частью названия.

Например

```bash
$ rails generate migration CreateJoinTableCustomerProduct customer product
```
Сгенерирует следующую миграцию:

```ruby
class CreateJoinTableCustomerProduct < ActiveRecord::Migration
  def change
    create_join_table :customers, :products do |t|
      # t.index [:customer_id, :product_id]
      # t.index [:product_id, :customer_id]
    end
  end
end
```
### Генераторы модели

Генераторы модели и скаффолда создадут миграции, подходящие для создания новой модели. Миграция будет содержать инструкции для создания соответствующей таблицы. Если вы сообщите Rails, какие столбцы вы хотите, то выражения для добавления этих столбцов также будут созданы. Например, запуск

```bash
$ rails generate model Product name:string description:text
```

создаст миграцию, которая выглядит так

```ruby
class CreateProducts < ActiveRecord::Migration
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

### Поддерживаемые модификаторы типа

Также можно определить некоторые опции сразу после типа поля в фигурных скобках.
Можно использовать следующие модификаторы:

* `limit`        Устанавливает максимальный размер полей `string/text/binary/integer`
* `precision`    Определяет точность для полей `decimal`
* `scale`        Определяет масштаб для полей `decimal`
* `polymorphic`  Добавляет столбец `type` для связей `belongs_to`

К примеру, запуск

```bash
$ rails generate migration AddDetailsToProducts price:decimal{5,2} supplier:references{polymorphic}
```

создат миграцию, которая выглядит как эта:

```ruby
class AddDetailsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :price, precision: 5, scale: 2
    add_reference :products, :user, polymorphic: true, index: true
  end
end
```

Написание миграции
------------------

Как только вы создали свою миграцию, используя один из генераторов, пришло время поработать!

### Создание таблицы

Метод `create_table` один из самых фундаментальных, но в большинстве случаев, он будет создан для вас генератором модели или скаффолда. Обычное использование такое

```ruby
create_table :products do |t|
  t.string :name
end
```

Это создаст таблицу `products` со столбцом `name` (и, как обсуждалось выше, подразумеваемым столбцом `id`).

По умолчанию `create_table` создаст первичный ключ, названный `id`. Вы можете изменить имя первичного ключа с помощью опции `:primary_key` (не забудьте также обновить соответствующую модель), или, если вы вообще не хотите первичный ключ, можно указать опцию `id: false`. Если нужно передать базе данных специфичные опции, вы можете поместить фрагмент `SQL` в опцию `:options`. Например,

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

добавит `ENGINE=BLACKHOLE` к SQL выражению, используемому для создания таблицы (при использовании MySQL по умолчанию передается `ENGINE=InnoDB`).

### Создание соединительной таблицы

Миграционный метод `create_join_table` создает соединительную страницу HABTM. Обычное использование будет таким:

```ruby
create_join_table :products, :categories
```

что создаст таблицу `categories_products` с двумя столбцами по имени `category_id` и `product_id`. У этих столбцов есть опция `:null`, установленная в `false` по умолчанию.

Если хотите изменить имя таблицы, используйте опцию `:table_name`. Например,

```ruby
create_join_table :products, :categories, table_name: :categorization
```

создаст таблицу `categorization`.

По умолчанию `create_join_table` создаст два столбца без опций, но можно определить эти опции с использованием опции `:column_options`. Например,

```ruby
create_join_table :products, :categories, column_options: {null: true}
```

создаст `product_id` и `category_id` с опцией `:null` равной `true`.

### Изменение таблиц

Близкий родственник `create_table` это `change_table`, используемый для изменения существующих таблиц. Он используется подобно `create_table`, но у объекта, передаваемого в блок, больше методов. Например

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

удаляет столбцы `description` и `name`, создает строковый столбец `part_number` и добавляет индекс на него. Наконец, он переименовывает столбец `upccode`.

### Когда хелперов недостаточно

Если хелперов, предоставленных Active Record, недостаточно, можно использовать метод `execute` для запуска произвольного SQL:

```ruby
Products.connection.execute('UPDATE `products` SET `price`=`free` WHERE 1')
```

Больше подробностей и примеров отдельных методов содержится в документации по API. В частности, документация для [`ActiveRecord::ConnectionAdapters::SchemaStatements`](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html) (который обеспечивает методы, доступные в методах `up`, `down` и `change`), [`ActiveRecord::ConnectionAdapters::TableDefinition`](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html) (который обеспечивает методы, доступные у объекта, переданного методом `create_table`) и [`ActiveRecord::ConnectionAdapters::Table`](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Table.html) (который обеспечивает методы, доступные у объекта, переданного методом `change_table`).

### Использование метода `change`

Метод `change` это основной метод написания миграций. Он работает в большинстве случаев, когда Active Record знает, как обратить миграцию автоматически. На текущий момент метод `change` поддерживает только эти определения миграции:

* `add_column`
* `add_index`
* `add_reference`
* `add_timestamps`
* `create_table`
* `create_join_table`
* `drop_table` (Необходимо указать блок)
* `drop_join_table` (Необходимо указать блок)
* `remove_timestamps`
* `rename_column`
* `rename_index`
* `remove_reference`
* `rename_table`

`change_table` так же является обратимым, пока блок не вызывает `change`, `change_default` или `remove`.

Если вы нуждаетесь в использовании иных методов, следует использовать `reversible` или писать методы `up` и `down` вместо метода `change`.

### Использование `reversible`

Комплексная миграция может включать процессы, которые Active Record не знает как обратить. Вы можете использовать `reversible`, чтобы указать что делать когда миграция требует отката. Например,

```ruby
class ExampleMigration < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.references :category
    end

    reversible do |dir|
      dir.up do
        #add a foreign key
        execute <<-SQL
          ALTER TABLE products
            ADD CONSTRAINT fk_products_categories
            FOREIGN KEY (category_id)
            REFERENCES categories(id)
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE products
            DROP FOREIGN KEY fk_products_categories
        SQL
      end
    end

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end
```

Использование `reversible` гарантирует что инструкции выполнятся в правильном порядке. Если предыдущий пример миграции откатывается, `down` блок начнёт выполнятся после того как столбец `home_page_url` будет удалён и перед перед тем как произойдёт удаление таблицы `products`.

Иногда миграция будет делать то, что просто необратимо; например, она может уничтожить некоторые данные. В таких случаях, вы можете вызвать `ActiveRecord::IrreversibleMigration` в вашем `down` блоке. Если кто-либо попытается отменить вашу миграцию, будет отображена ошибка, что это не может быть выполнено.

### Использование методов `up`/`down`

Вы так же можете использовать старый стиль миграций используя `up` и `down` методы, вместо `change`
Метод `up` должен описывать изменения, которые вы хотите внести в вашу схему, а метод `down` вашей миграции должен обращать изменения, внесенные методом  `up`. Другими словами, схема базы данных должна остаться неизменной после выполнения `up`, а затем `down`. Например, если вы создали таблицу в методе `up`, ее следует удалить в методе `down`. Разумно производить отмену изменений в полностью противоположном порядке тому, в котором они сделаны в методе `up`. Например в сравнении с кодом `reversible` следующий код будет эквивалентным

```ruby
class ExampleMigration < ActiveRecord::Migration
  def up
    create_table :products do |t|
      t.references :category
    end

    #добавляем внешний ключ
    execute <<-SQL
      ALTER TABLE products
        ADD CONSTRAINT fk_products_categories
        FOREIGN KEY (category_id)
        REFERENCES categories(id)
    SQL

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end

  def down
    rename_column :users, :email_address, :email
    remove_column :users, :home_page_url

    execute <<-SQL
      ALTER TABLE products
        DROP FOREIGN KEY fk_products_categories
    SQL

    drop_table :products
  end
end
```

Если ваша миграция не обратима вам следует вызвать `ActiveRecord::IrreversibleMigration` из вашего метода `down`. Если кто-либо попытается отменить вашу миграцию, будет отображена ошибка, что это не может быть выполнено.

### Возвращение к предыдущим миграциям

Вы можете использовать возможность Active Record откатить миграции используя `revert` метод:

```ruby
require_relative '2012121212_example_migration'

class FixupExampleMigration < ActiveRecord::Migration
  def change
    revert ExampleMigration

    create_table(:apples) do |t|
      t.string :variety
    end
  end
end
```

Метод `revert` так же может принимает блок. Это может быть полезным для отката выбранной части предыдущих миграций. Для примера, давайте представим что `ExampleMigration` закомичена и уже поздно решать, хорошо ли было бы сериализовать список продуктов или нет. Она может быть написана так:

```ruby
class SerializeProductListMigration < ActiveRecord::Migration
  def change
    add_column :categories, :product_list

    reversible do |dir|
      dir.up do
        # transfer data from Products to Category#product_list
      end
      dir.down do
        # create Products from Category#product_list
      end
    end

    revert do
      # copy-pasted code from ExampleMigration
      create_table :products do |t|
        t.references :category
      end

      reversible do |dir|
        dir.up do
          #add a foreign key
          execute <<-SQL
            ALTER TABLE products
              ADD CONSTRAINT fk_products_categories
              FOREIGN KEY (category_id)
              REFERENCES categories(id)
          SQL
        end
        dir.down do
          execute <<-SQL
            ALTER TABLE products
              DROP FOREIGN KEY fk_products_categories
          SQL
        end
      end

      # The rest of the migration was ok
    end
  end
end
```

Подобная миграция так же может быть написана без использования `revert`, но это бы привело к ещё нескольким шагам: изменение порядка(следования) `create table` и `reversible`, замена `create_table` на `drop_table` и в конечном итоге изменение `up` `down` наоборот. Обо всём этом уже позаботился `revert`.

Запуск миграций
---------------

Rails предоставляет ряд задач rake для запуска определенных наборов миграций.

Самая первая команда Rake, относящаяся к миграциям, которую вы будете использовать, это `rake db:migrate`. В своей основной форме она всего лишь запускает метод `change` или `up` для всех миграций, которые еще не были запущены. Если таких миграций нет, она выходит. Она запустит эти миграции в порядке, основанном на дате миграции.

Заметьте, что запуск `db:migrate` также вызывает задачу `db:schema:dump`, которая обновляет ваш файл `db/schema.rb` в соответствии со структурой вашей базы данных.

Если вы определите целевую версию, Active Record запустит требуемые миграции (методы up, down или change), пока не достигнет требуемой версии. Версия это числовой префикс у файла миграции. Например, чтобы мигрировать к версии 20080906120000, запустите

```bash
$ rake db:migrate VERSION=20080906120000
```

Если версия 20080906120000 больше текущей версии (т.е. миграция вперед) это запустит метод `change` (или `up`) для всех миграций до и включая 20080906120000, но не запустит какие-либо поздние миграции. Если миграция назад, это запустит метод `down` для всех миграций до, но не включая, 20080906120000.

### Откат

Обычная задача это откатить последнюю миграцию. Например, вы сделали ошибку и хотите исправить ее. Можно отследить версию предыдущей миграции и произвести миграцию до нее, но можно поступить проще, запустив

```bash
$ rake db:rollback
```

Это вернёт ситуацию к последней миграции, или обратив метод `change`, или запустив метод `down`. Если нужно отменить несколько миграций, можно указать параметр `STEP`:

```bash
$ rake db:rollback STEP=3
```

произойдёт откат на 3 последних миграции.

Задача `db:migrate:redo` это ярлык для выполнения отката, а затем снова запуска миграции. Так же, как и с задачей `db:rollback` можно указать параметр `STEP`, если нужно работать более чем с одной версией, например

```bash
$ rake db:migrate:redo STEP=3
```

Ни одна из этих команд Rake не может сделать ничего такого, чего нельзя было бы сделать с `db:migrate`. Они просто более удобны, так как вам не нужно явно указывать версию миграции, к которой нужно мигрировать.

### Сброс базы данных

Задача `db:reset` удаляет базу данных, пересоздает ее и загружает в нее текущую схему.

NOTE. Это не то же самое, что запуск всех миграций. Оно использует только текущее содержимое файла schema.rb. Если миграция не может быть откачена,
'rake db:reset' может не помочь вам. Подробнее об экспорте схемы смотрите "Экспорт схемы":/rails-database-migrations/schema-dumping-and-you.

### Запуск определенных миграций

Если вам нужно запустить определенную миграцию (up или down), задачи `db:migrate:up` и `db:migrate:down` сделают это. Просто определите подходящий вариант и у соответствующей миграции будет вызван метод `change`, `up` или `down`, например

```bash
$ rake db:migrate:up VERSION=20080906120000
```

запустит метод `up` у миграции 20080906120000. Эта задача сперва проверит, была ли миграция уже выполнена, и ничего делать не будет, если Active Record считает, что она уже была запущена.

### Запуск миграций в различных средах

По умолчанию запуск `rake db:migrate` запустится в окружении `development`. Для запуска миграций в другом окружении, его можно указать, используя переменную среды `RAILS_ENV` при запуске команды. Например, для запуска миграций в среде `test`, следует запустить:

```bash
$ rake db:migrate RAILS_ENV=test
```

### Изменение вывод результата запущенных миграций

По умолчанию миграции говорят нам только то, что они делают, и сколько времени это заняло. Миграция, создающая таблицу и добавляющая индекс, выдаст что-то наподобие этого

```bash
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

Некоторые методы в миграциях позволяют вам все это контролировать:

|Метод             |Назначение|
|------------------|----------|
|suppress_messages |Принимает блок как аргумент и запрещает любой вывод, сгенерированный этим блоком.|
|say               |Принимает сообщение как аргумент и выводит его как есть. Может быть передан второй булевый аргумент для указания, нужен отступ или нет.|
|say_with_time     |Выводит текст вместе с продолжительностью выполнения блока. Если блок возвращает число, предполагается, что это количество затронутых строк.|

Например, эта миграция

```ruby
class CreateProducts < ActiveRecord::Migration
  def change
    suppress_messages do
      create_table :products do |t|
        t.string :name
        t.text :description
        t.timestamps
      end
    end

    say "Created a table"

    suppress_messages {add_index :products, :name}
    say "and an index!", true

    say_with_time 'Waiting for a while' do
      sleep 10
      250
    end
  end
end
```

сгенерирует следующий результат

```bash
==  CreateProducts: migrating =================================================
-- Created a table
   -> and an index!
-- Waiting for a while
   -> 10.0013s
   -> 250 rows
==  CreateProducts: migrated (10.0054s) =======================================
```

Если хотите, чтобы Active Record ничего не выводил, запуск `rake db:migrate VERBOSE=false` запретит любой вывод.

Изменение существующих миграций
--------------------------------

Периодически вы будете делать ошибки при написании миграции. Если вы уже запустили миграцию, вы не сможете просто отредактировать миграцию и запустить ее снова: Rails посчитает, что он уже выполнял миграцию, и ничего не сделает при запуске `rake db:migrate`. Вы должны откатить миграцию (например, с помощью `rake db:rollback`), отредактировать миграцию и затем запустить `rake db:migrate` для запуска исправленной версии.

В целом, редактирование существующих миграций не хорошая идея. Вы создадите дополнительную работу себе и своим коллегам, и вызовете море головной боли, если существующая версия миграции уже была запущена в production. Вместо этого, следует написать новую миграцию, выполняющую требуемые изменения. Редактирование только что созданной миграции, которая еще не была закомичена в систему контроля версий (или, хотя бы, не ушла дальше вашей рабочей машины) относительно безвредно.

Метод `revert` может быть очень полезным при написании новой миграции для возвращения предыдущей в целом или какой то части (смотрите [Возвращение к предыдущим миграциям](https://github.com/morsbox/rusrails/blob/4.0/source/01-rails-database-migrations/2-writing-a-migration.md)

Использование моделей в ваших миграциях
---------------------------------------

При создании или обновлении данных зачастую хочется использовать одну из ваших моделей. Ведь они же существуют, чтобы облегчить доступ к лежащим в их основе данным. Это осуществимо, но с некоторыми предостережениями.

Например, проблемы происходят, когда модель использует столбцы базы данных, которые (1) в текущий момент отсутствуют в базе данных и (2) будут созданы в этой или последующих миграциях.

Рассмотрим пример, когда Алиса и Боб работают над одним и тем же участком кода, содержащим модель `Product`

Боб ушел в отпуск.

Алиса создала миграцию для таблицы `products`, добавляющую новый столбец, и инициализировала его. Она также добавила в модели Product валидацию на новый столбец.

```ruby
# db/migrate/20100513121110_add_flag_to_product.rb

class AddFlagToProduct < ActiveRecord::Migration
  def change
    add_column :products, :flag, :boolean
    reversible do |dir|
      dir.up { Product.update_all flag: false }
    end
    Product.update_all flag: false
  end
end
```

```ruby
# app/model/product.rb

class Product < ActiveRecord::Base
  validates :flag, presence: true
end
```

Алиса добавила вторую миграцию, добавляющую и инициализирующую другой столбец в таблице `products`, и снова добавила в модели `Product` валидацию на новый столбец.

```ruby
# db/migrate/20100515121110_add_fuzz_to_product.rb

class AddFuzzToProduct < ActiveRecord::Migration
  def change
    add_column :products, :fuzz, :string
    reversible do |dir|
      dir.up { Product.update_all fuzz: 'fuzzy' }
    end
  end
end
```

```ruby
# app/model/product.rb

class Product < ActiveRecord::Base
  validates :flag, :fuzz, presence: true
end
```

Обе миграции работают для Алисы.

Боб вернулся с отпуска, и:

*   Обновил исходники - содержащие обе миграции и последнюю версию модели Product.
*   Запустил невыполненные миграции с помощью `rake db:migrate`, включая обновляющие модель `Product`.

Миграции не выполнятся, так как при попытке сохранения модели, она попытается валидировать второй добавленный столбец, отсутствующий в базе данных на момент запуска _первой_ миграции.

```
rake aborted!
An error has occurred, this and all later migrations canceled:

undefined method `fuzz' for #<Product:0x000001049b14a0>
```

Это исправляется путем создания локальной модели внутри миграции. Это предохраняет Rails от запуска валидаций, поэтому миграции проходят.

При использовании локальной модели неплохо бы вызвать `Product.reset_column_information` для обновления кэша `ActiveRecord` для модели `Product` до обновления данных в базе данных.

Если бы Алиса сделала бы так, проблем бы не было:

```ruby
# db/migrate/20100513121110_add_flag_to_product.rb

class AddFlagToProduct < ActiveRecord::Migration
  class Product < ActiveRecord::Base
  end

  def change
    add_column :products, :flag, :boolean
    Product.reset_column_information
    reversible do |dir|
      dir.up { Product.update_all flag: false }
    end
  end
end
```

```ruby
# db/migrate/20100515121110_add_fuzz_to_product.rb

class AddFuzzToProduct < ActiveRecord::Migration
  class Product < ActiveRecord::Base
  end

  def change
    add_column :products, :fuzz, :string
    Product.reset_column_information
    reversible do |dir|
      dir.up { Product.update_all fuzz: 'fuzzy' }
    end
  end
end
```

Имеется несколько способов, при которых вышеприведенные примеры могут сработать плохо.

Например, представим, что Алиса создала миграцию, избирательно обновляющую поле `description` для определенных продуктов. Она запускает миграцию, комитит код, и начинает работать над следующей задачей, которая добавляет новый столбец `fuzz` в таблицу продуктов.

Она создает две миграции для этой новой задачи, одна из которых добавляет новый столбец, а вторая избирательно обновляет столбец `fuzz`, основываясь на других атрибутах продукта.

Эти миграции прекрасно запускаются, но когда Боб возвращается из отпуска вызывает `rake db:migrate` для запуска всех невыполненных миграций, он получает неуловимый баг: Описания имеют значения по умолчанию, столбец `fuzz` присутствует, но `fuzz` равно nil для всех продуктов.

Решением снова является использование `Product.reset_column_information` до обращения к модели Product в миграции, чтобы убедиться в знании Active Record о текущей структуре таблицы до манипуляции с данными в этих записях.

Экспорт схемы
-------------

### Для чего нужны файлы схемы?

Миграции, какими бы не были они мощными, не являются авторитетным источником для вашей схемы базы данных. Это роль достается или файлу `db/schema.rb`, или файлу SQL, которые генерирует Active Record при исследовании базы данных. Они разработаны не для редактирования, они всего лишь отражают текущее состояние базы данных.

Не нужно (это может привести к ошибке) развертывать новый экземпляр приложения, применяя всю историю миграций. Намного проще и быстрее загрузить в базу данных описание текущей схемы.

Например, как создается тестовая база данных: текущая рабочая база данных выгружается (или в `db/schema.rb`, или в `db/structure.sql`), а затем загружается в тестовую базу данных.

Файлы схемы также полезны, если хотите быстро взглянуть, какие атрибуты есть у объекта Active Record. Эта информация не содержится в коде модели и часто размазана по нескольким миграциям, но собрана воедино в файле схемы. Имеется гем [annotate_models](https://github.com/ctran/annotate_models), который автоматически добавляет и обновляет комментарии в начале каждой из моделей, составляющих схему, если хотите такую функциональность.

### Типы выгрузок схемы

Есть два способа выгрузить схему. Они устанавливаются в `config/environment.rb` в свойстве `config.active_record.schema_format`, которое может быть или `:sql`, или `:ruby`.

Если выбрано `:ruby`, тогда схема храниться в `db/schema.rb`. Посмотрев в этот файл, можно увидеть, что он очень похож на одну большую миграцию:

```ruby
ActiveRecord::Schema.define(version: 20080906171750) do
  create_table "authors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "part_number"
  end
end
```

Во многих случаях этого достаточно. Этот файл создается с помощью проверки базы данных и описывает свою структуру, используя `create_table`, `add_index` и так далее. Так как он не зависит от типа базы данных, он может быть загружен в любую базу данных, поддерживаемую Active Record. Это очень полезно, если Вы распространяете приложение, которое может быть запущено на разных базах данных.

Однако, тут есть компромисс: `db/schema.rb` не может описать специфичные элементы базы данных, такие как внешний ключ (как ограничитель ссылочной целостности), триггеры или хранимые процедуры. В то время как в миграции вы можете выполнить произвольное выражение SQL, выгрузчик схемы не может воспроизвести эти выражения из базы данных. Если Вы используете подобные функции, нужно установить формат схемы :sql.

Вместо использования выгрузчика схемы Active Records, структура базы данных будет выгружена с помощью инструмента, предназначенного для этой базы данных (с помощью задачи `db:structure:dump` Rake) в `db/structure.sql`. Например, для PostgreSQL используется утилита `pg_dump`. Для MySQL этот файл будет содержать результат `SHOW CREATE TABLE` для разных таблиц.

Загрузка таких схем это просто запуск содержащихся в них выражений SQL. По определению создастся точная копия структуры базы данных. Использование формата `:sql` схемы, однако, предотвращает загрузку схемы в СУБД иную, чем использовалась при ее создании.

### Выгрузки схем и контроль исходного кода

Поскольку выгрузки схем это авторитетный источник для вашей схемы базы данных, очень рекомендовано включать их в контроль исходного кода.

Active Record и ссылочная целостность
-------------------------------------

Способ Active Record требует, чтобы логика была в моделях, а не в базе данных. По большому счету, функции, такие как триггеры или внешние ключи как ограничители ссылочной целостности, которые переносят часть логики обратно в базу данных, не используются активно.

Валидации, такие как `validates :foreign_key, uniqueness: true`, это один из способов, которым ваши модели могут соблюдать ссылочную целостность. Опция `:dependent` в связях позволяет моделям автоматически уничтожать дочерние объекты при уничтожении родителя. Подобно всему, что работает на уровне приложения, это не может гарантировать ссылочной целостности, таким образом кто-то может добавить еще и внешние ключи как ограничители ссылочной целостности в базе данных.

Хотя Active Record не предоставляет каких-либо инструментов для работы напрямую с этими функциями, можно использовать метод `execute` для запуска произвольного SQL. Можно использовать плагины, такие как [foreigner](https://github.com/matthuhiggins/foreigner), добавляющие поддержку внешних ключей в Active Record (включая поддержку выгрузки внешних ключей в `db/schema.rb`).

Миграции и сиды
---------------

Кто-то использует миграции для добавления данных в базу данных:

```ruby
class AddInitialProducts < ActiveRecord::Migration
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

Однако, в Rails есть особенность 'seeds' которая должна быть использована для заполнения базы данных начальными данными. Это действительно простая особенность: просто заполните `db/seeds.rb` некоторым кодом Ruby и запустите `rake db:seed`:

```ruby
5.times do |i|
  Product.create(name: "Product ##{i}", description: "A product.")
end
```

В основном, это более чистый способ настроить базу данных для пустого приложения.
