Колбэки Active Record
=====================

Это руководство научит вас вмешиваться в жизненный цикл ваших объектов Active Record.

После прочтения этого руководства вы узнаете:

* Когда определенные события случаются в течение жизни объекта Active Record
* Как создавать методы колбэков, отвечающих на события в жизненном цикле объекта
* Как создавать специальные классы, инкапсулирующих обычное поведение для ваших колбэков

Жизненный цикл объекта
----------------------

В результате обычных операций приложения на Rails, объекты могут быть созданы, обновлены и уничтожены. Active Record дает возможность вмешаться в этот жизненный цикл объекта, таким образом, вы можете контролировать свое приложение и его данные.

Валидации позволяют вам быть уверенными, что только валидные данные хранятся в вашей базе данных. Колбэки позволяют вам переключать логику до или после изменения состояния объекта.

```ruby
class Baby < ApplicationRecord
  after_create -> { puts "Congratulations!" }
end
```

```irb
irb> @baby = Baby.create
Congratulations!
```

Вы увидите, что есть множество событий жизненного цикла, и вы сможете вклиниться в любое из них, до, после или даже вокруг них.

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
      if login.blank?
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

Альтернативно можно передать в колбэк proc, который будут выполнен.

```ruby
class User < ApplicationRecord
  before_create ->(user) { user.name = user.login.capitalize if user.name.blank? }
end
```

