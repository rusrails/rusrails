# Подробная информация по связи belongs_to

Связь `belongs_to` создает соответствие один-к-одному с другой моделью. В терминах базы данных эта связь сообщает, что этот класс содержит внешний ключ. Если внешний ключ содержит другой класс, вместо этого следует использовать `has_one`.

### Методы, добавляемые `belongs_to`

Когда объявляете связь `belongs_to`, объявляющий класс автоматически получает четыре метода, относящихся к связи:

* `association(force_reload = false)`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`

Во всех четырех методах `association` заменяется символом, переданным как первый аргумент в `belongs_to`. Например, имеем объявление:

```ruby
class Order < ActiveRecord::Base
  belongs_to :customer
end
```

Каждый экземпляр модели order будет иметь эти методы:

```ruby
customer
customer=
build_customer
create_customer
```

NOTE: Когда устанавливаете новую связь `has_one` или `belongs_to`, следует использовать префикс `build_` для построения связи, в отличие от метода `association.build`, используемый для связей `has_many` или `has_and_belongs_to_many`. Чтобы создать связь, используйте префикс `create_`.

#### association(force_reload = false)`

Метод `association` возвращает связанный объект, если он есть. Если объекта нет, возвращает `nil`.

```ruby
@customer = @order.customer
```

Если связанный объект уже был получен из базы данных для этого объекта, возвращается кэшированная версия. Чтобы переопределить это поведение (и заставить прочитать из базы данных), передайте `true` как аргумент `force_reload`.

#### `association=(associate)`

Метод `association=` привязывает связанный объект к этому объекту. Фактически это означает извлечение первичного ключа из связанного объекта и присвоение его значения внешнему ключу.

```ruby
@order.customer = @customer
```

#### `build_association(attributes = {})`

Метод `build_association` возвращает новый объект связанного типа. Этот объект будет экземпляром с переданными атрибутами, будет установлена связь с внешним ключом этого объекта, но связанный объект пока _не_ будет сохранен.

```ruby
@customer = @order.build_customer(customer_number: 123,
                                  customer_name: "John Doe")
```

#### `create_association(attributes = {})`

Метод `create_association` возвращает новый объект связанного типа. Этот объект будет экземпляром с переданными атрибутами, будет установлена связь с внешним ключом этого объекта, и, если он пройдет валидации, определенные в связанной модели, связанный объект _будет_ сохранен.

```ruby
@customer = @order.create_customer(customer_number: 123,
                                   customer_name: "John Doe")
```

### Опции для `belongs_to`

Хотя Rails использует разумные значения по умолчанию, работающие во многих ситуациях, бывают случаи, когда хочется изменить поведение связи `belongs_to`. Такая настройка легко выполнима с помощью передачи опций и блоков со скоупом при создании связи. Например, эта связь использует две такие опции:

```ruby
class Order < ActiveRecord::Base
  belongs_to :customer, dependent: :destroy,
    counter_cache: true
end
```

Связь `belongs_to` поддерживает эти опции:

* `:autosave`
* `:class_name`
* `:counter_cache`
* `:dependent`
* `:foreign_key`
* `:inverse_of`
* `:polymorphic`
* `:touch`
* `:validate`

#### `:autosave`

Если установить опцию `:autosave` в `true`, Rails сохранит любые загруженные члены и уничтожит члены, помеченные для уничтожения, всякий раз, когда вы сохраните родительский объект.

#### `:class_name`

Если имя другой модели не может быть получено из имени связи, можете использовать опцию `:class_name` для предоставления имени модели. Например, если заказ принадлежит покупателю, но фактическое имя модели, содержащей покупателей `Patron`, можете установить это следующим образом:

```ruby
class Order < ActiveRecord::Base
  belongs_to :customer, class_name: "Patron"
end
```

#### `:counter_cache`

Опция `:counter_cache` может быть использована, чтобы сделать поиск количества принадлежацих объектов более эффективным. Рассмотрим эти модели:

```ruby
class Order < ActiveRecord::Base
  belongs_to :customer
end
class Customer < ActiveRecord::Base
  has_many :orders
end
```

С этими объявлениями запрос значения `@customer.orders.size` требует обращения к базе данных для выполнения запроса `COUNT(*)`. Чтобы этого избежать, можете добавить кэш счетчика в _принадлежащую_ модель:

```ruby
class Order < ActiveRecord::Base
  belongs_to :customer, counter_cache: true
end
class Customer < ActiveRecord::Base
  has_many :orders
end
```

С этим объявлением, Rails будет хранить в кэше актуальное значение и затем возвращать это значение в ответ на метод `size`.

Хотя опция `:counter_cache` определяется в модели, включающей определение `belongs_to`, фактический столбец должен быть добавлен в _связанную_ модель. В вышеописанном случае, необходимо добавить столбец, названный `orders_count` в модель `Customer`. Имя столбца по умолчанию можно переопределить, если вы этого желаете:

```ruby
class Order < ActiveRecord::Base
  belongs_to :customer, counter_cache: :count_of_orders
end
class Customer < ActiveRecord::Base
  has_many :orders
end
```

