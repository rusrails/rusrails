Основы Active Record
====================

Это руководство является введением в Active Record.

После прочтения этого руководства, вы узнаете:

* Как Active Record вписывается в парадигму Model-View-Controller (MVC).
* Что такое паттерны Object Relational Mapping и Active Record, и как они используются в Rails.
* Как использовать модели Active Record для управления информацией, хранящейся в реляционной базе данных.
* О соглашении по именованиям схемы Active Record.
* О концепциях миграций базы данных, валидаций, колбэков и связей.

Что такое Active Record?
------------------------

Active Record является частью M в [MVC][] - модели - это уровень системы, отвечающий за представление данных и бизнес-логики. Active Record помогает создавать и использовать Ruby-объекты, атрибуты которых требуют постоянного хранения в базе данных.

NOTE: В чем разница между Active Record и Active Model? Моделирование данных возможно с помощью Ruby-объектов, которым *не обязательно* иметь поддержку базы данных. [Active Model](/active-model-basics) обычно используется для этого в Rails, делая Active Record и Active Model частью M в MVC, также как и ваши собственные обычные Ruby-объекты.

Термин "Active Record" также относится к шаблону архитектуры программного обеспечения. Active Record в Rails является реализацией этого шаблона.  Это также описание того, что иногда называется системой [Object Relational Mapping][ORM]. В следующих разделах объясняются эти термины.

### Паттерн Active Record

[Шаблон Active Record описал Martin Fowler][MFAR] в книге _Patterns of Enterprise Application Architecture_ как "объект, который оборачивает строку в таблице базы данных, инкапсулирует доступ к базе данных и добавляет к этим данным доменную логику". Объекты Active Record содержат как данные, так и поведение. Классы Active Record тесно связаны со структурой записей лежащей в основе базы данных. Таким образом, пользователи могут легко читать из базы данных и записывать в нее, как вы увидите в приведенных ниже примерах.

### Object Relational Mapping

Object Relational Mapping, обычно называемое ORM, - это техника, которая связывает полноценные объекты языка программирования с таблицами в реляционной системе управления базами данных (RDBMS). В случае приложения Rails это объекты Ruby. С помощью ORM атрибуты объектов Ruby, а также связи между объектами, можно легко хранить и извлекать из базы данных без непосредственного написания SQL-запросов. В целом, ORM минимизируют объем кода доступа к базе данных, который вам приходится писать.

NOTE: Чтобы полностью понять Active Record, будут полезны базовые знания реляционных систем управления базами данных (RDBMS) или языка структурированных запросов (SQL). Если хотите узнать больше, обратитесь [к этому учебному пособию][sqlcourse] (или [к этому][rdbmsinfo]) или изучите их другими способами.

### Active Record это фреймворк ORM

Active Record позволяет нам делать следующее с помощью объектов Ruby:

* Представления моделей и их данных.
* Представления связей между моделями.
* Представления иерархий наследования с помощью связанных моделей.
* Валидации моделей до того, как они станут персистентными в базе данных.
* Выполнения операций с базой данных в объектно-ориентированном стиле.

[MVC]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller
[MFAR]: https://www.martinfowler.com/eaaCatalog/activeRecord.html
[ORM]: https://en.wikipedia.org/wiki/Object-relational_mapping
[sqlcourse]: https://www.khanacademy.org/computing/computer-programming/sql
[rdbmsinfo]: https://www.devart.com/what-is-rdbms/

Соглашения над конфигурацией в Active Record
--------------------------------------------

При написании приложения с использованием других языков программирования или фреймворков часто требуется писать много конфигурационного кода. В частности, это справедливо для фреймворков ORM. Однако, если следовать соглашениям, принятым Rails, при создании моделей Active Record вам потребуется писать очень мало или совсем не писать код конфигурации.

Rails использует принцип, согласно которому если вы конфигурируете свои приложения одинаковым образом в большинстве случаев, то этот способ должен быть установлен по умолчанию. Явная конфигурация должна требоваться только в тех случаях, когда вы не можете следовать соглашениям.

