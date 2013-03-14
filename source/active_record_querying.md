Интерфейс запросов Active Record
================================

Это руководство раскрывает различные способы получения данных из базы данных, используя Active Record.

После его прочтения, вы узнаете:

* Как искать записи, используя различные методы и условия.
* Как определять порядок, получаемые атрибуты, группировку и другие свойства поиска записей.
* Как использовать нетерпеливую загрузку (eager loading) для уменьшения числа запросов к базе данных, необходимых для получения данных.
* Как использовать методы динамического поиска.
* Как проверять существование отдельных записей.
* Как выполнять различные вычисления в моделях Active Record.
* Как запускать EXPLAIN на relations.

Если вы использовали чистый SQL для поиска записей в базе данных, то скорее всего обнаружите, что в Rails есть лучшие способы выполнения тех же операций. Active Record ограждает вас от необходимости использования SQL во многих случаях.

Примеры кода далее в этом руководстве будут относиться к некоторым из этих моделей:

TIP: Все модели используют `id` как первичный ключ, если не указано иное.

```ruby
class Client < ActiveRecord::Base
  has_one :address
  has_many :orders
  has_and_belongs_to_many :roles
end
```

```ruby
class Address < ActiveRecord::Base
  belongs_to :client
end
```

```ruby
class Order < ActiveRecord::Base
  belongs_to :client, counter_cache: true
end
```

```ruby
class Role < ActiveRecord::Base
  has_and_belongs_to_many :clients
end
```

Active Record выполнит запросы в базу данных за вас, он совместим с большинством СУБД (MySQL, PostgreSQL и SQLite - это только некоторые из них). Независимо от того, какая используется СУБД, формат методов Active Record будет всегда одинаковый.

Получение объектов из базы данных
---------------------------------

Для получения объектов из базы данных Active Record предоставляет несколько методов поиска. В каждый метод поиска можно передавать аргументы для выполнения определенных запросов в базу данных без необходимости писать на чистом SQL.

Методы следующие:

* `bind`
* `create_with`
* `eager_load`
* `extending`
* `from`
* `group`
* `having`
* `includes`
* `joins`
* `limit`
* `lock`
* `none`
* `offset`
* `order`
* `preload`
* `readonly`
* `references`
* `reorder`
* `reverse_order`
* `select`
* `uniq`
* `where`

Все эти методы возвращают экземпляр `ActiveRecord::Relation`.

Вкратце основные операции `Model.find(options)` таковы:

* Преобразовать предоставленные опции в эквивалентный запрос SQL.
* Выполнить запрос SQL и получить соответствующие результаты из базы данных.
* Создать экземпляр эквивалентного объекта Ruby подходящей модели для каждой строки результата запроса.
* Запустить колбэки `after_find`, если таковые имеются.

### Получение одиночного объекта

Active Record представляет пять различных способов получения одиночного объекта.

#### Использование первичного ключа

Используя `Model.find(primary_key, options = nil)`, можно получить объект, соответствующий определенному первичному ключу (_primary key_) и предоставленным опциям. Например:

```ruby
# Ищет клиента с первичным ключом (id) 10.
client = Client.find(10)
# => #<Client id: 10, first_name: "Ryan">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients WHERE (clients.id = 10) LIMIT 1
```

`Model.find(primary_key)` вызывает исключение `ActiveRecord::RecordNotFound`, если соответствующей записи не было найдено.

#### `take`

`Model.take` получает запись без какого-либо явного упорядочивания. Например:

```ruby
client = Client.take
# => #<Client id: 1, first_name: "Lifo">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients LIMIT 1
```

`Model.take` возвращает `nil`, если ни одной записи не найдено, и исключение не будет вызвано.

TIP: Получаемая запись может отличаться в зависимости от движка базы данных.

#### `first`

`Model.first` находит первую запись, упорядоченную по первичному ключу. Например:

```ruby
client = Client.first
# => #<Client id: 1, first_name: "Lifo">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients ORDER BY clients.id ASC LIMIT 1
```

`Model.first` возвращает `nil`, если не найдено соответствующей записи, и исключение не вызывается.

#### `last`

`Model.last` находит последнюю запись, упорядоченную по первичному ключу. Например:

```ruby
client = Client.last
# => #<Client id: 221, first_name: "Russel">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients ORDER BY clients.id DESC LIMIT 1
```

`Model.last` возвращает `nil`, если не найдено соответствующей записи, и исключение не вызывается.

#### `find_by`

`Model.find_by` ищет первую запись, соответствующую некоторым условиям. Например:

```ruby
Client.find_by first_name: 'Lifo'
# => #<Client id: 1, first_name: "Lifo">

Client.find_by first_name: 'Jon'
# => nil
```

Это эквивалент записи:

```ruby
Client.where(first_name: 'Lifo').take
```

#### `take!`

`Model.take!` получает запись без какого-либо явного упорядочивания. Например:

```ruby
client = Client.take!
# => #<Client id: 1, first_name: "Lifo">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients LIMIT 1
```

`Model.take!` вызывает `ActiveRecord::RecordNotFound`, если соответсвующей записи не было найдено.

#### `first!`

`Model.first!` находит первую запись, упорядоченную по первичному ключу. Например:

```ruby
client = Client.first!
# => #<Client id: 1, first_name: "Lifo">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients ORDER BY clients.id ASC LIMIT 1
```

`Model.first` вызывает `ActiveRecord::RecordNotFound`, если не найдено соответствующей записи.

#### `last!`

`Model.last!` находит последнюю запись, упорядоченную по первичному ключу. Например:

```ruby
client = Client.last!
# => #<Client id: 221, first_name: "Russel">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients ORDER BY clients.id DESC LIMIT 1
```

`Model.last` вызывает `ActiveRecord::RecordNotFound`, если не найдено соответствующей записи.

#### `find_by!`

`Model.find_by!` ищет первую запись, соответствующую некоторым условиям. Он вызывает `ActiveRecord::RecordNotFound`, если не найдено соответствующей записи. Например:

```ruby
Client.find_by! first_name: 'Lifo'
# => #<Client id: 1, first_name: "Lifo">

Client.find_by! first_name: 'Jon'
# => ActiveRecord::RecordNotFound
```

Это эквивалент записи:

```ruby
Client.where(first_name: 'Lifo').take!
```

### Получение нескольких объектов

#### Использование нескольких первичных ключей

`Model.find(array_of_primary_key)` принимает массив _первичных ключей_, возвращая массив, содержащий все соответствующие записи для предоставленных _первичных ключей_. Например:

