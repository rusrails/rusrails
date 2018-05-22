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

Если вы использовали чистый SQL для поиска записей в базе данных, то скорее всего обнаружите, что в Rails есть лучшие способы выполнения тех же операций. Active Record ограждает вас от необходимости использования SQL во многих случаях.

Примеры кода далее в этом руководстве будут относиться к некоторым из этих моделей:

TIP: Все модели используют `id` как первичный ключ, если не указано иное.

```ruby
class Client < ApplicationRecord
  has_one :address
  has_many :orders
  has_and_belongs_to_many :roles
end
```

```ruby
class Address < ApplicationRecord
  belongs_to :client
end
```

```ruby
class Order < ApplicationRecord
  belongs_to :client, counter_cache: true
end
```

```ruby
class Role < ApplicationRecord
  has_and_belongs_to_many :clients
end
```

Active Record выполнит запросы в базу данных за вас, он совместим с большинством СУБД, включая MySQL, MariaDB, PostgreSQL и SQLite. Независимо от того, какая используется СУБД, формат методов Active Record будет всегда одинаковый.

Получение объектов из базы данных
---------------------------------

Для получения объектов из базы данных Active Record предоставляет несколько методов поиска. В каждый метод поиска можно передавать аргументы для выполнения определенных запросов в базу данных без необходимости писать на чистом SQL.

Методы следующие:

* `find`
* `create_with`
* `distinct`
* `eager_load`
* `extending`
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
* `order`
* `preload`
* `readonly`
* `references`
* `reorder`
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
# Ищет клиента с первичным ключом (id) 10.
client = Client.find(10)
# => #<Client id: 10, first_name: "Ryan">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients WHERE (clients.id = 10) LIMIT 1
```

Метод `find` вызывает исключение `ActiveRecord::RecordNotFound`, если соответствующей записи не было найдено.

Этот метод также можно использовать для получения нескольких объектов. Вызовите метод `find` и передайте в него массив первичных ключей. Возвращенным результатом будет массив, содержащий все записи, соответствующие представленным _первичным ключам_. Например:

```ruby
# Найдем клиентов с первичными ключами 1 и 10.
clients = Client.find([1, 10]) # Или даже Client.find(1, 10)
# => [#<Client id: 1, first_name: "Lifo">, #<Client id: 10, first_name: "Ryan">]
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients WHERE (clients.id IN (1,10))
```

#### `take`

Метод `take` получает запись без какого-либо явного упорядочивания. Например:

```ruby
client = Client.take
# => #<Client id: 1, first_name: "Lifo">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients LIMIT 1
```

Метод `take` возвращает `nil`, если ни одной записи не найдено, и исключение не будет вызвано.

В метод `take` можно передать числовой аргумент, чтобы вернуть это количество результатов. Например

```ruby
clients = Client.take(2)
# => [
#   #<Client id: 1, first_name: "Lifo">,
#   #<Client id: 220, first_name: "Sara">
# ]
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients LIMIT 2
```

Метод `take!` ведет себя подобно `take`, за исключением того, что он вызовет `ActiveRecord::RecordNotFound`, если не найдено ни одной соответствующей записи.

TIP: Получаемая запись может отличаться в зависимости от подсистемы хранения СУБД.

#### `first`

Метод `first` находит первую запись, упорядоченную по первичному ключу (по умолчанию). Например:

```ruby
client = Client.first
# => #<Client id: 1, first_name: "Lifo">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients ORDER BY clients.id ASC LIMIT 1
```

Метод `first` возвращает `nil`, если не найдено соответствующей записи, и исключение не вызывается.

Если [скоуп по умолчанию](#applying-a-default-scope) содержит метод order, `first` возвратит первую запись в соответствии с этим упорядочиванием.

В метод `first` можно передать числовой аргумент, чтобы вернуть это количество результатов. Например

```ruby
clients = Client.first(3)
# => [
#   #<Client id: 1, first_name: "Lifo">,
#   #<Client id: 2, first_name: "Fifo">,
#   #<Client id: 3, first_name: "Filo">
# ]
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients ORDER BY clients.id ASC LIMIT 3
```

На коллекции, упорядоченной с помощью `order`, `first` вернет первую запись, упорядоченную по указанному в `order` атрибуту.

```ruby
client = Client.order(:first_name).first
# => #<Client id: 2, first_name: "Fifo">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients ORDER BY clients.first_name ASC LIMIT 1
```

Метод `first!` ведет себя подобно `first`, за исключением того, что он вызовет `ActiveRecord::RecordNotFound`, если не найдено ни одной соответствующей записи.

#### `last`

Метод `last` находит последнюю запись, упорядоченную по первичному ключу (по умолчанию). Например:

```ruby
client = Client.last
# => #<Client id: 221, first_name: "Russel">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients ORDER BY clients.id DESC LIMIT 1
```

Метод `last` возвращает `nil`, если не найдено соответствующей записи, и исключение не вызывается.

Если [скоуп по умолчанию](#applying-a-default-scope) содержит метод order, `last` возвратит последнюю запись в соответствии с этим упорядочиванием.

В метод `last` можно передать числовой аргумент, чтобы вернуть это количество результатов. Например

```ruby
clients = Client.last(3)
# => [
#   #<Client id: 219, first_name: "James">,
#   #<Client id: 220, first_name: "Sara">,
#   #<Client id: 221, first_name: "Russel">
# ]
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients ORDER BY clients.id DESC LIMIT 3
```

На коллекции, упорядоченной с помощью `order`, `last` вернет последнюю запись, упорядоченную по указанному в `order` атрибуту.

```ruby
client = Client.order(:first_name).last
# => #<Client id: 220, first_name: "Sara">
```

SQL эквивалент этого такой:

```sql
SELECT * FROM clients ORDER BY clients.first_name DESC LIMIT 1
```

Метод `last!` ведет себя подобно `last`, за исключением того, что он вызовет `ActiveRecord::RecordNotFound`, если не найдено ни одной соответствующей записи.

#### `find_by`

Метод `find_by` ищет первую запись, соответствующую некоторым условиям. Например:

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

SQL эквивалент выражения выше, следующий:

```sql
SELECT * FROM clients WHERE (clients.first_name = 'Lifo') LIMIT 1
```

Метод `find_by!` ведет себя подобно `find_by`, за исключением того, что он вызовет `ActiveRecord::RecordNotFound`, если не найдено ни одной соответствующей записи. Например:

```ruby
Client.find_by! first_name: 'does not exist'
# => ActiveRecord::RecordNotFound
```

Это эквивалент записи:

```ruby
Client.where(first_name: 'does not exist').take!
```

### Получение нескольких объектов пакетами

Часто необходимо перебрать огромный набор записей, например, когда рассылаем письма всем пользователям или импортируем некоторые данные.

Это может показаться простым:

```ruby
# Это может потребить слишком много памяти, если таблица большая.
User.all.each do |user|
  NewsMailer.weekly(user).deliver_now
