Интерфейс запросов Active Record
================================

Это руководство раскрывает различные способы получения данных из базы данных, используя Active Record.

После его прочтения, вы узнаете:

* Как искать записи, используя различные методы и условия.
* Как определять порядок, получаемые атрибуты, группировку и другие свойства поиска записей.
* Как использовать нетерпеливую загрузку (eager loading) для уменьшения числа запросов к базе данных, необходимых для получения данных.
* Как использовать методы динамического поиска.
* Как использовать цепочки методов (method chaining), для использования нескольких методов Active Record одновременно.
* Как проверять существование отдельных записей.
* Как выполнять различные вычисления в моделях Active Record.
* Как запускать EXPLAIN на relations.

Что такое интерфейс запросов Active Record?
------------------------------------------

Если вы использовали чистый SQL для поиска записей в базе данных, то скорее всего обнаружите, что в Rails есть лучшие способы выполнения тех же операций. Active Record ограждает вас от необходимости использования SQL во многих случаях.

Active Record выполнит запросы в базу данных за вас, он совместим с большинством СУБД, включая MySQL, MariaDB, PostgreSQL и SQLite. Независимо от того, какая используется СУБД, формат методов Active Record будет всегда одинаковый.

Примеры кода далее в этом руководстве будут относиться к некоторым из этих моделей:

TIP: Все модели используют `id` как первичный ключ, если не указано иное.

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order(year_published: :desc) }
end
```

```ruby
class Book < ApplicationRecord
  belongs_to :supplier
  belongs_to :author
  has_many :reviews
  has_and_belongs_to_many :orders, join_table: 'books_orders'

  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }
  scope :old, -> { where('year_published < ?', 50.years.ago )}
  scope :out_of_print_and_expensive, -> { out_of_print.where('price > 500') }
  scope :costs_more_than, ->(amount) { where('price > ?', amount) }
end
```

```ruby
class Customer < ApplicationRecord
  has_many :orders
  has_many :reviews
end
```

```ruby
class Order < ApplicationRecord
  belongs_to :customer
  has_and_belongs_to_many :books, join_table: 'books_orders'

  enum status: [:shipped, :being_packed, :complete, :cancelled]

  scope :created_before, ->(time) { where('created_at < ?', time) }
end
```

```ruby
class Review < ApplicationRecord
  belongs_to :customer
  belongs_to :book

  enum state: [:not_reviewed, :published, :hidden]
end
```

```ruby
class Supplier < ApplicationRecord
  has_many :books
  has_many :authors, through: :books
end
```

![Диаграмма всех моделей книжного магазина](images/active_record_querying/bookstore_models.png)

Получение объектов из базы данных
---------------------------------

Для получения объектов из базы данных Active Record предоставляет несколько методов поиска. В каждый метод поиска можно передавать аргументы для выполнения определенных запросов в базу данных без необходимости писать на чистом SQL.

Методы следующие:

* `annotate`
* `find`
* `create_with`
* `distinct`
* `eager_load`
* `extending`
* `extract_associated`
* `from`
* `group`
* `having`
* `includes`
* `joins`
* `left_outer_joins`
* `limit`
* `lock`
* `none`
* `offset`
* `optimizer_hints`
* `order`
* `preload`
* `readonly`
* `references`
* `reorder`
* `reselect`
* `reverse_order`
* `select`
* `where`

Методы поиска, возвращающие коллекцию, такие как `where` и `group`, возвращают экземпляр `ActiveRecord::Relation`. Методы, ищущие отдельную сущность, такие как `find` и `first`, возвращают отдельный экземпляр модели.

Вкратце основные операции `Model.find(options)` таковы:

* Преобразовать предоставленные опции в эквивалентный запрос SQL.
* Выполнить запрос SQL и получить соответствующие результаты из базы данных.
* Создать экземпляр эквивалентного объекта Ruby подходящей модели для каждой строки результата запроса.
* Запустить колбэки `after_find` и далее `after_initialize`, если таковые имеются.

### Получение одиночного объекта

Active Record предоставляет несколько различных способов получения одиночного объекта.

#### `find`

Используя метод `find`, можно получить объект, соответствующий определенному первичному ключу (_primary key_) и предоставленным опциям. Например:

```ruby
# Ищет покупателя с первичным ключом (id) 10.
customer = Customer.find(10)
# => #<Customer id: 10, first_name: "Ryan">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM customers WHERE (customers.id = 10) LIMIT 1
```

Метод `find` вызывает исключение `ActiveRecord::RecordNotFound`, если соответствующей записи не было найдено.

Этот метод также можно использовать для получения нескольких объектов. Вызовите метод `find` и передайте в него массив первичных ключей. Возвращенным результатом будет массив, содержащий все записи, соответствующие представленным _первичным ключам_. Например:

```ruby
# Найдем покупателей с первичными ключами 1 и 10.
customers = Customer.find([1, 10]) # Or even Customer.find(1, 10)
# => [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 10, first_name: "Ryan">]
```

SQL эквивалент этого такой:

```sql
SELECT * FROM customers WHERE (customers.id IN (1,10))
```

#### `take`

Метод `take` получает запись без какого-либо явного упорядочивания. Например:

```ruby
customer = Customer.take
# => #<Customer id: 1, first_name: "Lifo">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM customers LIMIT 1
```

Метод `take` возвращает `nil`, если ни одной записи не найдено, и исключение не будет вызвано.

В метод `take` можно передать числовой аргумент, чтобы вернуть это количество результатов. Например

```ruby
customers = Customer.take(2)
# => [
#   #<Customer id: 1, first_name: "Lifo">,
#   #<Customer id: 220, first_name: "Sara">
# ]
```

SQL эквивалент этого такой:

```sql
SELECT * FROM customers LIMIT 2
```

Метод `take!` ведет себя подобно `take`, за исключением того, что он вызовет `ActiveRecord::RecordNotFound`, если не найдено ни одной соответствующей записи.

TIP: Получаемая запись может отличаться в зависимости от подсистемы хранения СУБД.

#### `first`

Метод `first` находит первую запись, упорядоченную по первичному ключу (по умолчанию). Например:

```ruby
customer = Customer.first
# => #<Customer id: 1, first_name: "Lifo">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM customers ORDER BY customers.id ASC LIMIT 1
```

Метод `first` возвращает `nil`, если не найдено соответствующей записи, и исключение не вызывается.

Если [скоуп по умолчанию](#applying-a-default-scope) содержит метод order, `first` возвратит первую запись в соответствии с этим упорядочиванием.

В метод `first` можно передать числовой аргумент, чтобы вернуть это количество результатов. Например

```ruby
customers = Customer.first(3)
# => [
#   #<Customer id: 1, first_name: "Lifo">,
#   #<Customer id: 2, first_name: "Fifo">,
#   #<Customer id: 3, first_name: "Filo">
# ]
```

SQL эквивалент этого такой:

```sql
SELECT * FROM customers ORDER BY customers.id ASC LIMIT 3
```

На коллекции, упорядоченной с помощью `order`, `first` вернет первую запись, упорядоченную по указанному в `order` атрибуту.

```ruby
customer = Customer.order(:first_name).first
# => #<Customer id: 2, first_name: "Fifo">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM customers ORDER BY customers.first_name ASC LIMIT 1
```

Метод `first!` ведет себя подобно `first`, за исключением того, что он вызовет `ActiveRecord::RecordNotFound`, если не найдено ни одной соответствующей записи.

#### `last`

Метод `last` находит последнюю запись, упорядоченную по первичному ключу (по умолчанию). Например:

```ruby
customer = Customer.last
# => #<Customer id: 221, first_name: "Russel">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM customers ORDER BY customers.id DESC LIMIT 1
```

Метод `last` возвращает `nil`, если не найдено соответствующей записи, и исключение не вызывается.

Если [скоуп по умолчанию](#applying-a-default-scope) содержит метод order, `last` возвратит последнюю запись в соответствии с этим упорядочиванием.

В метод `last` можно передать числовой аргумент, чтобы вернуть это количество результатов. Например

```ruby
customers = Customer.last(3)
# => [
#   #<Customer id: 219, first_name: "James">,
#   #<Customer id: 220, first_name: "Sara">,
#   #<Customer id: 221, first_name: "Russel">
# ]
```

SQL эквивалент этого такой:

```sql
SELECT * FROM customers ORDER BY customers.id DESC LIMIT 3
```

На коллекции, упорядоченной с помощью `order`, `last` вернет последнюю запись, упорядоченную по указанному в `order` атрибуту.

```ruby
customer = Customer.order(:first_name).last
# => #<Customer id: 220, first_name: "Sara">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM customers ORDER BY customers.first_name DESC LIMIT 1
```

Метод `last!` ведет себя подобно `last`, за исключением того, что он вызовет `ActiveRecord::RecordNotFound`, если не найдено ни одной соответствующей записи.

#### `find_by`

Метод `find_by` ищет первую запись, соответствующую некоторым условиям. Например:

```ruby
Customer.find_by first_name: 'Lifo'
# => #<Customer id: 1, first_name: "Lifo">

