Расширения ядра Active Support
==============================

Active Support - это компонент Ruby on Rails, отвечающий за предоставление расширений для языка Ruby, утилит и множества других вещей.

Он предлагает более ценные функции на уровне языка, нацеленные как на разработку приложений на Rails, так и на разработку самого Ruby on Rails.

После прочтения этого руководства, вы узнаете:

* Что такое расширения ядра.
* Как загрузить все расширения.
* Как подобрать только те расширения, которые вам нужны.
* Какие расширения предоставляет Active Support.

Как загрузить расширения ядра
-----------------------------

### Автономный Active Support

Для обеспечения минимума влияния, Active Support по умолчанию ничего не загружает. Он разбит на маленькие части, поэтому можно загружать лишь то, что нужно, и имеет некоторые точки входа, которые по соглашению загружают некоторые расширения за раз, или даже все.

Таким образом, после обычного require:

```ruby
require 'active_support'
```

объекты не будут даже реагировать на `blank?`. Давайте посмотрим, как загрузить эти определения.

#### Подбор определений

Наиболее легкий способ получить `blank?` - подцепить файл, который его определяет.

Для каждого отдельного метода, определенного как расширение ядра, в этом руководстве имеется заметка, сообщающая, где такой метод определяется. В случае с `blank?` заметка гласит:

NOTE: Определено в `active_support/core_ext/object/blank.rb`.

Это означает, что это можно затребовать следующим образом:

```ruby
require 'active_support'
require 'active_support/core_ext/object/blank'
```

Active Support был тщательно пересмотрен и теперь подхватывает только те файлы для загрузки, которые содержат строго необходимые зависимости, если такие имеются.

#### Загрузка сгруппированных расширений ядра

Следующий уровень - это просто загрузка всех расширений к `Object`. Как правило, расширения к `SomeClass` доступны за раз при загрузке `active_support/core_ext/some_class`.

Таким образом, чтобы загрузить все расширения `Object` (в том числе `blank?`):

```ruby
require 'active_support'
require 'active_support/core_ext/object'
```

#### Загрузка всех расширений ядра

Возможно, вы предпочтете загрузить все расширения ядра, вот файл для этого необходимо:

```ruby
require 'active_support'
require 'active_support/core_ext'
```

#### Загрузка всего Active Support

И наконец, если необходимо получить доступ ко всему Active Support, просто выполните:

```ruby
require 'active_support/all'
```

В действительности это даже не поместит весь Active Support в память, так как некоторые вещи настроены через `autoload`, поэтому они загружаются только когда используются.

### Active Support в приложении на Ruby on Rails

Приложение на Ruby on Rails загружает весь Active Support, кроме случая когда `config.active_support.bare` равен true. В этом случае приложение загрузит только сам фреймворк и подберет файлы для собственных нужд, и позволит подобрать вам файлы самостоятельно на любом уровне, как описано в предыдущем разделе.

Расширения ко всем объектам
---------------------------

### `blank?` и `present?`

Следующие значения рассматриваются как пустые в Rails приложении:

* `nil` и `false`,
* строки, состоящие только из пробелов (смотрите примечание ниже),
* пустые массивы и хэши,
* и любые другие объекты, откликающиеся на `empty?` и являющиеся пустыми.

INFO: Предикат для строк использует совместимый с Unicode символьный класс `[:space:]`, поэтому, к примеру, U+2029 (разделитель параграфов) рассматривается как пробел.

WARNING: Отметьте, что числа тут не упомянуты, в частности, 0 и 0.0 **не** являются пустыми.

Например, этот метод из `ActionController::HttpAuthentication::Token::ControllerMethods` использует `blank?` для проверки, существует ли токен:

```ruby
def authenticate(controller, &login_procedure)
  token, options = token_and_options(controller.request)
  unless token.blank?
    login_procedure.call(token, options)
  end
end
```

Метод `present?` является эквивалентом `!blank?`. Этот пример взят из `ActionDispatch::Http::Cache::Response`:

```ruby
def set_conditional_cache_control!
  return if self["Cache-Control"].present?
  ...
end
```

NOTE: Определено в `active_support/core_ext/object/blank.rb`.

### `presence`

Метод `presence` возвращает его получателя, если `present?`, и `nil` в противном случае. Он полезен для подобных идиом:

```ruby
host = config[:host].presence || 'localhost'
```

NOTE: Определено в `active_support/core_ext/object/blank.rb`.

### `duplicable?`

В Ruby 2.5 большинство объектов могут дублироваться с помощью `dup` или `clone`:

```ruby
"foo".dup           # => "foo"
"".dup              # => ""
Rational(1).dup     # => (1/1)
Complex(0).dup      # => (0+0i)
1.method(:+).dup    # => TypeError (allocator undefined for Method)
```

Active Support предоставляет `duplicable?` для запроса к объекту об этой возможности:

```ruby
"foo".duplicable?        # => true
"".duplicable?           # => true
Rational(1).duplicable?  # => true
Complex(1).duplicable?   # => true
1.method(:+).duplicable? # => false
```

`duplicable?` соответствует поведению `dup` текущей версии Ruby, поэтому результаты будут варьироваться в зависимости от используемой версии Ruby. В Ruby 2.4, например, Complex и Rational не дублируются:

```ruby
Rational(1).duplicable?     # => false
Complex(1).duplicable?      # => false
```

WARNING. Любой класс может запретить дублирование, убрав `dup` и `clone`, или вызвав исключение в них. Таким образом, только `rescue` может сказать, является ли данный произвольный объект дублируемым. `duplicable?` зависит от жестко заданного вышеуказанного перечня, но он намного быстрее, чем `rescue`. Используйте его только в том случае, если знаете, что жесткий перечень достаточен в конкретном случае.

NOTE: Определено в `active_support/core_ext/object/duplicable.rb`.

### `deep_dup`

Метод `deep_dup` возвращает "глубокую" копию данного объекта. Обычно при вызове `dup` на объекте, содержащем другие объекты, Ruby не вызывает `dup` для них, поэтому он создает "мелкую" копию объекта. Если, к примеру, имеется массив со строкой, это будет выглядеть так:

```ruby
array     = ['string']
duplicate = array.dup

duplicate.push 'another-string'

# объект был дублирован, поэтому элемент был добавлен только в дубликат
array     # => ['string']
duplicate # => ['string', 'another-string']

duplicate.first.gsub!('string', 'foo')

# первый элемент не был дублирован, он будет изменен в обоих массивах
array     # => ['foo']
duplicate # => ['foo', 'another-string']
```

Как видите, после дублирования экземпляра `Array`, мы получили еще один объект, следовательно мы можем его модифицировать, и исходный объект останется нетронутым. Однако, это не истинно для элементов массива. Поскольку `dup` не делает "глубокую" копию, строка внутри массива остается тем же самым объектом.

Если нужна "глубокая" копия объекта, следует использовать `deep_dup`. Вот пример:

```ruby
array     = ['string']
duplicate = array.deep_dup

duplicate.first.gsub!('string', 'foo')

array     # => ['string']
duplicate # => ['foo']
```

Если объект нельзя дублировать, `deep_dup` просто возвратит его:

```ruby
number = 1
duplicate = number.deep_dup
number.object_id == duplicate.object_id   # => true
```

NOTE: Определено в `active_support/core_ext/object/deep_dup.rb`.

### `try`

Когда необходимо вызвать метод на объекте, но только в том случае, если он не `nil`, то простейшим способом достичь этого является условное выражение, добавляющее ненужный код. Альтернативой является использование `try`. `try` похож на `Object#send` за исключением того, что он возвращает `nil`, если вызван на `nil`.

Вот пример:

```ruby
# без try
unless @number.nil?
  @number.next
end

# используя try
@number.try(:next)
```

Другим примером является этот код из `ActiveRecord::ConnectionAdapters::AbstractAdapter`, где `@logger` может быть `nil`. Код использует `try` и позволяет избегать ненужной проверки.

```ruby
def log_info(sql, name, ms)
  if @logger.try(:debug?)
    name = '%s (%.1fms)' % [name || 'SQL', ms]
    @logger.debug(format_log_entry(name, sql.squeeze(' ')))
  end
end
```

`try` также может быть вызван не с аргументами, а с блоком, который будет выполнен, если объект не nil:

```ruby
@person.try { |p| "#{p.first_name} #{p.last_name}" }
```

Отметьте, что `try` поглотит ошибки об отсутствующем методе, возвратив вместо них nil. Если необходимо защититься от таких ошибок, используйте вместо него `try!`:

```ruby
@number.try(:nest)  # => nil
@number.try!(:nest) # NoMethodError: undefined method `nest' for 1:Integer
```

NOTE: Определено в `active_support/core_ext/object/try.rb`.

### `class_eval(*args, &block)`

Можно вычислить код в контексте синглтон-класса любого объекта, используя `class_eval`:

```ruby
class Proc
  def bind(object)
    block, time = self, Time.current
    object.class_eval do
      method_name = "__bind_#{time.to_i}_#{time.usec}"
      define_method(method_name, &block)
      method = instance_method(method_name)
      remove_method(method_name)
      method
    end.bind(object)
  end
end
```

NOTE: Определено в `active_support/core_ext/kernel/singleton_class.rb`.

### `acts_like?(duck)`

Метод `acts_like?` предоставляет возможность проверить, работает ли некий класс как некоторый другой класс, основываясь на простом соглашении: класс предоставляющий тот же интерфейс, как у `String` определяет

```ruby
def acts_like_string?
end
```

являющийся всего лишь маркером, его содержимое или возвращаемое значение ничего не значит. Затем, код клиента может запросить "безопасную утиную типизацию" следующим образом:

```ruby
some_klass.acts_like?(:string)
```

В Rails имеются классы, действующие как `Date` или `Time` и следующие этому соглашению.

NOTE: Определено в `active_support/core_ext/object/acts_like.rb`.

### `to_param`

Все объекты в Rails отвечают на метод `to_param`, который предназначен для возврата чего-то, что представляет их в строке запроса или как фрагменты URL.

По умолчанию `to_param` просто вызывает `to_s`:

```ruby
7.to_param # => "7"
```

Возвращаемое значение `to_param` **не** должно быть экранировано:

```ruby
"Tom & Jerry".to_param # => "Tom & Jerry"
```

Некоторые классы в Rails переопределяют этот метод.

Например, `nil`, `true` и `false` возвращают сами себя. `Array#to_param` вызывает `to_param` на элементах и соединяет результат с помощью "/":

```ruby
[0, true, String].to_param # => "0/true/String"
```

В частности, система роутинга Rails вызывает `to_param` на моделях, чтобы получить значение для местозаполнителя `:id`. `ActiveRecord::Base#to_param` возвращает `id` модели, но можно переопределить этот метод в своих моделях. Например, задав

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

мы получим:

```ruby
user_path(@user) # => "/users/357-john-smith"
```

WARNING. Контроллерам нужно быть в курсе любых переопределений `to_param`, поскольку в подобном запросе "357-john-smith" будет значением `params[:id]`.

NOTE: Определено в `active_support/core_ext/object/to_param.rb`.

### `to_query`

За исключением хэшей, для заданного неэкранированного `ключа` этот метод создает часть строки запроса, который связывает с этим ключом то, что возвращает `to_param`. Например, задав

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

мы получим:

```ruby
current_user.to_query('user') # => "user=357-john-smith"
```

Этот метод экранирует все, что требуется: и ключ, и значение:

```ruby
account.to_query('company[name]')
# => "company%5Bname%5D=Johnson+%26+Johnson"
```

поэтому результат готов для использования в строке запроса.

Массивы возвращают результат применения `to_query` к каждому элементу с `key[]` в качестве ключа, и соединяет результат с помощью "&":

```ruby
[3.4, -45.6].to_query('sample')
# => "sample%5B%5D=3.4&sample%5B%5D=-45.6"
```

Хэши также отвечают на `to_query`, но c другой сигнатурой. Если аргумент не передается, вызов генерирует отсортированную серию присваиваний ключ/значение, вызвав `to_query(key)` на этих значениях. Затем он соединяет результат с помощью "&":

```ruby
{c: 3, b: 2, a: 1}.to_query # => "a=1&b=2&c=3"
```

Метод `Hash#to_query` принимает опциональное пространство имен для ключей:

```ruby
{id: 89, name: "John Smith"}.to_query('user')
# => "user%5Bid%5D=89&user%5Bname%5D=John+Smith"
```

NOTE: Определено в `active_support/core_ext/object/to_query.rb`.

### `with_options`

Метод `with_options` предоставляет способ для выделения общих опций в серии вызовов метода.

Задав дефолтный хэш опций, `with_options` предоставляет прокси-объект в блок. Внутри блока методы, вызванные на прокси, отправляются получателю с объединением своих опций. Например, чтобы избавиться от дублирования:

```ruby
class Account < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :products,  dependent: :destroy
  has_many :invoices,  dependent: :destroy
  has_many :expenses,  dependent: :destroy
end
```

заменяем на:

```ruby
class Account < ApplicationRecord
  with_options dependent: :destroy do |assoc|
    assoc.has_many :customers
    assoc.has_many :products
    assoc.has_many :invoices
    assoc.has_many :expenses
  end
end
```

Эта идиома может передавать _группировку_ в ридер (reader). Например скажем, что нужно послать newsletter, язык которого зависит от пользователя. Где-нибудь в рассыльщике можно сгруппировать кусочки, зависимые от локали, следующим образом:

```ruby
I18n.with_options locale: user.locale, scope: "newsletter" do |i18n|
  subject i18n.t :subject
  body    i18n.t :body, user_name: user.name
end
```

TIP: Поскольку `with_options` переадресовывает вызовы получателю, они могут быть вложены. Каждый уровень вложенности будет объединять унаследованные дефолтные значения со своими собственными.

NOTE: Определено в `active_support/core_ext/object/with_options.rb`.

### Поддержка JSON

Active Support обеспечивает лучшую реализацию `to_json`, чем гем `json`, обычно предоставленный для объектов Ruby. Это так, потому что некоторые классы, такие как `Hash`, `OrderedHash` и `Process::Status`, нуждаются в специальной обработке для обеспечения подходящего JSON.

NOTE: Определено в `active_support/core_ext/object/json.rb`.

### Переменные экземпляра

Active Support предоставляет несколько методов для облегчения доступа к переменным экземпляра.

#### `instance_values`

Метод `instance_values` возвращает хэш, который связывает имена переменных экземпляра без "@" с их соответствующими значениями. Ключи являются строками:

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_values # => {"x" => 0, "y" => 1}
```

NOTE: Определено в `active_support/core_ext/object/instance_variables.rb`.

#### `instance_variable_names`

Метод `instance_variable_names` возвращает массив.  Каждое имя включает знак "@".

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_variable_names # => ["@x", "@y"]
```

