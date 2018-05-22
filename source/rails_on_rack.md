Rails on Rack
=============

Это руководство раскрывает интеграцию Rails и Rack и взаимодействие с другими компонентами Rack.

После прочтения этого руководства, вы узнаете:

* Как использовать промежуточные программы Rack в своих приложениях Rails
* О стеке внутренних промежуточных программ Action Pack
* Как определять собственный стек промежуточных программ

WARNING: Это руководство предполагает практические знания протокола Rack и такие концепции Rack, как промежуточные программы (middlewares), карты (maps) url и `Rack::Builder`.

Введение в Rack
---------------

Rack представляет собой минимальный, модульный и адаптивный интерфейс для разработки веб-приложений на Ruby. Оборачивая запросы и отклики HTTP как можно более простым образом, он объединил и очистил API для веб-серверов, веб-фреймворков и промежуточных программ (так называемых middleware) до единственного метода call.

Объяснение того, как работает Rack, на самом деле не является темой этого руководства. Если вы не знакомы с основами Rack, обратитесь к разделу [Источники](#resources).

Rails on Rack
-------------

### Объект Rack приложения Rails

`Rails.application` это основной объект приложения Rack в приложении Rails. Любой совместимый с Rack веб-сервер должен использовать объект `Rails.application` для обслуживания приложения Rails. `Rails.application` ссылается на тот же объект приложения.

### `rails server`

`rails server` выполняет основную задачу по созданию объекта `Rack::Server` и запуску веб-сервера.

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

### `rackup`

Для использования `rackup` вместо рельсового `rails server`, следует поместить следующее в `config.ru` в корневой директории приложения Rails:

```ruby
# Rails.root/config.ru
require_relative 'config/environment'

run Rails.application
```

И запустить сервер:

```bash
$ rackup config.ru
```

Чтобы узнать больше о различных опциях `rackup`, вы можете выполнить:

```bash
$ rackup --help
```

### Разработка и автоматическая перезагрузка

Промежуточные программы загружаются один раз и не отслеживаются на предмет изменений. Необходимо перезагрузить сервер, чтобы отразить изменения в запущенном приложении.

Стек промежуточных программ Action Dispatcher
---------------------------------------------

Многие внутренние компоненты Action Dispatcher реализованы как промежуточные программы Rack. `Rails::Application` использует `ActionDispatch::MiddlewareStack` для объединения различных внутренних и внешних промежуточных программ для формирования полноценного приложения Rails Rack.

NOTE: `ActionDispatch::MiddlewareStack` это эквивалент `Rack::Builder` в Rails, сделанный с большей гибкостью и приспособленностью к требованиям Rails.

### Просмотр стека промежуточных программ

В Rails имеется удобная задача для просмотра используемого стека промежуточных программ:

```bash
$ bin/rails middleware
```

Для свежесгенерированного приложения Rails он может выдать что-то наподобие:

```ruby
use Rack::Sendfile
use ActionDispatch::Static
use ActionDispatch::Executor
use ActiveSupport::Cache::Strategy::LocalCache::Middleware
use Rack::Runtime
use Rack::MethodOverride
use ActionDispatch::RequestId
use ActionDispatch::RemoteIp
use Sprockets::Rails::QuietAssets
use Rails::Rack::Logger
use ActionDispatch::ShowExceptions
use WebConsole::Middleware
use ActionDispatch::DebugExceptions
use ActionDispatch::Reloader
use ActionDispatch::Callbacks
use ActiveRecord::Migration::CheckPending
use ActionDispatch::Cookies
use ActionDispatch::Session::CookieStore
use ActionDispatch::Flash
use ActionDispatch::ContentSecurityPolicy::Middleware
use Rack::Head
use Rack::ConditionalGet
use Rack::ETag
use Rack::TempfileReaper
run MyApp::Application.routes
```

Промежуточные программы по умолчанию, показанные здесь (и некоторые другие) описываются в разделе [Внутренние промежуточные программы](#internal-middleware-stack) ниже.

### Настройка стека промежуточных программ

Rails предоставляет простой конфигурационный интерфейс `config.middleware` для добавления, удаления и модифицирования промежуточных программ в стеке промежуточных программ, из `application.rb` или конфигурационного файла определенной среды `environments/<environment>.rb`.

#### Добавление промежуточной программы

Добавить новую промежуточную программу в стек промежуточных программ можно с помощью следующих методов:

* `config.middleware.use(new_middleware, args)` - Добавляет новую промежуточную программу в конец стека.

* `config.middleware.insert_before(existing_middleware, new_middleware, args)` - Добавляет промежуточную программу до определенной существующей промежуточной программы в стеке.

* `config.middleware.insert_after(existing_middleware, new_middleware, args)` - Добавляет промежуточную программу после определенной существующей промежуточной программы в стеке.

```ruby
# config/application.rb

# Добавить Rack::BounceFavicon в конец
config.middleware.use Rack::BounceFavicon

# Добавить Lifo::Cache после ActionDispatch::Executor.
# Передать аргумент { page_cache: false } в Lifo::Cache.
config.middleware.insert_after ActionDispatch::Executor, Lifo::Cache, page_cache: false
```

#### Перемена местами промежуточных программ

Поменять местами существующие промежуточные программы в стеке можно с помощью `config.middleware.swap`.

```ruby
# config/application.rb

# Поменять местами ActionDispatch::ShowExceptions с Lifo::ShowExceptions
config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions
```

#### Удаление промежуточных программ

Добавьте следующие строчки в конфигурацию вашего приложения:

```ruby
# config/application.rb
config.middleware.delete "Rack::Runtime"
```

Теперь, при просмотре стека промежуточных программ, вы увидите, что `Rack::Runtime` больше не является его частью.

```bash
$ bin/rails middleware
(in /Users/lifo/Rails/blog)
use ActionDispatch::Static
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x00000001c304c8>
...
run Rails.application.routes
```

Если хотите убрать промежуточные программы, относящиеся к сессии, сделайте следующее:

```ruby
# config/application.rb
config.middleware.delete ActionDispatch::Cookies
config.middleware.delete ActionDispatch::Session::CookieStore
config.middleware.delete ActionDispatch::Flash
```

Чтобы убрать промежуточные программы, относящиеся к браузеру,

```ruby
# config/application.rb
config.middleware.delete Rack::MethodOverride
```

### (internal-middleware-stack) Стек внутренних промежуточных программ

Значительная часть функциональности Action Controller реализована как промежуточные программы. Следующий перечень объясняет назначение каждой из них:

**`Rack::Sendfile`**

* Устанавливает заголовки X-Sendfile, специфичные для сервера. Настраивается с помощью опции `config.action_dispatch.x_sendfile_header`.

**`ActionDispatch::Static`**

* Используется для раздачи статичных файлов из директории public. Отключена, если `config.public_file_server.enabled` является false.

**`Rack::Lock`**

* Устанавливает флажок `env["rack.multithread"]` в `false` и оборачивает приложение в мьютекс.

**`ActionDispatch::Executor`**

* Используется для перезагрузки тредобезопасного кода при разработке.

**`ActiveSupport::Cache::Strategy::LocalCache::Middleware`**

* Используется для кэширования в памяти. Этот кэш не является тредобезопасным(thread safe).

**`Rack::Runtime`**

* Устанавливает заголовок X-Runtime, содержащий время (в секундах), затраченное на выполнение запроса.

**`Rack::MethodOverride`**

* Переопределяет метод, если установлен `params[:_method]`. Эта промежуточная программа поддерживает типы HTTP методов PUT и DELETE.

**`ActionDispatch::RequestId`**

* Создает для отклика уникальный заголовок `X-Request-Id` и включает метод `ActionDispatch::Request#request_id`.

**`ActionDispatch::RemoteIp`**

* Проверяет на IP-спуфинг атаки.

**`Sprockets::Rails::QuietAssets`**

* Подавляет вывод логгера для запросов ассета.

**`Rails::Rack::Logger`**

* Уведомляет логи, что начался запрос. После выполнения запроса, глушит все логи.

**`ActionDispatch::ShowExceptions`**

* Ловит все исключения, возвращаемые приложением и вызывает приложение для показа исключений, которое форматирует его для конечного пользователя.

**`ActionDispatch::DebugExceptions`**

* Ответственна за логирование исключений и показа отладочной страницы, если запрос локальный.

**`ActionDispatch::Reloader`**

* Предоставляет колбэки prepare и cleanup, предназначенные для перезагрузки кода во время разработки.

**`ActionDispatch::Callbacks`**

* Предоставляет колбэки для выполнения до и после направления запроса.

**`ActiveRecord::Migration::CheckPending`**

* Проверяет отложенные миграции и вызывает `ActiveRecord::PendingMigrationError`, если какие-то миграции отложены.

**`ActionDispatch::Cookies`**

* Устанавливает для запроса куки.

**`ActionDispatch::Session::CookieStore`**

* Ответственна за хранение сессии в куки.

**`ActionDispatch::Flash`**

* Настраивает ключи flash. Доступно, только если `config.action_controller.session_store` присвоено значение.

**`ActionDispatch::ContentSecurityPolicy::Middleware`**

* Предоставляет DSL для настройки заголовка Content-Security-Policy.

**`Rack::Head`**

* Преобразует запросы HEAD в запросы `GET` и обслуживает их соответствующим образом.

**`Rack::ConditionalGet`**

* Добавляет поддержку для "Conditional `GET`", чтобы сервер ничего не отвечал, если страница не изменилась.

**`Rack::ETag`**

* Добавляет заголовок ETag во все строковые тела. ETags используются для проверки кэша.

**`Rack::TempfileReaper`**

* Очищает временные файлы, используемые для буферизации multipart запросов.

TIP: Можете использовать любые из этих промежуточных программ в своем стеке Rack.

(resources) Источники
---------------------

### Обучение Rack

* [Official Rack Website](https://rack.github.io)
* [Introducing Rack](http://chneukirchen.org/blog/archive/2007/02/introducing-rack.html)

### Понимание промежуточных программ

* [Railscast on Rack Middlewares](http://railscasts.com/episodes/151-rack-middleware)