```ruby
# Найти клиентов с первичными ключами 1 и 10.
client = Client.find([1, 10]) # Или даже Client.find(1, 10)
# => [#<Client id: 1, first_name: "Lifo">, #<Client id: 10, first_name: "Ryan">]
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients WHERE (clients.id IN (1,10))
```

WARNING: `Model.find(array_of_primary_key)` вызывает исключение `ActiveRecord::RecordNotFound`, если не найдено соответствующих записей для **всех** предоставленных первичных ключей.

#### take

`Model.take(limit)` извлекает первые несколько записей, определенных `limit` без какого-либо явного упорядочивания:

```ruby
Client.take(2)
# => [#<Client id: 1, first_name: "Lifo">,
      #<Client id: 2, first_name: "Raf">]
```

Эквивалент SQL этого следующий:

```sql
SELECT * FROM clients LIMIT 2
```

#### first

`Model.first(limit)` находит первые несколько записей, определенных `limit`, упорядоченные по первичному ключу:

```ruby
Client.first(2)
# => [#<Client id: 1, first_name: "Lifo">,
      #<Client id: 2, first_name: "Raf">]
```

Эквивалент SQL этого следующий:

```sql
SELECT * FROM clients ORDER BY id ASC LIMIT 2
```

#### last

`Model.last(limit)` находит несколько записей, определенных `limit`, упорядоченные по первичному ключу в порядке убывания:

```ruby
Client.last(2)
# => [#<Client id: 10, first_name: "Ryan">,
      #<Client id: 9, first_name: "John">]
```

Эквивалент SQL этого следующий:

```sql
SELECT * FROM clients ORDER BY id DESC LIMIT 2
```

### Получение нескольких объектов пакетами

Часто необходимо перебрать огромный набор записей, когда рассылаем письма всем пользователям или импортируем некоторые данные.

Это может показаться простым:

```ruby
# Очень неэффективно, когда в таблице users тысячи строк.
User.all.each do |user|
  NewsLetter.weekly_deliver(user)
end
```

Но этот подход становится очень непрактичным с увеличением размера таблицы, поскольку `User.all.each` говорит Active Record извлечь _таблицу полностью_ за один проход, создать объект модели для каждой строки и держать этот массив в памяти. В реальности, если имеется огромное количество записей, полная коллекция может превысить количество доступной памяти.

Rails представляет два метода, посвященных разделению записей на дружелюбные к памяти пакеты для обработки. Первый метод, `find_each`, получает пакет записей и затем вкладывает _каждую_ запись в блок отдельно как модель. Второй метод, `find_in_batches`, получает пакет записей и затем вкладывает _весь пакет_ в блок как массив моделей.

TIP: Методы `find_each` и `find_in_batches` предназначены для пакетной обработки большого числа записей, которые не поместятся в памяти за раз. Если нужно просто перебрать тысячу записей, более предпочтителен вариант обычных методов поиска.

#### `find_each`

Метод `find_each` получает пакет записей и затем вкладывает _каждую_ запись в блок отдельно как модель. В следующем примере `find_each` получит 1000 записей (текущее значение по умолчанию и для `find_each`, и для `find_in_batches`), а затем вложит каждую запись отдельно в блок как модель. Процесс повторится, пока не будут обработаны все записи:

```ruby
User.find_each do |user|
  NewsLetter.weekly_deliver(user)
end
```

##### Опции для `find_each`

Метод `find_each` принимает большинство опций, допустимых для обычного метода `find`, за исключением `:order` и `:limit`, зарезервированных для внутреннего использования в `find_each`.

Также доступны две дополнительные опции, `:batch_size` и `:start`.

**`:batch_size`**

Опция `:batch_size` позволяет опеределить число записей, подлежащих получению в одном пакете, до передачи отдельной записи в блок. Например, для получения 5000 записей в пакете:

```ruby
User.find_each(batch_size: 5000) do |user|
  NewsLetter.weekly_deliver(user)
end
```

**`:start`**

По умолчанию записи извлекаются в порядке увеличения первичного ключа, который должен быть числом. Опция `:start` позволяет вам настроить первый ID последовательности, когда наименьший ID не тот, что вам нужен. Это полезно, например, если хотите возобновить прерванный процесс пакетирования, предоставив последний обработанный ID как контрольную точку.

Например, чтобы выслать письма только пользователям с первичным ключом, начинающимся от 2000, и получить их в пакетах по 5000:

```ruby
User.find_each(start: 2000, batch_size: 5000) do |user|
  NewsLetter.weekly_deliver(user)
end
```

Другим примером является наличие нескольких воркеров, работающих с одной и той же очередью обработки. Можно было бы обрабатывать каждым воркером 10000 записей, установив подходящие опции `:start` в каждом воркере.

#### `find_in_batches`

Метод `find_in_batches` похож на `find_each`, посколько они оба получают пакеты записей. Различие в том, что `find_in_batches` передает в блок _пакеты_ как массив моделей, вместо отдельной модели. Следующий пример передаст в представленный блок массив из 1000 счетов за раз, а в последний блок содержащий все оставшиеся счета:

```ruby
# Передает в add_invoices массив из 1000 счетов за раз.
Invoice.find_in_batches(include: :invoice_lines) do |invoices|
  export.add_invoices(invoices)
end
```

NOTE: Опция `:include` позволяет назвать связи, которые должны быть загружены вместе с моделями.

##### Опции для `find_in_batches`

Метод `find_in_batches` принимает те же опции `:batch_size` и `:start`, как и `find_each`, а также большинство опций, допустимых для обычного метода `find`, за исключением `:order` и `:limit`, зарезервированных для внутреннего использования в `find_in_batches`.

Условия
-------

Метод `where` позволяет определить условия для ограничения возвращаемых записей, которые представляют `WHERE`-часть выражения SQL. Условия могут быть заданы как строка, массив или хэш.

### (pure-string-conditions) Чисто строковые условия

Если вы хотите добавить условия в свой поиск, можете просто определить их там, подобно `Client.where("orders_count = '2'")`. Это найдет всех клиентов, где значение поля `orders_count` равно 2.

WARNING: Создание условий в чистой строке подвергает вас риску SQL инъекций. Например, `Client.where("first_name LIKE '%#{params[:first_name]}%'")` не безопасно. Смотрите следующий раздел для более предпочтительного способа обработки условий с использованием массива.

### (array-conditions) Условия с использованием массива

Что если количество может изменяться, скажем, как аргумент извне, возможно даже от пользователя? Поиск тогда принимает такую форму:

```ruby
Client.where("orders_count = ?", params[:orders])
```

Active Record проходит через первый элемент в переданных условиях, подставляя остальные элементы вместо знаков вопроса `(?)` в первом элементе.