Столбцы кэша счетчика добавляются в список атрибутов модели только для чтения посредством `attr_readonly`.

#### `:dependent`

Если установить опцию `:dependent` как `:destroy`, тогда удаление этого объекта вызовет метод `destroy` у связанного объекта, для удаление того объекта. Если установить опцию `:dependent` как `:delete`, тогда удаление этого объекта удалит связанный объект _без_ вызова его метода `destroy`.

WARNING: Не следует определять эту опцию в связи `belongs_to`, которая соединена со связью `has_many` в другом классе. Это приведет к "битым" связям в записях вашей базы данных.

#### `:foreign_key`

По соглашению Rails предполагает, что столбец, используемый для хранения внешнего ключа в этой модели, имеет имя модели с добавленным суффиксом `_id`. Опция `:foreign_key` позволяет установить имя внешнего ключа явно:

```ruby
class Order < ActiveRecord::Base
  belongs_to :customer, class_name: "Patron",
                        foreign_key: "patron_id"
end
```

TIP: В любом случае, Rails не создаст столбцы внешнего ключа за вас. Вам необходимо явно определить их в своих миграциях.

#### `:inverse_of`

Опция `:inverse_of` определяет имя связи `has_many` или `has_one`, являющейся противополжностью для этой связи. Не работает в комбинации с опциями `:polymorphic`.

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, inverse_of: :customer
end

class Order < ActiveRecord::Base
  belongs_to :customer, inverse_of: :orders
end
```

#### `:polymorphic`

Передача `true` для опции `:polymorphic` показывает, что это полиморфная связь. Полиморфные связи подробно рассматривались [ранее](/active-record-associations/the-types-of-associations-2#polymorphic-associations).

#### `:touch`

Если установите опцию `:touch` в `:true`, то временные метки `updated_at` или `updated_on` на связанном объекте будут установлены в текущее время всякий раз, когда этот объект будет сохранен или уничтожен:

```ruby
class Order < ActiveRecord::Base
  belongs_to :customer, touch: true
end

class Customer < ActiveRecord::Base
  has_many :orders
end
```

В этом случае, сохранение или уничтожение заказа обновит временную метку на связанном покупателе. Также можно определить конкретный атрибут временной метки для обновления:

```ruby
class Order < ActiveRecord::Base
  belongs_to :customer, touch: :orders_updated_at
end
```

#### `:validate`

Если установите опцию `:validate` в `true`, тогда связанные объекты будут проходить валидацию всякий раз, когда вы сохраняете этот объект. По умолчанию она равна `false`: связанные объекты не проходят валидацию, когда этот объект сохраняется.

### Скоупы для `belongs_to`

Иногда хочется настроить запрос, используемый `belongs_to`. Такая настройка может быть достигнута с помощью блока скоупа. Например:

```ruby
class Order < ActiveRecord::Base
  belongs_to :customer, -> { where active: true },
                        dependent: :destroy
end
```

Внутри блока скоупа можно использовать любые стандартные "методы запросов":/active-record-query-interface. Далее обсудим следующие из них:

* `where`
* `includes`
* `readonly`
* `select`

#### `where`

Метод `where` позволяет определить условия, которым должен отвечать связанный объект.

```ruby
class Order < ActiveRecord::Base
  belongs_to :customer, -> { where active: true }
end
```

#### `includes`

Метод `includes` позволяет определить связи второго порядка, которые должны быть лениво загружены при использовании этой связи. Например, рассмотрим эти модели:

```ruby
class LineItem < ActiveRecord::Base
  belongs_to :order
end

class Order < ActiveRecord::Base
  belongs_to :customer
  has_many :line_items
end

class Customer < ActiveRecord::Base
  has_many :orders
end
```

Если вы часто получаете покупателей непосредственно из элементов заказа (`@line_item.order.customer`), то можно улучшить эффективность кода, включив  покупателей в связь между заказом и его элементами:

```ruby
class LineItem < ActiveRecord::Base
  belongs_to :order, -> { includes :customer }
end

class Order < ActiveRecord::Base
  belongs_to :customer
  has_many :line_items
end

class Customer < ActiveRecord::Base
  has_many :orders
end
```

NOTE: Нет необходимости в использовании `includes` для ближайших связей - то есть, если есть `Order belongs_to :customer`, то customer автоматически лениво загружается при необходимости.

#### `readonly`

При использовании `readonly`, связанный объект будет только для чтения при получении через связь.

#### `select`

Метод `select` позволяет переопределить SQL выражение `SELECT`, используемое для получения данных о связанном объекте. По умолчанию Rails получает все столбцы.

TIP: При использовании метода `select` на связи `belongs_to`, следует также установить опцию `:foreign_key` для гарантии правильных результатов.

### Существуют ли связанные объекты?

Можно увидеть, существует ли какой-либо связанный объект, при использовании метода `association.nil?`</tt>:

```ruby
if @order.customer.nil?
  @msg = "No customer found for this order"
end
```

### Когда сохраняются объекты?

Присвоение связи  `belongs_to` не приводит к автоматическому сохранению ни самого объекта, ни связанного объекта.