Чтобы воспользоваться преимуществами соглашения над конфигурацией в Active Record, необходимо соблюдать некоторые соглашения об именах и схемах. А в случае необходимости можно [переопределить соглашения об именовании](#overriding-the-naming-conventions).

### Соглашения по именованию

Active Record использует следующее соглашение об именах для сопоставления между моделями (представленными объектами Ruby) и таблицами базы данных:

Rails будет использовать множественное число классов ваших моделей, чтобы найти соответствующую таблицу базы данных. Например, класс с именем `Book` сопоставляется с таблицей базы данных `books`. Механизмы множественного числа Rails очень мощны и способны образовывать множественное число (и единственное число) как для правильных, так и для неправильных английских слов. В этом используется метод [pluralize](https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-pluralize) из [Active Support](/active-support-core-extensions#pluralize).

Для имен классов, состоящих из двух или более слов, имя класса модели будет следовать соглашениям Ruby об использовании UpperCamelCase. Имя таблицы базы данных в этом случае будет иметь формат snake_case. Например:

* `BookClub` - класс модели, единственное число, с заглавной первой буквы каждого слова.
* `book_clubs` - соответствующая таблица базы данных, множественное число, с разделителями подчеркивания между словами.

Вот еще несколько примеров имен классов моделей и соответствующих имен таблиц:

| Модель / Класс   | Таблица / Схема |
| ---------------- | --------------- |
| `Article`        | `articles`      |
| `LineItem`       | `line_items`    |
| `Product`        | `products`      |
| `Person`         | `people`        |

### Соглашения схемы

Active Record также использует соглашения о именах столбцов в таблицах базы данных, зависящих от назначения этих столбцов.

* **Первичные ключи** - По умолчанию Active Record использует числовой столбец с именем `id` как первичный ключ таблицы (`bigint` для PostgreSQL, MySQL и MariaDB, `integer` для SQLite). Этот столбец будет автоматически создан при использовании [миграций Active Record](#migrations) для создания таблиц.
* **Внешние ключи** - Эти поля должны именоваться по образцу `singularized_table_name_id` (т.е., `order_id`, `line_item_id`). Это поля, которые ищет Active Record при создании связей между вашими моделями.

Также имеются некоторые опциональные имена столбцов, добавляющие дополнительные особенности для экземпляров Active Record:

* `created_at` - Автоматически будут установлены текущие дата и время при изначальном создании записи.
* `updated_at` - Автоматически будут установлены текущие дата и время всякий раз, когда создается или обновляется запись.
* `lock_version` - Добавляет [оптимистическую блокировку](https://api.rubyonrails.org/classes/ActiveRecord/Locking.html) к модели.
* `type` - Указывает, что модель использует [Single Table Inheritance](https://api.rubyonrails.org/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance).
* `(association_name)_type` - Хранит тип для [полиморфных связей](/active-record-associations#polymorphic-associations).
* `(table_name)_count` - Используется для кэширования количества принадлежащих по связи объектов. Например, если у класса `Article` несколько `Comment`, столбец `comments_count` в таблице `articles` закэширует количество существующих комментариев для каждой статьи.

NOTE: Хотя эти имена столбцов опциональны, они зарезервированы Active Record. Избегайте зарезервированных ключевых слов при именовании столбцов таблицы. Например, `type` - это зарезервированное слово для определения таблицы, использующей наследование с единой таблицей (STI). Если вы не используете STI, используйте другое слово, аккуратно описывающее данные, которые вы моделируете.

Создание моделей Active Record
------------------------------

При генерации Rails-приложения в `app/models/application_record.rb` будет создан абстрактный класс `ApplicationRecord`. Класс `ApplicationRecord` наследуется от [`ActiveRecord::Base`](https://api.rubyonrails.org/classes/ActiveRecord/Base.html) и именно он превращает обычный класс Ruby в модель Active Record.

`ApplicationRecord` является базовым классом для всех моделей Active Record в вашем приложении. Чтобы создать новую модель, просто наследуйтесь от класса `ApplicationRecord`, и все готово:

```ruby
class Book < ApplicationRecord
end
```

Создастся модель `Book`, сопоставленная с таблицей `books` в базе данных, где каждый столбец таблицы сопоставляется с атрибутами класса `Book`. Экземпляр класса `Book` может представлять собой строку в таблице `books`. Таблица `books` со столбцами `id`, `title` и `author` может быть создана с помощью такого SQL-запроса:

```sql
CREATE TABLE books (
  id int(11) NOT NULL auto_increment,
  title varchar(255),
  author varchar(255),
  PRIMARY KEY  (id)
);
```

Однако в Rails это обычно делается не так. Таблицы баз данных в Rails обычно создаются с помощью [миграций Active Record](#migrations), а не с помощью чистого SQL. Миграцию для таблицы `books`, описанной выше, можно создать следующим образом:

```bash
$ bin/rails generate migration CreateBooks title:string author:string
```

что приведет к этому:

```ruby
# Примечание:
# Столбец `id`, в качестве первичного ключа, по соглашению создается автоматически.
# Столбцы `created_at` и `updated_at` добавляются `t.timestamps`.

# db/migrate/20240220143807_create_books.rb
class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.string :author

      t.timestamps
    end
  end
end
```

Эта миграция создает столбцы `id`, `title`, `author`, `created_at` и `updated_at`. Каждая строка этой таблицы может быть представлена экземпляром класса `Book` с теми же атрибутами: `id`, `title`, `author`, `created_at` и `updated_at`. Вы можете получить доступ к атрибутам книги следующим образом:

```irb
irb> book = Book.new
=> #<Book:0x00007fbdf5e9a038 id: nil, title: nil, author: nil, created_at: nil, updated_at: nil>

irb> book.title = "The Hobbit"
=> "The Hobbit"
irb> book.title
=> "The Hobbit"
```

NOTE: Создание модели Active Record и соответствующей миграции можно выполнить с помощью команды `bin/rails generate model Book title:string author:string`. Эта команда создаст файлы `app/models/book.rb`, `db/migrate/20240220143807_create_books.rb` и несколько дополнительных файлов для тестирования.

### Создание моделей в пространстве имен

По умолчанию модели Active Record размещаются в директории `app/models`. Однако вы можете захотеть организовать свои модели, разместив похожие модели в отдельной папке и пространстве имен. Например, файлы `order.rb` и `review.rb` можно разместить в `app/models/books` с именами классов `Book::Order` и `Book::Review` соответственно. Active Record позволяет создавать модели в пространстве имен.

Если модуль `Book` еще не существует, команда `generate` создаст все следующим образом:

```bash
$ bin/rails generate model Book::Order
      invoke  active_record
      create    db/migrate/20240306194227_create_book_orders.rb
      create    app/models/book/order.rb
      create    app/models/book.rb
      invoke    test_unit
      create      test/models/book/order_test.rb
      create      test/fixtures/book/orders.yml
```

Если модуль `Book` уже существует, вам будет предложено разрешить конфликт:

```bash
$ bin/rails generate model Book::Order
      invoke  active_record
      create    db/migrate/20240305140356_create_book_orders.rb
      create    app/models/book/order.rb
    conflict    app/models/book.rb
  Overwrite /Users/bhumi/Code/rails_guides/app/models/book.rb? (enter "h" for help) [Ynaqdhm]
```

После успешного создания модели в пространстве имен классы `Book` и `Order` будут выглядеть следующим образом:

```ruby
# app/models/book.rb
module Book
  def self.table_name_prefix
    "book_"
  end
end

# app/models/book/order.rb
class Book::Order < ApplicationRecord
end
```

Установка опции [table_name_prefix](https://api.rubyonrails.org/classes/ActiveRecord/ModelSchema.html#method-c-table_name_prefix-3D) в `Book` позволит назвать таблицу базы данных для модели `Order` как `book_orders`, вместо просто `orders`.

Другая возможность - у вас уже есть модель `Book`, которую вы хотите оставить в `app/models`. В этом случае вы можете выбрать `n`, чтобы не перезаписывать `book.rb` во время команды `generate`.

Это позволит использовать таблицу с пространством имен для класса `Book::Order` даже без необходимости использования `table_name_prefix`.

```ruby
# app/models/book.rb
class Book < ApplicationRecord
  # существующий код
end

Book::Order.table_name
# => "book_orders"
```

(overriding-the-naming-conventions) Переопределение соглашений об именовании
----------------------------------------------------------------------------

Но что, если вы следуете другому соглашению по именованию или используете новое приложение Rails со старой базой данных? Не проблема, можно просто переопределить соглашения по умолчанию.

Так как `ApplicationRecord` наследуется от `ActiveRecord::Base`, модели вашего приложения будут иметь ряд полезных методов. Например, вы можете использовать метод `ActiveRecord::Base.table_name=` для настройки имени таблицы, которая должна использоваться:

```ruby
class Book < ApplicationRecord
  self.table_name = "my_books"
end
```

Если вы сделаете это, вам придется вручную определить имя класса, в котором размещены [фикстуры](/testing#the-low-down-on-fixtures) (`my_books.yml`), используя метод `set_fixture_class` в вашем определении теста.

```ruby
# test/models/book_test.rb
class BookTest < ActiveSupport::TestCase
  set_fixture_class my_books: Book
  fixtures :my_books
  # ...
end
```

Также возможно переопределить столбец, который должен быть использован как первичный ключ таблицы, с помощью метода `ActiveRecord::Base.primary_key=`:

```ruby
class Book < ApplicationRecord
  self.primary_key = "book_id"
end
```

NOTE: **Active Record не рекомендует использовать столбцы с именем id, которые не являются первичным ключом.** Использование столбца `id`, который не является одностолбцовым первичным ключом, усложняет доступ к значению этого столбца. Приложению придется использовать псевдоним атрибута [`id_value`][] для доступа к значению столбца `id`, который не является первичным ключом.

[`id_value`]: https://api.rubyonrails.org/classes/ActiveRecord/ModelSchema.html#method-i-id_value

NOTE: Если вы попытаетесь создать столбец с именем `id`, который не является первичным ключом, Rails выдаст ошибку во время миграции, например: `you can't redefine the primary key column 'id' on 'my_books'.` `To define a custom primary key, pass { id: false } to create_table.`

(crud-reading-and-writing-data) CRUD: Чтение и запись данных
------------------------------------------------------------

CRUD это сокращение для четырех глаголов, используемых для описания операций с данными: **C**reate (создать), **R**ead (прочесть), **U**pdate (обновить) и **D**elete (удалить). Active Record автоматически создает методы, позволяющие читать и воздействовать на данные, хранимые в своих таблицах.

Active Record позволяет легко выполнять CRUD-операции с помощью этих высокоуровневых методов, которые абстрагируют детали доступа к базе данных. Обратите внимание, что все эти удобные методы приводят к выполнению SQL-запросов к базе данных.

В приведенных ниже примерах показано несколько методов CRUD, а также полученные SQL-запросы.

### Создание

Объекты Active Record могут быть созданы из хэша, блока или из вручную указанных после создания атрибутов. Метод `new` возвратит новый несохраненный объект, в то время как `create` сохранит объект в базе данных и возвратит его.

Например, для модели `Book` с атрибутами `title` и `author` вызов метода `create` создаст объект и сохранит новую запись в базе данных:

```ruby
book = Book.create(title: "The Lord of the Rings", author: "J.R.R. Tolkien")

# Имейте в виду, что `id` присваивается автоматически, когда запись фиксируется в базе данных.
book.inspect
# => "#<Book id: 106, title: \"The Lord of the Rings\", author: \"J.R.R. Tolkien\", created_at: \"2024-03-04 19:15:58.033967000 +0000\", updated_at: \"2024-03-04 19:15:58.033967000 +0000\">"
```

В то время как метод `new` создаст экземпляр объекта *не* сохраняя его в базе данных:

```ruby
book = Book.new
book.title = "The Hobbit"
book.author = "J.R.R. Tolkien"

# Имейте в виду, что для этого объекта `id` не установлен.
book.inspect
# => "#<Book id: nil, title: \"The Hobbit\", author: \"J.R.R. Tolkien\", created_at: nil, updated_at: nil>"

# Вышеупомянутая book` еще не сохранена в базе данных.

book.save
book.id # => 107

# Теперь запись `book` зафиксирована в базе данных и имеет `id`.
```

Наконец, если предоставлен блок и `create`, и `new` передадут новый объект в этот блок для инициализации, при этом только `create` сохраняет результирующий объект в базе данных:

```ruby
book = Book.new do |b|
  b.title = "Metaprogramming Ruby 2"
  b.author = "Paolo Perrotta"
end

book.save
```

В результате выполнения обоих методов `book.save` и `Book.create` SQL-запрос будет выглядеть примерно так:

```sql
/* Имейте в виду, что `created_at` и `updated_at` устанавливаются автоматически. */

INSERT INTO "books" ("title", "author", "created_at", "updated_at") VALUES (?, ?, ?, ?) RETURNING "id"  [["title", "Metaprogramming Ruby 2"], ["author", "Paolo Perrotta"], ["created_at", "2024-02-22 20:01:18.469952"], ["updated_at", "2024-02-22 20:01:18.469952"]]
```

### Чтение

Active Record предоставляет богатый API для доступа к данным в базе данных. Вы можете выполнять запросы к отдельной записи или нескольким записям, фильтровать их по любому атрибуту, упорядочивать, группировать, выбирать определенные поля и делать все, что можно сделать с помощью SQL.

```ruby
# возвратит коллекцию со всеми книгами.
books = Book.all

# Возвратит отдельную книгу.
first_book = Book.first
last_book = Book.last
book = Book.take
```

Вышесказанное приводит к следующему SQL-запросу:

```sql
-- Book.all
SELECT "books".* FROM "books"

-- Book.first
SELECT "books".* FROM "books" ORDER BY "books"."id" ASC LIMIT ?  [["LIMIT", 1]]

-- Book.last
SELECT "books".* FROM "books" ORDER BY "books"."id" DESC LIMIT ?  [["LIMIT", 1]]

-- Book.take
SELECT "books".* FROM "books" LIMIT ?  [["LIMIT", 1]]
```

Мы также можем находить конкретные книги с помощью `find_by` и `where`. В то время как `find_by` возвращает одну запись, `where` возвращает список записей:

```ruby
# Возвращает первую книгу с указанным названием или `nil`, если книга не найдена.
book = Book.find_by(title: "Metaprogramming Ruby 2")

# Альтернатива Book.find_by(id: 42). Выбросит исключение, если книга не найдена.
book = Book.find(42)
```

Вышесказанное приводит к следующему SQL-запросу:

```sql
SELECT "books".* FROM "books" WHERE "books"."author" = ? LIMIT ?  [["author", "J.R.R. Tolkien"], ["LIMIT", 1]]

SELECT "books".* FROM "books" WHERE "books"."id" = ? LIMIT ?  [["id", 42], ["LIMIT", 1]]
```

```ruby
# Находит все книги данного автора, отсортированные по дате создания в обратном хронологическом порядке.
Book.where(author: "Douglas Adams").order(created_at: :desc)
```

приводит к следующему SQL-запросу:

```sql
SELECT "books".* FROM "books" WHERE "books"."author" = ? ORDER BY "books"."created_at" DESC [["author", "Douglas Adams"]]
```

Существует множество других методов Active Record для чтения и запроса записей. Подробнее о них вы можете узнать в руководстве [по запросам Active Record](/active-record-querying).

### Обновление

Как только объект Active Record будет получен, его атрибуты могут быть модифицированы, и он может быть сохранен в базу данных.

```ruby
book = Book.find_by(title: "The Lord of the Rings")
book.title = "The Lord of the Rings: The Fellowship of the Ring"
book.save
```

Сокращенным вариантом для этого является использование хэша с атрибутами, связанными с желаемыми значениями, таким образом:

```ruby
book = Book.find_by(title: "The Lord of the Rings")
book.update(title: "The Lord of the Rings: The Fellowship of the Ring")
```

`update` приводит к следующему SQL-запросу:

```sql
/* Имейте в виду, что `updated_at` обновляется автоматически. */

 UPDATE "books" SET "title" = ?, "updated_at" = ? WHERE "books"."id" = ?  [["title", "The Lord of the Rings: The Fellowship of the Ring"], ["updated_at", "2024-02-22 20:51:13.487064"], ["id", 104]]
```

Это полезно, когда нужно обновить несколько атрибутов одновременно. Подобно `create`, использование `update` зафиксирует обновленные записи в базе данных.

Если необходимо обновить несколько записей за раз **без колбэков и валидаций**, можно обновить базу данных напрямую с помощью `update_all`:

```ruby
Book.update_all(status: "already own")
```

### Удаление

Более того, после получения, объект Active Record может быть уничтожен, что уберет его из базы данных.

```ruby
book = Book.find_by(title: "The Lord of the Rings")
book.destroy
```

`destroy` приводит к следующему SQL-запросу:

```sql
DELETE FROM "books" WHERE "books"."id" = ?  [["id", 104]]
```

Если необходимо удалить сразу несколько записей, можно использовать методы `destroy_by` или `destroy_all`:

```ruby
# Найти и удалить все книги Douglas Adams.
Book.destroy_by(author: "Douglas Adams")

# Удалить все книги.
Book.destroy_all
```

Валидации
---------

Active Record позволяет проверять состояние модели до того, как она будет записана в базу данных. Имеются различные методы для различных типов валидаций. Например, можно проверить, чтобы значение атрибута не было пустым, было уникальным, отсутствовало в базе данных, соответствовало определенному формату и многое другое.

Методы `save`, `create` и `update` выполняют валидацию модели перед ее сохранением в базе данных. Если модель невалидна, эти методы возвращают `false`, и никаких операций с базой данных не выполняется. У всех этих методов есть более строгие аналоги с восклицательным знаком (то есть `save!`, `create!` и `update!`), которые при неудачной валидации вызывают исключение `ActiveRecord::RecordInvalid`. Быстрый пример для иллюстрации:

```ruby
class User < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> user = User.new
irb> user.save
=> false
irb> user.save!
ActiveRecord::RecordInvalid: Validation failed: Name can't be blank
```

Подробнее о валидациях можно прочитать в руководстве [Валидации Active Record](/active-record-validations).

Колбэки
-------

Колбэки Active Record разрешают присоединить код к определенным событиям в жизненном цикле ваших моделей. Это позволяет добавить поведение модели, выполнив код, когда эти события произойдут, например, когда вы создадите новую запись, обновите её, удалите её и так далее.

```ruby
class User < ApplicationRecord
  after_create :log_new_user

  private
    def log_new_user
      puts "A new user was registered"
    end
end
```

```irb
irb> @user = User.create
A new user was registered
```

Подробнее о колбэках можно прочитать в руководстве [Колбэки Active Record](/active-record-callbacks).

(migrations) Миграции
---------------------

Rails предоставляет удобный способ управления схемой базы данных с помощью миграций. Миграции пишутся на специальном языке предметной области и хранятся в файлах, которые выполняются для любой базы данных, поддерживаемой Active Record.

Вот миграция, которая создает новую таблицу под названием `publications`:

```ruby
class CreatePublications < ActiveRecord::Migration[7.2]
  def change
    create_table :publications do |t|
      t.string :title
      t.text :description
      t.references :publication_type
      t.references :publisher, polymorphic: true
      t.boolean :single_issue

      t.timestamps
    end
  end
end
```

Имейте в виду, что приведенный выше код не зависит от конкретной базы данных: он будет работать в MySQL, MariaDB, PostgreSQL, SQLite и других.

Rails отслеживает, какие миграции были внедрены в базу данных, и хранит их в соседней таблице той же самой базы данных под названием `schema_migrations`.

Для запуска миграции и создания таблицы выполните команду `bin/rails db:migrate`, а для отката и удаления таблицы - `bin/rails db:rollback`.

Подробнее о миграциях вы можете узнать в руководстве Active Record Migrations: Active Record Migrations guide: active_record_migrations.html.

Подробнее о миграциях можно прочитать в [руководстве по миграциям Active Record](/active-record-migrations)

Связи
-----

Связи Active Record позволяют вам определять взаимосвязи между моделями. Связи могут использоваться для описания отношений один-к-одному, один-ко-многим и многие-ко-многим. Например, отношение "У автора много книг" можно определить следующим образом:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

Теперь класс `Author` обладает методами для добавления и удаления книг у автора, а также многим другим.

Подробнее о связях можно прочитать в [руководстве по связям Active Record](/active-record-associations).
