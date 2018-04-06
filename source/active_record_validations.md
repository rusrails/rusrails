Валидации Active Record
=======================

Это руководство научит, как осуществлять валидацию состояния объектов до того, как они будут направлены в базу данных, используя особенность валидаций Active Record.

После прочтения руководства вы узнаете:

* Как использовать встроенные хелперы валидации Active Record
* Как создавать свои собственные методы валидации
* Как работать с сообщениями об ошибках, генерируемыми в процессе валидации

Обзор валидаций
---------------

Вот пример очень простой валидации:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

Person.create(name: "John Doe").valid? # => true
Person.create(name: nil).valid? # => false
```

Как видите, наша валидация позволяет узнать, что наш `Person` не валиден без атрибута `name`. Второй `Person` не будет персистентным в базе данных.

Прежде чем погрузиться в подробности, давайте поговорим о том, как валидации вписываются в общую картину приложения.

### Зачем использовать валидации?

Валидации используются, чтобы быть уверенными, что только валидные данные сохраняются в вашу базу данных. Например, для вашего приложения может быть важно, что каждый пользователь предоставил валидный электронный и почтовый адреса. Валидации на уровне модели - наилучший способ убедиться, что в базу данных будут сохранены только валидные данные. Они не зависят от базы данных, не могут быть обойдены конечными пользователями и удобны в тестировании и обслуживании. Rails представляет простоту в обслуживании, представляет встроенные хелперы для общих нужд, а также позволяет создавать свои собственные методы валидации.

Есть несколько способов валидации данных, прежде чем они будут сохранены в вашу базу данных, включая ограничения, встроенные в базу данных, валидации на клиентской части и валидации на уровне контроллера. Вкратце о плюсах и минусах:

* Ограничения базы данных и/или хранимые процедуры делают механизмы валидации зависимыми от базы данных, что делает тестирование и поддержку более трудными. Однако, если ваша база данных используется другими приложениями, валидация на уровне базы данных может безопасно обрабатывать некоторые вещи (такие как уникальность в нагруженных таблицах), которые затруднительно выполнять по-другому.
* Валидации на клиентской части могут быть очень полезны, но в целом ненадежны, если используются в одиночку. Если они используют JavaScript, они могут быть пропущены, если JavaScript отключен в клиентском браузере. Однако, если этот способ комбинировать с другими, валидации на клиентской части могут быть удобным способом предоставить пользователям немедленную обратную связь при использовании вашего сайта.
* Валидации на уровне контроллера заманчиво делать, но это часто приводит к громоздкости и трудности тестирования и поддержки. Во всех случаях, когда это возможно, держите свои контроллеры 'тощими', тогда с вашим приложением будет приятно работать в долгосрочной перспективе.

Выбирайте их под свои определенные специфичные задачи. Общее мнение команды Rails состоит в том, что валидации на уровне модели - наиболее подходящий вариант во многих случаях.

### Когда происходит валидация?

Есть два типа объектов Active Record: те, которые соответствуют строке в вашей базе данных, и те, которые нет. Когда создаете новый объект, например, используя метод `new`, этот объект еще не привязан к базе данных. Как только вы вызовете `save`, этот объект будет сохранен в подходящую таблицу базы данных. Active Record использует метод экземпляра `new_record?` для определения, есть ли уже объект в базе данных или нет. Рассмотрим следующий простой класс Active Record:

```ruby
class Person < ApplicationRecord
end
```

Можно увидеть, как он работает, взглянув на результат `rails console`:

```ruby
$ bin/rails console
>> p = Person.new(name: "John Doe")
=> #<Person id: nil, name: "John Doe", created_at: nil, updated_at: nil>
>> p.new_record?
=> true
>> p.save
=> true
>> p.new_record?
=> false
```

Создание и сохранение новой записи посылает операцию SQL `INSERT` базе данных. Обновление существующей записи вместо этого посылает операцию SQL `UPDATE`. Валидации обычно запускаются до того, как эти команды посылаются базе данных. Если любая из валидаций проваливается, объект помечается как недействительный и Active Record не выполняет операцию `INSERT` или `UPDATE`. Это помогает избежать хранения невалидного объекта в базе данных. Можно выбирать запуск специфичных валидаций, когда объект создается, сохраняется или обновляется.

CAUTION: Есть разные методы изменения состояния объекта в базе данных. Некоторые методы вызывают валидации, некоторые нет. Это означает, что возможно сохранить в базу данных объект с недействительным статусом, если вы будете не внимательны.

Следующие методы вызывают валидацию, и сохраняют объект в базу данных только если он валиден:

* `create`
* `create!`
* `save`
* `save!`
* `update`
* `update!`

Версии с восклицательным знаком (т.е. `save!`) вызывают исключение, если запись недействительна. Невосклицательные версии не вызывают: `save` и `update` возвращают `false`, `create` возвращает объект.

### Пропуск валидаций

Следующие методы пропускают валидации, и сохраняют объект в базу данных, независимо от его валидности. Их нужно использовать осторожно.

* `decrement!`
* `decrement_counter`
* `increment!`
* `increment_counter`
* `toggle!`
* `touch`
* `update_all`
* `update_attribute`
* `update_column`
* `update_columns`
* `update_counters`

Заметьте, что `save` также имеет способность пропустить валидации, если передать `validate: false` как аргумент. Этот способ нужно использовать осторожно.

* `save(validate: false)`

### `valid?` или `invalid?`

Перед сохранением объекта Active Record, Rails запускает ваши валидации. Если валидации производят какие-либо ошибки, Rails не сохраняет этот объект.

Вы также можете запускать эти валидации самостоятельно. `valid?` вызывает ваши валидации и возвращает true, если ни одной ошибки не было найдено у объекта, иначе false.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

Person.create(name: "John Doe").valid? # => true
Person.create(name: nil).valid? # => false
```

