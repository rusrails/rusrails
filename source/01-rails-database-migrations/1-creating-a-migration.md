# Создание миграции

### Создание автономной миграции

Миграции хранятся как файлы в директории `db/migrate`, один файл на каждый класс. Имя файла имеет вид `YYYYMMDDHHMMSS_create_products.rb`, это означает, что временная метка UTC идентифицирует миграцию, затем идет знак подчеркивания, затем идет имя миграции, где слова разделены подчеркиваниями. Имя класса миграции содержит буквенную часть названия файла, но уже в формате CamelCase (т.е. слова пишутся слитно, каждое слово начинается с большой буквы). Например, `20080906120000_create_products.rb` должен определять класс `CreateProducts`, а `20080906120001_add_details_to_products.rb` должен определять `AddDetailsToProducts`.

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
  def up
    remove_column :products, :part_number
  end

  def down
    add_column :products, :part_number, :string
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

NOTE. Генерируемый файл миграции для деструктивных миграций будет все еще по-старому использовать методы `up` и `down`. Это так, потому что Rails не может знать оригинальные типы данных, которые вы создали когда-то ранее.

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

Можно определить сколько угодно пар имя столбца/тип.

### Поддерживаемые модификаторы типа

Также возможно определить некоторые опции сразу после типа поля в фигурных скобках. Можно использовать следующие модификаторы:

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
