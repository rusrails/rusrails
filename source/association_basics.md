Связи (ассоциации) Active Record
================================

Это руководство раскрывает особенности связей Active Record.

После его прочтения, вы узнаете, как:

* Объявлять связи между моделями Active Record.
* Понимать различные типы связей Active Record.
* Использовать методы, добавленные в ваши модели при создании связей.

--------------------------------------------------------------------------------

Зачем нужны связи?
------------------

В Rails _связь_ - это соединение между двумя моделями Active Record. Зачем нам нужны связи между моделями? Затем, что они позволяют сделать код для обычных операций проще и легче.

Например, рассмотрим простое приложение на Rails, которое включает модель для авторов и модель для книг.

Каждый автор может иметь много книг. Без связей объявление модели будет выглядеть так:

```ruby
class Author < ApplicationRecord
end

class Book < ApplicationRecord
end
```

Теперь, допустим, мы хотим добавить новую книгу для существующего автора. Нам нужно сделать так:

```ruby
@book = Book.create(published_at: Time.now, author_id: @author.id)
```

Или, допустим, удалим автора и убедимся, что все его книги также будут удалены:

```ruby
@books = Book.where(author_id: @author.id)
@books.each do |book|
  book.destroy
end
@author.destroy
```

Со связями Active Record можно упростить эти и другие операции, декларативно сказав Rails, что имеется соединение между двумя моделями. Вот пересмотренный код для создания авторов и книг:

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end

class Book < ApplicationRecord
  belongs_to :author
end
```

С этими изменениями создание новой книги для определенного автора проще:

```ruby
@book = @author.books.create(published_at: Time.now)
```

Удаление автора и всех его книг *намного* проще:

```ruby
@author.destroy
```

Чтобы узнать больше о различных типах связей, читайте следующий раздел руководства. Затем следуют некоторые полезные советы по работе со связями, а затем полное описание методов и опций для связей в Rails.

Типы связей
-----------

Rails поддерживает шесть типов связей, каждый подразумевает конкретный вариант использования.

Вот список всех поддерживаемых типов со ссылкой на их документацию API с подробностями, как их использовать, параметрами их методов, и т.д.

* [`belongs_to`][]
* [`has_one`][]
* [`has_many`][]
* [`has_many :through`][`has_many`]
* [`has_one :through`][`has_one`]
* [`has_and_belongs_to_many`][]

Связи реализуются с использованием макро-вызовов (macro-style calls), и, таким образом, вы можете декларативно добавлять возможности для своих моделей. Например, объявляя, что одна модель принадлежит (`belongs_to`) другой, вы указываете Rails сохранять информацию о [первичном](https://ru.wikipedia.org/wiki/Первичный_ключ)-[внешнем](https://ru.wikipedia.org/wiki/Внешний_ключ) ключах между экземплярами двух моделей, а также получаете несколько полезных методов, добавленных в модель.

После прочтения всего этого руководства, вы научитесь объявлять и использовать различные формы связей. Но сначала следует быстро ознакомиться с ситуациями, когда применим каждый тип связи.

[`belongs_to`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-belongs_to
[`has_and_belongs_to_many`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_and_belongs_to_many
[`has_many`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_many
[`has_one`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_one

### Связь `belongs_to`

Связь [`belongs_to`][] устанавливает соединение один-к-одному с другой моделью, когда один экземпляр объявляющей модели "принадлежит" одному экземпляру другой модели. Например, если в приложении есть авторы и книги, и одна книга может быть связана только с одним автором, нужно объявить модель book следующим образом:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

![Диаграмма для связи belongs_to](association_basics/belongs_to.png)

NOTE: Связи `belongs_to` _обязаны_ использовать единственное число. Если использовать множественное число в вышеприведенном примере для связи `author` в модели `Book` и создать экземпляр с помощью `Book.create(authors: @author)`, будет сообщено "uninitialized constant Book::Authors". Это так, потому что Rails автоматически получает имя класса из имени связи. Если в имени связи неправильно использовано число, то получаемый класс также будет неправильного числа.

Соответствующая миграция может выглядеть так:

```ruby
class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

