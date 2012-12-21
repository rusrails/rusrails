# Написание миграции

Как только вы создали свою миграцию, используя один из генераторов, пришло время поработать!

### Создание таблицы

Метод `create_table` один из основных, но в большинстве случаев будет создан для вас генератором модли или скаффолда. Обычное использование такое

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

добавит `ENGINE=BLACKHOLE` к выражению SQL, используемому для создания таблицы (при использовании MySQL по умолчанию передается `ENGINE=InnoDB`).

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

Больше подробностей и примеров отдельных методов содержится в документации по API. В частности, документация для [`ActiveRecord::ConnectionAdapters::SchemaStatements`](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html) (который обеспечивает методы, доступные в методах `up` и `down`), [`ActiveRecord::ConnectionAdapters::TableDefinition`](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html) (который обеспечивает методы, доступные у объекта, переданного методом `create_table`) и [`ActiveRecord::ConnectionAdapters::Table`](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Table.html) (который обеспечивает методы, доступные у объекта, переданного методом `change_table`).

### Использование метода `change`

Метод `change` это основной метод написания миграций. Он работает в большинстве случаев, когда Active Record знает, как обратить миграцию автоматически. На текущий момент метод `change` поддерживает только эти определения миграции:

* `add_column`
* `add_index`
* `add_timestamps`
* `create_table`
* `remove_timestamps`
* `rename_column`
* `rename_index`
* `rename_table`

Если вы нуждаетесь в использовании иных методов, следует писать методы `up` и `down` вместо метода `change`.

### Использование методов `up`/`down`

Метод `up` должен описывать изменения, которые выхотите внести в вашу схему, а метод `down` вашей миграции должен обращать изменения, внесенные методом  `up`. Другими словами, схема базы данных должна остаться неизменной после выполнения `up`, а затем `down`. Например, если вы создали таблицу в методе `up`, ее следует адлить в методе `down`. Разумно производить отмену изменений в полностью противоположном порядке тому, в котором они сделаны в методе `up`. Например,

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

Иногда ваша миграция делает то, что невозможно отменить, например, уничтожает какую-либо информацию. В таких случаях можете вызвать `IrreversibleMigration` из вашего метода `down`. Если кто-либо попытается отменить вашу миграцию, будет отображена ошибка, что это не может быть выполнено.
