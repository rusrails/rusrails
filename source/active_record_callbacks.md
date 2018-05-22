Колбэки Active Record
=====================

Это руководство научит вас вмешиваться в жизненный цикл ваших объектов Active Record.

После прочтения этого руководства вы узнаете:

* О жизненном цикле объектов Active Record
* Как создавать методы колбэков, отвечающих на события в жизненном цикле объекта
* Как создавать специальные классы, инкапсулирующих обычное поведение для ваших колбэков

Жизненный цикл объекта
----------------------

В результате обычных операций приложения на Rails, объекты могут быть созданы, обновлены и уничтожены. Active Record дает возможность вмешаться в этот жизненный цикл объекта, таким образом, вы можете контролировать свое приложение и его данные.

Валидации позволяют вам быть уверенными, что только валидные данные хранятся в вашей базе данных. Колбэки позволяют вам переключать логику до или после изменения состояния объекта.

Обзор колбэков
--------------

Колбэки это методы, которые вызываются в определенные моменты жизненного цикла объекта. С колбэками возможно написать код, который будет запущен, когда объект Active Record создается, сохраняется, обновляется, удаляется, проходит валидацию или загружается из базы данных.

### Регистрация колбэков

Для того, чтобы использовать доступные колбэки, их нужно зарегистрировать. Можно реализовать колбэки как обычные методы, а затем использовать макро-методы класса для их регистрации в качестве колбэков.

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_validation :ensure_login_has_a_value

  private
    def ensure_login_has_a_value
      if login.nil?
        self.login = email unless email.blank?
      end
    end
end
```

Макро-методы класса также могут получать блок. Их следует использовать, если код внутри блока такой короткий, что помещается в одну строчку.

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_create do
    self.name = login.capitalize if name.blank?
  end
end
```

Колбэки также могут быть зарегистрированы на выполнение при определенных событиях жизненного цикла:

```ruby
class User < ApplicationRecord
  before_validation :normalize_name, on: :create

  # :on также принимает массив
  after_validation :set_location, on: [ :create, :update ]

  private
    def normalize_name
      self.name = name.downcase.titleize
    end

    def set_location
      self.location = LocationService.query(self)
    end
end
```

Считается хорошей практикой объявлять методы колбэков как private. Если их оставить public, они могут быть вызваны извне модели и нарушить принципы инкапсуляции объекта.

Доступные колбэки
-----------------

Вот список всех доступных колбэков Active Record, перечисленных в том порядке, в котором они вызываются в течение соответствующих операций:

### Создание объекта

* `before_validation`
* `after_validation`
* `before_save`
* `around_save`
* `before_create`
* `around_create`
* `after_create`
* `after_save`
* `after_commit/after_rollback`

### Обновление объекта

* `before_validation`
* `after_validation`
* `before_save`
* `around_save`
* `before_update`
* `around_update`
* `after_update`
* `after_save`
* `after_commit/after_rollback`

### Уничтожение объекта

* `before_destroy`
* `around_destroy`
* `after_destroy`
* `after_commit/after_rollback`

WARNING. `after_save` запускается и при создании, и при обновлении, но всегда _после_ более специфичных колбэков `after_create` и `after_update`, независимо от порядка, в котором выполняются макро-вызовы.

NOTE: Колбэк `before_destroy` должен быть размещен перед связями `dependent: :destroy` (или использовать опцию `prepend: true`), чтобы убедиться, что они выполняются до того, как записи будут удалены с помощью `dependent: :destroy`.

### `after_initialize` и `after_find`

Колбэк `after_initialize` вызывается всякий раз, когда возникает экземпляр объекта Active Record, или непосредственно при использовании `new`, или когда запись загружается из базы данных. Он может быть полезен, чтобы избежать необходимости напрямую переопределять метод Active Record `initialize`.

Колбэк `after_find` будет вызван всякий раз, когда Active Record загружает запись из базы данных. `after_find` вызывается перед `after_initialize`, если они оба определены.

У колбэков `after_initialize` и `after_find` нет пары `before_*`, но они могут быть зарегистрированы подобно другим колбэкам Active Record.

```ruby
class User < ApplicationRecord
  after_initialize do |user|
    puts "You have initialized an object!"
  end

  after_find do |user|
    puts "You have found an object!"
  end
end

>> User.new
You have initialized an object!
=> #<User id: nil>

>> User.first
You have found an object!
You have initialized an object!
=> #<User id: 1>
```

### `after_touch`

Колбэк `after_touch` будет вызван, когда на объекте Active Record вызван `touch`.

```ruby
class User < ApplicationRecord
  after_touch do |user|
    puts "You have touched an object"
  end
end

>> u = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

>> u.touch
You have touched an object
=> true
```