end
```

Но этот подход становится очень непрактичным с увеличением размера таблицы, поскольку `User.all.each` говорит Active Record извлечь _таблицу полностью_ за один проход, создать объект модели для каждой строки и держать этот массив в памяти. В реальности, если имеется огромное количество записей, полная коллекция может превысить количество доступной памяти.

Rails предоставляет два метода, которые решают эту проблему путем разделения записей на дружелюбные к памяти пакеты для обработки. Первый метод, `find_each`, получает пакет записей и затем вкладывает _каждую_ запись в блок отдельно как модель. Второй метод, `find_in_batches`, получает пакет записей и затем вкладывает _весь пакет_ в блок как массив моделей.

TIP: Методы `find_each` и `find_in_batches` предназначены для пакетной обработки большого числа записей, которые не поместятся в памяти за раз. Если нужно просто перебрать тысячу записей, более предпочтителен вариант обычных методов поиска.

#### `find_each`

Метод `find_each` получает пакет записей и затем передает _каждую_ запись в блок. В следующем примере `find_each` получает пользователей пакетами по 1000 записей, а затем передает их в блок один за другим:

```ruby
User.find_each do |user|
  NewsMailer.weekly(user).deliver_now
end
```

Этот процесс повторяется, извлекая больше пакетов при необходимости, пока не будут обработаны все записи.

`find_each` работает на классах модели, как показано выше, а также на relation:

```ruby
User.where(weekly_subscriber: true).find_each do |user|
  NewsMailer.weekly(user).deliver_now
end
```

только у них нет упорядочивания, так как методу необходимо собственное упорядочивание для работы.

Если у получателя есть упорядочивание, то поведение зависит от флажка `config.active_record.error_on_ignored_order`. Если true, вызывается `ArgumentError`, в противном случае упорядочивание игнорируется, что является поведением по умолчанию. Это можно переопределить с помощью опции `:error_on_ignore`, описанной ниже.

##### Опции для `find_each`

**`:batch_size`**

Опция `:batch_size` позволяет определить число записей, подлежащих получению в одном пакете, до передачи отдельной записи в блок. Например, для получения 5000 записей в пакете:

```ruby
User.find_each(batch_size: 5000) do |user|
  NewsMailer.weekly(user).deliver_now
end
```

**`:start`**

По умолчанию записи извлекаются в порядке увеличения первичного ключа, который должен быть числом. Опция `:start` позволяет вам настроить первый ID последовательности, когда наименьший ID не тот, что вам нужен. Это может быть полезно, например, если хотите возобновить прерванный процесс пакетирования, предоставив последний обработанный ID как контрольную точку.

Например, чтобы выслать письма только пользователям с первичным ключом, начинающимся от 2000:

```ruby
User.find_each(start: 2000) do |user|
  NewsMailer.weekly(user).deliver_now
end
```

**`:finish`**

Подобно опции `:start`, `:finish` позволяет указать последний ID последовательности, когда наибольший ID не тот, что вам нужен.
Это может быть полезно, например, если хотите запустить процесс пакетирования, используя подмножество записей на основании `:start` и `:finish`

Например, чтобы выслать письма только пользователям с первичным ключом от 2000 до 10000:

```ruby
User.find_each(start: 2000, finish: 10000) do |user|
  NewsMailer.weekly(user).deliver_now
end
```

Другим примером является наличие нескольких воркеров, работающих с одной и той же очередью обработки. Можно было бы обрабатывать каждым воркером 10000 записей, установив подходящие опции `:start` и `:finish` в каждом воркере.

**`:error_on_ignore`**

Переопределяет настройку приложения, указывающую, должна ли быть вызвана ошибка, если в relation присутствует упорядочивание.

#### `find_in_batches`

Метод `find_in_batches` похож на `find_each` тем, что они оба получают пакеты записей. Различие в том, что `find_in_batches` передает в блок _пакеты_ как массив моделей, вместо отдельной модели. Следующий пример передаст в представленный блок массив из 1000 счетов за раз, а в последний блок содержащий все оставшиеся счета:

```ruby
# Передает в add_invoices массив из 1000 счетов за раз.
Invoice.find_in_batches do |invoices|
  export.add_invoices(invoices)
end
```

`find_in_batches` работает на классах модели, как показано выше, а также на relation:

```ruby
Invoice.pending.find_in_batches do |invoices|
  pending_invoices_export.add_invoices(invoices)
end
```

только у них нет упорядочивания, так как методу необходимо собственное упорядочивание для работы.

##### Опции для `find_in_batches`

Метод `find_in_batches` принимает те же опции, что и `find_each`.

Условия
-------

Метод `where` позволяет определить условия для ограничения возвращаемых записей, которые представляют `WHERE`-часть выражения SQL. Условия могут быть заданы как строка, массив или хэш.

### (pure-string-conditions) Чисто строковые условия

Если вы хотите добавить условия в свой поиск, можете просто определить их там, подобно `Client.where("orders_count = '2'")`. Это найдет всех клиентов, где значение поля `orders_count` равно 2.

WARNING: Создание условий в чистой строке подвергает вас риску SQL-инъекций. Например, `Client.where("first_name LIKE '%#{params[:first_name]}%'")` не безопасно. Смотрите следующий раздел для более предпочтительного способа обработки условий с использованием массива.

### (array-conditions) Условия с использованием массива

Что если количество может изменяться, скажем, как аргумент откуда-то извне, возможно даже от пользователя? Поиск тогда принимает такую форму:

```ruby
Client.where("orders_count = ?", params[:orders])
```

Active Record примет первый аргумент в качестве строки условия, а все остальные элементы подставит вместо знаков вопроса `(?)` в ней.

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

TIP: Подробнее об опасности SQL-инъекций можно узнать из руководства [Безопасность приложений на Rails](/ruby-on-rails-security-guide).

#### Местозаполнители в условиях

Подобно тому, как `(?)` заменяют параметры, можно использовать ключи в условиях совместно с соответствующим хэшем ключей/значений:

```ruby
Client.where("created_at >= :start_date AND created_at <= :end_date",
  {start_date: params[:start_date], end_date: params[:end_date]})
