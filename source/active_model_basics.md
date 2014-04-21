Основы Active Model
===================

Это руководство познакомит вас со всем необходимым для начала использования моделей классов. Active Model позволяет Actions Pack хелперам работать с не-Active Record моделями. Дополнительно, Active Model может помочь с созданием гибкой, настраиваемой ORM для использования вне фреймворка Rails.

После прочтение данного руководства, вы узнаете:

--------------------------------------------------------------------------------

Введение
--------

Библиотека Active Model содержит различные модули используемые для разработки фрейимворков, необходимых для взаимодействия с Rails Action Pack. Active Model содержит множество интерфейсов для использования в классах. Некоторые из модулей объясняются ниже.

### AttributeMethods

Модуль AttributeMethods позволяет добавлять различные суффиксы и префиксы к методам класса. Для использования необходимо определить суффиксы, префиксы, а также к каким методам объекта они будут применяться.

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
person.age_highest?  # true
person.reset_age     # 0
person.age_highest?  # false
```

### Callbacks

Модуль `Callbacks` дает Active Record возможность использования функций обратного вызова (колбэков). Это позволяет определять колбэки, вызываемые в определенное время. После определения колбэков вы можете обернуть их дополнительным функционалом before, after и around которые позволяют определить момент вызова колбека до, после, и до и после вызова нужного метода.

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

### Conversion

Если у класса определены методы `persisted?` и `id`, то вы можете добавить модуль `Conversion` в этот класс и использовать методы преобразования Rails.

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

Объект становится грязным после одного или нескольких изменений его атрибутов, и при этом он не сохранен. Данный модуль дает возможность проверить объект, был ли он изменен или нет. Дополнительно представлены методы доступа атрибутов. Представим, что имеется класс `Person` с атрибутами `first_name` и `last_name`:

```ruby
require 'active_model'

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
person.first_name_was # => "First Name"
```

Отслеживает старое и новое значение измененного атрибута. Возвращает массив, если изменяли, иначе nil.

```ruby
# attr_name_change
person.first_name_change # => [nil, "First Name"]
person.last_name_change # => nil
```

### Validations

Модуль валидаций добавляет возможность объекту класса проверять атрибуты в стиле Active Record.

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :email, :token

  validates :name, presence: true
  validates_format_of :email, with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i
  validates! :token, presence: true
end

person = Person.new(token: "2b1f325")
person.valid?                        # => false
person.name = 'vishnu'
person.email = 'me'
person.valid?                        # => false
person.email = 'me@vishnuatrai.com'
person.valid?                        # => true
person.token = nil
person.valid?                        # => raises ActiveModel::StrictValidationFailed
```
