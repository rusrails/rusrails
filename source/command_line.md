Командная строка Rails
======================

В Rails имеются все необходимые вам инструменты командной строки.

После прочтения этого руководства, вы узнаете

* Как создать приложение на Rails
* Как создать модели, контроллеры, миграции базы данных и юнит-тесты
* Как запустить сервер для разработки
* Как экспериментировать с объектами в интерактивной оболочке
* Как профилировать и тестировать ваше новое творение

NOTE: Этот самоучитель предполагает, что вы обладаете знаниями основ Rails, которые можно почерпнуть в [руководстве Rails для начинающих](/getting-started-with-rails).

Основы командной строки
-----------------------

Имеется несколько команд, абсолютно критичных для повседневного использования в Rails. В порядке возможной частоты использования, они следующие:

* `rails console`
* `rails server`
* `rake`
* `rails generate`
* `rails dbconsole`
* `rails new app_name`

Давайте создадим простое приложение на Rails, чтобы рассмотреть все эти команды в контексте.

### `rails new`

Сперва мы хотим создать новое приложение на Rails, запустив команду `rails new` после установки Rails.

INFO: Гем rails можно установить, написав `gem install rails`, если его еще нет.

```bash
$ rails new commandsapp
     create
     create  README.rdoc
     create  Rakefile
     create  config.ru
     create  .gitignore
     create  Gemfile
     create  app
     ...
     create  tmp/cache
     ...
        run  bundle install
```

Rails создаст кучу всего с помощью такой маленькой команды! Теперь вы получили готовую структуру директории Rails со всем кодом, необходимым для запуска нашего простого приложения.

### `rails server`

Команда `rails server` запускает небольшой веб сервер, названный WEBrick, поставляемый с Ruby. Его будем использовать всякий раз, когда захотим увидеть свою работу в веб браузере.

INFO: WEBrick не единственный выбор для обслуживания Rails. Мы вернемся к этому в следующем разделе.

Безо всякого принуждения, `rails server` запустит наше блестящее приложение на Rails:

```bash
$ cd commandsapp
$ rails server
=> Booting WEBrick
=> Rails 3.2.3 application starting in development on http://0.0.0.0:3000
=> Call with -d to detach
=> Ctrl-C to shutdown server
[2012-05-28 00:39:41] INFO  WEBrick 1.3.1
[2012-05-28 00:39:41] INFO  ruby 1.9.2 (2011-02-18) [x86_64-darwin11.2.0]
[2012-05-28 00:39:41] INFO  WEBrick::HTTPServer#start: pid=69680 port=3000
```

