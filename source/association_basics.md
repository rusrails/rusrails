Связи (ассоциации) Active Record
================================

Это руководство раскрывает особенности связей Active Record.

После его прочтения, вы узнаете:

* Как объявлять связи между моделями Active Record.
* Как понимать различные типы связей Active Record.
* Как использовать методы, добавленные в ваши модели при создании связей.

--------------------------------------------------------------------------------

Зачем нужны связи?
------------------

В Rails _связь_ - это соединение между двумя моделями Active Record. Зачем нам нужны связи между моделями? Затем, что они позволяют сделать код для обычных операций проще и легче. Например, рассмотрим простое приложение на Rails, которое включает модель для авторов и модель для книг. Каждый автор может иметь много книг. Без связей объявление модели будет выглядеть так:

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

Rails поддерживает шесть типов связей:

* `belongs_to`
* `has_one`
* `has_many`
* `has_many :through`
* `has_one :through`
* `has_and_belongs_to_many`

Связи реализуются с использованием макро-вызовов (macro-style calls), и, таким образом, вы можете декларативно добавлять возможности для своих моделей. Например, объявляя, что одна модель принадлежит (`belongs_to`) другой, вы указываете Rails сохранять информацию о [первичном](https://ru.wikipedia.org/wiki/Первичный_ключ)-[внешнем](https://ru.wikipedia.org/wiki/Внешний_ключ) ключах между экземплярами двух моделей, а также получаете несколько полезных методов, добавленных в модель.

После прочтения всего этого руководства, вы научитесь объявлять и использовать различные формы связей. Но сначала следует быстро ознакомиться с ситуациями, когда применим каждый тип связи.

### Связь `belongs_to`

Связь `belongs_to` устанавливает соединение один-к-одному с другой моделью, когда один экземпляр объявляющей модели "принадлежит" одному экземпляру другой модели. Например, если в приложении есть авторы и книги, и одна книга может быть связана только с одним автором, нужно объявить модель book следующим образом:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

![Диаграмма для связи belongs_to](/images/belongs_to.png)

NOTE: связи `belongs_to` _обязаны_ использовать единственное число. Если использовать множественное число в вышеприведенном примере для связи `author` в модели `Book`, вам будет сообщено "uninitialized constant Book::Authors". Это так, потому что Rails автоматически получает имя класса из имени связи. Если в имени связи неправильно использовано число, то получаемый класс также будет неправильного числа.

Соответствующая миграция может выглядеть так:

```ruby
class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author, index: true
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

### Связь `has_one`

Связь `has_one` также устанавливает соединение один-к-одному с другой моделью, но в несколько ином смысле (и с другими последствиями). Эта связь показывает, что каждый экземпляр модели содержит или обладает одним экземпляром другой модели. Например, если каждый поставщик имеет только один аккаунт, можете объявить модель supplier подобно этому:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

![Диаграмма для связи has_one](/images/has_one.png)

Соответствующая миграция может выглядеть так:

```ruby
class CreateSuppliers < ActiveRecord::Migration[5.0]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier, index: true
      t.string :account_number
      t.timestamps
    end
  end
end
```

В зависимости от применения, возможно потребуется создать индекс уникальности и/или ограничение внешнего ключа на указанный столбец таблицы accounts. В этом случае определение столбца может выглядеть так:

```ruby
create_table :accounts do |t|
  t.belongs_to :supplier, index: { unique: true }, foreign_key: true
  # ...
end
```

### Связь `has_many`

Связь `has_many` указывает на соединение один-ко-многим с другой моделью. Эта связь часто бывает на "другой стороне" связи `belongs_to`. Эта связь указывает на то, что каждый экземпляр модели имеет ноль или более экземпляров другой модели. Например, в приложении, содержащем авторов и книги, модель author может быть объявлена следующим образом:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

NOTE: Имя другой модели указывается во множественном числе при объявлении связи `has_many`.

![Диаграмма для связи has_many](/images/has_many.png)

Соответствующая миграция может выглядеть так:

```ruby
class CreateAuthors < ActiveRecord::Migration[5.0]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author, index: true
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

### (the-has-many-through-association) Связь `has_many :through`

Связь `has_many :through` часто используется для настройки соединения многие-ко-многим с другой моделью. Эта связь указывает, что объявляющая модель может соответствовать нулю или более экземплярам другой модели _через_ третью модель. Например, рассмотрим поликлинику, где пациентам (patients) дают направления (appointments) к врачам (physicians). Соответствующие объявления связей будут выглядеть следующим образом:

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

![Диаграмма для связи has_many :through](/images/has_many_through.png)

Соответствующая миграция может выглядеть так:

```ruby
class CreateAppointments < ActiveRecord::Migration[5.0]
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
      t.belongs_to :physician, index: true
      t.belongs_to :patient, index: true
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

Связь `has_one :through` настраивает соединение один-к-одному с другой моделью. Эта связь показывает, что объявляющая модель может быть связана с одним экземпляром другой модели _через_ третью модель. Например, если каждый поставщик имеет один аккаунт, и каждый аккаунт связан с одной историей аккаунта, тогда модели могут выглядеть так:

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

![Диаграмма для связи has_one :through](/images/has_one_through.png)

Соответствующая миграция может выглядеть так:

```ruby
class CreateAccountHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier, index: true
      t.string :account_number
      t.timestamps
    end

    create_table :account_histories do |t|
      t.belongs_to :account, index: true
      t.integer :credit_rating
      t.timestamps
    end
  end
end
```

### Связь `has_and_belongs_to_many`

Связь `has_and_belongs_to_many` создает прямое соединение многие-ко-многим с другой моделью, без промежуточной модели. Например, если ваше приложение включает сборки (assemblies) и детали (parts), где каждый узел имеет много деталей, и каждая деталь встречается во многих сборках, модели можно объявить таким образом:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

![Диаграмма для связи has_and_belongs_to_many](/images/habtm.png)

Соответствующая миграция может выглядеть так:

```ruby
class CreateAssembliesAndParts < ActiveRecord::Migration[5.0]
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
      t.belongs_to :assembly, index: true
      t.belongs_to :part, index: true
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
class CreateSuppliers < ActiveRecord::Migration[5.0]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.integer :supplier_id
      t.string  :account_number
      t.timestamps
    end

    add_index :accounts, :supplier_id
  end
end
```

NOTE: Использование `t.integer :supplier_id` указывает имя внешнего ключа очевидно и явно. В современных версиях Rails можно абстрагироваться от деталей реализации используя `t.references :supplier`.

### Выбор между `has_many :through` и `has_and_belongs_to_many`

Rails предлагает два разных способа объявления отношения многие-ко-многим между моделями. Простейший способ - использовать `has_and_belongs_to_many`, который позволяет создать связь напрямую:

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
class CreatePictures < ActiveRecord::Migration[5.0]
  def change
    create_table :pictures do |t|
      t.string  :name
      t.integer :imageable_id
      t.string  :imageable_type
      t.timestamps
    end

    add_index :pictures, [:imageable_type, :imageable_id]
  end
end
```

Эта миграция может быть упрощена при использовании формы `t.references`:

```ruby
class CreatePictures < ActiveRecord::Migration[5.0]
  def change
    create_table :pictures do |t|
      t.string :name
      t.references :imageable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
```

![Диаграмма для полиморфной связи](/images/polymorphic.png)

### Присоединение к себе

При разработке модели данных иногда находится модель, которая может иметь отношение сама к себе. Например, мы хотим хранить всех работников в одной модели базы данных, но нам нужно отслеживать отношения начальник-подчиненный. Эта ситуация может быть смоделирована с помощью связей, присоединяемых к себе:

```ruby
class Employee < ApplicationRecord
  has_many :subordinates, class_name: "Employee",
                          foreign_key: "manager_id"

  belongs_to :manager, class_name: "Employee"
end
```

С такой настройкой, вы можете получить `@employee.subordinates` и `@employee.manager`.

В миграциях/схеме следует добавить столбец ссылки модели на саму себя.

```ruby
class CreateEmployees < ActiveRecord::Migration[5.0]
  def change
    create_table :employees do |t|
      t.references :manager, index: true
      t.timestamps
    end
  end
end
```

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
author.books                 # получаем книги из базы данных
author.books.size            # используем кэшированную копию книг
author.books.empty?          # используем кэшированную копию книг
```

Но что если вы хотите перезагрузить кэш, так как данные могли быть изменены другой частью приложения? Всего лишь вызовите `reload` на связи:

```ruby
author.books                 # получаем книги из базы данных
author.books.size            # используем кэшированную копию книг
author.books.reload.empty?   # отказываемся от кэшированной копии книг
                             # и снова обращаемся к базе данных
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
class CreateBooks < ActiveRecord::Migration[5.0]
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
class AddAuthorToBooks < ActiveRecord::Migration[5.0]
  def change
    add_reference :books, :author
  end
end
```

Если необходимо [принудительно использовать ссылочную целостность на уровне базы данных](/rails-database-migrations#foreign-keys), добавьте опцию `foreign_key: true` в вышеприведенное объявление 'reference' столбца.

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
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[5.0]
  def change
    create_table :assemblies_parts, id: false do |t|
      t.integer :assembly_id
      t.integer :part_id
    end

    add_index :assemblies_parts, :assembly_id
    add_index :assemblies_parts, :part_id
  end
end
```

Мы передаем `id: false` в `create_table`, так как эта таблица не представляет модель. Это необходимо, чтобы связь работала правильно. Если вы видите странное поведение в связи `has_and_belongs_to_many`, например, искаженные ID моделей, или исключения в связи с конфликтом ID, скорее всего вы забыли убрать первичный ключ.

Также можно использовать метод `create_join_table`

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[5.0]
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

### Двусторонние связи

Для связей нормально работать в двух направлениях, затребовав объявление в двух различных моделях:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
end
```

Active Record попытается автоматически определить, что эти две модели образуют двунаправленную связь, основываясь на имени связи. Таким образом, Active Record загрузит только одну копию объекта `Author`, делая ваше приложение более эффективным и предотвращая несогласованные данные:


```ruby
a = Author.first
b = a.books.first
a.first_name == b.author.first_name # => true
a.first_name = 'David'
a.first_name == b.author.first_name # => true
```

Active Record поддерживает автоматическое определение для большинства связей со стандартными именами. Однако, Active Record не будет автоматически определять двунаправленные связи, содержащие область видимости или любые из следующих опций:

* `:through`
* `:foreign_key`

Например, рассмотрим следующие объявления моделей:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

Active Record больше не будет автоматически распознавать двунаправленную связь:

```ruby
a = Author.first
b = a.books.first
a.first_name == b.writer.first_name # => true
a.first_name = 'David'
a.first_name == b.writer.first_name # => false
```

Active Record представляет опцию `:inverse_of`, таким образом можно явно объявит двунаправленные связи:

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: 'writer'
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

Включив опцию `:inverse_of` в объявлении связи `has_many`, Active Record будет распознавать двунаправленную связь:

```ruby
a = Author.first
b = a.books.first
a.first_name == b.writer.first_name # => true
a.first_name = 'David'
a.first_name == b.writer.first_name # => true
```

Подробная информация по связи `belongs_to`
------------------------------------------

Связь `belongs_to` создает соответствие один-к-одному с другой моделью. В терминах базы данных эта связь сообщает, что этот класс содержит внешний ключ. Если внешний ключ содержит другой класс, вместо этого следует использовать `has_one`.

### Методы, добавляемые `belongs_to`

Когда объявляете связь `belongs_to`, объявляющий класс автоматически получает 6 методов, относящихся к связи:

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`

Во всех четырех методах `association` заменяется символом, переданным как первый аргумент в `belongs_to`. Например, имеем объявление:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

Каждый экземпляр модели `Book` будет иметь эти методы:

```ruby
author
author=
build_author
create_author
create_author!
reload_author
```

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

### (options-for-belongs-to) Опции для `belongs_to`

Хотя Rails использует разумные значения по умолчанию, работающие во многих ситуациях, бывают случаи, когда хочется изменить поведение связи `belongs_to`. Такая настройка легко выполнима с помощью передачи опций и блоков со скоупом при создании связи. Например, эта связь использует две такие опции:

```ruby
class Book < ApplicationRecord
  belongs_to :author, dependent: :destroy,
    counter_cache: true
end
```

Связь `belongs_to` поддерживает эти опции:

* `:autosave`
* `:class_name`
* `:counter_cache`
* `:dependent`
* `:foreign_key`
* `:primary_key`
* `:inverse_of`
* `:polymorphic`
* `:touch`
* `:validate`
* `:optional`

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

#### `:dependent`

Если установить опцию `:dependent` в:

* `:destroy`, когда объект будет уничтожен, `destroy` будет вызван на его связанных объектах.
* `:delete`, когда объект будет уничтожен, все его связанные объекты будут удалены прямо из базы данных без вызова метода `destroy`.

WARNING: Не следует определять эту опцию в связи `belongs_to`, которая соединена со связью `has_many` в другом классе. Это приведет к "битым" связям в записях вашей базы данных.

#### `:foreign_key`

По соглашению Rails предполагает, что столбец, используемый для хранения внешнего ключа в этой модели, имеет имя модели с добавленным суффиксом `_id`. Опция `:foreign_key` позволяет установить имя внешнего ключа явно:

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron",
                        foreign_key: "patron_id"
end
```

TIP: В любом случае, Rails не создаст столбцы внешнего ключа за вас. Вам необходимо явно определить их в своих миграциях.

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

Опция `:inverse_of` определяет имя связи `has_many` или `has_one`, являющейся противоположностью для этой связи.

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

#### `:polymorphic`

Передача `true` для опции `:polymorphic` показывает, что это полиморфная связь. Полиморфные связи подробно рассматривались [ранее](#polymorphic-associations).

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

#### `:optional`

Если установить `:optional` в `true`, тогда наличие связанных объектов не будет валидироваться. По умолчанию установлено в `false`.

### Скоупы для `belongs_to`

Иногда хочется настроить запрос, используемый `belongs_to`. Такая настройка может быть достигнута с помощью блока скоупа. Например:

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true },
                        dependent: :destroy
end
```

Внутри блока скоупа можно использовать любые стандартные [методы запросов](/active-record-query-interface). Далее обсудим следующие из них:

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
class LineItem < ApplicationRecord
  belongs_to :book
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :line_items
end

class Author < ApplicationRecord
  has_many :books
end
```

Если вы часто получаете авторов непосредственно из элементов (`@line_item.book.author`), то можно улучшить эффективность кода, включив авторов в связь между книгой и ее элементами:

```ruby
class LineItem < ApplicationRecord
  belongs_to :book, -> { includes :author }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :line_items
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

Во всех этих методах `association` заменяется на символ, переданный как первый аргумент в `has_one`. Например, имеем объявление:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

Каждый экземпляр модели `Supplier` будет иметь эти методы:

```ruby
account
account=
build_account
create_account
create_account!
reload_account
```

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

Связь `has_one` поддерживает эти опции:

* `:as`
* `:autosave`
* `:class_name`
* `:dependent`
* `:foreign_key`
* `:inverse_of`
* `:primary_key`
* `:source`
* `:source_type`
* `:through`
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
* `:nullify` приведет к тому, что внешний ключ будет установлен `NULL`. Колбэки не выполняются.
* `:restrict_with_exception` приведет к вызову исключения, если есть связанный объект
* `:restrict_with_error` приведет к ошибке, добавляемой к владельцу, если есть связанный объект

Нельзя устанавливать или уставлять опцию `:nullify` для связей, имеющих ограничение `NOT NULL`. Если не установить `dependent` для уничтожения таких связей, вы не сможете изменить связанный объект, так как внешнему ключу изначально связанного объекта будет назначено недопустимое значение `NULL`.

#### `:foreign_key`

По соглашению Rails предполагает, что столбец, используемый для хранения внешнего ключа в этой модели, имеет имя модели с добавленным суффиксом `_id`. Опция `:foreign_key` позволяет установить имя внешнего ключа явно:

```ruby
class Supplier < ApplicationRecord
  has_one :account, foreign_key: "supp_id"
end
```

TIP: В любом случае, Rails не создаст столбцы внешнего ключа за вас. Вам необходимо явно определить их в своих миграциях.

#### `:inverse_of`

Опция `:inverse_of` определяет имя связи `belongs_to`, являющейся обратной для этой связи.

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

#### `:source`

Опция `:source` определяет имя источника связи для связи `has_one :through`.

#### `:source_type`

Опция `:source_type` определяет тип источника связи для связи `has_one :through`, который действует при полиморфной связи.

#### `:through`

Опция `:through` определяет соединительную модель, через которую выполняется запрос. Связи `has_one :through` подробно рассматривались [ранее](#the-has-one-through-association).

#### `:validate`

Если установите опцию `:validate` в `true`, тогда связанные объекты будут проходить валидацию всякий раз, когда вы сохраняете этот объект. По умолчанию она равна `false`: связанные объекты не проходят валидацию, когда этот объект сохраняется.

### Скоупы для `has_one`

Иногда хочется настроить запрос, используемый `has_one`. Такая настройка может быть достигнута с помощью блока скоупа. Например:

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where active: true }
end
```

Внутри блока скоупа можно использовать любые стандартные [методы запросов](/active-record-query-interface). Далее обсудим следующие из них:

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
* `collection<<(object, ...)`
* `collection.delete(object, ...)`
* `collection.destroy(object, ...)`
* `collection=(objects)`
* `collection_singular_ids`
* `collection_singular_ids=(ids)`
* `collection.clear`
* `collection.empty?`
* `collection.size`
* `collection.find(...)`
* `collection.where(...)`
* `collection.exists?(...)`
* `collection.build(attributes = {}, ...)`
* `collection.create(attributes = {})`
* `collection.create!(attributes = {})`
* `collection.reload`

Во всех этих методах `collection` заменяется символом, переданным как первый аргумент в `has_many`, и `collection_singular` заменяется версией в единственном числе этого символа. Например, имеем объявление:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

Каждый экземпляр модели `Author` будет иметь эти методы:

```ruby
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

#### `collection`

Метод `collection` возвращает Relation всех связанных объектов. Если нет связанных объектов, он возвращает пустой Relation.

```ruby
@books = @author.books
```

#### `collection<<(object, ...)`

Метод `collection<<` добавляет один или более объектов в коллекцию, устанавливая их внешние ключи равными первичному ключу вызывающей модели.

```ruby
@author.books << @book1
```

#### `collection.delete(object, ...)`

Метод `collection.delete` убирает один или более объектов из коллекции, установив их внешние ключи в `NULL`.

```ruby
@author.books.delete(@book1)
```

WARNING: Объекты будут в дополнение уничтожены, если связаны с `dependent: :destroy`, и удалены, если они связаны с `dependent: :delete_all`.

#### `collection.destroy(object, ...)`

Метод `collection.destroy` убирает один или более объектов из коллекции, выполняя `destroy` для каждого объекта.

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

Метод `collection.clear` убирает каждый объект из коллекции в соответствии со стратегией, определенной опцией `dependent`. Если опция не указана, он следует стратегии по умолчанию. Стратегия по умолчанию для `has_many :through` это `delete_all`, а для связей `has_many` — установить их внешние ключи в `NULL`.

```ruby
@author.books.clear
```

WARNING: Объекты будут удалены, если они связаны с помощью `dependent: :destroy`, как и с помощью `dependent: :delete_all`.

#### `collection.empty?`

Метод `collection.empty?` возвращает `true`, если коллекция не содержит каких-либо связанных объектов.

```ruby
<% if @author.books.empty? %>
  No Books Found
<% end %>
```

#### `collection.size`

Метод `collection.size` возвращает количество объектов в коллекции.

```ruby
@book_count = @author.books.size
```

#### `collection.find(...)`

Метод `collection.find` ищет объекты в коллекции. Он использует тот же синтаксис и опции, что и [`ActiveRecord::Base.find`](http://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find).

```ruby
@available_book = @author.books.find(1)
```

#### `collection.where(...)`

Метод `collection.where` ищет объекты в коллекции, основываясь на переданных условиях, но объекты загружаются лениво, что означает, что база данных запрашивается только когда происходит доступ к объекту(-там).

```ruby
@available_books = @author.books.where(available: true) # Пока нет запроса
@available_book = @available_books.first # Теперь база данных будет запрошена
```

#### `collection.exists?(...)`

Метод `collection.exists?` проверяет, существует ли в коллекции объект, отвечающий представленным условиям. Он использует тот же синтаксис и опции, что и [`ActiveRecord::Base.exists?`](http://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-exists-3F).

#### `collection.build(attributes = {}, ...)`

Метод `collection.build` возвращает один или массив объектов связанного типа. Объект(ы) будут экземплярами с переданными атрибутами, будет создана ссылка через их внешние ключи, но связанные объекты _не_ будут пока сохранены.

```ruby
@book = @author.books.build(published_at: Time.now,
                                book_number: "A12345")

@books = @author.books.build([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }])
```

#### `collection.create(attributes = {})`

Метод `collection.create` возвращает один или массив новых объектов связанного типа. Объект(ы) будут экземплярами с переданными атрибутами, будет создана ссылка через его внешний ключ, и, если он пройдет валидации, определенные в связанной модели, связанный объект _будет_ сохранен

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

Метод `collection.reload` возвращает Relation всех связанных объектов, принудительно читая базу данных. Если нет связанных объектов, он возвращает пустой Relation.

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

Связь `has_many` поддерживает эти опции:

* `:as`
* `:autosave`
* `:class_name`
* `:counter_cache`
* `:dependent`
* `:foreign_key`
* `:inverse_of`
* `:primary_key`
* `:source`
* `:source_type`
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
* `:nullify` приведет к тому, что внешние ключи будет установлен `NULL`. Колбэки не выполняются.
* `:restrict_with_exception` приведет к вызову исключения, если есть какой-нибудь связанный объект
* `:restrict_with_error` приведет к ошибке, добавляемой к владельцу, если есть какой-нибудь связанный объект

#### `:foreign_key`

По соглашению Rails предполагает, что столбец, используемый для хранения внешнего ключа в этой модели, имеет имя модели с добавленным суффиксом `_id`. Опция `:foreign_key` позволяет установить имя внешнего ключа явно:

```ruby
class Author < ActiveRecord::Base
  has_many :books, foreign_key: "cust_id"
end
```

TIP: В любом случае, Rails не создаст столбцы внешнего ключа за вас. Вам необходимо явно определить их в своих миграциях.

#### `:inverse_of`

Опция `:inverse_of` определяет имя связи `belongs_to`, являющейся обратной для этой связи.

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

#### `:source`

Опция `:source` определяет имя источника связи для связи `has_many :through`. Эту опцию нужно использовать, только если имя источника связи не может быть автоматически выведено из имени связи.

#### `:source_type`

Опция `:source_type` определяет тип источника связи для связи `has_many :through`, который действует при полиморфной связи.

#### `:through`

Опция `:through` определяет соединительную модель, через которую выполняется запрос. Связи `has_many :through` предоставляют способ осуществления отношений многие-ко-многим, как обсуждалось [ранее в этом руководстве](#the-has-many-through-association).

#### `:validate`

Если установите опцию `:validate` в `false`, тогда связанные объекты не будут проходить валидацию всякий раз, когда вы сохраняете этот объект. По умолчанию она равна `true`: связанные объекты проходят валидацию, когда этот объект сохраняется.

### Скоупы для `has_many`

Иногда хочется настроить запрос, используемый `has_many`. Такая настройка может быть достигнута с помощью блока скоупа. Например:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { where processed: true }
end
```

Внутри блока скоупа можно использовать любые стандартные [методы запросов](/active-record-query-interface). Далее обсудим следующие из них:

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
  has_many :line_items, -> { group 'books.id' },
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
  has_many :line_items
end

class LineItem < ApplicationRecord
  belongs_to :book
end
```

Если вы часто получаете элементы прямо из авторов (`@author.books.line_items`), тогда можете сделать свой код более эффективным, включив элементы в связь от авторов к книгам:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { includes :line_items }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :line_items
end

class LineItem < ApplicationRecord
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

article   = Article.create(name: 'a1')
person.articles << article
person.articles << article
person.articles.inspect # => [#<Article id: 5, name: "a1">, #<Article id: 5, name: "a1">]
Reading.all.inspect     # => [#<Reading id: 12, person_id: 5, article_id: 5>, #<Reading id: 13, person_id: 5, article_id: 5>]
```

В вышеописанной задаче два reading, и `person.articles` выявляет их оба, даже если эти записи указывают на одну и ту же статью.

Давайте установим `distinct`:

```ruby
class Person
  has_many :readings
  has_many :articles, -> { distinct }, through: :readings
end

person = Person.create(name: 'Honda')
article   = Article.create(name: 'a1')
person.articles << article
person.articles << article
person.articles.inspect # => [#<Article id: 7, name: "a1">]
Reading.all.inspect     # => [#<Reading id: 16, person_id: 7, article_id: 7>, #<Reading id: 17, person_id: 7, article_id: 7>]
```

В вышеописанной задаче все еще два reading. Однако `person.articles` показывает только одну статью, поскольку коллекция загружает только уникальные записи.

Если вы хотите быть уверенными, что после вставки все записи персистентной связи различны (и, таким образом, убедиться, что при просмотре связи никогда не будет дублирующихся записей), следует добавить уникальный индекс для самой таблицы. Например, если таблица называется `readings`, и вы хотите убедиться, что все публикации могут быть добавлены к персоне один раз, следует добавить в миграцию:

```ruby
add_index :readings, [:person_id, :article_id], unique: true
```

Как только у вас появится этот индекс уникальности, попытка добавить статью к персоне дважды вызовет ошибку `ActiveRecord::RecordNotUnique`:

```ruby
person = Person.create(name: 'Honda')
article = Article.create(name: 'a1')
person.articles << article
person.articles << article # => ActiveRecord::RecordNotUnique
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

Когда объявляете связь `has_and_belongs_to_many`, объявляющий класс автоматически получает 17 методов, относящихся к связи:

* `collection`
* `collection<<(object, ...)`
* `collection.delete(object, ...)`
* `collection.destroy(object, ...)`
* `collection=(objects)`
* `collection_singular_ids`
* `collection_singular_ids=(ids)`
* `collection.clear`
* `collection.empty?`
* `collection.size`
* `collection.find(...)`
* `collection.where(...)`
* `collection.exists?(...)`
* `collection.build(attributes = {})`
* `collection.create(attributes = {})`
* `collection.create!(attributes = {})`
* `collection.reload`

Во всех этих методах `collection` заменяется символом, переданным как первый аргумент в `has_and_belongs_to_many`, а `collection_singular` заменяется версией в единственном числе этого символа. Например, имеем объявление:

```ruby
class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

Каждый экземпляр модели `Part` будет иметь следующие методы:

```ruby
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

Метод `collection<<` добавляет один или более объектов в коллекцию, создавая записи в соединительной таблице.

```ruby
@part.assemblies << @assembly1
```

NOTE: Этот метод - просто псевдоним к `collection.concat` и `collection.push`.

#### `collection.delete(object, ...)`

Метод `collection.delete` убирает один или более объектов из коллекции, удаляя записи в соединительной таблице. Это не уничтожает объекты.

```ruby
@part.assemblies.delete(@assembly1)
```

#### `collection.destroy(object, ...)`

Метод `collection.destroy` убирает один или более объектов из коллекции, удаляя записи в соединительной таблице. Это не уничтожает объекты.

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

Метод `collection.clear` убирает каждый объект из коллекции, удаляя строки из соединительной таблицы. Это не уничтожает связанные объекты.

#### `collection.empty?`

Метод `collection.empty?` возвращает `true`, если коллекция не содержит каких-либо связанных объектов.

```ruby
<% if @part.assemblies.empty? %>
  This part is not used in any assemblies
<% end %>
```

#### `collection.size`

Метод `collection.size` возвращает количество объектов в коллекции.

```ruby
@assembly_count = @part.assemblies.size
```

#### `collection.find(...)`

Метод `collection.find` ищет объекты в коллекции. Он использует тот же синтаксис и опции, что и [`ActiveRecord::Base.find`](http://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find). А также добавляет дополнительное условие, что объект должен быть в коллекции.

```ruby
@assembly = @part.assemblies.find(1)
```

#### `collection.where(...)`

Метод `collection.where` ищет объекты в коллекции, основываясь на переданных условиях, но объекты загружаются лениво, что означает, что база данных запрашивается только когда происходит доступ к объекту(-там).

```ruby
@new_assemblies = @part.assemblies.where("created_at > ?", 2.days.ago)
```

#### `collection.exists?(...)`

Метод `collection.exists?` проверяет, существует ли в коллекции объект, отвечающий представленным условиям. Он использует тот же синтаксис и опции, что и [`ActiveRecord::Base.exists?`](http://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-exists-3F).

#### `collection.build(attributes = {})`

Метод `collection.build` возвращает один или более объектов связанного типа. Эти объекты будут экземплярами с переданными атрибутами, и будет создана связь через соединительную таблицу, но связанный объект пока _не_ будет сохранен.

```ruby
@assembly = @part.assemblies.build({assembly_name: "Transmission housing"})
```

#### `collection.create(attributes = {})`

Метод `collection.create` возвращает один или более объектов связанного типа. Эти объекты будут экземплярами с переданными атрибутами, будет создана связь через соединительную таблицу, и, если он пройдет валидации, определенные в связанной модели, связанный объект _будет_ сохранен.

```ruby
@assembly = @part.assemblies.create({assembly_name: "Transmission housing"})
```

#### `collection.create!(attributes = {})`

Работает так же, как вышеприведенный `collection.create`, но вызывает `ActiveRecord::RecordInvalid`, если запись невалидна.

#### `collection.reload`

Метод `collection.reload` возвращает Relation всех связанных объектов, принудительно читая базу данных. Если нет связанных объектов, он возвращает пустой Relation.

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

Связь `has_and_belongs_to_many` поддерживает эти опции:

* `:association_foreign_key`
* `:autosave`
* `:class_name`
* `:foreign_key`
* `:join_table`
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

#### `:validate`

Если установите опцию `:validate` в `false`, тогда связанные объекты не будут проходить валидацию всякий раз, когда вы сохраняете этот объект. По умолчанию она равна `true`: связанные объекты проходят валидацию, когда этот объект сохраняется.

### Скоупы для `has_and_belongs_to_many`

Иногда хочется настроить запрос, используемый `has_many`. Такая настройка может быть достигнута с помощью блока скоупа. Например:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { where active: true }
end
```

Внутри блока скоупа можно использовать любые стандартные [методы запросов](/active-record-query-interface). Далее обсудим следующие из них:

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

При использовании опции `where` хэшем, при создание записи через эту связь будет автоматически применен скоуп с использованием хэша. В этом случае при использовании `@parts.assemblies.create` или `@parts.assemblies.build` будут созданы заказы, в которых столбец `factory` будет иметь значение `Seattle`.

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
    ...
  end
end
```

Rails передает добавляемый или удаляемый объект в колбэк.

Можете помещать колбэки в очередь на отдельное событие, передав их как массив:

```ruby
class Author < ApplicationRecord
  has_many :books,
    before_add: [:check_credit_limit, :calculate_shipping_charges]

  def check_credit_limit(book)
    ...
  end

  def calculate_shipping_charges(book)
    ...
  end
end
```

Если колбэк `before_add` вызывает исключение, объект не будет добавлен в коллекцию. Подобным образом, если колбэк `before_remove` вызывает исключение, объект не убирается из коллекции.

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

Наследование с единой таблицей (STI)
------------------------------------

Иногда можно делиться полями и поведением между различными моделями. Скажем, у нас есть модели Car, Motorcycle и Bicycle. Мы хотим совместно использовать поля `color` и `price` и некоторые методы всеми из них, но иметь некоторое специфичное поведение для каждого, а также различные контроллеры.

Rails позволяет сделать это достаточно просто. Сначала нужно сгенерировать базовую модель Vehicle:

```bash
$ rails generate model vehicle type:string color:string price:decimal{10.2}
```

Вы заметили, что мы добавили поле "type"? Так как все модели будут сохранены в одну таблицу базы данных, Rails сохранит в этот столбец имя модели, которая сохраняется. В нашем примере это может быть "Car", "Motorcycle" или "Bicycle." STI не работает без поля "type" в таблице.

Затем мы сгенерируем три модели, унаследованные от Vehicle. Для этого можно использовать опцию `--parent=PARENT`, которая сгенерирует модель, унаследованную от указанного родителя и без эквивалентной миграции (так как таблица уже существует).

Например, чтобы сгенерировать модель Car:

```bash
$ rails generate model car --parent=Vehicle
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

Запрос записей автомобилей будет просто искать среди транспортных средств, которые являются автомобилями:

```ruby
Car.all
```

запустит подобный запрос:

```sql
SELECT "vehicles".* FROM "vehicles" WHERE "vehicles"."type" IN ('Car')
```
