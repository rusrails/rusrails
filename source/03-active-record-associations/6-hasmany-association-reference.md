# Подробная информация по связи has_many

Связь `has_many` создает отношение один-ко-многим с другой моделью. В терминах базы данных эта связь говорит, что другой класс будет иметь внешний ключ, относящийся к экземплярам этого класса.

### Добавляемые методы

Когда объявляете связь `has_many`, объявляющий класс автоматически получает 14 методов, относящихся к связи:
* `collection(force_reload = false)`
* `collection<<(object, ...)`
* `collection.delete(object, ...)`
* `collection.destroy(object, ...)`
* `collection=objects`
* `collection_singular_ids`
* `collection_singular_ids=ids`
* `collection.clear`
* `collection.empty?`
* `collection.size`
* `collection.find(...)`
* `collection.where(...)`
* `collection.exists?(...)`
* `collection.build(attributes = {}, ...)`
* `collection.create(attributes = {})`

Во всех этих методах `collection` заменяется символом, переданным как первый аргумент в `has_many`, и `collection_singular` заменяется версией в единственном числе этого символа. Например, имеем объявление:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders
end
```

Каждый экземпляр модели customer будет иметь эти методы:

```ruby
orders(force_reload = false)
orders<<(object, ...)
orders.delete(object, ...)
orders.destroy(object, ...)
orders=objects
order_ids
order_ids=ids
orders.clear
orders.empty?
orders.size
orders.find(...)
orders.where(...)
orders.exists?(...)
orders.build(attributes = {}, ...)
orders.create(attributes = {})
```

#### `collection(force_reload = false)`

Метод `collection` возвращает массив всех связанных объектов. Если нет связанных объектов, он возвращает пустой массив.

```ruby
@orders = @customer.orders
```

#### `collection<<(object, ...)`

Метод `collection<<` добавляет один или более объектов в коллекцию, устанавливая их внешние ключи равными первичному ключу вызывающей модели.

```ruby
@customer.orders << @order1
```

#### `collection.delete(object, ...)`

Метод `collection.delete` убирает один или более объектов из коллекции, установив их внешние ключи в `NULL`.

```ruby
@customer.orders.delete(@order1)
```

WARNING: Объекты будут в дополнение уничтожены, если связаны с `dependent: :destroy`, и удалены, если они связаны с `dependent: :delete_all`.

#### `collection.destroy(object, ...)`

Метод `collection.destroy` убирает один или более объектов из коллекции, выполняя `destroy` для каждого объекта.

```ruby
@customer.orders.destroy(@order1)
```

WARNING: Объекты будут _всегда_ удаляться из базы данных, игнорируя опцию `:dependent`.

#### `collection=objects`

Метод `collection=` делает коллекцию содержащей только представленные объекты, добавляя и удаляя по мере необходимости.

#### `collection_singular_ids`

Метод `collection_singular_ids` возвращает массив id объектов в коллекции.

```ruby
@order_ids = @customer.order_ids
```

#### `collection_singular_ids=ids`

Метод `collection_singular_ids=` делает коллекцию содержащей только объекты, идентифицированные представленными значениями первичного ключа, добавляя и удаляя по мере необходимости.

#### `collection.clear`

Метод `collection.clear` убирает каждый объект из коллекции. Это уничтожает связанные объекты, если они связаны с `dependent: :destroy`, удаляет их непосредственно из базы данных, если `dependent: :delete_all`, и в противном случае устанавливает их внешние ключи в `NULL`.

#### `collection.empty?`

Метод `collection.empty?` возвращает `true`, если коллекция не содержит каких-либо связанных объектов.

```ruby
<% if @customer.orders.empty? %>
  No Orders Found
<% end %>
```

#### `collection.size`

Метод `collection.size` возвращает количество объектов в коллекции.

```ruby
@order_count = @customer.orders.size
```

#### `collection.find(...)`

Метод `collection.find` ищет объекты в коллекции. Он использует тот же синтаксис и опции, что и `ActiveRecord::Base.find`.

```ruby
@open_orders = @customer.orders.find(1)
```

#### `collection.where(...)`

Метод `collection.where` ищет объекты в коллекции, основываясь на переданных условиях, но объекты загружаются лениво, что означает, что база данных запрашивается только когда происходит доступ к объекту(-там).

```ruby
@open_orders = @customer.orders.where(open: true) # Пока нет запроса
@open_order = @open_orders.first # Теперь база данных будет запрошена
```

#### `collection.exists?(...)`

Метод `collection.exists?` проверяет, существует ли в коллекции объект, отвечающий представленным условиям. Он использует тот же синтаксис и опции, что и `ActiveRecord::Base.exists?`.

#### `collection.build(attributes = {}, ...)`

Метод `collection.build` возвращает один или более объектов связанного типа. Эти объекты будут экземплярами с переданными атрибутами, будет создана ссылка через их внешние ключи, но связанные объекты _не_ будут пока сохранены.

```ruby
@order = @customer.orders.build(order_date: Time.now,
                                order_number: "A12345")