После того, как Active Record выполнит валидации, все найденные ошибки будут доступны в методе экземпляра `errors.messages`, возвращающем коллекцию ошибок. По определению объект валиден, если эта коллекция будет пуста после запуска валидаций.

Заметьте, что объект, созданный с помощью `new` не сообщает об ошибках, даже если технически невалиден, поскольку валидации автоматически запускаются только когда сохраняется объект, как в случае с методами `create` или `save`.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

>> p = Person.new
# => #<Person id: nil, name: nil>
>> p.errors.messages
# => {}

>> p.valid?
# => false
>> p.errors.messages
# => {name:["can't be blank"]}

>> p = Person.create
# => #<Person id: nil, name: nil>
>> p.errors.messages
# => {name:["can't be blank"]}

>> p.save
# => false

>> p.save!
# => ActiveRecord::RecordInvalid: Validation failed: Name can't be blank

>> Person.create!
# => ActiveRecord::RecordInvalid: Validation failed: Name can't be blank
```

`invalid?` это просто антипод `valid?`. Он запускает ваши валидации, возвращая true, если для объекта были добавлены ошибки, и false в противном случае.

### `errors[]`

Чтобы проверить, является или нет конкретный атрибут объекта валидным, можно использовать `errors[:attribute]`, который возвращает массив со всеми ошибками атрибута, когда нет ошибок по определенному атрибуту, возвращается пустой массив.

Этот метод полезен только _после того_, как валидации были запущены, так как он всего лишь исследует коллекцию errors, но сам не вызывает валидации. Он отличается от метода `ActiveRecord::Base#invalid?`, описанного выше, тем, что не проверяет валидность объекта в целом. Он всего лишь проверяет, какие ошибки были найдены для отдельного атрибута объекта.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

>> Person.new.errors[:name].any? # => false
>> Person.create.errors[:name].any? # => true
```

Мы рассмотрим ошибки валидации подробнее в разделе [Работаем с ошибками валидации](#working-with-validation-errors).

### `errors.details`

Чтобы проверить, какие валидации упали на невалидном атрибуте, можно использовать `errors.details[:attribute]`. Он возвращает массив хэшей с ключом `:error`, чтобы получить символ валидатора:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

>> person = Person.new
>> person.valid?
>> person.errors.details[:name] # => [{error: :blank}]
```