```

Читаемость улучшится, в случае если вы используете большое количество переменных в условиях.

### (hash-conditions) Условия с использованием хэша

Active Record также позволяет передавать условия в хэше, что улучшает читаемость синтаксиса условий. В этом случае передается хэш с ключами, соответствующими полям, которые хотите уточнить, и с значениями, которые вы хотите к ним применить:

NOTE: Хэшем можно передать условия проверки только равенства, интервала и подмножества.

#### Условия равенства

```ruby
Client.where(locked: true)
```

Это сгенерирует такой SQL:

```sql
SELECT * FROM clients WHERE (clients.locked = 1)
```

Имя поля также может быть строкой, а не символом:

```ruby
Client.where('locked' => true)
```

В случае отношений belongs_to, может быть использован ключ связи для указания модели, если как значение используется объект Active Record. Этот метод также работает с полиморфными отношениями.

```ruby
Article.where(author: author)
Author.joins(:articles).where(articles: { author: author })
```

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

Если хотите найти записи, используя выражение `IN`, можете передать массив в хэш условий:

```ruby
Client.where(orders_count: [1,3,5])
```

Этот код сгенерирует подобный SQL:

```sql
SELECT * FROM clients WHERE (clients.orders_count IN (1,3,5))
```

### Условия NOT

Запросы `NOT` в SQL могут быть созданы с помощью `where.not`:

```ruby
Client.where.not(locked: true)
```

Другими словами, этот запрос может быть сгенерирован с помощью вызова `where` без аргументов и далее присоединенным `not` с переданными условиями для `where`. Это сгенерирует такой SQL:

```sql
SELECT * FROM clients WHERE (clients.locked != 1)
```

### Условия OR

Условия `OR` между двумя отношениями могут быть построены путем вызова `or` на первом отношении и передачи второго в качестве аргумента.

```ruby
Client.where(locked: true).or(Client.where(orders_count: [1,3,5]))
```

```sql
SELECT * FROM clients WHERE (clients.locked = 1 OR clients.orders_count IN (1,3,5))
```

(ordering) Сортировка
---------------------

Чтобы получить записи из базы данных в определенном порядке, можете использовать метод `order`.

Например, если вы получаете ряд записей и хотите упорядочить их в порядке возрастания поля `created_at` в таблице:

```ruby
Client.order(:created_at)
# ИЛИ
Client.order("created_at")
```

Также можете определить `ASC` или `DESC`:

```ruby
Client.order(created_at: :desc)
# ИЛИ
Client.order(created_at: :asc)
# ИЛИ
Client.order("created_at DESC")
# ИЛИ
Client.order("created_at ASC")
```

Или сортировку по нескольким полям:

```ruby
Client.order(orders_count: :asc, created_at: :desc)
# ИЛИ
Client.order(:orders_count, created_at: :desc)
# ИЛИ
Client.order("orders_count ASC, created_at DESC")
# ИЛИ
Client.order("orders_count ASC", "created_at DESC")
```

Если хотите вызвать `order` несколько раз, последующие сортировки будут добавлены к первой:

```ruby
Client.order("orders_count ASC").order("created_at DESC")
# SELECT * FROM clients ORDER BY orders_count ASC, created_at DESC
```

WARNING: Если используется **MySQL 5.7.5** и выше, то при выборе полей из результирующей выборки с помощью методов, таких как `select`, `pluck` и `ids`; метод `order` вызовет исключение `ActiveRecord::StatementInvalid`, если поля, используемые в выражении `order`, не включены в список выбора. Смотрите следующий раздел по выбору полей из результирующей выборки.

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

Если хотите вытащить только по одной записи для каждого уникального значения в определенном поле, можно использовать `distinct`:

```ruby
Client.select(:name).distinct
```

Это сгенерирует такой SQL:

```sql
SELECT DISTINCT name FROM clients
```

Также можно убрать ограничение уникальности:

```ruby
query = Client.select(:name).distinct
# => Возвратит уникальные имена

query.distinct(false)
# => Возвратит все имена, даже если есть дубликаты
```

Ограничение и смещение
----------------------

Чтобы применить `LIMIT` к SQL, запущенному с помощью `Model.find`, нужно определить `LIMIT`, используя методы `limit` и `offset` на relation.

Используйте `limit` для определения количества записей, которые будут получены, и `offset` - для числа записей, которые будут пропущены до начала возврата записей. Например:

```ruby
Client.limit(5)
```

возвратит максимум 5 клиентов, и, поскольку не определено смещение, будут возвращены первые 5 клиентов в таблице. Выполняемый SQL будет выглядеть подобным образом:

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

Чтобы применить условие `GROUP BY` к `SQL`, можно использовать метод `group`.

Например, если хотите найти коллекцию дат, в которые были созданы заказы:

```ruby
Order.select("date(created_at) as ordered_date, sum(price) as total_price").group("date(created_at)")
```

Это выдаст вам отдельный объект `Order` на каждую дату, для которой были заказы в базе данных.

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT date(created_at) as ordered_date, sum(price) as total_price
FROM orders
GROUP BY date(created_at)
```

### Общее количество сгруппированных элементов

Чтобы получить общее количество сгруппированных элементов одним запросом, вызовите `count` после `group`.

```ruby
Order.group(:status).count
# => { 'awaiting_approval' => 7, 'paid' => 12 }
```

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT COUNT (*) AS count_all, status AS status
FROM "orders"
GROUP BY status
```

Having
------

SQL использует условие `HAVING` для определения условий для полей, указанных в `GROUP BY`. Условие `HAVING`, определенное в SQL, запускается в `Model.find` с использованием метода `having` для поиска.

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

Это возвращает дату и итоговую цену для каждого объекта заказа, сгруппированные по дню, когда они были заказаны, и где цена больше $100.

Переопределяющие условия
------------------------

### `unscope`

Можете указать определенные условия, которые будут убраны, используя метод `unscope`. Например:

```ruby
Article.where('id > 10').limit(20).order('id asc').unscope(:order)
```

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT * FROM articles WHERE id > 10 LIMIT 20

# Оригинальный запрос без `unscope`
SELECT * FROM articles WHERE id > 10 ORDER BY id asc LIMIT 20

```

Также можно убрать определенные условия `where`. Например:

```ruby
Article.where(id: 10, trashed: false).unscope(where: :id)
# SELECT "articles".* FROM "articles" WHERE trashed = 0
```

Relation, использующий `unscope` повлияет на любой relation, в который он слит:

```ruby
Article.order('id asc').merge(Article.unscope(:order))
# SELECT "articles".* FROM "articles"
```

### `only`

Также можно переопределить условия, используя метод `only`. Например:

```ruby
Article.where('id > 10').limit(20).order('id desc').only(:order, :where)
```

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT * FROM articles WHERE id > 10 ORDER BY id DESC

# Оригинальный запрос без `only`
SELECT * FROM articles WHERE id > 10 ORDER BY id DESC LIMIT 20

```

### `reorder`

Метод `reorder` переопределяет сортировку скоупа по умолчанию. Например:

```ruby
class Article < ApplicationRecord
  ..
  ..
  has_many :comments, -> { order('posted_at DESC') }
end

Article.find(10).comments.reorder('name')
```

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT * FROM articles WHERE id = 10 LIMIT 1
SELECT * FROM comments WHERE article_id = 10 ORDER BY name
```

В случае, когда условие `reorder` не было использовано, выполненный SQL будет:

```sql
SELECT * FROM articles WHERE id = 10 LIMIT 1
SELECT * FROM comments WHERE article_id = 10 ORDER BY posted_at DESC
```

### `reverse_order`

Метод `reverse_order` меняет направление условия сортировки, если оно определено:

```ruby
Client.where("orders_count > 10").order(:name).reverse_order
```

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT * FROM clients WHERE orders_count > 10 ORDER BY name DESC
```

Если условие сортировки не было определено в запросе, `reverse_order` сортирует по первичному ключу в обратном порядке:

```ruby
Client.where("orders_count > 10").reverse_order
```

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT * FROM clients WHERE orders_count > 10 ORDER BY clients.id DESC
```

Этот метод не принимает аргументы.

### `rewhere`

Метод `rewhere` переопределяет существующее именованное условие `where`. Например:

```ruby
Article.where(trashed: true).rewhere(trashed: false)
```

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT * FROM articles WHERE `trashed` = 0
```

В случае, когда не используется условие `rewhere`,

```ruby
Article.where(trashed: true).where(trashed: false)
```

выполненный SQL будет следующий:

```sql
SELECT * FROM articles WHERE `trashed` = 1 AND `trashed` = 0
```

Нулевой Relation
----------------

Метод `none` возвращает сцепляемый relation без записей. Любые последующие условия, сцепленные с возвращенным relation, продолжат генерировать пустые relation. Это полезно в случаях, когда необходим сцепляемый отклик на метод или скоуп, который может вернуть пустые результаты.

```ruby
Article.none # возвращает пустой Relation и не вызывает запросов.
```

```ruby
# От метода visible_articles ожидается, что он вернет Relation.
@articles = current_user.visible_articles.where(name: params[:name])

def visible_articles
  case role
  when 'Country Manager'
    Article.where(country: country)
  when 'Reviewer'
    Article.published
  when 'Bad User'
    Article.none # => если бы вернули [] или nil, код поломался бы в этом случае
  end
end
```

Объекты только для чтения
-------------------------

Active Record предоставляет relation метод `readonly` для явного запрета на модификацию любого из возвращаемых объектов. Любая попытка изменить запись, доступную только для чтения, не удастся, вызвав исключение `ActiveRecord::ReadOnlyRecord`.

```ruby
client = Client.readonly.first
client.visits += 1
client.save
```

Так как `client` явно указан как объект доступный только для чтения, выполнение вышеуказанного кода выдаст исключение `ActiveRecord::ReadOnlyRecord` при вызове `client.save` с обновленным значением `visits`.

Блокировка записей для обновления
---------------------------------

Блокировка полезна для предотвращения состояния гонки при обновлении записей в базе данных и обеспечения атомарного обновления.

Active Record предоставляет два механизма блокировки:

* Оптимистическая блокировка
* Пессимистическая блокировка

### Оптимистическая блокировка

Оптимистическая блокировка позволяет нескольким пользователям обращаться к одной и той же записи для редактирования и предполагает минимум конфликтов с данными. Она осуществляет это с помощью проверки, внес ли другой процесс изменения в записи, с тех пор как она была открыта. Если это происходит, вызывается исключение `ActiveRecord::StaleObjectError`, и обновление игнорируется.

**Столбец оптимистической блокировки**

Чтобы начать использовать оптимистическую блокировку, таблица должна иметь столбец, называющийся `lock_version`, с типом integer. Каждый раз, когда запись обновляется, Active Record увеличивает значение `lock_version`, и средства блокирования обеспечивают, что для записи, вызванной дважды, та, которая первая успеет, будет сохранена, а для второй будет вызвано исключение `ActiveRecord::StaleObjectError`. Пример:

```ruby
c1 = Client.find(1)
c2 = Client.find(1)

c1.first_name = "Michael"
c1.save

c2.name = "should fail"
c2.save # вызывает исключение ActiveRecord::StaleObjectError
```

Вы ответственны за разрешение конфликта с помощью обработки исключения и либо отката, либо объединения, либо применения бизнес-логики, необходимой для разрешения конфликта.

Это поведение может быть отключено, если установить `ActiveRecord::Base.lock_optimistically = false`.

Для переопределения имени столбца `lock_version`, `ActiveRecord::Base` предоставляет атрибут класса `locking_column`:

```ruby
class Client < ApplicationRecord
  self.locking_column = :lock_client_column
end
```

### Пессимистическая блокировка

Пессимистическая блокировка использует механизм блокировки, предоставленный лежащей в основе базой данных. Использование `lock` при построении relation применяет эксклюзивную блокировку для выбранных строк. Relations, которые используют `lock`, обычно упакованы внутри transaction для предотвращения условий взаимной блокировки (дедлока).

Например:

```ruby
Item.transaction do
  i = Item.lock.first
  i.name = 'Jones'
  i.save!
end
```

Вышеописанная сессия осуществляет следующие SQL для бэкенда MySQL:

```sql
SQL (0.2ms)   BEGIN
Item Load (0.3ms)   SELECT * FROM `items` LIMIT 1 FOR UPDATE
Item Update (0.4ms)   UPDATE `items` SET `updated_at` = '2009-02-07 18:05:56', `name` = 'Jones' WHERE `id` = 1
SQL (0.8ms)   COMMIT
```

Также можно передать чистый SQL в опцию `lock` для разрешения различных типов блокировок. Например, в MySQL есть выражение, называющееся `LOCK IN SHARE MODE`, которым можно заблокировать запись, но все же разрешить другим запросам читать ее. Чтобы указать это выражения, просто передайте его как опцию блокировки:

```ruby
Item.transaction do
  i = Item.lock("LOCK IN SHARE MODE").find(1)
  i.increment!(:views)
end
```

Если у вас уже имеется экземпляр модели, можно одновременно начать транзакцию и затребовать блокировку, используя следующий код:

```ruby
item = Item.first
item.with_lock do
  # Этот блок вызывается в транзакции,
  # элемент уже заблокирован.
  item.increment!(:views)
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
Author.joins("INNER JOIN posts ON posts.author_id = authors.id AND posts.published = 't'")
```

Это приведет к следующему SQL:

```sql
SELECT authors.* FROM authors INNER JOIN posts ON posts.author_id = authors.id AND posts.published = 't'
```

#### Использование массива/хэша именованных связей

Active Record позволяет использовать имена [связей](/active-record-associations), определенных в модели, как ярлыки для определения условия `JOIN` этих связей при использовании метода `joins`.

Например, рассмотрим следующие модели `Category`, `Article`, `Comment`, `Guest` и `Tag`:

```ruby
class Category < ApplicationRecord
  has_many :articles
end

class Article < ApplicationRecord
  belongs_to :category
  has_many :comments
  has_many :tags
end

class Comment < ApplicationRecord
  belongs_to :article
  has_one :guest
end

class Guest < ApplicationRecord
  belongs_to :comment
end

class Tag < ApplicationRecord
  belongs_to :article
end
```

Сейчас все нижеследующее создаст ожидаемые соединительные запросы с использованием `INNER JOIN`:

##### Соединение одиночной связи

```ruby
Category.joins(:articles)
```

Это создаст:

```sql
SELECT categories.* FROM categories
  INNER JOIN articles ON articles.category_id = categories.id