Если хотите определить несколько условий:

```ruby
Client.where("orders_count = ? AND locked = ?", params[:orders], false)
```

В этом примере первый знак вопроса будет заменен на значение в `params[:orders]` и второй будет заменен SQL аналогом `false`, который зависит от адаптера.

Этот код значительно предпочтительнее:

```ruby
Client.where("orders_count = ?", params[:orders])
```

чем такой код:

```ruby
Client.where("orders_count = #{params[:orders]}")
```

по причине безопасности аргумента. Помещение переменной прямо в строку условий передает переменную в базу данных _как есть_. Это означает, что неэкранированная переменная, переданная пользователем, может иметь злой умысел. Если так сделать, вы подвергаете базу данных риску, так как если пользователь обнаружит, что он может использовать вашу базу данных, то он сможет сделать с ней что угодно. Никогда не помещайте аргументы прямо в строку условий!

TIP: Подробнее об опасности SQL инъекций можно узнать из [Руководства Ruby On Rails по безопасности](/ruby-on-rails-security-guide).

#### Символы-заполнители в условиях

Подобно тому, как `(?)` заменяют параметры, можно использовать хэш ключей/параметров в условиях с использованием массива:

```ruby
Client.where("created_at >= :start_date AND created_at <= :end_date",
  {start_date: params[:start_date], end_date: params[:end_date]})
```

Читаемость улучшится, в случае если вы используете большое количество переменных в условиях.

### (hash-conditions) Условия с использованием хэша

Active Record также позволяет передавать условия в хэше, что улучшает читаемость синтаксиса условий. В этом случае передается хэш с ключами, равными полям, к которым применяются условия, и с значениями, указывающим каким образом вы хотите применить к ним условия:

NOTE: Хэшем можно передать условия проверки только равенства, интервала и подмножества.

#### Условия равенства

```ruby
Client.where(locked: true)
```

Имя поля также может быть строкой, а не символом:

```ruby
Client.where('locked' => true)
```

В случае отношений belongs_to, может быть использован ключ связи для указания модели, если как значение используется объект Active Record. Этот метод также работает с полиморфными отношениями.

```ruby
Post.where(author: author)
Author.joins(:posts).where(posts: {author: author})
```

NOTE: Значения не могут быть символами. Например, нельзя сделать `Client.where(status: :active)`.

#### Интервальные условия

```ruby
Client.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight)
```

Это найдет всех клиентов, созданных вчера, с использованием SQL выражения `BETWEEN`:

```sql
SELECT * FROM clients WHERE (clients.created_at BETWEEN '2008-12-21 00:00:00' AND '2008-12-22 00:00:00')
```