Использование `details` с собственным валидатором раскрыто в разделе [Работаем с ошибками валидации](#working-with-validation-errors).

Валидационные хелперы
---------------------

Active Record предлагает множество предопределенных валидационных хелперов, которые вы можете использовать прямо внутри ваших определений класса. Эти хелперы предоставляют общие правила валидации. Каждый раз, когда валидация проваливается, сообщение об ошибке добавляется в коллекцию `errors` объекта, и это сообщение связывается с атрибутом, который подлежал валидации.

Каждый хелпер принимает произвольное количество имен атрибутов, поэтому в одной строчке кода можно добавить валидации одинакового вида для нескольких атрибутов.

Они все принимают опции `:on` и `:message`, которые определяют, когда валидация должна быть запущена, и какое сообщение должно быть добавлено в коллекцию `errors`, если она провалится. Опция `:on` принимает одно из значений `:create` или `:update`. Для каждого валидационного хелпера есть свое сообщение об ошибке по умолчанию. Эти сообщения используются, если не определена опция `:message`. Давайте рассмотрим каждый из доступных хелперов.

### `acceptance`

Этот метод проверяет, что чекбокс в пользовательском интерфейсе был нажат, когда форма была подтверждена. Обычно используется, когда пользователю нужно согласиться с условиями использования вашего приложения, подтвердить, что некоторый текст прочтен, или другой подобной концепции.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end
```

Эта проверка выполнится, только если `terms_of_service` не `nil`. Для этого хелпера сообщение об ошибке по умолчанию следующее _"must be accepted"_. Можно передать произвольное сообщение с помощью опции `message`.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { message: 'must be abided' }
end
```

Также он может получать опцию `:accept`, которая определяет допустимые значения, которые будут считаться принятыми. По умолчанию это "1", но его можно изменить.

```ruby
class Person < ApplicationRecord
  validates :eula, acceptance: { accept: ['TRUE', 'accepted'] }
end
```

Эта валидация очень специфична для веб-приложений, и ее принятие не нужно записывать куда-либо в базу данных. Если у вас нет поля для него, хелпер всего лишь создаст виртуальный атрибут. Если поле существует в базе данных, опция `accept` должна быть установлена или включать `true`, а иначе эта валидация не будет выполнена.

### `validates_associated`

Этот хелпер можно использовать, когда у вашей модели есть связи с другими моделями, и их также нужно проверить на валидность. Когда вы пытаетесь сохранить свой объект, будет вызван метод `valid?` для каждого из связанных объектов.

```ruby
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

Эта валидация работает со всеми типами связей.

CAUTION: Не используйте `validates_associated` на обоих концах ваших связей, они будут вызывать друг друга в бесконечном цикле.

Для `validates_associated` сообщение об ошибке по умолчанию следующее _"is invalid"_. Заметьте, что каждый связанный объект имеет свою собственную коллекцию `errors`; ошибки не добавляются к вызывающей модели.

### `confirmation`

Этот хелпер можно использовать, если у вас есть два текстовых поля, из которых нужно получить полностью идентичное содержание. Например, вы хотите подтверждение адреса электронной почты или пароля. Эта валидация создает виртуальный атрибут, имя которого равно имени подтверждаемого поля с добавлением "\_confirmation".

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
end
```

В вашем шаблоне вьюхи нужно использовать что-то вроде этого

```erb
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>
```

Эта проверка выполняется, только если `email_confirmation` не равно `nil`. Чтобы требовать подтверждение, нужно добавить еще проверку на существование проверяемого атрибута (мы рассмотрим `presence` чуть позже):

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end
```

Также имеется опция `:case_sensitive`, которую используют, чтобы определить, должно ли ограничение подтверждения быть чувствительным к регистру. Эта опция по умолчанию true.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: { case_sensitive: false }
end
```

По умолчанию сообщение об ошибке для этого хелпера такое _"doesn't match confirmation"_.

### `exclusion`

Этот хелпер проводит валидацию того, что значения атрибутов не включены в указанный набор. Фактически, этот набор может быть любым перечисляемым объектом.

```ruby
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} is reserved." }
end
```

Хелпер `exclusion` имеет опцию `:in`, которая получает набор значений, которые не должны приниматься проверяемыми атрибутами. Опция `:in` имеет псевдоним `:within`, который используется для тех же целей. Этот пример использует опцию `:message`, чтобы показать вам, как можно включать значение атрибута. Для того, чтобы увидеть все опции аргументов сообщения смотрите [документацию по message](#message).

Значение сообщения об ошибке по умолчанию "_is reserved_".

### `format`

Этот хелпер проводит валидацию значений атрибутов, тестируя их на соответствие указанному регулярному выражению, которое определяется с помощью опции `:with`.

```ruby
class Product < ApplicationRecord
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "only allows letters" }
end
```

В качестве альтернативы можно потребовать, чтобы указанный атрибут _не_ соответствовал регулярному выражению, используя опцию `:without`.

Значение сообщения об ошибке по умолчанию "_is invalid_".

### `inclusion`

Этот хелпер проводит валидацию значений атрибутов на включение в указанный набор. Фактически этот набор может быть любым перечисляемым объектом.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }
end
```

Хелпер `inclusion` имеет опцию `:in`, которая получает набор значений, которые должны быть приняты. Опция `:in` имеет псевдоним `:within`, который используется для тех же целей. Предыдущий пример использует опцию `:message`, чтобы показать вам, как можно включать значение атрибута. Для того, чтобы увидеть все опции смотрите [документацию по message](#message).

Значение сообщения об ошибке по умолчанию для этого хелпера такое "_is not included in the list_".

### `length`

Этот хелпер проводит валидацию длины значений атрибутов. Он предлагает ряд опций, с помощью которых вы можете определить ограничения по длине разными способами:

```ruby
class Person < ApplicationRecord
  validates :name, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
end
```

Возможные опции ограничения длины такие:

* `:minimum` - атрибут не может быть меньше определенной длины.
* `:maximum` - атрибут не может быть больше определенной длины.
* `:in` (или `:within`) - длина атрибута должна находиться в указанном интервале. Значение этой опции должно быть интервалом.
* `:is` - длина атрибута должна быть равной указанному значению.

Значение сообщения об ошибке по умолчанию зависит от типа выполняемой валидации длины. Можно переопределить эти сообщения, используя опции `:wrong_length`, `:too_long` и `:too_short`, и `%{count}` как местозаполнитель (placeholder) числа, соответствующего длине используемого ограничения. Можете использовать опцию `:message` для определения сообщения об ошибке.

```ruby
class Person < ApplicationRecord
  validates :bio, length: { maximum: 1000,
    too_long: "%{count} characters is the maximum allowed" }
end
```

Отметьте, что сообщения об ошибке по умолчанию во множественном числе (т.е., "is too short (minimum is %{count} characters)"). По этой причине, когда `:minimum` равно 1, следует предоставить собственное сообщение или использовать вместо него `presence: true`. Когда `:in` или `:within` имеют как нижнюю границу 1, следует или предоставить собственное сообщение, или вызвать `presence` перед `length`.

### `numericality`

Этот хелпер проводит валидацию того, что ваши атрибуты имеют только числовые значения. По умолчанию, этому будет соответствовать возможный знак первым символом, и следующее за ним целочисленное или с плавающей запятой число. Чтобы определить, что допустимы только целочисленные значения, установите `:only_integer` в true.

Если установить `:only_integer` в `true`, тогда будет использоваться регулярное выражение

```ruby
/\A[+-]?\d+\z/
```

для проведения валидации значения атрибута. В противном случае, он будет пытаться конвертировать значение в число, используя `Float`.

```ruby
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: { only_integer: true }
end
```

Кроме `:only_integer`, хелпер `validates_numericality_of` также принимает следующие опции для добавления ограничений к приемлемым значениям:

* `:greater_than` - определяет, что значение должно быть больше, чем значение опции. По умолчанию сообщение об ошибке для этой опции такое _"must be greater than %{count}"_.
* `:greater_than_or_equal_to` - определяет, что значение должно быть больше или равно значению опции. По умолчанию сообщение об ошибке для этой опции такое _"must be greater than or equal to %{count}"_.
* `:equal_to` - определяет, что значение должно быть равно значению опции. По умолчанию сообщение об ошибке для этой опции такое _"must be equal to %{count}"_.
* `:less_than` - определяет, что значение должно быть меньше, чем значение опции. По умолчанию сообщение об ошибке для этой опции такое _"must be less than %{count}"_.
* `:less_than_or_equal_to` - определяет, что значение должно быть меньше или равно значению опции. По умолчанию сообщение об ошибке для этой опции такое _"must be less than or equal to %{count}"_.
* `:other_than` - определяет, что значение должно отличаться от представленного значения. По умолчанию сообщение об ошибке для этой опции такое _"must be other than %{count}"_.
* `:odd` - определяет, что значение должно быть нечетным, если установлено true. По умолчанию сообщение об ошибке для этой опции такое _"must be odd"_.
* `:even` - определяет, что значение должно быть четным, если установлено true. По умолчанию сообщение об ошибке для этой опции такое _"must be even"_.

NOTE: По умолчанию `numericality` не допускает значения `nil`. Чтобы их разрешить, можно использовать опцию `allow_nil: true`.

По умолчанию сообщение об ошибке _"is not a number"_.

### `presence`

Этот хелпер проводит валидацию того, что определенные атрибуты не пустые. Он использует метод `blank?` для проверки того, является ли значение или `nil`, или пустой строкой (это строка, которая или пуста, или состоит из пробелов).

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, presence: true
end
```

Если хотите быть уверенным, что связь существует, нужно проверить, существует ли сам связанный объект, а не внешний ключ, используемый для связи.

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, presence: true
end
```

Для того, чтобы проверять связанные записи, чье присутствие необходимо, нужно определить опцию `:inverse_of` для связи:

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

При проведении валидации существования объекта, связанного отношением `has_one` или `has_many`, будет проверено, что объект ни `blank?`, ни `marked_for_destruction?`.

Так как `false.blank?` это true, если хотите провести валидацию существования булева поля, нужно использовать одну из следующих валидаций:

```ruby
validates :boolean_field_name, inclusion: { in: [true, false] }
validates :boolean_field_name, exclusion: { in: [nil] }
```

При использовании одной из этих валидаций, вы можете быть уверены, что значение не будет `nil`, которое в большинстве случаев преобразуется в `NULL` значение.

### `absence`

Этот хелпер проверяет, что указанные атрибуты отсутствуют. Он использует метод `present?` для проверки, что значение является либо nil, либо пустой строкой (то есть либо нулевой длины, либо состоящей из пробелов).

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, absence: true
end
```

Если хотите убедиться, что отсутствует связь, необходимо проверить, что отсутствует сам связанный объект, а не внешний ключ, используемый для связи.

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, absence: true
end
```

Чтобы проверять связанные объекты, отсутствие которых требуется, для связи необходимо указать опцию `:inverse_of`:

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

Если проверяете отсутствие объекта, связанного отношением `has_one` или `has_many`, он проверит, что объект и не `present?`, и не `marked_for_destruction?`.

Поскольку `false.present?` является false, если хотите проверить отсутствие булева поля, следует использовать `validates :field_name, exclusion: { in: [true, false] }`.

По умолчанию сообщение об ошибке _"must be blank"_.

### `uniqueness`

Этот хелпер проводит валидацию того, что значение атрибута уникально, перед тем, как объект будет сохранен. Он не создает условие уникальности в базе данных, следовательно, может произойти так, что два разных подключения к базе данных создадут две записи с одинаковым значением для столбца, который вы подразумеваете уникальным. Чтобы этого избежать, нужно создать индекс unique на оба столбцах в вашей базе данных.

```ruby
class Account < ApplicationRecord
  validates :email, uniqueness: true
end
```

Валидация производится путем SQL-запроса в таблицу модели, поиска существующей записи с тем же значением атрибута.

Имеется опция `:scope`, которую можно использовать для определения одного и более атрибутов, используемых для ограничения проверки уникальности:

```ruby
class Holiday < ApplicationRecord
  validates :name, uniqueness: { scope: :year,
    message: "should happen once per year" }
end
```

Если хотите создать ограничение на уровне базы данных, чтобы предотвратить возможные нарушения валидации уникальности с помощью опции `:scope`, необходимо создать индекс уникальности на обоих столбцах базы данных. Подробнее об индексах для нескольких столбцов смотрите в [мануале MySQL](http://dev.mysql.com/doc/refman/5.7/en/multiple-column-indexes.html), или примеры ограничений уникальности, относящихся к группе столбцов в [мануале PostgreSQL](https://postgrespro.ru/docs/postgrespro/current/ddl-constraints.html).

Также имеется опция `:case_sensitive`, которой можно определить, будет ли ограничение уникальности чувствительно к регистру или нет. Опция по умолчанию равна true.

```ruby
class Person < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
end
```

WARNING. Отметьте, что некоторые базы данных настроены на выполнение чувствительного к регистру поиска в любом случае.

По умолчанию сообщение об ошибке _"has already been taken"_.

### `validates_with`

Этот хелпер передает запись в отдельный класс для валидации.

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors[:base] << "This person is evil"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator
end
```

NOTE: Ошибки, добавляемые в `record.errors[:base]` относятся к состоянию записи в целом, а не к определенному атрибуту.

Хелпер `validates_with` принимает класс или список классов для использования в валидации. Для `validates_with` нет сообщения об ошибке по умолчанию. Следует вручную добавлять ошибки в коллекцию errors записи в классе валидатора.

Для применения метода validate, необходимо иметь определенным параметр `record`, который является записью, проходящей валидацию.

Подобно всем другим валидациям, `validates_with` принимает опции `:if`, `:unless` и `:on`. Если передадите любые другие опции, они будут переданы в класс валидатора как `options`:

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any?{|field| record.send(field) == "Evil" }
      record.errors[:base] << "This person is evil"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator, fields: [:first_name, :last_name]
end
```

Отметьте, что валидатор будет инициализирован **только один раз** на протяжении всего жизненного цикла приложения, а не при каждом запуске валидации, поэтому будьте аккуратнее с использованием переменных экземпляра в нем.

Если ваш валидатор настолько сложный, что вы хотите использовать переменные экземпляра, вместо него проще использовать обычные объекты Ruby:

```ruby
class Person < ApplicationRecord
  validate do |person|
    GoodnessValidator.new(person).validate
  end
end

class GoodnessValidator
  def initialize(person)
    @person = person
  end

  def validate
    if some_complex_condition_involving_ivars_and_private_methods?
      @person.errors[:base] << "This person is evil"
    end
  end

  # ...
end
```

### `validates_each`

Этот хелпер помогает провести валидацию атрибутов с помощью блока кода. Он не имеет предопределенной валидационной функции. Вы должны создать ее, используя блок, и каждый атрибут, указанный в `validates_each`, будет протестирован в нем. В следующем примере нам не нужны имена и фамилии, начинающиеся с маленькой буквы.

```ruby
class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, 'must start with upper case') if value =~ /\A[[:lower:]]/
  end