NOTE: Определено в `active_support/core_ext/object/instance_variables.rb`.

### Отключение предупреждений и исключения

Методы `silence_warnings` и `enable_warnings` изменяют значение `$VERBOSE` в течение исполнения блока, и сбрасывают в исходное значение после его окончания:

```ruby
silence_warnings { Object.const_set "RAILS_DEFAULT_LOGGER", logger }
```

Отключение исключений также возможно с помощью `suppress`. Этот метод получает определенное количество классов исключений. Если вызывается исключение во время выполнения блока, и `kind_of?` соответствует любому аргументу, `suppress` ловит его и возвращает отключенным. В противном случае исключение не захватывается:

```ruby
# Если пользователь под блокировкой, инкремент теряется, ничего страшного.
suppress(ActiveRecord::StaleObjectError) do
  current_user.increment! :visits
end
```

NOTE: Определено в `active_support/core_ext/kernel/reporting.rb`.

### `in?`

Предикат `in?` проверяет, включен ли объект в другой объект. Если переданный элемент не отвечает на `include?`, будет вызвано исключение `ArgumentError`.

Примеры применения `in?`:

```ruby
1.in?([1,2])        # => true
"lo".in?("hello")   # => true
25.in?(30..50)      # => false
1.in?(1)            # => ArgumentError
```

NOTE: Определено в `active_support/core_ext/object/inclusion.rb`.

Расширения для `Module`
-----------------------

### Атрибуты

#### `alias_attribute`

В атрибутах модели есть ридер (reader), райтер (writer) и предикат. Можно создать псевдоним к атрибуту модели, в котором будут определены сразу три соответствующих метода. Как и в других создающих псевдоним методах, новое имя - это первый аргумент, а старое имя - второй (мнемоническое правило такое: они идут в том же порядке, как если бы делалось присваивание):

```ruby
class User < ApplicationRecord
  # Теперь можно обращаться к столбцу email как "login".
  # Это имеет больше смысла для кода аутентификации.
  alias_attribute :login, :email
end
```

NOTE: Определено в `active_support/core_ext/module/aliasing.rb`.

#### Внутренние атрибуты

При определении атрибута в классе, который предназначен для подкласса, есть риск коллизии подклассовых имен. Это особенно важно для библиотек.

Active Support определяет макросы `attr_internal_reader`, `attr_internal_writer` и `attr_internal_accessor`. Они ведут себя подобно встроенным в Ruby коллегам `attr_*`, за исключением того, что они именуют лежащую в основе переменную экземпляра способом, наиболее снижающим коллизии.

Макрос `attr_internal` - это синоним для `attr_internal_accessor`:

```ruby
# библиотека
class ThirdPartyLibrary::Crawler
  attr_internal :log_level
end

# код клиента
class MyCrawler < ThirdPartyLibrary::Crawler
  attr_accessor :log_level
end
```

В предыдущем примере мог быть случай, при котором `:log_level` не принадлежит публичному интерфейсу библиотеки и используется только для разработки. Код клиента, не подозревающий о потенциальном конфликте, создает подкласс и определяет внутри него свой `:log_level`. Благодаря `attr_internal` здесь не будет коллизий.

По умолчанию внутренняя переменная экземпляра именуется с предшествующим подчеркиванием, `@_log_level` в примере выше. Это настраивается через `Module.attr_internal_naming_format`, куда можно передать любую строку в формате `sprintf` с предшествующими `@` и `%s` в любом месте, которая означает место, куда вставляется имя. По умолчанию `"@_%s"`.

Rails использует внутренние атрибуты в некоторых местах, например для вьюх:

```ruby
module ActionView
  class Base
    attr_internal :captures
    attr_internal :request, :layout
    attr_internal :controller, :template
  end
end
```

NOTE: Определено в `active_support/core_ext/module/attr_internal.rb`.

#### Атрибуты модуля

Макросы `mattr_reader`, `mattr_writer` и `mattr_accessor` - это те же самые макросы `cattr_*`, определенным для класса. Фактически, макросы `cattr_*` — это всего лишь псевдонимы для макросов `mattr_*`. Смотрите [Атрибуты класса](#extensions-to-class).

Например, их использует механизм зависимостей:

```ruby
module ActiveSupport
  module Dependencies
    mattr_accessor :warnings_on_first_load
    mattr_accessor :history
    mattr_accessor :loaded
    mattr_accessor :mechanism
    mattr_accessor :load_paths
    mattr_accessor :load_once_paths
    mattr_accessor :autoloaded_constants
    mattr_accessor :explicitly_unloadable_constants
    mattr_accessor :constant_watch_stack
    mattr_accessor :constant_watch_stack_mutex
  end
end
```

NOTE: Определено в `active_support/core_ext/module/attribute_accessors.rb`.

### Родители

#### `parent`

Метод `parent` на вложенном именованном модуле возвращает модуль, содержащий его соответствующую константу:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.parent # => X::Y
M.parent       # => X::Y
```

Если модуль анонимный или относится к верхнему уровню, `parent` возвращает `Object`.

WARNING: Отметьте, что в этом случае `parent_name` возвращает `nil`.

NOTE: Определено в `active_support/core_ext/module/introspection.rb`.

#### `parent_name`

Метод `parent_name` на вложенном именованном модуле возвращает полностью определенное имя модуля, содержащего его соответствующую константу:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.parent_name # => "X::Y"
M.parent_name       # => "X::Y"
```

Для верхнеуровневых и анонимных модулей `parent_name` возвращает `nil`.

WARNING: Отметьте, что в этом случае `parent` возвращает `Object`.

NOTE: Определено в `active_support/core_ext/module/introspection.rb`.

#### `parents`

Метод `parents` вызывает `parent` на получателе и вверх по иерархии, пока не будет достигнут `Object`. Цепочка возвращается в массиве, от низшего к высшему:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.parents # => [X::Y, X, Object]
M.parents       # => [X::Y, X, Object]
```

NOTE: Определено в `active_support/core_ext/module/introspection.rb`.

### Anonymous

У модуля может быть или не быть имени:

```ruby
module M
end
M.name # => "M"

N = Module.new
N.name # => "N"

Module.new.name # => nil
```

Можно проверить, имеет ли модуль имя с помощью предиката `anonymous?`:

```ruby
module M
end
M.anonymous? # => false

Module.new.anonymous? # => true
```

Отметьте, что быть недостижимым не означает быть анонимным:

```ruby
module M
end

m = Object.send(:remove_const, :M)

m.anonymous? # => false
```

хотя анонимный модуль недостижим по определению.

NOTE: Определено в `active_support/core_ext/module/anonymous.rb`.

### Делегирование метода

#### `delegate`

Макрос `delegate` предлагает простой способ передать методы.

Давайте представим, что у пользователей в неком приложении имеется информация о логинах в модели `User`, но имена и другие данные в отдельной модели `Profile`:

```ruby
class User < ApplicationRecord
  has_one :profile
end
```

С такой конфигурацией можно получить имя пользователя через его профиль, `user.profile.name`, но было бы удобнее обеспечить доступ к такому атрибуту напрямую:

```ruby
class User < ApplicationRecord
  has_one :profile

  def name
    profile.name
  end
end
```

Это как раз то, что делает `delegate`:

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate :name, to: :profile
end
```

Это короче, и намерения более очевидные.

Целевой метод должен быть публичным.

Макрос `delegate` принимает несколько методов:

```ruby
delegate :name, :age, :address, :twitter, to: :profile
```

При интерполяции в строку опция `:to` должна стать выражением, вычисляемым объектом, метод которого делегируется. Обычно строка или символ. Такое выражение вычисляется в контексте получателя:

```ruby
# делегирует константе Rails
delegate :logger, to: :Rails

# делегирует классу получателя
delegate :table_name, to: :class
```

WARNING: Если опция `:prefix` установлена в `true` - это менее характерно, смотрите ниже.

По умолчанию, если делегирование вызывает `NoMethodError` и цель является `nil`, выводится исключение. Можно попросить с помощью опции `:allow_nil`, чтобы вместо этого возвращался `nil`:

```ruby
delegate :name, to: :profile, allow_nil: true
```

С `:allow_nil` вызов `user.name` возвратит `nil`, если у пользователя нет профиля.

Опция `:prefix` добавляет префикс к имени генерируемого метода. Это может быть удобно, например, для получения более благозвучного имени:

```ruby
delegate :street, to: :address, prefix: true
```

Предыдущий пример сгенерирует `address_street`, а не `street`.

WARNING: Поскольку в этом случае имя генерируемого метода составляется из имен целевого объекта и целевого метода, опция `:to` должна быть именем метода.

Также может быть настроен произвольный префикс:

```ruby
delegate :size, to: :attachment, prefix: :avatar
```

В предыдущем примере макрос генерирует `avatar_size`, а не `size`.

NOTE: Определено в `active_support/core_ext/module/delegation.rb`

#### `delegate_missing_to`

Представьте, что нужно делегировать все, отсутствующее в объекте `User` в `Profile`. Макрос `delegate_missing_to` позволяет реализовать это быстро:

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate_missing_to :profile
end
```

Целью может быть все что угодно, вызываемое внутри объекта, например, переменные экземпляра, методы, константы и т.д. Делегируются только публичные методы цели.

NOTE: Определено в `active_support/core_ext/module/delegation.rb`.

### Переопределение методов

Бывают ситуации, когда нужно определить метод с помощью `define_method`, но вы не знаете, существует ли уже метод с таким именем. Если так, то выдается предупреждение, если оно включено. Такое поведение хоть и не ошибочно, но не элегантно.

Метод `redefine_method` предотвращает такое потенциальное предупреждение, предварительно убирая существующий метод, если нужно.

Также можно использовать `silence_redefinition_of_method`, если необходимо определить заменяющий метод отдельно (потому что используется `delegate`, например).

NOTE: Определено в `active_support/core_ext/module/redefine_method.rb`.

(extensions-to-class) Расширения для `Class`
--------------------------------------------

### Атрибуты класса

#### `class_attribute`

Метод `class_attribute` объявляет один или более наследуемых атрибутов класса, которые могут быть переопределены на низшем уровне иерархии:

```ruby
class A
  class_attribute :x
end

class B < A; end

class C < B; end

A.x = :a
B.x # => :a
C.x # => :a

B.x = :b
A.x # => :a
C.x # => :b

C.x = :c
A.x # => :a
B.x # => :b
```

Например, `ActionMailer::Base` определяет:

```ruby
class_attribute :default_params
self.default_params = {
  mime_version: "1.0",
  charset: "UTF-8",
  content_type: "text/plain",
  parts_order: [ "text/plain", "text/enriched", "text/html" ]
}.freeze
```

К ним также есть доступ, и они могут быть переопределены на уровне экземпляра:

```ruby
A.x = 1

a1 = A.new
a2 = A.new
a2.x = 2

a1.x # => 1, приходит из A
a2.x # => 2, переопределено в a2
```

Генерация райтер-метода экземпляра может быть отключена установлением опции `:instance_writer` в `false`.

```ruby
module ActiveRecord
  class Base
    class_attribute :table_name_prefix, instance_writer: false, default: "my"
  end
end
```

В модели такая опция может быть полезной как способ предотвращения массового назначения для установки атрибута.

Генерация ридер-метода экземпляра может быть отключена установлением опции `:instance_reader` в `false`.

```ruby
class A
  class_attribute :x, instance_reader: false
end

A.new.x = 1
A.new.x # NoMethodError
```

Для удобства `class_attribute` определяет также предикат экземпляра, являющийся двойным отрицанием того, что возвращает ридер экземпляра. В вышеописанном примере оно может вызываться `x?`.

Когда `instance_reader` равен `false`, предикат экземпляра возвратит `NoMethodError`, как и ридер-метод.

Если не нужен предикат, передайте `instance_predicate: false`, и он не будет определен.

NOTE: Определено в `active_support/core_ext/class/attribute.rb`.

#### `cattr_reader`, `cattr_writer` и `cattr_accessor`

Макросы `cattr_reader`, `cattr_writer` и `cattr_accessor` являются аналогами их коллег `attr_*`, но для классов. Они инициализируют переменную класса как `nil`, если она еще не существует, и генерируют соответствующие методы класса для доступа к ней:

```ruby
class MysqlAdapter < AbstractAdapter
  # Генерирует методы класса для доступа к @@emulate_booleans.
  cattr_accessor :emulate_booleans
end
```

Также можно передать блок в `cattr_*` для настройки атрибута со значением по умолчанию:

```ruby
class MysqlAdapter < AbstractAdapter
  # Генерирует методы класса для доступа к @@emulate_booleans со значением по умолчанию true.
  cattr_accessor :emulate_booleans, default: true
end
```

Методы экземпляра также создаются для удобства, они всего лишь прокси к атрибуту класса. Таким образом, экземпляры могут менять атрибут класса, но не могут переопределять его, как это происходит в случае с `class_attribute` (смотрите выше). К примеру, задав

```ruby
module ActionView
  class Base
    cattr_accessor :field_error_proc, default: Proc.new { ... }
  end
end
```

мы получим доступ к `field_error_proc` во вьюхах.

Генерация ридер-метода экземпляра предотвращается установкой `:instance_reader` в `false` и генерация райтер-метода экземпляра предотвращается установкой `:instance_writer` в `false`. Генерация обоих методов предотвращается установкой `:instance_accessor` в `false`. Во всех случаях, должно быть не любое ложное значение, а именно `false`:

```ruby
module A
  class B
    # first_name ридер экземпляра не генерируется.
    cattr_accessor :first_name, instance_reader: false
    # last_name= райтер экземпляра не генерируется.
    cattr_accessor :last_name, instance_writer: false
    # surname ридер экземпляра или surname= райтер экземпляра не генерируется.
    cattr_accessor :surname, instance_accessor: false
  end
end
```

В модели может быть полезным установить `:instance_accessor` в `false` как способ предотвращения массового назначения для установки атрибута.

NOTE: Определено в `active_support/core_ext/class/attribute_accessors.rb`.

### Подклассы и потомки

#### `subclasses`

Метод `subclasses` возвращает подклассы получателя:

```ruby
class C; end
C.subclasses # => []

class B < C; end
C.subclasses # => [B]

class A < B; end
C.subclasses # => [B]

class D < C; end
C.subclasses # => [B, D]
```

Порядок, в котором эти классы возвращаются, не определен.

NOTE: Определено в `active_support/core_ext/class/subclasses.rb`.

#### `descendants`

Метод `descendants` возвращает все классы, которые являются `<` к его получателю:

```ruby
class C; end
C.descendants # => []

class B < C; end
C.descendants # => [B]

class A < B; end
C.descendants # => [B, A]

class D < C; end
C.descendants # => [B, A, D]
```

Порядок, в котором эти классы возвращаются, не определен.

NOTE: Определено в `active_support/core_ext/class/subclasses.rb`.

Расширения для `String`
-----------------------

### Безопасность вывода

#### Мотивация

Вставка данных в шаблоны HTML требует дополнительной осторожности. Например, нельзя просто интерполировать `@review.title` на страницу HTML. С одной стороны, если заголовок рецензии "Flanagan & Matz rules!", то результат не будет правильно отображен, поскольку амперсанд должен быть экранирован как "&amp;amp;". К тому же, в зависимости от приложения, это может быть большой дырой в безопасности, так как пользователи могут внедрить вредоносный HTML, устанавливающий вручную изготовленный заголовок рецензии. Смотрите подробную информацию о рисках в разделе о межсайтовом скриптинге в руководстве [Безопасность приложений на Rails](/ruby-on-rails-security-guide#cross-site-scripting-xss).

#### Безопасные строки

В Active Support есть концепция _(html) безопасных_ строк. Безопасная строка - это та, которая помечена как подлежащая вставке в HTML как есть. Ей можно доверять, независимо от того, была она экранирована или нет.

Строки рассматриваются как _небезопасные_ по умолчанию:

```ruby
"".html_safe? # => false
```

Можно получить безопасную строку из заданной с помощью метода `html_safe`:

```ruby
s = "".html_safe
s.html_safe? # => true
```

Важно понять, что `html_safe` не выполняет какого бы то ни было экранирования, это всего лишь утверждение:

```ruby
s = "<script>...</script>".html_safe
s.html_safe? # => true
s            # => "<script>...</script>"
```

Вы ответственны за обеспечение вызова `html_safe` на подходящей строке.

При присоединении к безопасной строке или с помощью `concat`/`<<`, или с помощью `+`, результат будет безопасной строкой. Небезопасные аргументы экранируются:

```ruby
"".html_safe + "<" # => "&lt;"
```

Безопасные аргументы непосредственно присоединяются:

```ruby
"".html_safe + "<".html_safe # => "<"
```

Эти методы не должны использоваться в обычных вьюхах. Небезопасные значения автоматически экранируются:

```erb
<%= @review.title %> <%# прекрасно, экранируется, если нужно %>
```

Чтобы вставить что-либо дословно, используйте хелпер `raw` вместо вызова `html_safe`:

```erb
<%= raw @cms.current_template %> <%# вставляет @cms.current_template как есть %>
```

или используйте эквивалентную запись `<%==`:

```erb
<%== @cms.current_template %> <%# вставляет @cms.current_template как есть %>
```

Хелпер `raw` вызывает за вас хелпер `html_safe`:

```ruby
def raw(stringish)
  stringish.to_s.html_safe
end
```

NOTE: Определено в `active_support/core_ext/string/output_safety.rb`.

#### Преобразование

Как правило, за исключением, разве что, конкатенации, как объяснялось выше, любой метод, который может изменить строку, дает небезопасную строку. Это `downcase`, `gsub`, `strip`, `chomp`, `underscore` и т.д.

В случае встроенного преобразования, такого как `gsub!`, получатель сам становится небезопасным.

INFO: Бит безопасности всегда теряется, независимо от того, изменило ли что-то преобразование или нет.

#### Конверсия и принуждение

Вызов `to_s` на безопасной строке возвратит безопасную строку, но принуждение с помощью `to_str` возвратит небезопасную строку.

#### Копирование

Вызов `dup` или `clone` на безопасной строке создаст безопасные строки.

### `remove`

Метод `remove` уберет все совпадения с шаблоном:

```ruby
"Hello World".remove(/Hello /) # => "World"
```

Также имеется деструктивная версия `String#remove!`.

NOTE: Определено в `active_support/core_ext/string/filters.rb`.

### `squish`

Метод `squish` отсекает начальные и конечные пробелы, а также заменяет внутренние пробелы на один пробел:

```ruby
" \n  foo\n\r \t bar \n".squish # => "foo bar"
```

Также имеется разрушительная версия `String#squish!`.

Отметьте, что он обрабатывает и ASCII, и Unicode пробелы.

NOTE: Определено в `active_support/core_ext/string/filters.rb`.

### `truncate`

Метод `truncate` возвращает копию получателя, сокращенную после заданного `length`:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20)
# => "Oh dear! Oh dear!..."
```

Многоточие может быть настроено с помощью опции `:omission`:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20, omission: '&hellip;')
# => "Oh dear! Oh &hellip;"
```

