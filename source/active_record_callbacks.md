Колбэки Active Record
=====================

Это руководство научит вас вмешиваться в жизненный цикл ваших объектов Active Record.

После прочтения этого руководства вы узнаете:

* Когда определенные события случаются в течение жизни объекта Active Record.
* Как регистрировать, запускать и пропускать колбэки, реагирующие на события.
* Как создавать реляционные, ассоциативные, условные и транзакционные колбэки.
* Как создавать объекты, инкапсулирующие общее поведение для повторного использования ваших колбэков.

Жизненный цикл объекта
----------------------

В результате обычных операций приложения на Rails, объекты могут быть [созданы, обновлены и уничтожены](/active-record-basics#crud-reading-and-writing-data). Active Record дает возможность вмешаться в этот жизненный цикл объекта, таким образом, вы можете контролировать свое приложение и его данные.

Колбэки позволяют вам переключать логику до или после изменения состояния объекта. Это методы, которые вызываются в определенные моменты жизненного цикла объекта. С помощью колбэков можно писать код, который будет выполняться всякий раз, когда объект Active Record инициализируется, создается, сохраняется, обновляется, удаляется, проверяется на валидность или загружается из базы данных.

```ruby
class BirthdayCake < ApplicationRecord
  after_create -> { Rails.logger.info("Congratulations, the callback has run!") }
end
```

```irb
irb> BirthdayCake.create
Congratulations, the callback has run!
```

Вы увидите, что есть множество событий жизненного цикла, и несколько вариантов вклиниться в них - или до, или после или даже вокруг них.

Регистрация колбэков
--------------------

Для того, чтобы использовать доступные колбэки, их необходимо реализовать и зарегистрировать. Реализация может быть выполнена множеством способов, например, с помощью обычных методов, блоков и proc, или путем определения пользовательских объектов колбэков с использованием классов или модулей. Давайте рассмотрим каждую из этих методик реализации.

Вы можете зарегистрировать колбэки с помощью **специального макро-метода класса, который вызывает обычный метод** для реализации.

```ruby
class User < ApplicationRecord
  validates :username, :email, presence: true

  before_validation :ensure_username_has_value

  private
    def ensure_username_has_value
      if username.blank?
        self.username = email
      end
    end
end
```

**Макро-методы класса также могут получать блок**. Их следует использовать, если код внутри блока такой короткий, что помещается в одну строчку.

```ruby
class User < ApplicationRecord
  validates :username, :email, presence: true

  before_validation do
    self.username = email if username.blank?
  end
end
```

Альтернативно можно **передать в колбэк proc**, который будут выполнен.

```ruby
class User < ApplicationRecord
  validates :username, :email, presence: true

  before_validation ->(user) { user.username = user.email if user.username.blank? }
end
```

Наконец, можно определить **собственный объект колбэка**, как показано ниже. мы раскроем их [ниже подробнее](#callback-objects).

```ruby
class User < ApplicationRecord
  validates :username, :email, presence: true

  before_validation AddUsername
end

class AddUsername
  def self.before_validation(record)
    if record.username.blank?
      record.username = record.email
    end
  end
end
```

### (registering-callbacks-to-fire-on-life-cycle-events) Регистрация колбэков, срабатывающих на событиях жизненного цикла

Колбэки также можно регистрировать для срабатывания только на определенных событиях жизненного цикла. Это можно сделать с помощью опции `:on`, которая позволяет полностью контролировать, когда и в каком контексте будут вызываться ваши колбэки.

NOTE:  Контекст - это категория или сценарий, в котором вы хотите применить определенные проверки.  При валидации модели ActiveRecord вы можете указать контекст для группировки проверок. Это позволяет вам иметь разные наборы валидаций, применяемые в разных ситуациях. В Rails существуют определенные контексты по умолчанию для проверок, такие как :create, :update и :save.

```ruby
class User < ApplicationRecord
  validates :username, :email, presence: true

  before_validation :ensure_username_has_value, on: :create

  # :on также принимает массив
  after_validation :set_location, on: [ :create, :update ]

  private
    def ensure_username_has_value
      if username.blank?
        self.username = email
      end
    end

    def set_location
      self.location = LocationService.query(self)
    end
end
```

NOTE: Считается хорошей практикой объявлять методы колбэков как private. Если их оставить public, они могут быть вызваны извне модели и нарушить принципы инкапсуляции объекта.

WARNING. Не рекомендуется использовать методы, такие как `update`, `save` или любые другие, которые вызывают побочные эффекты для объекта внутри ваших колбэков. <br><br> Например, избегайте вызова `update(attribute: "value")` внутри колбэка. Эта практика может привести к изменению состояния модели и потенциально вызвать непредвиденные проблемы во время коммита. <br><br> Вместо этого, для более безопасного подхода вы можете напрямую присваивать значения (например, `self.attribute = "value"`) в колбэках, таких как `before_create`, `before_update` или даже более ранних.

Доступные колбэки
-----------------

Вот список всех доступных колбэков Active Record, перечисленных **в том порядке, в котором они вызываются** в течение соответствующих операций:

### Создание объекта

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_create`][]
* [`around_create`][]
* [`after_create`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]

Примеры `after_commit` / `after_rollback` можно найти [здесь](#after-commit-and-after-rollback).

[`after_create`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_create
[`after_commit`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_commit
[`after_rollback`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_rollback
[`after_save`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_save
[`after_validation`]:
    https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-after_validation
[`around_create`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_create
[`around_save`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_save
[`before_create`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_create
[`before_save`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_save
[`before_validation`]:
    https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-before_validation

Ниже приведены примеры использования этих колбэков. Мы сгруппировали их по связанным операциям, а затем покажем, как их можно использовать совместно.

#### (validation-callbacks) Валидационные колбэки

Валидационные колбэки вызываются всякий раз, когда запись проверяется на валидность напрямую через методы [`valid?`](https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-valid-3F) (или его псевдоним [`validate`](https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-validate)) или [`invalid?`](https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-invalid-3F), или косвенно через методы `create`, `update` или `save`. Они выполняются до и после этапа валидации.

```ruby
class User < ApplicationRecord
  validates :name, presence: true
  before_validation :titleize_name
  after_validation :log_errors

  private
    def titleize_name
      self.name = name.downcase.titleize if name.present?
      Rails.logger.info("Name titleized to #{name}")
    end

    def log_errors
      if errors.any?
        Rails.logger.error("Validation failed: #{errors.full_messages.join(', ')}")
      end
    end
end
```

```irb
irb> user = User.new(name: "", email: "john.doe@example.com", password: "abc123456")
=> #<User id: nil, email: "john.doe@example.com", created_at: nil, updated_at: nil, name: "">

irb> user.valid?
Name titleized to
Validation failed: Name can't be blank
=> false
```

#### (save-callbacks) Колбэки сохранения

Колбэки сохранения вызываются всякий раз, когда запись передается (т.е. "сохраняется") в базу данных с помощью методов `create`, `update` или `save`. Они вызываются до, после и во время сохранения объекта.

```ruby
class User < ApplicationRecord
  before_save :hash_password
  around_save :log_saving
  after_save :update_cache

  private
    def hash_password
      self.password_digest = BCrypt::Password.create(password)
      Rails.logger.info("Password hashed for user with email: #{email}")
    end

    def log_saving
      Rails.logger.info("Saving user with email: #{email}")
      yield
      Rails.logger.info("User saved with email: #{email}")
    end

    def update_cache
      Rails.cache.write(["user_data", self], attributes)
      Rails.logger.info("Update Cache")
    end
end
```

```irb
irb> user = User.create(name: "Jane Doe", password: "password", email: "jane.doe@example.com")

Password encrypted for user with email: jane.doe@example.com
Saving user with email: jane.doe@example.com
User saved with email: jane.doe@example.com
Update Cache
=> #<User id: 1, email: "jane.doe@example.com", created_at: "2024-03-20 16:02:43.685500000 +0000", updated_at: "2024-03-20 16:02:43.685500000 +0000", name: "Jane Doe">
```

#### колбэки создания

колбэки создания вызываются всякий раз, когда запись **впервые** передается (т.е. "сохраняется") в базу данных. Другими словами, они срабатывают при сохранении новой записи с помощью методов `create` или `save`. Они вызываются до, после и во время создания объекта.

```ruby
class User < ApplicationRecord
  before_create :set_default_role
  around_create :log_creation
  after_create :send_welcome_email

  private
    def set_default_role
      self.role = "user"
      Rails.logger.info("User role set to default: user")
    end

    def log_creation
      Rails.logger.info("Creating user with email: #{email}")
      yield
      Rails.logger.info("User created with email: #{email}")
    end

    def send_welcome_email
      UserMailer.welcome_email(self).deliver_later
      Rails.logger.info("User welcome email sent to: #{email}")
    end
end
```

```irb
irb> user = User.create(name: "John Doe", email: "john.doe@example.com")

User role set to default: user
Creating user with email: john.doe@example.com
User created with email: john.doe@example.com
User welcome email sent to: john.doe@example.com
=> #<User id: 10, email: "john.doe@example.com", created_at: "2024-03-20 16:19:52.405195000 +0000", updated_at: "2024-03-20 16:19:52.405195000 +0000", name: "John Doe">
```

### Обновление объекта

Колбэки обновления вызываются всякий раз, когда **существующая** запись передается (т.е. "сохраняется") в базу данных. Они вызываются до, после и во время обновления объекта.

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_update`][]
* [`around_update`][]
* [`after_update`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]

[`after_update`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_update
[`around_update`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_update
[`before_update`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_update

WARNING: Колбэк `after_save` вызывается как при создании, так и при обновлении записей. Однако он всегда выполняется после более специфичных колбэков `after_create` и `after_update`, независимо от порядка вызова макросов. Аналогично, колбэки `before_save` и `around_save` следуют тому же правилу: `before_save` запускается перед созданием/обновлением, а `around_save` — вокруг операций создания/обновления.  Важно отметить, что колбэки сохранения всегда будут выполняться до/вокруг/после более специфических колбэков создания/обновления.

Мы уже рассмотрели колбэки [валидации](#validation-callbacks) и [сохранения](#save-callbacks).  Примеры `after_commit` / `after_rollback` можно найти [здесь](#after-commit-and-after-rollback).

#### Колбэки обновления

```ruby
class User < ApplicationRecord
  before_update :check_role_change
  around_update :log_updating
  after_update :send_update_email

  private
    def check_role_change
      if role_changed?
        Rails.logger.info("User role changed to #{role}")
      end
    end

    def log_updating
      Rails.logger.info("Updating user with email: #{email}")
      yield
      Rails.logger.info("User updated with email: #{email}")
    end

    def send_update_email
      UserMailer.update_email(self).deliver_later
      Rails.logger.info("Update email sent to: #{email}")
    end
end
```

```irb
irb> user = User.find(1)
=> #<User id: 1, email: "john.doe@example.com", created_at: "2024-03-20 16:19:52.405195000 +0000", updated_at: "2024-03-20 16:19:52.405195000 +0000", name: "John Doe", role: "user" >

irb> user.update(role: "admin")
User role changed to admin
Updating user with email: john.doe@example.com
User updated with email: john.doe@example.com
Update email sent to: john.doe@example.com
```

#### Комбинирование колбэков

Во многих случаях для достижения нужного поведения требуется комбинация колбэков. Например, вы можете захотеть отправить приветственное письмо после создания пользователя, но только если это новый пользователь, а не обновляемый. При обновлении информации о пользователе вы можете захотеть уведомить администратора, если были изменены важные данные. В этом случае вы можете использовать вместе колбэки `after_create` и `after_update`.

```ruby
class User < ApplicationRecord
  after_create :send_confirmation_email
  after_update :notify_admin_if_critical_info_updated

  private
    def send_confirmation_email
      UserMailer.confirmation_email(self).deliver_later
      Rails.logger.info("Confirmation email sent to: #{email}")
    end

    def notify_admin_if_critical_info_updated
      if saved_change_to_email? || saved_change_to_phone_number?
        AdminMailer.user_critical_info_updated(self).deliver_later
        Rails.logger.info("Notification sent to admin about critical info update for: #{email}")
      end
    end
end
```

```irb
irb> user = User.create(name: "John Doe", email: "john.doe@example.com")
Confirmation email sent to: john.doe@example.com
=> #<User id: 1, email: "john.doe@example.com", ...>

irb> user.update(email: "john.doe.new@example.com")
Notification sent to admin about critical info update for: john.doe.new@example.com
=> true
```

### Уничтожение объекта

Колбэки уничтожения вызываются всякий раз, когда запись уничтожается, но игнорируются при удалении записи. Они вызываются до, после и во время уничтожения объекта.

* [`before_destroy`][]
* [`around_destroy`][]
* [`after_destroy`][]
* [`after_commit`][] / [`after_rollback`][]

[`after_destroy`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_destroy
[`around_destroy`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_destroy
[`before_destroy`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_destroy

Примеры `after_commit` / `after_rollback` можно найти [здесь](#after-commit-and-after-rollback).

#### Колбэки уничтожения

```ruby
class User < ApplicationRecord
  before_destroy :check_admin_count
  around_destroy :log_destroy_operation
  after_destroy :notify_users

  private
    def check_admin_count
      if admin? && User.where(role: "admin").count == 1
        throw :abort
      end
      Rails.logger.info("Checked the admin count")
    end

    def log_destroy_operation
      Rails.logger.info("About to destroy user with ID #{id}")
      yield
      Rails.logger.info("User with ID #{id} destroyed successfully")
    end

    def notify_users
      UserMailer.deletion_email(self).deliver_later
      Rails.logger.info("Notification sent to other users about user deletion")
    end
end
```

```irb
irb> user = User.find(1)
=> #<User id: 1, email: "john.doe@example.com", created_at: "2024-03-20 16:19:52.405195000 +0000", updated_at: "2024-03-20 16:19:52.405195000 +0000", name: "John Doe", role: "admin">

irb> user.destroy
Checked the admin count
About to destroy user with ID 1
User with ID 1 destroyed successfully
Notification sent to other users about user deletion
```

### `after_initialize` и `after_find`

Всякий раз, когда возникает объект Active Record или непосредственно при использовании `new`, или когда запись загружается из базы данных, будет вызван колбэк [`after_initialize`][]. Он может быть полезен, чтобы избежать необходимости напрямую переопределять метод Active Record `initialize`.

При загрузке записи из базы данных, будет вызван колбэк [`after_find`][]. `after_find` вызывается перед `after_initialize`, если они оба определены.

NOTE: У колбэков `after_initialize` и `after_find` нет пары `before_*`.

Они могут быть зарегистрированы подобно другим колбэкам Active Record.

```ruby
class User < ApplicationRecord
  after_initialize do |user|
    Rails.logger.info("You have initialized an object!")
  end

  after_find do |user|
    Rails.logger.info("You have found an object!")
  end
end
```

```irb
irb> User.new
You have initialized an object!
=> #<User id: nil>

irb> User.first
You have found an object!
You have initialized an object!
=> #<User id: 1>
```

[`after_find`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_find
[`after_initialize`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_initialize

### `after_touch`

Колбэк [`after_touch`][] будет вызван, когда на объекте Active Record вызван `touch`. Подробнее о `touch` можно прочитать [здесь](https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-touch).

```ruby
class User < ApplicationRecord
  after_touch do |user|
    Rails.logger.info("You have touched an object")
  end
end
```

```irb
irb> user = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

irb> user.touch
You have touched an object
=> true
```

Он может быть использован совместно с `belongs_to`:

```ruby
class Book < ApplicationRecord
  belongs_to :library, touch: true
  after_touch do
    Rails.logger.info("A Book was touched")
  end
end

class Library < ApplicationRecord
  has_many :books
  after_touch :log_when_books_or_library_touched

  private
    def log_when_books_or_library_touched
      Rails.logger.info("Book/Library was touched")
    end
end
```

```irb
irb> book = Book.last
=> #<Book id: 1, library_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

irb> book.touch # вызывает book.library.touch
A Book was touched
Book/Library was touched
=> true
```

[`after_touch`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_touch

Запуск колбэков
---------------

Следующие методы запускают колбэки:

* `create`
* `create!`
* `destroy`
* `destroy!`
* `destroy_all`
* `destroy_by`
* `save`
* `save!`
* `save(validate: false)`
* `save!(validate: false)`
* `toggle!`
* `touch`
* `update_attribute`
* `update_attribute!`
* `update`
* `update!`
* `valid?`
* `validate`

Дополнительно, колбэк `after_find` запускается следующими поисковыми методами:

* `all`
* `first`
* `find`
* `find_by`
* `find_by!`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`
* `sole`
* `take`

Колбэк `after_initialize` запускается всякий раз, когда инициализируется новый объект класса.

NOTE: Методы `find_by_*` и `find_by_*!` это динамические методы поиска, генерируемые автоматически для каждого атрибута. Изучите подробнее их в [разделе Динамический поиск](/active-record-querying#dynamic-finders)

Условные колбэки
----------------

Как и в [валидациях](/active-record-validations), возможно сделать вызов метода колбэка условным в зависимости от заданного предиката. Это осуществляется при использовании опций `:if` и `:unless`, которые могут принимать символ, `Proc` или массив.

Опцию `:if` следует использовать для определения, при каких условиях колбэк *должен* быть вызван. Если вы хотите определить условия, при которых колбэк *не должен* быть вызван, используйте опцию `:unless`.

### Использование `:if` и `:unless` с `Symbol`

Опции `:if` и `:unless` можно связать с символом, соответствующим имени метода предиката, который будет вызван непосредственно перед вызовом колбэка.

При использовании опции `:if`, колбэк **не будет** выполнен, если метод предиката возвратит **false**; при использовании опции `:unless`, колбэк **не будет** выполнен, если метод предиката возвратит **true**. Это самый распространенный вариант.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: :paid_with_card?
end
```

При использовании такой формы регистрации, также возможно зарегистрировать несколько различных предикатов, которые будут вызваны, чтобы проверить, должен ли выполняться колбэк. Мы раскроем это [ниже](#multiple-callback-conditions).

### Использование `:if` и `:unless` с `Proc`

Можно связать `:if` и `:unless` с объектом `Proc`. Этот вариант больше всего подходит при написании коротких методов, обычно однострочных.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number,
    if: ->(order) { order.paid_with_card? }
end
```

Так как proc вычисляется в контексте объекта, также возможно написать так:

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: -> { paid_with_card? }
end
```

### (multiple-callback-conditions) Составные условия колбэков

Опции `:if` и `:unless` также принимают массив из proc или имен методов в виде символов:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, :untrusted_author?]
end
```

В список условий также можно запросто включить proc:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, -> { untrusted_author? }]
end
```

### Одновременное использование :if и :unless

В колбэках можно смешивать `:if` и `:unless` в одном выражении:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: -> { forum.parental_control? },
    unless: -> { author.trusted? }
end
```

Колбэк запустится только когда все условия `:if` и не один из условий `:unless` будут истинны.

Пропуск колбэков
----------------

Как и в [валидациях](/active-record-validations), возможно пропустить колбэки с помощью следующих методов:

* [`decrement!`][]
* [`decrement_counter`][]
* [`delete`][]
* [`delete_all`][]
* [`delete_by`][]
* [`increment!`][]
* [`increment_counter`][]
* [`insert`][]
* [`insert!`][]
* [`insert_all`][]
* [`insert_all!`][]
* [`touch_all`][]
* [`update_column`][]
* [`update_columns`][]
* [`update_all`][]
* [`update_counters`][]
* [`upsert`][]
* [`upsert_all`][]

Давайте рассмотрим модель `User`, где колбэк `before_save` логирует любые изменения адреса электронной почты пользователя:

```ruby
class User < ApplicationRecord
  before_save :log_email_change

  private
    def log_email_change
      if email_changed?
        Rails.logger.info("Email changed from #{email_was} to #{email}")
      end
    end
end
```

Теперь предположим, что существует сценарий, в котором вы хотите обновить адрес электронной почты пользователя, не вызывая колбэк `before_save` для регистрации изменения email. Для этого вы можете использовать метод `update_columns`.

```irb
irb> user = User.find(1)
irb> user.update_columns(email: 'new_email@example.com')
```

Вышесказанное обновит адрес электронной почты пользователя без вызова колбэка `before_save`.

WARNING. Эти методы следует использовать с осторожностью, поскольку в колбэках могут быть важные бизнес-правила и логика приложения, которые вы не хотите обходить. Их обход без понимания потенциальных последствий может привести к неверным данным.

[`decrement!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-decrement-21
[`decrement_counter`]:
    https://api.rubyonrails.org/classes/ActiveRecord/CounterCache/ClassMethods.html#method-i-decrement_counter
[`delete`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-delete
[`delete_all`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-delete_all
[`delete_by`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-delete_by
[`increment!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-increment-21
[`increment_counter`]:
    https://api.rubyonrails.org/classes/ActiveRecord/CounterCache/ClassMethods.html#method-i-increment_counter
[`insert`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence/ClassMethods.html#method-i-insert
[`insert!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence/ClassMethods.html#method-i-insert-21
[`insert_all`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence/ClassMethods.html#method-i-insert_all
[`insert_all!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence/ClassMethods.html#method-i-insert_all-21
[`touch_all`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-touch_all
[`update_column`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-update_column
[`update_columns`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-update_columns
[`update_all`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-update_all
[`update_counters`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-update_counters
[`upsert`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence/ClassMethods.html#method-i-upsert
[`upsert_all`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence/ClassMethods.html#method-i-upsert_all


Подавление колбэков
-------------------

В некоторых ситуациях вам может понадобиться временно отключить выполнение определенных колбэков в вашем Rails-приложении. Это полезно, когда вы хотите пропустить конкретные действия во время определенных операций, не отключая колбэки навсегда.

Rails предоставляет механизм подавления колбэков с помощью [модуля `ActiveRecord::Suppressor`](https://api.rubyonrails.org/classes/ActiveRecord/Suppressor.html). Используя этот модуль, вы можете обернуть блок кода, в котором хотите подавить колбэки, гарантируя, что они не будут выполняться во время этой конкретной операции.

Рассмотрим сценарий, где у нас есть модель `User` с колбэком, который отправляет приветственное письмо новым пользователям после регистрации. Однако могут быть случаи, когда вы хотите создать пользователя без отправки приветственного письма, например, при заполнении базы данных тестовыми данными.

```ruby
class User < ApplicationRecord
  after_create :send_welcome_email

  def send_welcome_email
    puts "Welcome email sent to #{self.email}"
  end
end
```

В этом примере колбэк `after_create` вызывает метод `send_welcome_email` каждый раз, когда создается новый пользователь.

Чтобы создать пользователя без отправки приветственного письма, мы можем использовать модуль `ActiveRecord::Suppressor` следующим образом:

```ruby
User.suppress do
  User.create(name: "Jane", email: "jane@example.com")
end
```

В этом коде блок `User.suppress` гарантирует, что колбэк `send_welcome_email` не будет выполнен во время создания пользователя "Jane", позволяя создать пользователя без отправки приветственного письма.

WARNING: Использование механизма подавления колбэков ActiveRecord, хотя и может быть полезным для выборочного управления их выполнением, может привести к усложнению кода и неожиданному поведению. Подавление колбэков может затемнить логику работы вашего приложения, что со временем затруднит понимание и поддержку кодовой базы. Тщательно взвешивайте необходимость подавления колбэков, обеспечивая тщательную документацию и продуманное тестирование, чтобы снизить риски непреднамеренных побочных эффектов, проблем с производительностью и сбоев тестов.

Остановка выполнения
--------------------

При регистрации новых колбэков для ваших моделей они будут помещены в очередь на выполнение. Эта очередь будет включать все валидации модели, зарегистрированные колбэки и операцию с базой данных, которая должна быть выполнена.

Вся цепочка колбэков обернута в транзакцию. Если какой-либо колбэк вызывает исключение, цепочка выполнения прерывается, выполняется **откат**, а ошибка будет выброшена повторно.

```ruby
class Product < ActiveRecord::Base
  before_validation do
    raise "Price can't be negative" if total_price < 0
  end
end

Product.create # вызовет "Price can't be negative"
```

Это неожиданно приводит к сбою кода, который не ожидает, что методы вроде `create` и `save` будут вызывать исключения.

NOTE: Если во время цепочки колбэков возникает исключение, Rails повторно выбросит его, за исключением случаев, когда это исключение `ActiveRecord::Rollback` или `ActiveRecord::RecordInvalid`. Вместо этого, вы должны использовать `throw :abort` для преднамеренного прерывания цепочки. Если какой-либо колбэк использует кидает `:abort`, процесс будет прерван, а create вернет значение `create`.

```ruby
class Product < ActiveRecord::Base
  before_validation do
    throw :abort if total_price < 0
  end
end

Product.create # => false
```

Однако при вызове метода `create!` будет выброшено исключение `ActiveRecord::RecordNotSaved`. Это исключение указывает на то, что запись не была сохранена из-за прерывания колбэком.

```ruby
User.create! # => вызовет ActiveRecord::RecordNotSaved
```

При `throw :abort` в любом колбэке уничтожения метод `destroy` вернет false:

```ruby
class User < ActiveRecord::Base
  before_destroy do
    throw :abort if still_active?
  end
end

User.first.destroy # => false
```

Однако, при вызове `destroy!` будет выброшено `ActiveRecord::RecordNotDestroyed`.

```ruby
User.first.destroy! # => вызовет ActiveRecord::RecordNotDestroyed
```

(association-callbacks) Колбэки связей
--------------------------------------

Колбэки связей похожи на обычные колбэки, но они вызываются событиями в жизненном цикле связанной коллекции. Существует четыре доступных колбэка связей:

* `before_add`
* `after_add`
* `before_remove`
* `after_remove`

Вы можете определить колбэки связей, добавив опции к самой связи.

Представим ситуацию, когда автор может иметь множество книг. Однако, прежде чем добавлять книгу в коллекцию автора, вы хотите убедиться, что автор не достиг своего лимита книг. Этого можно добиться с помощью колбэка `before_add`, который проверит лимит.

```ruby
class Author < ApplicationRecord
  has_many :books, before_add: :check_limit

  private
    def check_limit
      if books.count >= 5
        errors.add(:base, "Cannot add more than 5 books for this author")
        throw(:abort)
      end
    end
end
```

Если колбэк `before_add` бросает `:abort`, объект не добавляется в коллекцию.

Иногда вам может понадобиться выполнить несколько действий с связанным объектом. В этом случае вы можете объединить колбэки для одного события, передав их массивом. Кроме того, Rails автоматически передает колбэку объект, который добавляется или удаляется, для использования вами.

```ruby
class Author < ApplicationRecord
  has_many :books, before_add: [:check_limit, :calculate_shipping_charges]

  def check_limit
    if books.count >= 5
      errors.add(:base, "Cannot add more than 5 books for this author")
      throw(:abort)
    end
  end

  def calculate_shipping_charges(book)
    weight_in_pounds = book.weight_in_pounds || 1
    shipping_charges = weight_in_pounds * 2

    shipping_charges
  end
end
```

Аналогично, если колбэк `before_remove` бросает `:abort`, объект не будет удален из коллекции.

NOTE: Эти колбэки вызываются только тогда, когда связанные объекты добавляются или удаляются через коллекцию ассоциации.

```ruby
# Вызывает колбэк `before_add`
author.books << book
author.books = [book, book2]

# Не вызывает колбэк `before_add`
book.update(author_id: 1)
```

Каскадные колбэки связей
------------------------

Колбэки могут быть вызваны при изменении связанных объектов. Они работают через связи моделей, при этом жизненные циклы событий могут ниспадать по связям и запускать колбэки.

Представим ситуацию, когда у пользователя есть много статей. Статьи пользователя должны быть удалены, если сам пользователь удаляется. Давайте добавим колбэк `after_destroy` к модели `User` через ее связь с моделью `Article`:

```ruby
class User < ApplicationRecord
  has_many :articles, dependent: :destroy
end

class Article < ApplicationRecord
  after_destroy :log_destroy_action

  def log_destroy_action
    Rails.logger.info("Article destroyed")
  end
end
```

```irb
irb> user = User.first
=> #<User id: 1>
irb> user.articles.create!
=> #<Article id: 1, user_id: 1>
irb> user.destroy
Article destroyed
=> #<User id: 1>
```

WARNING: При использовании колбэка `before_destroy` его следует размещать перед связями с `dependent: :destroy` (или использовать опцию `prepend: true`), чтобы гарантировать их выполнение до того, как записи будут удалены с помощью `dependent: :destroy`.

(transaction-callbacks) Транзакционные колбэки
----------------------------------------------

### (after-commit-and-after-rollback) `after_commit` и `after_rollback`

Два дополнительных колбэка вызываются по завершению транзакции базы данных: [`after_commit`][] и [`after_rollback`][]. Эти колбэки очень похожи на колбэк `after_save`, за исключением того, что они не выполняются пока изменения в базе данных не будут подтверждены или обращены. Они наиболее полезны, когда вашим моделям Active Record необходимо взаимодействовать с внешними системами, не являющимися частью транзакции базы данных.

Рассмотрим модель `PictureFile`. которой необходимо удалить файл после того, как запись уничтожена.

```ruby
class PictureFile < ApplicationRecord
  after_destroy :delete_picture_file_from_disk

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

Если что-либо вызовет исключение после того, как был вызван колбэк `after_destroy`, и транзакция откатывается, тогда файл будет удален и модель останется в противоречивом состоянии. Например, предположим, что `picture_file_2` в следующем коде не валидна, и метод `save!` вызовет ошибку.

```ruby
PictureFile.transaction do
  picture_file_1.destroy
  picture_file_2.save!
end
```

Используя колбэк `after_commit`, можно учесть этот случай.

```ruby
class PictureFile < ApplicationRecord
  after_commit :delete_picture_file_from_disk, on: :destroy

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

NOTE: Опция `:on` определяет, когда будет запущен колбэк. Если не предоставить опцию `:on`, колбэк будет запущен для каждого события жизненного цикла.  Подробнее об `:on` читайте [тут](#registering-callbacks-to-fire-on-life-cycle-events).

Когда транзакция завершается, колбэки `after_commit` или `after_rollback` вызываются для всех моделей, созданных, обновленных или уничтоженных внутри этой транзакции. Однако, если внутри одного из этих колбэков возникает исключение, оно будет передано дальше, и любые оставшиеся методы `after_commit` или `after_rollback` _не_ будут выполнены.

```ruby
class User < ActiveRecord::Base
  after_commit { raise "Intentional Error" }
  after_commit {
    # Это не будет вызвано, потому что предыдущий after_commit вызывает исключение.
    Rails.logger.info("This will not be logged")
  }
end
```

WARNING. Если код вашего колбэка вызывает исключение, вам нужно будет перехватить его и обработать внутри колбэка, чтобы дать другим колбэкам возможность выполниться.

`after_commit` предоставляет совершенно другие гарантии, чем `after_save`, `after_update` и `after_destroy`. Например, если исключение возникает в `after_save`, транзакция будет отменена, и данные не сохранятся.

```ruby
class User < ActiveRecord::Base
  after_save do
    # Если это завершится с ошибкой, пользователь не будет сохранен.
    EventLog.create!(event: "user_saved")
  end
end
```

Однако, во время `after_commit` данные уже были сохранены в базе данных, поэтому любое исключение больше ничего не откатит.

```ruby
class User < ActiveRecord::Base
  after_commit do
    # Если это завершится с ошибкой, пользователь уже был сохранен.
    EventLog.create!(event: "user_saved")
  end
end
```

Код внутри колбэков `after_commit` или `after_rollback` не выполняется в отдельной транзакции.

В контексте одиночной транзакции, важно учитывать поведение колбэков `after_commit` и `after_rollback`, когда вы работаете с несколькими объектами, представляющими одну и ту же запись в базе данных. Эти колбэки вызываются только для первого объекта конкретной записи, которая изменяется внутри транзакции. Для других загруженных объектов, даже если они представляют ту же запись в базе данных, их соответствующие колбэки `after_commit` или `after_rollback` не будут вызваны.

```ruby
class User < ApplicationRecord
  after_commit :log_user_saved_to_db, on: :update

  private
    def log_user_saved_to_db
      Rails.logger.info("User was saved to database")
    end
end
```

```irb
irb> user = User.create
irb> User.transaction { user.save; user.save }
# User was saved to database
```

WARNING: Это тонкое поведение особенно влияет на сценарии, где вы ожидаете независимого выполнения колбэков для каждого объекта, связанного с одной и той же записью в базе данных. Оно может повлиять на последовательность и предсказуемость вызова колбэков, что может привести к потенциальным несоответствиям в логике приложения после транзакции.

### Псевдонимы для `after_commit`

Использование колбэка `after_commit` только при создании, обновлении или удалении данных является распространенной практикой. Иногда вы также можете захотеть использовать один колбэк для обоих `create` и `update`. Вот некоторые распространенные псевдонимы для этих операций:

* [`after_destroy_commit`][]
* [`after_create_commit`][]
* [`after_update_commit`][]
* [`after_save_commit`][]

Давайте разберем несколько примеров:

Вместо использования `after_commit` с опцией `on` для уничтожения, как показано ниже:

```ruby
class PictureFile < ApplicationRecord
  after_commit :delete_picture_file_from_disk, on: :destroy

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

Вместо этого можно использовать `after_destroy_commit`.

```ruby
class PictureFile < ApplicationRecord
  after_destroy_commit :delete_picture_file_from_disk

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

То же самое применимо к `after_create_commit` и `after_update_commit`.

Однако, если используются `after_create_commit` и `after_update_commit` с одним и тем же именем метода, сработает только колбэк, определенный последним, так как они оба являются псевдонимами к `after_commit`, который переопределяет ранее определенные колбэки с тем же именем метода.

```ruby
class User < ApplicationRecord
  after_create_commit :log_user_saved_to_db
  after_update_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      # Это будет вызвано один раз
      Rails.logger.info("User was saved to database")
    end
end
```

```irb
irb> user = User.create # ничего не выводит

irb> user.save # обновление user
User was saved to database
```

В этом случае лучше использовать `after_save_commit`, который является псевдонимом для использования колбэка `after_commit` для создания и обновления записей:

```ruby
class User < ApplicationRecord
  after_save_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      Rails.logger.info("User was saved to database")
    end
end
```

```irb
irb> user = User.create # создание a User
User was saved to database

irb> user.save # обновление user
User was saved to database
```

### Упорядочивание транзакционных колбэков


По умолчанию (начиная с Rails 7.1), транзакционные колбэки выполняются в том порядке, в котором они определены.

```ruby
class User < ActiveRecord::Base
  after_commit { Rails.logger.info("this gets called first") }
  after_commit { Rails.logger.info("this gets called second") }
end
```

Впрочем, в предыдущих версиях Rails при определении нескольких транзакционных колбэков `after_` (`after_commit`, `after_rollback` и т.д.) порядок их выполнения был обратным.

Если по какой-то причине вы по-прежнему хотите, чтобы они выполнялись в обратном порядке, вы можете установить [следующую конфигурацию](/configuring#config-active-record-run-after-transaction-callbacks-in-order-defined) в значение `false`. Тогда колбэки будут выполняться в обратном порядке.

```ruby
config.active_record.run_after_transaction_callbacks_in_order_defined = false
```

NOTE: Это также применяется ко всем вариациям `after_*_commit`, таким как `after_destroy_commit`.

[`after_create_commit`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_create_commit
[`after_destroy_commit`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_destroy_commit
[`after_save_commit`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_save_commit
[`after_update_commit`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_update_commit

(callback-objects) Объекты колбэков
----------------

Иногда методы колбэков, которые вы пишете, могут быть настолько полезными, что их можно будет переиспользовать в других моделях. Active Record позволяет создавать классы, которые инкапсулируют методы колбэков, чтобы их можно было переиспользовать.

Вот пример класса колбэка `after_commit` для очистки ненужных файлов из файловой системы. Это поведение может быть не уникальным для нашей модели `PictureFile`, и мы можем захотеть поделиться им, поэтому хорошей идеей будет инкапсулировать его в отдельный класс. Это значительно облегчит тестирование и изменение этого поведения.

```ruby
class FileDestroyerCallback
  def after_commit(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

При объявлении внутри класса, как показано выше, методы колбэка будут получать объект модели в качестве параметра. Это будет работать для любой модели, которая использует класс следующим образом:

```ruby
class PictureFile < ApplicationRecord
  after_commit FileDestroyerCallback.new
end
```

Имейте в виду, что нам нужно было создать новый объект `FileDestroyerCallback`, поскольку мы объявили наш колбэк как метод экземпляра. Это особенно полезно, если колбэки используют состояние созданного объекта. Однако во многих случаях более разумно объявлять колбэки как методы класса:

```ruby
class FileDestroyerCallback
  def self.after_commit(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

При объявлении метода колбэка таким образом, не потребуется создавать новый объект `FileDestroyerCallback` в нашей модели.

```ruby
class PictureFile < ApplicationRecord
  after_commit FileDestroyerCallback
end
```

Внутри объектов колбэков вы можете объявлять столько колбэков, сколько вам нужно.