end
```

Блок получает запись, имя атрибута и значение атрибута. Вы можете делать что угодно для проверки валидности данных внутри блока. Если валидация проваливается, следует добавить сообщение об ошибке в модель, которое делает ее невалидной.

Общие опции валидаций
---------------------

Есть несколько общих опций валидаций:

### `:allow_nil`

Опция `:allow_nil` пропускает валидацию, когда проверяемое значение равно `nil`.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }, allow_nil: true
end
```

Для того, чтобы увидеть все опции аргументов сообщения смотрите [документацию по message](#message).

### `:allow_blank`

Опция `:allow_blank` подобна опции `:allow_nil`. Эта опция пропускает валидацию, если значение атрибута `blank?`, например `nil` или пустая строка.

```ruby
class Topic < ApplicationRecord
  validates :title, length: { is: 5 }, allow_blank: true
end

Topic.create(title: "").valid?  # => true
Topic.create(title: nil).valid? # => true
```

### `:message`

Как мы уже видели, опция `:message` позволяет определить сообщение, которое будет добавлено в коллекцию `errors`, когда валидация проваливается. Если эта опция не используется, Active Record будет использовать соответствующие сообщения об ошибках по умолчанию для каждого валидационного хелпера. Опция `:message` принимает `String` или `Proc`.

Значение `String` в `:message` может опционально содержать любые из `%{value}`, `%{attribute}` и `%{model}`, которые будут динамически заменены, когда валидация провалится. Эта замена выполняется, если используется гем I18n, и местозаполнитель должен полностью совпадать, пробелы не допускаются.

Значение `Proc` в `:message` задается с двумя аргументами: проверяемым объектом и хэшем с ключами `:model`, `:attribute` и `:value`.

```ruby
class Person < ApplicationRecord
  # Жестко закодированное сообщение
  validates :name, presence: { message: "must be given please" }

  # Сообщение со значением с динамическим атрибутом. %{value} будет заменено
  # фактическим значением атрибута. Также доступны %{attribute} и %{model}.
  validates :age, numericality: { message: "%{value} seems wrong" }

  # Proc
  validates :username,
    uniqueness: {
      # object = person object being validated
      # data = { model: "Person", attribute: "Username", value: <username> }
      message: ->(object, data) do
        "Hey #{object.name}!, #{data[:value]} is taken already! Try again #{Time.zone.tomorrow}"
      end
    }
end
```

### `:on`

Опция `:on` позволяет определить, когда должна произойти валидация. Стандартное поведение для всех встроенных валидационных хелперов это запускаться при сохранении (и когда создается новая запись, и когда она обновляется). Если хотите изменить это, используйте `on: :create`, для запуска валидации только когда создается новая запись, или `on: :update`, для запуска валидации когда запись обновляется.

```ruby
class Person < ApplicationRecord
  # будет возможно обновить email с дублирующим значением
  validates :email, uniqueness: true, on: :create

  # будет возможно создать запись с нечисловым возрастом
  validates :age, numericality: true, on: :update

  # по умолчанию (проверяет и при создании, и при обновлении)
  validates :name, presence: true
end
```

`on:` также можно использовать для определения пользовательского контекста. Пользовательские контексты должны быть явно включены с помощью передачи имени контекста в `valid?`, `invalid?` или `save`.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
end

person = Person.new
```

`person.valid?(:account_setup)` выполнит обе валидации без сохранения модели. И `person.save(context: :account_setup)` перед сохранением валидирует `person` в контексте `account_setup`. При явном включении модель валидируется только валидациями только этого контекста и валидациями без контекста.

Строгие валидации
-----------------

Также можно определить валидации строгими, чтобы они вызывали `ActiveModel::StrictValidationFailed`, когда объект невалиден.

```ruby
class Person < ApplicationRecord
  validates :name, presence: { strict: true }
end

Person.new.valid?  # => ActiveModel::StrictValidationFailed: Name can't be blank
```

Также возможно передать собственное исключение в опцию `:strict`.

```ruby
class Person < ApplicationRecord
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end

Person.new.valid?  # => TokenGenerationException: Token can't be blank
```

Условная валидация
------------------

Иногда имеет смысл проводить валидацию объекта только при выполнении заданного предиката. Это можно сделать, используя опции `:if` и `:unless`, которые принимают символ, `Proc` или `Array`. Опцию `:if` можно использовать, если необходимо определить, когда валидация **должна** произойти. Если же нужно определить, когда валидация **не должна** произойти, воспользуйтесь опцией `:unless`.

### Использование символа с `:if` и `:unless`

Вы можете связать опции `:if` и `:unless` с символом, соответствующим имени метода, который будет вызван перед валидацией. Это наиболее часто используемый вариант.

```ruby
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == "card"
  end
end
```

### Использование Proc с `:if` и `:unless`

Наконец, можно связать `:if` и `:unless` с объектом `Proc`, который будет вызван. Использование объекта `Proc` дает возможность написать встроенное условие вместо отдельного метода. Этот вариант лучше всего подходит для однострочного кода.

```ruby
class Account < ApplicationRecord
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end
```

### Группировка условных валидаций

Иногда полезно иметь несколько валидаций с одним условием. Это легко достигается с использованием `with_options`.

```ruby
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end
```

Во все валидации внутри `with_options` будет автоматически передано условие `if: :is_admin?`.

### Объединение условий валидации

С другой стороны, может использоваться массив, когда несколько условий определяют, должна ли произойти валидация. Более того, в одной и той же валидации можно применить и `:if:`, и `:unless`.

```ruby
class Computer < ApplicationRecord
  validates :mouse, presence: true,
                    if: [Proc.new { |c| c.market.retail? }, :desktop?],
                    unless: Proc.new { |c| c.trackpad.present? }
end
```

Валидация выполнится только тогда, когда все условия `:if` и ни одно из условий `:unless` будут вычислены со значением `true`.

Выполнение собственных валидаций
---------------------------------

Когда встроенных валидационных хелперов недостаточно для ваших нужд, можете написать свои собственные валидаторы или методы валидации.

### Собственные валидаторы

Собственные валидаторы это классы, наследуемые от `ActiveModel::Validator`. Эти классы должны реализовать метод `validate`, принимающий запись как аргумент и выполняющий валидацию на ней. Собственный валидатор вызывается с использованием метода `validates_with`.

```ruby
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.starts_with? 'X'
      record.errors[:name] << 'Need a name starting with X please!'
    end
  end
end
 
class Person
  include ActiveModel::Validations
  validates_with MyValidator
end
```

Простейшим способом добавить собственные валидаторы для валидации отдельных атрибутов является наследуемость от `ActiveModel::EachValidator`. В этом случае класс собственного валидатора должен реализовать метод `validate_each`, принимающий три аргумента: запись, атрибут и значение. Это будут соответствующие экземпляр, атрибут, который будет проверяться и значение атрибута в переданном экземпляре:

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)`[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end

class Person < ApplicationRecord
  validates :email, presence: true, email: true
end
```

Как показано в примере, можно объединять стандартные валидации со своими произвольными валидаторами.

### Собственные методы

Также возможно создать методы, проверяющие состояние ваших моделей и добавляющие сообщения в коллекцию `errors`, когда они невалидны. Затем эти методы следует зарегистрировать, используя метод класса `validate` ([API](http://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validate)), передав символьные имена валидационных методов.

Можно передать более одного символа для каждого метода класса, и соответствующие валидации будут запущены в том порядке, в котором они зарегистрированы.

Метод `valid?` проверит, что коллекция ошибок пуста. поэтому ваши собственные методы валидации должны добавить ошибки в нее, когда вы хотите, чтобы валидация провалилась:

```ruby
class Invoice < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "can't be in the past")
    end
  end

  def discount_cannot_be_greater_than_total_value
    errors.add(:discount, "can't be greater than total value") if
      discount > total_value
  end
end
```

По умолчанию такие валидации будут выполнены каждый раз при вызове `valid?` или сохранении объекта. Но также возможно контролировать, когда выполнять собственные валидации, передав опцию `:on` в метод `validate`, с ключами: `:create` или `:update`.

```ruby
class Invoice < ApplicationRecord
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "is not active") unless customer.active?
  end