Отметьте, что сокращение учитывает длину строки omission.

Передайте `:separator` для сокращения строки по естественным разрывам:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18)
# => "Oh dear! Oh dea..."
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: ' ')
# => "Oh dear! Oh..."
```

Опция `:separator` может быть регулярным выражением:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: /\s/)
# => "Oh dear! Oh..."
```

В вышеуказанных примерах "dear" обрезается сначала, а затем `:separator` предотвращает это.

NOTE: Определено в `active_support/core_ext/string/filters.rb`.

### (truncate_words) `truncate_words`

Метод `truncate_words` возвращает копию получателя, сокращенную после заданного количества слов:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4)
# => "Oh dear! Oh dear!..."
```

Многоточие может быть настроено с помощью опции `:omission`:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, omission: '&hellip;')
# => "Oh dear! Oh dear!&hellip;"
```

Передайте `:separator` для сокращения строки по естественным разрывам:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(3, separator: '!')
# => "Oh dear! Oh dear! I shall be late..."
```

Опция `:separator` может быть регулярным выражением:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, separator: /\s/)
# => "Oh dear! Oh dear!..."
```

NOTE: Определено в `active_support/core_ext/string/filters.rb`.

### `inquiry`

Метод `inquiry` конвертирует строку в объект `StringInquirer`, делая проверки равенства более красивыми.

```ruby
"production".inquiry.production? # => true
"active".inquiry.inactive?       # => false
```

### `starts_with?` и `ends_with?`

Active Support определяет псевдонимы `String#start_with?` и `String#end_with?` (в связи с особенностями английской морфологии, преобразует глаголы в форму 3-го лица):

```ruby
"foo".starts_with?("f") # => true
"foo".ends_with?("o")   # => true
```

NOTE: Определено в `active_support/core_ext/string/starts_ends_with.rb`.

### `strip_heredoc`

Метод `strip_heredoc` обрезает отступы в heredocs.

Для примера в

```ruby
if options[:usage]
  puts <<-USAGE.strip_heredoc
    This command does such and such.

    Supported options are:
      -h         This message
      ...
  USAGE
end
```

пользователь увидит используемое сообщение, выровненное по левому краю.

Технически это выглядит как выделение красной строки в отдельную строку и удаление всех впередиидущих пробелов.

NOTE: Определено в `active_support/core_ext/string/strip.rb`.

### `indent`

Устанавливает отступы строчкам получателя:

```ruby
<<EOS.indent(2)
def some_method
  some_code
end
EOS
# =>
  def some_method
    some_code
  end
```

Второй аргумент, `indent_string`, определяет, какой отступ строки использовать. По умолчанию `nil`, что сообщает методу самому догадаться на основе первой строчки с отступом, а если такой нет, то использовать пробел.

```ruby
"  foo".indent(2)        # => "    foo"
"foo\n\t\tbar".indent(2) # => "\t\tfoo\n\t\t\t\tbar"
"foo".indent(2, "\t")    # => "\t\tfoo"
```

Хотя `indent_string` это обычно один пробел или табуляция, он может быть любой строкой.

Третий аргумент, `indent_empty_lines`, это флажок, указывающий, должен ли быть отступ для пустых строчек. По умолчанию false.

```ruby
"foo\n\nbar".indent(2)            # => "  foo\n\n  bar"
"foo\n\nbar".indent(2, nil, true) # => "  foo\n  \n  bar"
```

Метод `indent!` добавляет отступ строке.

NOTE: Определено в `active_support/core_ext/string/indent.rb`.

### Доступ

#### `at(position)`

Возвращает символ строки на позиции `position`:

```ruby
"hello".at(0)  # => "h"
"hello".at(4)  # => "o"
"hello".at(-1) # => "o"
"hello".at(10) # => nil
```

NOTE: Определено в `active_support/core_ext/string/access.rb`.

#### `from(position)`

Возвращает подстроку строки, начинающуюся с позиции `position`:

```ruby
"hello".from(0)  # => "hello"
"hello".from(2)  # => "llo"
"hello".from(-2) # => "lo"
"hello".from(10) # => nil
```

NOTE: Определено в `active_support/core_ext/string/access.rb`.

#### `to(position)`

Возвращает подстроку строки с начала до позиции `position`:

```ruby
"hello".to(0)  # => "h"
"hello".to(2)  # => "hel"
"hello".to(-2) # => "hell"
"hello".to(10) # => "hello"
```

NOTE: Определено в `active_support/core_ext/string/access.rb`.

#### `first(limit = 1)`

Вызов `str.first(n)` эквивалентен `str.to(n-1)`, если `n` > 0, и возвращает пустую строку для `n` == 0.

NOTE: Определено в `active_support/core_ext/string/access.rb`.

#### `last(limit = 1)`

Вызов `str.last(n)` эквивалентен `str.from(-n)`, если `n` > 0, и возвращает пустую строку для `n` == 0.

NOTE: Определено в `active_support/core_ext/string/access.rb`.

### Изменения слов

#### `pluralize`

Метод `pluralize` возвращает множественное число получателя:

```ruby
"table".pluralize     # => "tables"
"ruby".pluralize      # => "rubies"
"equipment".pluralize # => "equipment"
```

Как показывает предыдущий пример, Active Support знает некоторые неправильные множественные числа и неисчисляемые существительные. Встроенные правила могут быть расширены в `config/initializers/inflections.rb`. Этот файл генерируется командой `rails` и имеет инструкции в комментариях.

`pluralize` также может принимать опциональный параметр `count`. Если `count == 1`, будет возвращена единственная форма. Для остальных значений `count` будет возвращена множественная форма:

```ruby
"dude".pluralize(0) # => "dudes"
"dude".pluralize(1) # => "dude"
"dude".pluralize(2) # => "dudes"
```

Active Record использует этот метод для вычисления дефолтного имени таблицы, соответствующей модели:

```ruby
# active_record/model_schema.rb
def undecorated_table_name(class_name = base_class.name)
  table_name = class_name.to_s.demodulize.underscore
  pluralize_table_names ? table_name.pluralize : table_name
end
```

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `singularize`

Противоположность `pluralize`:

```ruby
"tables".singularize    # => "table"
"rubies".singularize    # => "ruby"
"equipment".singularize # => "equipment"
```

Связи вычисляют имя соответствующего связанного дефолтного класса, используя этот метод:

```ruby
# active_record/reflection.rb
def derive_class_name
  class_name = name.to_s.camelize
  class_name = class_name.singularize if collection?
  class_name
end
```

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `camelize`

Метод `camelize` возвращает получателя в стиле CamelCase:

```ruby
"product".camelize    # => "Product"
"admin_user".camelize # => "AdminUser"
```

Как правило, об этом методе думают, как о преобразующем пути в классы Ruby или имена модулей, где слэши разделяют пространства имен:

```ruby
"backoffice/session".camelize # => "Backoffice::Session"
```

Например, Action Pack использует этот метод для загрузки класса, предоставляющего определенное хранилище сессии:

```ruby
# action_controller/metal/session_management.rb
def session_store=(store)
  @@session_store = store.is_a?(Symbol) ?
    ActionDispatch::Session.const_get(store.to_s.camelize) :
    store
end
```

`camelize` принимает опциональный аргумент, он может быть `:upper` (по умолчанию) или `:lower`. В последнем случае первая буква становится строчной:

```ruby
"visual_effect".camelize(:lower) # => "visualEffect"
```

Это может быть удобно для вычисления имен методов на языке, который следует такому соглашению, например JavaScript.

INFO: Как правило, можно рассматривать `camelize` как противоположность `underscore`, хотя бывают случаи, когда это не так: `"SSLError".underscore.camelize` возвращает `"SslError"`. Для поддержки подобных случаев, Active Support позволяет указывать акронимы в `config/initializers/inflections.rb`

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'SSL'
end

"SSLError".underscore.camelize # => "SSLError"
```

`camelize` имеет псевдоним `camelcase`.

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `underscore`

Метод `underscore`, наоборот, от CamelCase к путям:

```ruby
"Product".underscore   # => "product"
"AdminUser".underscore # => "admin_user"
```

Также преобразует "::" обратно в "/":

```ruby
"Backoffice::Session".underscore # => "backoffice/session"
```

и понимает строки, начинающиеся с прописной буквы:

```ruby
"visualEffect".underscore # => "visual_effect"
```

хотя `underscore` не принимает никакие аргументы.

Автозагрузка классов и модулей Rails использует `underscore` для вывода относительного пути без расширения файла, определяющего заданную отсутствующую константу:

```ruby
# active_support/dependencies.rb
def load_missing_constant(from_mod, const_name)
  ...
  qualified_name = qualified_name_for from_mod, const_name
  path_suffix = qualified_name.underscore
  ...
end
```

INFO: Как правило, рассматривайте `underscore` как противоположность `camelize`, хотя бывают случаи, когда это не так. Например, `"SSLError".underscore.camelize` возвратит `"SslError"`.

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `titleize`

Метод `titleize` озаглавит слова в получателе:

```ruby
"alice in wonderland".titleize # => "Alice In Wonderland"
"fermat's enigma".titleize     # => "Fermat's Enigma"
```

`titleize` имеет псевдоним `titlecase`.

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `dasherize`

Метод `dasherize` заменяет подчеркивания в получателе дефисами:

```ruby
"name".dasherize         # => "name"
"contact_data".dasherize # => "contact-data"
```

Сериализатор XML моделей использует этот метод для форматирования имен узлов:

```ruby
# active_model/serializers/xml.rb
def reformat_name(name)
  name = name.camelize if camelize?
  dasherize? ? name.dasherize : name
end
```

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `demodulize`

Для заданной строки с ограниченным именем константы, `demodulize` возвращает само имя константы, то есть правой части этого:

```ruby
"Product".demodulize                        # => "Product"
"Backoffice::UsersController".demodulize    # => "UsersController"
"Admin::Hotel::ReservationUtils".demodulize # => "ReservationUtils"
"::Inflections".demodulize                  # => "Inflections"
"".demodulize                               # => ""

```

Active Record, к примеру, использует этот метод для вычисления имени столбца кэширования счетчика:

```ruby
# active_record/reflection.rb
def counter_cache_column
  if options[:counter_cache] == true
    "#{active_record.name.demodulize.underscore.pluralize}_count"
  elsif options[:counter_cache]
    options[:counter_cache]
  end