```

#### `collection.create(attributes = {})`

Метод `collection.create` возвращает новый объект связанного типа. Этот объект будет экземпляром с переданными атрибутами, будет создана ссылка через его внешний ключ, и, если он пройдет валидации, определенные в связанной модели, связанный объект _будет_ сохранен

```ruby
@order = @customer.orders.create(order_date: Time.now,
                                 order_number: "A12345")
```

### Опции для `has_many`

Хотя Rails использует разумные значения по умолчанию, работающие во многих ситуациях, бывают случаи, когда хочется изменить поведение связи `has_many`. Такая настройка легко выполнима с помощью передачи опций при создании связи. Например, эта связь использует две такие опции:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, dependent: :delete_all, validate: :false
end
```

Связь `has_many` поддерживает эти опции:

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

Установка опции `:as` показывает, что это полиморфная связь. Полиморфные связи подробно рассматривались [ранее](/active-record-associations/the-types-of-associations-2#polymorphic-associations).

#### `:autosave`

Если установить опцию `:autosave` в `true`, Rails сохранит любые загруженные члены и уничтожит члены, помеченные для уничтожения, всякий раз, когда вы сохраняете родительский объект.

#### `:class_name`

Если имя другой модели не может быть произведено из имени связи, можете использовать опцию `:class_name` для предоставления имени модели. Например, если покупатель имеет много заказов, но фактическое имя модели, содержащей заказы это `Transaction`, можете установить это следующим образом:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, class_name: "Transaction"
end
```

#### `:dependent`

Управляет тем, что произойдет со связанными объектами, когда его владелец будет уничтожен:

* `:destroy` приведет к тому, что связанные объекты также будут уничтожены
* `:delete` приведет к тому, что связанные объекты будут удалены из базы данных напрямую (таким образом не будут выполнены колбэки)
* `:nullify` приведет к тому, что внешние ключи будет установлен `NULL`. Колбэки не запускаются.
* `:restrict_with_exception` приведет к вызову исключения, если есть какой-нибудь связанный объект
* `:restrict_with_error` приведет к ошибке, добавляемой к владельцу, если есть какой-нибудь связанный объект

NOTE: Эта опция игнорируется при использовании на связи опции `:through`.

#### `:foreign_key`

По соглашению Rails предполагает, что столбец, используемый для хранения внешнего ключа в этой модели, имеет имя модели с добавленным суффиксом `_id`. Опция `:foreign_key` позволяет установить имя внешнего ключа явно:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, foreign_key: "cust_id"
end
```

TIP: В любом случае, Rails не создаст столбцы внешнего ключа за вас. Вам необходимо явно определить их в своих миграциях.

#### `:inverse_of`

Опция `:inverse_of` определяет имя связи `belongs_to`, являющейся обратной для этой связи. Не работает в комбинации с опциями `:through` или `:as`.

```ruby
class Supplier < ActiveRecord::Base
  has_many :orders, inverse_of: :customer
end

class Account < ActiveRecord::Base
  belongs_to :customer, inverse_of: :orders
end
```

#### `:primary_key`

По соглашению, Rails предполагает, что столбец, используемый для хранения первичного ключа, это `id`. Вы можете переопределить это и явно определить первичный ключ с помощью опции `:primary_key`.

#### `:source`

Опция `:source` oпределяет имя источника связи для связи `has_many :through`. Эту опцию нужно использовать, только если имя источника связи не может быть автоматически выведено из имени связи.

#### `:source_type`

Опция `:source_type` определяет тип источника связи для связи `has_many :through`, который действует при полиморфной связи.

#### `:through`

Опция `:through` определяет соединительную модель, через которую выполняется запрос. Связи `has_many :through` предоставляют способ осуществления отношений многие-ко-многим, как обсуждалось [ранее в этом руководстве](/active-record-associations/the-types-of-associations-1#the-has-many-through-association).

#### `:validate`

Если установите опцию `:validate` в `false`, тогда связанные объекты не будут проходить валидацию всякий раз, когда вы сохраняете этот объект. По умолчанию она равна `true`: связанные объекты проходят валидацию, когда этот объект сохраняется.

### Скоупы для `has_many`

Иногда хочется настроить запрос, используемый `has_many`. Такая настройка может быть достигнута с помощью блока скоупа. Например:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, -> { where processed: true }
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
* `uniq`

#### `where`

Метод `where` позволяет определить условия, которым должен отвечать связанный объект.

```ruby
class Customer < ActiveRecord::Base
  has_many :confirmed_orders, -> { where "confirmed = 1" },
    class_name: "Order"
end
```

Также можно задать условия хэшем:

```ruby
class Customer < ActiveRecord::Base
  has_many :confirmed_orders, -> { where confirmed: true },
                              class_name: "Order"
end
```

При использовании опции `where` хэшем, при создание записи через эту связь будет автоматически применен скоуп с использованием хэша. В этом случае при использовании `@customer.confirmed_orders.create` или `@customer.confirmed_orders.build` будут созданы заказы, в которых столбец confirmed будет иметь значение `true`.

#### `extending`

Метод `extending` определяет именнованый модуль для расширения прокси связи. Расширения связей подробно обсуждаются [позже в этом руководстве](/active-record-associations/association-callbacks-and-extensions).

#### `group`

Метод `group` доставляет имя атрибута, по которому группируется результирующий набор, используя выражение `GROUP BY` в поисковом SQL.

```ruby
class Customer < ActiveRecord::Base
  has_many :line_items, -> { group 'orders.id' },
                        through: :orders
end
```

#### `includes`

Можете использовать метод `include` для определения связей второго порядка, которые должны быть нетерпеливо загружены, когда эта связь используется. Например, рассмотрим эти модели:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders
end

class Order < ActiveRecord::Base
  belongs_to :customer
  has_many :line_items
end

class LineItem < ActiveRecord::Base
  belongs_to :order
end
```

Если вы часто получаете позиции прямо из покупателей (`@customer.orders.line_items`), тогда можете сделать свой код более эффективным, включив позиции в связь от покупателей к заказам:

```ruby
class Customer < ActiveRecord::Base
  as_many :orders, -> { includes :line_items }
end

class Order < ActiveRecord::Base
  belongs_to :customer
  has_many :line_items
end

class LineItem < ActiveRecord::Base
  belongs_to :order
end
```

#### `limit`

Метод `limit` позволяет ограничить общее количество объектов, которые будут выбраны через связь.

```ruby
class Customer < ActiveRecord::Base
  has_many :recent_orders,
    -> { order('order_date desc').limit(100) },
    class_name: "Order"
end
```

#### `offset`

Метод `offset` позволяет определить начальное смещение для выбора объектов через связь. Например, `-> { offset(11) }` пропустит первые 11 записей.

#### `order`

Метод `order` предписывает порядок, в котором связанные объекты будут получены (в синтаксисе SQL, используемом в условии `ORDER BY`).

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, -> { order "date_confirmed DESC" }
end
```

#### `readonly`

При использовании метода `:readonly`, связанные объекты будут доступны только для чтения, когда получены посредством связи.

#### `select`

Метод `select` позволяет переопределить SQL условие `SELECT`, которое используется для получения данных о связанном объекте. По умолчанию Rails получает все столбцы.

WARNING: Если укажете свой собственный `select`, не забудьте включить столбцы первичного ключа и внешнего ключа в связанной модели. Если так не сделать, Rails выдаст ошибку.

#### `uniq`

Используйте метод `uniq`, чтобы убирать дубликаты из коллекции. Это полезно в сочетании с опцией `:through`.

```ruby
class Person < ActiveRecord::Base
  has_many :readings
  has_many :posts, through: :readings
end

person = Person.create(name: 'John')
post   = Post.create(name: 'a1')
person.posts << post
person.posts << post
person.posts.inspect # => [#<Post id: 5, name: "a1">, #<Post id: 5, name: "a1">]
Reading.all.inspect  # => [#<Reading id: 12, person_id: 5, post_id: 5>, #<Reading id: 13, person_id: 5, post_id: 5>]
```

В вышеописанной задаче два reading, и `person.posts` выявляет их оба, даже хотя эти записи указывают на один и тот же post.

Давайте установим `:uniq`:

```ruby
class Person
  has_many :readings
  has_many :posts, -> { uniq }, through: :readings
end

person = Person.create(name: 'Honda')
post   = Post.create(name: 'a1')
person.posts << post
person.posts << post
person.posts.inspect # => [#<Post id: 7, name: "a1">]
Reading.all.inspect  # => [#<Reading id: 16, person_id: 7, post_id: 7>, #<Reading id: 17, person_id: 7, post_id: 7>]
```

В вышеописанной задаче все еще два reading. Однако `person.posts` показывает только один post, поскольку коллекция загружает только уникальные записи.

### Когда сохраняются объекты?

Когда вы назначаете объект связью `has_many`, этот объект автоматически сохраняется (для того, чтобы обновить его внешний ключ). Если назначаете несколько объектов в одном выражении, они все будут сохранены.

Если одно из этих сохранений проваливается из-за ошибок валидации, тогда выражение назначения возвращает `false`, и само назначение отменяется.

Если родительский объект (который объявляет связь `has_many`) является несохраненным (то есть `new_record?` возвращает `true`) тогда дочерние объекты не сохраняются при добавлении. Все несохраненные члены связи сохранятся автоматически, когда сохранится родительский объект.

Если вы хотите назначить объект связью `has_many` без сохранения объекта, используйте метод `collection.build`.