end
```

(working-with-validation-errors) Работаем с ошибками валидации
--------------------------------------------------------------

В дополнение к методам `valid?` и `invalid?`, рассмотренным ранее, Rails предоставляет ряд методов для работы с коллекцией `errors` и проверки валидности объектов.

Предлагаем список наиболее часто используемых методов. Если хотите увидеть список всех доступных методов, обратитесь к документации по `ActiveModel::Errors`.

### `errors`

Возвращает экземпляр класса `ActiveModel::Errors`, содержащий все ошибки. Каждый ключ это имя атрибута и значение это массив строк со всеми ошибками.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

person = Person.new
person.valid? # => false
person.errors.messages
 # => {:name=>["can't be blank", "is too short (minimum is 3 characters)"]}

person = Person.new(name: "John Doe")
person.valid? # => true
person.errors.messages # => []
```

### `errors[]`

`errors[]` используется, когда вы хотите проверить сообщения об ошибке для определенного атрибута. Он возвращает массив строк со всеми сообщениями об ошибке для заданного атрибута, каждая строка с одним сообщением об ошибке. Если нет ошибок, относящихся к атрибуту, возвратится пустой массив.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

person = Person.new(name: "John Doe")
person.valid? # => true
person.errors[:name] # => []

person = Person.new(name: "JD")
person.valid? # => false
person.errors[:name] # => ["is too short (minimum is 3 characters)"]