Customer.find_by first_name: 'Jon'
# => nil
```

Это эквивалент записи:

```ruby
Customer.where(first_name: 'Lifo').take
```

SQL эквивалент выражения выше, следующий:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Lifo') LIMIT 1
```

Метод `find_by!` ведет себя подобно `find_by`, за исключением того, что он вызовет `ActiveRecord::RecordNotFound`, если не найдено ни одной соответствующей записи. Например:

```ruby
Customer.find_by! first_name: 'does not exist'
# => ActiveRecord::RecordNotFound
```

Это эквивалент записи:

```ruby
Customer.where(first_name: 'does not exist').take!
```

### Получение нескольких объектов пакетами

Часто необходимо перебрать огромный набор записей, например, когда рассылаем письма всем покупателям или импортируем некоторые данные.

Это может показаться простым:

```ruby
# Это может потребить слишком много памяти, если таблица большая.
Customer.all.each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

Но этот подход становится очень непрактичным с увеличением размера таблицы, поскольку `Customer.all.each` говорит Active Record извлечь _таблицу полностью_ за один проход, создать объект модели для каждой строки и держать этот массив в памяти. В реальности, если имеется огромное количество записей, полная коллекция может превысить количество доступной памяти.

Rails предоставляет два метода, которые решают эту проблему путем разделения записей на дружелюбные к памяти пакеты для обработки. Первый метод, `find_each`, получает пакет записей и затем вкладывает _каждую_ запись в блок отдельно как модель. Второй метод, `find_in_batches`, получает пакет записей и затем вкладывает _весь пакет_ в блок как массив моделей.

TIP: Методы `find_each` и `find_in_batches` предназначены для пакетной обработки большого числа записей, которые не поместятся в памяти за раз. Если нужно просто перебрать тысячу записей, более предпочтителен вариант обычных методов поиска.

#### `find_each`

Метод `find_each` получает пакет записей и затем передает _каждую_ запись в блок. В следующем примере `find_each` получает покупателей пакетами по 1000 записей, а затем передает их в блок один за другим:

```ruby
Customer.find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

Этот процесс повторяется, извлекая больше пакетов при необходимости, пока не будут обработаны все записи.

`find_each` работает на классах модели, как показано выше, а также на relation:

```ruby
Customer.where(weekly_subscriber: true).find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

только у них нет упорядочивания, так как методу необходимо собственное упорядочивание для работы.

Если у получателя есть упорядочивание, то поведение зависит от флажка `config.active_record.error_on_ignored_order`. Если true, вызывается `ArgumentError`, в противном случае упорядочивание игнорируется, что является поведением по умолчанию. Это можно переопределить с помощью опции `:error_on_ignore`, описанной ниже.

##### Опции для `find_each`

**`:batch_size`**

Опция `:batch_size` позволяет определить число записей, подлежащих получению в одном пакете, до передачи отдельной записи в блок. Например, для получения 5000 записей в пакете:

```ruby
Customer.find_each(batch_size: 5000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

**`:start`**

По умолчанию записи извлекаются в порядке увеличения первичного ключа. Опция `:start` позволяет вам настроить первый ID последовательности, когда наименьший ID не тот, что вам нужен. Это может быть полезно, например, если хотите возобновить прерванный процесс пакетирования, предоставив последний обработанный ID как контрольную точку.

Например, чтобы выслать письма только покупателям с первичным ключом, начинающимся от 2000:

```ruby
Customer.find_each(start: 2000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

**`:finish`**

Подобно опции `:start`, `:finish` позволяет указать последний ID последовательности, когда наибольший ID не тот, что вам нужен.
Это может быть полезно, например, если хотите запустить процесс пакетирования, используя подмножество записей на основании `:start` и `:finish`

Например, чтобы выслать письма только покупателям с первичным ключом от 2000 до 10000:

```ruby
Customer.find_each(start: 2000, finish: 10000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

Другим примером является наличие нескольких воркеров, работающих с одной и той же очередью обработки. Можно было бы обрабатывать каждым воркером 10000 записей, установив подходящие опции `:start` и `:finish` в каждом воркере.

**`:error_on_ignore`**

Переопределяет настройку приложения, указывающую, должна ли быть вызвана ошибка, если в relation присутствует упорядочивание.

#### `find_in_batches`

Метод `find_in_batches` похож на `find_each` тем, что они оба получают пакеты записей. Различие в том, что `find_in_batches` передает в блок _пакеты_ как массив моделей, вместо отдельной модели. Следующий пример передаст в представленный блок массив из 1000 счетов за раз, а в последний блок содержащий всех оставшихся покупателей:

```ruby
# Передает в add_customers массив из 1000 покупателей за раз.
Customer.find_in_batches do |customers|
  export.add_customers(customers)
end
```

`find_in_batches` работает на классах модели, как показано выше, а также на relation:

```ruby
# Передает в add_customers массив из 1000 недавно активных покупателей за раз.
Customer.recently_active.find_in_batches do |customers|
  export.add_customers(customers)
end
```

только у них нет упорядочивания, так как методу необходимо собственное упорядочивание для работы.

##### Опции для `find_in_batches`

Метод `find_in_batches` принимает те же опции, что и `find_each`:

**`:batch_size`**

Как и для `find_each`, `batch_size` устанавливает, сколько записей будет извлечено в каждой группе. Например, получение пакетов по 2500 записей может быть определено как:

```ruby
Customer.find_in_batches(batch_size: 2500) do |customers|
  export.add_customers(customers)
end
```

**`:start`**

Опция `:start` позволяет вам указать начальный ID, начиная с которого будут выбраны записи. Как уже упоминалось, по умолчанию записи извлекаются по возрастанию первичного ключа. Например, чтобы получить покупателей начиная с ID: 5000 пакетами по 2500 записей, можно использовать следующий код:

```ruby
Customer.find_in_batches(batch_size: 2500, start: 5000) do |customers|
  export.add_customers(customers)
end
```

**`:finish`**

Опция `finish` позволяет указать последний ID записей для извлечения. Нижеследующий код показывает случай извлечения покупателей пакетами до покупателя с ID: 7000:

```ruby
Customer.find_in_batches(finish: 7000) do |customers|
  export.add_customers(customers)
end
```

**`:error_on_ignore`**

Опция `error_on_ignore` переопределяет настройку приложения, указывающую, должна ли быть вызвана ошибка, если в relation присутствует упорядочивание.

Условия
-------

Метод `where` позволяет определить условия для ограничения возвращаемых записей, которые представляют `WHERE`-часть выражения SQL. Условия могут быть заданы как строка, массив или хэш.

### (pure-string-conditions) Чисто строковые условия

Если вы хотите добавить условия в свой поиск, можете просто определить их там, подобно `Book.where("title = 'Introduction to Algorithms'")`. Это найдет все книги, где значение поля `title` равно 'Introduction to Algorithms'.

WARNING: Создание условий в чистой строке подвергает вас риску SQL-инъекций. Например, `Book.where("title LIKE '%#{params[:title]}%'")` не безопасно. Смотрите следующий раздел для более предпочтительного способа обработки условий с использованием массива.

### (array-conditions) Условия с использованием массива

Что если заголовок может быть задан, скажем, как аргумент откуда-то извне? Поиск тогда принимает такую форму:

```ruby
Book.where("title = ?", params[:title])
```

Active Record примет первый аргумент в качестве строки условия, а все остальные элементы подставит вместо знаков вопроса `(?)` в ней.

Если хотите определить несколько условий:

```ruby
Book.where("title = ? AND out_of_print = ?", params[:title], false)
```

В этом примере первый знак вопроса будет заменен на значение в `params[:title]` и второй будет заменен SQL аналогом `false`, который зависит от адаптера.

Этот код значительно предпочтительнее:

```ruby
Book.where("title = ?", params[:title])
```

чем такой код:

```ruby
Book.where("title = #{params[:title]}")
```

по причине безопасности аргумента. Помещение переменной прямо в строку условий передает переменную в базу данных _как есть_. Это означает, что неэкранированная переменная, переданная пользователем, может иметь злой умысел. Если так сделать, вы подвергаете базу данных риску, так как если пользователь обнаружит, что он может использовать вашу базу данных, то он сможет сделать с ней что угодно. Никогда не помещайте аргументы прямо в строку условий!

TIP: Подробнее об опасности SQL-инъекций можно узнать из руководства [Безопасность приложений на Rails](/ruby-on-rails-security-guide).

#### Местозаполнители в условиях

Подобно тому, как `(?)` заменяют параметры, можно использовать ключи в условиях совместно с соответствующим хэшем ключей/значений:

```ruby
Book.where("created_at >= :start_date AND created_at <= :end_date",
  {start_date: params[:start_date], end_date: params[:end_date]})
```

Читаемость улучшится, в случае если вы используете большое количество переменных в условиях.

### (hash-conditions) Условия с использованием хэша

Active Record также позволяет передавать условия в хэше, что улучшает читаемость синтаксиса условий. В этом случае передается хэш с ключами, соответствующими полям, которые хотите уточнить, и с значениями, которые вы хотите к ним применить:

NOTE: Хэшем можно передать условия проверки только равенства, интервала и подмножества.

#### Условия равенства

```ruby
Book.where(out_of_print: true)
```

Это сгенерирует такой SQL:

```sql
SELECT * FROM books WHERE (books.out_of_print = 1)
```

Имя поля также может быть строкой, а не символом:

```ruby
Book.where('out_of_print' => true)
```

В случае отношений belongs_to, может быть использован ключ связи для указания модели, если как значение используется объект Active Record. Этот метод также работает с полиморфными отношениями.

```ruby
author = Author.first
Book.where(author: author)
Author.joins(:books).where(books: { author: author })
```

#### Интервальные условия

```ruby
Book.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight)
```

Это найдет все книги, созданные вчера, с использованием SQL выражения `BETWEEN`:

```sql
SELECT * FROM books WHERE (books.created_at BETWEEN '2008-12-21 00:00:00' AND '2008-12-22 00:00:00')
```

Это была демонстрация более короткого синтаксиса для примеров в [Условия с использованием массива](#array-conditions)

#### Условия подмножества

Если хотите найти записи, используя выражение `IN`, можете передать массив в хэш условий:

```ruby
Customer.where(orders_count: [1,3,5])
```

Этот код сгенерирует подобный SQL:

```sql
SELECT * FROM customers WHERE (customers.orders_count IN (1,3,5))
```

### Условия NOT

Запросы `NOT` в SQL могут быть созданы с помощью `where.not`:

```ruby
Customer.where.not(orders_count: [1,3,5])
```

Другими словами, этот запрос может быть сгенерирован с помощью вызова `where` без аргументов и далее присоединенным `not` с переданными условиями для `where`. Это сгенерирует такой SQL:

```sql
SELECT * FROM customers WHERE (customers.orders_count NOT IN (1,3,5))
```

### Условия OR

Условия `OR` между двумя отношениями могут быть построены путем вызова `or` на первом отношении и передачи второго в качестве аргумента.

```ruby
Customer.where(last_name: 'Smith').or(Customer.where(orders_count: [1,3,5]))
```

```sql
SELECT * FROM customers WHERE (customers.last_name = 'Smith' OR customers.orders_count IN (1,3,5))
```

(ordering) Сортировка
---------------------

Чтобы получить записи из базы данных в определенном порядке, можете использовать метод `order`.

Например, если вы получаете ряд записей и хотите упорядочить их в порядке возрастания поля `created_at` в таблице:

```ruby
Customer.order(:created_at)
# ИЛИ
Customer.order("created_at")
```

Также можете определить `ASC` или `DESC`:

```ruby
Customer.order(created_at: :desc)
# ИЛИ
Customer.order(created_at: :asc)
# ИЛИ
Customer.order("created_at DESC")
# ИЛИ
Customer.order("created_at ASC")
```

Или сортировку по нескольким полям:

```ruby
Customer.order(orders_count: :asc, created_at: :desc)
# ИЛИ
Customer.order(:orders_count, created_at: :desc)
# ИЛИ
Customer.order("orders_count ASC, created_at DESC")
# ИЛИ
Customer.order("orders_count ASC", "created_at DESC")
```

Если хотите вызвать `order` несколько раз, последующие сортировки будут добавлены к первой:

```ruby
Customer.order("orders_count ASC").order("created_at DESC")
# SELECT * FROM customers ORDER BY orders_count ASC, created_at DESC
```

WARNING: В большинстве СУБД при выборе полей с помощью `distinct` из результирующей выборки используя методы, такие как `select`, `pluck` и `ids`; метод `order` вызовет исключение `ActiveRecord::StatementInvalid`, если поля, используемые в выражении `order`, не включены в список выбора. Смотрите следующий раздел по выбору полей из результирующей выборки.

Выбор определенных полей
------------------------

По умолчанию `Model.find` выбирает все множество полей результата, используя `select *`.

Чтобы выбрать подмножество полей из всего множества, можете определить его, используя метод `select`.

Например, чтобы выбрать только столбцы `isbn` и `out_of_print`:

```ruby
Book.select(:isbn, :out_of_print)
# ИЛИ
Book.select("isbn, out_of_print")
```

Используемый для этого запрос SQL будет иметь подобный вид:

```sql
SELECT isbn, out_of_print FROM books
```

Будьте осторожны, поскольку это также означает, что будет инициализирован объект модели только с теми полями, которые вы выбрали. Если вы попытаетесь обратиться к полям, которых нет в инициализированной записи, то получите:

```
ActiveModel::MissingAttributeError: missing attribute: <attribute>
```

Где `<attribute>` это атрибут, который был запрошен. Метод `id` не вызывает `ActiveRecord::MissingAttributeError`, поэтому будьте аккуратны при работе со связями, так как они нуждаются в методе `id` для правильной работы.

Если хотите вытащить только по одной записи для каждого уникального значения в определенном поле, можно использовать `distinct`:

```ruby
Customer.select(:last_name).distinct
```

Это сгенерирует такой SQL:

```sql
SELECT DISTINCT last_name FROM customers
```

Также можно убрать ограничение уникальности:

```ruby
query = Customer.select(:last_name).distinct
# => Возвратит уникальные last_name

query.distinct(false)
# => Возвратит все last_name, даже если есть дубликаты
```

Ограничение и смещение
----------------------

Чтобы применить `LIMIT` к SQL, запущенному с помощью `Model.find`, нужно определить `LIMIT`, используя методы `limit` и `offset` на relation.

Используйте `limit` для определения количества записей, которые будут получены, и `offset` - для числа записей, которые будут пропущены до начала возврата записей. Например:

```ruby
Customer.limit(5)
```

возвратит максимум 5 покупателей, и, поскольку не определено смещение, будут возвращены первые 5 в таблице. Выполняемый SQL будет выглядеть подобным образом:

```sql
SELECT * FROM customers LIMIT 5
```

Добавление `offset` к этому

```ruby
Customer.limit(5).offset(30)
```

Возвратит максимум 5 покупателей, начиная с 31-го. SQL выглядит так:

```sql
SELECT * FROM customers LIMIT 5 OFFSET 30
```

Группировка
-----------

Чтобы применить условие `GROUP BY` к `SQL`, можно использовать метод `group`.

Например, если хотите найти коллекцию дат, в которые были созданы заказы:

```ruby
Order.select("created_at").group("created_at")
```

Это выдаст вам отдельный объект `Order` на каждую дату, для которой были заказы в базе данных.

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT created_at
FROM orders
GROUP BY created_at
```

### Общее количество сгруппированных элементов

Чтобы получить общее количество сгруппированных элементов одним запросом, вызовите `count` после `group`.

```ruby
Order.group(:status).count
# => { 'being_packed' => 7, 'shipped' => 12 }
```

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT COUNT (*) AS count_all, status AS status
FROM orders
GROUP BY status
```

Having
------

SQL использует условие `HAVING` для определения условий для полей, указанных в `GROUP BY`. Условие `HAVING`, определенное в SQL, запускается в `Model.find` с использованием метода `having` для поиска.

Например:

```ruby
Order.select("created_at, sum(total) as total_price").
  group("created_at").having("sum(total) > ?", 200)
```

SQL, который будет выполнен, выглядит так:

```sql
SELECT created_at as ordered_date, sum(total) as total_price
FROM orders
GROUP BY created_at
HAVING sum(total) > 200
```

Это возвращает дату и итоговую цену для каждого объекта заказа, сгруппированные по дню, когда они были заказаны, и где цена больше $200.

Получить `total_price` каждого возвращенного объекта заказа можно так:

```ruby
big_orders = Order.select("created_at, sum(total) as total_price")
                  .group("created_at")
                  .having("sum(total) > ?", 200)

big_orders[0].total_price
# Возвращает итоговую цену первого объекта Order
```

Переопределяющие условия
------------------------

### `unscope`

Можете указать определенные условия, которые будут убраны, используя метод `unscope`. Например:

```ruby
Book.where('id > 100').limit(20).order('id desc').unscope(:order)
```

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT * FROM books WHERE id > 100 LIMIT 20

# Оригинальный запрос без `unscope`
SELECT * FROM books WHERE id > 100 ORDER BY id desc LIMIT 20

```

Также можно убрать определенные условия `where`. Например, это уберет условие для `id` из условия where:

```ruby
Book.where(id: 10, out_of_print: false).unscope(where: :id)
# SELECT books.* FROM books WHERE out_of_print = 0
```

Relation, использующий `unscope` повлияет на любой relation, в который он слит:

```ruby
Book.order('id desc').merge(Book.unscope(:order))
# SELECT books.* FROM books
```

### `only`

Также можно переопределить условия, используя метод `only`. Например:

```ruby
Book.where('id > 10').limit(20).order('id desc').only(:order, :where)
```

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT * FROM books WHERE id > 10 ORDER BY id DESC

# Оригинальный запрос без `only`
SELECT * FROM books WHERE id > 10 ORDER BY id DESC LIMIT 20

```

### `reselect`

Метод `reselect` переопределяет существующее выражение select. Например:

```ruby
Book.select(:title, :isbn).reselect(:created_at)
```

SQL, который будет выполнен:

```sql
SELECT `books`.`created_at` FROM `books`
```

Сравните это со случаем, когда не было использовано выражение `reselect`:

```ruby
Book.select(:title, :isbn).select(:created_at)
```

SQL, который будет выполнен:

```sql
SELECT `books`.`title`, `books`.`isbn`, `books`.`created_at` FROM `books`
```

### `reorder`

Метод `reorder` переопределяет сортировку скоупа по умолчанию. Например, если определение класса включает это:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order(year_published: :desc) }
end
```

И вы выполняете это:

```ruby
Author.find(10).books
```

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT * FROM authors WHERE id = 10 LIMIT 1
SELECT * FROM books WHERE author_id = 10 ORDER BY year_published DESC
```

Можно использовать выражение `reorder` для указания иного способа упорядочивания книг:

```ruby
Author.find(10).books.reorder('year_published ASC')
```

SQL, который будет выполнен:

```sql
SELECT * FROM authors WHERE id = 10 LIMIT 1
SELECT * FROM books WHERE author_id = 10 ORDER BY year_published ASC
```

### `reverse_order`

Метод `reverse_order` меняет направление условия сортировки, если оно определено:

```ruby
Customer.where("orders_count > 10").order(:last_name).reverse_order
```

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT * FROM customers WHERE orders_count > 10 ORDER BY last_name DESC
```

Если условие сортировки не было определено в запросе, `reverse_order` сортирует по первичному ключу в обратном порядке:

```ruby
Customer.where("orders_count > 10").reverse_order
```

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT * FROM customers WHERE orders_count > 10 ORDER BY customers.id DESC
```

Метод `reverse_order` не принимает аргументы.

### `rewhere`

Метод `rewhere` переопределяет существующее именованное условие `where`. Например:

```ruby
Book.where(out_of_print: true).rewhere(out_of_print: false)
```

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT * FROM books WHERE `out_of_print` = 0
```

В случае, когда не используется условие `rewhere`, условия where соединяются с помощью AND

```ruby
Book.where(out_of_print: true).where(out_of_print: false)
```

выполненный SQL будет следующий:

```sql
SELECT * FROM books WHERE `out_of_print` = 1 AND `out_of_print` = 0
```

Нулевой Relation
----------------

Метод `none` возвращает сцепляемый relation без записей. Любые последующие условия, сцепленные с возвращенным relation, продолжат генерировать пустые relation. Это полезно в случаях, когда необходим сцепляемый отклик на метод или скоуп, который может вернуть пустые результаты.

```ruby
Order.none # возвращает пустой Relation и не вызывает запросов.
```

```ruby
# От метода highlighted_reviews ожидается, что он вернет Relation.
Book.first.highlighted_reviews.average(:rating)
# => Возвращает средний рейтинг книги

class Book
  # Возвращает рецензии, когда их как минимум 5,
  # иначе рассматривает эту книгу как не рецензированную
  def highlighted_reviews
    if reviews.count > 5
      reviews
    else
      Review.none # Пока не удовлетворяет минимальному порогу
    end
  end
end
```

Объекты только для чтения
-------------------------

Active Record предоставляет relation метод `readonly` для явного запрета на модификацию любого из возвращаемых объектов. Любая попытка изменить запись, доступную только для чтения, не удастся, вызвав исключение `ActiveRecord::ReadOnlyRecord`.

```ruby
customer = Customer.readonly.first
customer.visits += 1
customer.save
```

Так как `customer` явно указан как объект доступный только для чтения, выполнение вышеуказанного кода выдаст исключение `ActiveRecord::ReadOnlyRecord` при вызове `customer.save` с обновленным значением `visits`.

Блокировка записей для обновления
---------------------------------

Блокировка полезна для предотвращения состояния гонки при обновлении записей в базе данных и обеспечения атомарного обновления.

Active Record предоставляет два механизма блокировки:

* Оптимистическая блокировка
* Пессимистическая блокировка

### Оптимистическая блокировка

Оптимистическая блокировка позволяет нескольким пользователям обращаться к одной и той же записи для редактирования и предполагает минимум конфликтов с данными. Она осуществляет это с помощью проверки, внес ли другой процесс изменения в записи, с тех пор как она была открыта. Если это происходит, вызывается исключение `ActiveRecord::StaleObjectError`, и обновление игнорируется.

**Столбец оптимистической блокировки**

Чтобы начать использовать оптимистическую блокировку, таблица должна иметь столбец, называющийся `lock_version`, с типом integer. Каждый раз, когда запись обновляется, Active Record увеличивает значение `lock_version`, и средства блокирования обеспечивают, что для записи, вызванной дважды, та, которая первая успеет, будет сохранена, а для второй будет вызвано исключение `ActiveRecord::StaleObjectError`.

Например:

```ruby
c1 = Customer.find(1)
c2 = Customer.find(1)

c1.first_name = "Sandra"
c1.save

c2.first_name = "Michael"
c2.save # вызывает исключение ActiveRecord::StaleObjectError
```

Вы ответственны за разрешение конфликта с помощью обработки исключения и либо отката, либо объединения, либо применения бизнес-логики, необходимой для разрешения конфликта.

Это поведение может быть отключено, если установить `ActiveRecord::Base.lock_optimistically = false`.

Для переопределения имени столбца `lock_version`, `ActiveRecord::Base` предоставляет атрибут класса `locking_column`:

```ruby
class Customer < ApplicationRecord
  self.locking_column = :lock_customer_column
end
```

### Пессимистическая блокировка

Пессимистическая блокировка использует механизм блокировки, предоставленный лежащей в основе базой данных. Использование `lock` при построении relation применяет эксклюзивную блокировку для выбранных строк. Relations, которые используют `lock`, обычно упакованы внутри transaction для предотвращения условий взаимной блокировки (дедлока).

Например:

```ruby
Book.transaction do
  book = Book.lock.first
  book.title = 'Algorithms, second edition'
  book.save!
end
```

Вышеописанная сессия осуществляет следующие SQL для бэкенда MySQL:

```sql
SQL (0.2ms)   BEGIN
Book Load (0.3ms)   SELECT * FROM `books` LIMIT 1 FOR UPDATE
Book Update (0.4ms)   UPDATE `books` SET `updated_at` = '2009-02-07 18:05:56', `title` = 'Algorithms, second edition' WHERE `id` = 1
SQL (0.8ms)   COMMIT
```

Также можно передать чистый SQL в опцию `lock` для разрешения различных типов блокировок. Например, в MySQL есть выражение, называющееся `LOCK IN SHARE MODE`, которым можно заблокировать запись, но все же разрешить другим запросам читать ее. Чтобы указать это выражения, просто передайте его как опцию блокировки:

```ruby
Book.transaction do
  book = Book.lock("LOCK IN SHARE MODE").find(1)
  book.increment!(:views)
end
```

NOTE:  Отметьте, что ваша база данных должна поддерживать SQL, который вы передаете в метод `lock`.

Если у вас уже имеется экземпляр модели, можно одновременно начать транзакцию и затребовать блокировку, используя следующий код:

```ruby
book = Book.first
book.with_lock do
  # Этот блок вызывается в транзакции,
  # книга уже заблокирован.
  book.increment!(:views)
end
```

(joining-tables) Соединительные таблицы
---------------------------------------

Active Record предоставляет два метода поиска для определения условия `JOIN` в результирующем SQL: `joins` и `left_outer_joins`. В то время, как `joins` следует использовать для `INNER JOIN` или пользовательских запросов, `left_outer_joins` используется для запросов с помощью `LEFT OUTER JOIN`.

### `joins`

Существует несколько способов использования метода `joins`.

#### Использование строкового фрагмента SQL

Можно просто передать чистый SQL, определяющий условие `JOIN` в `joins`.

```ruby
Author.joins("INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE")
```

Это приведет к следующему SQL:

```sql
SELECT authors.* FROM authors INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE
```

#### Использование массива/хэша именованных связей

Active Record позволяет использовать имена [связей](/active-record-associations), определенных в модели, как ярлыки для определения условия `JOIN` этих связей при использовании метода `joins`.

Все нижеследующее создаст ожидаемые соединительные запросы с использованием `INNER JOIN`:

##### Соединение одиночной связи

```ruby
Book.joins(:reviews)
```

Это создаст:

```sql
SELECT books.* FROM books
  INNER JOIN reviews ON reviews.book_id = books.id
```

Или, по-русски, "возвратить объект Book для всех книг с рецензиями". Обратите внимание, что будут дублирующиеся книги, если у книги больше одной рецензии. Если нужны уникальные книги, можно использовать `Book.joins(:reviews).distinct`.

#### Соединение нескольких связей

```ruby
Book.joins(:author, :reviews)
```

Это создаст:

```sql
SELECT books.* FROM books
  INNER JOIN authors ON authors.id = books.author_id
  INNER JOIN reviews ON reviews.book_id = books.id
```

Или, по-русски, "возвратить все книги, у которых есть автор и как минимум одна рецензия". Снова отметьте, что книги с несколькими рецензиями будут показаны несколько раз.

##### Соединение вложенных связей (одного уровня)

```ruby
Book.joins(reviews: :customer)
```

Это создаст:

```sql
SELECT books.* FROM books
  INNER JOIN reviews ON reviews.book_id = book.id
  INNER JOIN customer ON customers.id = reviews.id
```

Или, по-русски, "возвратить все книги, у которых есть рецензия покупателя".

##### Соединение вложенных связей (разных уровней)

```ruby
Author.joins(books: [{reviews: { customer: :orders} }, :supplier] )
```

Это создаст:

```sql
SELECT * FROM authors
  INNER JOIN books ON books.author_id = authors.id
  INNER JOIN reviews ON reviews.book_id = books.id
  INNER JOIN customers ON customers.id = reviews.customer_id
  INNER JOIN orders ON orders.customer_id = customers.id
INNER JOIN suppliers ON suppliers.id = books.supplier_id
```

Или, по-русски: "возвратить всех авторов, у которых есть книги с рецензиями покупателей, делавших заказы, а также поставщики для этих книг".

#### Определение условий в соединительных таблицах

В соединительных таблицах можно определить условия, используя обычные [массивные](/active-record-query-interface#array-conditions) и [строковые](/active-record-query-interface#pure-string-conditions) условия. [Условия с использованием хэша](/active-record-query-interface#hash-conditions) предоставляют специальный синтаксис для определения условий в соединительных таблицах:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where('orders.created_at' => time_range)
```

Это найдет всех покупателей, сделавших вчера заказы, используя выражение SQL `BETWEEN` для сравнения `created_at`.

Альтернативный и более чистый синтаксис для этого - вложенные хэш-условия:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where(orders: { created_at: time_range })
```

Это найдет всех покупателей, сделавших вчера заказы, снова используя выражение SQL `BETWEEN`.

### `left_outer_joins`

Если хотите выбрать ряд записей, независимо от того, имеют ли они связанные записи, можно использовать метод `left_outer_joins`.

```ruby
Customer.left_outer_joins(:reviews).distinct.select('customers.*, COUNT(reviews.*) AS reviews_count').group('customers.id')
```

Который создаст:

```sql
SELECT DISTINCT customers.*, COUNT(reviews.*) AS reviews_count FROM customers
LEFT OUTER JOIN reviews ON reviews.customer_id = customers.id GROUP BY customers.id
```

Что означает: "возвратить всех покупателей и количество их рецензий, независимо от того, имеются ли у них вообще рецензии".

Нетерпеливая загрузка связей
----------------------------

Нетерпеливая загрузка - это механизм загрузки связанных записей объекта, возвращаемых `Model.find`, с использованием как можно меньшего количества запросов.

**Проблема N + 1 запроса**

Рассмотрим следующий код, который находит 10 книг и выводит фамилии их авторов:

```ruby
books = Book.limit(10)

books.each do |book|
  puts book.author.last_name
end
```

На первый взгляд выглядит хорошо. Но проблема лежит в общем количестве выполненных запросов. Вышеупомянутый код выполняет 1 (чтобы найти 10 книг) + 10 (каждый на одну книгу для загрузки автора) = итого **11** запросов.

**Решение проблемы N + 1 запроса**

Active Record позволяет заранее указать все связи, которые должны быть загружены. Это возможно с помощью указания метода `includes` на вызове `Model.find`. Посредством `includes`, Active Record обеспечивает то, что все указанные связи загружаются с использованием минимально возможного количества запросов.

Пересмотрев вышеупомянутую задачу, можно переписать `Book.limit(10)`, чтобы нетерпеливо загрузить авторов:

```ruby
books = Book.includes(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

Этот код выполнит всего **2** запроса, вместо **11** запросов из прошлого примера:

```sql
SELECT * FROM books LIMIT 10
SELECT authors.* FROM authors
  WHERE (authors.id IN (1,2,3,4,5,6,7,8,9,10))
```

### Нетерпеливая загрузка нескольких связей

Active Record позволяет нетерпеливо загружать любое количество связей в одном вызове `Model.find` с использованием массива, хэша или вложенного хэша массивов/хэшей с помощью метода `includes`.

#### Массив нескольких связей

```ruby
Customer.includes(:orders, :reviews)
```

Это загрузит всех покупателей и связанные заказы и рецензии для каждого.

#### Вложенный хэш связей

```ruby
Customer.includes(orders: {books: [:supplier, :author]}).find(1)
```

Вышеприведенный код находит покупателя с id 1 и нетерпеливо загружает все связанные заказы для него, книги для всех заказов, и автора и поставщика каждой книги.

### Определение условий для нетерпеливой загрузки связей

Хотя Active Record и позволяет определить условия для нетерпеливой загрузки связей точно так же, как и в `joins`, рекомендуем использовать вместо этого [joins](#joining-tables).

Однако, если сделать так, то можно использовать `where` как обычно.

```ruby
Author.includes(:books).where(books: { out_of_print: true })
```

Это сгенерирует запрос с ограничением `LEFT OUTER JOIN`, в то время как метод `joins` сгенерировал бы его с использованием функции `INNER JOIN`.

```ruby
  SELECT authors.id AS t0_r0, ... books.updated_at AS t1_r5 FROM authors LEFT OUTER JOIN "books" ON "books"."author_id" = "authors"."id" WHERE (books.out_of_print = 1)
```

Если бы не было условия `where`, то сгенерировался бы обычный набор из двух запросов.

NOTE: Использование `where` подобным образом будет работать только, если передавать в него хэш. Для фрагментов SQL необходимо использовать `references` для принуждения соединения таблиц:

```ruby
Author.includes(:books).where("books.out_of_print = true").references(:books)
```

Если, в случае с этим запросом `includes`, не будет ни одной книги ни для одного автора, все авторы все равно будут загружены. При использовании `joins` (INNER JOIN), соединительные условия **должны** соответствовать, иначе ни одной записи не будет возвращено.

NOTE: Если связь нетерпеливо загружена как часть join, любые поля из произвольного выражения select не будут присутствовать в загруженных моделях. Это так, потому что это избыточность, которая должна появиться или в родительской модели, или в дочерней.

(scopes) Скоупы
---------------

Скоупы позволяют задавать часто используемые запросы, к которым можно обращаться как к вызовам метода в связанных объектах или моделях. С помощью этих скоупов можно использовать каждый ранее раскрытый метод, такой как `where`, `joins` и `includes`. Все методы скоупов возвращают объект `ActiveRecord::Relation` или `nil`, что позволяет вызывать на них дополнительные методы (такие как другие скоупы).

Для определения простого скоупа мы используем метод `scope` внутри класса, передав запрос, который хотим запустить при вызове этого скоупа:

```ruby
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
end
```

Для вызова скоупа `out_of_print`, можно вызвать его либо на классе:

```ruby
Book.out_of_print # => [все распроданные книги]
```

Либо на связи, состоящей из объектов `Book`:

```ruby
author = Author.first
author.books.out_of_print # => [все распроданные книги этого автора]
```

Скоупы также сцепляются с другими скоупами:

```ruby
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
  scope :out_of_print_and_expensive, -> { out_of_print.where("price > 500") }
end
```

### Передача аргумента

Скоуп может принимать аргументы:

```ruby
class Book < ApplicationRecord
  scope :costs_more_than, ->(amount) { where("price > ?", amount) }
end
```

Вызывайте скоуп, как будто это метод класса:

```ruby
Book.costs_more_than(100.10)
```

Однако, это всего лишь дублирование функциональности, которая должна быть предоставлена методом класса.

```ruby
class Book < ApplicationRecord
  def self.costs_more_than(amount)
    where("price > ?", amount)
  end
end
```

Эти методы также будут доступны на связанных объектах:

```ruby
author.books.costs_more_than(100.10)
```

### Использование условий

Ваши скоупы могут использовать условия:

```ruby
class Order < ApplicationRecord
  scope :created_before, ->(time) { where("created_at < ?", time) if time.present? }
end
```

Подобно остальным примерам, это ведет себя подобно методу класса.

```ruby
class Order < ApplicationRecord
  def self.created_before(time)
    where("created_at < ?", time) if time.present?
  end
end
```

Однако, имеется одно важное предостережение: скоуп всегда должен возвращать объект `ActiveRecord::Relation`, даже если условие вычисляется `false`, в отличие от метода класса, возвращающего `nil`. Это может вызвать `NoMethodError` при сцеплении методов класса с условиями, если одно из условий вернет `false`.

### (applying-a-default-scope) Применение скоупа по умолчанию

Если хотите, чтобы скоуп был применен ко всем запросам модели, можно использовать метод `default_scope` в самой модели.

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }
end
```

Когда запросы для этой модели будут выполняться, запрос SQL теперь будет выглядеть примерно так:

```sql
SELECT * FROM books WHERE (out_of_print = false)
```

Если необходимо сделать более сложные вещи со скоупом по умолчанию, альтернативно его можно определить как метод класса:

```ruby
class Book < ApplicationRecord
  def self.default_scope
    # Должен возвращать ActiveRecord::Relation.
  end
end
```

NOTE: `default_scope` также применяется при создании записи, когда аргументы скоупа передаются как `Hash`. Он не применяется при обновлении записи. То есть:

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }
end

Book.new          # => #<Book id: nil, out_of_print: false>
Book.unscoped.new # => #<Book id: nil, out_of_print: nil>
```

Имейте в виду, что когда передаются в формате `Array`, аргументы запроса `default_scope` не могут быть преобразованы в `Hash` для назначения атрибутов по умолчанию. То есть:

```ruby
class Book < ApplicationRecord
  default_scope { where("out_of_print = ?", false) }
end

Book.new # => #<Book id: nil, out_of_print: nil>
```

### Объединение скоупов

Подобно условиям `where`, скоупы объединяются с использованием `AND`.

```ruby
class Book < ApplicationRecord
  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }

  scope :recent, -> { where('year_published >= ?', Date.current.year - 50 )}
  scope :old, -> { where('year_published < ?', Date.current.year - 50 )}
end

Book.out_of_print.old
# SELECT books.* FROM books WHERE books.out_of_print = 'true' AND books.year_published < 1969
```

Можно комбинировать условия `scope` и `where`, и результирующий SQL будет содержать все условия, соединенные с помощью `AND`.

```ruby
Book.in_print.where('price < 100')
# SELECT books.* FROM books WHERE books.out_of_print = 'false' AND books.price < 100
```

Если необходимо, чтобы сработало только последнее условие `where`, тогда можно использовать `Relation#merge`.

```ruby
Book.in_print.merge(Book.out_of_print)
# SELECT books.* FROM books WHERE books.out_of_print = true
```

Важным предостережением является то, что `default_scope` переопределяется условиями `scope` и `where`.

```ruby
class Book < ApplicationRecord
  default_scope { where('year_published >= ?', Date.current.year - 50 )}

  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }
end

Book.all
# SELECT books.* FROM books WHERE (year_published >= 1969)

Book.in_print
# SELECT books.* FROM books WHERE (year_published >= 1969) AND books.out_of_print = true

Book.where('price > 50')
# SELECT books.* FROM books WHERE (year_published >= 1969) AND (price > 50)
```

Как видите, `default_scope` объединяется как со `scope`, так и с `where` условиями.

### Удаление всех скоупов

Если хотите удалить скоупы по какой-то причине, можете использовать метод `unscoped`. Это особенно полезно, если в модели определен `default_scope`, и он не должен быть применен для конкретно этого запроса.

```ruby
Book.unscoped.load
```

Этот метод удаляет все скоупы и выполняет обычный запрос к таблице.

```ruby
Book.unscoped.all
# SELECT books.* FROM books

Book.where(out_of_print: true).unscoped.all
# SELECT books.* FROM books
```

`unscoped` также может принимать блок:

```ruby
Book.unscoped {
  Book.out_of_print
}
# SELECT books.* FROM books WHERE books.out_of_print
```

(dynamic-finders) Динамический поиск
------------------------------------

Для каждого поля (также называемого атрибутом), определенного в вашей таблице, Active Record предоставляет метод поиска. Например, если есть поле `first_name` в вашей модели `Customer`, вы автоматически получаете `find_by_first_name` от Active Record. Если также есть поле `locked` в модели `Customer`, вы также получаете `find_by_locked` метод.

Можете определить восклицательный знак (`!`) в конце динамического поиска, чтобы он вызвал ошибку `ActiveRecord::RecordNotFound`, если не возвратит ни одной записи, например так `Customer.find_by_name!("Ryan")`

Если хотите искать и по `name`, и по `orders_count`, можете сцепить эти поиски вместе, просто написав "`and`" между полями, например, `Customer.find_by_first_name_and_orders_count("Ryan", 5)`.

Перечисление
------------

`enum` позволяет определить массив значений для атрибута, и ссылаться на них по имени. Фактическим значением, хранимым в базе данных, будет целое число, соответствующее одному из значений.

Объявление перечисления:

* Создаст скоупы, которые можно использовать для поиска всех объектов имеющих или не имеющих одно из значений перечисления
* Создаст метод экземпляра, который можно использовать для определения, имеет ли объект определенное значение для перечисления
* Создаст метод экземпляра, который можно использовать для изменения значения перечисления у объекта

для каждого возможного значения `enum`.

Например, дано это определение example `enum`:

```ruby
class Order < ApplicationRecord
  enum status: [:shipped, :being_packaged, :complete, :cancelled]
end
```

Эти [скоупы](#scopes) будут автоматически созданы, и их можно использовать, чтобы найти все объекты с или без определенного значения для `status`.

```ruby
Order.shipped
# находит все заказы со status == :shipped
Order.not_shipped
# находит все заказы со status != :shipped
...
```

Эти методы экземпляра создаются автоматически и запрашивают, имеет ли модель это значение для перечисления `status`:

```ruby
order = Order.first
order.shipped?
# Возвращает true если status == :shipped
order.complete?
# Возвращает true если status == :complete
...
```

Эти методы экземпляра создаются автоматически, и сначала обновляют значение `status` на названное значение, а затем запрашивают, был ли успешно установлен статус:

```ruby
order = Order.first
order.shipped!
# =>  UPDATE "orders" SET "status" = ?, "updated_at" = ? WHERE "orders"."id" = ?  [["status", 0], ["updated_at", "2019-01-24 07:13:08.524320"], ["id", 1]]
# => true
...
```

Полную документацию об enum можно найти в [документации Rails API](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html).

(Method Chaining) Цепочки методов
---------------------------------

В Active Record есть полезный приём программирования [Method Chaining](https://en.wikipedia.org/wiki/Method_chaining), который позволяет нам комбинировать множество Active Record методов.

Можно сцепить несколько методов в единое выражение, если предыдущий вызываемый метод возвращает `ActiveRecord::Relation`, такие как `all`, `where` и `joins`. Методы, которые возвращают одиночный объект (смотрите раздел [Получение одиночного объекта](#poluchenie-odinochnogo-ob-ekta)) должны вызываться в конце.

Ниже представлены несколько примеров. Это руководство не покрывает все возможности, а только некоторые, для ознакомления. Когда вызывается Active Record метод, запрос не сразу генерируется и отправляется в базу. Запрос посылается только тогда, когда данные реально необходимы. Таким образом, каждый пример ниже генерирует только один запрос.

### Получение отфильтрованных данных из нескольких таблиц

```ruby
Customer
  .select('customers.id, customers.last_name, reviews.body')
  .joins(:reviews)
  .where('reviews.created_at > ?', 1.week.ago)
```

Результат должен быть примерно следующим:

```sql
SELECT customers.id, customers.last_name, reviews.body
FROM customers
INNER JOIN reviews
  ON reviews.customer_id = customers.id
WHERE (reviews.created_at > '2019-01-08')
```

### Получение определённых данных из нескольких таблиц

```ruby
Book.select('books.id, books.title, authors.first_name')
  .joins(:author)
  .find_by(title: 'Abstraction and Specification in Program Development')
```

Выражение выше, сгенерирует следующий SQL-запрос:

```sql
SELECT books.id, books.title, authors.first_name
FROM books
INNER JOIN authors
 ON authors.id = books.author_id
WHERE books.title = $1 [["title", "Abstraction and Specification in Program Development"]]
```

NOTE: Обратите внимание, что если запросу соответствует несколько записей, `find_by` вернет только первую запись и проигнорирует остальные (смотрите `LIMIT 1` выше).

Поиск или создание нового объекта
---------------------------------

Часто бывает, что вам нужно найти запись или создать ее, если она не существует. Вы можете сделать это с помощью методов `find_or_create_by` и `find_or_create_by!`.

### `find_or_create_by`

Метод `find_or_create_by` проверяет, существует ли запись с определенными атрибутами. Если нет, то вызывается `create`. Давайте рассмотрим пример.

Предположим, вы хотите найти покупателя по имени 'Andy', и, если такого нет, создать его. Это можно сделать, выполнив:

```ruby
Customer.find_or_create_by(first_name: 'Andy')
# => #Customer id: 5, first_name: "Andy", last_name: nil, title: nil, visits: 0, orders_count: nil, lock_version: 0, created_at: "2019-01-17 07:06:45", updated_at: "2019-01-17 07:06:45"
```

SQL, генерируемый этим методом, будет выглядеть так:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Andy') LIMIT 1
BEGIN
INSERT INTO customers (created_at, first_name, locked, orders_count, updated_at) VALUES ('2011-08-30 05:22:57', 'Andy', 1, NULL, '2011-08-30 05:22:57')
COMMIT
```

`find_or_create_by` возвращает либо уже существующую запись, либо новую запись. В нашем случае, у нас еще нет покупателя с именем Andy, поэтому запись будет создана и возвращена.

Новая запись может быть не сохранена в базу данных; это зависит от того, прошли валидации или нет (подобно `create`).

Предположим, мы хотим установить атрибут 'locked' как `false`, если создаем новую запись, но не хотим включать его в запрос. Таким образом, мы хотим найти покупателя по имени "Andy" или, если этот покупатель не существует, создать покупателя по имени "Andy", который не заблокирован.

Этого можно достичь двумя способами. Первый - это использование `create_with`:

```ruby
Customer.create_with(locked: false).find_or_create_by(first_name: 'Andy')
```

Второй способ - это использование блока:

```ruby
Customer.find_or_create_by(first_name: 'Andy') do |c|
  c.locked = false
end
```

Блок будет выполнен, только если покупателя был создан. Во второй раз, при запуске этого кода, блок будет проигнорирован.

### `find_or_create_by!`

Можно также использовать `find_or_create_by!`, чтобы вызвать исключение, если новая запись невалидна. Валидации не раскрываются в этом руководстве, но давайте на момент предположим, что вы временно добавили

```ruby
validates :orders_count, presence: true
```

в модель `Customer`. Если попытаетесь создать нового `Customer` без передачи `orders_count`, запись будет невалидной и будет вызвано исключение:

```ruby
Customer.find_or_create_by!(first_name: 'Andy')
# => ActiveRecord::RecordInvalid: Validation failed: Orders count can't be blank
```

### `find_or_initialize_by`

Метод `find_or_initialize_by` работает похоже на `find_or_create_by`, но он вызывает не `create`, а `new`. Это означает, что новый экземпляр модели будет создан в памяти, но не будет сохранен в базу данных. Продолжая пример с `find_or_create_by`, теперь нам нужен покупатель по имени 'Nina':

```ruby
nina = Customer.find_or_initialize_by(first_name: 'Nina')
# => #<Customer id: nil, first_name: "Nina", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">

nina.persisted?
# => false

nina.new_record?
# => true
```

Поскольку объект еще не сохранен в базу данных, сгенерированный SQL выглядит так:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Nina') LIMIT 1
```

Когда захотите сохранить его в базу данных, просто вызовите `save`:

```ruby
nina.save
# => true
```

Поиск с помощью SQL
-------------------

Если вы предпочитаете использовать собственные запросы SQL для поиска записей в таблице, можете использовать `find_by_sql`. Метод `find_by_sql` возвратит массив объектов, даже если лежащий в основе запрос вернет всего лишь одну запись. Например, можете запустить такой запрос:

```ruby
Customer.find_by_sql("SELECT * FROM customers
  INNER JOIN orders ON customers.id = orders.customer_id
  ORDER BY customers.created_at desc")
# =>  [
#   #<Customer id: 1, first_name: "Lucas" ...>,
#   #<Customer id: 2, first_name: "Jan" ...>,
#   ...
# ]
```

`find_by_sql` предоставляет простой способ создания произвольных запросов к базе данных и получения экземпляров объектов.

### `select_all`

У `find_by_sql` есть близкий родственник, называемый `connection#select_all`. `select_all` получит объекты из базы данных, используя произвольный SQL, как и в `find_by_sql`, но не создаст их экземпляры. Этот метод вернет экземпляр класса `ActiveRecord::Result` и вызвав `to_a` на этом объекте вернет массив хэшей, где каждый хэш указывает на запись.

```ruby
Customer.connection.select_all("SELECT first_name, created_at FROM customers WHERE id = '1'").to_hash
# => [
#   {"first_name"=>"Rafael", "created_at"=>"2012-11-10 23:23:45.281189"},
#   {"first_name"=>"Eileen", "created_at"=>"2013-12-09 11:22:35.221282"}
# ]
```

### `pluck`

`pluck` может быть использован для запроса с одним или несколькими столбцами из таблицы, лежащей в основе модели. Он принимает список имен столбцов как аргумент и возвращает массив значений определенных столбцов соответствующего типа данных.

```ruby
Book.where(out_of_print: true).pluck(:id)
# SELECT id FROM books WHERE out_of_print = false
# => [1, 2, 3]

Order.distinct.pluck(:status)
# SELECT DISTINCT status FROM orders
# => ['shipped', 'being_packed', 'cancelled']

Customer.pluck(:id, :first_name)
# SELECT customers.id, customers.name FROM customers
# => [[1, 'David'], [2, 'Fran'], [3, 'Jose']]
```

`pluck` позволяет заменить такой код:

```ruby
Customer.select(:id).map { |c| c.id }
# или
Customer.select(:id).map(&:id)
# или
Customer.select(:id, :name).map { |c| [c.id, c.first_name] }
```

на:

```ruby
Customer.pluck(:id)
# или
Customer.pluck(:id, :first_name)
```

В отличие от `select`, `pluck` непосредственно конвертирует результат запроса в массив Ruby, без создания объектов `ActiveRecord`. Это может означать лучшую производительность для больших или часто используемых запросов. Однако, любые переопределения методов в модели будут недоступны. Например:

```ruby
class Customer < ApplicationRecord
  def name
    "I am #{first_name}"
  end
end

Customer.select(:first_name).map &:name
# => ["I am David", "I am Jeremy", "I am Jose"]

Customer.pluck(:first_name)
# => ["David", "Jeremy", "Jose"]
```

Вы не ограничены запросом полей из одиночной таблицы, также можно запрашивать несколько таблиц.

```ruby
Order.joins(:customer, :books).pluck("orders.created_at, customers.email,  books.title")
```

Более того, в отличие от `select` и других скоупов `Relation`, `pluck` вызывает немедленный запрос, и поэтому не может быть соединен с любыми последующими скоупами, хотя он может работать со скоупами, подключенными ранее:

```ruby
Customer.pluck(:first_name).limit(1)
# => NoMethodError: undefined method `limit' for #<Array:0x007ff34d3ad6d8>

Customer.limit(1).pluck(:first_name)
# => ["David"]
```

NOTE: Следует знать, что использование `pluck` запустит нетерпеливую загрузку, если объект relation содержит включаемые значения, даже если нетерпеливая загрузка не нужна для запроса. Например:

```ruby
# сохраняем связь для ее повторного использования
assoc = Customer.includes(:reviews)
assoc.pluck(:id)
# SELECT "customers"."id" FROM "customers" LEFT OUTER JOIN "reviews" ON "reviews"."id" = "customers"."review_id"
```

Один из способов избежать этого — `unscope` на includes:

```ruby
assoc.unscope(:includes).pluck(:id)
```

### `ids`

`ids` может быть использован для сбора всех ID для relation, используя первичный ключ таблицы.

```ruby
Customer.ids
# SELECT id FROM customers
```

```ruby
class Customer < ApplicationRecord
  self.primary_key = "customer_id"
end

Customer.ids
# SELECT customer_id FROM customers
```

Существование объектов
----------------------

Если вы просто хотите проверить существование объекта, есть метод, называемый `exists?`. Этот метод запрашивает базу данных, используя тот же запрос, что и `find`, но вместо возврата объекта или коллекции объектов, он возвращает или `true`, или `false`.

```ruby
Customer.exists?(1)
```

Метод `exists?` также принимает несколько значений, при этом возвращает `true`, если хотя бы одна из этих записей существует.

```ruby
Customer.exists?(id: [1,2,3])
# или
Customer.exists?(name: ['John', 'Sergei'])
```

Даже возможно использовать `exists?` без аргументов на модели или relation:

```ruby
Customer.where(first_name: 'Ryan').exists?
```

Пример выше вернет `true`, если есть хотя бы один покупатель с `first_name` 'Ryan', и `false` в противном случае.

```ruby
Customer.exists?
```

Это возвратит `false`, если таблица `customers` пустая, и `true` в противном случае.

Для проверки на существование также можно использовать `any?` и `many?` на модели или relation. `many?` будет использовать SQL `count`, для определения, существует ли элемент.

```ruby
# на модели
Order.any?   # => SELECT 1 AS one FROM orders
Order.many?  # => SELECT COUNT(*) FROM orders

# на именованном скоупе
Order.shipped.any?   # => SELECT 1 AS one FROM orders WHERE orders.status = 0
Order.shipped.many?  # => SELECT COUNT(*) FROM orders WHERE orders.status = 0

# на relation
Book.where(out_of_print: true).any?
Book.where(out_of_print: true).many?

# на связи
Customer.first.orders.any?
Customer.first.orders.many?
```

Вычисления
----------

Этот раздел использует `count` для примера в этой преамбуле, но описанные опции применяются ко всем подразделам.

Все методы вычисления работают прямо на модели:

```ruby
Customer.count
# SELECT COUNT(*) FROM customers
```

Или на relation:

```ruby
Customer.where(first_name: 'Ryan').count
# SELECT COUNT(*) FROM customers WHERE (first_name = 'Ryan')
```

Можно также использовать различные методы поиска на relation для выполнения сложных вычислений:

```ruby
Customer.includes("orders").where(first_name: 'Ryan', orders: { status: 'shipped' }).count
```

Что выполнит:

```sql
SELECT COUNT(DISTINCT customers.id) FROM customers
  LEFT OUTER JOIN orders ON orders.customer_id = customers.id
  WHERE (customers.first_name = 'Ryan' AND orders.status = 0)
```

при условии что в Order есть `enum status: [ :shipped, :being_packed, :cancelled ]`

### Количество

Если хотите увидеть, сколько записей есть в таблице модели, можете вызвать `Customer.count`, и он возвратит число. Если хотите быть более определенным и найти всех покупателей с присутствующим в базе данных титулом, используйте `Customer.count(:title)`.

Про опции смотрите выше в разделе [Вычисления](#vychisleniya).

### Среднее

Если хотите увидеть среднее значение определенного показателя в одной из ваших таблиц, можно вызвать метод `average` для класса, относящегося к таблице. Вызов этого метода выглядит так:

```ruby
Order.average("subtotal")
```

Это возвратит число (возможно, с плавающей запятой, такое как 3.14159265), представляющее среднее значение поля.

Про опции смотрите выше в разделе [Вычисления](#vychisleniya).

### Минимум

Если хотите найти минимальное значение поля в таблице, можете вызвать метод `minimum` для класса, относящегося к таблице. Вызов этого метода выглядит так:

```ruby
Order.minimum("subtotal")
```

Про опции смотрите выше в разделе [Вычисления](#vychisleniya).

### Максимум

Если хотите найти максимальное значение поля в таблице, можете вызвать метод `maximum` для класса, относящегося к таблице. Вызов этого метода выглядит так:

```ruby
Order.maximum("subtotal")
```

Про опции смотрите выше в разделе [Вычисления](#vychisleniya).

### Сумма

Если хотите найти сумму полей для всех записей в таблице, можете вызвать метод `sum` для класса, относящегося к таблице. Вызов этого метода выглядит так:

```ruby
Order.sum("subtotal")
```

Про опции смотрите выше в разделе [Вычисления](#vychisleniya).

Запуск EXPLAIN
--------------

Можно запустить EXPLAIN на запросах, вызываемых в relations. Вывод EXPLAIN различается для каждой базы данных.

Например, запуск

```ruby
Customer.where(id: 1).joins(:orders).explain
```

может выдать

```sql
EXPLAIN for: SELECT `customers`.* FROM `customers` INNER JOIN `orders` ON `orders`.`customer_id` = `customers`.`id` WHERE `customers`.`id` = 1
+----+-------------+------------+-------+---------------+
| id | select_type | table      | type  | possible_keys |
+----+-------------+------------+-------+---------------+
|  1 | SIMPLE      | customers  | const | PRIMARY       |
|  1 | SIMPLE      | orders     | ALL   | NULL          |
+----+-------------+------------+-------+---------------+
+---------+---------+-------+------+-------------+
| key     | key_len | ref   | rows | Extra       |
+---------+---------+-------+------+-------------+
| PRIMARY | 4       | const |    1 |             |
| NULL    | NULL    | NULL  |    1 | Using where |
+---------+---------+-------+------+-------------+

2 rows in set (0.00 sec)
```

для MySQL и MariaDB.

Active Record применяет красивое форматирование, эмулирующее работу соответствующей оболочки базы данных. Таким образом, запуск того же запроса с адаптером PostgreSQL выдаст вместо этого

```
EXPLAIN for: SELECT "customers".* FROM "customers" INNER JOIN "orders" ON "orders"."customer_id" = "customers"."id" WHERE "customers"."id" = $1 [["id", 1]]
                                  QUERY PLAN
------------------------------------------------------------------------------
 Nested Loop  (cost=4.33..20.85 rows=4 width=164)
    ->  Index Scan using customers_pkey on customers  (cost=0.15..8.17 rows=1 width=164)
          Index Cond: (id = '1'::bigint)
    ->  Bitmap Heap Scan on orders  (cost=4.18..12.64 rows=4 width=8)
          Recheck Cond: (customer_id = '1'::bigint)
          ->  Bitmap Index Scan on index_orders_on_customer_id  (cost=0.00..4.18 rows=4 width=0)
                Index Cond: (customer_id = '1'::bigint)
(7 rows)
```

Нетерпеливая загрузка может вызвать более одного запроса за раз, и некоторым запросам могут потребоваться результаты предыдущих. Поэтому `explain` фактически выполняет запрос, а затем запрашивает планы запросов. Например,

```ruby
Customer.where(id: 1).includes(:orders).explain
```

может выдать это для MySQL и MariaDB:

```
EXPLAIN for: SELECT `customers`.* FROM `customers`  WHERE `customers`.`id` = 1
+----+-------------+-----------+-------+---------------+
| id | select_type | table     | type  | possible_keys |
+----+-------------+-----------+-------+---------------+
|  1 | SIMPLE      | customers | const | PRIMARY       |
+----+-------------+-----------+-------+---------------+
+---------+---------+-------+------+-------+
| key     | key_len | ref   | rows | Extra |
+---------+---------+-------+------+-------+
| PRIMARY | 4       | const |    1 |       |
+---------+---------+-------+------+-------+

1 row in set (0.00 sec)

EXPLAIN for: SELECT `orders`.* FROM `orders`  WHERE `orders`.`customer_id` IN (1)
+----+-------------+--------+------+---------------+
| id | select_type | table  | type | possible_keys |
+----+-------------+--------+------+---------------+
|  1 | SIMPLE      | orders | ALL  | NULL          |
+----+-------------+--------+------+---------------+
+------+---------+------+------+-------------+
| key  | key_len | ref  | rows | Extra       |
+------+---------+------+------+-------------+
| NULL | NULL    | NULL |    1 | Using where |
+------+---------+------+------+-------------+


1 row in set (0.00 sec)
```

и может выдать это для PostgreSQL:

```
  Customer Load (0.3ms)  SELECT "customers".* FROM "customers" WHERE "customers"."id" = $1  [["id", 1]]
  Order Load (0.3ms)  SELECT "orders".* FROM "orders" WHERE "orders"."customer_id" = $1  [["customer_id", 1]]
=> EXPLAIN for: SELECT "customers".* FROM "customers" WHERE "customers"."id" = $1 [["id", 1]]
                                    QUERY PLAN
----------------------------------------------------------------------------------
 Index Scan using customers_pkey on customers  (cost=0.15..8.17 rows=1 width=164)
   Index Cond: (id = '1'::bigint)
(2 rows)
```

### Интерпретация EXPLAIN

Интерпретация результатов EXPLAIN находится за рамками этого руководства. Может быть полезной следующая информация:

* SQLite3: [EXPLAIN QUERY PLAN](https://www.sqlite.org/eqp.html)

* MySQL: [EXPLAIN Output Format](https://dev.mysql.com/doc/refman/5.7/en/explain-output.html)

* MariaDB: [EXPLAIN](https://mariadb.com/kb/en/mariadb/explain/)

* PostgreSQL: [Using EXPLAIN](https://postgrespro.ru/docs/postgrespro/current/using-explain)