Всего лишь тремя командами мы развернули сервер Rails, прослушивающий порт 3000. Перейдите в браузер и зайдите на [http://localhost:3000](http://localhost:3000), вы увидите простое приложение, запущенное на rails.

INFO: Для запуска сервера также можно использовать псевдоним "s": `rails s`.

Сервер может быть запущен на другом порту, при использовании опции `-p`. Среда по умолчанию может быть изменена с использованием `-e`.

```bash
$ rails server -e production -p 4000
```

Опция `-b` привязывает Rails к определенному IP, по умолчанию это 0.0.0.0. Можете запустить сервер, как демона, передав опцию `-d`.

### `rails generate`

Команда `rails generate` использует шаблоны для создания целой кучи вещей. Запуск `rails generate` выдаст список доступных генераторов:

INFO: Также можно использовать псевдоним "g" для вызова команды `generate`: `rails g`.

```bash
$ rails generate
Usage: rails generate GENERATOR [args] [options]

...
...

Please choose a generator below.

Rails:
  assets
  controller
  generator
  ...
  ...
```

NOTE: Можно установить больше генераторов с помощью генераторных гемов, части плагинов, которые вы, несомненно, установите, и даже можете создать свой собственный!

Использование генераторов поможет сэкономить много времени, написав за вас **шаблонный код** - необходимый для работы приложения.

Давайте создадим свой собственный контроллер с помощью генератора контроллера. Какую же команду использовать? Давайте спросим у генератора:

INFO: Все консольные утилиты Rails имеют текст помощи. Как и с большинством утилит *NIX, можно попробовать `--help` или `-h` в конце, например `rails server --help`.

```bash
$ rails generate controller
Usage: rails generate controller NAME [action action] [options]

...
...

Description:
    ...

    To create a controller within a module, specify the controller name as a
    path like 'parent_module/controller_name'.

    ...

Example:
    `rails generate controller CreditCard open debit credit close`

    Credit card controller with URLs like /credit_card/debit.
        Controller: app/controllers/credit_card_controller.rb
        Test:       test/controllers/credit_card_controller_test.rb
        Views:      app/views/credit_card/debit.html.erb [...]
        Helper:     app/helpers/credit_card_helper.rb
```

Генератор контроллера ожидает параметры в форме `generate controller ControllerName action1 action2`. Давайте создадим контроллер `Greetings` с экшном **hello**, который скажет нам что-нибудь приятное.

```bash
$ rails generate controller Greetings hello
     create  app/controllers/greetings_controller.rb
     route  get "greetings/hello"
     invoke  erb
     create    app/views/greetings
     create    app/views/greetings/hello.html.erb
     invoke  test_unit
     create    test/controllers/greetings_controller_test.rb
     invoke  helper
     create    app/helpers/greetings_helper.rb
     invoke    test_unit
     create      test/helpers/greetings_helper_test.rb
     invoke  assets
     invoke    coffee
     create      app/assets/javascripts/greetings.js.coffee
     invoke    scss
     create      app/assets/stylesheets/greetings.css.scss
```

Что создалось? Создался ряд директорий в нашем приложении, и создались файл контроллера, файл вьюхи, файл функционального теста, хелпер для вьюхи, файл JavaScript и файл таблицы стилей.

Давайте проверим наш контроллер и немного его изменим (в `app/controllers/greetings_controller.rb`):

```ruby
class GreetingsController < ApplicationController
  def hello
    @message = "Hello, how are you today?"
  end
end
```

Затем вьюху для отображения нашего сообщения (в `app/views/greetings/hello.html.erb`):

```html+erb
<h1>A Greeting for You!</h1>
<p><%= @message %></p>
```

Запустим сервер с помощью `rails server`.

```bash
$ rails server
=> Booting WEBrick...
```

URL должен быть [http://localhost:3000/greetings/hello](http://localhost:3000/greetings/hello).

INFO: В нормальном старом добром приложении на Rails, ваши URL будут создаваться по образцу http://(host)/(controller)/(action), и URL, подобный такому http://(host)/(controller), вызовет экшн **index** этого контроллера.

В Rails также есть генератор для моделей данных.

```bash
$ rails generate model
Usage:
  rails generate model NAME [field[:type][:index] field[:type][:index]] [options]

...

ActiveRecord options:
      [--migration]            # Indicates when to generate migration
                               # Default: true

...

Description:
    Create rails files for model generator.
```

NOTE: Список доступных типов полей можно узнать в [документации API](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html#method-i-column) для метода column класса `TableDefinition`

Но вместо создания модели непосредственно (что мы сделаем еще позже), давайте установим скаффолд. **Скаффолд** в Rails это полный набор из модели, миграции базы данных для этой модели, контроллер для воздействия на нее, вьюхи для просмотра и обращения с данными и тестовый набор для всего этого.

Давайте настроим простой ресурс, названный "HighScore", который будет отслеживать наши лучшие результаты в видеоиграх, в которые мы играли.

```bash
$ rails generate scaffold HighScore game:string score:integer
    invoke  active_record
    create    db/migrate/20120528060026_create_high_scores.rb
    create    app/models/high_score.rb
    invoke    test_unit
    create      test/models/high_score_test.rb
    create      test/fixtures/high_scores.yml
    invoke  resource_route
     route    resources :high_scores
    invoke  scaffold_controller
    create    app/controllers/high_scores_controller.rb
    invoke    erb
    create      app/views/high_scores
    create      app/views/high_scores/index.html.erb
    create      app/views/high_scores/edit.html.erb
    create      app/views/high_scores/show.html.erb
    create      app/views/high_scores/new.html.erb
    create      app/views/high_scores/_form.html.erb
    invoke    test_unit
    create      test/controllers/high_scores_controller_test.rb
    invoke    helper
    create      app/helpers/high_scores_helper.rb
    invoke      test_unit
    create        test/helpers/high_scores_helper_test.rb
    invoke  assets
    invoke    coffee
    create      app/assets/javascripts/high_scores.js.coffee
    invoke    scss
    create      app/assets/stylesheets/high_scores.css.scss
    invoke  scss
    create    app/assets/stylesheets/scaffolds.css.scss
```

Генератор проверил, что существуют директории для моделей, контроллеров, хелперов, макетов, функциональных и юнит тестов, таблиц стилей, создал вьюхи, контроллер, модель и миграцию базы данных для HighScore (создающую таблицу `high_scores` и поля), позаботился о маршруте для *ресурса*, и создал новые тесты для всего этого.

Миграция требует, чтобы мы **мигрировали ее**, то есть запустили некоторый код Ruby (находящийся в этом `20120528060026_create_high_scores.rb`), чтобы изменить схему базы данных. Какой базы данных? Базы данных sqlite3, которую создаст Rails, когда мы запустим команду `rake db:migrate`. Поговорим о Rake чуть позже.

```bash
$ rake db:migrate
==  CreateHighScores: migrating ===============================================
-- create_table(:high_scores)
   -> 0.0017s
==  CreateHighScores: migrated (0.0019s) ======================================
```

INFO: Давайте поговорим об юнит тестах. Юнит тесты это код, который тестирует и делает суждения о коде. В юнит тестировании мы берем часть кода, скажем, метод модели, и тестируем его входы и выходы. Юнит тесты ваши друзья. Чем раньше вы смиритесь с фактом, что качество жизни возрастет, когда станете юнит тестировать свой код, тем лучше. Серьезно. Мы сделаем один через мгновение.

Давайте взглянем на интерфейс, который Rails создал для нас.

```bash
$ rails server
```

Перейдите в браузер и откройте [http://localhost:3000/high_scores](http://localhost:3000/high_scores), теперь мы можем создать новый рекорд (55,160 в Space Invaders!)

### `rails console`

Команда `console` позволяет взаимодействовать с приложением на Rails из командной строки. В своей основе `rails console` использует IRB, поэтому, если вы когда-либо его использовали, то будете чувствовать себя уютно. Это полезно для тестирования быстрых идей с кодом и правки данных на сервере без затрагивания вебсайта.

INFO: Для вызова консоли также можно использовать псевдоним "c": `rails c`.

Можно указать среду, в которой должна работать команда `console`.

```bash
$ rails console staging
```

Если нужно протестировать некоторый код без изменения каких-либо данных, можно это сделать, вызвав `rails console --sandbox`.

```bash
$ rails console --sandbox
Loading development environment in sandbox (Rails 3.2.3)
Any modifications you make will be rolled back on exit
irb(main):001:0>
```

### `rails dbconsole`

`rails dbconsole` определяет, какая база данных используется, и перемещает вас в такой интерфейс командной строки, в котором можно ее использовать (и также определяет параметры командной строки, которые нужно передать!). Она поддерживает MySQL, PostgreSQL, SQLite и SQLite3.

INFO: Для вызова консоли базы данных также можно использовать псевдоним "db": `rails db`.

### `rails runner`

`runner` запускает код Ruby в контексте неинтерактивности Rails. Для примера:

```bash
$ rails runner "Model.long_running_method"
```

INFO: Можно также использовать псевдоним "r" для вызова runner: `rails r`.

Можно определить среду, в которой будет работать команда `runner`, используя переключатель `-e`:

```bash
$ rails runner -e staging "Model.long_running_method"
```

### `rails destroy`

Воспринимайте `destroy` как противоположность `generate`. Она выясняет, что было создано, и отменяет это.

INFO: Также можно использовать псевдоним "d" для вызова команды destroy: `rails d`.

```bash
$ rails generate model Oops
      invoke  active_record
      create    db/migrate/20120528062523_create_oops.rb
      create    app/models/oops.rb
      invoke    test_unit
      create      test/models/oops_test.rb
      create      test/fixtures/oops.yml
```

```bash
$ rails destroy model Oops
      invoke  active_record
      remove    db/migrate/20120528062523_create_oops.rb
      remove    app/models/oops.rb
      invoke    test_unit
      remove      test/models/oops_test.rb
      remove      test/fixtures/oops.yml
```

Rake
----

Rake означает Ruby Make, отдельная утилита Ruby, заменяющая утилиту Unix "make", и использующая файлы "Rakefile" и `.rake` для построения списка задач. В Rails Rake используется для обычных административных задач, особенно таких, которые зависят друг от друга.

Можно получить список доступных задач Rake, который часто зависит от вашей текущей директории, написав `rake --tasks`. У кажой задачи есть описание, помогающее найти то, что вам необходимо.

```bash
$ rake --tasks
rake about              # List versions of all Rails frameworks and the environment
rake assets:clean       # Remove compiled assets
rake assets:precompile  # Compile all the assets named in config.assets.precompile
rake db:create          # Create the database from config/database.yml for the current Rails.env
...
rake log:clear          # Truncates all *.log files in log/ to zero bytes (specify which logs with LOGS=test,development)
rake middleware         # Prints out your Rack middleware stack
...
rake tmp:clear          # Clear session, cache, and socket files from tmp/ (narrow w/ tmp:sessions:clear, tmp:cache:clear, tmp:sockets:clear)
rake tmp:create         # Creates tmp directories for sessions, cache, sockets, and pids
```

### `about`

`rake about` предоставляет информацию о номерах версий Ruby, RubyGems, Rails, подкомпонентов Rails, папке вашего приложения, имени текущей среды Rails, адаптере базы данных вашего приложения и версии схемы. Это полезно, когда нужно попросить помощь, проверить патч безопасности, который может повлиять на вас, или просто хотите узнать статистику о текущей инсталляции Rails.

```bash
$ rake about
About your application's environment
Ruby version              1.9.3 (x86_64-linux)
RubyGems version          1.3.6
Rack version              1.3
Rails version             4.0.0.beta
JavaScript Runtime        Node.js (V8)
Active Record version     4.0.0.beta
Action Pack version       4.0.0.beta
Action Mailer version     4.0.0.beta
Active Support version    4.0.0.beta
Middleware                ActionDispatch::Static, Rack::Lock, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, Rails::Rack::Logger, ActionDispatch::ShowExceptions, ActionDispatch::DebugExceptions, ActionDispatch::RemoteIp, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActiveRecord::ConnectionAdapters::ConnectionManagement, ActiveRecord::QueryCache, ActionDispatch::Cookies, ActionDispatch::Session::EncryptedCookieStore, ActionDispatch::Flash, ActionDispatch::ParamsParser, Rack::Head, Rack::ConditionalGet, Rack::ETag
Application root          /home/foobar/commandsapp
Environment               development
Database adapter          sqlite3
Database schema version   20110805173523
```

### `assets`

Можно предварительно компилировать ресурсы (ассеты) в `app/assets`, используя `rake assets:precompile`, и удалять эти скомпилированные ресурсы, используя `rake assets:clean`.

### `db`

Самыми распространенными задачами пространства имен Rake `db:` являются `migrate` и `create`, но следует попробовать и остальные миграционные задачи rake (`up`, `down`, `redo`, `reset`). `rake db:version` полезна для решения проблем, показывая текущую версию базы данных.

Более подробно о миграциях написано в руководстве [Миграции](/rails-database-migrations).

### `doc`

В пространстве имен `doc:` имеются инструменты для создания документации для вашего приложения, документации API, руководств. Документация также может вырезаться, что полезно для сокращения вашего кода, если вы пишите приложения Rails для встраимовой платформы.

* `rake doc:app` создает документацию для вашего приложения в `doc/app`.
* `rake doc:guides` создает руководства Rails в `doc/guides`.
* `rake doc:rails` создает документацию по API Rails в `doc/api`.

### `notes`

`rake notes` ищет в вашем коде комментарии, начинающиеся с FIXME, OPTIMIZE или TODO. Поиск выполняется в файлах с разрешениями `.builder`, `.rb`, `.erb`, `.haml` и `.slim` для аннотаций как по умолчанию, так и произвольных.

```bash
$ rake notes
(in /home/foobar/commandsapp)
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

app/models/school.rb:
  * [ 13] [OPTIMIZE] refactor this code to make it faster
  * [ 17] [FIXME]
```

Если ищете определенную аннотацию, скажем FIXME, используйте `rake notes:fixme`. Отметьте, что имя аннотации использовано в нижнем регистре.

```bash
$ rake notes:fixme
(in /home/foobar/commandsapp)
app/controllers/admin/users_controller.rb:
  * [132] high priority for next deploy

app/models/school.rb:
  * [ 17]
```

Также можно использовать произвольные аннотации в своем коде и выводить их, используя `rake notes:custom`, определив аннотацию, используя переменную среды `ANNOTATION`.

```bash
$ rake notes:custom ANNOTATION=BUG
(in /home/foobar/commandsapp)
app/models/post.rb:
  * [ 23] Have to fix this one before pushing!
```

NOTE. При использовании определенных и произвольных аннотаций, имя аннотации (FIXME, BUG и т.д.) не отображается в строках результата.

По умолчанию `rake notes` будет искать в директориях `app`, `config`, `lib`, `bin` и `test`. Если желаете искать в иных директориях, можно их предоставить как разделенный запятыми список в переменную среды `SOURCE_ANNOTATION_DIRECTORIES`.

```bash
$ export SOURCE_ANNOTATION_DIRECTORIES='spec,vendor'
$ rake notes
(in /home/foobar/commandsapp)
app/models/user.rb:
  * [ 35] [FIXME] User should have a subscription at this point
rspec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works
```

### `routes`

`rake routes` отобразит список всех определенных маршрутов, что полезно для отслеживания проблем с роутингом в вашем приложении, или предоставления хорошего обзора URL приложения, с которым вы пытаетесь ознакомиться.

### `test`

INFO: Хорошее описание юнит-тестирования в Rails дано в [Руководстве по тестированию приложений на Rails](/a-guide-to-testing-rails-applications)

Rails поставляется с набором тестов по имени `Test::Unit`. Rails сохраняет стабильность в связи с использованием тестов. Задачи, доступные в пространстве имен `test:` помогает с запуском различных тестов, которые вы, несомненно, напишите.

### `tmp`

Директория `Rails.root/tmp` является, как любая *nix директория /tmp, местом для временных файлов, таких как сессии (если вы используете файловое хранение), файлы id процессов и кэшированные экшны.

Задачи пространства имен `tmp:` поможет очистить директорию `Rails.root/tmp`:

* `rake tmp:cache:clear` очистит <tt>tmp/cache</tt>.
* `rake tmp:sessions:clear` очистит <tt>tmp/sessions</tt>.
* `rake tmp:sockets:clear` очистит <tt>tmp/sockets</tt>.
* `rake tmp:clear` очистит все три: кэша, сессий и сокетов.

### Прочее

* `rake stats` великолепно для обзора статистики вашего кода, отображает такие вещи, как KLOCs (тысячи строк кода) и ваш код для тестирования показателей.
* `rake secret` даст псевдо-случайный ключ для использования в качестве секретного ключа сессии.
* `rake time:zones:all` перечислит все временные зоны, о которых знает Rails.

### Пользовательские таски Rake

Пользовательские таски rake имеют расширение `.rake` и располагаются в`Rails.root/lib/tasks`.

```ruby
desc "I am short, but comprehensive description for my cool task"
task task_name: [:prerequisite_task, :another_task_we_depend_on] do
  # Вся магия тут
  # Разрешен любой код Ruby
end
```

Чтобы передать аргументы в ваш таск rake:

```ruby
task :task_name, [:arg_1] => [:pre_1, :pre_2] do |t, args|
  # Здесь можно использовать args
end
```

Таски можно группировать, помещая их в пространства имен:

```ruby
namespace :db do
  desc "This task does nothing"
  task :nothing do
    # Серьезно, ничего
  end
end
```

Вызов тасков выглядит так:

```bash
rake task_name
rake "task_name[value 1]" # entire argument string should be quoted
rake db:nothing
```

NOTE: Если необходимо взаимодействовать с моделями приложения, выполнять запросы в базу данных и так далее, ваш таск должен зависеть от таска `environment`, который загрузит код вашего приложения.

Продвинутая командная строка Rails
----------------------------------

Более продвинутое использование командной строки сфокусировано на полезных (даже иногда удивляющих) опциях утилит, и подгонке утилит к вашим потребностям и особенностям рабочего процесса. Сейчас мы перечислим трюки из рукава Rails.

### Rails с базами данными и SCM

При создании нового приложения на Rails, можно выбрать, какой тип базы данных и какой тип системы управления исходным кодом (SCM) собирается использовать ваше приложение. Это сэкономит вам несколько минут и, конечно, несколько строк.

Давайте посмотрим, что могут сделать для нас опции `--git` и `--database=postgresql`:

```bash
$ mkdir gitapp
$ cd gitapp
$ git init
Initialized empty Git repository in .git/
$ rails new . --git --database=postgresql
      exists
      create  app/controllers
      create  app/helpers
...
...
      create  tmp/cache
      create  tmp/pids
      create  Rakefile
add 'Rakefile'
      create  README.rdoc
add 'README.rdoc'
      create  app/controllers/application_controller.rb
add 'app/controllers/application_controller.rb'
      create  app/helpers/application_helper.rb
...
      create  log/test.log
add 'log/test.log'
```

Мы создали директорию **gitapp** и инициализировали пустой репозиторий перед тем, как Rails добавил бы созданные им файлы в наш репозиторий. Давайте взглянем, что он нам поместил в конфигурацию базы данных:

```bash
$ cat config/database.yml
# PostgreSQL. Versions 8.2 and up are supported.
#
# Install the pg driver:
#   gem install pg
# On OS X with Homebrew:
#   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
# On OS X with MacPorts:
#   gem install pg -- --with-pg-config=/opt/local/lib/postgresql84/bin/pg_config
# On Windows:
#   gem install pg
#       Choose the win32 build.
#       Install PostgreSQL and put its /bin directory on your path.
#
# Configure Using Gemfile
# gem 'pg'
#
development:
  adapter: postgresql
  encoding: unicode
  database: gitapp_development
  pool: 5
  username: gitapp
  password:
...
...
```

Она также создала несколько строчек в нашей конфигурации database.yml, соответствующих нашему выбору PostgreSQL как базы данных. Единственная хитрость с использованием опции SCM состоит в том, что сначала нужно создать директорию для приложения, затем инициализировать ваш SCM, и лишь затем можно запустить команду `rails new` для создания основы вашего приложения.