```

Или, по-русски, "возвратить объект Category для всех категорий со статьями". Обратите внимание, что будут дублирующиеся категории, если более одной статьи имеют одинаковые категорию. Если нужны уникальные категории, можно использовать `Category.joins(:articles).distinct`.

#### Соединение нескольких связей

```ruby
Article.joins(:category, :comments)
```

Это создаст:

```sql
SELECT articles.* FROM articles
  INNER JOIN categories ON categories.id = articles.category_id
  INNER JOIN comments ON comments.article_id = articles.id
```

Или, по-русски, "возвратить все статьи, у которых есть категория и как минимум один комментарий". Отметьте, что статьи с несколькими комментариями будут показаны несколько раз.

##### Соединение вложенных связей (одного уровня)

```ruby
Article.joins(comments: :guest)
```

Это создаст:

```sql
SELECT articles.* FROM articles
  INNER JOIN comments ON comments.article_id = articles.id
  INNER JOIN guests ON guests.comment_id = comments.id
```

Или, по-русски, "возвратить все статьи, в которых есть комментарий, оставленный гостем".

##### Соединение вложенных связей (разных уровней)

```ruby
Category.joins(articles: [{ comments: :guest }, :tags])
```

Это создаст:

```sql
SELECT categories.* FROM categories
  INNER JOIN articles ON articles.category_id = categories.id
  INNER JOIN comments ON comments.article_id = articles.id
  INNER JOIN guests ON guests.comment_id = comments.id
  INNER JOIN tags ON tags.article_id = articles.id
```

Или, по-русски: "возвратить все категории, в которых есть статьи, и в этих статьях есть комментарий, оставленный гостем, а также в этих статьях есть тег".

#### Определение условий в соединительных таблицах

В соединительных таблицах можно определить условия, используя обычные [массивные](/active-record-query-interface#array-conditions) и [строковые](/active-record-query-interface#pure-string-conditions) условия. [Условия с использованием хэша](/active-record-query-interface#hash-conditions) предоставляют специальный синтаксис для определения условий в соединительных таблицах:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Client.joins(:orders).where('orders.created_at' => time_range)
```

Альтернативный и более чистый синтаксис для этого - вложенные хэш-условия:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Client.joins(:orders).where(orders: { created_at: time_range })
```

Будут найдены все клиенты, имеющие созданные вчера заказы, снова используя выражение SQL `BETWEEN`.

### `left_outer_joins`

Если хотите выбрать ряд записей, независимо от того, имеют ли они связанные записи, можно использовать метод `left_outer_joins`.

```ruby
Author.left_outer_joins(:posts).distinct.select('authors.*, COUNT(posts.*) AS posts_count').group('authors.id')
```

Который создаст:

```sql
SELECT DISTINCT authors.*, COUNT(posts.*) AS posts_count FROM "authors"
LEFT OUTER JOIN posts ON posts.author_id = authors.id GROUP BY authors.id
```

Что означает: "возвратить всех авторов и количество их публикаций, независимо от того, имеются ли у них вообще публикации".

Нетерпеливая загрузка связей
----------------------------

Нетерпеливая загрузка - это механизм загрузки связанных записей объекта, возвращаемых `Model.find`, с использованием как можно меньшего количества запросов.

**Проблема N + 1 запроса**

Рассмотрим следующий код, который находит 10 клиентов и выводит их почтовые индексы:

```ruby
clients = Client.limit(10)

clients.each do |client|
  puts client.address.postcode
end
```

На первый взгляд выглядит хорошо. Но проблема лежит в общем количестве выполненных запросов. Вышеупомянутый код выполняет 1 (чтобы найти 10 клиентов) + 10 (каждый на одного клиента для загрузки адреса) = итого **11** запросов.

**Решение проблемы N + 1 запроса**

Active Record позволяет заранее указать все связи, которые должны быть загружены. Это возможно с помощью указания метода `includes` на вызове `Model.find`. Посредством `includes`, Active Record обеспечивает то, что все указанные связи загружаются с использованием минимально возможного количества запросов.

Пересмотрев вышеупомянутую задачу, можно переписать `Client.limit(10)`, чтобы нетерпеливо загрузить адреса:

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

Active Record позволяет нетерпеливо загружать любое количество связей в одном вызове `Model.find` с использованием массива, хэша или вложенного хэша массивов/хэшей с помощью метода `includes`.

#### Массив нескольких связей

```ruby
Article.includes(:category, :comments)
```

Это загрузит все статьи и связанные категорию, и комментарии для каждой статьи.

#### Вложенный хэш связей

```ruby
Category.includes(articles: [{ comments: :guest }, :tags]).find(1)
```

Вышеприведенный код находит категории с id 1 и нетерпеливо загружает все связанные статьи, теги и комментарии каждой статьи, а также гостей, связанных с комментариями.

### Определение условий для нетерпеливой загрузки связей

Хотя Active Record и позволяет определить условия для нетерпеливой загрузки связей точно так же, как и в `joins`, рекомендуем использовать вместо этого [joins](#joining-tables).

Однако, если сделать так, то можно использовать `where` как обычно.

```ruby
Article.includes(:comments).where(comments: { visible: true })
```

Это сгенерирует запрос с ограничением `LEFT OUTER JOIN`, в то время как метод `joins` сгенерировал бы его с использованием функции `INNER JOIN`.

```ruby
  SELECT "articles"."id" AS t0_r0, ... "comments"."updated_at" AS t1_r5 FROM "articles"
    LEFT OUTER JOIN "comments" ON "comments"."article_id" = "articles"."id" WHERE (comments.visible = 1)
```

Если бы не было условия `where`, то сгенерировался бы обычный набор из двух запросов.

NOTE: Использование `where` подобным образом будет работать только, если передавать в него хэш. Для фрагментов SQL необходимо использовать `references` для принуждения соединения таблиц:

```ruby
Article.includes(:comments).where("comments.visible = true").references(:comments)
```

Если, в случае с этим запросом `includes`, не будет ни одного комментария ни для одной статьи, все статьи все равно будут загружены. При использовании `joins` (INNER JOIN), соединительные условия **должны** соответствовать, иначе ни одной записи не будет возвращено.

NOTE: Если связь нетерпеливо загружена как часть join, любые поля из произвольного выражения select не будут присутствовать в загруженных моделях. Это так, потому что это избыточность, которая должна появиться или в родительской модели, или в дочерней.

(scopes) Скоупы
---------------

Скоупинг позволяет задавать часто используемые запросы, к которым можно обращаться как к вызовам метода в связанных объектах или моделях. С помощью этих скоупов можно использовать каждый ранее раскрытый метод, такой как `where`, `joins` и `includes`. Все методы скоупов возвращают объект `ActiveRecord::Relation`, который позволяет вызывать на нем дополнительные методы (такие как другие скоупы).

Для определения простого скоупа мы используем метод `scope` внутри класса, передав запрос, который хотим запустить при вызове этого скоупа:

```ruby
class Article < ApplicationRecord
  scope :published, -> { where(published: true) }
