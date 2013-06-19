Процесс инициализации в Rails
=============================

Это руководство объясняет внутренние процессы инициализации в Rails, начиная с Rails 4. Это достаточно углубленное руководство, оно рекомендовано для продвинутых разработчиков на Rails.

После прочтения этого руководства вы узнаете:

* Как использовать `rails server`.

Это руководство рассмотрит каждый вызов методов, требуемых для загрузки стека Ruby on Rails для нового приложения на Rails 4, объяснив подробно каждую встреченную часть кода. Для целей этого руководства мы сосредоточимся на том, что произойдет при запуске `rails server` для загрузки вашего приложения.

NOTE: Пути в этом руководстве указаны относительно Rails или приложения Rails, если не оговорено иное.

TIP: Если желаете параллельно чтению просматривать [исходный код Rails](https://github.com/rails/rails), мы рекомендуем использовать горячую клавишу `t`, чтобы открыть быстрый поиск файлов на GitHub.

Поехали!
--------

Сейчас мы загрузим и инициализируем приложение. Все начинается в исполняемом файле `bin/rails` вашего приложения. Приложение Rails обычно стартует с помощью запуска `rails console` или `rails server`.

### `bin/rails`

Этот файл содержит следующее:

```ruby
#!/usr/bin/env ruby
APP_PATH = File.expand_path('../../config/application',  __FILE__)
require File.expand_path('../../config/boot',  __FILE__)
require 'rails/commands'
```

Константа `APP_PATH` будет использована позже в `rails/commands`. Файл `config/boot`, упомянутый тут, это файл `config/boot.rb` нашего приложения, который ответственен за загрузку Bundler и его настройку.

### `config/boot.rb`

`config/boot.rb` содержит:

```ruby
# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
```

В стандартном приложении Rails имеется `Gemfile`, объявляющий все зависимости приложения. `config/boot.rb` устанавливает `ENV['BUNDLE_GEMFILE']` как расположение этого файла. Затем, если Gemfile существует, будет затребован `bundler/setup`.

Стандартное Rails приложение зависит от несольких гемов, а именно:

* abstract
* actionmailer
* actionpack
* activemodel
* activerecord
* activesupport
* arel
* builder
* bundler
* erubis
* i18n
* mail
* mime-types
* polyglot
* rack
* rack-cache
* rack-mount
* rack-test
* rails
* railties
* rake
* sqlite3-ruby
* thor
* treetop
* tzinfo

### `rails/commands.rb`

Как только завершится `config/boot.rb`, следующим файлом, который будет затребован, является `rails/commands`, который запустит команду, основываясь на переданных аргументах. В нашем случае, массив `ARGV` просто содержит `server`, который извлекается в переменную `command` следующими строчками:

```ruby
ARGV << '--help' if ARGV.empty?

aliases = {
  "g"  => "generate",
  "d"  => "destroy",
  "c"  => "console",
  "s"  => "server",
  "db" => "dbconsole",
  "r"  => "runner"
}

command = ARGV.shift
command = aliases[command] || command
```

TIP: Как видите, пустой список ARGV приведет к показу помощи Rails.

Если бы мы использовали `s` вместо `server`, Rails использовал бы определенные в файле псевдонимы `aliases`, соответствующие их командам. С помощью команды `server` Rails запустит следующий код:

```ruby
when 'server'
  # Change to the application's path if there is no config.ru file in current dir.
  # This allows us to run `rails server` from other directories, but still get
  # the main config.ru and properly set the tmp directory.
  Dir.chdir(File.expand_path('../../', APP_PATH)) unless File.exists?(File.expand_path("config.ru"))

  require 'rails/commands/server'
  Rails::Server.new.tap do |server|
    # We need to require application after the server sets environment,
    # otherwise the --environment option given to the server won't propagate.
    require APP_PATH
    Dir.chdir(Rails.application.root)
    server.start
  end
```

Этот файл изменит корень директории (путь на две директории выше `APP_PATH`, указывающего на `config/application.rb`), но только если не найден файл `config.ru`. Затем он затребует `rails/commands/server`, устанавливающий класс `Rails::Server`.

```ruby
require 'fileutils'
require 'optparse'
require 'action_dispatch'

module Rails
  class Server < ::Rack::Server
```

`fileutils` и `optparse` - это стандартные библиотеки Ruby, представляющие вспомогательные функции для работы с файлами и парсинга опций.

### `actionpack/lib/action_dispatch.rb`

Action Dispatch - это компонент маршрутизации фреймворка Rails. Он добавляет такой функционал, как роутинг, сессию и промежуточные программы.

### `rails/commands/server.rb`

Класс `Rails::Server` определен в этом файле, как унаследованный от `Rack::Server`. Когда вызывается `Rails::Server.new`, вызывается метод `initialize` в `rails/commands/server.rb`:

```ruby
def initialize(*)
  super
  set_environment
end
```

Сперва вызывается `super`, что вызывает метод `initialize` у `Rack::Server`.

### Rack: `lib/rack/server.rb`

`Rack::Server` ответственен за представление обычного интерфейса сервера для всех приложений, основанных на Rack, частью которых сейчас является Rails.

Метод `initialize` в `Rack::Server` просто устанавливает ряд переменных:

```ruby
def initialize(options = nil)
  @options = options
  @app = options[:app] if options && options[:app]
end
```

В нашем случае, `options` будут `nil`, поэтому в этом методе ничего не происходит.

После завершения `super` в `Rack::Server`, мы возвращаемся в `rails/commands/server.rb`. Далее вызывается `set_environment` в контексте объекта `Rails::Server`, и этот метод, на первый взгляд, не делает слишком многого:

```ruby
def set_environment
  ENV["RAILS_ENV"] ||= options[:environment]
end
```

Фактически, метод `options` отсюда делает достаточно много. Этот метод определен в `Rack::Server` следующим образом:

```ruby
def options
  @options ||= parse_options(ARGV)
end
```

Далее, `parse_options` определен следующим образом:

```ruby
def parse_options(args)
  options = default_options

  # Don't evaluate CGI ISINDEX parameters.
  # http://hoohoo.ncsa.uiuc.edu/cgi/cl.html
  args.clear if ENV.include?("REQUEST_METHOD")

  options.merge! opt_parser.parse! args
  options[:config] = ::File.expand_path(options[:config])
  ENV["RACK_ENV"] = options[:environment]
  options
end
```

И `default_options` установлены так:

```ruby
def default_options
  {
    :environment => ENV['RACK_ENV'] || "development",
    :pid         => nil,
    :Port        => 9292,
    :Host        => "0.0.0.0",
    :AccessLog   => [],
    :config      => "config.ru"
  }
end
```

Ключа `REQUEST_METHOD` нет в `ENV`, поэтому можно пропустить следующую строчку. Последующие строчки сливают опции из `opt_parser`, который также определен в `Rack::Server`

```ruby
def opt_parser
  Options.new
end
```

Класс опций **опеределен** в `Rack::Server`, но переопределен в `Rails::Server`, чтобы он мог принимать различные аргументы. Его метод `parse!` начинается со следующего:

```ruby
def parse!(args)
  args, options = args.dup, {}

  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: rails server [mongrel, thin, etc] [options]"
    opts.on("-p", "--port=port", Integer,
            "Runs Rails on the specified port.", "Default: 3000") { |v| options[:Port] = v }
  ...
```

Этот метод установит ключи для `options`, которые затем будут доступны Rails для определения того, как должен быть запущен его сервер. После того, как `initialize` будет закончен, мы вернемся обратно в `rails/server`, где требуется `APP_PATH` (который был установлен ранее).

### `config/application`

При выполнении `require APP_PATH` будет загружен `config/application.rb`. Этот файл находится в вашем приложении, и вы свободно можете изменять его под свои нужды.

### `Rails::Server#start`

После загрузки `config/application` вызывается `server.start`. Этот метод определен следующим образом:

```ruby
def start
  url = "#{options[:SSLEnable] ? 'https' : 'http'}://#{options[:Host]}:#{options[:Port]}"
  puts "=> Booting #{ActiveSupport::Inflector.demodulize(server)}"
  puts "=> Rails #{Rails.version} application starting in #{Rails.env} on #{url}"
  puts "=> Run `rails server -h` for more startup options"
  trap(:INT) { exit }
  puts "=> Ctrl-C to shutdown server" unless options[:daemonize]

  #Create required tmp directories if not found
  %w(cache pids sessions sockets).each do |dir_to_make|
    FileUtils.mkdir_p(Rails.root.join('tmp', dir_to_make))
  end

  unless options[:daemonize]
    wrapped_app # touch the app so the logger is set up

    console = ActiveSupport::Logger.new($stdout)
    console.formatter = Rails.logger.formatter

    Rails.logger.extend(ActiveSupport::Logger.broadcast(console))
  end

  super
ensure
  # The '-h' option calls exit before @options is set.
  # If we call 'options' with it unset, we get double help banners.
  puts 'Exiting' unless @options && options[:daemonize]
end
```

Это то место, где происходит первый вывод на экран при инициализации Rails. Этот метод создает ловушку (trap) для сигналов `INT`, поэтому, при нажатии  `CTRL-C`, сервер завершит процесс. Как видим дальше по коду, он создает директории `tmp/cache`, `tmp/pids`, `tmp/sessions` и `tmp/sockets`. Затем он вызывает `wrapped_app`, который ответственен за создание приложения Rack, а затем создает и присваивает экземпляр `ActiveSupport::Logger`.

Метод `super` вызовет `Rack::Server.start`, определение которого выглядит так:

```ruby
def start &blk
  if options[:warn]
    $-w = true
  end

  if includes = options[:include]
    $LOAD_PATH.unshift(*includes)
  end

  if library = options[:require]
    require library
  end

  if options[:debug]
    $DEBUG = true
    require 'pp'
    p options[:server]
    pp wrapped_app
    pp app
  end

  check_pid! if options[:pid]

  # Touch the wrapped app, so that the config.ru is loaded before
  # daemonization (i.e. before chdir, etc).
  wrapped_app

  daemonize_app if options[:daemonize]

  write_pid if options[:pid]

  trap(:INT) do
    if server.respond_to?(:shutdown)
      server.shutdown
    else
      exit
    end
  end

  server.run wrapped_app, options, &blk
end
```

Самой интересной частью для приложения Rails является последняя строчка, `server.run`. Здесь мы снова сталкиваемся с методом `wrapped_app`, но на этот раз мы собираемся копнуть глубже (несмотря на то, что он уже был запущен ранее, и поэтому сейчас возвратится просто запомненный результат).

```ruby
@wrapped_app ||= build_app app
```

Метод `app` отсюда определен так:

```ruby
def app
  @app ||= begin
    if !::File.exist? options[:config]
      abort "configuration #{options[:config]} not found"
    end

    app, options = Rack::Builder.parse_file(self.options[:config], opt_parser)
    self.options.merge! options
    app
  end
end
```

Значение по умолчанию `options[:config]` - это `config.ru`, содержащий следующее:

```ruby
# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run <%= app_const %>
```

Метод `Rack::Builder.parse_file` принимает содержимое этого файла `config.ru` и парсит его, используя следующий код:

```ruby
app = eval "Rack::Builder.new {( " + cfgfile + "\n )}.to_app",
    TOPLEVEL_BINDING, config
```

Метод `initialize` из `Rack::Builder` принимает блок и выполняет его в рамках экземпляра `Rack::Builder`. Это то место, в котором происходит большая часть процесса инициализации Rails. Сперва запускается строчка `require` для `config/environment.rb` в `config.ru`:

```ruby
require ::File.expand_path('../config/environment',  __FILE__)
```

### `config/environment.rb`

Этот файл является общим файлом, требуемым и `config.ru` (`rails server`), и Passenger. Тут встречаются два способа, как можно запустить сервер; все, что было до этой точки - была настройка Rack и Rails.

Этот файл начинается с затребования `config/application.rb`.

### `config/application.rb`

Этот файл требует `config/boot.rb`, но только если он не был затребован ранее, что уже было сделано в случае с `rails server`, но **не делалось** в случае с Passenger.

Дальше начинается веселье!

Загрузка Rails
-------------

Следующей строчкой в `config/application.rb` является:

```ruby
require 'rails/all'
```

### `railties/lib/rails/all.rb`

Этот файл ответственен за подключение всех отдельных фреймворков Rails:

```ruby
require "rails"

%w(
    active_record
    action_controller
    action_mailer
    rails/test_unit
    sprockets
).each do |framework|
  begin
    require "#{framework}/railtie"
  rescue LoadError
  end
end
```

Это то место, где загружаются все фреймворки Rails и, поэтому, становятся доступны для приложения. Мы не будем вдаваться в подробности, что именно происходит внутри каждого фреймворка, но вы можете попробовать исследовать их самостоятельно.

Сейчас просто держите в памяти, что весь обычный функционал, такой как Rails engines, I18n и конфигурация Rails, определен тут.

### Возвращаемся в `config/environment.rb`

Когда `config/application.rb` закончит загружать Rails и определит пространство имен приложения, вы вернетесь в `config/environment.rb`, где инициализируется ваше приложение. Например, если ваше приложение называется `Blog`, тут вы обнаружите `Blog::Application.initialize!`, который определен в `rails/application.rb`

### `railties/lib/rails/application.rb`

Метод `initialize!` выглядит так:

```ruby
def initialize!(group=:default) #:nodoc:
  raise "Application has been already initialized." if @initialized
  run_initializers(group, self)
  @initialized = true
  self
end
```

Как видите, инициализировать приложение можно лишь единожды. Также тут запускаются инициализаторы.

Код инициализаторов сам по себе является сложным. Тут Rails проходит всех предков класса, ищет метод `initializers`, сортирует и запускает их. Например, класс `Engine` делает доступными все engine, предоставляя метод `initializers`.

После того, как это закончится, мы вернемся в `Rack::Server`

### Rack: lib/rack/server.rb

В прошлый раз мы ушли отсюда, когда был вызван метод `app`:

```ruby
def app
  @app ||= begin
    if !::File.exist? options[:config]
      abort "configuration #{options[:config]} not found"
    end

    app, options = Rack::Builder.parse_file(self.options[:config], opt_parser)
    self.options.merge! options
    app
  end
end
```

В этом месте `app` - это само приложение Rails (промежуточная программа, middleware), и дальше происходит то, что Rack вызывает все представленные промежуточные программы:

```ruby
def build_app(app)
  middleware[options[:environment]].reverse_each do |middleware|
    middleware = middleware.call(self) if middleware.respond_to?(:call)
    next unless middleware
    klass = middleware.shift
    app = klass.new(app, *middleware)
  end
  app
end
```

Помните, что `build_app` был вызван (из wrapped_app) в последней строчке `Server#start`? Вот как она выглядела:

```ruby
server.run wrapped_app, options, &blk
```

С этого момента реализация `server.run` будет зависеть от используемого вами сервера. Например, при использовании Mongrel вот как выглядит метод `run`:

```ruby
def self.run(app, options={})
  server = ::Mongrel::HttpServer.new(
    options[:Host]           || '0.0.0.0',
    options[:Port]           || 8080,
    options[:num_processors] || 950,
    options[:throttle]       || 0,
    options[:timeout]        || 60)
  # Acts like Rack::URLMap, utilizing Mongrel's own path finding methods.
  # Use is similar to #run, replacing the app argument with a hash of
  # { path=>app, ... } or an instance of Rack::URLMap.
  if options[:map]
    if app.is_a? Hash
      app.each do |path, appl|
        path = '/'+path unless path[0] == ?/
        server.register(path, Rack::Handler::Mongrel.new(appl))
      end
    elsif app.is_a? URLMap
      app.instance_variable_get(:@mapping).each do |(host, path, appl)|
       next if !host.nil? && !options[:Host].nil? && options[:Host] != host
       path = '/'+path unless path[0] == ?/
       server.register(path, Rack::Handler::Mongrel.new(appl))
      end
    else
      raise ArgumentError, "first argument should be a Hash or URLMap"
    end
  else
    server.register('/', Rack::Handler::Mongrel.new(app))
  end
  yield server  if block_given?
  server.run.join
end
```

Мы не будем погружаться в саму конфигурацию сервера, но это последняя часть нашего путешествия в процесс инициализации Rails.

Надеемся, что этот поверхностный обзор помог вам понять, когда и как будет выполнен ваш код, и вцелом стать более хорошим разработчиком на Rails. Если вы хотите узнать больше, лучшим источником для дальнейшего изучения будет являться сам исходный код Rails.