person = Person.new
person.valid? # => false
person.errors[:name]
 # => ["can't be blank", "is too short (minimum is 3 characters)"]
```

### `errors.add`

Метод `add` позволяет добавлять сообщение об ошибке, относящейся к определенному атрибуту. Он принимает в качестве аргументов атрибут и сообщение об ошибке.

Метод `errors.full_messages` (или его эквивалент `errors.to_a`) возвращает сообщения об ошибках в дружелюбном формате с именем атрибута с прописной буквы, предшествующим каждому сообщению, как показано в следующем примере.

```ruby
class Person < ApplicationRecord
  def a_method_used_for_validation_purposes
    errors.add(:name, "cannot contain the characters !@#%*()_-+=")
  end
end

person = Person.create(name: "!@#")

person.errors[:name]
 # => ["cannot contain the characters !@#%*()_-+="]

person.errors.full_messages
 # => ["Name cannot contain the characters !@#%*()_-+="]
```

Эквивалентом `errors#add` является использование `<<` для добавления сообщения к массиву `errors.messages` атрибута:

```ruby
  class Person < ApplicationRecord
    def a_method_used_for_validation_purposes
      errors.messages[:name] << "cannot contain the characters !@#%*()_-+="
    end
  end

  person = Person.create(name: "!@#")

  person.errors[:name]
   # => ["cannot contain the characters !@#%*()_-+="]

  person.errors.to_a
   # => ["Name cannot contain the characters !@#%*()_-+="]
```