end
```

Это в точности то же самое, что определение метода класса, и то, что именно вы используете, является вопросом профессионального предпочтения:

```ruby
class Article < ApplicationRecord
  def self.published
    where(published: true)
  end
end
```

Скоупы также сцепляются с другими скоупами:

```ruby
class Article < ApplicationRecord
  scope :published,               -> { where(published: true) }
  scope :published_and_commented, -> { published.where("comments_count > 0") }
end
```

Для вызова скоупа `published`, можно вызвать его либо на классе:

```ruby
Article.published # => [опубликованные статьи]
```

Либо на связи, состоящей из объектов `Article`:

```ruby
category = Category.first
category.articles.published # => [опубликованные статьи, принадлежащие этой категории]
```

### Передача аргумента

Скоуп может принимать аргументы:

```ruby
class Article < ApplicationRecord
  scope :created_before, ->(time) { where("created_at < ?", time) }
end
```

Вызывайте скоуп, как будто это метод класса:

```ruby
Article.created_before(Time.zone.now)
```

Однако, это всего лишь дублирование функциональности, которая должна быть предоставлена методом класса.

```ruby
class Article < ApplicationRecord
  def self.created_before(time)
    where("created_at < ?", time)
  end
end
```

Использование метода класса - более предпочтительный способ принятию аргументов скоупом. Эти методы также будут доступны на связанных объектах:

```ruby
category.articles.created_before(time)
```

### Использование условий

Ваши скоупы могут использовать условия:

```ruby
class Article < ApplicationRecord
  scope :created_before, ->(time) { where("created_at < ?", time) if time.present? }
end
```

Подобно остальным примерам, это ведет себя подобно методу класса.

```ruby
class Article < ApplicationRecord
  def self.created_before(time)
    where("created_at < ?", time) if time.present?
  end
end
```

Однако, имеется одно важное предостережение: скоуп всегда должен возвращать объект `ActiveRecord::Relation`, даже если условие вычисляется `false`, в отличие от метода класса, возвращающего `nil`. Это может вызвать `NoMethodError` при сцеплении методов класса с условиями, если одно из условий вернет `false`.

### (applying-a-default-scope) Применение скоупа по умолчанию

Если хотите, чтобы скоуп был применен ко всем запросам модели, можно использовать метод `default_scope` в самой модели.

```ruby
class Client < ApplicationRecord
  default_scope { where("removed_at IS NULL") }
end
```

Когда запросы для этой модели будут выполняться, запрос SQL теперь будет выглядеть примерно так:

```sql
SELECT * FROM clients WHERE removed_at IS NULL
```

Если необходимо сделать более сложные вещи со скоупом по умолчанию, альтернативно его можно определить как метод класса:

```ruby
class Client < ApplicationRecord
  def self.default_scope
    # Должен возвращать ActiveRecord::Relation.
  end
end
```

NOTE: `default_scope` также применяется при создании записи, когда аргументы скоупа передаются как `Hash`. Он не применяется при обновлении записи. То есть:

```ruby
class Client < ApplicationRecord
  default_scope { where(active: true) }
end

Client.new          # => #<Client id: nil, active: true>
Client.unscoped.new # => #<Client id: nil, active: nil>
```

Имейте в виду, что когда передаются в формате `Array`, аргументы запроса `default_scope` не могут быть преобразованы в `Hash` для назначения атрибутов по умолчанию. То есть:

```ruby
class Client < ApplicationRecord
  default_scope { where("active = ?", true) }
end

Client.new # => #<Client id: nil, active: nil>
```

### Объединение скоупов

Подобно условиям `where`, скоупы объединяются с использованием `AND`.

```ruby
class User < ApplicationRecord
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.active.inactive
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active' AND "users"."state" = 'inactive'
```

Можно комбинировать условия `scope` и `where`, и результирующий sql будет содержать все условия, соединенные с помощью `AND`.

```ruby
User.active.where(state: 'finished')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active' AND "users"."state" = 'finished'
```

Если необходимо, чтобы сработало только последнее условие `where`, тогда можно использовать `Relation#merge`.

```ruby
User.active.merge(User.inactive)
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

Важным предостережением является то, что `default_scope` переопределяется условиями `scope` и `where`.

```ruby
class User < ApplicationRecord
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

Как видите, `default_scope` объединяется как со `scope`, так и с `where` условиями.

### Удаление всех скоупов

Если хотите удалить скоупы по какой-то причине, можете использовать метод `unscoped`. Это особенно полезно, если в модели определен `default_scope`, и он не должен быть применен для конкретно этого запроса.

```ruby
Client.unscoped.load
```

Этот метод удаляет все скоупы и выполняет обычный запрос к таблице.

```ruby
Client.unscoped.all
# SELECT "clients".* FROM "clients"

Client.where(published: false).unscoped.all
# SELECT "clients".* FROM "clients"
```

`unscoped` также может принимать блок.

```ruby
Client.unscoped {
  Client.created_before(Time.zone.now)
}
```

(dynamic-finders) Динамический поиск
------------------------------------

Для каждого поля (также называемого атрибутом), определенного в вашей таблице, Active Record предоставляет метод поиска. Например, если есть поле `first_name` в вашей модели `Client`, вы автоматически получаете `find_by_first_name` от Active Record. Если также есть поле `locked` в модели `Client`, вы также получаете `find_by_locked` метод.

Можете определить восклицательный знак (`!`) в конце динамического поиска, чтобы он вызвал ошибку `ActiveRecord::RecordNotFound`, если не возвратит ни одной записи, например так `Client.find_by_name!("Ryan")`

Если хотите искать и по first_name, и по locked, можете сцепить эти поиски вместе, просто написав "`and`" между полями, например, `Client.find_by_first_name_and_locked("Ryan", true)`.

Enum
----

Макрос `enum` связывает числовой столбец с набором возможных значений.

```ruby
class Book < ApplicationRecord
  enum availability: [:available, :unavailable]
end
```

