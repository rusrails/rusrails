Основы Active Model
===================

Это руководство познакомит вас со всем необходимым для начала использования классов моделей. Active Model позволяет хелперам Action Pack взаимодействовать с обычными объектами на чистом Ruby. Также Active Model помогает с созданием гибкой, настраиваемой ORM для использования вне фреймворка Rails.

После прочтение данного руководства, вы узнаете:

* Как ведет себя модель Active Record.
* Как работают колбэки и валидации.
* Как работают сериализаторы.
* Как Active Model интегрируется с фреймворком интернационализации Rails (i18n).

--------------------------------------------------------------------------------

Что такое Active Model?
-----------------------

Библиотека Active Model содержит различные модули, используемые для разработки классов, которым необходимы некоторые особенности, присутствующие в Active Record. Некоторые из этих модулей описаны ниже.

### API

`ActiveModel::API` добавляет возможность классу работать с Action Pack и Action View прямо из коробки.

```ruby
class EmailContact
  include ActiveModel::API

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # доставляем письмо
    end
  end
end
```

При включении `ActiveModel::API` вы получаете несколько возможностей, таких как:

- интроспекция имени модели
- преобразования
- переводы
- валидации

Он также дает возможность инициализировать объект с помощью хэша атрибутов, подобно любому объекту Active Record.

```irb
irb> email_contact = EmailContact.new(name: 'David', email: 'david@example.com', message: 'Hello World')
irb> email_contact.name
=> "David"
irb> email_contact.email
=> "david@example.com"
irb> email_contact.valid?
=> true
irb> email_contact.persisted?
=> false
```

Любой класс, включающий `ActiveModel::API`, может быть использован с `form_with`, `render` и любыми другими методами хелпера Action View, точно так же, как и объекты Active Record.

### Методы атрибутов

Модуль `ActiveModel::AttributeMethods` позволяет добавлять различные суффиксы и префиксы к методам класса. Для использования необходимо определить суффиксы, префиксы, а также к каким методам объекта они будут применяться.

```ruby
class Person
  include ActiveModel::AttributeMethods

  attribute_method_prefix 'reset_'
  attribute_method_suffix '_highest?'
  define_attribute_methods 'age'

  attr_accessor :age

  private
    def reset_attribute(attribute)
      send("#{attribute}=", 0)
    end

    def attribute_highest?(attribute)
      send(attribute) > 100
    end
end
```

```irb
irb> person = Person.new
irb> person.age = 110
irb> person.age_highest?
=> true
irb> person.reset_age
=> 0
irb> person.age_highest?
=> false
```

### Колбэки

Модуль `ActiveModel::Callbacks` дает Active Record возможность использования функций обратного вызова (колбэков). Это позволяет определять колбэки, вызываемые в определенное время. После определения колбэков можно обернуть их дополнительной функциональностью before, after и around, которые позволяют определить момент вызова колбэка "до", "после" и "до и после" вызова нужного метода.

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me

  def update
    run_callbacks(:update) do
      # Этот метод вызывается при вызове у объекта метода update.
    end
  end

  def reset_me
    # Этот метод вызывается при вызове у объекта метода update, выполнение метода reset_me произойдет до вызова update, т.к он определен как колбэк before_update.
  end
end
```

### Преобразования

Если для класса определены методы `persisted?` и `id`, то можно добавить модуль `ActiveModel::Conversion` в этот класс и вызывать методы преобразования Rails на объектах этого класса.

```ruby
class Person
  include ActiveModel::Conversion

  def persisted?
    false
  end

  def id
    nil
  end
end
```

```irb
irb> person = Person.new
irb> person.to_model == person
=> true
irb> person.to_key
=> nil
irb> person.to_param
=> nil
```

### Грязный объект

Объект становится грязным после одного или нескольких изменений его атрибутов, и при этом он не был сохранен. `ActiveModel::Dirty` дает возможность проверить, был ли объект изменен или нет. Также имеются акцессор-методы на основе атрибутов. Представим, что имеется класс Person с атрибутами `first_name` и `last_name`:

```ruby
class Person
  include ActiveModel::Dirty
  define_attribute_methods :first_name, :last_name

  def first_name
    @first_name
  end

  def first_name=(value)
    first_name_will_change!
    @first_name = value
  end

  def last_name
    @last_name
  end

  def last_name=(value)
    last_name_will_change!
    @last_name = value
  end

  def save
    # метод для сохранения изменений...
    changes_applied
  end
