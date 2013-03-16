Rails on Rack
=============

Это руководство раскрывает интеграцию Rails и Rack и взаимодействие с другими компонентами Rack.

После прочтения этого руководства, вы узнаете:

* Как создавать приложения Rails Metal
* Как использовать промежуточные программы Rack в своих приложениях Rails
* О стеке внутренних промежуточных программ Action Pack
* Как определять собственный стек промежуточных программ

WARNING: Это руководство предполагает практические знания протокола Rack и такие концепции Rack, как промежуточные программы (middlewares), карты (maps) url и `Rack::Builder`.

Введение в Rack
---------------

Rack представляет собой минимальный, модульный и адаптивный интерфейс для разработки веб-приложений на Ruby. Оборачивая запросы и отклики HTTP как можно более простым образом, он объединил и очистил API для веб-серверов, веб-фреймворков и промежуточных программ (так называемых middleware) до единственного метода call.

- [Документация Rack API](http://rack.rubyforge.org/doc/)

Объяснение, что такое Rack, на самом деле не является темой этого руководства. Если вы не знакомы с основами Rack, обратитесь к разделу [Источники](#resources).

Rails on Rack
-------------

### Объект Rack приложения Rails

`ApplicationName::Application` это основной объект приложения Rack в приложении Rails. Любой совместимый с Rack веб-сервер должен использовать объект `ApplicationName::Application` для обслуживания приложения Rails.

### `rails server`

`rails server` выполняет основную работу по созданию объекта `Rack::Server` и запуску веб-сервера.

Вот как `rails server` создает экземпляр `Rack::Server`

```ruby
Rails::Server.new.tap do |server|
  require APP_PATH
  Dir.chdir(Rails.application.root)
  server.start
end
```

`Rails::Server` унаследован от `Rack::Server` и вызывает метод `Rack::Server#start` следующим образом:

```ruby
class Server < ::Rack::Server
  def start
    ...
    super
  end
end
```

Вот как он загружает промежуточные программы:

```ruby
def middleware
  middlewares = []
  middlewares << [Rails::Rack::Debugger] if options[:debugger]
  middlewares << [::Rack::ContentLength]
  Hash.new(middlewares)
end
```

`Rails::Rack::Debugger` в основном полезен только в окружении development. Следующая таблица объясняет назначение загружаемых промежуточных программ:

| Промежуточная программа | Назначение                                                                      |
| ----------------------- | ------------------------------------------------------------------------------- |
| `Rails::Rack::Debugger` | Запускает отладчик                                                              |
| `Rack::ContentLength`   | Считает количество байт в отклике и устанавливает заголовок HTTP Content-Length |

### `rackup`

Для использования `rackup` вместо рельсового `rails server`, следует поместить следующее в `config.ru` в корневой директории приложения Rails:

```ruby
# Rails.root/config.ru
require "config/environment"

use Rack::Debugger
use Rack::ContentLength
run ApplicationName::Application
```

И запустить сервер:

```bash
$ rackup config.ru
```

Узнать подробности различных опций `rackup`:

```bash
$ rackup --help
```

Стек промежуточных программ Action Dispatcher
---------------------------------------------

Многие внутренние компоненты Action Dispatcher реализованы как промежуточные программы Rack. `Rails::Application` использует `ActionDispatch::MiddlewareStack` для объединения различных внутренних и внешних промежуточных программ для формирования полноценного приложения Rails Rack.

NOTE: `ActionDispatch::MiddlewareStack` это эквивалент `Rack::Builder` в Rails, сделанный с большей гибкостью и приспособленностью к требованиям Rails.

### Просмотр стека промежуточных программ

В Rails имеется удобный таск rake для просмотра используемого стека промежуточных программ:

```bash
$ rake middleware
```

Для нового приложения Rails он может выдать что-то наподобие:

```ruby
use ActionDispatch::Static
use Rack::Lock
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x000000029a0838>
use Rack::Runtime
use Rack::MethodOverride
use ActionDispatch::RequestId
use Rails::Rack::Logger
use ActionDispatch::ShowExceptions
use ActionDispatch::DebugExceptions
use ActionDispatch::RemoteIp
use ActionDispatch::Reloader
use ActionDispatch::Callbacks
use ActiveRecord::ConnectionAdapters::ConnectionManagement
use ActiveRecord::QueryCache
use ActionDispatch::Cookies
use ActionDispatch::Session::CookieStore
use ActionDispatch::Flash
use ActionDispatch::ParamsParser
use Rack::Head
use Rack::ConditionalGet
use Rack::ETag
run MyApp::Application.routes
```

Назначение каждой из этих промежуточных программ объясняется в разделе "Внутренние промежуточные программы":#internal-middleware-stack.

### Настройка стека промежуточных программ

Rails предоставляет простой конфигурационных интерфейс `config.middleware` для добавления, удаления и изменения промежуточных программ в стеке промежуточных программ, из `application.rb` или конфигурационного файла определенной среды `environments/&lt;environment&gt;.rb`.

#### Добавление промежуточной программы

Добавить новую промежуточную программу в стек промежуточных программ можно с использованием следующих методов:

* `config.middleware.use(new_middleware, args)` - Добавляет новую промежуточную программу в конец стека.

* `config.middleware.insert_before(existing_middleware, new_middleware, args)` - Добавляет промежуточную программу до определенной существующей промежуточной программы в стеке.

* `config.middleware.insert_after(existing_middleware, new_middleware, args)` - Добавляет промежуточную программу после определенной существующей промежуточной программы в стеке.

```ruby
# config/application.rb

# Добавить Rack::BounceFavicon в конец
config.middleware.use Rack::BounceFavicon

# Добавить Lifo::Cache после ActiveRecord::QueryCache.
# Передать аргумент { page_cache: false } в Lifo::Cache.
config.middleware.insert_after ActiveRecord::QueryCache, Lifo::Cache, page_cache: false
```

#### Перемена местами промежуточных программ

Поменять местами существующие промежуточные программы в стеке можно с использованием `config.middleware.swap`.

```ruby
# config/application.rb

# Поменять местами ActionDispatch::ShowExceptions с Lifo::ShowExceptions
config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions
```

#### Стек промежуточных программ как Enumerable

Стек промежуточных программ ведет себя как обычный `Enumerable`. Можно использовать любой `Enumerable` метод для воздействия или получения данных из стека. Стек промежуточных программ также реализует некоторые методы `Array`, включая `[]`, `unshift` and `delete`. Методы, описанные в предыдущем разделе - это всего лишь методы для удобства.

Добавьте следующие строчки в конфигурацию вашего приложения:

```ruby
# config/application.rb
config.middleware.delete "Rack::Lock"
```

Теперь, при просмотре стека промежуточных программ, вы увидите, что `Rack::Lock` больше не является его частью.

```bash
$ rake middleware
(in /Users/lifo/Rails/blog)
use ActionDispatch::Static
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x00000001c304c8>
use Rack::Runtime
...
run Blog::Application.routes
```

Если хотите убрать промежуточные программы, относящиеся к сессии, сделайте следующее:

```ruby
# config/application.rb
config.middleware.delete "ActionDispatch::Cookies"
config.middleware.delete "ActionDispatch::Session::CookieStore"
config.middleware.delete "ActionDispatch::Flash"
```

Чтобы убрать промежуточные программы, относящиеся к бразуеру,

```ruby
# config/application.rb
config.middleware.delete "Rack::MethodOverride"
```

### Стек внутренних промежуточных программ

Значительная часть функционала Action Controller реализована как промежуточные программы. Следующий перечень объясняет назначение каждой из них:

 **`ActionDispatch::Static`**

* Используется для раздачи статичных ресурсов. Отключена, если `config.serve_static_assets` является true.

 **`Rack::Lock`**

* Устанавливает флажок `env["rack.multithread"]` в `false` и оборачивает приложение в Mutex.

 **`ActiveSupport::Cache::Strategy::LocalCache::Middleware`**

* Используется для кэширования в памяти. Этот кэш не является нитебезопасным (thread safe).

 **`Rack::Runtime`**

* Устанавливает заголовок X-Runtime, содержащий время (в секундах), затраченное на выполнение запроса.

 **`Rack::MethodOverride`**

* Переопределяет метод, если установлен `params[:_method]`. Эта промежуточная программа поддерживает типы HTTP методов PUT и DELETE.

 **`ActionDispatch::RequestId`**

* Создает для отклика уникальный заголовок `X-Request-Id` и включает метод `ActionDispatch::Request#uuid`.

 **`Rails::Rack::Logger`**

* Уведомляет логи, что начался запрос. После выполнения запроса, глушит все логи.

 **`ActionDispatch::ShowExceptions`**

* Ловит все исключения, возвращаемые приложением и вызывает приложение для показа исключений, которое форматирует его для конечного пользователя.

 **`ActionDispatch::DebugExceptions`**

* Ответственна за логирование исключений и показа отладочной страницы, если запрос локальный.

 **`ActionDispatch::RemoteIp`**

* Проверяет на атаки с ложных IP.

 **`ActionDispatch::Reloader`**

* Предоставляет колбэки prepare и cleanup, предназначенные для перезагрузки кода во время разработки.

 **`ActionDispatch::Callbacks`**

* Запускает колбэки prepare до обслуживания запроса.

 **`ActiveRecord::ConnectionAdapters::ConnectionManagement`**

* Очищает активные соединения после каждого запроса, если ключ `rack.test` в среде запроса не установлен в `true`.

 **`ActiveRecord::QueryCache`**

* Включает кэширование запросов Active Record.

 **`ActionDispatch::Cookies`**

* Устанавливает для запроса куки.

 **`ActionDispatch::Session::CookieStore`**

* Ответственна за хранение сессии в куки.

 **`ActionDispatch::Flash`**

* Настраивает ключи flash. Доступна только если `config.action_controller.session_store` присовено значение.

 **`ActionDispatch::ParamsParser`**

* Парсит параметры запроса в `params`.

 **`ActionDispatch::Head`**

* Преобразует запросы HEAD в запросы `GET` и обслуживает их соответствующим образом.

 **`Rack::ConditionalGet`**

* Добавляет поддержку для "Conditional `GET`", чтобы сервер ничего не отвечал, если страница не изменилась.

 **`Rack::ETag`**

* Добавляет заголовок ETag во все строковые header on all String bodies. ETags are used to validate cache.

TIP: Можете использовать любые из этих промежуточных программ в своем стеке Rack.

### Использование Rack Builder

Следующее показывает, как использовать `Rack::Builder` вместо предоставленного Rails `MiddlewareStack`.

<strong>Очистите существующий стек промежуточных программ Rails</strong>

```ruby
# config/application.rb
config.middleware.clear
```

<br />
<strong>Добавьте файл `config.ru` в `Rails.root`</strong>

```ruby
# config.ru
use MyOwnStackFromScratch
run ApplicationName::Application
```

(resources) Источники
---------

### Обучение Rack

* [Official Rack Website](http://rack.github.com)
* [Introducing Rack](http://chneukirchen.org/blog/archive/2007/02/introducing-rack.html)
* [Ruby on Rack #1 - Hello Rack!](http://m.onkey.org/ruby-on-rack-1-hello-rack)
* [Ruby on Rack #2 - The Builder](http://m.onkey.org/ruby-on-rack-2-the-builder)

### Понимание промежуточных программ

* [Railscast on Rack Middlewares](http://railscasts.com/episodes/151-rack-middleware)