Это автоматически создаст соответствующие [скоупы](#scopes) для запроса модели. Также добавляются методы для перехода между состояниями и запроса текущего состояния.

```ruby
# Оба примера ниже запрашивают только доступные книги.
Book.available
# или
Book.where(availability: :available)

book = Book.new(availability: :available)
book.available?   # => true
book.unavailable! # => true
book.available?   # => false
```

Полную документацию об enum можно прочитать в [документации Rails API](http://api.rubyonrails.org/classes/ActiveRecord/Enum.html).

(Method Chaining) Цепочки методов
---------------------------------

В Active Record есть полезный приём программирования [Method Chaining](https://en.wikipedia.org/wiki/Method_chaining),
который позволяет нам комбинировать множество Active Record методов.

Можно сцепить несколько методов в единое выражение, если предыдущий вызываемый метод возвращает
`ActiveRecord::Relation`, такие как `all`, `where` и `joins`. Методы, которые возвращают одиночный объект
(смотрите раздел [Получение одиночного объекта](#poluchenie-odinochnogo-ob-ekta)) должны вызываться в конце.

Ниже представлены несколько примеров. Это руководство не покрывает все возможности, а только некоторые, для ознакомления.
Когда вызывается Active Record метод, запрос не сразу генерируется и отправляется в базу,
это происходит только тогда, когда данные реально необходимы. Таким образом, каждый пример ниже генерирует только один запрос.

### Получение отфильтрованных данных из нескольких таблиц

```ruby
Person
  .select('people.id, people.name, comments.text')
  .joins(:comments)
  .where('comments.created_at > ?', 1.week.ago)
```

Результат должен быть примерно следующим:

```sql
SELECT people.id, people.name, comments.text
FROM people
INNER JOIN comments
  ON comments.person_id = people.id
WHERE comments.created_at > '2015-01-01'
```

### Получение определённых данных из нескольких таблиц

```ruby
Person
  .select('people.id, people.name, companies.name')
  .joins(:company)
  .find_by('people.name' => 'John') # это должно быть в конце
```

Выражение выше, сгенерирует следующий SQL-запрос:

```sql
SELECT people.id, people.name, companies.name
FROM people
INNER JOIN companies
  ON companies.person_id = people.id
WHERE people.name = 'John'
LIMIT 1
```

NOTE: Обратите внимание, что если запросу соответствует несколько записей, `find_by` вернет только первую запись и проигнорирует остальные (смотрите `LIMIT 1` выше).

Поиск или создание нового объекта
---------------------------------

Часто бывает, что вам нужно найти запись или создать ее, если она не существует. Вы можете сделать это с помощью методов `find_or_create_by` и `find_or_create_by!`.

### `find_or_create_by`

Метод `find_or_create_by` проверяет, существует ли запись с определенными атрибутами. Если нет, то вызывается `create`. Давайте рассмотрим пример.

Предположим, вы хотите найти клиента по имени 'Andy', и, если такого нет, создать его. Это можно сделать, выполнив:

```ruby
Client.find_or_create_by(first_name: 'Andy')
# => #<Client id: 1, first_name: "Andy", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">
```

SQL, генерируемый этим методом, будет выглядеть так:

```sql
SELECT * FROM clients WHERE (clients.first_name = 'Andy') LIMIT 1
BEGIN
INSERT INTO clients (created_at, first_name, locked, orders_count, updated_at) VALUES ('2011-08-30 05:22:57', 'Andy', 1, NULL, '2011-08-30 05:22:57')
COMMIT
```

`find_or_create_by` возвращает либо уже существующую запись, либо новую запись. В нашем случае, у нас еще нет клиента с именем Andy, поэтому запись будет создана и возвращена.

Новая запись может быть не сохранена в базу данных; это зависит от того, прошли валидации или нет (подобно `create`).

Предположим, мы хотим установить атрибут 'locked' как `false`, если создаем новую запись, но не хотим включать его в запрос. Таким образом, мы хотим найти клиента по имени "Andy" или, если этот клиент не существует, создать клиента по имени "Andy", который не заблокирован.

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

Блок будет выполнен, только если клиент был создан. Во второй раз, при запуске этого кода, блок будет проигнорирован.

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

Метод `find_or_initialize_by` работает похоже на `find_or_create_by`, но он вызывает не `create`, а `new`. Это означает, что новый экземпляр модели будет создан в памяти, но не будет сохранен в базу данных. Продолжая пример с `find_or_create_by`, теперь нам нужен клиент по имени 'Nick':

```ruby
nick = Client.find_or_initialize_by(first_name: 'Nick')
# => #<Client id: nil, first_name: "Nick", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">

nick.persisted?
# => false

nick.new_record?
# => true
```

Поскольку объект еще не сохранен в базу данных, сгенерированный SQL выглядит так:

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
  ORDER BY clients.created_at desc")
# =>  [
#   #<Client id: 1, first_name: "Lucas" >,
#   #<Client id: 2, first_name: "Jan" >,
#   ...
# ]
```

`find_by_sql` предоставляет простой способ создания произвольных запросов к базе данных и получения экземпляров объектов.

### `select_all`

У `find_by_sql` есть близкий родственник, называемый `connection#select_all`. `select_all` получит объекты из базы данных, используя произвольный SQL, как и в `find_by_sql`, но не создаст их экземпляры. Этот метод вернет экземпляр класса `ActiveRecord::Result` и вызвав `to_hash` на этом объекте вернет массив хэшей, где каждый хэш указывает на запись.

```ruby
Client.connection.select_all("SELECT first_name, created_at FROM clients WHERE id = '1'").to_hash
# => [
#   {"first_name"=>"Rafael", "created_at"=>"2012-11-10 23:23:45.281189"},
#   {"first_name"=>"Eileen", "created_at"=>"2013-12-09 11:22:35.221282"}
# ]
```

### `pluck`

`pluck` может быть использован для запроса с одним или несколькими столбцами из таблицы, лежащей в основе модели. Он принимает список имен столбцов как аргумент и возвращает массив значений определенных столбцов соответствующего типа данных.

```ruby
Client.where(active: true).pluck(:id)
# SELECT id FROM clients WHERE active = 1
# => [1, 2, 3]

Client.distinct.pluck(:role)
# SELECT DISTINCT role FROM clients
# => ['admin', 'member', 'guest']

Client.pluck(:id, :name)
# SELECT clients.id, clients.name FROM clients
# => [[1, 'David'], [2, 'Jeremy'], [3, 'Jose']]
```

`pluck` позволяет заменить такой код:

```ruby
Client.select(:id).map { |c| c.id }
# или
Client.select(:id).map(&:id)
# или
Client.select(:id, :name).map { |c| [c.id, c.name] }
```

на:

```ruby
Client.pluck(:id)
# или
Client.pluck(:id, :name)
```

В отличие от `select`, `pluck` непосредственно конвертирует результат запроса в массив Ruby, без создания объектов `ActiveRecord`. Это может означать лучшую производительность для больших или часто используемых запросов. Однако, любые переопределения методов в модели будут недоступны. Например:

```ruby
class Client < ApplicationRecord
  def name
    "I am #{super}"
  end
end

Client.select(:name).map &:name
# => ["I am David", "I am Jeremy", "I am Jose"]

Client.pluck(:name)
# => ["David", "Jeremy", "Jose"]
```

Более того, в отличие от `select` и других скоупов `Relation`, `pluck` вызывает немедленный запрос, и поэтому не может быть соединен с любыми последующими скоупами, хотя он может работать со скоупами, подключенными ранее:

```ruby
Client.pluck(:name).limit(1)
# => NoMethodError: undefined method `limit' for #<Array:0x007ff34d3ad6d8>

Client.limit(1).pluck(:name)
# => ["David"]
```

### `ids`

`ids` может быть использован для сбора всех ID для relation, используя первичный ключ таблицы.

```ruby
Person.ids
# SELECT id FROM people
```

```ruby
class Person < ApplicationRecord
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

Метод `exists?` также принимает несколько значений, при этом возвращает `true`, если хотя бы одна из этих записей существует.

```ruby
Client.exists?(id: [1,2,3])
# или
Client.exists?(name: ['John', 'Sergei'])
```

Даже возможно использовать `exists?` без аргументов на модели или relation:

```ruby
Client.where(first_name: 'Ryan').exists?
```

Пример выше вернет `true`, если есть хотя бы один клиент с `first_name` 'Ryan', и `false` в противном случае.

```ruby
Client.exists?
```

Это возвратит `false`, если таблица `clients` пустая, и `true` в противном случае.

Для проверки на существование также можно использовать `any?` и `many?` на модели или relation.

```ruby
# на модели
Article.any?
Article.many?

# на именованном скоупе
Article.recent.any?
Article.recent.many?

# на relation
Article.where(published: true).any?
Article.where(published: true).many?

# на связи
Article.first.categories.any?
Article.first.categories.many?
```

Вычисления
----------

Этот раздел использует count для примера в этой преамбуле, но описанные опции применяются ко всем подразделам.

Все методы вычисления работают прямо на модели:

```ruby
Client.count
# SELECT COUNT(*) FROM clients
```

Или на relation:

```ruby
Client.where(first_name: 'Ryan').count
# SELECT COUNT(*) FROM clients WHERE (first_name = 'Ryan')
```

Можно также использовать различные методы поиска на relation для выполнения сложных вычислений:

```ruby
Client.includes("orders").where(first_name: 'Ryan', orders: { status: 'received' }).count
```

Что выполнит:

```sql
SELECT COUNT(DISTINCT clients.id) FROM clients
  LEFT OUTER JOIN orders ON orders.client_id = clients.id
  WHERE (clients.first_name = 'Ryan' AND orders.status = 'received')
```

### Количество

Если хотите увидеть, сколько записей есть в таблице модели, можете вызвать `Client.count`, и он возвратит число. Если хотите быть более определенным и найти всех клиентов с присутствующим в базе данных возрастом, используйте `Client.count(:age)`.

Про опции смотрите выше в разделе [Вычисления](#vychisleniya).

### Среднее

Если хотите увидеть среднее значение определенного показателя в одной из ваших таблиц, можно вызвать метод `average` для класса, относящегося к таблице. Вызов этого метода выглядит так:

```ruby
Client.average("orders_count")
```

Это возвратит число (возможно, с плавающей запятой, такое как 3.14159265), представляющее среднее значение поля.

Про опции смотрите выше в разделе [Вычисления](#vychisleniya).

### Минимум

Если хотите найти минимальное значение поля в таблице, можете вызвать метод `minimum` для класса, относящегося к таблице. Вызов этого метода выглядит так:

```ruby
Client.minimum("age")
```

Про опции смотрите выше в разделе [Вычисления](#vychisleniya).

### Максимум

Если хотите найти максимальное значение поля в таблице, можете вызвать метод `maximum` для класса, относящегося к таблице. Вызов этого метода выглядит так:

```ruby
Client.maximum("age")
```

Про опции смотрите выше в разделе [Вычисления](#vychisleniya).

### Сумма

Если хотите найти сумму полей для всех записей в таблице, можете вызвать метод `sum` для класса, относящегося к таблице. Вызов этого метода выглядит так:

```ruby
Client.sum("orders_count")
```

Про опции смотрите выше в разделе [Вычисления](#vychisleniya).

Запуск EXPLAIN
--------------

Можно запустить EXPLAIN на запросах, вызываемых в relations. Например,

```ruby
User.where(id: 1).joins(:articles).explain
```

может выдать

```
EXPLAIN for: SELECT `users`.* FROM `users` INNER JOIN `articles` ON `articles`.`user_id` = `users`.`id` WHERE `users`.`id` = 1
+----+-------------+----------+-------+---------------+
| id | select_type | table    | type  | possible_keys |
+----+-------------+----------+-------+---------------+
|  1 | SIMPLE      | users    | const | PRIMARY       |
|  1 | SIMPLE      | articles | ALL   | NULL          |
+----+-------------+----------+-------+---------------+
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
EXPLAIN for: SELECT "users".* FROM "users" INNER JOIN "articles" ON "articles"."user_id" = "users"."id" WHERE "users"."id" = 1
                                  QUERY PLAN
------------------------------------------------------------------------------
 Nested Loop Left Join  (cost=0.00..37.24 rows=8 width=0)
   Join Filter: (articles.user_id = users.id)
   ->  Index Scan using users_pkey on users  (cost=0.00..8.27 rows=1 width=4)
         Index Cond: (id = 1)
   ->  Seq Scan on articles  (cost=0.00..28.88 rows=8 width=4)
         Filter: (articles.user_id = 1)
(6 rows)
```

Нетерпеливая загрузка может вызвать более одного запроса за раз, и некоторым запросам могут потребоваться результаты предыдущих. Поэтому `explain` фактически выполняет запрос, а затем запрашивает планы запросов. Например,

```ruby
User.where(id: 1).includes(:articles).explain
```

выдаст

```
EXPLAIN for: SELECT `users`.* FROM `users`  WHERE `users`.`id` = 1
+----+-------------+-------+-------+---------------+
| id | select_type | table | type  | possible_keys |
+----+-------------+-------+-------+---------------+
|  1 | SIMPLE      | users | const | PRIMARY       |
+----+-------------+-------+-------+---------------+
+---------+---------+-------+------+-------+
| key     | key_len | ref   | rows | Extra |
+---------+---------+-------+------+-------+
| PRIMARY | 4       | const |    1 |       |
+---------+---------+-------+------+-------+

1 row in set (0.00 sec)

EXPLAIN for: SELECT `articles`.* FROM `articles`  WHERE `articles`.`user_id` IN (1)
+----+-------------+----------+------+---------------+
| id | select_type | table    | type | possible_keys |
+----+-------------+----------+------+---------------+
|  1 | SIMPLE      | articles | ALL  | NULL          |
+----+-------------+----------+------+---------------+
+------+---------+------+------+-------------+
| key  | key_len | ref  | rows | Extra       |
+------+---------+------+------+-------------+
| NULL | NULL    | NULL |    1 | Using where |
+------+---------+------+------+-------------+


1 row in set (0.00 sec)
```

для MySQL и MariaDB.

### Интерпретация EXPLAIN

Интерпретация результатов EXPLAIN находится за рамками этого руководства. Может быть полезной следующая информация:

* SQLite3: [EXPLAIN QUERY PLAN](http://www.sqlite.org/eqp.html)

* MySQL: [EXPLAIN Output Format](http://dev.mysql.com/doc/refman/5.7/en/explain-output.html)

* MariaDB: [EXPLAIN](https://mariadb.com/kb/en/mariadb/explain/)

* PostgreSQL: [Using EXPLAIN](https://postgrespro.ru/docs/postgrespro/current/using-explain)
