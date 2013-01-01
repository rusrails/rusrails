# Подробная информация по связи has_one

Связь `has_one` создает соответствие один-к-одному с другой моделью. В терминах базы данных эта связь сообщает, что другой класс содержит внешний ключ. Если этот класс содержит внешний ключ, следует использовать `belongs_to`.

### Методы, добавляемые `has_one`

Когда объявляете связь `has_one`, объявляющий класс автоматически получает четыре метода, относящихся к связи:
* `association(force_reload = false)`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`

Во всех этих методах `association` заменяется на символ, переданный как первый аргумент в `has_one`. Например, имеем объявление:

```ruby
class Supplier < ActiveRecord::Base
  has_one :account
end
```

Каждый экземпляр модели `Supplier` будет иметь эти методы:

```ruby
account
account=
build_account
create_account
```

NOTE: При устанавлении новой связи `has_one` или `belongs_to`, следует использовать префикс `build_` для построения связи, в отличие от метода `association.build`, используемого для связей `has_many` или `has_and_belongs_to_many`. Чтобы создать связь, используйте префикс `create_`.

#### `association(force_reload = false)`

Метод `association` возвращает связанный объект, если таковой имеется. Если связанный объект не найден, возвращает `nil`.

```ruby
@account = @supplier.account
```

Если связанный объект уже был получен из базы данных для этого объекта, возвращается кэшированная версия. Чтобы переопределить это поведение (и заставить прочитать из базы данных), передайте `true` как аргумент `force_reload`.

#### `association=(associate)`

Метод `association=` привязывает связанный объект к этому объекту. Фактически это означает извлечение первичного ключа этого объекта и присвоение его значения внешнему ключу связанного объекта.

```ruby
@supplier.account = @account
```

#### `build_association(attributes = {})`

Метод `build_association` возвращает новый объект связанного типа. Этот объект будет экземпляром с переданными атрибутами, и будет установлена связь через внешний ключ, но связанный объект _не_ будет пока сохранен.

```ruby
@account = @supplier.build_account(terms: "Net 30")
```

#### `create_association(attributes = {})`

Метод `create_association` возвращает новый объект связанного типа. Этот объект будет экземпляром с переданными атрибутами, будет установлена связь через внешний ключ, и, если он пройдет валидации, определенные в связанной модели, связанный объект _будет_ сохранен

```ruby
@account = @supplier.create_account(terms: "Net 30")
```

### Опции для `has_one`

Хотя Rails использует разумные значения по умолчанию, работающие во многих ситуациях, бывают случаи, когда хочется изменить поведение связи `has_one`. Такая настройка легко выполнима с помощью передачи опции при создании связи. Например, эта связь использует две такие опции:

```ruby
class Supplier < ActiveRecord::Base
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

Установка опции `:as` показывает, что это полиморфная связь. Полиморфные связи подробно рассматривались [ранее](/active-record-associations/the-types-of-associations-2#polymorphic-associations).

#### `:autosave`

Если установить опцию `:autosave` в `true`, это сохранит любые загруженные члены и уничтожит члены, помеченные для уничтожения, всякий раз, когда вы сохраните родительский объект.

#### `:class_name`

Если имя другой модели не может быть образовано из имени связи, можете использовать опцию `:class_name` для предоставления имени модели. Например, если поставщик имеет аккаунт, но фактическое имя модели, содержащей аккаунты, это `Billing`, можете установить это следующим образом:

```ruby
class Supplier < ActiveRecord::Base
  has_one :account, class_name: "Billing"
end
```

#### `:dependent`

Управляет тем, что произойдет со связанным объектом, когда его владелец будет уничтожен:

* `:destroy` приведет к тому, что связанный объект также будет уничтожен
* `:delete` приведет к тому, что связанный объект будет удален из базы данных напрямую (таким образом не будут выполнены колбэки)
* `:nullify` приведет к тому, что внешний ключ будет установлен `NULL`. Колбэки не запускаются.
* `:restrict_with_exception` приведет к вызову исключения, если есть связанный объект
* `:restrict_with_error` приведет к ошибке, добавляемой к владельцу, если есть связанный объект

#### `:foreign_key`

По соглашению Rails предполагает, что столбец, используемый для хранения внешнего ключа в этой модели, имеет имя модели с добавленным суффиксом `_id`. Опция `:foreign_key` позволяет установить имя внешнего ключа явно:

```ruby
class Supplier < ActiveRecord::Base
  has_one :account, foreign_key: "supp_id"
end
```

TIP: В любом случае, Rails не создаст столбцы внешнего ключа за вас. Вам необходимо явно определить их в своих миграциях.

#### `:inverse_of`

Опция `:inverse_of` определяет имя связи `belongs_to`, являющейся обратной для этой связи. Не работает в комбинации с опциями `:through` или `:as`.

```ruby
class Supplier < ActiveRecord::Base
  has_one :account, inverse_of: :supplier
end

class Account < ActiveRecord::Base
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

Опция `:through` определяет соединительную модель, через которую выполняется запрос. Связи `has_one :through` подробно рассматривались [ранее](/active-record-associations/the-types-of-associations-1#the-has-one-through-association).

#### `:validate`

Если установите опцию `:validate` в `true`, тогда связанные объекты будут проходить валидацию всякий раз, когда вы сохраняете этот объект. По умолчанию она равна `false`: связанные объекты не проходят валидацию, когда этот объект сохраняется.

### Скоупы для `has_one`

Иногда хочется настроить запрос, используемый `has_one`. Такая настройка может быть достигнута с помощью блока скоупа. Например:

```ruby
class Supplier < ActiveRecord::Base
  has_one :account, -> { where active: true }
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
class Supplier < ActiveRecord::Base
  has_one :account, -> { where "confirmed = 1" }
end
```

#### `includes`

Метод `includes` позволяет определить связи второго порядка, которые должны быть лениво загружены при использовании этой связи. Например, рассмотрим жти модели:

```ruby
class Supplier < ActiveRecord::Base
  has_one :account
end

class Account < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ActiveRecord::Base
  has_many :accounts
end
```

Если вы часто получаете representatives непосредственно из suppliers (`@supplier.account.representative`), то можно улучшить эффективность кода, включив representatives в связь между suppliers и accounts:

```ruby
class Supplier < ActiveRecord::Base
  has_one :account, -> { includes :representative }
end

class Account < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ActiveRecord::Base
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

Если вы хотите назначить объект связью `has_one` без сохранения объекта, используйте метод `association.build`.