### `errors.details`

Можно указать тип валидатора в возвращаемом хэше подробностей об ошибке details с помощью метода `errors.add`.

```ruby
class Person < ApplicationRecord
  def a_method_used_for_validation_purposes
    errors.add(:name, :invalid_characters)
  end
end

person = Person.create(name: "!@#")

person.errors.details[:name]
# => [{error: :invalid_characters}]
```

Чтобы расширить хэш подробностей об ошибке details, добавив, к примеру, недопустимые символы, можно передать дополнительные ключи в `errors.add`.

```ruby
class Person < ApplicationRecord
  def a_method_used_for_validation_purposes
    errors.add(:name, :invalid_characters, not_allowed: "!@#%*()_-+=")
  end
end

person = Person.create(name: "!@#")

person.errors.details[:name]
# => [{error: :invalid_characters, not_allowed: "!@#%*()_-+="}]
```

Все встроенные в Rails валидаторы заполняют хэш details соответствующим типом валидатора.

### `errors[:base]`

Можете добавлять сообщения об ошибках, которые относятся к состоянию объекта в целом, а не к отдельному атрибуту. Этот метод можно использовать, если вы хотите сказать, что объект невалиден, независимо от значений его атрибутов. Поскольку `errors[:base]` массив, можете просто добавить строку к нему, и она будет использована как сообщение об ошибке.

