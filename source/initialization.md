Процесс инициализации в Rails
=============================

Это руководство объясняет внутренние процессы инициализации в Rails. Это достаточно углубленное руководство, оно рекомендовано для продвинутых разработчиков на Rails.

После прочтения этого руководства вы узнаете:

* Как использовать `bin/rails server`.
* График инициализации Rails.
* Когда различные файлы подключаются в процессе загрузки.
* Как определен и используется интерфейс Rails::Server.

Это руководство рассмотрит каждый вызов методов, требуемых для загрузки стека Ruby on Rails для нового приложения на Rails, объяснив подробно каждую встреченную часть кода. Для целей этого руководства мы сосредоточимся на том, что произойдет при выполнении `bin/rails server` для загрузки вашего приложения.

NOTE: Пути в этом руководстве указаны относительно Rails или приложения Rails, если не оговорено иное.

TIP: Если желаете параллельно чтению просматривать [исходный код Rails](https://github.com/rails/rails), мы рекомендуем использовать горячую клавишу `t`, чтобы открыть быстрый поиск файлов на GitHub.

Поехали!
--------

Давайте загрузим и инициализируем приложение. Приложение Rails обычно стартует с помощью запуска `bin/rails console` или `bin/rails server`.

### `bin/rails`

Этот файл содержит следующее:

```ruby
#!/usr/bin/env ruby
APP_PATH = File.expand_path('../config/application', __dir__)
require_relative "../config/boot"
require "rails/commands"
```

Константа `APP_PATH` будет использована позже в `rails/commands`. Файл `config/boot`, упомянутый тут, это файл `config/boot.rb` нашего приложения, который ответственен за загрузку Bundler и его настройку.

### `config/boot.rb`

`config/boot.rb` содержит:

```ruby
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
```

В стандартном приложении Rails имеется `Gemfile`, объявляющий все зависимости приложения. `config/boot.rb` устанавливает `ENV['BUNDLE_GEMFILE']` как место расположения этого файла. Затем, если `Gemfile` существует, будет затребован `bundler/setup`. Строка используется Bundler-ом для настройки путей загрузки для зависимостей вашего `Gemfile`.

Стандартное Rails приложение зависит от нескольких гемов, а именно:

* actioncable
* actionmailer
* actionpack
* actionview
* activejob
* activemodel
* activerecord
* activestorage
* activesupport
* actionmailbox
* actiontext
* arel
* builder
* bundler
* erubi
* i18n
* mail
* mime-types
* rack
* rack-test
* rails
* railties
* rake
* sqlite3
* thor
* tzinfo

### `rails/commands.rb`

Как только завершится `config/boot.rb`, следующим файлом, который будет затребован, является `rails/commands`, который помогает расширить псевдонимы. В нашем случае, массив `ARGV` просто содержит `server`, который будет передан дальше:

```ruby
require "rails/command"

aliases = {
  "g"  => "generate",
  "d"  => "destroy",
  "c"  => "console",
  "s"  => "server",
  "db" => "dbconsole",
  "r"  => "runner",
  "t"  => "test"
}

command = ARGV.shift
command = aliases[command] || command

Rails::Command.invoke command, ARGV
```

Если бы мы использовали `s` вместо `server`, Rails использовал бы определенные тут псевдонимы `aliases` для поиска соответствующей команды.

### `rails/command.rb`

Когда кто-то вводит команду Rails, `invoke` пытается найти команду для данного пространства имен и выполняет команду, если она найдена.

Как показано, `Rails::Command` выводит справку автоматически, если `namespace` пустой.

```ruby
module Rails
  module Command
    class << self
      def invoke(full_namespace, args = [], **config)
        namespace = full_namespace = full_namespace.to_s

        if char = namespace =~ /:(\w+)$/
          command_name, namespace = $1, namespace.slice(0, char)
        else
          command_name = namespace
        end

        command_name, namespace = "help", "help" if command_name.blank? || HELP_MAPPINGS.include?(command_name)
        command_name, namespace = "version", "version" if %w( -v --version ).include?(command_name)

        command = find_by_namespace(namespace, command_name)
        if command && command.all_commands[command_name]
          command.perform(command_name, args, config)
        else
          find_by_namespace("rake").perform(full_namespace, args, config)
        end
      end
    end
  end
end
```

С помощью команды `server` Rails далее запустит следующий код:

```ruby
module Rails
  module Command
    class ServerCommand < Base # :nodoc:
      def perform
        extract_environment_option_from_argument
        set_application_directory!
        prepare_restart

        Rails::Server.new(server_options).tap do |server|
          # Require application after server sets environment to propagate
          # the --environment option.
          require APP_PATH
          Dir.chdir(Rails.application.root)

          if server.serveable?
            print_boot_information(server.server, server.served_url)
            after_stop_callback = -> { say "Exiting" unless options[:daemon] }
            server.start(after_stop_callback)
          else
            say rack_server_suggestion(using)
          end
        end
      end
    end
  end
end
```

Этот файл изменит корень директории (путь на две директории выше `APP_PATH`, указывающего на `config/application.rb`), но только если не найден файл `config.ru`. Затем он запускает класс `Rails::Server`.

### `actionpack/lib/action_dispatch.rb`

Action Dispatch - это компонент маршрутизации фреймворка Rails. Он добавляет такую функциональность, как роутинг, сессию и промежуточные программы.

### `rails/commands/server/server_command.rb`

Класс `Rails::Server` определен в этом файле, как унаследованный от `Rack::Server`. Когда вызывается `Rails::Server.new`, вызывается метод `initialize` в `rails/commands/server/server_command.rb`:

```ruby
module Rails
  class Server < ::Rack::Server
    def initialize(options = nil)
      @default_options = options || {}
      super(@default_options)
      set_environment
    end
  end
end
```

Сперва вызывается `super`, что вызывает метод `initialize` у `Rack::Server`.

### Rack: `lib/rack/server.rb`

`Rack::Server` ответственен за представление обычного интерфейса сервера для всех приложений, основанных на Rack, частью которых сейчас является Rails.

Метод `initialize` в `Rack::Server` просто устанавливает несколько переменных:

```ruby
module Rack
  class Server
    def initialize(options = nil)
      @ignore_options = []

      if options
        @use_default_options = false
        @options = options
        @app = options[:app] if options[:app]
      else
        argv = defined?(SPEC_ARGV) ? SPEC_ARGV : ARGV
        @use_default_options = true
        @options = parse_options(argv)
      end
    end
  end
end
```

В этом случае возвращаемое `Rails::Command::ServerCommand#server_options` значение будет присвоено `options`. Когда вычисляются строчки в выражении if, будет установлено ряд переменных экземпляра.

Метод `server_options` в `Rails::Command::ServerCommand` определен следующим образом:

```ruby
module Rails
  module Command
    class ServerCommand
      no_commands do
        def server_options
          {
            user_supplied_options: user_supplied_options,
            server:                using,
            log_stdout:            log_to_stdout?,
            Port:                  port,
            Host:                  host,
            DoNotReverseLookup:    true,
            config:                options[:config],
            environment:           environment,
            daemonize:             options[:daemon],
            pid:                   pid,
            caching:               options[:dev_caching],
            restart_cmd:           restart_command,
            early_hints:           early_hints
          }
        end
      end
    end
  end
end
```

Значение будет присвоено переменной экземпляра `@options`.

После завершения `super` в `Rack::Server`, мы возвращаемся в `rails/commands/server/server_command.rb`. Здесь вызывается `set_environment` в контексте объекта `Rails::Server`.

```ruby
module Rails
  module Server
    def set_environment
      ENV["RAILS_ENV"] ||= options[:environment]
    end
  end
end
```

После того, как `initialize` будет закончен, мы вернемся обратно к серверной команде, где требуется `APP_PATH` (который был установлен ранее).

### `config/application`

При выполнении `require APP_PATH` будет загружен `config/application.rb` (напоминаем, что `APP_PATH` определен в `bin/rails`). Этот файл находится в вашем приложении, и вы свободно можете изменять его под свои нужды.

### `Rails::Server#start`

После загрузки `config/application` вызывается `server.start`. Этот метод определен следующим образом:

```ruby
module Rails
  class Server < ::Rack::Server
    def start(after_stop_callback = nil)
      trap(:INT) { exit }
      create_tmp_directories
      setup_dev_caching
      log_to_stdout if options[:log_stdout]

      super()
      # ...
    end

    private
      def setup_dev_caching
        if options[:environment] == "development"
          Rails::DevCaching.enable_by_argument(options[:caching])
        end
      end

      def create_tmp_directories
        %w(cache pids sockets).each do |dir_to_make|
          FileUtils.mkdir_p(File.join(Rails.root, "tmp", dir_to_make))
        end
      end

      def log_to_stdout
        wrapped_app # touch the app so the logger is set up

        console = ActiveSupport::Logger.new(STDOUT)
        console.formatter = Rails.logger.formatter
        console.level = Rails.logger.level

        unless ActiveSupport::Logger.logger_outputs_to?(Rails.logger, STDOUT)
          Rails.logger.extend(ActiveSupport::Logger.broadcast(console))
        end
      end
  end
end
```

Этот метод создает ловушку (trap) для сигналов `INT`, поэтому, при нажатии `CTRL-C`, сервер завершит процесс. Как видим дальше по коду, он создает директории `tmp/cache`, `tmp/pids` и `tmp/sockets`. Затем он включает кэширование в development, если `bin/rails server` вызывается с `--dev-caching`. Наконец, он вызывает `wrapped_app`, который ответственен за создание приложения Rack, а затем создает и присваивает экземпляр `ActiveSupport::Logger`.

Метод `super` вызовет `Rack::Server.start`, который определяется следующим образом:

```ruby
module Rack
  class Server
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
        require "pp"
        p options[:server]
        pp wrapped_app
        pp app
      end

      check_pid! if options[:pid]

      # Touch the wrapped app, so that the config.ru is loaded before
      # daemonization (i.e. before chdir, etc).
      handle_profiling(options[:heapfile], options[:profile_mode], options[:profile_file]) do
        wrapped_app
      end

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
  end
end
```

Самой интересной частью для приложения Rails является последняя строчка, `server.run`. Здесь мы снова сталкиваемся с методом `wrapped_app`, но на этот раз мы собираемся копнуть глубже (несмотря на то, что он уже был выполнен ранее, и поэтому сейчас возвратится просто запомненный результат).

```ruby
module Rack
  class Server
    def wrapped_app
      @wrapped_app ||= build_app app
    end
  end
end
```

Метод `app` отсюда определен так:

```ruby
module Rack
  class Server
    def app
      @app ||= options[:builder] ? build_app_from_string : build_app_and_options_from_config
    end

    # ...

    private
      def build_app_and_options_from_config
        if !::File.exist? options[:config]
          abort "configuration #{options[:config]} not found"
        end

        app, options = Rack::Builder.parse_file(self.options[:config], opt_parser)
        @options.merge!(options) { |key, old, new| old }
        app
      end

      def build_app_from_string
        Rack::Builder.new_from_string(self.options[:builder])
      end
  end
end
```

Значение по умолчанию `options[:config]` - это `config.ru`, содержащий следующее:

```ruby
# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
```

Метод `Rack::Builder.parse_file` принимает содержимое этого файла `config.ru` и парсит его, используя следующий код:

```ruby
module Rack
  class Builder
    def self.load_file(path, opts = Server::Options.new)
      # ...
      app = new_from_string cfgfile, config
      # ...
    end

    # ...

    def self.new_from_string(builder_script, file="(rackup)")
      eval "Rack::Builder.new {\n" + builder_script + "\n}.to_app",
        TOPLEVEL_BINDING, file, 0
    end
  end
end
```

Метод `initialize` из `Rack::Builder` принимает блок и выполняет его в рамках экземпляра `Rack::Builder`. Это то место, в котором происходит большая часть процесса инициализации Rails. Сперва запускается строчка `require` для `config/environment.rb` в `config.ru`:

```ruby
require_relative "config/environment"
```

### `config/environment.rb`

Этот файл является общим файлом, требуемым и `config.ru` (`bin/rails server`), и Passenger. Тут встречаются два способа, как можно запустить сервер; все, что было до этой точки - была настройка Rack и Rails.

Этот файл начинается с затребования `config/application.rb`:

```ruby
require_relative "application"
```

### `config/application.rb`

Этот файл требует `config/boot.rb`:

```ruby
require_relative "boot"
```

Но только если он не был затребован ранее, что уже было сделано в случае с `bin/rails server`, но **не делалось** в случае с Passenger.

Дальше начинается веселье!

Загрузка Rails
-------------

Следующей строчкой в `config/application.rb` является:

```ruby
require "rails/all"
```

### `railties/lib/rails/all.rb`

Этот файл ответственен за подключение всех отдельных фреймворков Rails:

```ruby
require "rails"

%w(
  active_record/railtie
  active_storage/engine
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  action_cable/engine
  action_mailbox/engine
  action_text/engine
  rails/test_unit/railtie
  sprockets/railtie
).each do |railtie|
  begin
    require railtie
  rescue LoadError
  end
end
```

Это то место, где загружаются все фреймворки Rails и, поэтому, становятся доступны для приложения. Мы не будем вдаваться в подробности, что именно происходит внутри каждого фреймворка, но вы можете попробовать исследовать их самостоятельно.

Сейчас просто держите в памяти, что вся обычная функциональность, такая как Rails engines, I18n и конфигурация Rails, определена тут.

### Возвращаемся в `config/environment.rb`

Оставшаяся часть `config/application.rb` определяет конфигурацию для `Rails::Application`, которая будет единожды использована после того, как приложение полностью инициализируется. Когда `config/application.rb` закончит загружать Rails и определит пространство имен приложения, вы вернетесь в `config/environment.rb`. Здесь инициализируется приложение с помощью `Rails.application.initialize!`, который определен в `rails/application.rb`

### `railties/lib/rails/application.rb`

Метод `initialize!` выглядит так:

```ruby
def initialize!(group = :default) #:nodoc:
  raise "Application has been already initialized." if @initialized
  run_initializers(group, self)
  @initialized = true
  self
end
```

Инициализировать приложение можно лишь единожды. [Инициализаторы Railtie](/configuring-rails-applications#initializers) запускаются с помощью метода `run_initializers`, который определен в `railties/lib/rails/initializable.rb`:

```ruby
def run_initializers(group = :default, *args)
  return if instance_variable_defined?(:@ran)
  initializers.tsort_each do |initializer|
    initializer.run(*args) if initializer.belongs_to?(group)
  end
  @ran = true
end
```

Код `run_initializers` сам по себе является сложным. Тут Rails проходит всех предков класса, ищет тех, кто отвечает на метод `initializers`. Затем он сортирует предков по имени и запускает. Например, класс `Engine` делает доступными все engine, предоставляя в нем метод `initializers`.

Класс `Rails::Application`, как определено в `railties/lib/rails/application.rb`, определяет инициализаторы `bootstrap`, `railtie` и `finisher`. Инициализаторы `bootstrap` подготавливает приложение (такие как инициализатор логгера), в то время как инициализаторы `finisher` (такие как создание стека промежуточных программ) запускаются последними. Инициализаторы `railtie` – это инициализаторы, которые определены самим `Rails::Application` и запускаются между `bootstrap` и `finisher`.

*Note:* Не путайте общие инициализаторы Railtie с экземпляром инициализатора [load_config_initializers](/configuring-rails-applications#initialization) или связанные с ним инициализаторами конфигурации в `config/initializers`.

После того, как это закончится, мы вернемся в `Rack::Server`.

### Rack: lib/rack/server.rb

В прошлый раз мы ушли отсюда, когда был вызван метод `app`:

```ruby
module Rack
  class Server
    def app
      @app ||= options[:builder] ? build_app_from_string : build_app_and_options_from_config
    end

    # ...

    private
      def build_app_and_options_from_config
        if !::File.exist? options[:config]
          abort "configuration #{options[:config]} not found"
        end

        app, options = Rack::Builder.parse_file(self.options[:config], opt_parser)
        @options.merge!(options) { |key, old, new| old }
        app
      end

      def build_app_from_string
        Rack::Builder.new_from_string(self.options[:builder])
      end
  end
end
```

В этом месте `app` - это само приложение Rails (промежуточная программа, middleware), и дальше происходит то, что Rack вызывает все представленные промежуточные программы:

```ruby
module Rack
  class Server
    private
      def build_app(app)
        middleware[options[:environment]].reverse_each do |middleware|
          middleware = middleware.call(self) if middleware.respond_to?(:call)
          next unless middleware
          klass, *args = middleware
          app = klass.new(app, *args)
        end
        app
      end
  end
end
```

Помните, что `build_app` был вызван (из `wrapped_app`) в последней строчке `Rack::Server#start`? Вот как она выглядела:

```ruby
server.run wrapped_app, options, &blk
```

С этого момента реализация `server.run` будет зависеть от используемого вами сервера. Например, при использовании Puma вот как выглядит метод `run`:

```ruby
...
module Rack
  module Handler
    module Puma
      # ...
      def self.run(app, options = {})
        conf   = self.config(app, options)

        events = options.delete(:Silent) ? ::Puma::Events.strings : ::Puma::Events.stdio

        launcher = ::Puma::Launcher.new(conf, :events => events)

        yield launcher if block_given?
        begin
          launcher.run
        rescue Interrupt
          puts "* Gracefully stopping, waiting for requests to finish"
          launcher.stop
          puts "* Goodbye!"
        end
      end
      # ...
    end
  end
end
```

Мы не будем погружаться в саму конфигурацию сервера, но это последняя часть нашего путешествия в процесс инициализации Rails.

Надеемся, что этот поверхностный обзор помог вам понять, когда и как будет выполнен ваш код, и в целом стать более хорошим разработчиком на Rails. Если вы хотите узнать больше, лучшим источником для дальнейшего изучения будет являться сам исходный код Rails.