Наконец, можно определить собственный объект колбэка, который мы раскроем подробнее [ниже](#callback-classes).

```ruby
class User < ApplicationRecord
  before_create MaybeAddName
end

class MaybeAddName
  def self.before_create(record)
    if record.name.blank?
      record.name = record.login.capitalize
    end
  end
end
```

Колбэки также могут быть зарегистрированы на выполнение только при определенных событиях жизненного цикла, что позволяет полностью контролировать в каком контексте ваши колбэки выполняются.

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

WARNING. Избегайте вызовов `update`, `save` или других методов, которые создают побочные эффекты для объекта, внутри вашего колбэка. Например, не вызывайте `update(attribute: "value")` внутри колбэка. Это может изменить состояние модели и может привести к неожиданным побочным эффектам при завершении транзакции. Вместо этого можно безопасно присваивать значения напрямую (например, `self.attribute = "value"`) в `before_create` / `before_update` или более ранних колбэках.

Доступные колбэки
-----------------

Вот список всех доступных колбэков Active Record, перечисленных в том порядке, в котором они вызываются в течение соответствующих операций:

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

[`after_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_create
[`after_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_commit
[`after_rollback`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_rollback
[`after_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_save
[`after_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-after_validation
[`around_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_create
[`around_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_save
[`before_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_create
[`before_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_save
[`before_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-before_validation

### Обновление объекта

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_update`][]
* [`around_update`][]
* [`after_update`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]

[`after_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_update
[`around_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_update
[`before_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_update

WARNING. `after_save` запускается и при создании, и при обновлении, но всегда _после_ более специфичных колбэков `after_create` и `after_update`, независимо от порядка, в котором выполняются макро-вызовы.

### Уничтожение объекта

* [`before_destroy`][]
* [`around_destroy`][]
* [`after_destroy`][]
* [`after_commit`][] / [`after_rollback`][]

[`after_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_destroy
[`around_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_destroy
[`before_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_destroy

NOTE: Колбэк `before_destroy` должен быть размещен перед связями `dependent: :destroy` (или использовать опцию `prepend: true`), чтобы убедиться, что они выполняются до того, как записи будут удалены с помощью `dependent: :destroy`.

WARNING. `after_commit` создает гарантии, сильно отличающиеся от `after_save`, `after_update` и `after_destroy`. Например, если случается исключение в `after_save`, транзакция будет отменена, и данные не сохранятся. Не важно, что произойдет, `after_commit` может гарантировать, что транзакция уже произошла, и данные были сохранены в базу данных. Подробнее о [транзакционных колбэках](#transaction-callbacks) ниже.

### `after_initialize` и `after_find`

Всякий раз, когда возникает объект Active Record, будет вызван колбэк [`after_initialize`][], или непосредственно при использовании `new`, или когда запись загружается из базы данных. Он может быть полезен, чтобы избежать необходимости напрямую переопределять метод Active Record `initialize`.

При загрузке записи из базы данных, будет вызван колбэк [`after_find`][]. `after_find` вызывается перед `after_initialize`, если они оба определены.

NOTE: У колбэков `after_initialize` и `after_find` нет пары `before_*`.

Они могут быть зарегистрированы подобно другим колбэкам Active Record.

```ruby
class User < ApplicationRecord
  after_initialize do |user|
    puts "You have initialized an object!"
  end

  after_find do |user|
    puts "You have found an object!"
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

[`after_find`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_find
[`after_initialize`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_initialize

### `after_touch`

Колбэк [`after_touch`][] будет вызван, когда на объекте Active Record вызван `touch`.

```ruby
class User < ApplicationRecord
  after_touch do |user|
    puts "You have touched an object"
  end
end
```

```irb
irb> u = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

irb> u.touch
You have touched an object
=> true
```

Он может быть использован совместно с `belongs_to`:

```ruby
class Book < ApplicationRecord
  belongs_to :library, touch: true
  after_touch do
    puts 'A Book was touched'
  end
end

class Library < ApplicationRecord
  has_many :books
  after_touch :log_when_books_or_library_touched

  private
    def log_when_books_or_library_touched
      puts 'Book/Library was touched'
    end
end
```

```irb
irb> @book = Book.last
=> #<Book id: 1, library_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

irb> @book.touch # triggers @book.library.touch
A Book was touched
Book/Library was touched
=> true
```

[`after_touch`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_touch

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

NOTE: Методы `find_by_*` и `find_by_*!` это динамические методы поиска, генерируемые автоматически для каждого атрибута. Изучите подробнее их в [разделе Динамический поиск](/active-record-querying#dynamic-finders)

Пропуск колбэков
----------------

Подобно валидациям, также возможно пропустить колбэки, используя следующие методы.

* `decrement`
* `decrement!`
* `decrement_counter`
* `delete`
* `delete_all`
* `delete_by`
* `increment`
* `increment!`
* `increment_counter`
* `insert`
* `insert!`
* `insert_all`
* `insert_all!`
* `touch_all`
* `update_column`
* `update_columns`
* `update_all`
* `update_counters`
* `upsert`
* `upsert_all`

Однако, эти методы нужно использовать осторожно, поскольку важные бизнес-правила и логика приложения могут содержаться в колбэках. Пропуск их без понимания возможных последствий может привести к невалидным данным.

Прерывание выполнения
---------------------

Как только вы зарегистрировали новые колбэки в своих моделях, они будут поставлены в очередь на выполнение. Эта очередь включает все валидации вашей модели, зарегистрированные колбэки и операции с базой данных для выполнения.

Вся цепочка колбэков упаковывается в операцию. Если любой колбэк вызывает исключение, выполняемая цепочка прерывается и запускается ROLLBACK. Чтобы преднамеренно остановить цепочку, используйте:

```ruby
throw :abort
```

WARNING. Вызов произвольного исключения может прервать код, который предполагает, что `save` и тому подобное не будут провалены подобным образом. Исключение `ActiveRecord::Rollback` чуть точнее сообщает Active Record, что происходит откат. Он подхватывается изнутри, но не перевызывает исключение.

WARNING. Любое исключение, кроме `ActiveRecord::Rollback` или `ActiveRecord::RecordInvalid`, будет перевызвано Rails после того, как прервется цепочка колбэков. Помимо этого, они могут сломать код, который не ожидает, что методы, такие как `save` и `update` (которые обычно пытаются вернуть `true` или `false`) вызовут исключение.

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

(association-callbacks) Колбэки связи
---------------------

TODO

Условные колбэки
----------------

Как и в валидациях, возможно сделать вызов метода колбэка условным в зависимости от заданного предиката. Это осуществляется при использовании опций `:if` и `:unless`, которые могут принимать символ, `Proc` или массив.

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
    if: Proc.new { |order| order.paid_with_card? }
end
```

Так как proc вычисляется в контексте объекта, также возможно написать так:

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: Proc.new { paid_with_card? }
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
    if: [:subject_to_parental_control?, Proc.new { untrusted_author? }]
end
```

### Одновременное использование :if и :unless

В колбэках можно смешивать `:if` и `:unless` в одном выражении:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: Proc.new { forum.parental_control? },
    unless: Proc.new { author.trusted? }
end
```

Колбэк запустится только когда все условия `:if` и не один из условий `:unless` будут истинны.

(callback-classes) Классы колбэков
----------------------------------

Иногда написанные вами методы колбэков достаточно полезны для повторного использования в других моделях. Active Record делает возможным создавать классы, включающие методы колбэка, так, что их можно использовать повторно.

Вот пример, где создается класс с колбэком `after_destroy`, чтобы разобраться с очисткой отвергнутых файлов в файловой системе. Это поведение может быть неуникальным для нашей модели `PictureFile`, и мы хотим поделиться им, таким образом хорошей идеей будет инкапсуляция его в отдельный класс. Это сделает более простым тестирование и изменение этого поведения.

```ruby
class FileDestroyerCallback
  def after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

При объявлении внутри класса, как выше, методы колбэка получают объект модели как параметр. Это будет работать с любой моделью, которая использует класс подобным образом:

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback.new
end
```

Заметьте, что нам нужно создать экземпляр нового объекта `FileDestroyerCallback`, после того, как объявили наш колбэк как отдельный метод. Это особенно полезно, если колбэки используют состояние экземпляра объекта. Часто, однако, более подходящим является объявление его в качестве метода класса.

```ruby
class FileDestroyerCallback
  def self.after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

Когда метод колбэка объявляется таким образом, нет необходимости создавать экземпляр объекта `FileDestroyerCallback` в нашей модели.

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback
end
```

Внутри своего колбэк-класса можно создать сколько угодно колбэков.

(transaction-callbacks) Транзакционные колбэки
----------------------------------------------

### Разбираемся с согласованностью

Имеются два дополнительных колбэка, которые включаются по завершению транзакции базы данных: [`after_commit`][] и [`after_rollback`][]. Эти колбэки очень похожи на колбэк `after_save`, за исключением того, что они не выполняются пока изменения в базе данных не будут подтверждены или обращены. Они наиболее полезны, когда вашим моделям Active Record необходимо взаимодействовать с внешними системами, не являющимися частью транзакции базы данных.

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

### Контекст имеет значение

Так как принято использовать колбэк `after_commit` только при создании, обновлении или удалении, есть псевдонимы для этих операций:

* [`after_create_commit`][]
* [`after_update_commit`][]
* [`after_destroy_commit`][]

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

WARNING: Когда завершается транзакция, колбэки `after_commit` и `after_rollback` вызываются для всех созданных, обновленных или удаленных моделей внутри транзакции. Однако, если какое-либо исключение вызовется в одном из этих колбэков, это исключение всплывет, и любые оставшиеся методы `after_commit` или `after_rollback` _не_ будут выполнены. По сути, если код вашего колбэка может вызвать исключение, нужно для него вызвать rescue, и обработать его в колбэке, чтобы позволить запуститься другим колбэкам.

WARNING. Сам код, выполняемый в колбэках `after_commit` или `after_rollback`, не замкнут в транзакцию.

WARNING. При одновременном использовании `after_create_commit` и `after_update_commit` с тем же именем метода, сработает только колбэк, определенный последним, так как они оба являются псевдонимами к `after_commit`, который переопределяет ранее определенные колбэки с тем же именем метода.

```ruby
class User < ApplicationRecord
  after_create_commit :log_user_saved_to_db
  after_update_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'User was saved to database'
    end
end
```

```irb
irb> @user = User.create # ничего не выводит

irb> @user.save # обновление @user
User was saved to database
```

### `after_save_commit`

Также имеется [`after_save_commit`][], являющийся псевдонимом для использования колбэком `after_commit` вместе для создания и обновления:

```ruby
class User < ApplicationRecord
  after_save_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'User was saved to database'
    end
end
```

```irb
irb> @user = User.create # создание a User
User was saved to database

irb> @user.save # обновление @user
User was saved to database
```

### Упорядочивание транзакционных колбэков

При определении нескольких транзакционных колбэков `after_` (`after_commit`, `after_rollback` и т.д.), порядок будет обратным к тому, как они определены.

```ruby
class User < ActiveRecord::Base
  after_commit { puts("это будет фактически вызвано вторым") }
  after_commit { puts("это будет фактически вызвано первым") }
end
```

NOTE: Это также применяется ко всем вариациям `after_*_commit`, таким как `after_destroy_commit`.

[`after_create_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_create_commit
[`after_destroy_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_destroy_commit
[`after_save_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_save_commit
[`after_update_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_update_commit
