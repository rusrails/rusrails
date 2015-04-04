Основы Active Model
===================

Это руководство познакомит вас со всем необходимым для начала использования моделей классов. Active Model позволяет Actions Pack хелперам работать с объектами на чистом Ruby. Дополнительно, Active Model может помочь с созданием гибкой, настраиваемой ORM для использования вне фреймворка Rails.

После прочтение данного руководства, вы сможете добавить к объектам на чистом Ruby:

* Возможность вести себя как модель Active Record.
* Колбэки и валидации, как в Active Record.
* Сериализаторы.
* Интеграцию с фреймворком интернационализации Rails (i18n).

--------------------------------------------------------------------------------

Введение
--------

Библиотека Active Model содержит различные модули, используемые для разработки классов, которым необходимы некоторые особенности, присутствующие в Active Record. Некоторые из этих модулей описаны ниже.

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

person = Person.new
person.age = 110
person.age_highest?  # => true
person.reset_age     # => 0
person.age_highest?  # => false
```

### Колбэки

Модуль `ActiveModel::Callbacks` дает Active Record возможность использования функций обратного вызова (колбэков). Это позволяет определять колбэки, вызываемые в определенное время. После определения колбэков вы можете обернуть их дополнительным функционалом before, after и around которые позволяют определить момент вызова колбека до, после, и до и после вызова нужного метода.

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me

  def update
    run_callbacks(:update) do
      # Этот метод вызывается при вызове у обьекта метода update.
    end
  end

  def reset_me
    # Этот метод вызывается при вызове у обьекта метода update, выполнение метода reset_me произойдет до вызова update, т.к он определен как колбэк before_update
  end
end
```

### Преобразования

Если у класса определены методы `persisted?` и `id`, то вы можете добавить модуль `ActiveModel::Conversion` в этот класс и использовать методы преобразования Rails.

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

person = Person.new
person.to_model == person  # => true
person.to_key              # => nil
person.to_param            # => nil
```

### Dirty

Объект становится грязным после одного или нескольких изменений его атрибутов, и при этом он не сохранен. `ActiveModel::Dirty` дает возможность проверить объект, был ли он изменен или нет. Дополнительно представлены методы доступа атрибутов. Представим, что имеется класс `Person` с атрибутами `first_name` и `last_name`:

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
    # do save work...
    changes_applied
  end
end
```

#### Запрашиваем у объекта список всех измененных атрибутов.

```ruby
person = Person.new
person.changed? # => false

person.first_name = "First Name"
person.first_name # => "First Name"

# возвращает true, если был изменен хоть один атрибут
person.changed? # => true

# возвращает список измененных атрибутов
person.changed # => ["first_name"]

# возвращает "хэш" измененных атрибутов с их первоначальными значениями
person.changed_attributes # => {"first_name"=>nil}

# возвращает "хэш" изменений, с именами атрибутов и их значений, массив значений содержит старое и новое значение атрибута.
person.changes # => {"first_name"=>[nil, "First Name"]}
```

#### Mетоды доступа, основанные на атрибутах

Отслеживает, был ли атрибут изменен или нет.

```ruby
# attr_name_changed?
person.first_name # => "First Name"
person.first_name_changed? # => true
```

Отслеживает, какое было предыдущее значение атрибута.

```ruby
# метод доступа attr_name_was 
person.first_name_was # => nil
```

Отслеживает старое и новое значение измененного атрибута. Возвращает массив, если изменяли, иначе nil.

```ruby
# attr_name_change
person.first_name_change # => [nil, "First Name"]
person.last_name_change # => nil
```

### Валидации

Модуль `ActiveModel::Validations` добавляет возможность проверять объекты класса, как в Active Record.

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :email, :token

  validates :name, presence: true
  validates_format_of :email, with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i
  validates! :token, presence: true
end

person = Person.new
person.token = "2b1f325"
person.valid?                        # => false
person.name = 'vishnu'
person.email = 'me'
person.valid?                        # => false
person.email = 'me@vishnuatrai.com'
person.valid?                        # => true
person.token = nil
person.valid?                        # => raises ActiveModel::StrictValidationFailed
```

### Именование

`ActiveModel::Naming` добавляет ряд методов класса, упрощающие управление именованием и роутингом. Модуль определяет метод класса `model_name`, который определит несколько акцессоров с помощью методов `ActiveSupport::Inflector`.

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

`ActiveModel::Model` добавляет классу возможность работать из коробки с Action Pack и Action View.

```ruby
class EmailContact
  include ActiveModel::Model

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # deliver email
    end
  end
end
```

При включении `ActiveModel::Model` вы получите несколько возможностей, таких как:

- интроспекция имени модели
- конверсии
- переводы
- валидации

Он также дает возможность инициализировать объект с помощью хэша атрибутов, подобно любому объекту Active Record.

```ruby
email_contact = EmailContact.new(name: 'David',
                                 email: 'david@example.com',
                                 message: 'Hello World')
email_contact.name       # => 'David'
email_contact.email      # => 'david@example.com'
email_contact.valid?     # => true
email_contact.persisted? # => false
```

Любой класс, включающий `ActiveModel::Model`, может быть использован в `form_for`, `render` и любом другом методе хелпера Action View, точно так же, как и объекты Active Record.

### Сериализация

`ActiveModel::Serialization` представляет простую сериализацию для вашего объекта. Вам необходимо объявить хэш атрибутов, содержащий атрибуты, которые вы хотите сериализовать. Атрибуты должны быть строками, не символами.

```ruby
class Person
  include ActiveModel::Serialization

  attr_accessor :name

  def attributes
    {'name' => nil}
  end