end
```

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `deconstantize`

У заданной строки с ограниченным выражением ссылки на константу `deconstantize` убирает самый правый сегмент, в основном оставляя имя контейнера константы:

```ruby
"Product".deconstantize                        # => ""
"Backoffice::UsersController".deconstantize    # => "Backoffice"
"Admin::Hotel::ReservationUtils".deconstantize # => "Admin::Hotel"
```

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `parameterize`

Метод `parameterize` нормализует получателя способом, который может использоваться в красивых URL.

```ruby
"John Smith".parameterize # => "john-smith"
"Kurt Gödel".parameterize # => "kurt-godel"
```

Чтобы сохранить регистр строки, установите аргумент `preserve_case` в true. По умолчанию `preserve_case` установлен в false.

```ruby
"John Smith".parameterize(preserve_case: true) # => "John-Smith"
"Kurt Gödel".parameterize(preserve_case: true) # => "Kurt-Godel"
```

Чтобы использовать произвольный разделитель, переопределите аргумент `separator`.

```ruby
"John Smith".parameterize(separator: "_") # => "john\_smith"
"Kurt Gödel".parameterize(separator: "_") # => "kurt\_godel"
```

Фактически результирующая строка оборачивается в экземпляр `ActiveSupport::Multibyte::Chars`.

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `tableize`

Метод `tableize` - это `underscore` вместе с `pluralize`.

```ruby
"Person".tableize      # => "people"
"Invoice".tableize     # => "invoices"
"InvoiceLine".tableize # => "invoice_lines"
```

Как правило, `tableize` возвращает имя таблицы, соответствующей заданной модели для простых случаев. На самом деле фактическая реализация в Active Record не является прямым `tableize`, так как он также демодулизирует имя класса и проверяет несколько опций, которые могут повлиять на возвращаемую строку.

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `classify`

Метод `classify` является противоположностью `tableize`. Он выдает имя класса, соответствующего имени таблицы:

```ruby
"people".classify        # => "Person"
"invoices".classify      # => "Invoice"
"invoice_lines".classify # => "InvoiceLine"
```

Метод понимает ограниченные имена таблиц:

```ruby
"highrise_production.companies".classify # => "Company"
```

Отметьте, что `classify` возвращает имя класса как строку. Можете получить фактический объект класса, вызвав `constantize` на ней, как объяснено далее.

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `constantize`

Метод `constantize` решает выражение, ссылающееся на константу, в его получателе:

```ruby
"Integer".constantize # => Integer

module M
  X = 1
end
"M::X".constantize # => 1
```

Если строка вычисляет неизвестную константу, или ее содержимое даже не является валидным именем константы, `constantize` вызывает `NameError`.

Анализ имени константы с помощью `constantize` начинается всегда с верхнего уровня `Object`, даже если нет предшествующих "::".

```ruby
X = :in_Object
module M
  X = :in_M

  X                 # => :in_M
  "::X".constantize # => :in_Object
  "X".constantize   # => :in_Object (!)
end
```

Таким образом, в общем случае это не эквивалентно тому, что Ruby сделал бы в том же месте, когда вычислял настоящую константу.

Тестовые случаи рассыльщика получают тестируемый рассыльщик из имени класса теста, используя `constantize`:

```ruby
# action_mailer/test_case.rb
def determine_default_mailer(name)
  name.sub(/Test$/, '').constantize
rescue NameError => e
  raise NonInferrableMailerError.new(name)
end
```

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `humanize`

Метод `humanize` настраивает имя атрибута для отображения конечным пользователям.

А в частности выполняет эти преобразования:

  * Применяет правила словоизменения к аргументу.
  * Удаляет любые предшествующие знаки подчеркивания.
  * Убирает суффикс "\_id".
  * Заменяет знаки подчеркивания пробелами.
  * Переводит в нижний регистр все слова, кроме акронимов.
  * Озаглавливает первое слово.

Озаглавливание первого слова может быть выключено с помощью установки опции `:capitalize` в false (по умолчанию true).

```ruby
"name".humanize                         # => "Name"
"author_id".humanize                    # => "Author"
"author_id".humanize(capitalize: false) # => "author"
"comments_count".humanize               # => "Comments count"
"_id".humanize                          # => "Id"
```

Если "SSL" был определен как акроним:

```ruby
'ssl_error'.humanize # => "SSL error"
```

Метод хелпера `full_messages` использует `humanize` как резервный способ для включения имен атрибутов:

```ruby
def full_messages
  map { |attribute, message| full_message(attribute, message) }
end

def full_message
  attr_name = attribute.to_s.tr('.', '_').humanize
  attr_name = @base.class.human_attribute_name(attribute, default: attr_name)
end
```

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `foreign_key`

Метод `foreign_key` дает имя столбца внешнего ключа из имени класса. Чтобы это сделать он демодулизирует, подчеркивает и добавляет "\_id":

```ruby
"User".foreign_key           # => "user_id"
"InvoiceLine".foreign_key    # => "invoice_line_id"
"Admin::Session".foreign_key # => "session_id"
```

Передайте аргумент false, если не хотите подчеркивание в "\_id":

```ruby
"User".foreign_key(false) # => "userid"
```

Связи используют этот метод для вывода внешних ключей, например `has_one` и `has_many` делают так:

```ruby
# active_record/associations.rb
foreign_key = options[:foreign_key] || reflection.active_record.name.foreign_key
```

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

### Конвертирование

#### `to_date`, `to_time`, `to_datetime`

Методы `to_date`, `to_time` и `to_datetime` - в основном удобные обертки для `Date._parse`:

```ruby
"2010-07-27".to_date              # => Tue, 27 Jul 2010
"2010-07-27 23:37:00".to_time     # => 2010-07-27 23:37:00 +0200
"2010-07-27 23:37:00".to_datetime # => Tue, 27 Jul 2010 23:37:00 +0000
```

`to_time` получает опциональный аргумент `:utc` или `:local`, для указания, время какой временной зоны необходимо:

```ruby
"2010-07-27 23:42:00".to_time(:utc)   # => 2010-07-27 23:42:00 UTC
"2010-07-27 23:42:00".to_time(:local) # => 2010-07-27 23:42:00 +0200
```

По умолчанию `:local`.

Пожалуйста, обратитесь к документации по `Date._parse` для получения дополнительной информации.

INFO: Все три возвратят `nil` для пустых получателей.

NOTE: Определено в `active_support/core_ext/string/conversions.rb`.

Расширения для `Numeric`
------------------------

### Байты

Все числа отвечают на эти методы:

```ruby
bytes
kilobytes
megabytes
gigabytes
terabytes
petabytes
exabytes
```

Они возвращают соответствующее количество байтов, используя конвертирующий множитель 1024:

```ruby
2.kilobytes   # => 2048
3.megabytes   # => 3145728
3.5.gigabytes # => 3758096384
-4.exabytes   # => -4611686018427387904
```

Форма в единственном числе является псевдонимом, поэтому можно написать так:

```ruby
1.megabyte # => 1048576
```

NOTE: Определено в `active_support/core_ext/numeric/bytes.rb`.

### Время

Включает возможность вычисления и объявления времени, подобно `45.minutes + 2.hours + 4.weeks`.

Эти методы используют Time#advance для точного вычисления дат с использованием from_now, ago, и т. д., а также для сложения или вычитания их результата из объекта Time. Например:

```ruby
# эквивалент для Time.current.advance(months: 1)
1.month.from_now

# эквивалент для Time.current.advance(weeks: 2)
2.weeks.from_now

# эквивалент для Time.current.advance(months: 4, weeks: 5)
(4.months + 5.weeks).from_now
```

WARNING. Для других длительностей, обратитесь, пожалуйста, к временному расширению для `Integer`.

NOTE: Определено в `active_support/core_ext/numeric/time.rb`

### Форматирование

Включает форматирование чисел различными способами.

Преобразует число в строковое представление телефонного номера:

```ruby
5551234.to_s(:phone)
# => 555-1234
1235551234.to_s(:phone)
# => 123-555-1234
1235551234.to_s(:phone, area_code: true)
# => (123) 555-1234
1235551234.to_s(:phone, delimiter: " ")
# => 123 555 1234
1235551234.to_s(:phone, area_code: true, extension: 555)
# => (123) 555-1234 x 555
1235551234.to_s(:phone, country_code: 1)
# => +1-123-555-1234
```

Преобразует число в строковое представление валюты:

```ruby
1234567890.50.to_s(:currency)                 # => $1,234,567,890.50
1234567890.506.to_s(:currency)                # => $1,234,567,890.51
1234567890.506.to_s(:currency, precision: 3)  # => $1,234,567,890.506
```

Преобразует число в строковое представление процентов:

```ruby
100.to_s(:percentage)
# => 100.000%
100.to_s(:percentage, precision: 0)
# => 100%
1000.to_s(:percentage, delimiter: '.', separator: ',')
# => 1.000,000%
302.24398923423.to_s(:percentage, precision: 5)
# => 302.24399%
```

Преобразует число в строковое представление числа с разделенными разрядами:

```ruby
12345678.to_s(:delimited)                     # => 12,345,678
12345678.05.to_s(:delimited)                  # => 12,345,678.05
12345678.to_s(:delimited, delimiter: ".")     # => 12.345.678
12345678.to_s(:delimited, delimiter: ",")     # => 12,345,678
12345678.05.to_s(:delimited, separator: " ")  # => 12,345,678 05
```

Преобразует число в строковое представление числа, округленного с определенной точностью:

```ruby
111.2345.to_s(:rounded)                     # => 111.235
111.2345.to_s(:rounded, precision: 2)       # => 111.23
13.to_s(:rounded, precision: 5)             # => 13.00000
389.32314.to_s(:rounded, precision: 0)      # => 389
111.2345.to_s(:rounded, significant: true)  # => 111
```

Преобразует число в строковое представление с удобочитаемым количеством байт:

```ruby
123.to_s(:human_size)                  # => 123 Bytes
1234.to_s(:human_size)                 # => 1.21 KB
12345.to_s(:human_size)                # => 12.1 KB
1234567.to_s(:human_size)              # => 1.18 MB
1234567890.to_s(:human_size)           # => 1.15 GB
1234567890123.to_s(:human_size)        # => 1.12 TB
1234567890123456.to_s(:human_size)     # => 1.1 PB
1234567890123456789.to_s(:human_size)  # => 1.07 EB
```

Преобразует число в строковое представление с удобочитаемым числом слов:

```ruby
123.to_s(:human)               # => "123"
1234.to_s(:human)              # => "1.23 Thousand"
12345.to_s(:human)             # => "12.3 Thousand"
1234567.to_s(:human)           # => "1.23 Million"
1234567890.to_s(:human)        # => "1.23 Billion"
1234567890123.to_s(:human)     # => "1.23 Trillion"
1234567890123456.to_s(:human)  # => "1.23 Quadrillion"
```

NOTE: Определено в `active_support/core_ext/numeric/conversions.rb`.

Расширения для `Integer`
------------------------

### `multiple_of?`

Метод `multiple_of?` проверяет, является ли целое число множителем аргумента:

```ruby
2.multiple_of?(1) # => true
1.multiple_of?(2) # => false
```

NOTE: Определено в `active_support/core_ext/integer/multiple.rb`.

### `ordinal`

Метод `ordinal` возвращает суффикс порядковой строки, соответствующей полученному целому числу:

```ruby
1.ordinal    # => "st"
2.ordinal    # => "nd"
53.ordinal   # => "rd"
2009.ordinal # => "th"
-21.ordinal  # => "st"
-134.ordinal # => "th"
```

NOTE: Определено в `active_support/core_ext/integer/inflections.rb`.

### `ordinalize`

Метод `ordinalize` возвращает порядковую строку, соответствующую полученному целому числу. Для сравнения отметьте, что метод `ordinal` возвращает **только** строковый суффикс.

```ruby
1.ordinalize    # => "1st"
2.ordinalize    # => "2nd"
53.ordinalize   # => "53rd"
2009.ordinalize # => "2009th"
-21.ordinalize  # => "-21st"
-134.ordinalize # => "-134th"
```

NOTE: Определено в `active_support/core_ext/integer/inflections.rb`.

### Время

Включает возможность вычисления и объявления времени, подобно `4.months + 5.years`.

Эти методы используют Time#advance для точного вычисления дат с использованием from_now, ago, и т. д., а также для сложения или вычитания их результата из объекта Time. Например:

```ruby
# эквивалент для Time.current.advance(months: 1)
1.month.from_now

# эквивалент для Time.current.advance(years: 2)
2.years.from_now

# эквивалент для Time.current.advance(months: 4, years: 5)
(4.months + 5.years).from_now
```

WARNING. Для других длительностей, обратитесь, пожалуйста, к временному расширению для `Numeric`.

NOTE: Определено в `active_support/core_ext/integer/time.rb`.

Расширения для `BigDecimal`
---------------------------

### `to_s`

Метод `to_s` предоставляет спецификатор по умолчанию для "F". Это означает, что простой вызов `to_s` приведет к представлению с плавающей запятой вместо инженерной нотации:

```ruby
BigDecimal(5.00, 6).to_s       # => "5.0"
```

а также поддерживаются эти спецификаторы символа:

```ruby
BigDecimal(5.00, 6).to_s(:db)  # => "5.0"
```

Инженерная нотация все еще поддерживается:

```ruby
BigDecimal(5.00, 6).to_s("e")  # => "0.5E1"
```

Расширения для `Enumerable`
---------------------------

### `sum`

Метод `sum` складывает элементы перечисления:

```ruby
[1, 2, 3].sum # => 6
(1..100).sum  # => 5050
```

Сложение применяется только к элементам, откликающимся на `+`:

```ruby
[[1, 2], [2, 3], [3, 4]].sum    # => [1, 2, 2, 3, 3, 4]
%w(foo bar baz).sum             # => "foobarbaz"
{a: 1, b: 2, c: 3}.sum          # => [:b, 2, :c, 3, :a, 1]
```

Сумма пустой коллекции равна нулю по умолчанию, но это может быть настроено:

```ruby
[].sum    # => 0
[].sum(1) # => 1
```

Если задан блок, `sum` становится итератором, вкладывающим элементы коллекции и суммирующим возвращаемые значения:

```ruby
(1..5).sum {|n| n * 2 } # => 30
[2, 4, 6, 8, 10].sum    # => 30
```

Сумма пустого получателя также может быть настроена в такой форме:

```ruby
[].sum(1) {|n| n**3} # => 1
```

NOTE: Определено в `active_support/core_ext/enumerable.rb`.

### `index_by`

Метод `index_by` генерирует хэш с элементами перечисления, индексированными по некоторому ключу.

Он перебирает коллекцию и передает каждый элемент в блок. Значение, возвращенное блоком, будет ключом для элемента:

```ruby
invoices.index_by(&:number)
# => {'2009-032' => <Invoice ...>, '2009-008' => <Invoice ...>, ...}
```

WARNING. Ключи, как правило, должны быть уникальными. Если блок возвратит одно и то же значение для нескольких элементов, для этого ключа не будет построена коллекция. А значение получит последний элемент.

NOTE: Определено в `active_support/core_ext/enumerable.rb`.

### `many?`

Метод `many?` это сокращение для `collection.size > 1`:

```erb
<% if pages.many? %>
  <%= pagination_links %>
