Основы Active Model
===================

Это руководство познакомит вас со всем необходимым для начала использования Active Model. Active Model предоставляет способ хелперам Action Pack и Action View взаимодействовать с обычными объектами на чистом Ruby. Также он помогает с созданием гибкой, настраиваемой ORM для использования вне фреймворка Rails.

После прочтение данного руководства, вы узнаете:

* Что такое Active Model, и как он относится к Active Record.
* О разных модулях, включенных в Active Model.
* Как использовать Active Model в ваших классах.

--------------------------------------------------------------------------------

Что такое Active Model?
-----------------------

Чтобы понять Active Model, вам нужно немного знать об [Active Record](/active-record-basics). Active Record - это ORM (Object Relational Mapper), который соединяет объекты, данные которых требуют постоянного хранения, с реляционной базой данных. Однако он обладает функциональностью, которая полезна вне ORM, например, валидация, колбэки, переводы, возможность создавать пользовательские атрибуты и т.д.

Некоторые из этих функций были абстрагированы из Active Record для формирования Active Model. Active Model - это библиотека, содержащая различные модули, которые можно использовать для обычных объектов Ruby, которым требуются функции, похожие на модели, но которые не привязаны к какой-либо таблице в базе данных.

Итак, Active Record предоставляет интерфейс для определения моделей, соответствующих таблицам базы данных, а Active Model предоставляет функционал для создания похожих на модели классов Ruby, которым не обязательно требуется поддержка базы данных. Active Model можно использовать независимо от Active Record.

Некоторые из этих модулей описаны ниже.

### API