end
```

Теперь будет доступен сериализованный хэш вашего объекта с помощью `serializable_hash`.

```ruby
person = Person.new
person.serializable_hash   # => {"name"=>nil}
person.name = "Bob"
person.serializable_hash   # => {"name"=>"Bob"}
```

#### ActiveModel::Serializers

Rails предоставляет два сериализатора: `ActiveModel::Serializers::JSON` и `ActiveModel::Serializers::Xml`. Оба из этих модуля автоматически подключают `ActiveModel::Serialization`.

##### ActiveModel::Serializers::JSON

Для использования `ActiveModel::Serializers::JSON` необходимо только изменить `ActiveModel::Serialization` на `ActiveModel::Serializers::JSON`.

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes
    {'name' => nil}
  end
end
```

С помощью `as_json` можно получить хэш, представляющий модель.

```ruby
person = Person.new
person.as_json # => {"name"=>nil}
person.name = "Bob"
person.as_json # => {"name"=>"Bob"}
```

Из строки JSON определяются атрибуты модели. В классе должен быть определен метод `attributes=`:

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

Теперь возможно создавать экземпляры person и устанавливать атрибуты с помощью `from_json`.

```ruby
json = { name: 'Bob' }.to_json
person = Person.new
person.from_json(json) # => #<Person:0x00000100c773f0 @name="Bob">
person.name            # => "Bob"
```

##### ActiveModel::Serializers::Xml

Для использования `ActiveModel::Serializers::Xml` необходимо только изменить `ActiveModel::Serialization` на `ActiveModel::Serializers::Xml`.

```ruby
class Person
  include ActiveModel::Serializers::Xml

  attr_accessor :name

  def attributes
    {'name' => nil}
  end
end
```

С помощью `to_xml` можно получить XML, представляющий модель.

```ruby
person = Person.new
person.to_xml # => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<person>\n  <name nil=\"true\"/>\n</person>\n"
person.name = "Bob"
person.to_xml # => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<person>\n  <name>Bob</name>\n</person>\n"
```

Из строки XML определяются атрибуты модели. В классе должен быть определен метод `attributes=`:

```ruby
class Person
  include ActiveModel::Serializers::Xml

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

Теперь возможно создавать экземпляры person и устанавливать атрибуты с помощью `from_xml`.

```ruby
xml = { name: 'Bob' }.to_xml
person = Person.new
person.from_xml(xml) # => #<Person:0x00000100c773f0 @name="Bob">
person.name          # => "Bob"
```

### Перевод

`ActiveModel::Translation` представляет интеграцию между вашим объектом и вреймворком интернационализации Rails (i18n).

```ruby
class Person
  extend ActiveModel::Translation
end
```

С помощью `human_attribute_name` можно преобразовывать имена атрибутов в более человечный формат. Человечный формат определяется в вашем файле локали.

* config/locales/app.pt-BR.yml

  ```yml
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

`ActiveModel::Lint::Tests` позволяет проверить, соответствует ли объект Active Model API.

* app/models/person.rb

    ```ruby
    class Person
      include ActiveModel::Model

    end
    ```

* test/models/person_test.rb

    ```ruby
    require 'test_helper'

    class PersonTest < ActiveSupport::TestCase
      include ActiveModel::Lint::Tests

      def setup
        @model = Person.new
      end
    end
    ```

```bash
$ rake test

Run options: --seed 14596

# Running:

......

Finished in 0.024899s, 240.9735 runs/s, 1204.8677 assertions/s.

6 runs, 30 assertions, 0 failures, 0 errors, 0 skips
```

Объекту не нужно реализовывать все API, чтобы работать с Action Pack. Этот модуль всего лишь предназначен для предоставления руководства в случае, если вы хотите все особенности из коробки.

### SecurePassword

`ActiveModel::SecurePassword` представляет способ безопасно хранить любой пароль в зашифрованной форме. При включении этого модуля предоставляется метод класса `has_secure_password`, определяющий акцессор с именем `password` с определенными валидациями на нем.

#### Требования

`ActiveModel::SecurePassword` зависит от [`bcrypt`](https://github.com/codahale/bcrypt-ruby 'BCrypt'), поэтому включите этот гем в свой Gemfile для корректного использования `ActiveModel::SecurePassword`. Чтобы он работал, в модели должен быть акцессор с именем `password_digest`. `has_secure_password` добавит следующие валидации на акцессор `password`:

1. Пароль должен присутствовать should be present.
2. Пароль должен быть равен его подтверждению.
3. Максимальная длина пароля 72 (требуется `bcrypt` от которого зависит ActiveModel::SecurePassword)

#### Примеры

```ruby
class Person
  include ActiveModel::SecurePassword
  has_secure_password
  attr_accessor :password_digest
end

person = Person.new

# Когда пароль пустой.
person.valid? # => false

# Когда подтверждение не совпадает с паролем.
person.password = 'aditya'
person.password_confirmation = 'nomatch'
person.valid? # => false

# Когда длина пароля превышает 72.
person.password = person.password_confirmation = 'a' * 100
person.valid? # => false

# Когда проходят все валидации.
person.password = person.password_confirmation = 'aditya'
person.valid? # => true
```