<% end %>
```

Если задан опциональный блок, `many?` учитывает только те элементы, которые возвращают true:

```ruby
@see_more = videos.many? {|video| video.category == params[:category]}
```

NOTE: Определено в `active_support/core_ext/enumerable.rb`.

### `exclude?`

Предикат `exclude?` проверяет, является ли заданный объект **не** принадлежащим коллекции. Это противоположность встроенного `include?`:

```ruby
to_visit << node if visited.exclude?(node)
```

NOTE: Определено в `active_support/core_ext/enumerable.rb`.

### `without`

Метод `without` возвращает копию перечисления без указанных элементов:

```ruby
["David", "Rafael", "Aaron", "Todd"].without("Aaron", "Todd") # => ["David", "Rafael"]
```

NOTE: Определено в `active_support/core_ext/enumerable.rb`.

### `pluck`

Метод `pluck` возвращает массив на основе заданного ключа:

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pluck(:name) # => ["David", "Rafael", "Aaron"]
```

NOTE: Определено в `active_support/core_ext/enumerable.rb`.

Расширения для `Array`
----------------------

### Доступ

Active Support расширяет API массивов для облегчения нескольких способов доступа к ним. Например, `to` возвращает подмассив элементов от первого до переданного индекса:

```ruby
%w(a b c d).to(2) # => ["a", "b", "c"]
[].to(7)          # => []
```

По аналогии, `from` возвращает хвост массива, количество элементов которого равно переданному индексу. Если индекс больше длины массива, возвращается пустой массив.

```ruby
%w(a b c d).from(2)  # => ["c", "d"]
%w(a b c d).from(10) # => []
[].from(0)           # => []
```

Методы `second`, `third`, `fourth` и `fifth` возвращают соответствующие элементы, так же как `second_to_last` и `third_to_last` (`first` и `last` являются встроенными). Благодаря [социальной мудрости и всеобщей позитивной конструктивности](https://ru.wikipedia.org/wiki/Ответ_на_главный_вопрос_жизни,_вселенной_и_всего_такого), `forty_two` также доступен.

```ruby
%w(a b c d).third # => "c"
%w(a b c d).fifth # => nil
```

NOTE: Определено в `active_support/core_ext/array/access.rb`.

### Добавление элементов

#### `prepend`

Этот метод - псевдоним `Array#unshift`.

```ruby
%w(a b c d).prepend('e')  # => ["e", "a", "b", "c", "d"]
[].prepend(10)            # => [10]
```

NOTE: Определено в `active_support/core_ext/array/prepend_and_append.rb`.

#### `append`

Этот метод - псевдоним `Array#<<`.

```ruby
%w(a b c d).append('e')  # => ["a", "b", "c", "d", "e"]
[].append([1,2])         # => [[1, 2]]
```

NOTE: Определено в `active_support/core_ext/array/prepend_and_append.rb`.

### Извлечение опций

Когда последний аргумент в вызове метода является хэшем, за исключением, пожалуй, аргумента `&block`, Ruby позволяет опустить скобки:

```ruby
User.exists?(email: params[:email])
```

Этот синтаксический сахар часто используется в Rails для избежания позиционных аргументов там, где их не слишком много, предлагая вместо них интерфейсы, эмулирующие именованные параметры. В частности, очень характерно использовать такой хэш для опций.

Если метод ожидает различное количество аргументов и использует `*` в своем объявлении, однако хэш опций завершает их и является последним элементом массива аргументов, тогда тип теряет свою роль.

В этих случаях можно задать хэшу опций отличительную трактовку с помощью `extract_options!`. Метод проверяет тип последнего элемента массива. Если это хэш, он вырезает его и возвращает, в противном случае возвращает пустой хэш.

Давайте рассмотрим пример определения макроса контроллера `caches_action`:

```ruby
def caches_action(*actions)
  return unless cache_configured?
  options = actions.extract_options!
  ...
end
```

Этот метод получает произвольное число имен экшнов и опциональный хэш опций как последний аргумент. Вызвав `extract_options!`, получаем хэш опций и убираем его из `actions` простым и явным способом.

NOTE: Определено в `active_support/core_ext/array/extract_options.rb`.

### Конвертирование

#### `to_sentence`

Метод `to_sentence` превращает массив в строку, содержащую предложение, в котором перечисляются элементы массива:

```ruby
%w().to_sentence                # => ""
%w(Earth).to_sentence           # => "Earth"
%w(Earth Wind).to_sentence      # => "Earth and Wind"
%w(Earth Wind Fire).to_sentence # => "Earth, Wind, and Fire"
```

Этот метод принимает три опции:

* `:two_words_connector`: Что используется для массивов с длиной 2. По умолчанию " and ".
* `:words_connector`: Что используется для соединения элементов массивов с 3 и более элементами, кроме последних двух. По умолчанию ", ".
* `:last_word_connector`: Что используется для соединения последних элементов массива из 3 и более элементов. По умолчанию ", and ".

По умолчанию эти опции могут быть локализованы, их ключи следующие:

| Опция                  | Ключ I18n                           |
| ---------------------- | ----------------------------------- |
| `:two_words_connector` | `support.array.two_words_connector` |
| `:words_connector`     | `support.array.words_connector`     |
| `:last_word_connector` | `support.array.last_word_connector` |

NOTE: Определено в `active_support/core_ext/array/conversions.rb`.

#### `to_formatted_s`

Метод `to_formatted_s` по умолчанию работает как `to_s`.

Однако, если массив содержит элементы, откликающиеся на `id`, как аргумент можно передать символ `:db`. Это обычно используется с коллекциями объектов Active Record. Возвращаемые строки следующие:

```ruby
[].to_formatted_s(:db)            # => "null"
[user].to_formatted_s(:db)        # => "8456"
invoice.lines.to_formatted_s(:db) # => "23,567,556,12"
```

Целые числа в примере выше предполагается, что приходят от соответствующих вызовов `id`.

NOTE: Определено в `active_support/core_ext/array/conversions.rb`.

#### `to_xml`

Метод `to_xml` возвращает строку, содержащую представление XML его получателя:

```ruby
Contributor.limit(2).order(:rank).to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors type="array">
#   <contributor>
#     <id type="integer">4356</id>
#     <name>Jeremy Kemper</name>
#     <rank type="integer">1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id type="integer">4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank type="integer">2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

Чтобы это сделать, он посылает `to_xml` к каждому элементу за раз и собирает результаты в корневом узле. Все элементы должны откликаться на `to_xml`, иначе будет вызвано исключение.

По умолчанию имя корневого элемента - это подчеркнутое и `dasherize` имя класса первого элемента во множественном числе, при условии что остальные элементы принадлежат этому типу (проверяется с помощью `is_a?`) и они не являются хэшами. В примере выше это "contributors".

Если есть какой-либо элемент, не принадлежащий типу первого, корневой узел становится "objects":

```ruby
[Contributor.first, Commit.first].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <id type="integer">4583</id>
#     <name>Aaron Batalion</name>
#     <rank type="integer">53</rank>
#     <url-id>aaron-batalion</url-id>
#   </object>
#   <object>
#     <author>Joshua Peek</author>
#     <authored-timestamp type="datetime">2009-09-02T16:44:36Z</authored-timestamp>
#     <branch>origin/master</branch>
#     <committed-timestamp type="datetime">2009-09-02T16:44:36Z</committed-timestamp>
#     <committer>Joshua Peek</committer>
#     <git-show nil="true"></git-show>
#     <id type="integer">190316</id>
#     <imported-from-svn type="boolean">false</imported-from-svn>
#     <message>Kill AMo observing wrap_with_notifications since ARes was only using it</message>
#     <sha1>723a47bfb3708f968821bc969a9a3fc873a3ed58</sha1>
#   </object>
# </objects>
```

Если получатель является массивом хэшей, корневой элемент по умолчанию также "objects":

```ruby
[{a: 1, b: 2}, {c: 3}].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <b type="integer">2</b>
#     <a type="integer">1</a>
#   </object>
#   <object>
#     <c type="integer">3</c>
#   </object>
# </objects>
```

WARNING. Если коллекция пустая, корневой элемент по умолчанию "nil-classes". Пример для понимания, корневой элемент вышеописанного списка вкладчиков будет не "contributors", если коллекция пустая, а "nil-classes". Можно использовать опцию `:root` для обеспечения согласованного корневого элемента.

Имя дочерних узлов по умолчанию является именем корневого узла в единственном числе. В вышеприведенных примерах мы видели "contributor" и "object". Опция `:children` позволяет установить эти имена узлов.

По умолчанию билдер XML является свежим экземпляром `Builder::XmlMarkup`. Можно сконфигурировать свой собственный билдер через опцию `:builder`. Метод также принимает опции, такие как `:dasherize` и ему подобные, они перенаправляются в билдер:

```ruby
Contributor.limit(2).order(:rank).to_xml(skip_types: true)
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors>
#   <contributor>
#     <id>4356</id>
#     <name>Jeremy Kemper</name>
#     <rank>1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id>4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank>2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

NOTE: Определено в `active_support/core_ext/array/conversions.rb`.

### Оборачивание

Метод `Array.wrap` оборачивает свои аргументы в массив, кроме случая когда это уже массив (или массивоподобные).

А именно:

* Если аргумент `nil`, возвращается пустой массив.
* В противном случае, если аргумент откликается на `to_ary`, он вызывается, и, если значение `to_ary` не `nil`, оно возвращается.
* В противном случае, возвращается массив с аргументом в качестве его первого элемента.

```ruby
Array.wrap(nil)       # => []
Array.wrap([1, 2, 3]) # => [1, 2, 3]
Array.wrap(0)         # => [0]
```

Этот метод похож на `Kernel#Array`, но с некоторыми отличиями:

* Если аргумент откликается на `to_ary`, метод вызывается. `Kernel#Array` начинает пробовать `to_a`, если вернувшееся значение `nil`, а `Arraw.wrap` сразу возвращает массив с аргументом в качестве единственного элемента.
* Если возвращаемое значение от `to_ary` и не `nil`, и не объект `Array`, то `Kernel#Array` вызывает исключение, в то время как `Array.wrap` нет, он просто возвращает значение.
* Он не вызывает `to_a` на аргументе, если аргумент не откликается на `to_ary`, а возвращает массив с аргументом в качестве своего единственного элемента.

Последний пункт особенно заметен для некоторых перечислений:

```ruby
Array.wrap(foo: :bar) # => [{:foo=>:bar}]
Array(foo: :bar)      # => [[:foo, :bar]]
```

Также имеется связанная идиома, использующая оператор расплющивания:

```ruby
[*object]
```

который в Ruby 1.8 возвращает `[nil]` для `nil`, а в противном случае вызывает `Array(object)`. (Точное поведение в 1.9 пока непонятно)

Таким образом, в этом случае поведение различается для `nil`, а описанные выше различия с `Kernel#Array` применяются к остальным `object`.

NOTE: Определено в `active_support/core_ext/array/wrap.rb`.

### Дублирование

Метод `Array#deep_dup` дублирует себя и все объекты внутри рекурсивно с помощью метода Active Support `Object#deep_dup`. Он работает так же, как `Array#map`, посылая метод `deep_dup` для каждого объекта внутри.

```ruby
array = [1, [2, 3]]
dup = array.deep_dup
dup[1][2] = 4
array[1][2] == nil   # => true
```

NOTE: Определено в `active_support/core_ext/object/deep_dup.rb`.

### Группировка

#### `in_groups_of(number, fill_with = nil)`

Метод `in_groups_of` разделяет массив на последовательные группы определенного размера. Он возвращает массив с группами:

```ruby
[1, 2, 3].in_groups_of(2) # => [[1, 2], [3, nil]]
```

или выдает их по очереди, если передается блок:

```erb
<% sample.in_groups_of(3) do |a, b, c| %>
  <tr>
    <td><%= a %></td>
    <td><%= b %></td>
    <td><%= c %></td>
  </tr>
<% end %>
```

Первый пример показывает, как `in_groups_of` заполняет последнюю группу столькими элементами `nil`, сколько нужно, чтобы получить требуемый размер. Можно изменить это набивочное значение используя второй опциональный аргумент:

```ruby
[1, 2, 3].in_groups_of(2, 0) # => [[1, 2], [3, 0]]
```

Наконец, можно сказать методу не заполнять последнюю группу, передав `false`:

```ruby
[1, 2, 3].in_groups_of(2, false) # => [[1, 2], [3]]
```

Как следствие `false` не может использоваться как набивочное значение.

NOTE: Определено в `active_support/core_ext/array/grouping.rb`.

#### `in_groups(number, fill_with = nil)`

Метод `in_groups` разделяет массив на определенное количество групп. Метод возвращает массив с группами:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3)
# => [["1", "2", "3"], ["4", "5", nil], ["6", "7", nil]]
```

или выдает их по очереди, если передается блок:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3) {|group| p group}
["1", "2", "3"]
["4", "5", nil]
["6", "7", nil]
```

Примеры выше показывают, что `in_groups` заполняет некоторые группы с помощью заключительного элемента `nil`, если необходимо. Группа может получить не более одного из этих дополнительных элементов, самый правый, если таковой имеется. И группы, получившие его, будут всегда последние.

Можно изменить это набивочное значение, используя второй опциональный аргумент:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, "0")
# => [["1", "2", "3"], ["4", "5", "0"], ["6", "7", "0"]]
```

Также можно сказать методу не заполнять меньшие группы, передав `false`:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, false)
# => [["1", "2", "3"], ["4", "5"], ["6", "7"]]
```

Как следствие, `false` не может быть набивочным значением.

NOTE: Определено в `active_support/core_ext/array/grouping.rb`.

#### `split(value = nil)`

Метод `split` разделяет массив разделителем и возвращает получившиеся куски.

Если передан блок, разделителями будут те элементы массива, для которых блок возвращает true:

```ruby
(-5..5).to_a.split { |i| i.multiple_of?(4) }
# => [[-5], [-3, -2, -1], [1, 2, 3], [5]]
```

В противном случае, значение, полученное как аргумент, которое по умолчанию является `nil`, будет разделителем:

```ruby
[0, 1, -5, 1, 1, "foo", "bar"].split(1)
# => [[0], [-5], [], ["foo", "bar"]]
```