Это была демонстрация более короткого синтаксиса для примеров в [Условия с использованием массива](#array-conditions)

#### Условия подмножества

Если хотите найти записи, используя выражение `IN`, можете передать массив в хэш условия:

```ruby
Client.where(orders_count: [1,3,5])
```

Этот код создаст подобный SQL:

```sql
SELECT * FROM clients WHERE (clients.orders_count IN (1,3,5))
```

### Условия NOT, LIKE и NOT LIKE

Запросы `NOT`, `LIKE` и `NOT LIKE` в SQL могут быть созданы с помощью `where.not`, `where.like` и `where.not_like` соответственно.

```ruby
Post.where.not(author: author)

Author.where.like(name: 'Nari%')

Developer.where.not_like(name: 'Tenderl%')
```

Другими словами, этот тип запросов может быть создан с помощью вызова `where` без аргументов с далее присоединенным `not`, `like` или `not_like` с переданными условиями для `where`.

(ordering) Сортировка
---------------------

Чтобы получить записи из базы данных в определенном порядке, можете использовать метод `order`.

Например, если вы получаете ряд записей и хотите упорядочить их в порядке возрастания поля `created_at` в таблице:

```ruby
Client.order("created_at")
```

Также можете определить `ASC` или `DESC`:

```ruby
Client.order("created_at DESC")
# ИЛИ
Client.order("created_at ASC")
```

Или сортировку по нескольким полям:

```ruby
Client.order("orders_count ASC, created_at DESC")
# или
Client.order("orders_count ASC", "created_at DESC")
```

Если хотите вызвать `order` несколько раз, т.е. в различном контексте, новый порядок будет предшествовать предыдущему

```ruby
Client.order("orders_count ASC").order("created_at DESC")
# SELECT * FROM clients ORDER BY created_at DESC, orders_count ASC
```

Выбор определенных полей
------------------------

По умолчанию `Model.find` выбирает все множество полей результата, используя `select *`.

Чтобы выбрать подмножество полей из всего множества, можете определить его, используя метод `select`.

Например, чтобы выбрать только столбцы `viewable_by` и `locked`:

```ruby
Client.select("viewable_by, locked")
```

Используемый для этого запрос SQL будет иметь подобный вид:

```sql
SELECT viewable_by, locked FROM clients
```

Будьте осторожны, поскольку это также означает, что будет инициализирован объект модели только с теми полями, которые вы выбрали. Если вы попытаетесь обратиться к полям, которых нет в инициализированной записи, то получите:

```bash
ActiveModel::MissingAttributeError: missing attribute: <attribute>
```

Где `<attribute>` это атрибут, который был запрошен. Метод `id` не вызывает `ActiveRecord::MissingAttributeError`, поэтому будьте аккуратны при работе со связями, так как они нуждаются в методе `id` для правильной работы.

Если хотите вытащить только по одной записи для каждого уникального значения в определенном поле, можно использовать `uniq`:

```ruby
Client.select(:name).uniq
```

Это создаст такой SQL:

```sql
SELECT DISTINCT name FROM clients
```

Также можно убрать ограничение уникальности:

```ruby
query = Client.select(:name).uniq
# => Возвратит уникальные имена

query.uniq(false)
# => Возвратит все имена, даже если есть дубликаты
```

Ограничение и смещение
----------------------

Чтобы применить `LIMIT` к SQL, запущенному с помощью `Model.find`, нужно определить `LIMIT`, используя методы `limit` и `offset` на relation.

Используйте limit для определения количества записей, которые будут получены, и offset - для числа записей, которые будут пропущены до начала возврата записей. Например:

```ruby
Client.limit(5)
```

возвратит максимум 5 клиентов, и, поскольку не определено смещение, будут возвращены первые 5 клиентов в таблице. Запускаемый SQL будет выглядеть подобным образом:

```sql
SELECT * FROM clients LIMIT 5
```

Добавление `offset` к этому

```ruby
Client.limit(5).offset(30)
```

Возвратит максимум 5 клиентов, начиная с 31-го. SQL выглядит так:

```sql
SELECT * FROM clients LIMIT 5 OFFSET 30
```

Группировка
-----------

Чтобы применить условие `GROUP BY` к `SQL`, можете определить метод `group` в поисковом запросе.

Например, если хотите найти коллекцию дат, в которые были созданы заказы:

```ruby
Order.select("date(created_at) as ordered_date, sum(price) as total_price").group("date(created_at)")
```

Это даст вам отдельный объект `Order` для каждой даты, в которой были заказы в базе данных.

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT date(created_at) as ordered_date, sum(price) as total_price
FROM orders
GROUP BY date(created_at)
```

Владение
--------

SQL использует условие `HAVING` для определения условий для полей, указанных в `GROUP BY`. Условие `HAVING`, определенное в SQL, запускается в `Model.find` с использованием опции `:having` для поиска.

Например:

```ruby
Order.select("date(created_at) as ordered_date, sum(price) as total_price").group("date(created_at)").having("sum(price) > ?", 100)
```

SQL, который будет выполнен, выглядит так:

```sql
SELECT date(created_at) as ordered_date, sum(price) as total_price
FROM orders
GROUP BY date(created_at)
HAVING sum(price) > 100
```

Это возвратит отдельные объекты order для каждого дня, но только те, которые заказаны более чем на 100$ в день.

Переопределяющие условия
------------------------

### `except`

Можете указать определенные условия, которые будут исключены, используя метод `except`. Например:

```ruby
Post.where('id > 10').limit(20).order('id asc').except(:order)
```

SQL, который будет выполнен:

```sql
SELECT * FROM posts WHERE id > 10 LIMIT 20
```

### `unscope`

Метод `except` не работает, когда сливаются несколько relation. Например:

```ruby
Post.comments.except(:order)
```

все еще будет иметь упорядочивание, если оно задано скоупом по умолчанию в Comment. Чтобы убрать все упорядочивание, даже из слитых relation, используйте unscope следующим образом:

```ruby
Post.order('id DESC').limit(20).unscope(:order) = Post.limit(20)
Post.order('id DESC').limit(20).unscope(:order, :limit) = Post.all
```

Дополнительно можно убрать определенные условия из where. Например:

```ruby
Post.where(:id => 10).limit(1).unscope(:where => :id, :limit).order('id DESC') = Post.order('id DESC')
```

### `only`

Также можно переопределить условия, используя метод `only`. Например:

```ruby
Post.where('id > 10').limit(20).order('id desc').only(:order, :where)
```

SQL, который будет выполнен:

```sql
SELECT * FROM posts WHERE id > 10 ORDER BY id DESC
```

### `reorder`

Метод `reorder` переопределяет сортировку скоупа по умолчанию. Например:

```ruby
class Post < ActiveRecord::Base
  ..
  ..
  has_many :comments, order: 'posted_at DESC'
end

Post.find(10).comments.reorder('name')
```

SQL, который будет выполнен:

```sql
SELECT * FROM posts WHERE id = 10 ORDER BY name
```

В случае, если бы условие `reorder` не было бы использовано, запущенный SQL был бы:

```sql
SELECT * FROM posts WHERE id = 10 ORDER BY posted_at DESC
```

### `reverse_order`

Метод `reverse_order` меняет направление условия сортировки, если оно определено:

```ruby
Client.where("orders_count > 10").order(:name).reverse_order
```

SQL, который будет выполнен:

```sql
SELECT * FROM clients WHERE orders_count > 10 ORDER BY name DESC
```

Если условие сортировки не было определено в запросе, `reverse_order` сортирует по первичному ключу в обратном порядке:

```ruby
Client.where("orders_count > 10").reverse_order
```

SQL, который будет выполнен:

```sql
SELECT * FROM clients WHERE orders_count > 10 ORDER BY clients.id DESC
```

Этот метод не принимает аргументы.

Нулевой Relation
----------------

Метод `none` возвращает сцепляемый relation без записей. Любые последующие условия, сцепленные с возвращенным relation, продолжат возвращать пустые relation. Это полезно в случаях, когда необходим сцепляемый отклик на метод или скоуп, который может вернуть пустые результаты.

```ruby
Post.none # returns an empty Relation and fires no queries.
```

```ruby
# От метода visible_posts ожидается, что он вернет Relation.
@posts = current_user.visible_posts.where(name: params[:name])

def visible_posts
  case role
  when 'Country Manager'
    Post.where(country: country)
  when 'Reviewer'
    Post.published
  when 'Bad User'
    Post.none # => если бы вернули [] или nil, код поломался бы в этом случае
  end
end
```

Объекты только для чтения
-------------------------

Active Record представляет метод `readonly` у relation для явного запрета изменения любого возвращаемого объекта. Любая попытка изменить объект только для чтения будет неудачной, вызвав исключение `ActiveRecord::ReadOnlyRecord`.

```ruby
client = Client.readonly.first
client.visits += 1
client.save
```

Так как `client` явно указан как объект только для чтения, вызов вышеуказанного кода вызовет исключение `ActiveRecord::ReadOnlyRecord` при вызове `client.save` с обновленным значением `visits`.

Блокировка записей для обновления
---------------------------------

Блокировка полезна для предотвращения гонки условий при обновлении записей в базе данных и обеспечения атомарного обновления.

Active Record предоставляет два механизма блокировки:

* Оптимистичная блокировка
* Пессимистичная блокировка

### Оптимистичная блокировка

Оптимистичная блокировка позволяет нескольким пользователям обращаться к одной и той же записи для редактирования и предполагает минимум конфликтов с данными. Она осуществляется с помощью проверки, сделал ли другой процесс изменения в записи, с тех пор как она была открыта. Если это происходит, вызывается исключение `ActiveRecord::StaleObjectError`, и обновление игнорируется.

**Столбец оптимистичной блокировки**

Чтобы начать использовать оптимистичную блокировку, таблица должна иметь столбец, называющийся `lock_version`, с типом integer. Каждый раз, когда запись обновляется, Active Record увеличивает значение `lock_version`, и средства блокирования обеспечивают, что для записи, вызванной дважды, та, которая первая успеет будет сохранена, а для второй будет вызвано исключение `ActiveRecord::StaleObjectError`. Пример:

```ruby
c1 = Client.find(1)
c2 = Client.find(1)

c1.first_name = "Michael"
c1.save

c2.name = "should fail"
c2.save # Raises a ActiveRecord::StaleObjectError
```

Вы ответственны за разрешение конфликта с помощью обработки исключения и либо отката, либо объединения, либо применения бизнес-логики, необходимой для разрешения конфликта.

Это поведение может быть отключено, если установить `ActiveRecord::Base.lock_optimistically = false`.

Для переопределения имени столбца `lock_version`, `ActiveRecord::Base` предоставляет атрибут класса `locking_column`:

```ruby
class Client < ActiveRecord::Base
  self.locking_column = :lock_client_column
end
```

### Пессимистичная блокировка

Пессимистичная блокировка использует механизм блокировки, предоставленный лежащей в основе базой данных. Использование `lock` при построении relation применяет эксклюзивную блокировку на выделенные строки. Relation использует `lock` обычно упакованный внутри transaction для предотвращения условий взаимной блокировки (дедлока).

Например:

```ruby
Item.transaction do
  i = Item.lock.first
  i.name = 'Jones'
  i.save
end
```

Вышеописанная сессия осуществляет следующие SQL для бэкенда MySQL:

```sql
SQL (0.2ms)   BEGIN
Item Load (0.3ms)   SELECT * FROM `items` LIMIT 1 FOR UPDATE
Item Update (0.4ms)   UPDATE `items` SET `updated_at` = '2009-02-07 18:05:56', `name` = 'Jones' WHERE `id` = 1
SQL (0.8ms)   COMMIT
```

Можете передать чистый SQL в опцию `:lock` для разрешения различных типов блокировок. Например, MySQL имеет выражение, называющееся `LOCK IN SHARE MODE`, которым можно заблокировать запись, но разрешить другим запросам читать ее. Для указания этого выражения, просто передайте его как опцию блокировки:

```ruby
Item.transaction do
  i = Item.lock("LOCK IN SHARE MODE").find(1)
  i.increment!(:views)
end
```

Если у вас уже имеется экземпляр модели, можно начать транзакцию и затребовать блокировку одновременно, используя следующий код:

```ruby
item = Item.first
item.with_lock do
  # Этот блок вызывается в транзакции,
  # элемент уже заблокирован.
  item.increment!(:views)
end
```

Соединительные таблицы
----------------------

Active Record предоставляет метод поиска с именем `joins` для определения условия `JOIN` в результирующем SQL. Есть разные способы определить метод `joins`:

### Использование строчного фрагмента SQL

Можете просто дать чистый SQL, определяющий условие `JOIN` в `joins`.

```ruby
Client.joins('LEFT OUTER JOIN addresses ON addresses.client_id = clients.id')
```

Это приведет к следующему SQL:

```sql
SELECT clients.* FROM clients LEFT OUTER JOIN addresses ON addresses.client_id = clients.id
```

### Использование массива/хэша именнованных связей

WARNING: Этот метод работает только с `INNER JOIN`.

Active Record позволяет использовать имена [связей](/active-record-associations), определенных в модели, как ярлыки для определения условия `JOIN` этих связей при использовании метода `joins`.

Например, рассмотрим следующие модели `Category`, `Post`, `Comments` и `Guest`:

```ruby
class Category < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :category
  has_many :comments
  has_many :tags
end

class Comment < ActiveRecord::Base
  belongs_to :post
  has_one :guest
end

class Guest < ActiveRecord::Base
  belongs_to :comment
end

class Tag < ActiveRecord::Base
  belongs_to :post
end
```

Сейчас все нижеследующее создаст ожидаемые соединительные запросы с использованием `INNER JOIN`:

#### Соединение одиночной связи

```ruby
Category.joins(:posts)
```

Это создаст:

```sql
SELECT categories.* FROM categories
  INNER JOIN posts ON posts.category_id = categories.id
```

Или, по-русски, "возвратить объект Category для всех категорий с публикациями". Отметьте, что будут дублирующиеся категории, если имеется более одной публикации в одной категории. Если нужны уникальные категории, можно использовать `Category.joins(:posts).uniq`.

#### Соединение нескольких связей

```ruby
Post.joins(:category, :comments)
```

Это создаст:

```sql
SELECT posts.* FROM posts
  INNER JOIN categories ON posts.category_id = categories.id
  INNER JOIN comments ON comments.post_id = posts.id
```

Или, по-русски, "возвратить все публикации, у которых есть категория и как минимум один комментарий". Отметьте, что публикации с несколькими комментариями будут показаны несколько раз.

#### Соединение вложенных связей (одного уровня)

```ruby
Post.joins(comments: :guest)
```

Это создаст:

```sql
SELECT posts.* FROM posts
  INNER JOIN comments ON comments.post_id = posts.id
  INNER JOIN guests ON guests.comment_id = comments.id
```

Или, по-русски, "возвратить все публикации, имеющие комментарий, сделанный гостем".

#### Соединение вложенных связей (разных уровней)

```ruby
Category.joins(posts: [{comments: :guest}, :tags])
```

Это создаст:

```sql
SELECT categories.* FROM categories
  INNER JOIN posts ON posts.category_id = categories.id
  INNER JOIN comments ON comments.post_id = posts.id
  INNER JOIN guests ON guests.comment_id = comments.id
  INNER JOIN tags ON tags.post_id = posts.id
```

### Определение условий в соединительных таблицах

В соединительных таблицах можно определить условия, используя надлежащие [массивные](/active-record-query-interface#array-conditions) и [строчные](/active-record-query-interface#pure-string-conditions) условия. [Условия с использованием хэша](/active-record-query-interface#hash-conditions) предоставляют специальный синтаксис для определения условий в соединительных таблицах:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Client.joins(:orders).where('orders.created_at' => time_range)
```

Альтернативный и более чистый синтаксис для этого - вложенные хэш-условия:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Client.joins(:orders).where(orders: {created_at: time_range})
```

Будут найдены все клиенты, имеющие созданные вчера заказы, снова используя выражение SQL `BETWEEN`.

Нетерпеливая загрузка связей
----------------------------

Нетерпеливая загрузка - это механизм загрузки связанных записей объекта, возвращаемого `Model.find`, с использованием как можно меньшего количества запросов.

**Проблема N + 1 запроса**

Рассмотрим следующий код, который находит 10 клиентов и печатает их почтовые индексы:

```ruby
clients = Client.limit(10)

clients.each do |client|
  puts client.address.postcode
end
```

На первый взгляд выглядит хорошо. Но проблема лежит в в общем количестве выполненных запросов. Вышеупомянутый код выполняет 1 (чтобы найти 10 клиентов) + 10 (каждый на одного клиента для загрузки адреса) = итого **11** запросов.

**Решение проблемы N + 1 запроса**

Active Record позволяет усовершенствовано определить все связи, которые должны быть загружены. Это возможно с помощью определения метода `includes` на вызове `Model.find`. Посредством `includes`, Active Record обеспечивает то, что все определенные связи загружаются с использованием минимально возможного количества запросов.

Пересмотривая вышеупомянутую задачу, мы можем переписать `Client.limit(10)` для использование нетерпеливой загрузки адресов:

```ruby
clients = Client.includes(:address).limit(10)

clients.each do |client|
  puts client.address.postcode
end
```

Этот код выполнит всего **2** запроса, вместо **11** запросов из прошлого примера:

```sql
SELECT * FROM clients LIMIT 10
SELECT addresses.* FROM addresses
  WHERE (addresses.client_id IN (1,2,3,4,5,6,7,8,9,10))
```

### Нетерпеливая загрузка нескольких связей

Active Record позволяет нетерпеливо загружать любое количество связей в одном вызове `Model.find` с использованием массива, хэша, или вложенного хэша массивов/хэшей, с помощью метода `includes`.

#### Массив нескольких связей

```ruby
Post.includes(:category, :comments)
```

Это загрузит все публикации и связанные категорию и комментарии для каждой публикации.

#### Вложенный хэш связей

```ruby
Category.includes(posts: [{comments: :guest}, :tags]).find(1)
```

Вышеприведенный код находит категории с id 1 и нетерпеливо загружает все публикации, связанные с найденной категорией. Кроме того, он также нетерпеливо загружает теги и комментарии каждой публикации. Гость, связанный с оставленным комментарием, также будет нетерпеливо загружен.

### Определение условий для нетерпеливой загрузки связей

Хотя Active Record и позволяет определить условия для нетерпеливой загрузки связей, как и в `joins`, рекомендуем использовать вместо этого "joins":/active-record-query-interface/joining-tables.

Однако, если вы сделаете так, то сможете использовать `where` как обычно.

```ruby
Post.includes(:comments).where("comments.visible" => true)
```

Это сгенерирует запрос с ограничением `LEFT OUTER JOIN`, в то время как метод `joins` сгенерировал бы его с использованием функции `INNER JOIN`.

```ruby
  SELECT "posts"."id" AS t0_r0, ... "comments"."updated_at" AS t1_r5 FROM "posts"
    LEFT OUTER JOIN "comments" ON "comments"."post_id" = "posts"."id" WHERE (comments.visible = 1)
```

Если бы не было условия `where`, то сгенерировался бы обычный набор из двух запросов.

Если, в случае с этим запросом `includes`, не будет ни одного комментария ни для одной публикации, все публикации все равно будут загружены. При использовании `joins` (INNER JOIN), соединительные условия **должны** соответствовать, иначе ни одной записи не будет возвращено.

Скоупы
------

Скоупинг позволяет определить часто используемые запросы, к которым можно обращаться как к вызовам метода в связанных объектах или моделях. С помощью этих скоупов можно использовать каждый ранее раскрытый метод, такой как `where`, `joins` и `includes`. Все методы скоупов возвращают объект `ActiveRecord::Relation`, который позволяет вызывать следующие методы (такие как другие скоупы).

Для определения простого скоупа мы используем метод `scope` внутри класса, передав запрос, который хотим запустить при вызове скоупа:

```ruby
class Post < ActiveRecord::Base
  scope :published, -> { where(published: true) }
end
```

Это в точности то же самое, что определение метода класса, и то, что именно вы используете, является вопросом профессионального предпочтения:

```ruby
class Post < ActiveRecord::Base
  def self.published
    where(published: true)
  end
end
```

Скоупы также сцепляются с другими скоупами:

```ruby
class Post < ActiveRecord::Base
  scope :published,               -> { where(published: true) }
  scope :published_and_commented, -> { published.where("comments_count > 0") }
end
```

Для вызова этого скоупа `published`, можно вызвать его либо на классе:

```ruby
Post.published # => [published posts]
```

Либо на связи, состоящей из объектов `Post`:

```ruby
category = Category.first
category.posts.published # => [published posts belonging to this category]
```

### Передача аргумента

Скоуп может принимать аргументы:

```ruby
class Post < ActiveRecord::Base
  scope :created_before, ->(time) { where("created_at < ?", time) }
end
```

Это можно использовать так:

```ruby
Post.created_before(Time.zone.now)
```

Однако, это всего лишь дублирование функциональности, которая должна быть предоставлена методом класса.

```ruby
class Post < ActiveRecord::Base
  def self.created_before(time)
    where("created_at < ?", time)
  end
end
```

Использование метода класса - более предпочтительный способ принятию аргументов скоупом. Эти методы также будут доступны на связанных объектах:

```ruby
category.posts.created_before(time)
```

### Слияние скоупов

Подобно условиям `where`, скоупы сливаются с использованием `AND`.

```ruby
class User < ActiveRecord::Base
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

```ruby
User.active.inactive
# => SELECT "users".* FROM "users" WHERE "users"."state" = 'active' AND "users"."state" = 'inactive'
```

Можно комбинировать условия `scope` и `where`, и результирующий sql будет содержать все условия, соединенные с помощью `AND` .

```ruby
User.active.where(state: 'finished')
# => SELECT "users".* FROM "users" WHERE "users"."state" = 'active' AND "users"."state" = 'finished'
```

Если необходимо, чтобы сработало только последнее условие `where`, тогда можно использовать `Relation#merge`.

```ruby
User.active.merge(User.inactive)
# => SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

Важным отличием является то, что `default_scope` будет переопределен условиями `scope` и `where`.

```ruby
class User < ActiveRecord::Base
  default_scope  { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# => SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# => SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.where(state: 'inactive')
# => SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

Как видите, `default_scope` был переопределен как условием `scope`, так и `where`.

### Применение скоупа по умолчанию

Если хотите, чтобы скоуп был применен ко всем запросам к модели, можно использовать метод `default_scope` в самой модели.

```ruby
class Client < ActiveRecord::Base
  default_scope { where("removed_at IS NULL") }
end
```

Когды запросы для этой модели будут выполняться, запрос SQL теперь будет выглядеть примерно так:

```sql
SELECT * FROM clients WHERE removed_at IS NULL
```

Если необходимо сделать более сложные вещи со скоупом по умолчанию, альтернативно его можно определить как метод класса:

```ruby
class Client < ActiveRecord::Base
  def self.default_scope
    # Should return an ActiveRecord::Relation.
  end
end
```

### Удаление всех скоупов

Если хотите удалить скоупы по какой-то причине, можете использовать метод `unscoped`. Это особенно полезно, если в модели определен `default_scope`, и он не должен быть применен для конкретно этого запроса.

```ruby
Client.unscoped.all
```

Этот метод удаляет все скоупы и выполняет обычный запрос к таблице.

Отметьте, что сцепление `unscoped` со `scope` не работает. В этих случаях рекомендовано использовать блочную форму `unscoped`:

```ruby
Client.unscoped {
  Client.created_before(Time.zone.now)
}
```

(dynamic-finders) Динамический поиск
------------------

Для каждого поля (также называемого атрибутом), определенного в вашей таблице, Active Record предоставляет метод поиска. Например, если есть поле `first_name` в вашей модели `Client`, вы на халяву получаете `find_by_first_name` от Active Record. Если также есть поле `locked` в модели `Client`, вы также получаете `find_by_locked`.

Можете определить восклицательный знак (!) в конце динамического поиска, чтобы он вызвал ошибку `ActiveRecord::RecordNotFound`, если не возвратит ни одной записи, например так `Client.find_by_name!("Ryan")`

Если хотите искать и по first_name, и по locked, можете сцепить эти поиски вместе, просто написав "`and`" между полями, например `Client.find_by_first_name_and_locked("Ryan", true)`.

Поиск или создание нового объекта
---------------------------------

Нормально, если вам нужно найти запись или создать ее, если она не существует. Это осуществимо с помощью методов `find_or_create_by` и `find_or_create_by!`.

### `find_or_create_by`

Метод `find_or_create_by` проверяет, существует ли запись с атрибутами. Если нет, то вызывается `create`. Давайте рассмотрим пример.

Предположим, вы хотите найти клиента по имени 'Andy', и, если такого нет, создать его. Это можно сделать, выполнив:

```ruby
Client.find_or_create_by(first_name: 'Andy')
+# => #<Client id: 1, first_name: "Andy", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">
```

SQL, генерируемый этим методом, выглядит так:

```sql
SELECT * FROM clients WHERE (clients.first_name = 'Andy') LIMIT 1
BEGIN
INSERT INTO clients (created_at, first_name, locked, orders_count, updated_at) VALUES ('2011-08-30 05:22:57', 'Andy', 1, NULL, '2011-08-30 05:22:57')
COMMIT
```

`find_or_create_by` возвращает либо уже существующую запись, либо новую запись. В нашем случае, у нас еще нет клиента с именем Andy, поэтому запись будет создана и возвращена.

Новая запись может быть не сохранена в базу данных; это зависит от того, прошли валидации или нет (подобно `create`).

Предположим, мы хотим установить атрибут 'locked' как true, если создаем новую запись, но не хотим включать его в запрос. Таким образом, мы хотим найти клиента по имени "Andy" или, если этот клиент не существует, создать клиента по имени "Andy", который не заблокирован.

Этого можно достичь двумя способами. Первый - это использование `create_with`:

```ruby
Client.create_with(locked: false).find_or_create_by(first_name: 'Andy')
```

Второй способ - это использование блока:

```ruby
Client.find_or_create_by(first_name: 'Andy') do |c|
  c.locked = false
end
```

Блок будет запущен только если клиент был создан. Во второй раз при запуске этого кода блок будет проигнорирован.

### `find_or_create_by!`

Можно также использовать `find_or_create_by!`, чтобы вызвать исключение, если новая запись невалидна. Валидации не раскрываются в этом руководстве, но давайте на момент предположим, что вы временно добавили

```ruby
validates :orders_count, presence: true
```

в модель `Client`. Если попытаетесь создать нового `Client` без передачи `orders_count`, запись будет невалидной и будет вызвано исключение:

```ruby
Client.find_or_create_by!(first_name: 'Andy')
# => ActiveRecord::RecordInvalid: Validation failed: Orders count can't be blank
```

### `find_or_initialize_by`

Метод `find_or_initialize_by` работает похоже на `find_or_create_by`, но он вызывает не `create`, а `new`. Это означает, что новый экземпляр модели будет создан в памяти, но не будет сохранен в базу данных. Продолжая пример с `find_or_create_by`, теперь мы хотим клиента по имени 'Nick':

```ruby
nick = Client.find_or_initialize_by(first_name: 'Nick')
# => <Client id: nil, first_name: "Nick", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">

nick.persisted?
# => false

nick.new_record?
# => true
```

Поскольку объект еще не сохранен в базу данных, создаваемый SQL выглядит так:

```sql
SELECT * FROM clients WHERE (clients.first_name = 'Nick') LIMIT 1
```

Когда захотите сохранить его в базу данных, просто вызовите `save`:

```ruby
nick.save
# => true
```

Поиск с помощью SQL
-------------------

Если вы предпочитаете использовать собственные запросы SQL для поиска записей в таблице, можете использовать `find_by_sql`. Метод `find_by_sql` возвратит массив объектов, даже если лежащий в основе запрос вернет всего лишь одну запись. Например, можете запустить такой запрос:

```ruby
Client.find_by_sql("SELECT * FROM clients
  INNER JOIN orders ON clients.id = orders.client_id
  ORDER clients.created_at desc")
```

`find_by_sql` предоставляет простой способ создания произвольных запросов к базе данных и получения экземпляров объектов.

`select_all`
------------

У `find_by_sql` есть близкий родственник, называемый `connection#select_all`. `select_all` получит объекты из базы данных, используя произвольный SQL, как и в `find_by_sql`, но не создаст их экземпляры. Вместо этого, вы получите массив хэшей, где каждый хэш указывает на запись.

```ruby
Client.connection.select_all("SELECT * FROM clients WHERE id = '1'")
```

`pluck`
-------

`pluck` может быть использован для запроса отдельного столбца или нескольких столбцов из таблицы, лежащей в основе модели. Он принимает имя столбца как аргумент и возвращает массив значений определенного столбца соответствующего типа данных.

```ruby
Client.where(active: true).pluck(:id)
# SELECT id FROM clients WHERE active = 1
# => [1, 2, 3]

Client.uniq.pluck(:role)
# SELECT DISTINCT role FROM clients
# => ['admin', 'member', 'guest']

Client.pluck(:id, :name)
# SELECT clients.id, clients.name FROM clients
# => [[1, 'David'], [2, 'Jeremy'], [3, 'Jose']]
```

`pluck` позволяет заменить такой код

```ruby
Client.select(:id).map { |c| c.id }
# или
Client.select(:id).map(&:id)
# или
Client.select(:id, :name).map { |c| [c.id, c.name] }
```

на

```ruby
Client.pluck(:id)
# или
Client.pluck(:id, :name)
```

`ids`
-----

`ids` может быть использован для сбора всех ID для relation, используя первичный ключ таблицы.

```ruby
Person.ids
# SELECT id FROM people
```

```ruby
class Person < ActiveRecord::Base
  self.primary_key = "person_id"
end

Person.ids
# SELECT person_id FROM people
```

Существование объектов
----------------------

Если вы просто хотите проверить существование объекта, есть метод, называемый `exists?`. Этот метод запрашивает базу данных, используя тот же запрос, что и `find`, но вместо возврата объекта или коллекции объектов, он возвращает или `true`, или `false`.

```ruby
Client.exists?(1)
```

Метод `exists?` также принимает несколько id, при этом возвращает true, если хотя бы хотя бы одна запись из них существует.

```ruby
Client.exists?(1,2,3)
#или
Client.exists?([1,2,3])
```

Более того, `exists` принимает опцию `conditions` подобно этому:

```ruby
Client.where(first_name: 'Ryan').exists?
```

Даже возможно использовать `exists?` без аргументов:

```ruby
Client.exists?
```

Это возвратит `false`, если таблица `clients` пустая, и `true` в противном случае.

Для проверки на существование также можно использовать `any?` и `many?` на модели или relation.

```ruby
# на модели
Post.any?
Post.many?

# на именнованном скоупе
Post.recent.any?
Post.recent.many?

# на relation
Post.where(published: true).any?
Post.where(published: true).many?

# на связи
Post.first.categories.any?
Post.first.categories.many?
```

Вычисления
----------

Этот раздел использует count для примера из [преамбулы](/active-record-query-interface), но описанные опции применяются ко всем подразделам.

Все методы вычисления работают прямо на модели:

```ruby
Client.count
# SELECT count(*) AS count_all FROM clients
```

Или на relation:

```ruby
Client.where(first_name: 'Ryan').count
# SELECT count(*) AS count_all FROM clients WHERE (first_name = 'Ryan')
```

Можете также использовать различные методы поиска на relation для выполнения сложных вычислений:

```ruby
Client.includes("orders").where(first_name: 'Ryan', orders: {status: 'received'}).count
```

Что выполнит:

```sql
SELECT count(DISTINCT clients.id) AS count_all FROM clients
  LEFT OUTER JOIN orders ON orders.client_id = client.id WHERE
  (clients.first_name = 'Ryan' AND orders.status = 'received')
```

### Количество

Если хотите увидеть, сколько записей есть в таблице модели, можете вызвать `Client.count`, и он возвратит число. Если хотите быть более определенным и найти всех клиентов с присутствующим в базе данных возрастом, используйте `Client.count(:age)`.

Про опции смотрите выше "Вычисления".

### Среднее

Если хотите увидеть среднее значение опредененного показателя в одной из ваших таблиц, можно вызвать метод `average` для класса, относящегося к таблице. Вызов этого метода выглядит так:

```ruby
Client.average("orders_count")
```

Это возвратит число (возможно, с плавающей запятой, такое как 3.14159265), представляющее среднее значение поля.
Про опции смотрите выше "Вычисления".

### Минимум

Если хотите найти минимальное значение поля в таблице, можете вызвать метод `minimum` для класса, относящегося к таблице. Вызов этого метода выглядит так:

```ruby
Client.minimum("age")
```

Про опции смотрите выше "Вычисления".

### Максимум

Если хотите найти максимальное значение поля в таблице, можете вызвать метод `maximum` для класса, относящегося к таблице. Вызов этого метода выглядит так:

```ruby
Client.maximum("age")
```

Про опции смотрите выше "Вычисления".

### Сумма

Если хотите найти сумму полей для всех записей в таблице, можете вызвать метод `sum` для класса, относящегося к таблице. Вызов этого метода выглядит так:

```ruby
Client.sum("orders_count")
```

Про опции смотрите выше "Вычисления".

Запуск EXPLAIN
--------------

Можно запустить EXPLAIN на запросах, вызываемых в relations. Например,

```ruby
User.where(id: 1).joins(:posts).explain
```

может выдать в MySQL.

```
EXPLAIN for: SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`id` = 1
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------------+
| id | select_type | table | type  | possible_keys | key     | key_len | ref   | rows | Extra       |
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------------+
|  1 | SIMPLE      | users | const | PRIMARY       | PRIMARY | 4       | const |    1 |             |
|  1 | SIMPLE      | posts | ALL   | NULL          | NULL    | NULL    | NULL  |    1 | Using where |
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------------+
2 rows in set (0.00 sec)
```

Active Record применяет красивое форматирование, эмулирующее оболочку одной из баз данных. Таким образом, запуск того же запроса в адаптере PostgreSQL выдаст вместо этого

```
EXPLAIN for: SELECT "users".* FROM "users" INNER JOIN "posts" ON "posts"."user_id" = "users"."id" WHERE "users"."id" = 1
                                  QUERY PLAN
------------------------------------------------------------------------------
 Nested Loop Left Join  (cost=0.00..37.24 rows=8 width=0)
   Join Filter: (posts.user_id = users.id)
   ->  Index Scan using users_pkey on users  (cost=0.00..8.27 rows=1 width=4)
         Index Cond: (id = 1)
   ->  Seq Scan on posts  (cost=0.00..28.88 rows=8 width=4)
         Filter: (posts.user_id = 1)
(6 rows)
```

Нетерпеливая загрузка может вызвать более одного запроса за раз, и некоторые запросы могут нуждаться в результате предыдущих. Поэтому `explain` фактически запускает запрос, а затем узнает о дальнейших планах по запросам. Например,

```ruby
User.where(id: 1).includes(:posts).explain
```

выдаст в MySQL.

```
EXPLAIN for: SELECT `users`.* FROM `users`  WHERE `users`.`id` = 1
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------+
| id | select_type | table | type  | possible_keys | key     | key_len | ref   | rows | Extra |
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------+
|  1 | SIMPLE      | users | const | PRIMARY       | PRIMARY | 4       | const |    1 |       |
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------+
1 row in set (0.00 sec)

EXPLAIN for: SELECT `posts`.* FROM `posts`  WHERE `posts`.`user_id` IN (1)
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows | Extra       |
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
|  1 | SIMPLE      | posts | ALL  | NULL          | NULL | NULL    | NULL |    1 | Using where |
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
1 row in set (0.00 sec)
```

### Интерпретация EXPLAIN

Интерпретация результатов EXPLAIN находится за рамками этого руководства. Может быть полезной следующая информация:

* SQLite3: [EXPLAIN QUERY PLAN](http://www.sqlite.org/eqp.html)

* MySQL: [EXPLAIN Output Format](http://dev.mysql.com/doc/refman/5.6/en/explain-output.html)

* PostgreSQL: [Using EXPLAIN](http://www.postgresql.org/docs/current/static/using-explain.html)