[`ActiveModel::API`](https://api.rubyonrails.org/classes/ActiveModel/API.html) добавляет возможность классу работать с [Action Pack](https://api.rubyonrails.org/files/actionpack/README_rdoc.html) и [Action View](/action-view-overview) прямо из коробки.

При включении `ActiveModel::API`, по умолчанию включаются другие модули, добавляющие особенности, такие как:

- [Назначение атрибутов](#attribute-assignment)
- [Преобразование](#conversion)
- [Именование](#naming)
- [Перевод](#translation)
- [Валидации](#validations)

Вот пример класса, включающего `ActiveModel::API`, и как его можно использовать:

```ruby
class EmailContact
  include ActiveModel::API

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # Доставляем письмо
    end
  end
end
```

```irb
irb> email_contact = EmailContact.new(name: "David", email: "david@example.com", message: "Hello World")

irb> email_contact.to_model == email_contact # Преобразование
=> true

irb> email_contact.model_name.name # Именование
=> "EmailContact"

irb> EmailContact.human_attribute_name("name") # Перевод, если установлена локаль
=> "Name"

irb> email_contact.valid? # Валидации
=> true

irb> empty_contact = EmailContact.new
irb> empty_contact.valid?
=> false
```

Любой класс, включающий `ActiveModel::API`, может быть использован с `form_with`, `render` и любыми другими [вспомогательными методами Action View](https://api.rubyonrails.org/classes/ActionView/Helpers.html), точно так же, как и объекты Active Record.

Например, `form_with` можно использовать, чтобы создать форму для объекта `EmailContact` следующим образом:

```html+erb
<%= form_with model: EmailContact.new do |form| %>
  <%= form.text_field :name %>
<% end %>
```

что приведет к следующему HTML:

```html
<form action="/email_contacts" method="post">
  <input type="text" name="email_contact[name]" id="email_contact_name">
</form>
```

`render` может быть использован для отрисовки партиала с объектом:

```html+erb
<%= render @email_contact %>
```

NOTE: Дополнительную информацию об использовании `form_with` и `render` с объектами, совместимыми с `ActiveModel::API`, можно найти в руководствах [по хелперам форм](/form-helpers) и [по макетам и рендерингу](layouts-and-rendering) соответственно.

### Модель

[`ActiveModel::Model`](https://api.rubyonrails.org/classes/ActiveModel/Model.html) по умолчанию включает [ActiveModel::API](#api) для взаимодействия с Action Pack и Action View. Это рекомендуемый подход для реализации Ruby-классов, похожих на модели. В будущем он будет расширен для добавления дополнительных функций.

```ruby
class Person
  include ActiveModel::Model

  attr_accessor :name, :age
end
```

```irb
irb> person = Person.new(name: 'bob', age: '18')
irb> person.name # => "bob"
irb> person.age  # => "18"
```

### Атрибуты

[`ActiveModel::Attributes`](https://api.rubyonrails.org/classes/ActiveModel/Attributes.html) позволяет определять типы данных, устанавливать значения по умолчанию, а также обрабатывать преобразование и сериализацию для обычных объектов Ruby. Это может быть полезно для данных форм, которые будут выполнять преобразование, похожее на Active Record, для таких вещей, как даты и логические значения в обычных объектах.

Для того, чтобы использовать `Attributes`, включите этот модуль в ваш класс модели и определите свои атрибуты с помощью макроса `attribute`. Он принимает имя, тип приведения, значение по умолчанию и любые другие опции, поддерживаемые типом атрибута.

```ruby
class Person
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :date_of_birth, :date
  attribute :active, :boolean, default: true
end
```

```irb
irb> person = Person.new

irb> person.name = "Jane"
irb> person.name
=> "Jane"

# Преобразует строку в дату, установленную атрибутом
irb> person.date_of_birth = "2020-01-01"
irb> person.date_of_birth
=> Wed, 01 Jan 2020
irb> person.date_of_birth.class
=> Date

# Использует значение по умолчанию, установленное атрибутом
irb> person.active
=> true

# Преобразует число в логическое значение, установленное атрибутом
irb> person.active = 0
irb> person.active
=> false
```

При использовании `ActiveModel::Attributes` доступны дополнительные методы, описанные ниже.

#### Метод: `attribute_names`

Метод `attribute_names` возвращает массив имен атрибутов.

```irb
irb> Person.attribute_names
=> ["name", "date_of_birth", "active"]
```

#### Метод: `attributes`

Метод `attributes` возвращает хэш всех атрибутов с их именами в качестве ключей и значениями атрибутов в качестве значений.

```irb
irb> person.attributes
=> {"name" => "Jane", "date_of_birth" => Wed, 01 Jan 2020, "active" => false}
```

### (attribute-assignment) Назначение Атрибутов

[`ActiveModel::AttributeAssignment`](https://api.rubyonrails.org/classes/ActiveModel/AttributeAssignment.html) позволяет устанавливать атрибуты объекта путем передачи хэша атрибутов, где ключи соответствуют именам атрибутов. Это удобно, когда вы хотите установить сразу несколько атрибутов.

Рассмотрим следующий класс:

```ruby
class Person
  include ActiveModel::AttributeAssignment

  attr_accessor :name, :date_of_birth, :active
end
```

```irb
irb> person = Person.new

# Устанавливаем несколько атрибутов за раз
irb> person.assign_attributes(name: "John", date_of_birth: "1998-01-01", active: false)

irb> person.name
=> "John"
irb> person.date_of_birth
=> Thu, 01 Jan 1998
irb> person.active
=> false
```

Если переданный хеш отвечает на метод `permitted?` и возвращаемое значение этого метода равно `false`, то возникает исключение `ActiveModel::ForbiddenAttributesError`.

NOTE: `permitted?` используется для интеграции со [strong params](https://guides.rubyonrails.org/action_controller_overview.html#strong-parameters) при назначении атрибута params из запроса.

```irb
irb> person = Person.new

# Используется проверка strong parameters, создаем хэш атрибутов, подобный params из запроса
irb> params = ActionController::Parameters.new(name: "John")
=> #<ActionController::Parameters {"name" => "John"} permitted: false>

irb> person.assign_attributes(params)
=> # Вызывает ActiveModel::ForbiddenAttributesError
irb> person.name
=> nil

# Разрешаем атрибуты, для которых мы желаем разрешить назначение
irb> permitted_params = params.permit(:name)
=> #<ActionController::Parameters {"name" => "John"} permitted: true>

irb> person.assign_attributes(permitted_params)
irb> person.name
=> "John"
```

#### Псевдоним метода: `attributes=`

Метод `assign_attributes` имеет псевдоним `attributes=`.

INFO: Псевдоним метода - это метод, который выполняет то же самое действие, что и другой метод, но называется по-другому. Псевдонимы существуют для улучшения читаемости и удобства.

В следующем примере показано использование метода `attributes=` для одновременной установки нескольких атрибутов:

```irb
irb> person = Person.new

irb> person.attributes = { name: "John", date_of_birth: "1998-01-01", active: false }

irb> person.name
=> "John"
irb> person.date_of_birth
=> "1998-01-01"
```

INFO: `assign_attributes` и `attributes=` - оба являются вызовами методов и принимают в качестве аргумента хэш атрибутов для назначения. Во многих случаях в Ruby разрешено опускать круглые скобки `()` при вызове метода и фигурные скобки `{}` при определении хэша. <br><br>
Методы-сеттеры, такие как `attributes=`, обычно пишутся без скобок `()`, хотя их использование не приведет к ошибкам. Однако хэш в таком случае всегда должен быть заключен в фигурные скобки `{}`. Например, `person.attributes=({ name: "John" })` - это правильно, а `person.attributes = name: "John"` приведет к ошибке `SyntaxError`.<br><br>
Другие вызовы методов вроде `assign_attributes` могут принимать хэш-аргумент как с круглыми скобками `()`, так и с фигурными скобками `{}`. Например, `assign_attributes name: "John"` и `assign_attributes({ name: "John" })` - оба варианта являются корректным кодом Ruby. Однако запись `assign_attributes { name: "John" }` вызовет ошибку `SyntaxError`, поскольку Ruby не сможет отличить хэш-аргумент от блока кода.

### Методы атрибутов
[`ActiveModel::AttributeMethods`](https://api.rubyonrails.org/classes/ActiveModel/AttributeMethods.html) позволяет динамически определять методы для атрибутов модели. Этот модуль особенно полезен для упрощения доступа к атрибутам и их обработки. Он также может добавлять пользовательские префиксы и суффиксы к методам класса. Для определения префиксов, суффиксов и методов, их использующих, выполните следующие действия:

1. Включите `ActiveModel::AttributeMethods` в ваш класс.
2. Вызовите необходимые методы, такие как `attribute_method_suffix`, `attribute_method_prefix`, `attribute_method_affix`.
3. После вызова других методов вызовите `define_attribute_methods` для указания атрибутов, к которым следует применять префикс и суффикс.
4. Определите различные общие методы `_attribute`, которые вы объявили. Параметр `attribute` в этих методах будет заменен аргументом, переданным в `define_attribute_methods`. В приведенном ниже примере это `name`.

NOTE: `attribute_method_prefix` и `attribute_method_suffix` используются для определения префиксов и суффиксов, которые будут использоваться для создания методов. `attribute_method_affix` используется для одновременного определения как префикса, так и суффикса.

```ruby
class Person
  include ActiveModel::AttributeMethods

  attribute_method_affix prefix: "reset_", suffix: "_to_default!"
  attribute_method_prefix "first_", "last_"
  attribute_method_suffix "_short?"

  define_attribute_methods "name"

  attr_accessor :name

  private
    # Вызов метода атрибута для 'first_name'
    def first_attribute(attribute)
      public_send(attribute).split.first
    end

    # Вызов метода атрибута для 'last_name'
    def last_attribute(attribute)
      public_send(attribute).split.last
    end

    # Вызов метода атрибута для 'name_short?'
    def attribute_short?(attribute)
      public_send(attribute).length < 5
    end

    # Вызов метода атрибута 'reset_name_to_default!'
    def reset_attribute_to_default!(attribute)
      public_send("#{attribute}=", "Default Name")
    end
end
```

```irb
irb> person = Person.new
irb> person.name = "Jane Doe"

irb> person.first_name
=> "Jane"
irb> person.last_name
=> "Doe"

irb> person.name_short?
=> false

irb> person.reset_name_to_default!
=> "Default Name"
```

Если вы вызовете метод, который не определен, возникнет ошибка `NoMethodError`.

#### Метод: `alias_attribute`

`ActiveModel::AttributeMethods` позволяет создавать псевдонимы для методов атрибутов с помощью метода `alias_attribute`.

В примере ниже создается псевдонимный атрибут для `name` под названием `full_name`. Они возвращают одно и то же значение, но псевдоним `full_name` лучше отражает тот факт, что атрибут включает в себя имя и фамилию.

```ruby
class Person
  include ActiveModel::AttributeMethods

  attribute_method_suffix "_short?"
  define_attribute_methods :name

  attr_accessor :name

  alias_attribute :full_name, :name

  private
    def attribute_short?(attribute)
      public_send(attribute).length < 5
    end
end
```

```irb
irb> person = Person.new
irb> person.name = "Joe Doe"
irb> person.name
=> "Joe Doe"

# `full_name` - псевдоним для `name`, и возвращает то же самое значение
irb> person.full_name
=> "Joe Doe"
irb> person.name_short?
=> false

# `full_name_short?` псевдоним для `name_short?`, и возвращает то же самое значение
irb> person.full_name_short?
=> false
```

### Колбэки

[`ActiveModel::Callbacks`](https://api.rubyonrails.org/classes/ActiveModel/Callbacks.html) предоставляет обычным объектам Ruby возможность использовать [колбэки в стиле Active Record](/active-record-callbacks). Колбэки позволяют вам подключаться к событиям жизненного цикла модели, таким как `before_update` и `after_create`, а также определять собственную логику, которая будет выполняться в определенные моменты жизненного цикла модели.

Вы можете реализовать `ActiveModel::Callbacks`, выполнив следующие действия:

1. Расширьте ваш класс с помощью `ActiveModel::Callbacks`.
2. Используйте `define_model_callbacks` для определения списка методов, с которыми должны быть связаны колбэки. Когда вы указываете метод, такой как `:update`, он автоматически включает все три колбэка по умолчанию (`before`, `around` и `after`) для события `:update`.
3. Внутри определенного метода используйте `run_callbacks`, который выполнит цепочку колбэков, когда будет вызвано определенное событие.
4. Затем в своем классе вы можете использовать методы `before_update`, `after_update` и `around_update` так же, как вы использовали бы их в модели Active Record.

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me
  after_update :finalize_me
  around_update :log_me

  # метод `define_model_callbacks` содержит `run_callbacks`, который запустит колбэк(и) для заданного события
  def update
    run_callbacks(:update) do
      puts "update method called"
    end
  end

  private
    # Когда на объекте вызван update, этот метод будет вызван колбэком `before_update`
    def reset_me
      puts "reset_me method: called before the update method"
    end

    # Когда на объекте вызван update, этот метод будет вызван колбэком `after_update`
    def finalize_me
      puts "finalize_me method: called after the update method"
    end

    # Когда на объекте вызван update, этот метод будет вызван колбэком `around_update`
    def log_me
      puts "log_me method: called around the update method"
      yield
      puts "log_me method: block successfully called"
    end
end
```

Класс, описанный выше, выведет следующее, что указывает на очередность вызова колбэков:

```irb
irb> person = Person.new
irb> person.update
reset_me method: called before the update method
log_me method: called around the update method
update method called
log_me method: block successfully called
finalize_me method: called after the update method
=> nil
```

В соответствии с приведенным выше примером, при определении колбэка 'around' необходимо выполнять `yield` для блока, иначе он не будет выполнен.

NOTE: `method_name`, передаваемый в `define_model_callbacks`, не должен заканчиваться на `!`, `?` или `=`. Кроме того, многократное определение одного и того же колбэка перезапишет предыдущие определения колбэков.

#### Определение конкретных колбэков

Вы можете создавать определенные колбэки, передавая опцию `only` методу `define_model_callbacks`:

```ruby
define_model_callbacks :update, :create, only: [:after, :before]
```

Это создаст только колбэки `before_create` / `after_create` и `before_update` / `after_update`, пропуская `around_*`. Опция будет применяться ко всем колбэкам, определенным в данном вызове метода. Можно вызвать `define_model_callbacks` несколько раз, чтобы указать разные события жизненного цикла:

```ruby
define_model_callbacks :create, only: :after
define_model_callbacks :update, only: :before
define_model_callbacks :destroy, only: :around
```

В этом случае будут созданы только методы `after_create`, `before_update` и `around_destroy`.

#### Определение колбэков с классом

Для большего контроля над тем, когда и в каком контексте будут вызваны ваши колбэки, вы можете передать класс в `before_<type>`, `after_<type>` и `around_<type>`. колбэк вызовет метод `<action>_<type>` этого класса, передав экземпляр класса в качестве аргумента.

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :create
  before_create PersonCallbacks
end

class PersonCallbacks
  def self.before_create(obj)
    # `obj` - экземпляр Person, для которого вызывается колбэк
    end
  end
end
```

#### Прерывание колбэков

Цепочку колбэков можно прервать в любой момент времени, выбросив `:abort`. Это аналогично работе колбэков Active Record.

В приведенном ниже примере, поскольку мы бросаем `:abort` перед обновлением в методе `reset_me`, оставшаяся цепочка колбэков, включая `before_update`, будет прервана, и тело метода `update` не будет выполнено.

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me
  after_update :finalize_me
  around_update :log_me

  def update
    run_callbacks(:update) do
      puts "update method called"
    end
  end

  private
    def reset_me
      puts "reset_me method: called before the update method"
      throw :abort
      puts "reset_me method: some code after abort"
    end

    def finalize_me
      puts "finalize_me method: called after the update method"
    end

    def log_me
      puts "log_me method: called around the update method"
      yield
      puts "log_me method: block successfully called"
    end
end
```

```irb
irb> person = Person.new

irb> person.update
reset_me method: called before the update method
=> false
```

### (Conversion) Преобразование

[`ActiveModel::Conversion`](https://api.rubyonrails.org/classes/ActiveModel/Conversion.html) - это набор методов для преобразования объекта в различные форматы для различных целей. Обычно используется для преобразования объекта в строку или число для построения URL, полей формы и так далее.

Модуль `ActiveModel::Conversion` добавляет классам следующие методы: `to_model`, `to_key`, `to_param` и `to_partial_path`.

Возвращаемое значение методов зависит от определения `persisted?` и наличия `id`. Метод `persisted?` должен возвращать `true`, если объект был сохранен в базе данных или хранилище, в противном случае должен возвращать `false`. `id` должен возвращать идентификатор объекта, если он был сохранен, или nil, если не был сохранен.

```ruby
class Person
  include ActiveModel::Conversion
  attr_accessor :id

  def initialize(id)
    @id = id
  end

  def persisted?
    id.present?
  end
end
```

#### to_model

Метод `to_model` возвращает сам объект.

```irb
irb> person = Person.new(1)
irb> person.to_model == person
=> true
```

Если ваша модель не ведёт себя как объект Active Model, вам следует определить метод `:to_model` самостоятельно. Он должен возвращать прокси-объект, который заворачивает ваш объект и предоставляет методы, совместимые с Active Model.

```ruby
class Person
  def to_model
    # A proxy object that wraps your object with Active Model compliant methods.
    PersonModel.new(self)
  end
end
```

#### to_key

Метод `to_key` возвращает массив ключевых атрибутов объекта, если таковые имеются, независимо от того, сохранен ли объект. Если ключевых атрибутов нет, метод возвращает nil.

```irb
irb> person.to_key
=> [1]
```

NOTE: Ключевой атрибут - это атрибут, используемый для идентификации объекта. Например, в модели, поддерживаемой базой данных, ключевым атрибутом является первичный ключ.

#### to_param

Метод `to_param` возвращает строковое представление ключа объекта, пригодное для использования в URL, или `nil`, если метод `persisted?` возвращает `false`.

```irb
irb> person.to_param
=> "1"
```

#### to_partial_path

Метод `to_partial_path` возвращает строку, представляющую путь, связанный с объектом. Action Pack использует этот путь для поиска подходящего партиала для отображения объекта.

```irb
irb> person.to_partial_path
=> "people/person"
```

### Грязный объект

[`ActiveModel::Dirty`](https://api.rubyonrails.org/classes/ActiveModel/Dirty.html) - это полезный инструмент в Ruby on Rails, который позволяет отслеживать изменения, внесенные в атрибуты модели перед их сохранением. Эта функциональность позволяет вам определить, какие атрибуты объекта были изменены, каковы их предыдущие и текущие значения, и выполнять действия на основе этих изменений. Это особенно полезно для аудита, проверки данных и условной логики в вашем приложении. Он позволяет отслеживать изменения в вашем объекте так же, как и в Active Record.

Объект становится грязным после одного или нескольких изменений его атрибутов, и при этом он не был сохранен. У него имеются акцессор-методы на основе атрибутов.

Для использования `ActiveModel::Dirty` необходимо выполнить следующие шаги:

1. Подключите модуль в ваш класс.
2. Определите методы атрибутов, изменения которых вы хотите отслеживать, с помощью `define_attribute_methods`.
3. Вызовите `[attr_name]_will_change!` перед каждым изменением отслеживаемого атрибута.
4. Вызовите `changes_applied` после сохранения изменений.
5. Вызовите `clear_changes_information` для сброса информации об изменениях, когда это необходимо.
6. Используйте `restore_attributes` для восстановления предыдущих данных объекта.

После этого вы можете использовать методы, предоставляемые `ActiveModel::Dirty`, чтобы запросить у объекта список всех измененных атрибутов, их исходные значения и внесенные изменения.

Рассмотрим класс `Person` с атрибутами `first_name` и `last_name` и определим, как использовать `ActiveModel::Dirty` для отслеживания изменений этих атрибутов.

```ruby
class Person
  include ActiveModel::Dirty

  attr_reader :first_name, :last_name
  define_attribute_methods :first_name, :last_name

  def initialize
    @first_name = nil
    @last_name = nil
  end

  def first_name=(value)
    first_name_will_change! unless value == @first_name
    @first_name = value
  end

  def last_name=(value)
    last_name_will_change! unless value == @last_name
    @last_name = value
  end

  def save
    # Записываем данные - очищает грязные данные и перемещает `changes` в `previous_changes`.
    changes_applied
  end

  def reload!
    # Очищает все грязные данные: текущие изменения и предыдущие изменения.
    clear_changes_information
  end

  def rollback!
    # Восстанавливает все предыдущие данные предоставленных атрибутов.
    restore_attributes
  end
end
```

#### Прямой запрос к объекту о списке всех измененных атрибутов

```irb
irb> person = Person.new

# Вновь инициализированный объект `Person` неизмененный:
irb> person.changed?
=> false

irb> person.first_name = "Jane Doe"
irb> person.first_name
=> "Jane Doe"
```

**`changed?`** возвращает `true` если любой из атрибутов имеет несохраненные изменения, в противном случае `false`.

```irb
irb> person.changed?
=> true
```

**`changed`** возвращает массив с именем атрибутов, содержащих несохраненные изменения.

```irb
irb> person.changed
=> ["first_name"]
```

**`changed_attributes`** возвращает хэш атрибутов с несохраненными изменениями, указывающий их изначальные значения, наподобие `attr => original value`.

```irb
irb> person.changed_attributes
=> {"first_name" => nil}
```

**`changes`** возвращает хэш изменений с именами атрибутов в качестве ключей и значениями массивами из оригинального и нового значений, наподобие `attr => [original value, new value]`.

```
irb> person.changes
=> {"first_name" => [nil, "Jane Doe"]}
```

**`previous_changes`** возвращает хэш атрибутов, которые были изменены до того, как модель была сохранена (то есть до вызова `changes_applied`).

```irb
irb> person.previous_changes
=> {}

irb> person.save
irb> person.previous_changes
=> {"first_name" => [nil, "Jane Doe"]}
```

#### Акцессор-методы на основе атрибутов

```irb
irb> person = Person.new

irb> person.changed?
=> false

irb> person.first_name = "John Doe"
irb> person.first_name
=> "John Doe"
```

**`[attr_name]_changed?`** проверяет, был ли некоторый атрибут изменен или нет.

```
irb> person.first_name_changed?
=> true
```

**`[attr_name]_was`** отслеживает предыдущее значение атрибута.

```irb
irb> person.first_name_was
=> nil
```

**`[attr_name]_change`** отслеживает оба предыдущее и текущее значения измененного атрибута. Возвращает массив с `[original value, new value]`, если изменен, в противном случае `nil`.

```irb
irb> person.first_name_change
=> [nil, "John Doe"]
irb> person.last_name_change
=> nil
```

**`[attr_name]_previously_changed?`** проверяет, был ли некоторый атрибут изменен до сохранения модели (то есть до вызова `changes_applied`).

```irb
irb> person.first_name_previously_changed?
=> false
irb> person.save
irb> person.first_name_previously_changed?
=> true
```

**`[attr_name]_previous_change`** отслеживает оба предыдущее и текущее значения измененного атрибута до сохранения модели (то есть до вызова `changes_applied`). Возвращает массив с `[original value, new value]`, если изменен, в противном случае `nil`.

```irb
irb> person.first_name_previous_change
=> [nil, "John Doe"]
```

### (Naming) Именование

[`ActiveModel::Naming`](https://api.rubyonrails.org/classes/ActiveModel/Naming.html) добавляет метод класса и вспомогательные методы для упрощения именования и управления маршрутизацией. Модуль определяет метод класса `model_name`, который с помощью методов из [`ActiveSupport::Inflector`](https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html) создает несколько акцессоров.

```ruby
class Person
  extend ActiveModel::Naming
end
```

**`name`** возвращает имя модели.

```irb
irb> Person.model_name.name
=> "Person"
```

**`singular`** возвращает имя в единственном числе записи или класса.

```irb
irb> Person.model_name.singular
=> "person"
```

**`plural`** возвращает имя во множественном числе записи или класса.

```irb
irb> Person.model_name.plural
=> "people"
```

**`element`** удаляет пространство имен и возвращает имя в единственном числе snake_cased. Обычно этот метод используется хелперами Action Pack и/или Action View для помощи в отрисовке по имени партиалов/форм.

```irb
irb> Person.model_name.element
=> "person"
```

**`human`** преобразует название модели в более понятный для человека формат, используя библиотеку I18n. По умолчанию он применяет знак подчеркивания, а затем преобразует его в более читаемый вид.

```irb
irb> Person.model_name.human
=> "Person"
```

**`collection`** удаляет пространство имен и возвращает имя во множественном числе snake_cased. Обычно этот метод используется хелперами Action Pack и/или Action View для помощи в отрисовке по имени партиалов/форм.

```irb
irb> Person.model_name.collection
=> "people"
```

**`param_key`** возвращает строку для использования в именах параметров.

```irb
irb> Person.model_name.param_key
=> "person"
```

**`i18n_key`** возвращает имя ключа i18n. Он применяет знак подчеркивания к имени модели и затем возвращает как символ.

```irb
irb> Person.model_name.i18n_key
=> :person
```

**`route_key`** возвращает строку при генерации имен маршрутов.

```irb
irb> Person.model_name.route_key
=> "people"
```

**`singular_route_key`** возвращает строку при генерации имен маршрутов.

```irb
irb> Person.model_name.singular_route_key
=> "person"
```

**`uncountable?`** идентифицирует, является ли имя записи или класса исчисляемым.

```irb
irb> Person.model_name.uncountable?
=> false
```

NOTE: Некоторые методы `Naming`, такие как `param_key`, `route_key` и `singular_route_key`, ведут себя по-разному для моделей с пространством имен в зависимости от того, находятся ли они внутри изолированного [Engine](/engines).

#### Настройка названия модели

Иногда вы можете захотеть изменить название модели, которое используется в хелперах форм и генерации URL. Это может быть полезно в ситуациях, когда вы хотите использовать более понятное для пользователя название модели, при этом сохраняя возможность ссылаться на нее с использованием полного пространства имен.

Например, предположим, в вашем Rails-приложении есть пространство имен `Person`, и вы хотите создать форму для нового `Person::Profile`.

По умолчанию Rails сгенерирует форму с URL `/person/profiles`, который включает пространство имен `person`. Однако, если вы хотите, чтобы URL просто указывал на `profiles` без пространства имен, вы можете настроить метод `model_name` следующим образом:

```ruby
module Person
  class Profile
    include ActiveModel::Model

    def self.model_name
      ActiveModel::Name.new(self, nil, "Profile")
    end
  end
end
```

При такой настройке, когда вы используете хелпер `form_with` для создания формы добавления нового объекта `Person::Profile`, Rails сгенерирует форму с URL `/profiles` вместо `/person/profiles`. Это происходит потому, что метод `model_name` переопределен для возвращения значения `Profile`.

Помимо этого, хелперы путей будут генерироваться без пространства имен, поэтому вы сможете использовать `profiles_path` вместо `person_profiles_path` для генерации URL к ресурсу `profiles`. Для использования хелпера `profiles_path` вам необходимо определить маршруты для модели `Person::Profile` в файле `config/routes.rb` следующим образом:

```ruby
Rails.application.routes.draw do
  resources :profiles
end
```

Следовательно, для методов, описанных в предыдущем разделе, модель будет возвращать следующие значения:

```irb
irb> name = ActiveModel::Name.new(Person::Profile, nil, "Profile")
=> #<ActiveModel::Name:0x000000014c5dbae0

irb> name.singular
=> "profile"
irb> name.singular_route_key
=> "profile"
irb> name.route_key
=> "profiles"
```

### SecurePassword

[`ActiveModel::SecurePassword`](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword.html) предназначен для безопасного хранения паролей в зашифрованном виде. При подключении этого модуля появляется метод класса `has_secure_password`, который по умолчанию определяет акцессор `password` с некоторыми встроенными валидациями.

Для работы `ActiveModel::SecurePassword` необходима библиотека [`bcrypt`](https://github.com/bcrypt-ruby/bcrypt-ruby 'BCrypt'), для ее использования добавьте этот гем в ваш `Gemfile`.

```ruby
gem "bcrypt"
```

`ActiveModel::SecurePassword` требует наличия атрибута `password_digest`.

Он также автоматически добавляет следующие валидации:

1. Обязательное наличие пароля при создании.
2. Подтверждение пароля (с помощью атрибута `password_confirmation`).
3. Максимальная длина пароля составляет 72 символа (ограничение библиотеки `bcrypt`, которая обрезает строку перед шифрованием).

NOTE: Если подтверждение пароля не требуется, просто оставьте поле `password_confirmation` пустым (т.е. не включайте его в форму). При значении `nil` этого атрибута валидация подтверждения не будет выполняться.

Для дополнительной настройки можно отключить все валидации по умолчанию, передав аргумент `validations: false`.

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

# Когда подтверждение не соответствует паролю.
irb> person.password = "aditya"
irb> person.password_confirmation = "nomatch"
irb> person.valid?
=> false

# Когда длина пароля превышает 72.
irb> person.password = person.password_confirmation = "a" * 100
irb> person.valid?
=> false

# Когда предоставлен только password без password_confirmation.
irb> person.password = "aditya"
irb> person.valid?
=> true

# Когда все валидации проходят.
irb> person.password = person.password_confirmation = "aditya"
irb> person.valid?
=> true

irb> person.recovery_password = "42password"

# `authenticate` это псевдоним для `authenticate_password`
irb> person.authenticate("aditya")
=> #<Person> # == person
irb> person.authenticate("notright")
=> false
irb> person.authenticate_password("aditya")
=> #<Person> # == person
irb> person.authenticate_password("notright")
=> false

irb> person.authenticate_recovery_password("aditya")
=> false
irb> person.authenticate_recovery_password("42password")
=> #<Person> # == person
irb> person.authenticate_recovery_password("notright")
=> false

irb> person.password_digest
=> "$2a$04$gF8RfZdoXHvyTjHhiU4ZsO.kQqV9oonYZu31PRE4hLQn3xM2qkpIy"
irb> person.recovery_password_digest
=> "$2a$04$iOfhwahFymCs5weB3BNH/uXkTG65HR.qpW.bNhEjFP3ftli3o5DQC"
```

### Сериализация

[`ActiveModel::Serialization`](https://api.rubyonrails.org/classes/ActiveModel/Serialization.html) предназначен для базовой сериализации объектов. Вам потребуется определить хэш атрибутов, который будет содержать атрибуты, которые вы хотите сериализовать. Атрибуты должны быть строками, а не символами.

```ruby
class Person
  include ActiveModel::Serialization

  attr_accessor :name, :age

  def attributes
    # Определение сериализуемых атрибутов
    { "name" => nil, "age" => nil }
  end

  def capitalized_name
    # Объявленные методы потом могут быть включены в сериализованный хэш
    name&.capitalize
  end
end
```

Теперь вы можете получить сериализованный хэш вашего объекта с помощью метода `serializable_hash`. Допустимые опции для `serializable_hash` включают `:only`, `:except`, `:methods` и `:include`.

```irb
irb> person = Person.new

irb> person.serializable_hash
=> {"name" => nil, "age" => nil}

# Устанавливаем атрибуты name и age и сериализуем объект
irb> person.name = "bob"
irb> person.age = 22
irb> person.serializable_hash
=> {"name" => "bob", "age" => 22}

# Используем опцию methods для включения метода capitalized_name
irb>  person.serializable_hash(methods: :capitalized_name)
=> {"name" => "bob", "age" => 22, "capitalized_name" => "Bob"}

# Используем опцию only для включения только атрибута name
irb> person.serializable_hash(only: :name)
=> {"name" => "bob"}

# Используем опцию except для исключения атрибута name
irb> person.serializable_hash(except: :name)
=> {"age" => 22}
```

Пример использования опции `includes` требует немного более сложной ситуации, как описано ниже:

```ruby
  class Person
    include ActiveModel::Serialization
    attr_accessor :name, :notes # Эмулируем has_many :notes

    def attributes
      { "name" => nil }
    end
  end

  class Note
    include ActiveModel::Serialization
    attr_accessor :title, :text

    def attributes
      { "title" => nil, "text" => nil }
    end
  end
```

```irb
irb> note = Note.new
irb> note.title = "Weekend Plans"
irb> note.text = "Some text here"

irb> person = Person.new
irb> person.name = "Napoleon"
irb> person.notes = [note]

irb> person.serializable_hash
=> {"name" => "Napoleon"}

irb> person.serializable_hash(include: { notes: { only: "title" }})
=> {"name" => "Napoleon", "notes" => [{"title" => "Weekend Plans"}]}
```

#### ActiveModel::Serializers::JSON

Active Model также предоставляет модуль [`ActiveModel::Serializers::JSON`](https://api.rubyonrails.org/classes/ActiveModel/Serializers/JSON.html) для сериализации / десериализации в формат JSON.

Для использования сериализации в JSON формате замените подключаемый модуль с `ActiveModel::Serialization` на `ActiveModel::Serializers::JSON`. Он уже включает в себя функциональность предыдущего, поэтому его отдельное подключение не требуется.

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes
    { "name" => nil }
  end
end
```

Метод `as_json`, как и `serializable_hash`, возвращает хэш, представляющий модель, где ключи являются строками. Метод `to_json` возвращает строку в формате JSON, представляющую модель.

```irb
irb> person = Person.new

# Хэш, представляющий модель, где ключи - это строки.
irb> person.as_json
=> {"name" => nil}

# Строка JSON, представляющая модель
irb> person.to_json
=> "{\"name\":null}"

irb> person.name = "Bob"
irb> person.as_json
=> {"name" => "Bob"}

irb> person.to_json
=> "{\"name\":\"Bob\"}"
```

Также можно определить атрибуты для модели из строки JSON. Для этого сначала нужно определить в классе метод `attributes=`:

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes=(hash)
    hash.each do |key, value|
      public_send("#{key}=", value)
    end
  end

  def attributes
    { "name" => nil }
  end
end
```

Теперь есть возможность создавать экземпляры `Person` и устанавливать атрибуты с помощью `from_json`.

```irb
irb> json = { name: "Bob" }.to_json
=> "{\"name\":\"Bob\"}"

irb> person = Person.new

irb> person.from_json(json)
=> #<Person:0x00000100c773f0 @name="Bob">

irb> person.name
=> "Bob"
```

### (Translation) Перевод

[`ActiveModel::Translation`](https://api.rubyonrails.org/classes/ActiveModel/Translation.html) предоставляет интеграцию между вашим объектом и [фреймворком интернационализации Rails (i18n)](/i18n).

```ruby
class Person
  extend ActiveModel::Translation
end
```

С помощью метода `human_attribute_name` можно преобразовывать имена атрибутов в более удобочитаемый формат. Удобочитаемый формат определяется в вашем(-их) файле(-ах) локали.

* config/locales/app.pt-BR.yml

```yaml
# config/locales/app.pt-BR.yml
pt-BR:
  activemodel:
    attributes:
      person:
        name: "Nome"
```

```irb
irb> Person.human_attribute_name("name")
=> "Name"

irb> I18n.locale = :"pt-BR"
=> :"pt-BR"
irb> Person.human_attribute_name("name")
=> "Nome"
```

### (Validations) Валидации

[`ActiveModel::Validations`](https://api.rubyonrails.org/classes/ActiveModel/Validations.html) предоставляет возможности для валидации объектов, что играет важную роль в обеспечении целостности и согласованности данных в вашем приложении. Встраивая валидации в свои модели, вы можете определять правила, регламентирующие корректность значений атрибутов, и предотвращать недопустимые данные.

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :email, :token

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates! :token, presence: true
end
```

```irb
irb> person = Person.new
irb> person.token = "2b1f325"
irb> person.valid?
=> false

irb> person.name = "Jane Doe"
irb> person.email = "me"
irb> person.valid?
=> false

irb> person.email = "jane.doe@gmail.com"
irb> person.valid?
=> true

# `token` использует validate! и вызовет исключение когда не установлен.
irb> person.token = nil
irb> person.valid?
=> "Token can't be blank (ActiveModel::StrictValidationFailed)"
```

#### Методы и опции валидации

Вы можете добавить валидации, используя некоторые из следующих методов:

- [`validate`](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validate): Добавляет проверку через метод или блок к классу.

- [`validates`](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates): Атрибут может быть передан методу `validates`, который предоставляет сокращение для всех стандартных валидаторов.

- [`validates!`](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates-21) или установка `strict: true`: Используется для определения валидаций, которые не могут быть исправлены конечными пользователями и считаются исключительными. Каждый валидатор, определенный с восклицательным знаком или опцией `:strict`, установленной в значение true, всегда будет вызывать `ActiveModel::StrictValidationFailed` вместо добавления к ошибкам, когда проверка не удается.

- [`validates_with`](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_with): Передает запись в указанный класс или классы и позволяет им добавлять ошибки на основе более сложных условий.

- [`validates_each`](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_each): Проверяет каждый атрибут в блоке.

Некоторые из приведенных ниже опций могут использоваться с определенными валидаторами. Чтобы определить, можно ли использовать опцию с конкретным валидатором, ознакомьтесь с документацией [здесь](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html).

- `:on`: Указывает контекст, в котором добавлять валидацию. Вы можете передать символ или массив символов. (например, `on: :create`, или `on: :custom_validation_context`, или `on: [:create, :custom_validation_context]`). Валидации без опции `:on` будут выполняться независимо от контекста. Валидации с некоторой опцией `:on` будут выполняться только в указанном контексте. Вы можете передать контекст при валидации с помощью `valid?(:context)`.

- `:if`: Указывает метод, proc или строку для вызова, чтобы определить, должна ли выполняться валидация (например, `if: :allow_validation`, или `if: -> { signup_step > 2 }`). Метод, proc или строка должны возвращать или вычисляться в значение `true` или `false`.

- `:unless`: Указывает метод, proc или строку для вызова, чтобы определить, не должна ли выполняться валидация (например, `unless: :skip_validation`, или `unless: Proc.new { |user| user.signup_step <= 2 }`). Метод, proc или строка должны возвращать или вычисляться в значение `true` или `false`.

- `:allow_nil`: Пропустите валидацию, если атрибут `nil`.

- `:allow_blank`: Пропустите валидацию, если атрибут пустой.

- `:strict`: Если опция `:strict` установлена в значение true, она будет вызывать `ActiveModel::StrictValidationFailed` вместо добавления ошибки. Опция `:strict` также может быть установлена в любое другое исключение.

NOTE: Многократный вызов `validate` на одном и том же методе перезапишет предыдущие определения.

#### Ошибки

`ActiveModel::Validations` автоматически добавляет метод `errors` к вашим экземплярам, инициализированным новым объектом [`ActiveModel::Errors`](https://api.rubyonrails.org/classes/ActiveModel/Errors.html) (вам не нужно делать это вручную).

Вызовите `valid?` на объекте, чтобы проверить, является ли объект валидным. Если объект не является валидным, он вернет `false`, а ошибки будут добавлены в объект `errors`.

```irb
irb> person = Person.new

irb> person.email = "me"
irb> person.valid?
=> # Raises Token can't be blank (ActiveModel::StrictValidationFailed)

irb> person.errors.to_hash
=> {:name => ["can't be blank"], :email => ["is invalid"]}

irb> person.errors.full_messages
=> ["Name can't be blank", "Email is invalid"]
```

### Тесты совместимости

[`ActiveModel::Lint::Tests`](https://api.rubyonrails.org/classes/ActiveModel/Lint/Tests.html) позволяет проверить, совместим ли объект с Active Model API. Включая `ActiveModel::Lint::Tests` в ваш TestCase, он будет включать тесты, которые сообщают вам, полностью ли ваш объект соответствует, или, если нет, какие аспекты API не реализованы.

Эти тесты не пытаются определить семантическую правильность возвращаемых значений. Например, вы можете реализовать `valid?` так, чтобы он всегда возвращал `true`, и тесты пройдут. Вы должны сами позаботиться о том, чтобы значения имели смысловое значение.

Ожидается, что объекты, которые вы передаете, будут возвращать совместимый объект при вызове `to_model`. Вполне допустимо, чтобы `to_model` возвращал `self`.

* `app/models/person.rb`

    ```ruby
    class Person
      include ActiveModel::API
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

Тестовые методы можно найти [здесь](https://api.rubyonrails.org/classes/ActiveModel/Lint/Tests.html).

Чтобы запустить тесты, используйте следующую команду:

```bash
$ bin/rails test

Run options: --seed 14596

# Running:

......

Finished in 0.024899s, 240.9735 runs/s, 1204.8677 assertions/s.

6 runs, 30 assertions, 0 failures, 0 errors, 0 skips
```