При одиночном использовании, `belongs_to` создает однонаправленное соединение один-к-одному. Следовательно, в вышеприведенном примере каждая книга "знает" своего автора, но авторы не знают о своих книгах. Чтобы настроить [двунаправленную связь](#bi-directional-associations) - используйте `belongs_to` в сочетании с `has_one` или `has_many` на другой модели, в данном случае модели Author.

`belongs_to` не гарантирует ссылочной целостности, если `optional` установлен true, поэтому, в зависимости от использования, возможно, необходимо добавить ограничение внешнего ключа на столбце ссылки на уровне базы данных, подобным образом:

```ruby
create_table :books do |t|
  t.belongs_to :author, foreign_key: true
  # ...
end
```

### Связь `has_one`

Связь [`has_one`][] показывает, что у другой модели есть ссылка на эту модель. Та модель может быть извлечена с помощью этой связи.

Например, если каждый поставщик имеет только один аккаунт, можете объявить модель supplier подобно этому:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

Главным отличием от `belongs_to` является то, что связующий столбец `supplier_id` расположен в другой таблице:

![Диаграмма для связи has_one](association_basics/has_one.png)

Соответствующая миграция может выглядеть так:

```ruby
class CreateSuppliers < ActiveRecord::Migration[7.2]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end
  end
end
```

В зависимости от применения, возможно, потребуется создать индекс уникальности и/или ограничение внешнего ключа на указанный столбец таблицы accounts. В этом случае определение столбца может выглядеть так:

```ruby
create_table :accounts do |t|
  t.belongs_to :supplier, index: { unique: true }, foreign_key: true
  # ...
end
```

Эта связь может быть [двунаправленной](#bi-directional-associations) при использовании в сочетании с `belongs_to` на другой модели.

### Связь `has_many`

Связь [`has_many`][] указывает на соединение один-ко-многим с другой моделью. Эта связь часто бывает на "другой стороне" связи `belongs_to`. Эта связь указывает на то, что каждый экземпляр модели имеет ноль или более экземпляров другой модели. Например, в приложении, содержащем авторов и книги, модель author может быть объявлена следующим образом:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

NOTE: Имя другой модели указывается во множественном числе при объявлении связи `has_many`.

![Диаграмма для связи has_many](association_basics/has_many.png)

Соответствующая миграция может выглядеть так:

```ruby
class CreateAuthors < ActiveRecord::Migration[7.2]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

В зависимости от применения, обычно неплохо было бы создать неуникальный индекс и опционально ограничение внешнего ключа на столбец автора для таблицы books:

```ruby
create_table :books do |t|
  t.belongs_to :author, index: true, foreign_key: true
  # ...
end
```

### (the-has-many-through-association) Связь `has_many :through`

Связь [`has_many :through`][`has_many`] часто используется для настройки соединения многие-ко-многим с другой моделью. Эта связь указывает, что объявляющая модель может соответствовать нулю или более экземплярам другой модели _через_ третью модель. Например, рассмотрим поликлинику, где пациентам (patients) дают направления (appointments) к врачам (physicians). Соответствующие объявления связей будут выглядеть следующим образом:

```ruby
class Physician < ApplicationRecord
  has_many :appointments
  has_many :patients, through: :appointments
end

class Appointment < ApplicationRecord
  belongs_to :physician
  belongs_to :patient
end

class Patient < ApplicationRecord
  has_many :appointments
  has_many :physicians, through: :appointments
end
```

![Диаграмма для связи has_many :through](association_basics/has_many_through.png)

Соответствующая миграция может выглядеть так:

```ruby
class CreateAppointments < ActiveRecord::Migration[7.2]
  def change
    create_table :physicians do |t|
      t.string :name
      t.timestamps
    end

    create_table :patients do |t|
      t.string :name
      t.timestamps
    end

    create_table :appointments do |t|
      t.belongs_to :physician
      t.belongs_to :patient
      t.datetime :appointment_date
      t.timestamps
    end
  end
end
```

Коллекция соединительных моделей может управляться с помощью [методов связи `has_many`](#has-many-association-reference). Например, если вы присвоите:

```ruby
physician.patients = patients
```

Тогда будут автоматически созданы новые соединительные модели для вновь связанных объектов. Если некоторые из ранее существующих сейчас отсутствуют, их соединительные строки автоматически удаляются.

WARNING: Автоматическое удаление соединительных моделей прямое, ни один из колбэков на уничтожение не включается.

Связь `has_many :through` также полезна для настройки "ярлыков" через вложенные связи `has_many`. Например, если документ имеет много секций, а секция имеет много параграфов, иногда хочется получить просто коллекцию всех параграфов в документе. Это можно настроить следующим образом:

```ruby
class Document < ApplicationRecord
  has_many :sections
  has_many :paragraphs, through: :sections
end

class Section < ApplicationRecord
  belongs_to :document
  has_many :paragraphs
end

class Paragraph < ApplicationRecord
  belongs_to :section
end
```

С определенным `through: :sections` Rails теперь понимает:

```ruby
@document.paragraphs
```

### (the-has-one-through-association) Связь `has_one :through`

Связь [`has_one :through`][`has_one`] настраивает соединение один-к-одному с другой моделью. Эта связь показывает, что объявляющая модель может быть связана с одним экземпляром другой модели _через_ третью модель. Например, если каждый поставщик имеет один аккаунт, и каждый аккаунт связан с одной историей аккаунта, тогда модели могут выглядеть так:

```ruby
class Supplier < ApplicationRecord
  has_one :account
  has_one :account_history, through: :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  has_one :account_history
end

class AccountHistory < ApplicationRecord
  belongs_to :account
end
```

![Диаграмма для связи has_one :through](association_basics/has_one_through.png)

Соответствующая миграция может выглядеть так:

```ruby
class CreateAccountHistories < ActiveRecord::Migration[7.2]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end

    create_table :account_histories do |t|
      t.belongs_to :account
      t.integer :credit_rating
      t.timestamps
    end
  end
end
```

### (the-has-and-belongs-to-many-association) Связь `has_and_belongs_to_many`

Связь [`has_and_belongs_to_many`][] создает прямое соединение многие-ко-многим с другой моделью, без промежуточной модели. Эта связь показывает, что каждый экземпляр объявляющей модели ссылается на ноль или более записей другой модели. Например, если ваше приложение включает сборки (assemblies) и детали (parts), где каждый узел имеет много деталей, и каждая деталь встречается во многих сборках, модели можно объявить таким образом:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

![Диаграмма для связи has_and_belongs_to_many](association_basics/habtm.png)

Соответствующая миграция может выглядеть так:

```ruby
class CreateAssembliesAndParts < ActiveRecord::Migration[7.2]
  def change
    create_table :assemblies do |t|
      t.string :name
      t.timestamps
    end

    create_table :parts do |t|
      t.string :part_number
      t.timestamps
    end

    create_table :assemblies_parts, id: false do |t|
      t.belongs_to :assembly
      t.belongs_to :part
    end
  end
end
```

### Выбор между `belongs_to` и `has_one`

Если хотите настроить отношение один-к-одному между двумя моделями, необходимо добавить `belongs_to` к одной и `has_one` к другой. Как узнать что к какой?

Различие в том, где помещен внешний ключ (он должен быть в таблице для класса, объявляющего связь `belongs_to`), но вы также должны думать о реальном значении данных. Отношение `has_one` говорит, что что-то принадлежит вам - то есть что что-то указывает на вас. Например, больше смысла в том, что поставщик владеет аккаунтом, чем в том, что аккаунт владеет поставщиком. Это означает, что правильные отношения подобны этому:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

Соответствующая миграция может выглядеть так:

```ruby
class CreateSuppliers < ActiveRecord::Migration[7.2]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.bigint  :supplier_id
      t.string  :account_number
      t.timestamps
    end

    add_index :accounts, :supplier_id
  end
end
```

NOTE: Использование `t.bigint :supplier_id` указывает имя внешнего ключа очевидно и явно. В современных версиях Rails можно абстрагироваться от деталей реализации используя `t.references :supplier`.

### Выбор между `has_many :through` и `has_and_belongs_to_many`

Rails предлагает два разных способа объявления отношения многие-ко-многим между моделями. Первый способ - использовать `has_and_belongs_to_many`, который позволяет создать связь напрямую:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

Второй способ объявить отношение многие-ко-многим - использование `has_many :through`. Это осуществляет связь не напрямую, а через соединяющую модель:

```ruby
class Assembly < ApplicationRecord
  has_many :manifests
  has_many :parts, through: :manifests
end

class Manifest < ApplicationRecord
  belongs_to :assembly
  belongs_to :part
end

class Part < ApplicationRecord
  has_many :manifests
  has_many :assemblies, through: :manifests
end
```

Простейший признак того, что нужно настраивать отношение `has_many :through` - если необходимо работать с моделью отношений как с независимым объектом. Если вам не нужно ничего делать с моделью отношений, проще настроить связь `has_and_belongs_to_many` (хотя нужно не забыть создать соединяющую таблицу в базе данных).

Вы должны использовать `has_many :through`, если нужны валидации, колбэки или дополнительные атрибуты для соединительной модели.

Хотя `has_and_belongs_to_many` предлагает создать соединительную таблицу без первичного ключа с помощью `id: false`, рассмотрите использование составного первичного ключа для соединительной таблицы в связях `has_many :through`. Например, рекомендуется использовать `create_table :manifests, primary_key: [:assembly_id, :part_id]` в вышеуказанном примере.

### (polymorphic-associations) Полиморфные связи

_Полиморфные связи_ - это немного более "навороченный" вид связей. С полиморфными связями модель может принадлежать более чем одной модели, на одиночной связи. Например, имеется модель изображения, которая принадлежит или модели работника, или модели продукта. Вот как это объявляется:

```ruby
class Picture < ApplicationRecord
  belongs_to :imageable, polymorphic: true
end

class Employee < ApplicationRecord
  has_many :pictures, as: :imageable
end

class Product < ApplicationRecord
  has_many :pictures, as: :imageable
end
```

Можно считать полиморфное объявление `belongs_to` как настройку интерфейса, которую может использовать любая другая модель. Из экземпляра модели `Employee` можно получить коллекцию изображений: `@employee.pictures`.

Подобным образом можно получить `@product.pictures`.

Если имеется экземпляр модели `Picture`, можно получить его родителя посредством `@picture.imageable`. Чтобы это работало, необходимо объявить столбец внешнего ключа и столбец типа в модели, объявляющей полиморфный интерфейс:

```ruby
class CreatePictures < ActiveRecord::Migration[7.2]
  def change
    create_table :pictures do |t|
      t.string  :name
      t.bigint  :imageable_id
      t.string  :imageable_type
      t.timestamps
    end

    add_index :pictures, [:imageable_type, :imageable_id]
  end
end
```

Эта миграция может быть упрощена при использовании формы `t.references`:

```ruby
class CreatePictures < ActiveRecord::Migration[7.2]
  def change
    create_table :pictures do |t|
      t.string :name
      t.references :imageable, polymorphic: true
      t.timestamps
    end
  end
end
```

![Диаграмма для полиморфной связи](association_basics/polymorphic.png)


### Связи между моделями со составными первичными ключами

Rails часто способен вывести информацию о первичном/внешнем ключах между связанными моделями со составными первичными ключами, без необходимости дополнительной информации. Возьмем следующий пример:

```ruby
class Order < ApplicationRecord
  self.primary_key = [:shop_id, :id]
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :order
end
```

Тут Rails предполагает, что столбец `:id` должен быть использован в качестве первичного ключа для связи между заказом и его книгами, как и при обычных связях `has_many` / `belongs_to`. Он выведет, что столбец внешнего ключа на таблице `books` - `:order_id`. Получение заказа книги:

```ruby
order = Order.create!(id: [1, 2], status: "pending")
book = order.books.create!(title: "A Cool Book")

book.reload.order
```

сгенерирует следующий SQL для доступа к заказу:

```sql
SELECT * FROM orders WHERE id = 2
```

Это работает, только если составной первичный ключ модели содержит столбец `:id` _и_ столбец, уникальный для всех записей. Чтобы использовать полный составной первичный ключ в связях, установите опцию `query_constraints` связи. Эта опция указывает составной внешний ключ на связи: будут использованы все столбцы во внешнем ключе при запросе связанной записи(ей). Например:

```ruby
class Author < ApplicationRecord
  self.primary_key = [:first_name, :last_name]
  has_many :books, query_constraints: [:first_name, :last_name]
end

class Book < ApplicationRecord
  belongs_to :author, query_constraints: [:author_first_name, :author_last_name]
end
```

Доступ к автору книги:

```ruby
author = Author.create!(first_name: "Jane", last_name: "Doe")
book = author.books.create!(title: "A Cool Book")

book.reload.author
```

использует `:first_name` _и_ `:last_name` в запросе SQL:

```sql
SELECT * FROM authors WHERE first_name = 'Jane' AND last_name = 'Doe'
```

### Присоединение к себе

При разработке модели данных иногда находится модель, которая может иметь отношение сама к себе. Например, мы хотим хранить всех работников в одной модели базы данных, но нам нужно отслеживать отношения начальник-подчиненный. Эта ситуация может быть смоделирована с помощью связей, присоединяемых к себе:

```ruby
class Employee < ApplicationRecord
  has_many :subordinates, class_name: "Employee",
                          foreign_key: "manager_id"

  belongs_to :manager, class_name: "Employee", optional: true
end
```

С такой настройкой, вы можете получить `@employee.subordinates` и `@employee.manager`.

В миграциях/схеме следует добавить столбец ссылки модели на саму себя.

```ruby
class CreateEmployees < ActiveRecord::Migration[7.2]
  def change
    create_table :employees do |t|
      t.references :manager, foreign_key: { to_table: :employees }
      t.timestamps
    end
  end
end
```

NOTE: Опция `to_table`, передаваемая в `foreign_key`, подробнее объяснена в [`SchemaStatements#add_reference`][connection.add_reference].

[connection.add_reference]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference

Полезные советы и предупреждения
--------------------------------

Вот некоторые вещи, которые необходимо знать для эффективного использования связей Active Record в вашем приложении на Rails:

* Управление кэшированием
* Предотвращение коллизий имен
* Обновление схемы
* Управление областью видимости связей
* Двусторонние связи

### Управление кэшированием

Все методы связи построены вокруг кэширования, которое хранит результаты последних запросов доступными для будущих операций. Кэш является общим для разных методов. Например:

```ruby
# получаем книги из базы данных
author.books

# используем кэшированную копию книг
author.books.size

# используем кэшированную копию книг
author.books.empty?
```

Но что если вы хотите перезагрузить кэш, так как данные могли быть изменены другой частью приложения? Всего лишь вызовите `reload` на связи:

```ruby
# получаем книги из базы данных
author.books

# используем кэшированную копию книг
author.books.size

# отказываемся от кэшированной копии книг и снова обращаемся к базе данных
author.books.reload.empty?
```

### Предотвращение коллизий имен

Вы не свободны в выборе любого имени для своих связей. Поскольку создание связи добавляет метод с таким именем в модель, будет плохой идеей дать связи имя, уже используемое как метод экземпляра `ActiveRecord::Base`. Метод связи тогда переопределит базовый метод, и что-нибудь перестанет работать. Например, `attributes` или `connection` плохие имена для связей.

### Обновление схемы

Связи очень полезные, но не волшебные. Вы ответственны за содержание вашей схемы базы данных в соответствии со связями. На практике это означает две вещи, в зависимости от того, какой тип связей создаете. Для связей `belongs_to` нужно создать внешние ключи, а для связей `has_and_belongs_to_many` нужно создать подходящую соединительную таблицу.

#### Создание внешних ключей для связей `belongs_to`

Когда объявляете связь `belongs_to`, нужно создать внешние ключи, при необходимости. Например, рассмотрим эту модель:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

Это объявление нуждается в поддержке соответствующим столбцом внешнего ключа в таблице books. Для совершенно новой таблицы миграция может выглядеть примерно так:

```ruby
class CreateBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :books do |t|
      t.datetime   :published_at
      t.string     :book_number
      t.references :author
    end
  end
end
```

В то время как для существующей таблицы, это может выглядеть следующим образом:

```ruby
class AddAuthorToBooks < ActiveRecord::Migration[7.2]
  def change
    add_reference :books, :author
  end
end
```

Если необходимо [принудительно использовать ссылочную целостность на уровне базы данных][foreign_keys], добавьте опцию `foreign_key: true` в вышеприведенное объявление 'reference' столбца.

[foreign_keys]: /active-record-migrations#foreign-keys

#### Создание соединительных таблиц для связей `has_and_belongs_to_many`

Если вы создали связь `has_and_belongs_to_many`, необходимо обязательно создать соединительную таблицу. Если имя соединительной таблицы явно не указано с использованием опции `:join_table`, Active Record создает имя, используя алфавитный порядок имен классов. Поэтому соединение между моделями author и book по умолчанию даст значение имени таблицы "authors_books", так как "a" идет перед "b" в алфавитном порядке.

WARNING: Приоритет между именами модели рассчитывается с использованием оператора `<=>` для `String`. Это означает, что если строки имеют разную длину и в своей короткой части они равны, тогда более длинная строка рассматривается как с более высоким лексическим приоритетом, по сравнению с короткой. Например, кто-то ожидает, что таблицы "paper_boxes" и "papers" создадут соединительную таблицу "papers_paper_boxes" поскольку имя "paper_boxes" длиннее, но фактически будет сгенерирована таблица с именем "paper_boxes_papers" (поскольку знак подчеркивания "\_" лексикографически _меньше_, чем "s" в обычной кодировке).

Какое бы ни было имя, вы должны вручную сгенерировать соединительную таблицу в соответствующей миграции. Например, рассмотрим эти связи:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

Теперь нужно написать миграцию для создания таблицы `assemblies_parts`. Эта таблица должна быть создана без первичного ключа:

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.2]
  def change
    create_table :assemblies_parts, id: false do |t|
      t.bigint :assembly_id
      t.bigint :part_id
    end

    add_index :assemblies_parts, :assembly_id
    add_index :assemblies_parts, :part_id
  end
end
```

Мы передаем `id: false` в `create_table`, так как эта таблица не представляет модель. Это необходимо, чтобы связь работала правильно. Если вы видите странное поведение в связи `has_and_belongs_to_many`, например, искаженные ID моделей, или исключения в связи с конфликтом ID, скорее всего вы забыли убрать первичный ключ.

Для простоты, также можно использовать метод `create_join_table`

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.2]
  def change
    create_join_table :assemblies, :parts do |t|
      t.index :assembly_id
      t.index :part_id
    end
  end
end
```

### Управление областью видимости связей

По умолчанию связи ищут объекты только в пределах области видимости текущего модуля. Это важно, когда вы объявляете модели Active Record внутри модуля. Например:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end

    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

Это будет работать, так как оба класса `Supplier` и `Account` определены в пределах одной области видимости. Но нижеследующее не будет работать, потому что `Supplier` и `Account` определены в разных областях видимости:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

Для связи модели с моделью в другом пространстве имен, необходимо указать полное имя класса в объявлении связи:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account,
        class_name: "MyApplication::Billing::Account"
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier,
        class_name: "MyApplication::Business::Supplier"
    end
  end
end
```

### (bi-directional-associations) Двунаправленные связи

Для связей нормально работать в двух направлениях, затребовав объявление в двух различных моделях:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
end
```

Active Record попытается автоматически определить, что эти две модели образуют двунаправленную связь, основываясь на имени связи. Эта информация позволяет Active Record:

* Предотвращать необходимость запросов для уже загруженных данных:

    ```irb
    irb> author = Author.first
    irb> author.books.all? do |book|
    irb>   book.author.equal?(author) # Тут не выполняются дополнительные запросы
    irb> end
    => true
    ```

* Предотвращать несогласованные данные (как только есть только одна загруженная копия объекта `Author`):

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "Changed Name"
    irb> author.name == book.author.name
    => true
    ```

* Автоматически сохраняет связи в большинстве случаев:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => true
    ```

* Проверяет [наличие](/active-record-validations#presence) и [отсутствие](/active-record-validations#absence) связей в большинстве случаев:

    ```irb
    irb> book = Book.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["Author must exist"]
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => true
    ```

Active Record поддерживает автоматическое определение для большинства связей со стандартными именами. Однако, двунаправленные связи, содержащие опции `:through` или `:foreign_key`, не будут автоматически определены.

Пользовательские скоупы на противоположных связях также предотвращают автоматическое определение, как и пользовательские скоупы на самой связи, за исключением когда [`config.active_record.automatic_scope_inversing`][] установлена true (по умолчанию для новых приложений).

Например, рассмотрим следующие объявления моделей:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

Из-за опции `:foreign_key`, Active Record больше не будет автоматически распознавать двунаправленную связь. Это может вызвать, что ваше приложение:

* Выполняет необходимые запросы для тех же данных (в этом примере вызывая N+1 запрос):

    ```irb
    irb> author = Author.first
    irb> author.books.any? do |book|
    irb>   book.author.equal?(author) # Это выполняет запрос для каждой книги
    irb> end
    => false
    ```

* Ссылается на несколько копий модели с несогласованными данными:

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "Changed Name"
    irb> author.name == book.author.name
    => false
    ```

* Не в состоянии автоматически сохранять связи:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => false
    ```

* Не в состоянии проверять наличие или отсутствие:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["Author must exist"]
    ```

Active Record представляет опцию `:inverse_of`, таким образом можно явно объявить двунаправленные связи:

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: 'writer'
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

Включив опцию `:inverse_of` в объявлении связи `has_many`, Active Record будет распознавать двунаправленную связь и будет вести себя как в изначальных примерах выше:

[`config.active_record.automatic_scope_inversing`]: /configuring#config-active-record-automatic-scope-inversing

Подробная информация по связи `belongs_to`
------------------------------------------

В терминах базы данных связь `belongs_to` сообщает, что таблица этой модели содержит столбец, представляющий ссылку на другую таблицу. Она может быть использована для настройки отношений один-к-одному или один-ко-многим, в зависимости от настроек. Если таблица другого класса содержит ссылку в отношении один-к-одному, вместо этого  следует использовать `has_one`.

### Методы, добавляемые `belongs_to`

Когда объявляете связь `belongs_to`, объявляющий класс автоматически получает 8 методов, относящихся к связи:

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`
* `association_changed?`
* `association_previously_changed?`

Во всех четырех методах `association` заменяется символом, переданным как первый аргумент в `belongs_to`. Например, имеем объявление:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

Каждый экземпляр модели `Book` будет иметь эти методы:

* `author`
* `author=`
* `build_author`
* `create_author`
* `create_author!`
* `reload_author`
* `reset_author`
* `author_changed?`
* `author_previously_changed?`

NOTE: Когда устанавливаете новую связь `has_one` или `belongs_to`, следует использовать префикс `build_` для построения связи, в отличие от метода `association.build`, используемый для связей `has_many` или `has_and_belongs_to_many`. Чтобы создать связь, используйте префикс `create_`.

#### `association`

Метод `association` возвращает связанный объект, если он есть. Если объекта нет, возвращает `nil`.

```ruby
@author = @book.author
```

Если связанный объект уже был получен из базы данных для этого объекта, возвращается кэшированная версия. Чтобы переопределить это поведение (и заставить прочитать из базы данных), вызовите `#reload_association` на родительском объекте.

```ruby
@author = @book.reload_author
```

Чтобы выгрузить кэшированную версию связанного объекта при следующем доступе, если таковая имеется, и прочитать ее из базы данных, вызовите `#reset_association` на родительском объекте.

```ruby
@book.reset_author
```

#### `association=(associate)`

Метод `association=` привязывает связанный объект к этому объекту. Фактически это означает извлечение первичного ключа из связанного объекта и присвоение его значения внешнему ключу.

```ruby
@book.author = @author
```

#### `build_association(attributes = {})`

Метод `build_association` возвращает новый объект связанного типа. Этот объект будет экземпляром с переданными атрибутами, будет установлена связь с внешним ключом этого объекта, но связанный объект пока _не_ будет сохранен.

```ruby
@author = @book.build_author(author_number: 123,
                             author_name: "John Doe")
```

#### `create_association(attributes = {})`

Метод `create_association` возвращает новый объект связанного типа. Этот объект будет экземпляром с переданными атрибутами, будет установлена связь с внешним ключом этого объекта, и, если он пройдет валидации, определенные в связанной модели, связанный объект _будет_ сохранен.

```ruby
@author = @book.create_author(author_number: 123,
                              author_name: "John Doe")
```

#### `create_association!(attributes = {})`

Работает так же, как и вышеприведенный `create_association`, но вызывает `ActiveRecord::RecordInvalid`, если запись невалидна.

##### `association_changed?`

Метод `association_changed?` возвращает true, если был назначен новый связанный объект, и внешний ключ будет обновлен при следующем сохранении.

```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.author_changed? # => true

@book.save!
@book.author_changed? # => false
```

##### `association_previously_changed?`

Метод `association_previously_changed?` возвращает true, если предыдущее сохранение обновило связь, ссылающуюся на новый связанный объект.

```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_previously_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.save!
@book.author_previously_changed? # => true
```

### (options-for-belongs-to) Опции для `belongs_to`

Хотя Rails использует разумные значения по умолчанию, работающие во многих ситуациях, бывают случаи, когда хочется изменить поведение связи `belongs_to`. Такая настройка легко выполнима с помощью передачи опций и блоков со скоупом при создании связи. Например, эта связь использует две такие опции:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at,
    counter_cache: true
end
```

Связь [`belongs_to`][] поддерживает эти опции:

* `:autosave`
* `:class_name`
* `:counter_cache`
* `:default`
* `:dependent`
* `:ensuring_owner_was`
* `:foreign_key`
* `:foreign_type`
* `:primary_key`
* `:inverse_of`
* `:optional`
* `:polymorphic`
* `:required`
* `:strict_loading`
* `:touch`
* `:validate`

#### `:autosave`

Если установить опцию `:autosave` в `true`, Rails сохранит любые загруженные связанные члены и уничтожит члены, помеченные для уничтожения, всякий раз, когда сохраняется родительский объект. Но установить `:autosave` в `false` - не то же самое, что не устанавливать опцию `:autosave`. Если опция `:autosave` отсутствует, то новые связанные объекты будут сохранены, но обновленные связанные объекты сохранены не будут.

#### `:class_name`

Если имя другой модели не может быть получено из имени связи, можете использовать опцию `:class_name` для предоставления имени модели. Например, если книга принадлежит автору, но фактическое имя модели, содержащей авторов, `Patron`, можете установить это следующим образом:

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron"
end
```

#### `:counter_cache`

Опция `:counter_cache` может быть использована, чтобы сделать поиск количества принадлежащих объектов более эффективным. Рассмотрим эти модели:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end

class Author < ApplicationRecord
  has_many :books
end
```

С этими объявлениями запрос значения `@author.books.size` требует обращения к базе данных для выполнения запроса `COUNT(*)`. Чтобы этого избежать, можете добавить кэш счетчика в _принадлежащую_ модель:

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: true
end

class Author < ApplicationRecord
  has_many :books
end
```

С этим объявлением, Rails будет хранить в кэше актуальное значение и затем возвращать это значение в отклик на метод `size`.

Хотя опция `:counter_cache` определяется в модели, включающей определение `belongs_to`, фактический столбец должен быть добавлен в _связанную_ (`has_many`) модель. В вышеописанном случае, необходимо добавить столбец, названный `books_count` в модель `Author`.

Имя столбца по умолчанию можно переопределить, указав произвольное имя столбца в объявлении `counter_cache` вместо `true`. Например, для использования `count_of_books` вместо `books_count`:

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: :count_of_books
end

class Author < ApplicationRecord
  has_many :books
end
```

NOTE: Опцию `:counter_cache` необходимо указывать только на стороне `belongs_to` связи.

Столбцы кэша счетчика добавляются в список атрибутов модели только для чтения посредством `attr_readonly`.

Если по какой-то причине вы изменяете значение первичного ключа модели, но не обновляете внешние ключи посчитанных моделей, то кэш счетчика может иметь устаревшие данные. Другими словами, любые "осиротевшие" модели все еще будут считать в отношении счетчика. Чтобы починить кэш счетчика, используйте [`reset_counters`][].

[`reset_counters`]: https://api.rubyonrails.org/classes/ActiveRecord/CounterCache/ClassMethods.html#method-i-reset_counters

##### `:default`

Когда установлен `true`, у связи не будет проверки ее наличия.

#### `:dependent`

Если установить опцию `:dependent` в:

* `:destroy`, когда объект уничтожается, `destroy` вызывается на его связанных объектах.
* `:delete`, когда объект уничтожается, все его связанные объекты удаляются прямо из базы данных без вызова метода `destroy`.
* `:destroy_async`: когда объект уничтожается, задание `ActiveRecord::DestroyAssociationAsyncJob` ставится в очередь, которое вызовет destroy на его связанных объектах. Чтобы это работало, должен быть настроен Active Job. Не используйте эту опцию, если связь обеспечена ограничением внешнего ключу в вашей базе данных. Действия ограничения внешнего ключа произойдут в той же транзакции, которая удаляет владельца.

WARNING: Не следует определять эту опцию в связи `belongs_to`, которая соединена со связью `has_many` в другом классе. Это приведет к "битым" связям в записях вашей базы данных.

##### `:ensuring_owner_was`

Указывает метод экземпляра, вызываемого на владельце. Этот метод должен возвратить true, чтобы связанные записи удалялись в фоновом задании.

#### `:foreign_key`

По соглашению Rails предполагает, что столбец, используемый для хранения внешнего ключа в этой модели, имеет имя модели с добавленным суффиксом `_id`. Опция `:foreign_key` позволяет установить имя внешнего ключа явно:

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron",
                      foreign_key: "patron_id"
end
```

TIP: В любом случае, Rails не создаст столбцы внешнего ключа за вас. Вам необходимо явно определить их в своих миграциях.

##### `:foreign_type`

Указывает столбец, используемый для хранения типа связанного объекта, если это полиморфная связь. По умолчанию это угадывается как имя связи с суффиксом “`_type`”. Таким образом, класс, определяющий связь `belongs_to :taggable, polymorphic: true`, будет использовать “`taggable_type`” как `:foreign_type` по умолчанию.

#### `:primary_key`

По соглашению Rails предполагает, что для первичного ключа используется столбец `id` в таблице. Опция `:primary_key` позволяет указать иной столбец.

Например, имеется таблица `users` с `guid` в качестве первичного ключа. Если мы хотим отдельную таблицу `todos`, содержащую внешний ключ `user_id` из столбца `guid`, для этого можно использовать `primary_key` следующим образом:

```ruby
class User < ApplicationRecord
  self.primary_key = 'guid' # primary key is guid and not id
end

class Todo < ApplicationRecord
  belongs_to :user, primary_key: 'guid'
end
```

При выполнении `@user.todos.create`, у записи `@todo` будет значение `user_id` таким же, как значение `guid` у `@user`.

#### `:inverse_of`

Опция `:inverse_of` определяет имя связи `has_many` или `has_one`, являющейся противоположностью для этой связи. Подробности смотрите в разделе [Двунаправленная связь](#bi-directional-associations).

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:optional`

Если установить опции `:optional` `true`, не будет проверяться наличие связанного объекта. По умолчанию этой опции установлено `false`.

#### `:polymorphic`

Передача `true` для опции `:polymorphic` показывает, что это полиморфная связь. Полиморфные связи подробно рассматривались [ранее](#polymorphic-associations).

##### `:required`

Когда установлена `true`, у связи проверяется ее наличие. Будет проверяться сама связь, а не ее id. Можно использовать `:inverse_of`, чтобы избежать дополнительного запроса во время валидации.

NOTE: Установлена `true` по умолчанию и устарела. Если не хотите, чтобы проверялось наличие связи, используйте `optional: true`.

##### `:strict_loading`

Обеспечивает строгую загрузку всякий раз, когда связанная запись загружается через связь.

#### `:touch`

Если установите опцию `:touch` в `true`, то временные метки `updated_at` или `updated_on` на связанном объекте будут установлены в текущее время всякий раз, когда этот объект будет сохранен или уничтожен:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: true
end

class Author < ApplicationRecord
  has_many :books
end
```

В этом случае, сохранение или уничтожение книги обновит временную метку на связанном авторе. Также можно определить конкретный атрибут временной метки для обновления:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at
end
```

#### `:validate`

Если установите опцию `:validate` в `true`, тогда связанные объекты будут проходить валидацию всякий раз, когда вы сохраняете этот объект. По умолчанию она равна `false`: связанные объекты не проходят валидацию, когда этот объект сохраняется.

### Скоупы для `belongs_to`

Иногда хочется настроить запрос, используемый `belongs_to`. Такая настройка может быть достигнута с помощью блока скоупа. Например:

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

Внутри блока скоупа можно использовать любые стандартные [методы запросов](/active-record-querying). Далее обсудим следующие из них:

* `where`
* `includes`
* `readonly`
* `select`

#### `where`

Метод `where` позволяет определить условия, которым должен отвечать связанный объект.

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

#### `includes`

Метод `includes` можно использовать для определения связей второго порядка, которые должны быть лениво загружены при использовании этой связи. Например, рассмотрим эти модели:

```ruby
class Chapter < ApplicationRecord
  belongs_to :book
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

Если вы часто получаете авторов непосредственно из глав (`@chapter.book.author`), то можно улучшить эффективность кода, включив авторов в связь между книгой и ее главами:

```ruby
class Chapter < ApplicationRecord
  belongs_to :book, -> { includes :author }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

NOTE: Нет необходимости в использовании `includes` для ближайших связей - то есть, если есть `Book belongs_to :author`, то author автоматически лениво загружается при необходимости.

#### `readonly`

При использовании `readonly`, связанный объект будет только для чтения при получении через связь.

#### `select`

Метод `select` позволяет переопределить SQL выражение `SELECT`, используемое для получения данных о связанном объекте. По умолчанию Rails получает все столбцы.

TIP: При использовании метода `select` на связи `belongs_to`, следует также установить опцию `:foreign_key` для гарантии правильных результатов.

### Существуют ли связанные объекты?

Можно увидеть, существует ли какой-либо связанный объект, при использовании метода `association.nil?`:

```ruby
if @book.author.nil?
  @msg = "No author found for this book"
end
```

### Когда сохраняются объекты?

Присвоение связи `belongs_to` не приводит к автоматическому сохранению ни самого объекта, ни связанного объекта.

Подробная информация по связи `has_one`
---------------------------------------

Связь `has_one` создает соответствие один-к-одному с другой моделью. В терминах базы данных эта связь сообщает, что другой класс содержит внешний ключ. Если этот класс содержит внешний ключ, следует использовать `belongs_to`.

### Методы, добавляемые `has_one`

Когда объявляете связь `has_one`, объявляющий класс автоматически получает 6 методов, относящихся к связи:

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`

Во всех этих методах `association` заменяется на символ, переданный как первый аргумент в `has_one`. Например, имеем объявление:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

Каждый экземпляр модели `Supplier` будет иметь эти методы:

* `account`
* `account=`
* `build_account`
* `create_account`
* `create_account!`
* `reload_account`
* `reset_account`

NOTE: При установлении новой связи `has_one` или `belongs_to`, следует использовать префикс `build_` для построения связи, в отличие от метода `association.build`, используемого для связей `has_many` или `has_and_belongs_to_many`. Чтобы создать связь, используйте префикс `create_`.

#### `association`

Метод `association` возвращает связанный объект, если таковой имеется. Если связанный объект не найден, возвращает `nil`.

```ruby
@account = @supplier.account
```

Если связанный объект уже был получен из базы данных для этого объекта, возвращается кэшированная версия. Чтобы переопределить это поведение (и заставить прочитать из базы данных), вызовите `#reload_association` на родительском объекте.

```ruby
@account = @supplier.reload_account
```

Чтобы выгрузить кэшированную версию связанного объекта при следующем доступе, если таковая имеется, и прочитать ее из базы данных, вызовите `#reset_association` на родительском объекте.

```ruby
@book.reset_author
```

#### `association=(associate)`

Метод `association=` привязывает связанный объект к этому объекту. Фактически это означает извлечение первичного ключа этого объекта и присвоение его значения внешнему ключу связанного объекта.

```ruby
@supplier.account = @account
```

#### `build_association(attributes = {})`

Метод `build_association` возвращает новый объект связанного типа. Этот объект будет экземпляром с переданными атрибутами, и будет установлена связь через внешний ключ, но связанный объект пока _не_ будет сохранен.

```ruby
@account = @supplier.build_account(terms: "Net 30")
```

#### `create_association(attributes = {})`

Метод `create_association` возвращает новый объект связанного типа. Этот объект будет экземпляром с переданными атрибутами, будет установлена связь через внешний ключ, и, если он пройдет валидации, определенные в связанной модели, связанный объект _будет_ сохранен

```ruby
@account = @supplier.create_account(terms: "Net 30")
```

#### `create_association!(attributes = {})`

Работает так же, как и вышеприведенный `create_association`, но вызывает `ActiveRecord::RecordInvalid`, если запись невалидна.

### Опции для `has_one`

Хотя Rails использует разумные значения по умолчанию, работающие во многих ситуациях, бывают случаи, когда хочется изменить поведение связи `has_one`. Такая настройка легко выполнима с помощью передачи опции при создании связи. Например, эта связь использует две такие опции:

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing", dependent: :nullify
end
```

Связь [`has_one`][] поддерживает эти опции:

* `:as`
* `:autosave`
* `:class_name`
* `:dependent`
* `:disable_joins`
* `:ensuring_owner_was`
* `:foreign_key`
* `:inverse_of`
* `:primary_key`
* `:query_constraints`
* `:required`
* `:source`
* `:source_type`
* `:strict_loading`
* `:through`
* `:touch`
* `:validate`

#### `:as`

Установка опции `:as` показывает, что это полиморфная связь. Полиморфные связи подробно рассматривались [ранее](#polymorphic-associations).

#### `:autosave`

Если установить опцию `:autosave` в `true`, Rails сохранит любые загруженные связанные члены и уничтожит члены, помеченные для уничтожения, всякий раз, когда сохраняется родительский объект. Но установить `:autosave` в `false` - не то же самое, что не устанавливать опцию `:autosave`. Если опция `:autosave` отсутствует, то новые связанные объекты будут сохранены, но обновленные связанные объекты сохранены не будут.

#### `:class_name`

Если имя другой модели не может быть образовано из имени связи, можете использовать опцию `:class_name` для предоставления имени модели. Например, если поставщик имеет аккаунт, но фактическое имя модели, содержащей аккаунты, это `Billing`, можете установить это следующим образом:

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing"
end
```

#### `:dependent`

Управляет тем, что произойдет со связанным объектом, когда его владелец будет уничтожен:

* `:destroy` приведет к тому, что связанный объект также будет уничтожен
* `:delete` приведет к тому, что связанный объект будет удален из базы данных напрямую (таким образом не будут выполнены колбэки)
* `:destroy_async`: когда объект уничтожается, задание `ActiveRecord::DestroyAssociationAsyncJob` ставится в очередь, которое вызовет destroy на его связанных объектах. Чтобы это работало, должен быть настроен Active Job. Не используйте эту опцию, если связь обеспечена ограничением внешнего ключу в вашей базе данных. Действия ограничения внешнего ключа произойдут в той же транзакции, которая удаляет владельца.
* `:nullify` приведет к тому, что внешний ключ будет установлен `NULL`. Столбцы полиморфного типа на полиморфных связях также обнуляются. Колбэки не выполняются.
* `:restrict_with_exception` приведет к вызову исключения `ActiveRecord::DeleteRestrictionError`, если есть связанный объект
* `:restrict_with_error` приведет к ошибке, добавляемой к владельцу, если есть связанный объект

Нельзя устанавливать или оставлять опцию `:nullify` для связей, имеющих ограничение `NOT NULL`. Если не установить `dependent` для уничтожения таких связей, вы не сможете изменить связанный объект, так как внешнему ключу изначально связанного объекта будет назначено недопустимое значение `NULL`.

##### `:disable_joins`

Указывает, должны ли опускаться join для связи. Если установлено `true`, будут сгенерированы два или более запроса. Отметьте, что в некоторых случаях, если применено упорядочивание или лимит, это будет выполнено в памяти из-за ограничений базы данных. Эта опция применима только на связях `has_one :through`, так как одиночный `has_one` не выполняет join.

#### `:foreign_key`

По соглашению Rails предполагает, что столбец, используемый для хранения внешнего ключа в этой модели, имеет имя модели с добавленным суффиксом `_id`. Опция `:foreign_key` позволяет установить имя внешнего ключа явно:

```ruby
class Supplier < ApplicationRecord
  has_one :account, foreign_key: "supp_id"
end
```

TIP: В любом случае, Rails не создаст столбцы внешнего ключа за вас. Вам необходимо явно определить их в своих миграциях.

#### `:inverse_of`

Опция `:inverse_of` определяет имя связи `belongs_to`, являющейся обратной для этой связи. Подробности смотрите в разделе [Двунаправленная связь](#bi-directional-associations).

```ruby
class Supplier < ApplicationRecord
  has_one :account, inverse_of: :supplier
end

class Account < ApplicationRecord
  belongs_to :supplier, inverse_of: :account
end
```

#### `:primary_key`

По соглашению, Rails предполагает, что столбец, используемый для хранения первичного ключа, это `id`. Вы можете переопределить это и явно определить первичный ключ с помощью опции `:primary_key`.

##### `:query_constraints`

Служит в качестве составного внешнего ключа. Определяет список столбцов для использования при запросе связанного объекта. Это необязательная опция. По умолчанию Rails попытается вывести значение автоматически. Когда есть значение, размер массива должен соответствовать размеру первичного ключа связанной модели или размеру `query_constraints`.

##### `:required`

Когда установлено `true`, у связи также будет проверено ее наличие. Это проверит саму связь, а не id. Можно использовать `:inverse_of`, чтобы избежать дополнительного запроса во время валидации.

#### `:source`

Опция `:source` определяет имя источника связи для связи `has_one :through`.

#### `:source_type`

Опция `:source_type` определяет тип источника связи для связи `has_one :through`, который действует при полиморфной связи.

```ruby
class Author < ApplicationRecord
  has_one :book
  has_one :hardback, through: :book, source: :format, source_type: "Hardback"
  has_one :dust_jacket, through: :hardback
end

class Book < ApplicationRecord
  belongs_to :format, polymorphic: true
end

class Paperback < ApplicationRecord; end

class Hardback < ApplicationRecord
  has_one :dust_jacket
end

class DustJacket < ApplicationRecord; end
```

##### `:strict_loading`

Обеспечивает строгую загрузку всякий раз, когда связанная запись загружается через связь.

#### `:through`

Опция `:through` определяет соединительную модель, через которую выполняется запрос. Связи `has_one :through` подробно рассматривались [ранее](#the-has-one-through-association).

##### `:touch`

Если опция `:touch` установлена `true`, тогда временные метки `updated_at` или `updated_on` у связанного объекта будут установлены в текущее время всякий раз, когда этот объект будет сохранен или уничтожен:

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: true
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

В этом случае, сохранение или удаление поставщика обновит временную метку у связанного счета. Также можно указать конкретный атрибут временной метки для обновления:

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: :suppliers_updated_at
end
```

#### `:validate`

Если установите опцию `:validate` в `true`, тогда новые связанные объекты будут проходить валидацию всякий раз, когда вы сохраняете этот объект. По умолчанию она равна `false`: новые связанные объекты не проходят валидацию, когда этот объект сохраняется.

### Скоупы для `has_one`

Иногда хочется настроить запрос, используемый `has_one`. Такая настройка может быть достигнута с помощью блока скоупа. Например:

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where active: true }
end
```

Внутри блока скоупа можно использовать любые стандартные [методы запросов](/active-record-querying). Далее обсудим следующие из них:

* `where`
* `includes`
* `readonly`
* `select`

#### `where`

Метод `where` позволяет определить условия, которым должен отвечать связанный объект.

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where "confirmed = 1" }
end
```

#### `includes`

Метод `includes` позволяет определить связи второго порядка, которые должны быть лениво загружены при использовании этой связи. Например, рассмотрим эти модели:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ApplicationRecord
  has_many :accounts
end
```

Если вы часто получаете representatives непосредственно из suppliers (`@supplier.account.representative`), то можно улучшить эффективность кода, включив representatives в связь между suppliers и accounts:

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { includes :representative }
end

class Account < ApplicationRecord
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ApplicationRecord
  has_many :accounts
end
```

#### `readonly`

При использовании `readonly`, связанный объект будет только для чтения при получении через связь.

#### `select`

Метод `select` позволяет переопределить SQL выражение `SELECT`, используемое для получения данных о связанном объекте. По умолчанию Rails получает все столбцы.

### Существуют ли связанные объекты?

Можно увидеть, существует ли какой-либо связанный объект, при использовании метода `association.nil?`:

```ruby
if @supplier.account.nil?
  @msg = "No account found for this supplier"
end
```

### Когда сохраняются объекты?

Когда вы назначаете объект связью `has_one`, этот объект автоматически сохраняется (для того, чтобы обновить его внешний ключ). Кроме того, любой заменяемый объект также автоматически сохраняется, поскольку его внешний ключ также изменяется.

Если одно из этих сохранений проваливается из-за ошибок валидации, тогда выражение назначения возвращает `false`, и само назначение отменяется.

Если родительский объект (который объявляет связь `has_one`) является несохраненным (то есть `new_record?` возвращает `true`), тогда дочерние объекты не сохраняются. Они сохранятся автоматически, когда сохранится родительский объект.

Если вы хотите назначить объект связью `has_one` без сохранения объекта, используйте метод `build_association`.

(has-many-association-reference) Подробная информация по связи `has_many`
-------------------------------------------------------------------------

Связь `has_many` создает отношение один-ко-многим с другой моделью. В терминах базы данных эта связь говорит, что другой класс будет иметь внешний ключ, относящийся к экземплярам этого класса.

### Методы, добавляемые `has_many`

Когда объявляете связь `has_many`, объявляющий класс автоматически получает 17 методов, относящихся к связи:

* `collection`
* [`collection<<(object, ...)`][`collection<<`]
* [`collection.delete(object, ...)`][`collection.delete`]
* [`collection.destroy(object, ...)`][`collection.destroy`]
* `collection=(objects)`
* `collection_singular_ids`
* `collection_singular_ids=(ids)`
* [`collection.clear`][]
* [`collection.empty?`][]
* [`collection.size`][]
* [`collection.find(...)`][`collection.find`]
* [`collection.where(...)`][`collection.where`]
* [`collection.exists?(...)`][`collection.exists?`]
* [`collection.build(attributes = {})`][`collection.build`]
* [`collection.create(attributes = {})`][`collection.create`]
* [`collection.create!(attributes = {})`][`collection.create!`]
* [`collection.reload`][]

Во всех этих методах `collection` заменяется символом, переданным как первый аргумент в `has_many`, и `collection_singular` заменяется версией в единственном числе этого символа. Например, имеем объявление:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

Каждый экземпляр модели `Author` будет иметь эти методы:

```
books
books<<(object, ...)
books.delete(object, ...)
books.destroy(object, ...)
books=(objects)
book_ids
book_ids=(ids)
books.clear
books.empty?
books.size
books.find(...)
books.where(...)
books.exists?(...)
books.build(attributes = {}, ...)
books.create(attributes = {})
books.create!(attributes = {})
books.reload
```

[`collection<<`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-3C-3C
[`collection.build`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-build
[`collection.clear`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-clear
[`collection.create`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-create
[`collection.create!`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-create-21
[`collection.delete`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-delete
[`collection.destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-destroy
[`collection.empty?`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-empty-3F
[`collection.exists?`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-exists-3F
[`collection.find`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-find
[`collection.reload`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-reload
[`collection.size`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-size
[`collection.where`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where

#### `collection`

Метод `collection` возвращает Relation всех связанных объектов. Если нет связанных объектов, он возвращает пустой Relation.

```ruby
@books = @author.books
```

#### `collection<<(object, ...)`

Метод [`collection<<`][] добавляет один или более объектов в коллекцию, устанавливая их внешние ключи равными первичному ключу вызывающей модели.

```ruby
@author.books << @book1
```

#### `collection.delete(object, ...)`

Метод [`collection.delete`][] убирает один или более объектов из коллекции, установив их внешние ключи в `NULL`.

```ruby
@author.books.delete(@book1)
```

WARNING: Объекты будут в дополнение уничтожены, если связаны с `dependent: :destroy`, и удалены, если они связаны с `dependent: :delete_all`.

#### `collection.destroy(object, ...)`

Метод [`collection.destroy`][] убирает один или более объектов из коллекции, выполняя `destroy` для каждого объекта.

```ruby
@author.books.destroy(@book1)
```

WARNING: Объекты будут _всегда_ удаляться из базы данных, игнорируя опцию `:dependent`.

#### `collection=(objects)`

Метод `collection=` делает коллекцию содержащей только представленные объекты, добавляя и удаляя по мере необходимости. Изменения будут персистентными в базе данных.

#### `collection_singular_ids`

Метод `collection_singular_ids` возвращает массив id объектов в коллекции.

```ruby
@book_ids = @author.book_ids
```

#### `collection_singular_ids=(ids)`

Метод `collection_singular_ids=` делает коллекцию содержащей только объекты, идентифицированные представленными значениями первичного ключа, добавляя и удаляя по мере необходимости. Изменения будут персистентными в базе данных.

#### `collection.clear`

Метод [`collection.clear`][] убирает каждый объект из коллекции в соответствии со стратегией, определенной опцией `dependent`. Если опция не указана, он следует стратегии по умолчанию. Стратегия по умолчанию для `has_many :through` это `delete_all`, а для связей `has_many` — установить их внешние ключи в `NULL`.

```ruby
@author.books.clear
```

WARNING: Объекты будут удалены, если они связаны с помощью `dependent: :destroy` или `dependent: :destroy_async`, как и с помощью `dependent: :delete_all`.

#### `collection.empty?`

Метод [`collection.empty?`][] возвращает `true`, если коллекция не содержит каких-либо связанных объектов.

```ruby
<% if @author.books.empty? %>
  No Books Found
<% end %>
```

#### `collection.size`

Метод [`collection.size`][] возвращает количество объектов в коллекции.

```ruby
@book_count = @author.books.size
```

#### `collection.find(...)`

Метод [`collection.find`][] ищет объекты в таблице коллекции.

```ruby
@available_book = @author.books.find(1)
```

#### `collection.where(...)`

Метод [`collection.where`][] ищет объекты в коллекции, основываясь на переданных условиях, но объекты загружаются лениво, что означает, что база данных запрашивается только когда происходит доступ к объекту(-там).

```ruby
@available_books = @author.books.where(available: true) # Пока нет запроса
@available_book = @available_books.first # Теперь база данных будет запрошена
```

#### `collection.exists?(...)`

Метод [`collection.exists?`][] проверяет, существует ли в таблице коллекции объект, отвечающий представленным условиям.

#### `collection.build(attributes = {})`

Метод [`collection.build`][] возвращает один или массив объектов связанного типа. Объект(ы) будут экземплярами с переданными атрибутами, будет создана ссылка через их внешние ключи, но связанные объекты _не_ будут пока сохранены.

```ruby
@book = @author.books.build(published_at: Time.now,
                            book_number: "A12345")

@books = @author.books.build([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }])
```

#### `collection.create(attributes = {})`

Метод [`collection.create`][] возвращает один или массив новых объектов связанного типа. Объект(ы) будут экземплярами с переданными атрибутами, будет создана ссылка через его внешний ключ, и, если он пройдет валидации, определенные в связанной модели, связанный объект _будет_ сохранен

```ruby
@book = @author.books.create(published_at: Time.now,
                             book_number: "A12345")

@books = @author.books.create([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }])
```

#### `collection.create!(attributes = {})`

Работает так же, как вышеприведенный `collection.create`, но вызывает `ActiveRecord::RecordInvalid`, если запись невалидна.

#### `collection.reload`

Метод [`collection.reload`][] возвращает Relation всех связанных объектов, принудительно читая базу данных. Если нет связанных объектов, он возвращает пустой Relation.

```ruby
@books = @author.books.reload
```

### Опции для `has_many`

Хотя Rails использует разумные значения по умолчанию, работающие во многих ситуациях, бывают случаи, когда хочется изменить поведение связи `has_many`. Такая настройка легко выполнима с помощью передачи опций при создании связи. Например, эта связь использует две такие опции:

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :delete_all, validate: false
end
```

Связь [`has_many`][] поддерживает эти опции:

* `:as`
* `:autosave`
* `:class_name`
* `:counter_cache`
* `:dependent`
* `:disable_joins`
* `:ensuring_owner_was`
* `:extend`
* `:foreign_key`
* `:foreign_type`
* `:inverse_of`
* `:primary_key`
* `:query_constraints`
* `:source`
* `:source_type`
* `:strict_loading`
* `:through`
* `:validate`

#### `:as`

Установка опции `:as` показывает, что это полиморфная связь. Полиморфные связи подробно рассматривались [ранее](#polymorphic-associations).

#### `:autosave`

Если установить опцию `:autosave` в `true`, Rails сохранит любые загруженные связанные члены и уничтожит члены, помеченные для уничтожения, всякий раз, когда сохраняется родительский объект. Но установить `:autosave` в `false` - не то же самое, что не устанавливать опцию `:autosave`. Если опция `:autosave` отсутствует, то новые связанные объекты будут сохранены, но обновленные связанные объекты сохранены не будут.

#### `:class_name`

Если имя другой модели не может быть произведено из имени связи, можете использовать опцию `:class_name` для предоставления имени модели. Например, если автор имеет много книг, но фактическое имя модели, содержащей книги, это `Transaction`, можете установить это следующим образом:

```ruby
class Author < ApplicationRecord
  has_many :books, class_name: "Transaction"
end
```

#### `:counter_cache`

Эта опция используется для настройки произвольно названного `:counter_cache`. Эту опцию нужно использовать, только если вы изменили имя вашего `:counter_cache` у [связи belongs_to](#options-for-belongs-to).

#### `:dependent`

Управляет тем, что произойдет со связанными объектами, когда его владелец будет уничтожен:

* `:destroy` приведет к тому, что связанные объекты также будут уничтожены
* `:delete_all` приведет к тому, что связанные объекты будут удалены из базы данных напрямую (таким образом не будут выполнены колбэки)
* `:destroy_async`: когда объект уничтожается, задание `ActiveRecord::DestroyAssociationAsyncJob` ставится в очередь, которое вызовет destroy на его связанных объектах. Чтобы это работало, должен быть настроен Active Job.
* `:nullify` приведет к тому, что внешние ключи будет установлен `NULL`. Столбцы полиморфного типа на полиморфных связях также обнуляются. Колбэки не выполняются.
* `:restrict_with_exception` приведет к вызову исключения `ActiveRecord::DeleteRestrictionError`, если есть какой-нибудь связанный объект
* `:restrict_with_error` приведет к ошибке, добавляемой к владельцу, если есть какой-нибудь связанный объект

Опции `:destroy` и `:delete_all` также влияют на семантику методов `collection.delete` и `collection=`, вынуждая их удалять связанные объекты при удалении из коллекции.

##### `:disable_joins`

Указывает, должны ли опускаться join для связи. Если установлено `true`, будут сгенерированы два или более запроса. Отметьте, что в некоторых случаях, если применено упорядочивание или лимит, это будет выполнено в памяти из-за ограничений базы данных. Эта опция применима только на связях `has_many :through`, так как одиночный `has_many` не выполняет join.

##### `:ensuring_owner_was`

Указывает метод экземпляра, вызываемого на владельце. Этот метод должен возвратить true, чтобы связанные записи удалялись в фоновом задании.

##### `:extend`

Указывает модуль или массив модулей, расширяющих возвращаемый связанный объект. Полезно для определения методов на связях, в особенности когда они должны быть общими у объектов нескольких связей.

#### `:foreign_key`

По соглашению Rails предполагает, что столбец, используемый для хранения внешнего ключа в этой модели, имеет имя модели с добавленным суффиксом `_id`. Опция `:foreign_key` позволяет установить имя внешнего ключа явно:

```ruby
class Author < ActiveRecord::Base
  has_many :books, foreign_key: "cust_id"
end
```

TIP: В любом случае, Rails не создаст столбцы внешнего ключа за вас. Вам необходимо явно определить их в своих миграциях.

##### `:foreign_type`

Указывает столбец, используемый для хранения типа связанного объекта, если это полиморфная связь. По умолчанию это угадывается как имя полиморфной связи, указанное на опции “`as`” с суффиксом “`_type`”. Таким образом, класс, определяющий связь `has_many :tags, as: :taggable`, будет использовать “`taggable_type`” как `:foreign_type` по умолчанию.

#### `:inverse_of`

Опция `:inverse_of` определяет имя связи `belongs_to`, являющейся обратной для этой связи. Подробности смотрите в разделе [Двунаправленная связь](#bi-directional-associations).

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

#### `:primary_key`

По соглашению, Rails предполагает, что столбец, используемый для хранения первичного ключа, это `id`. Вы можете переопределить это и явно определить первичный ключ с помощью опции `:primary_key`.

Допустим, в таблице `users` есть `id` в качестве primary_key, но также имеется столбец `guid`. Имеется требование, что таблица `todos` должна содержать значение столбца `guid`, а не значение `id`. Это достигается следующим образом:

```ruby
class User < ApplicationRecord
  has_many :todos, primary_key: :guid
end
```

Теперь, если выполнить `@todo = @user.todos.create`, то в запись `@todo` значение `user_id` будет таким же, как значение `guid` в `@user`.

##### `:query_constraints`

Служит в качестве составного внешнего ключа. Определяет список столбцов для использования при запросе связанного объекта. Это необязательная опция. По умолчанию Rails попытается вывести значение автоматически. Когда есть значение, размер массива должен соответствовать размеру первичного ключа связанной модели или размеру `query_constraints`.

#### `:source`

Опция `:source` определяет имя источника связи для связи `has_many :through`. Эту опцию нужно использовать, только если имя источника связи не может быть автоматически выведено из имени связи.

```ruby
class Author < ApplicationRecord
  has_many :books
  has_many :paperbacks, through: :books, source: :format, source_type: "Paperback"
end

class Book < ApplicationRecord
  belongs_to :format, polymorphic: true
end

class Hardback < ApplicationRecord; end
class Paperback < ApplicationRecord; end
```

#### `:source_type`

Опция `:source_type` определяет тип источника связи для связи `has_many :through`, который действует при полиморфной связи.

##### `:strict_loading`

Когда установлено true, обеспечивает строгую загрузку всякий раз, когда связанная запись загружается через связь.

#### `:through`

Опция `:through` определяет соединительную модель, через которую выполняется запрос. Связи `has_many :through` предоставляют способ осуществления отношений многие-ко-многим, как обсуждалось [ранее в этом руководстве](#the-has-many-through-association).

#### `:validate`

Если установите опцию `:validate` в `false`, тогда новые связанные объекты не будут проходить валидацию всякий раз, когда вы сохраняете этот объект. По умолчанию она равна `true`: новые связанные объекты проходят валидацию, когда этот объект сохраняется.

### Скоупы для `has_many`

Иногда хочется настроить запрос, используемый `has_many`. Такая настройка может быть достигнута с помощью блока скоупа. Например:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { where processed: true }
end
```

Внутри блока скоупа можно использовать любые стандартные [методы запросов](/active-record-querying). Далее обсудим следующие из них:

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `distinct`

#### `where`

Метод `where` позволяет определить условия, которым должен отвечать связанный объект.

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where "confirmed = 1" },
    class_name: "Book"
end
```

Также можно задать условия хэшем:

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where confirmed: true },
    class_name: "Book"
end
```

При использовании опции `where` хэшем, при создание записи через эту связь будет автоматически применен скоуп с использованием хэша. В этом случае при использовании `@author.confirmed_books.create` или `@author.confirmed_books.build` будут созданы книги, в которых столбец confirmed будет иметь значение `true`.

#### `extending`

Метод `extending` определяет именованный модуль для расширения прокси связи. Расширения связей подробно обсуждаются [позже в этом руководстве](#association-callbacks-and-extensions).

#### `group`

Метод `group` предоставляет имя атрибута, по которому группируется результирующий набор, используя выражение `GROUP BY` в поисковом SQL.

```ruby
class Author < ApplicationRecord
  has_many :chapters, -> { group 'books.id' },
                      through: :books
end
```

#### `includes`

Можете использовать метод `includes` для определения связей второго порядка, которые должны быть нетерпеливо загружены, когда эта связь используется. Например, рассмотрим эти модели:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```

Если вы часто получаете главы прямо из авторов (`@author.books.chapters`), тогда можете сделать свой код более эффективным, включив главы в связь от авторов к книгам:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { includes :chapters }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```

#### `limit`

Метод `limit` позволяет ограничить общее количество объектов, которые будут выбраны через связь.

```ruby
class Author < ApplicationRecord
  has_many :recent_books,
    -> { order('published_at desc').limit(100) },
    class_name: "Book"
end
```

#### `offset`

Метод `offset` позволяет определить начальное смещение для выбора объектов через связь. Например, `-> { offset(11) }` пропустит первые 11 записей.

#### `order`

Метод `order` предписывает порядок, в котором связанные объекты будут получены (в синтаксисе SQL, используемом в условии `ORDER BY`).

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order "date_confirmed DESC" }
end
```

#### `readonly`

При использовании метода `readonly`, связанные объекты будут доступны только для чтения, когда получены посредством связи.

#### `select`

Метод `select` позволяет переопределить SQL условие `SELECT`, которое используется для получения данных о связанном объекте. По умолчанию Rails получает все столбцы.

WARNING: Если укажете свой собственный `select`, не забудьте включить столбцы первичного ключа и внешнего ключа в связанной модели. Если так не сделать, Rails выдаст ошибку.

#### `distinct`

Используйте метод `distinct`, чтобы убирать дубликаты из коллекции. Это полезно в сочетании с опцией `:through`.

```ruby
class Person < ApplicationRecord
  has_many :readings
  has_many :articles, through: :readings
end
```

```irb
irb> person = Person.create(name: 'John')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
irb> person.articles.to_a
=> [#<Article id: 5, name: "a1">, #<Article id: 5, name: "a1">]
irb> Reading.all.to_a
=> [#<Reading id: 12, person_id: 5, article_id: 5>, #<Reading id: 13, person_id: 5, article_id: 5>]
```

В вышеописанной задаче два reading, и `person.articles` выявляет их оба, даже если эти записи указывают на одну и ту же статью.

Давайте установим `distinct`:

```ruby
class Person
  has_many :readings
  has_many :articles, -> { distinct }, through: :readings
end
```

```irb
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
irb> person.articles.to_a
=> [#<Article id: 7, name: "a1">]
irb> Reading.all.to_a
=> [#<Reading id: 16, person_id: 7, article_id: 7>, #<Reading id: 17, person_id: 7, article_id: 7>]
```

В вышеописанной задаче все еще два reading. Однако `person.articles` показывает только одну статью, поскольку коллекция загружает только уникальные записи.

Если вы хотите быть уверенными, что после вставки все записи персистентной связи различны (и, таким образом, убедиться, что при просмотре связи никогда не будет дублирующихся записей), следует добавить уникальный индекс для самой таблицы. Например, если таблица называется `readings`, и вы хотите убедиться, что все публикации могут быть добавлены к персоне один раз, следует добавить в миграцию:

```ruby
add_index :readings, [:person_id, :article_id], unique: true
```

Как только у вас появится этот индекс уникальности, попытка добавить статью к персоне дважды вызовет ошибку `ActiveRecord::RecordNotUnique`:

```irb
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
ActiveRecord::RecordNotUnique
```

Отметьте, что проверка уникальности при использовании чего-то, наподобие `include?`, подвержено состояниям гонки. Не пытайтесь использовать `include?` для соблюдения уникальности в связи. Используя вышеприведенный пример со статьёй, нижеследующий код вызовет гонку, поскольку несколько пользователей могут использовать его одновременно:

```ruby
person.articles << article unless person.articles.include?(post)
```

### Когда сохраняются объекты?

Когда вы назначаете объект связью `has_many`, этот объект автоматически сохраняется (для того, чтобы обновить его внешний ключ). Если назначаете несколько объектов в одном выражении, они все будут сохранены.

Если одно из этих сохранений проваливается из-за ошибок валидации, тогда выражение назначения возвращает `false`, и само назначение отменяется.

Если родительский объект (который объявляет связь `has_many`) является несохраненным (то есть `new_record?` возвращает `true`), тогда дочерние объекты не сохраняются при добавлении. Все несохраненные члены связи сохранятся автоматически, когда сохранится родительский объект.

Если вы хотите назначить объект связью `has_many` без сохранения объекта, используйте метод `collection.build`.

Подробная информация по связи `has_and_belongs_to_many`
-------------------------------------------------------

Связь `has_and_belongs_to_many` создает отношение многие-ко-многим с другой моделью. В терминах базы данных это связывает два класса через промежуточную соединительную таблицу, которая включает внешние ключи, относящиеся к каждому классу.

### Методы, добавляемые `has_and_belongs_to_many`

Когда объявляете связь `has_and_belongs_to_many`, объявляющий класс автоматически получает несколько методов, относящихся к связи:

* `collection`
* [`collection<<(object, ...)`][`collection<<`]
* [`collection.delete(object, ...)`][`collection.delete`]
* [`collection.destroy(object, ...)`][`collection.destroy`]
* `collection=(objects)`
* `collection_singular_ids`
* `collection_singular_ids=(ids)`
* [`collection.clear`][]
* [`collection.empty?`][]
* [`collection.size`][]
* [`collection.find(...)`][`collection.find`]
* [`collection.where(...)`][`collection.where`]
* [`collection.exists?(...)`][`collection.exists?`]
* [`collection.build(attributes = {})`][`collection.build`]
* [`collection.create(attributes = {})`][`collection.create`]
* [`collection.create!(attributes = {})`][`collection.create!`]
* [`collection.reload`][]

Во всех этих методах `collection` заменяется символом, переданным как первый аргумент в `has_and_belongs_to_many`, а `collection_singular` заменяется версией в единственном числе этого символа. Например, имеем объявление:

```ruby
class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

Каждый экземпляр модели `Part` будет иметь следующие методы:

```
assemblies
assemblies<<(object, ...)
assemblies.delete(object, ...)
assemblies.destroy(object, ...)
assemblies=(objects)
assembly_ids
assembly_ids=(ids)
assemblies.clear
assemblies.empty?
assemblies.size
assemblies.find(...)
assemblies.where(...)
assemblies.exists?(...)
assemblies.build(attributes = {}, ...)
assemblies.create(attributes = {})
assemblies.create!(attributes = {})
assemblies.reload
```

#### Дополнительные методы столбцов

Если соединительная таблица для связи `has_and_belongs_to_many` имеет дополнительные столбцы, кроме двух внешних ключей, эти столбцы будут добавлены как атрибуты к записям, получаемым посредством связи. Записи, возвращаемые с дополнительными атрибутами, будут всегда только для чтения, поскольку Rails не может сохранить значения этих атрибутов.

WARNING: Использование дополнительных атрибутов в соединительной таблице в связи has_and_belongs_to_many устарело. Если требуется этот тип сложного поведения таблицы, соединяющей две модели в отношениях многие-ко-многим, следует использовать связь `has_many :through` вместо `has_and_belongs_to_many`.

#### `collection`

Метод `collection` возвращает Relation всех связанных объектов. Если нет связанных объектов, он возвращает пустой Relation.

```ruby
@assemblies = @part.assemblies
```

#### `collection<<(object, ...)`

Метод [`collection<<`][] добавляет один или более объектов в коллекцию, создавая записи в соединительной таблице.

```ruby
@part.assemblies << @assembly1
```

NOTE: Этот метод - просто псевдоним к `collection.concat` и `collection.push`.

#### `collection.delete(object, ...)`

Метод [`collection.delete`][] убирает один или более объектов из коллекции, удаляя записи в соединительной таблице. Это не уничтожает объекты.

```ruby
@part.assemblies.delete(@assembly1)
```

#### `collection.destroy(object, ...)`

Метод [`collection.destroy`][] убирает один или более объектов из коллекции, удаляя записи в соединительной таблице. Это не уничтожает объекты.

```ruby
@part.assemblies.destroy(@assembly1)
```

#### `collection=(objects)`

Метод `collection=` делает коллекцию содержащей только представленные объекты, добавляя и удаляя по мере необходимости. Изменения будут персистентными в базе данных.

#### `collection_singular_ids`

Метод `collection_singular_ids` возвращает массив id объектов в коллекции.

```ruby
@assembly_ids = @part.assembly_ids
```

#### `collection_singular_ids=(ids)`

Метод `collection_singular_ids=` делает коллекцию содержащей только объекты, идентифицированные представленными значениями первичного ключа, добавляя и удаляя по мере необходимости. Изменения будут персистентными в базе данных.

#### `collection.clear`

Метод [`collection.clear`][] убирает каждый объект из коллекции, удаляя строки из соединительной таблицы. Это не уничтожает связанные объекты.

#### `collection.empty?`

Метод [`collection.empty?`][] возвращает `true`, если коллекция не содержит каких-либо связанных объектов.

```html+erb
<% if @part.assemblies.empty? %>
  This part is not used in any assemblies
<% end %>
```

#### `collection.size`

Метод [`collection.size`][] возвращает количество объектов в коллекции.

```ruby
@assembly_count = @part.assemblies.size
```

#### `collection.find(...)`

Метод [`collection.find`][] ищет объекты в таблице коллекции.

```ruby
@assembly = @part.assemblies.find(1)
```

#### `collection.where(...)`

Метод [`collection.where`][] ищет объекты в коллекции, основываясь на переданных условиях, но объекты загружаются лениво, что означает, что база данных запрашивается только когда происходит доступ к объекту(-там).

```ruby
@new_assemblies = @part.assemblies.where("created_at > ?", 2.days.ago)
```

#### `collection.exists?(...)`

Метод [`collection.exists?`][] проверяет, существует ли в таблице коллекции объект, отвечающий представленным условиям.

#### `collection.build(attributes = {})`

Метод [`collection.build`][] возвращает один или более объектов связанного типа. Эти объекты будут экземплярами с переданными атрибутами, и будет создана связь через соединительную таблицу, но связанный объект пока _не_ будет сохранен.

```ruby
@assembly = @part.assemblies.build({ assembly_name: "Transmission housing" })
```

#### `collection.create(attributes = {})`

Метод [`collection.create`][] возвращает один или более объектов связанного типа. Эти объекты будут экземплярами с переданными атрибутами, будет создана связь через соединительную таблицу, и, если он пройдет валидации, определенные в связанной модели, связанный объект _будет_ сохранен.

```ruby
@assembly = @part.assemblies.create({ assembly_name: "Transmission housing" })
```

#### `collection.create!(attributes = {})`

Работает так же, как вышеприведенный `collection.create`, но вызывает `ActiveRecord::RecordInvalid`, если запись невалидна.

#### `collection.reload`

Метод [`collection.reload`][] возвращает Relation всех связанных объектов, принудительно читая базу данных. Если нет связанных объектов, он возвращает пустой Relation.

```ruby
@assemblies = @part.assemblies.reload
```

### Опции для `has_and_belongs_to_many`

Хотя Rails использует разумные значения по умолчанию, работающие во многих ситуациях, бывают случаи, когда хочется изменить поведение связи `has_and_belongs_to_many`. Такая настройка легко выполнима с помощью передачи опции при создании связи. Например, эта связь использует две такие опции:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { readonly },
                                       autosave: true
end
```

Связь [`has_and_belongs_to_many`][] поддерживает эти опции:

* `:association_foreign_key`
* `:autosave`
* `:class_name`
* `:foreign_key`
* `:join_table`
* `:strict_loading`
* `:validate`

#### `:association_foreign_key`

По соглашению Rails предполагает, что столбец в соединительной таблице, используемый для хранения внешнего ключа, указываемого на другую модель, является именем этой модели с добавленным суффиксом `_id`. Опция `:association_foreign_key` позволяет установить имя внешнего ключа явно:

TIP: Опции `:foreign_key` и `:association_foreign_key` полезны при настройке присоединения к себе многие-ко-многим. Например:

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

#### `:autosave`

Если установить опцию `:autosave` в `true`, Rails сохранит любые загруженные связанные члены и уничтожит члены, помеченные для уничтожения, всякий раз, когда сохраняется родительский объект. Но установить `:autosave` в `false` - не то же самое, что не устанавливать опцию `:autosave`. Если опция `:autosave` отсутствует, то новые связанные объекты будут сохранены, но обновленные связанные объекты сохранены не будут.

#### `:class_name`

Если имя другой модели не может быть произведено из имени связи, можете использовать опцию `:class_name` для предоставления имени модели. Например, если часть имеет много сборок, но фактическое имя модели, содержащей сборки - это `Gadget`, можете установить это следующим образом:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, class_name: "Gadget"
end
```

#### `:foreign_key`

По соглашению Rails предполагает, что столбец в соединительной таблице, используемый для хранения внешнего ключа, указываемого на эту модель, имеет имя модели с добавленным суффиксом `_id`. Опция `:foreign_key` позволяет установить имя внешнего ключа явно:

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

#### `:join_table`

Если имя соединительной таблицы по умолчанию, основанное на алфавитном порядке, - это не то, что вам нужно, используйте опцию `:join_table`, чтобы переопределить его.

##### `:strict_loading`

Обеспечивает строгую загрузку всякий раз, когда связанная запись загружается через связь.

#### `:validate`

Если установите опцию `:validate` в `false`, тогда новые связанные объекты не будут проходить валидацию всякий раз, когда вы сохраняете этот объект. По умолчанию она равна `true`: новые связанные объекты проходят валидацию, когда этот объект сохраняется.

### Скоупы для `has_and_belongs_to_many`

Иногда хочется настроить запрос, используемый `has_many`. Такая настройка может быть достигнута с помощью блока скоупа. Например:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { where active: true }
end
```

Внутри блока скоупа можно использовать любые стандартные [методы запросов](/active-record-querying). Далее обсудим следующие из них:

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `distinct`

#### `where`

Метод `where` позволяет определить условия, которым должен отвечать связанный объект.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where "factory = 'Seattle'" }
end
```

Также можно задать условия хэшем:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where factory: 'Seattle' }
end
```

При использовании опции `where` хэшем, при создание записи через эту связь будет автоматически применен скоуп с использованием хэша. В этом случае при использовании `@parts.assemblies.create` или `@parts.assemblies.build` будут созданы сборки, в которых столбец `factory` будет иметь значение `Seattle`.

#### `extending`

Метод `extending` определяет именованный модуль для расширения прокси связи. Расширения связей подробно обсуждаются [позже в этом руководстве](#association-callbacks-and-extensions).

#### `group`

Метод `group` предоставляет имя атрибута, по которому группируется результирующий набор, используя выражение `GROUP BY` в поисковом запросе SQL.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { group "factory" }
end
```

#### `includes`

Можете использовать метод `includes` для определения связей второго порядка, которые должны быть нетерпеливо загружены, когда эта связь используется.

#### `limit`

Метод `limit` позволяет ограничить общее количество объектов, которые будут выбраны через связь.

```ruby
class Customer < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order("created_at DESC").limit(50) }
end
```

#### `offset`

Метод `offset` позволяет определить начальное смещение для выбора объектов через связь. Например, `-> { offset(11) }` пропустит первые 11 записей.

#### `order`

Метод `order` предписывает порядок, в котором связанные объекты будут получены (в синтаксисе SQL, используемом в условии `ORDER BY`).

```ruby
class Customer < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order "assembly_name ASC" }
end
```

#### `readonly`

При использовании метода `:readonly`, связанные объекты будут доступны только для чтения, когда получены посредством связи.

#### `select`

Метод `select` позволяет переопределить SQL условие `SELECT`, которое используется для получения данных о связанном объекте. По умолчанию Rails получает все столбцы.

#### `distinct`

Используйте метод `distinct`, чтобы убирать дубликаты из коллекции.

### Когда сохраняются объекты?

Когда вы назначаете объект связью `has_and_belongs_to_many`, этот объект автоматически сохраняется (в порядке обновления соединительной таблицы). Если назначаете несколько объектов в одном выражении, они все будут сохранены.

Если одно из этих сохранений проваливается из-за ошибок валидации, тогда выражение назначения возвращает `false`, a само назначение отменяется.

Если родительский объект (который объявляет связь `has_and_belongs_to_many`) является несохраненным (то есть `new_record?` возвращает `true`), тогда дочерние объекты не сохраняются при добавлении. Все несохраненные члены связи сохранятся автоматически, когда сохранится родительский объект.

Если вы хотите назначить объект связью `has_and_belongs_to_many` без сохранения объекта, используйте метод `collection.build`.

(association-callbacks-and-extensions) Подробная информация по колбэкам и расширениям связи
-------------------------------------------------------------------------------------------

### Колбэки связи

Обычно колбэки прицепляются к жизненному циклу объектов Active Record, позволяя вам работать с этими объектами в различных точках. Например, можете использовать колбэк `:before_save`, чтобы вызвать что-то перед тем, как объект будет сохранен.

Колбэки связи похожи на обычные колбэки, но они включаются событиями в жизненном цикле коллекции. Доступны четыре колбэка связи:

* `before_add`
* `after_add`
* `before_remove`
* `after_remove`

Колбэки связи объявляются с помощью добавления опций в объявление связи. Например:

```ruby
class Author < ApplicationRecord
  has_many :books, before_add: :check_credit_limit

  def check_credit_limit(book)
    # ...
  end
end
```

Подробнее о колбэках связи читайте в [Руководстве о колбэках Active Record](/active-record-callbacks.html#association-callbacks)

### Расширения связи

Вы не ограничены функциональностью, которую Rails автоматически встраивает в выданные по связи объекты. Можно расширить эти объекты с помощью анонимных модулей, добавив новые методы поиска, методы создания и иные методы. Например:

```ruby
class Author < ApplicationRecord
  has_many :books do
    def find_by_book_prefix(book_number)
      find_by(category_id: book_number[0..2])
    end
  end
end
```

Если имеется расширение, которое должно быть общим для нескольких связей, можно использовать именованный модуль расширения. Например:

```ruby
module FindRecentExtension
  def find_recent
    where("created_at > ?", 5.days.ago)
  end
end

class Author < ApplicationRecord
  has_many :books, -> { extending FindRecentExtension }
end

class Supplier < ApplicationRecord
  has_many :deliveries, -> { extending FindRecentExtension }
end
```

Расширения могут ссылаться на внутренние методы выданных по связи объектов, используя следующие три атрибута акцессора `proxy_association`:

* `proxy_association.owner` возвращает объект, в котором объявлена связь.
* `proxy_association.reflection` возвращает объект reflection, описывающий связь.
* `proxy_association.target` возвращает связанный объект для `belongs_to` или `has_one`, или коллекцию связанных объектов для `has_many` или `has_and_belongs_to_many`.

### Ограничение связи с помощью владельца связи

Владелец связи может быть передан в качестве единственного аргумента в блок скоупа в ситуации, когда вам необходим больший контроль над ограничением связи. Однако, предупреждаем, что предварительная загрузка связи не будет больше работать.

```ruby
class Supplier < ApplicationRecord
  has_one :account, ->(supplier) { where active: supplier.active? }
end
```

(single-table-inheritance-sti) Наследование с единой таблицей (STI)
------------------------------------

Иногда можно делиться полями и поведением между различными моделями. Скажем, у нас есть модели Car, Motorcycle и Bicycle. Мы хотим совместно использовать поля `color` и `price` и некоторые методы всеми из них, но иметь некоторое специфичное поведение для каждого, а также различные контроллеры.

Сначала нужно сгенерировать базовую модель Vehicle:

```bash
$ bin/rails generate model vehicle type:string color:string price:decimal{10.2}
```

Вы заметили, что мы добавили поле "type"? Так как все модели будут сохранены в одну таблицу базы данных, Rails сохранит в этот столбец имя модели, которая сохраняется. В нашем примере это может быть "Car", "Motorcycle" или "Bicycle." STI не работает без поля "type" в таблице.

Затем мы сгенерируем модель Car, унаследованную от Vehicle. Для этого можно использовать опцию `--parent=PARENT`, которая сгенерирует модель, унаследованную от указанного родителя и без эквивалентной миграции (так как таблица уже существует).

Например, чтобы сгенерировать модель Car:

```bash
$ bin/rails generate model car --parent=Vehicle
```

Сгенерированная модель будет выглядеть так:

```ruby
class Car < Vehicle
end
```

Это означает, что все поведение, такое как связи, публичные методы и так далее, добавленное в Vehicle, доступно также для Car.

Создание автомобиля сохранит его в таблице `vehicles` со значением "Car" в поле `type`:

```ruby
Car.create(color: 'Red', price: 10000)
```

сгенерирует следующий SQL:

```sql
INSERT INTO "vehicles" ("type", "color", "price") VALUES ('Car', 'Red', 10000)
```

Запрос записей автомобилей будет искать только среди транспортных средств, которые являются автомобилями:

```ruby
Car.all
```

запустит подобный запрос:

```sql
SELECT "vehicles".* FROM "vehicles" WHERE "vehicles"."type" IN ('Car')
```

Делегированные типы
-------------------

[`Наследование с единой таблицей (STI)`](#single-table-inheritance-sti) хорошо работает, когда между подклассами и их атрибутами небольшая разница, но для включения всех атрибутов всех подклассов нужно создать единую таблицу.

Недостаток такого подхода в том, что он приводит к раздуванию этой таблицы. Поскольку ей нужно включать атрибуты, специфичные только для подкласса, но не используемые где-либо еще.

В следующем примере есть две модели Active Record, наследуемые от одного класса "Entry", включающего атрибут `subject`.

```ruby
# Schema: entries[ id, type, subject, created_at, updated_at]
class Entry < ApplicationRecord
end

class Comment < Entry
end

class Message < Entry
end
```

Делегируемые типы решают эту проблему с помощью `delegated_type`.

Чтобы использовать делегируемые типы, нужно смоделировать данные определенным образом. Требования следующие:

* Имеется суперкласс, хранящий общие атрибуты для всех подклассов в своей таблице.
* Каждый подкласс должен наследоваться от суперкласса и иметь отдельную таблицу для любых дополнительных атрибутов, специфичных для него.

Это устраняет необходимость определять атрибуты в единой таблице, которые непреднамеренно доступны всем подклассам.

Чтобы применить это в вышеприведенном примере, нужно перегенерировать модели. Сначала сгенерируем базовую модель `Entry`, которая будет выступать в роли суперкласса:

```bash
$ bin/rails generate model entry entryable_type:string entryable_id:integer
```

Затем сгенерируем новые модели `Message` и `Comment` для делегации:

```bash
$ bin/rails generate model message subject:string body:string
$ bin/rails generate model comment content:string
```

После запуска генераторов, должны получиться такие модели:

```ruby
# Schema: entries[ id, entryable_type, entryable_id, created_at, updated_at ]
class Entry < ApplicationRecord
end

# Schema: messages[ id, subject, body, created_at, updated_at ]
class Message < ApplicationRecord
end

# Schema: comments[ id, content, created_at, updated_at ]
class Comment < ApplicationRecord
end
```

### Объявляем `delegated_type`

Сначала объявляем `delegated_type` в суперклассе `Entry`.

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ], dependent: :destroy
end
```

Параметр `entryable` указывает поле, используемое для делегации, и включает типы `Message` и `Comment` в качестве делегируемых классов.

У класса `Entry` есть поля `entryable_type` и `entryable_id`. Это поля с добавленными суффиксами `_type`, `_id`, добавленными к имени `entryable` из определения `delegated_type`. `entryable_type` хранит им подкласса делегации, и `entryable_id` хранит id записи подкласса делегации.

Затем нужно определить модуль для реализации этих делегируемых типов, объявляя параметр `as: :entryable` у связи `has_one`.

```ruby
module Entryable
  extend ActiveSupport::Concern

  included do
    has_one :entry, as: :entryable, touch: true
  end
end
```

А затем включить созданный модуль в подкласс.

```ruby
class Message < ApplicationRecord
  include Entryable
end

class Comment < ApplicationRecord
  include Entryable
end
```

По завершение определения, делегатор `Entry` будет предоставлять следующие методы:

| Method                  | Return                                                                          |
|-------------------------|---------------------------------------------------------------------------------|
| `Entry#entryable_class` | Message или Comment                                                             |
| `Entry#entryable_name`  | "message" или "comment"                                                         |
| `Entry.messages`        | `Entry.where(entryable_type: "Message")`                                        |
| `Entry#message?`        | Возвращает true, когда `entryable_type == "Message"`                            |
| `Entry#message`         | Возвращает запись сообщения, когда `entryable_type == "Message"`, иначе `nil`   |
| `Entry#message_id`      | Возвращает `entryable_id`, когда `entryable_type == "Message"`, иначе `nil`     |
| `Entry.comments`        | `Entry.where(entryable_type: "Comment")`                                        |
| `Entry#comment?`        | Возвращает true, когда `entryable_type == "Comment"`                            |
| `Entry#comment`         | Возвращает запись комментария, когда `entryable_type == "Comment"`, иначе `nil` |
| `Entry#comment_id`      | Возвращает `entryable_id`, когда `entryable_type == "Comment"`, иначе `nil`     |

### Создание объекта

При создании нового объекта `Entry` в то же время можно указать подкласс `entryable`.

```ruby
Entry.create! entryable: Message.new(subject: "hello!")
```

### Добавление дальнейшей делегации

Можно расширить делегатор `Entry` и усовершенствовать его, определив `delegate` и используя полиморфизм на подклассах. Например, чтобы делегировать метод `title` из `Entry` в его подклассы:

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ]
  delegate :title, to: :entryable
end

class Message < ApplicationRecord
  include Entryable

  def title
    subject
  end
end

class Comment < ApplicationRecord
  include Entryable

  def title
    content.truncate(20)
  end
end
```