end
```

#### Запрашиваем у объекта список всех измененных атрибутов.

```irb
irb> person = Person.new
irb> person.changed?
=> false

irb> person.first_name = "First Name"
irb> person.first_name
=> "First Name"

# Возвращает true, если хотя бы у одного из атрибутов есть несохраненное значение.
irb> person.changed?
=> true

# Возвращает список атрибутов, которые были изменены до сохранения.
irb> person.changed
=> ["first_name"]

# Возвращает хэш с измененными атрибутами вместе с их первоначальными значениями.
irb> person.changed_attributes
=> {"first_name"=>nil}

# Возвращает хэш изменений с именами атрибутов в качестве ключей, и их значений как массива, который содержит старое и новое значение поля.
irb> person.changes
=> {"first_name"=>[nil, "First Name"]}
```

#### Акцессор-методы, основанные на атрибутах

Отслеживает, был ли атрибут изменен или нет.

```irb
irb> person.first_name
=> "First Name"

# attr_name_changed?
irb> person.first_name_changed?
=> true
```

Отслеживает предыдущее значение атрибута.

```irb
# акцессор attr_name_was
irb> person.first_name_was
=> nil
```

Отслеживает старое и новое значения измененного атрибута. Возвращает массив, если изменяли, в противном случае nil.

```irb
# attr_name_change
irb> person.first_name_change
=> [nil, "First Name"]
irb> person.last_name_change
=> nil
```

### Валидации

Модуль `ActiveModel::Validations` добавляет возможность проверять объекты, как в Active Record.

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :email, :token

  validates :name, presence: true
  validates_format_of :email, with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i
  validates! :token, presence: true
end
```

```irb
irb> person = Person.new
irb> person.token = "2b1f325"
irb> person.valid?
=> false
irb> person.name = 'vishnu'
irb> person.email = 'me'
irb> person.valid?
=> false
irb> person.email = 'me@vishnuatrai.com'
irb> person.valid?
=> true
irb> person.token = nil
irb> person.valid?
ActiveModel::StrictValidationFailed
```

### Именование

`ActiveModel::Naming` добавляет несколько методов класса, упрощающих управление именованием и роутингом. Модуль определяет метод класса `model_name`, который определит несколько акцессоров с помощью методов `ActiveSupport::Inflector`.

```ruby
class Person
  extend ActiveModel::Naming
end

Person.model_name.name                # => "Person"
Person.model_name.singular            # => "person"
Person.model_name.plural              # => "people"
Person.model_name.element             # => "person"
Person.model_name.human               # => "Person"
Person.model_name.collection          # => "people"
Person.model_name.param_key           # => "person"
Person.model_name.i18n_key            # => :person
Person.model_name.route_key           # => "people"
Person.model_name.singular_route_key  # => "person"
```

### Модель

`ActiveModel::Model` позволяет реализовывать модели, схоже с `ActiveRecord::Base`.

```ruby
class EmailContact
  include ActiveModel::Model

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # отправить электронную почту
    end
  end
end
```

При включении `ActiveModel::Model`, вы получите все особенности из `ActiveModel::API`.

### Сериализация

`ActiveModel::Serialization` предоставляет базовую сериализацию для вашего объекта. Вам необходимо объявить хэш, содержащий атрибуты, которые вы хотите сериализовать. Атрибуты должны быть строками, не символами.

```ruby
class Person
  include ActiveModel::Serialization

  attr_accessor :name

  def attributes
    {'name' => nil}
  end
end
```

Теперь можно получить доступ к сериализованному хэшу вашего объекта с помощью метода `serializable_hash`.

```irb
irb> person = Person.new
irb> person.serializable_hash
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.serializable_hash
=> {"name"=>"Bob"}
```

#### ActiveModel::Serializers

Active Model также предоставляет модуль `ActiveModel::Serializers::JSON` для сериализации/десериализации JSON. Этот модуль автоматически подключает ранее обсужденный модуль `ActiveModel::Serialization`.

##### ActiveModel::Serializers::JSON

Для использования `ActiveModel::Serializers::JSON` необходимо только изменить модуль, который вы подключали, с `ActiveModel::Serialization` на `ActiveModel::Serializers::JSON`.

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes
    {'name' => nil}
  end
end
```

Метод `as_json`, подобно `serializable_hash`, предоставляет хэш, описывающий модель.

```irb
irb> person = Person.new
irb> person.as_json
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.as_json
=> {"name"=>"Bob"}
```

Также можно определить атрибуты для модели из строки JSON. Однако, в классе нужно определить метод `attributes=`:

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes
    {'name' => nil}
  end
end
```