Он может быть использован совместно с `belongs_to`:

```ruby
class Employee < ApplicationRecord
  belongs_to :company, touch: true
  after_touch do
    puts 'An Employee was touched'
  end
end

class Company < ApplicationRecord
  has_many :employees
  after_touch :log_when_employees_or_company_touched

  private
  def log_when_employees_or_company_touched
    puts 'Employee/Company was touched'
  end
end

>> @employee = Employee.last
=> #<Employee id: 1, company_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

# вызывает @employee.company.touch
>> @employee.touch
Employee/Company was touched
An Employee was touched
=> true
```

Запуск колбэков
---------------

Следующие методы запускают колбэки:

* `create`
* `create!`
* `destroy`
* `destroy!`
* `destroy_all`
* `save`
* `save!`
* `save(validate: false)`
* `toggle!`
* `touch`
* `update_attribute`
* `update`
* `update!`
* `valid?`

Дополнительно, колбэк `after_find` запускается следующими поисковыми методами:

* `all`
* `first`
* `find`
* `find_by`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`

Колбэк `after_initialize` запускается всякий раз, когда инициализируется новый объект класса.

NOTE: Методы `find_by_*` и `find_by_*!` это динамические методы поиска, генерируемые автоматически для каждого атрибута. Изучите подробнее их в [разделе Динамический поиск](/active-record-query-interface#dynamic-finders)

Пропуск колбэков
----------------

Подобно валидациям, также возможно пропустить колбэки, используя следующие методы.

* `decrement`
* `decrement_counter`
* `delete`
* `delete_all`
* `increment`
* `increment_counter`
* `toggle`
* `update_column`
* `update_columns`
* `update_all`
* `update_counters`

Однако, эти методы нужно использовать осторожно, поскольку важные бизнес-правила и логика приложения могут содержаться в колбэках. Пропуск их без понимания возможных последствий может привести к невалидным данным.

Прерывание выполнения
---------------------

Как только вы зарегистрировали новые колбэки в своих моделях, они будут поставлены в очередь на выполнение. Эта очередь включает все валидации вашей модели, зарегистрированные колбэки и операции с базой данных для выполнения.

Вся цепочка колбэков упаковывается в операцию. Если любой колбэк вызывает исключение, выполняемая цепочка прерывается и запускается ROLLBACK. Чтобы преднамеренно остановить цепочку, используйте:

```ruby
throw :abort
```

WARNING. Вызов произвольного исключения может прервать код, который предполагает, что `save` и тому подобное не будут провалены подобным образом. Исключение `ActiveRecord::Rollback` чуть точнее сообщает Active Record, что происходит откат. Он подхватывается изнутри, но не перевызывает исключение.

WARNING. Любое исключение, кроме `ActiveRecord::Rollback` или `ActiveRecord::RecordInvalid`, будет перевызвано Rails после того, как прервется цепочка колбэков. Вызов исключения, отличного от `ActiveRecord::Rollback` или `ActiveRecord::RecordInvalid`, может сломать код, который не ожидает, что методы, такие как `save` и `update` (которые обычно пытаются вернуть `true` или `false`) вызовут исключение.

Колбэки для отношений
---------------------

Колбэки работают с отношениями между моделями, и даже могут быть определены ими. Представим пример, где пользователь имеет много статей. Статьи пользователя должны быть уничтожены, если уничтожается пользователь. Давайте добавим колбэк `after_destroy` в модель `User` через ее отношения с моделью `Article`.

```ruby
class User < ApplicationRecord
  has_many :articles, dependent: :destroy
end

class Article < ActiveRecord::Base
  after_destroy :log_destroy_action

  def log_destroy_action
    puts 'Article destroyed'
  end
end

>> user = User.first
=> #<User id: 1>
>> user.articles.create!
=> #<Article id: 1, user_id: 1>
>> user.destroy
Article destroyed
=> #<User id: 1>
```

Условные колбэки
----------------

Как и в валидациях, возможно сделать вызов метода колбэка условным в зависимости от заданного предиката. Это осуществляется при использовании опций `:if` и `:unless`, которые могут принимать символ, `Proc` или массив. Опцию `:if` следует использовать для определения, при каких условиях колбэк *должен* быть вызван. Если вы хотите определить условия, при которых колбэк *не должен* быть вызван, используйте опцию `:unless`.

### Использование `:if` и `:unless` с `Symbol`

Опции `:if` и `:unless` можно связать с символом, соответствующим имени метода предиката, который будет вызван непосредственно перед вызовом колбэка. При использовании опции `:if`, колбэк не будет выполнен, если метод предиката возвратит false; при использовании опции `:unless`, колбэк не будет выполнен, если метод предиката возвратит true. Это самый распространенный вариант. При использовании такой формы регистрации, также возможно зарегистрировать несколько различных предикатов, которые будут вызваны, чтобы проверить, должен ли выполняться колбэк.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: :paid_with_card?
end
```