```ruby
class Person < ApplicationRecord
  def a_method_used_for_validation_purposes
    errors[:base] << "This person is invalid because ..."
  end
end
```

### `errors.clear`

Метод `clear` используется, когда вы намеренно хотите очистить все сообщения в коллекции `errors`. Естественно, вызов `errors.clear` для невалидного объекта фактически не сделает его валидным: сейчас коллекция `errors` будет пуста, но в следующий раз, когда вы вызовете `valid?` или любой метод, который пытается сохранить этот объект в базу данных, валидации выполнятся снова. Если любая из валидаций провалится, коллекция `errors` будет заполнена снова.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

person = Person.new
person.valid? # => false
person.errors[:name]
 # => ["can't be blank", "is too short (minimum is 3 characters)"]

person.errors.clear
person.errors.empty? # => true

person.save # => false

person.errors[:name]
 # => ["can't be blank", "is too short (minimum is 3 characters)"]
```

### `errors.size`

Метод `size` возвращает количество сообщений об ошибке для объекта.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

person = Person.new
person.valid? # => false
person.errors.size # => 2

person = Person.new(name: "Andrea", email: "andrea@example.com")
person.valid? # => true
person.errors.size # => 0
```

(displaying-validation-errors-in-the-view) Отображение ошибок валидации во вьюхах
---------------------------------------------------------------------------------

Как только вы создали модель и добавили валидации, если эта модель создается с помощью веб-формы, то вы, возможно хотите отображать сообщение об ошибке, когда одна из валидаций проваливается.

Поскольку каждое приложение обрабатывает подобные вещи по-разному, в Rails нет какого-то хелпера вьюхи для непосредственной генерации этих сообщений. Однако, благодаря богатому набору методов, Rails в целом дает способ взаимодействия с валидациями, очень просто создать свой собственный. Кроме того, при генерации скаффолда, Rails поместит некоторый ERB в `_form.html.erb`, генерируемый для отображения полного списка ошибок этой модели.

Допустим, у нас имеется модель, сохраненная в переменную экземпляра `@article`, это выглядит следующим образом:

```erb
<% if @article.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@article.errors.count, "error") %> prohibited this article from being saved:</h2>
    <ul>
    <% @article.errors.full_messages.each do |msg| %>
      <li><%= msg %></li>
    <% end %>
    </ul>
  </div>
<% end %>
```

Более того, при использовании хелперов форм Rails для создания форм, когда у поля происходит ошибка валидации, генерируется дополнительный `<div>` вокруг содержимого.

```erb
<div class="field_with_errors">
 <input id="article_title" name="article[title]" size="30" type="text" value="">
</div>
```

Этот div можно стилизовать по желанию. К примеру, дефолтный скаффолд, который генерирует Rails, добавляет это правило CSS:

```
.field_with_errors {
  padding: 2px;
  background-color: red;
  display: table;
}
```

Это означает, что любое поле с ошибкой обведено красной рамкой толщиной 2 пикселя.