Теперь есть возможность создавать экземпляры `Person` и устанавливать атрибуты с помощью `from_json`.

```irb
irb> json = { name: 'Bob' }.to_json
irb> person = Person.new
irb> person.from_json(json)
=> #<Person:0x00000100c773f0 @name="Bob">
irb> person.name
=> "Bob"
```

### Перевод

`ActiveModel::Translation` предоставляет интеграцию между вашим объектом и фреймворком интернационализации Rails (i18n).

```ruby
class Person
  extend ActiveModel::Translation
end
```

С помощью метода `human_attribute_name` можно преобразовывать имена атрибутов в более удобочитаемый формат. Удобочитаемый формат определяется в вашем(-их) файле(-ах) локали.

* config/locales/app.pt-BR.yml

```yaml
pt-BR:
  activemodel:
    attributes:
      person:
        name: 'Nome'
```

```ruby
Person.human_attribute_name('name') # => "Nome"
```

### Тесты совместимости

`ActiveModel::Lint::Tests` позволяет проверить, совместим ли объект с Active Model API.

* `app/models/person.rb`

    ```ruby
    class Person
      include ActiveModel::Model
    end
    ```

* `test/models/person_test.rb`

    ```ruby
    require "test_helper"

    class PersonTest < ActiveSupport::TestCase
      include ActiveModel::Lint::Tests

      setup do
        @model = Person.new
      end
    end
    ```

```bash
$ bin/rails test

Run options: --seed 14596

# Running:

......

Finished in 0.024899s, 240.9735 runs/s, 1204.8677 assertions/s.

6 runs, 30 assertions, 0 failures, 0 errors, 0 skips
```

Объекту не нужно реализовывать все API, чтобы работать с Action Pack. Этот модуль всего лишь предназначен для руководства в случае, если вы хотите все особенности из коробки.

### SecurePassword

`ActiveModel::SecurePassword` предоставляет способ безопасно хранить любой пароль в зашифрованном виде. При включении этого модуля предоставляется метод класса `has_secure_password`, определяющий акцессор `password` с определенными валидациями на нем по умолчанию.

#### Требования

`ActiveModel::SecurePassword` зависит от [`bcrypt`](https://github.com/codahale/bcrypt-ruby 'BCrypt'), поэтому включите этот гем в свой `Gemfile` для правильного использования `ActiveModel::SecurePassword`. Чтобы он работал, в модели должен быть акцессор с именем `XXX_digest`. Где `XXX` это имя атрибута желаемого пароля. Следующие валидации добавляются автоматически:

1. Пароль должен существовать.
2. Пароль должен совпадать с подтверждением (проверяется, если передан `XXX_confirmation`).
3. Максимальная длина пароля 72 (требуется `bcrypt`, от которого зависит ActiveModel::SecurePassword)

#### Примеры

```ruby
class Person
  include ActiveModel::SecurePassword
  has_secure_password
  has_secure_password :recovery_password, validations: false

  attr_accessor :password_digest, :recovery_password_digest
end
```

```irb
irb> person = Person.new

# Когда пароль пустой.
irb> person.valid?
=> false

# Когда подтверждение не совпадает с паролем.
irb> person.password = 'aditya'
irb> person.password_confirmation = 'nomatch'
irb> person.valid?
=> false

# Когда длина пароля превышает 72.
irb> person.password = person.password_confirmation = 'a' * 100
irb> person.valid?
=> false

# Когда предоставлен только пароль без password_confirmation.
irb> person.password = 'aditya'
irb> person.valid?
=> true

# Когда проходят все валидации.
irb> person.password = person.password_confirmation = 'aditya'
irb> person.valid?
=> true

irb> person.recovery_password = "42password"

irb> person.authenticate('aditya')
=> #<Person> # == person
irb> person.authenticate('notright')
=> false
irb> person.authenticate_password('aditya')
=> #<Person> # == person
irb> person.authenticate_password('notright')
=> false

irb> person.authenticate_recovery_password('42password')
=> #<Person> # == person
irb> person.authenticate_recovery_password('notright')
=> false

irb> person.password_digest
=> "$2a$04$gF8RfZdoXHvyTjHhiU4ZsO.kQqV9oonYZu31PRE4hLQn3xM2qkpIy"
irb> person.recovery_password_digest
=> "$2a$04$iOfhwahFymCs5weB3BNH/uXkTG65HR.qpW.bNhEjFP3ftli3o5DQC"
```