TIP: Отметьте, в предыдущем примере, что последовательные разделители приводят к пустым массивам.

NOTE: Определено в `active_support/core_ext/array/grouping.rb`.

Расширения для `Hash`
---------------------

### Конверсия

#### `to_xml`

Метод `to_xml` возвращает строку, содержащую представление XML его получателя:

```ruby
{"foo" => 1, "bar" => 2}.to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <hash>
#   <foo type="integer">1</foo>
#   <bar type="integer">2</bar>
# </hash>
```

Чтобы это сделать, метод в цикле проходит пары и создает узлы, зависимые от _value_. Для заданной пары `key`, `value`:

* Если `value` - хэш, происходит рекурсивный вызов с `key` как `:root`.
* Если `value` - массив, происходит рекурсивный вызов с `key` как `:root`, и `key` в единственном числе как `:children`.
* Если `value` - вызываемый объект, он должен ожидать один или два аргумента. В зависимости от ситуации, вызываемый объект вызывается с помощью хэша `options` в качестве первого аргумента с `key` как `:root`, и `key` в единственном числе в качестве второго аргумента. Возвращенное значение становится новым узлом.
* Если `value` откликается на `to_xml`, метод вызывается с `key` как `:root`.
* В иных случаях, узел с `key` в качестве тега создается со строковым представлением `value` в качестве текстового узла. Если `value` является `nil`, добавляется атрибут "nil", установленный в "true". Кроме случаев, когда существует опция `:skip_types` со значением true, добавляется атрибут "type", соответствующий следующему преобразованию:

```ruby
XML_TYPE_NAMES = {
  "Symbol"     => "symbol",
  "Integer"    => "integer",
  "BigDecimal" => "decimal",
  "Float"      => "float",
  "TrueClass"  => "boolean",
  "FalseClass" => "boolean",
  "Date"       => "date",
  "DateTime"   => "datetime",
  "Time"       => "datetime"
}
```

По умолчанию корневой узел является "hash", но это настраивается с помощью опции `:root`.

По умолчанию билдер XML является новым экземпляром `Builder::XmlMarkup`. Можно настроить свой собственный билдер с помощью опции `:builder`. Метод также принимает опции, такие как `:dasherize` и ему подобные, они направляются в билдер.

NOTE: Определено в `active_support/core_ext/hash/conversions.rb`.

### Объединение

В Ruby имеется встроенный метод `Hash#merge`, который позволяет объединять два хэша:

```ruby
{a: 1, b: 1}.merge(a: 0, c: 2)
# => {:a=>0, :b=>1, :c=>2}
```

Active Support определяет еще несколько способов объединения хэшей, которые могут быть полезными.

#### `reverse_merge` и `reverse_merge!`

В случае коллизии, в `merge` остается ключ в хэше аргумента. Можно компактно предоставить хэш-опцию со значениями по умолчанию с помощью такой идиомы:

```ruby
options = {length: 30, omission: "..."}.merge(options)
```

Active Support определяет `reverse_merge` в случае, если нужна альтернативная запись:

```ruby
options = options.reverse_merge(length: 30, omission: "...")
```

И вариант с восклицательным знаком `reverse_merge!`, который выполняет объединение, модифицируя на месте:

```ruby
options.reverse_merge!(length: 30, omission: "...")
```

WARNING. Обратите внимание, что `reverse_merge!` может изменить хэш в вызывающем методе, что может как быть, так и не быть хорошей идеей.

NOTE: Определено в `active_support/core_ext/hash/reverse_merge.rb`.

#### `reverse_update`

Метод `reverse_update` это псевдоним для `reverse_merge!`, описанного выше.

WARNING. Отметьте, что у `reverse_update` нет варианта с восклицательным знаком.

NOTE: Определено в `active_support/core_ext/hash/reverse_merge.rb`.

#### `deep_merge` и `deep_merge!`

Как можно было видеть в предыдущем примере, если ключ обнаруживается в обоих хэшах, выбирается значение первого из аргументов.

Active Support определяет `Hash#deep_merge`. В углубленном объединении, если один и тот же ключ обнаруживается в обоих хэшах, и их значения также хэши, то в результирующем хэше будет _объединение_ их значений.

```ruby
{a: {b: 1}}.deep_merge(a: {c: 2})
# => {:a=>{:b=>1, :c=>2}}
```

Метод `deep_merge!` выполняет углубленное объединение, модифицируя на месте:

NOTE: Определено в `active_support/core_ext/hash/deep_merge.rb`.

### Глубокое дублирование

Метод `Hash#deep_dup` дублирует себя, а также все ключи и значения внутри, рекурсивно с помощью метода Active Support `Object#deep_dup`. Он работает так же, как `Enumerator#each_with_object`, посылая метод `deep_dup` в каждую пару внутри.

```ruby
hash = { a: 1, b: { c: 2, d: [3, 4] } }

dup = hash.deep_dup
dup[:b][:e] = 5
dup[:b][:d] << 5

hash[:b][:e] == nil      # => true
hash[:b][:d] == [3, 4]   # => true
```

NOTE: Определено в `active_support/core_ext/object/deep_dup.rb`.

### Работа с ключами

#### `except` и `except!`

Метод `except` возвращает хэш с убранными ключами, содержащимися в перечне аргументов, если они существуют:

```ruby
{a: 1, b: 2}.except(:a) # => {:b=>2}
```

Если получатель откликается на `convert_key`, метод вызывается на каждом из аргументов. Это позволяет `except` хорошо обращаться с хэшами с индифферентым доступом, например:

```ruby
{a: 1}.with_indifferent_access.except(:a)  # => {}
{a: 1}.with_indifferent_access.except("a") # => {}
```

Также имеется вариант с восклицательным знаком `except!`, который убирает ключи в самом получателе.

NOTE: Определено в `active_support/core_ext/hash/except.rb`.

#### `transform_keys` и `transform_keys!`

Метод `transform_keys` принимает блок и возвращает хэш, в котором к каждому из ключей получателя были применены операции в блоке:

```ruby
{nil => nil, 1 => 1, a: :a}.transform_keys { |key| key.to_s.upcase }
# => {"" => nil, "1" => 1, "A" => :a}
```

В случае коллизии будет выбрано одно из значений. Выбранное значение не всегда будет одинаковым для одного и того же хэша:

```ruby
{"a" => 1, a: 2}.transform_keys { |key| key.to_s.upcase }
# Результатом будет или
# => {"A"=>2}
# или
# => {"A"=>1}
```

Этот метод может помочь, к примеру, при создании специальных преобразований. Например, `stringify_keys` и `symbolize_keys` используют `transform_keys` для выполнения преобразований ключей:

```ruby
def stringify_keys
  transform_keys { |key| key.to_s }
end
...
def symbolize_keys
  transform_keys { |key| key.to_sym rescue key }
end
```

Также имеется вариант с восклицательным знаком `transform_keys!`, применяющий операции в блоке к ключам в самом получателе.

Кроме этого, можно использовать `deep_transform_keys` и `deep_transform_keys!` для выполнения операции в блоке ко всем ключам в заданном хэше и всех хэшах, вложенных в него. Пример результата:

```ruby
{nil => nil, 1 => 1, nested: {a: 3, 5 => 5}}.deep_transform_keys { |key| key.to_s.upcase }
# => {""=>nil, "1"=>1, "NESTED"=>{"A"=>3, "5"=>5}}
```

NOTE: Определено в `active_support/core_ext/hash/keys.rb`.

#### `stringify_keys` и `stringify_keys!`

Метод `stringify_keys` возвращает хэш, в котором ключи получателя преобразованы в строку. Это выполняется с помощью применения к ним `to_s`:

```ruby
{nil => nil, 1 => 1, a: :a}.stringify_keys
# => {"" => nil, "1" => 1, "a" => :a}
```

В случае коллизии ключей будет выбрано одно из значений. Выбранное значение не всегда будет одинаковым для одного и того же хэша:

```ruby
{"a" => 1, a: 2}.stringify_keys
# Результатом будет или
# => {"a"=>2}
# или
# => {"a"=>1}
```

Метод может быть полезным, к примеру, для простого принятия и символов, и строк как опций. Например, `ActionView::Helpers::FormHelper` определяет:

```ruby
def to_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
  options = options.stringify_keys
  options["type"] = "checkbox"
  ...
end
```

Вторая строчка может безопасно обратиться к ключу "type" и позволить пользователю передавать или `:type`, или "type".

Также имеется вариант с восклицательным знаком `stringify_keys!`, который преобразует к строке ключи в самом получателе.

Кроме этого, можно использовать `deep_stringify_keys` и `deep_stringify_keys!` для преобразования к строке всех ключей в заданном хэше и всех хэшей, вложенных в него. Пример результата:

```ruby
{nil => nil, 1 => 1, nested: {a: 3, 5 => 5}}.deep_stringify_keys
# => {""=>nil, "1"=>1, "nested"=>{"a"=>3, "5"=>5}}
```

NOTE: Определено в `active_support/core_ext/hash/keys.rb`.

#### `symbolize_keys` и `symbolize_keys!`

Метод `symbolize_keys` возвращает хэш, в котором ключи получателя преобразованы к символам там, где это возможно. Это выполняется с помощью применения к ним `to_sym`:

```ruby
{nil => nil, 1 => 1, "a" => "a"}.symbolize_keys
# => {nil=>nil, 1=>1, :a=>"a"}
```

WARNING. Отметьте в предыдущем примере, что только один ключ был преобразован к символу.

В случае коллизии ключей будет выбрано одно из значений. Выбранное значение не всегда будет одинаковым для одного и того же хэша:

```ruby
{"a" => 1, a: 2}.symbolize_keys
# Результатом будет или
# => {:a=>2}
# или
# => {:a=>1}
```

Метод может быть полезным, к примеру, для простого принятия и символов, и строк как опций. Например, `ActionController::UrlRewriter` определяет

```ruby
def rewrite_path(options)
  options = options.symbolize_keys
  options.update(options[:params].symbolize_keys) if options[:params]
  ...
end
```

Вторая строчка может безопасно обратиться к ключу `:params` и позволить пользователю передавать или `:params`, или "params".

Также имеется вариант с восклицательным знаком `symbolize_keys!`, который приводит к символу ключи в самом получателе.

Кроме этого, можно использовать `deep_symbolize_keys` и `deep_symbolize_keys!` для преобразования к символам всех ключей в заданном хэше и всех хэшей, вложенных в него. Пример результата:

```ruby
{nil => nil, 1 => 1, "nested" => {"a" => 3, 5 => 5}}.deep_symbolize_keys
# => {nil=>nil, 1=>1, nested:{a:3, 5=>5}}
```

NOTE: Определено в `active_support/core_ext/hash/keys.rb`.

#### `to_options` и `to_options!`

Методы `to_options` и `to_options!` являются псевдонимами `symbolize_keys` и `symbolize_keys!` соответственно.

NOTE: Определено в `active_support/core_ext/hash/keys.rb`.

#### `assert_valid_keys`

Метод `assert_valid_keys` получает определенное число аргументов и проверяет, имеет ли получатель хоть один ключ вне этого белого списка. Если имеет, вызывается `ArgumentError`.

```ruby
{a: 1}.assert_valid_keys(:a)  # passes
{a: 1}.assert_valid_keys("a") # ArgumentError
```

Active Record не принимает незнакомые опции при создании связей, к примеру. Он реализует такой контроль через `assert_valid_keys`.

NOTE: Определено в `active_support/core_ext/hash/keys.rb`.

### Нарезка

В Ruby есть встроенная поддержка для нарезки строк или массивов. Active Support расширяет нарезку на хэши:

```ruby
{a: 1, b: 2, c: 3}.slice(:a, :c)
# => {:a=>1, :c=>3}

{a: 1, b: 2, c: 3}.slice(:b, :X)
# => {:b=>2} # несуществующие ключи игнорируются
```

Если получатель откликается на `convert_key`, ключи нормализуются:

```ruby
{a: 1, b: 2}.with_indifferent_access.slice("a")
# => {:a=>1}
```

NOTE: Нарезка может быть полезной для экранизации хэш-опции с помощью белого списка ключей.

Также есть `slice!`, который выполняет нарезку, модифицируя на месте, и возвращает что было убрано:

```ruby
hash = {a: 1, b: 2}
rest = hash.slice!(:a) # => {:b=>2}
hash                   # => {:a=>1}
```

NOTE: Определено в `active_support/core_ext/hash/slice.rb`.

### Извлечение

Метод `extract!` убирает и возвращает пары ключ/значение, соответствующие заданным ключам.

```ruby
hash = {:a => 1, :b => 2}
rest = hash.extract!(:a) # => {:a=>1}
hash                     # => {:b=>2}
```

Метод `extract!` возвращает тот же подкласс Hash, каким является получатель.

```ruby
hash = {a: 1, b: 2}.with_indifferent_access
rest = hash.extract!(:a).class
# => ActiveSupport::HashWithIndifferentAccess
```

NOTE: Определено в `active_support/core_ext/hash/slice.rb`.

### Индифферентный доступ

Метод `with_indifferent_access` возвращает `ActiveSupport::HashWithIndifferentAccess` из своего получателя:

```ruby
{a: 1}.with_indifferent_access["a"] # => 1
```

NOTE: Определено в `active_support/core_ext/hash/indifferent_access.rb`.

Расширения для `Regexp`
-----------------------

### `multiline?`

Метод `multiline?` говорит, имеет ли регулярное выражение установленный флаг `/m`, то есть соответствует ли точка новым строкам.

```ruby
%r{.}.multiline?  # => false
%r{.}m.multiline? # => true

Regexp.new('.').multiline?                    # => false
Regexp.new('.', Regexp::MULTILINE).multiline? # => true
```

Rails использует этот метод в одном месте, в коде маршрутизации. Регулярные выражения Multiline недопустимы для маршрутных требований, и этот флаг облегчает соблюдение этого ограничения.

```ruby
def assign_route_options(segments, defaults, requirements)
  ...
  if requirement.multiline?
    raise ArgumentError, "Regexp multiline option not allowed in routing requirements: #{requirement.inspect}"
  end
  ...
end
```

NOTE: Определено в `active_support/core_ext/regexp.rb`.

Расширения для `Range`
----------------------

### `to_s`

Active Support расширяет метод `Range#to_s` так, что он понимает опциональный аргумент формата. В настоящий момент имеется только один поддерживаемый формат, отличный от дефолтного, это `:db`:

```ruby
(Date.today..Date.tomorrow).to_s
# => "2009-10-25..2009-10-26"

(Date.today..Date.tomorrow).to_s(:db)
# => "BETWEEN '2009-10-25' AND '2009-10-26'"
```

Как изображено в примере, формат `:db` генерирует SQL условие `BETWEEN`. Это используется Active Record в поддержке значений интервала в условиях.