### Использование `:if` и `:unless` с `Proc`

Наконец, можно связать `:if` и `:unless` с объектом `Proc`. Этот вариант больше всего подходит при написании коротких методов, обычно однострочных.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number,
    if: Proc.new { |order| order.paid_with_card? }
end
```

### Составные условия для колбэков

При написании условных колбэков, возможно смешивание `:if` и `:unless` в одном объявлении колбэка.

```ruby
class Comment < ApplicationRecord
  after_create :send_email_to_author, if: :author_wants_emails?,
    unless: Proc.new { |comment| comment.article.ignore_comments? }
end
```

Классы колбэков
---------------

Иногда написанные вами методы колбэков достаточно полезны для повторного использования в других моделях. Active Record делает возможным создавать классы, включающие методы колбэка, так, что становится очень легко использовать их повторно.

Вот пример, где создается класс с колбэком `after_destroy` для модели `PictureFile`:

```ruby
class PictureFileCallbacks
  def after_destroy(picture_file)
    if File.exist?(picture_file.filepath)
      File.delete(picture_file.filepath)
    end
  end
end
```

При объявлении внутри класса, как выше, методы колбэка получают объект модели как параметр. Теперь можем использовать класс колбэка в модели:

```ruby
class PictureFile < ApplicationRecord
  after_destroy PictureFileCallbacks.new
end
```

Заметьте, что нам нужно создать экземпляр нового объекта `PictureFileCallbacks`, после того, как объявили наш колбэк как отдельный метод. Это особенно полезно, если колбэки используют состояние экземпляра объекта. Часто, однако, более подходящим является объявление его в качестве метода класса.

```ruby
class PictureFileCallbacks
  def self.after_destroy(picture_file)
    if File.exist?(picture_file.filepath)
      File.delete(picture_file.filepath)
    end
  end
end
```

Если метод колбэка объявляется таким образом, нет необходимости создавать экземпляр объекта `PictureFileCallbacks`.

```ruby
class PictureFile < ApplicationRecord
  after_destroy PictureFileCallbacks
end
```

Внутри своего колбэк-класса можно создать сколько угодно колбэков.

Транзакционные колбэки
----------------------

Имеются два дополнительных колбэка, которые включаются по завершению транзакции базы данных: `after_commit` и `after_rollback`. Эти колбэки очень похожи на колбэк `after_save`, за исключением того, что они не выполняются пока изменения в базе данных не будут подтверждены или обращены. Они наиболее полезны, когда вашим моделям Active Record необходимо взаимодействовать с внешними системами, не являющимися частью транзакции базы данных.

Рассмотрим, допустим, предыдущий пример, где модели `PictureFile` необходимо удалить файл после того, как запись уничтожена. Если что-либо вызовет исключение после того, как был вызван колбэк `after_destroy`, и транзакция откатывается, файл будет удален и модель останется в противоречивом состоянии. Например, предположим, что `picture_file_2` в следующем коде не валидна, и метод `save!` вызовет ошибку.

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

NOTE: Опция `:on` определяет, когда будет запущен колбэк. Если не предоставить опцию `:on`, колбэк будет запущен для каждого экшна.

Так как принято использовать колбэк `after_commit` только при создании, обновлении или удалении, есть псевдонимы для этих операций:

* `after_create_commit`
* `after_update_commit`
* `after_destroy_commit`

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

WARNING: Колбэки `after_commit` и `after_rollback` вызываются для всех созданных, обновленных или удаленных моделей внутри блока транзакции. Однако, если какое-либо исключение вызовется в одном из этих колбэков, это исключение всплывет, и любые оставшиеся методы `after_commit` или `after_rollback` _не_ будут выполнены. По сути, если код вашего колбэка может вызвать исключение, нужно для него вызвать rescue, и обработать его в колбэке, чтобы позволить запуститься другим колбэкам.

WARNING. При одновременном использовании `after_create_commit` и `after_update_commit` в одной и той же модели сработает только колбэк, определенный последним, переопределив все остальные.

```ruby
class User < ApplicationRecord
  after_create_commit :log_user_saved_to_db
  after_update_commit :log_user_saved_to_db

  private
  def log_user_saved_to_db
    puts 'User was saved to database'
  end
end

# ничего не выводит
>> @user = User.create

# обновление @user
>> @user.save
=> User was saved to database
```

Чтобы зарегистрировать колбэки как для create, так и для update экшнов, используйте `after_commit`.

```ruby
class User < ApplicationRecord
  after_commit :log_user_saved_to_db, on: [:create, :update]
end
```