NOTE: Определено в `active_support/core_ext/range/conversions.rb`.

### `include?`

Методы `Range#include?` и `Range#===` сообщают, лежит ли некоторое значение между концами заданного экземпляра:

```ruby
(2..3).include?(Math::E) # => true
```

Active Support расширяет эти методы так, что аргумент, в свою очередь, может быть другим интервалом. В этом случае проверяется, принадлежат ли концы интервала аргументов самому получателю:

```ruby
(1..10).include?(3..7)  # => true
(1..10).include?(0..7)  # => false
(1..10).include?(3..11) # => false
(1...9).include?(3..9)  # => false
(1..10) === (3..7)  # => true
(1..10) === (0..7)  # => false
(1..10) === (3..11) # => false
(1...9) === (3..9)  # => false
```

NOTE: Определено в `active_support/core_ext/range/include_range.rb`.

### `overlaps?`

Метод `Range#overlaps?` говорит, имеют ли два заданных интервала непустое пересечение:

```ruby
(1..10).overlaps?(7..11)  # => true
(1..10).overlaps?(0..7)   # => true
(1..10).overlaps?(11..27) # => false
```

NOTE: Определено в `active_support/core_ext/range/overlaps.rb`.

Расширения для `Date`
---------------------

### Вычисления

NOTE: Все следующие методы определены в `active_support/core_ext/date/calculations.rb`.

```ruby
yesterday
tomorrow
beginning_of_week (at_beginning_of_week)
end_of_week (at_end_of_week)
monday
sunday
weeks_ago
prev_week (last_week)
next_week
months_ago
months_since
beginning_of_month (at_beginning_of_month)
end_of_month (at_end_of_month)
last_month
beginning_of_quarter (at_beginning_of_quarter)
end_of_quarter (at_end_of_quarter)
beginning_of_year (at_beginning_of_year)
end_of_year (at_end_of_year)
years_ago
years_since
last_year
on_weekday?
on_weekend?
```

INFO: Следующие методы вычисления имеют [временную пропасть](https://ru.wikipedia.org/wiki/Григорианский_календарь) в октябре 1582 года, когда дней с 5 по 14 (включительно) просто не существовало. Это руководство не документирует свое поведение в те дни для краткости, но достаточно сказать, будет происходит то, что от них ожидается. То есть, `Date.new(1582, 10, 4).tomorrow` возвратит `Date.new(1582, 10, 15)`, и так далее. Пожалуйста, проверьте `test/core_ext/date_ext_test.rb` в тестовом наборе Active Support, чтобы понять ожидаемое поведение.

#### `Date.current`

Active Support определяет `Date.current` как сегодняшний день в текущей временной зоне. Он похож на `Date.today`, за исключением того, что он учитывает временную зону пользователя, если она определена. Он также определяет `Date.yesterday` и `Date.tomorrow`, и предикаты экземпляра `past?`, `today?`, `future?`, `on_weekday?` и `on_weekend?`, все они зависят от `Date.current`.

#### Именованные даты

##### `beginning_of_week`, `end_of_week`

Методы `beginning_of_week` и `end_of_week` возвращают даты начала и конца недели соответственно. Предполагается, что неделя начинается с понедельника, но это может быть изменено переданным аргументом, установив локально для треда `Date.beginning_of_week` или `config.beginning_of_week`.

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.beginning_of_week          # => Mon, 03 May 2010
d.beginning_of_week(:sunday) # => Sun, 02 May 2010
d.end_of_week                # => Sun, 09 May 2010
d.end_of_week(:sunday)       # => Sat, 08 May 2010
```

У `beginning_of_week` есть псевдоним `at_beginning_of_week`, а у `end_of_week` есть псевдоним `at_end_of_week`.

##### `monday`, `sunday`

Методы `monday` и `sunday` возвращают даты предыдущего понедельника или следующего воскресенья соответственно.

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.monday                     # => Mon, 03 May 2010
d.sunday                     # => Sun, 09 May 2010

d = Date.new(2012, 9, 10)    # => Mon, 10 Sep 2012
d.monday                     # => Mon, 10 Sep 2012

d = Date.new(2012, 9, 16)    # => Sun, 16 Sep 2012
d.sunday                     # => Sun, 16 Sep 2012
```

##### `prev_week`, `next_week`

`next_week` принимает символ с днем недели на английском (по умолчанию локально для треда `Date.beginning_of_week` или `config.beginning_of_week`, или `:monday`) и возвращает дату, соответствующую этому дню на следующей неделе:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.next_week              # => Mon, 10 May 2010
d.next_week(:saturday)   # => Sat, 15 May 2010
```

`prev_week` работает аналогично:

```ruby
d.prev_week              # => Mon, 26 Apr 2010
d.prev_week(:saturday)   # => Sat, 01 May 2010
d.prev_week(:friday)     # => Fri, 30 Apr 2010
```

У `prev_week` есть псевдоним `last_week`.

И `next_week`, и `prev_week` работают так, как нужно, когда установлен `Date.beginning_of_week` или `config.beginning_of_week`.

##### `beginning_of_month`, `end_of_month`

Методы `beginning_of_month` и `end_of_month` возвращают даты начала и конца месяца:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_month     # => Sat, 01 May 2010
d.end_of_month           # => Mon, 31 May 2010
```

У `beginning_of_month` есть псевдоним `at_beginning_of_month`, а у `end_of_month` есть псевдоним `at_end_of_month`.

##### `beginning_of_quarter`, `end_of_quarter`

Методы `beginning_of_quarter` и `end_of_quarter` возвращают даты начала и конца квартала календарного года получателя:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_quarter   # => Thu, 01 Apr 2010
d.end_of_quarter         # => Wed, 30 Jun 2010
```

У `beginning_of_quarter` есть псевдоним `at_beginning_of_quarter`, а у `end_of_quarter` есть псевдоним `at_end_of_quarter`.

##### `beginning_of_year`, `end_of_year`

Методы `beginning_of_year` и `end_of_year` возвращают даты начала и конца года:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_year      # => Fri, 01 Jan 2010
d.end_of_year            # => Fri, 31 Dec 2010
```

У `beginning_of_year` есть псевдоним `at_beginning_of_year`, а у `end_of_year` есть псевдоним `at_end_of_year`.

#### Другие вычисления дат

##### `years_ago`, `years_since`

Метод `years_ago` получает число лет и возвращает ту же дату, что и много лет назад:

```ruby
date = Date.new(2010, 6, 7)
date.years_ago(10) # => Wed, 07 Jun 2000
```

`years_since` перемещает вперед по времени:

```ruby
date = Date.new(2010, 6, 7)
date.years_since(10) # => Sun, 07 Jun 2020
```

Если такая дата не найдена, возвращается последний день соответствующего месяца:

```ruby
Date.new(2012, 2, 29).years_ago(3)     # => Sat, 28 Feb 2009
Date.new(2012, 2, 29).years_since(3)   # => Sat, 28 Feb 2015
```

`last_year` это сокращение для `#years_ago(1)`.

##### `months_ago`, `months_since`

Методы `months_ago` и `months_since` работают аналогично, но для месяцев:

```ruby
Date.new(2010, 4, 30).months_ago(2)   # => Sun, 28 Feb 2010
Date.new(2010, 4, 30).months_since(2) # => Wed, 30 Jun 2010
```

Если такой день не существует, возвращается последний день соответствующего месяца:

```ruby
Date.new(2010, 4, 30).months_ago(2)    # => Sun, 28 Feb 2010
Date.new(2009, 12, 31).months_since(2) # => Sun, 28 Feb 2010
```

`last_month` это сокращение для `#months_ago(1)`.

##### `weeks_ago`

Метод `weeks_ago` работает аналогично для недель:

```ruby
Date.new(2010, 5, 24).weeks_ago(1)    # => Mon, 17 May 2010
Date.new(2010, 5, 24).weeks_ago(2)    # => Mon, 10 May 2010
```

##### `advance`

Более обычным способом перейти на другие дни является `advance`. Этот метод получает хэш с ключами `:years`, `:months`, `:weeks`, `:days`, и возвращает дату, передвинутую на столько, сколько указывают существующие ключи:

```ruby
date = Date.new(2010, 6, 6)
date.advance(years: 1, weeks: 2)  # => Mon, 20 Jun 2011
date.advance(months: 2, days: -2) # => Wed, 04 Aug 2010
```

Отметьте в предыдущем примере, что приросты могут быть отрицательными.

Для выполнения вычисления метод сначала приращивает года, затем месяцы, затем недели, и, наконец, дни. Этот порядок важен в концах месяцев. Скажем, к примеру, мы в конце февраля 2010, и мы хотим переместиться на один месяц и один день вперед.

Метод `advance` передвигает сначала на один месяц, и затем на один день, результат такой:

```ruby
Date.new(2010, 2, 28).advance(months: 1, days: 1)
# => Sun, 29 Mar 2010
```

Хотя, если бы мы делали по-другому, результат тоже был бы другой:

```ruby
Date.new(2010, 2, 28).advance(days: 1).advance(months: 1)
# => Thu, 01 Apr 2010
```

#### Изменяющиеся компоненты

Метод `change` позволяет получить новую дату, которая идентична получателю, за исключением заданного года, месяца или дня:

```ruby
Date.new(2010, 12, 23).change(year: 2011, month: 11)
# => Wed, 23 Nov 2011
```

Метод не принимает несуществующие даты, если изменение невалидно, вызывается `ArgumentError`:

```ruby
Date.new(2010, 1, 31).change(month: 2)
# => ArgumentError: invalid date
```

#### Длительности

Длительности могут добавляться и вычитаться из дат:

```ruby
d = Date.current
# => Mon, 09 Aug 2010
d + 1.year
# => Tue, 09 Aug 2011
d - 3.hours
# => Sun, 08 Aug 2010 21:00:00 UTC +00:00
```

Они переводят в вызовы `since` или `advance`. Например, здесь мы получим правильный переход ко времени календарной реформы:

```ruby
Date.new(1582, 10, 4) + 1.day
# => Fri, 15 Oct 1582
```

#### Временные метки

INFO: Следующие методы возвращают объект `Time`, если возможно, в противном случае `DateTime`. Если установлено, учитывается временная зона пользователя.

##### `beginning_of_day`, `end_of_day`

Метод `beginning_of_day` возвращает временную метку для начала дня (00:00:00):

```ruby
date = Date.new(2010, 6, 7)
date.beginning_of_day # => Mon Jun 07 00:00:00 +0200 2010
```

Метод `end_of_day` возвращает временную метку для конца дня (23:59:59):

```ruby
date = Date.new(2010, 6, 7)
date.end_of_day # => Mon Jun 07 23:59:59 +0200 2010
```

У `beginning_of_day` есть псевдонимы `at_beginning_of_day`, `midnight`, `at_midnight`.

##### `beginning_of_hour`, `end_of_hour`

Метод `beginning_of_hour` возвращает временную метку в начале часа (hh:00:00):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_hour # => Mon Jun 07 19:00:00 +0200 2010
```

Метод `end_of_hour` возвращает временную метку в конце часа (hh:59:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_hour # => Mon Jun 07 19:59:59 +0200 2010
```

У `beginning_of_hour` есть псевдоним `at_beginning_of_hour`.

##### `beginning_of_minute`, `end_of_minute`

Метод `beginning_of_minute` возвращает временную метку в начале минуты (hh:mm:00):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_minute # => Mon Jun 07 19:55:00 +0200 2010
```

Метод `end_of_minute` возвращает временную метку в конце минуты (hh:mm:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_minute # => Mon Jun 07 19:55:59 +0200 2010
```

У `beginning_of_minute` есть псевдоним `at_beginning_of_minute`.

INFO: `beginning_of_hour`, `end_of_hour`, `beginning_of_minute` и `end_of_minute` реализованы для `Time` и `DateTime`, но **не** для `Date`, так как у экземпляра `Date` не имеет смысла спрашивать о начале или окончании часа или минуты.

##### `ago`, `since`

Метод `ago` получает количество секунд как аргумент и возвращает временную метку, имеющую столько секунд до полуночи:

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.ago(1)         # => Thu, 10 Jun 2010 23:59:59 EDT -04:00
```

Подобным образом `since` двигается вперед:

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.since(1)       # => Fri, 11 Jun 2010 00:00:01 EDT -04:00
```

Расширения для `DateTime`
-------------------------

WARNING: `DateTime` не знает о правилах DST (переходов на летнее время), и поэтому некоторые из этих методов сталкиваются с временной пропастью, когда переход на и с летнего времени имеет место. К примеру, `seconds_since_midnight` может не возвратить настоящее значение для таких дней.

### Вычисления

NOTE: Все нижеследующие методы определены в `active_support/core_ext/date_time/calculations.rb`.

Класс `DateTime` является подклассом `Date`, поэтому загрузив `active_support/core_ext/date/calculations.rb` будут унаследованы эти методы и их псевдонимы, за исключением того, что они будут всегда возвращать дату и время.

Следующие методы переопределены, поэтому **не** нужно загружать `active_support/core_ext/date/calculations.rb` для них:

```ruby
beginning_of_day (midnight, at_midnight, at_beginning_of_day)
end_of_day
ago
since (in)
```

С другой стороны, `advance` и `change` также определены, и поэтому поддерживают больше опций, описанных [ранее](/active-support-core-extensions#advance).

Следующие методы реализованы только в `active_support/core_ext/date_time/calculations.rb`, так как они имеют смысл только при использовании с экземпляром `DateTime`:

```ruby
beginning_of_hour (at_beginning_of_hour)
end_of_hour
```

#### Именованные Datetime

##### `DateTime.current`

Active Support определяет `DateTime.current` похожим на `Time.now.to_datetime`, за исключением того, что он учитывает временную зону пользователя, если она определена. Он также определяет `DateTime.yesterday` и `DateTime.tomorrow`, и предикаты экземпляра `past?` и `future?` относительно `DateTime.current`.

#### Другие расширения

##### `seconds_since_midnight`

Метод `seconds_since_midnight` возвращает число секунд, прошедших с полуночи:

```ruby
now = DateTime.current     # => Mon, 07 Jun 2010 20:26:36 +0000
now.seconds_since_midnight # => 73596
```

##### `utc`

Метод `utc` выдает такую же дату и время получателя, но выраженную в UTC.

```ruby
now = DateTime.current # => Mon, 07 Jun 2010 19:27:52 -0400
now.utc                # => Mon, 07 Jun 2010 23:27:52 +0000
```

У этого метода также есть псевдоним `getutc`.

##### `utc?`

Предикат `utc?` говорит, имеет ли получатель UTC в качестве своей временной зоны:

```ruby
now = DateTime.now # => Mon, 07 Jun 2010 19:30:47 -0400
now.utc?           # => false
now.utc.utc?       # => true
```

##### (date-time-advance) `advance`

Более обычным способом перейти к другим дате и времени является `advance`. Этот метод получает хэш с ключами `:years`, `:months`, `:weeks`, `:days`, `:hours`, `:minutes` и `:seconds`, и возвращает дату и время, передвинутые на столько, на сколько указывают существующие ключи.

```ruby
d = DateTime.current
# => Thu, 05 Aug 2010 11:33:31 +0000
d.advance(years: 1, months: 1, days: 1, hours: 1, minutes: 1, seconds: 1)
# => Tue, 06 Sep 2011 12:34:32 +0000
```

Этот метод сначала вычисляет дату назначения, передавая `:years`, `:months`, `:weeks` и `:days` в `Date#advance`, описанный [ранее](/active-support-core-extensions#advance). После этого, он корректирует время, вызвав `since` с количеством секунд, на которое нужно передвинуть. Этот порядок обоснован, другой порядок мог бы дать другие дату и время для некоторых временных пропастей. Используем пример в `Date#advance`, и расширим его, показав обоснованность порядка, применимого к единицам измерения времени.

Если сначала передвинуть единицы измерения даты (относительный порядок вычисления, показанный ранее), а затем единицы измерения времени, мы получим для примера следующее вычисление:

```ruby
d = DateTime.new(2010, 2, 28, 23, 59, 59)
# => Sun, 28 Feb 2010 23:59:59 +0000
d.advance(months: 1, seconds: 1)
# => Mon, 29 Mar 2010 00:00:00 +0000
```

но если мы вычисляем обратным способом, результат будет иным:

```ruby
d.advance(seconds: 1).advance(months: 1)
# => Thu, 01 Apr 2010 00:00:00 +0000
```

WARNING: Поскольку `DateTime` не поддерживает DST (переход на летнее время), можно получить несуществующий момент времени без каких-либо предупреждений или сообщений об ошибке.

#### Изменение компонентов

Метод `change` позволяет получить новые дату и время, которая идентична получателю, за исключением заданных опций, включающих `:year`, `:month`, `:day`, `:hour`, `:min`, `:sec`, `:offset`, `:start`:

```ruby
now = DateTime.current
# => Tue, 08 Jun 2010 01:56:22 +0000
now.change(year: 2011, offset: Rational(-6, 24))
# => Wed, 08 Jun 2011 01:56:22 +0600
```

Если часы обнуляются, то минуты и секунды тоже (если у них не заданы значения):

```ruby
now.change(hour: 0)
# => Tue, 08 Jun 2010 00:00:00 +0000
```

Аналогично, если минуты обнуляются, то секунды тоже (если у них не задано значение):

```ruby
now.change(min: 0)
# => Tue, 08 Jun 2010 01:00:00 +0000
```

Этот метод не принимает несуществующие даты, если изменение невалидно, вызывается `ArgumentError`:

```ruby
DateTime.current.change(month: 2, day: 30)
# => ArgumentError: invalid date
```

#### Длительности

Длительности могут добавляться и вычитаться из даты и времени:

```ruby
now = DateTime.current
# => Mon, 09 Aug 2010 23:15:17 +0000
now + 1.year
# => Tue, 09 Aug 2011 23:15:17 +0000
now - 1.week
# => Mon, 02 Aug 2010 23:15:17 +0000
```

Они переводят в вызовы `since` или `advance`. Например, здесь мы получим правильный переход ко времени календарной реформы:

```ruby
DateTime.new(1582, 10, 4, 23) + 1.hour
# => Fri, 15 Oct 1582 00:00:00 +0000
```

Расширения для `Time`
---------------------

### Вычисления

NOTE: Все следующие методы определены в `active_support/core_ext/time/calculations.rb`.

```ruby
past?
today?
future?
yesterday
tomorrow
seconds_since_midnight
change
advance
ago
since (in)
prev_day
next_day
beginning_of_day (midnight, at_midnight, at_beginning_of_day)
end_of_day
beginning_of_hour (at_beginning_of_hour)
end_of_hour
beginning_of_week (at_beginning_of_week)
end_of_week (at_end_of_week)
monday
sunday
weeks_ago
prev_week (last_week)
next_week
months_ago
months_since
beginning_of_month (at_beginning_of_month)
end_of_month (at_end_of_month)
prev_month
next_month
last_month
beginning_of_quarter (at_beginning_of_quarter)
end_of_quarter (at_end_of_quarter)
beginning_of_year (at_beginning_of_year)
end_of_year (at_end_of_year)
years_ago
years_since
prev_year
last_year
next_year
on_weekday?
on_weekend?
```

Это аналоги. Обратитесь к их документации выше, но примите во внимание следующие различия:

* `change` принимает дополнительную опцию `:usec`.
* `Time` понимает летнее время (DST), поэтому вы получите правильные вычисления времени как тут:

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>

# В Барселоне, 2010/03/28 02:00 +0100 становится 2010/03/28 03:00 +0200 благодаря переходу на летнее время.
t = Time.local(2010, 3, 28, 1, 59, 59)
# => Sun Mar 28 01:59:59 +0100 2010
t.advance(seconds: 1)
# => Sun Mar 28 03:00:00 +0200 2010
```

* Если `since` или `ago` переходят на время, которое не может быть выражено с помощью `Time`, вместо него возвращается объект `DateTime`.

#### `Time.current`

Active Support определяет `Time.current` как сегодняшний день в текущей временной зоне. Он похож на `Time.now`, за исключением того, что он учитывает временную зону пользователя, если она определена. Он также определяет предикаты экземпляра `past?`, `today?` и `future?`, все они относительны к `Time.current`.

При осуществлении сравнения Time с использованием методов, учитывающих временную зону пользователя, убедитесь, что используете `Time.current` вместо `Time.now`. Есть случаи, когда временная зона пользователя может быть в будущем по сравнению с временной зоной системы, в которой по умолчанию используется `Time.now`. Это означает, что `Time.now.to_date` может быть равным `Date.yesterday`.

#### `all_day`, `all_week`, `all_month`, `all_quarter` и `all_year`

Метод `all_day` возвращает интервал, представляющий целый день для текущего времени.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_day
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Mon, 09 Aug 2010 23:59:59 UTC +00:00
```

Аналогично `all_week`, `all_month`, `all_quarter` и `all_year` служат целям генерации временных интервалов.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_week
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Sun, 15 Aug 2010 23:59:59 UTC +00:00
now.all_week(:sunday)
# => Sun, 16 Sep 2012 00:00:00 UTC +00:00..Sat, 22 Sep 2012 23:59:59 UTC +00:00
now.all_month
# => Sat, 01 Aug 2010 00:00:00 UTC +00:00..Tue, 31 Aug 2010 23:59:59 UTC +00:00
now.all_quarter
# => Thu, 01 Jul 2010 00:00:00 UTC +00:00..Thu, 30 Sep 2010 23:59:59 UTC +00:00
now.all_year
# => Fri, 01 Jan 2010 00:00:00 UTC +00:00..Fri, 31 Dec 2010 23:59:59 UTC +00:00
```

#### `prev_day`, `next_day`

В Ruby 1.9 `prev_day` и `next_day` возвращают дату для последнего или следующего дня:

```ruby
d = Date.new(2010, 5, 8) # => Sat, 08 May 2010
d.prev_day               # => Fri, 07 May 2010
d.next_day               # => Sun, 09 May 2010
```

#### `prev_month`, `next_month`

В Ruby 1.9 `prev_month` и `next_month` возвращают дату с тем же днем в предыдущем или следующем месяце:

```ruby
d = Date.new(2010, 5, 8) # => Sat, 08 May 2010
d.prev_month             # => Thu, 08 Apr 2010
d.next_month             # => Tue, 08 Jun 2010
```

Если такой день не существует, возвращается последний день соответствующего месяца:

```ruby
Date.new(2000, 5, 31).prev_month # => Sun, 30 Apr 2000
Date.new(2000, 3, 31).prev_month # => Tue, 29 Feb 2000
Date.new(2000, 5, 31).next_month # => Fri, 30 Jun 2000
Date.new(2000, 1, 31).next_month # => Tue, 29 Feb 2000
```

#### `prev_year`, `next_year`

В Ruby 1.9 `prev_year` и `next_year` возвращают дату с тем же днем/месяцем в предыдущем или следующем году:

```ruby
d = Date.new(2010, 5, 8) # => Sat, 08 May 2010
d.prev_year              # => Fri, 08 May 2009
d.next_year              # => Sun, 08 May 2011
```

Если датой является 29 февраля високосного года, возвратится 28-е:

```ruby
d = Date.new(2000, 2, 29) # => Tue, 29 Feb 2000
d.prev_year               # => Sun, 28 Feb 1999
d.next_year               # => Wed, 28 Feb 2001
```

#### `prev_quarter`, `next_quarter`

`prev_quarter` и `next_quarter` возвращают дату с тем же днем в предыдущем или следующем квартале:

```ruby
t = Time.local(2010, 5, 8) # => 2010-05-08 00:00:00 0300
t.prev_quarter             # => 2010-02-08 00:00:00 0200
t.next_quarter             # => 2010-08-08 00:00:00 0300
```

Если такой день не существует, возвращается последний день соответствующего месяца:

```ruby
Time.local(2000, 7, 31).prev_quarter  # => 2000-04-30 00:00:00 0300
Time.local(2000, 5, 31).prev_quarter  # => 2000-02-29 00:00:00 0200
Time.local(2000, 10, 31).prev_quarter # => 2000-07-31 00:00:00 0300
Time.local(2000, 11, 31).next_quarter # => 2001-03-01 00:00:00 0200
```

`prev_quarter` имеет псевдоним `last_quarter`.

### Конструкторы Time

Active Support определяет `Time.current` как `Time.zone.now`, если у пользователя определена временная зона, а иначе `Time.now`:

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>
Time.current
# => Fri, 06 Aug 2010 17:11:58 CEST +02:00
```

Как и у `DateTime`, предикаты `past?` и `future?` выполняются относительно `Time.current`.

Если время, подлежащее конструированию лежит за пределами интервала, поддерживаемого `Time` на запущенной платформе, usecs отбрасываются и вместо этого возвращается объект `DateTime`.

#### Длительности

Длительности могут быть добавлены и вычтены из объектов времени:

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now + 1.year
# => Tue, 09 Aug 2011 23:21:11 UTC +00:00
now - 1.week
# => Mon, 02 Aug 2010 23:21:11 UTC +00:00
```

Они переводят в вызовы `since` или `advance`. Например, здесь мы получим правильный переход ко времени календарной реформы:

```ruby
Time.utc(1582, 10, 3) + 5.days
# => Mon Oct 18 00:00:00 UTC 1582
```

Расширения для `File`
---------------------

### `atomic_write`

С помощью метода класса `File.atomic_write` можно записать в файл способом, предотвращающим от просмотра недописанного содержимого.

Имя файла передается как аргумент, и в метод вкладываются обработчики файла, открытого для записи. Как только блок выполняется, `atomic_write` закрывает файл и завершает свое задание.

Например, Action Pack использует этот метод для записи файлов кэша ассетов, таких как `all.css`:

```ruby
File.atomic_write(joined_asset_path) do |cache|
  cache.write(join_asset_file_contents(asset_paths))
end
```

Для выполнения этого `atomic_write` создает временный файл. Фактически код в блоке пишет в этот файл. При выполнении временный файл переименовывается, что является атомарной операцией в системах POSIX. Если целевой файл существует, `atomic_write` перезаписывает его и сохраняет владельцев и права доступа. Однако в некоторых случаях `atomic_write` не может изменить владельца или права доступа на файл, эта ошибка отлавливается и пропускается, позволяя файловой системе убедиться, что файл доступен для необходимых манипуляций.

NOTE: Благодаря операции chmod, выполняемой `atomic_write`, если у целевого файла установлен ACL, то этот ACL будет пересчитан/модифицирован.

WARNING. Отметьте, что с помощью `atomic_write` нельзя дописывать.

Вспомогательный файл записывается в стандартной директории для временных файлов, но можно передать эту директорию как второй аргумент.

NOTE: Определено в `active_support/core_ext/file/atomic.rb`.

Расширения для `Marshal`
------------------------

### `load`

Active Support добавляет поддержку постоянной автозагрузки для `load`.

Например, хранилище кэша файлов десериализует следующим образом:

```ruby
File.open(file_name) { |f| Marshal.load(f) }
```

Если закэшированные данные обращаются к константе, которая неизвестна в данный момент, включается механизм автозагрузки и, если он успешен, перевыполняется десериализация.

WARNING. Если аргумент `IO`, необходимо, чтобы он отвечал на `rewind`, чтобы быть способным на повтор. Обычные файлы отвечают на `rewind`.

NOTE: Определено в `active_support/core_ext/marshal.rb`.

Расширения для `NameError`
--------------------------

Active Support добавляет `missing_name?` к `NameError`, который проверяет было ли исключение вызвано в связи с тем, что имя было передано как аргумент.

Имя может быть задано как символ или строка. Символ проверяется как простое имя константы, строка - как полностью ограниченное имя константы.

TIP: Символ может представлять полностью ограниченное имя константы как `:"ActiveRecord::Base"`, такое поведение для символов определено для удобства, а не потому, что такое возможно технически.

К примеру, когда вызывается экшн `ArticlesController`, Rails пытается оптимистично использовать `ArticlesHelper`. Это нормально, когда не существует модуля хелпера, поэтому если вызывается исключение для этого имени константы, оно должно молчать. Но в случае, если `articles_helper.rb` вызывает `NameError` благодаря неизвестной константе, оно должно быть перевызвано. Метод `missing_name?` предоставляет способ проведения различия в этих двух случаях:

```ruby
def default_helper_module!
  module_name = name.sub(/Controller$/, '')
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

NOTE: Определено в `active_support/core_ext/name_error.rb`.

Расширения для `LoadError`
--------------------------

Active Support добавляет `is_missing?` к `LoadError`.

Для заданного имени пути `is_missing?` проверяет, будет ли вызвано исключение из-за определенного файла (за исключением файлов с расширением ".rb").

Например, когда вызывается экшн `ArticlesController`, Rails пытается загрузить `articles_helper.rb`, но этот файл может не существовать. Это нормально, модуль хелпера не обязателен, поэтому Rails умалчивает ошибку загрузки. Но может быть случай, что модуль хелпера существует, и в свою очередь требует другую библиотеку, которая отсутствует. В этом случае Rails должен вызвать исключение. Метод `is_missing?` предоставляет способ проведения различия в этих двух случаях:

```ruby
def default_helper_module!
  module_name = name.sub(/Controller$/, '')
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

NOTE: Определено в `active_support/core_ext/load_error.rb`.
