Командная строка Rails
======================

После прочтения этого руководства, вы узнаете

* Как создать приложение на Rails
* Как генерировать модели, контроллеры, миграции базы данных и юнит-тесты
* Как запустить сервер для разработки
* Как экспериментировать с объектами в интерактивной оболочке

NOTE: Этот самоучитель предполагает, что вы обладаете знаниями основ Rails, которые можно почерпнуть в руководстве [Rails для начинающих](/getting-started-with-rails).

Основы командной строки
-----------------------

Имеется несколько команд, абсолютно критичных для повседневного использования в Rails. В порядке возможной частоты использования, они следующие:

* `rails console`
* `rails server`
* `bin/rails`
* `rails generate`
* `rails dbconsole`
* `rails new app_name`

Каждую команду можно запустить с `-h или --help` для отображения подробной информации.

Давайте создадим простое приложение на Rails, чтобы рассмотреть все эти команды в контексте.

### `rails new`

Сперва мы хотим создать новое приложение на Rails, запустив команду `rails new` после установки Rails.

INFO: Гем rails можно установить, написав `gem install rails`, если его еще нет.

```bash
$ rails new commandsapp
     create
     create  README.md
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

Команда `rails server` запускает веб-сервер Puma, поставляемый с Ruby. Его будем использовать всякий раз, когда захотим увидеть свою работу в веб-браузере.

Безо всякого принуждения, `rails server` запустит наше блестящее приложение на Rails:

```bash
$ cd commandsapp
$ bin/rails server
=> Booting Puma
=> Rails 5.1.0 application starting in development on http://0.0.0.0:3000
=> Run `rails server -h` for more startup options
Puma starting in single mode...
* Version 3.0.2 (ruby 2.3.0-p0), codename: Plethora of Penguin Pinatas
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://localhost:3000
Use Ctrl-C to stop
```

Всего лишь тремя командами мы развернули сервер Rails, прослушивающий порт 3000. Перейдите в браузер и зайдите на [http://localhost:3000](http://localhost:3000), вы увидите простое приложение, запущенное на rails.

INFO: Для запуска сервера также можно использовать псевдоним "s": `rails s`.

Сервер может быть запущен на другом порту, при использовании опции `-p`. Среда по умолчанию может быть изменена с использованием `-e`.

```bash
$ bin/rails server -e production -p 4000
```

Опция `-b` привязывает Rails к определенному IP, по умолчанию это localhost. Можете запустить сервер, как демона, передав опцию `-d`.

### `rails generate`

Команда `rails generate` использует шаблоны для создания целой кучи вещей. Запуск `rails generate` выдаст список доступных генераторов:

INFO: Также можно использовать псевдоним "g" для вызова команды `generate`: `rails g`.

```bash
$ bin/rails generate
Usage: rails generate GENERATOR [args] [options]

...
...

Please choose a generator below.

Rails:
  assets
  channel
  controller
  generator
  ...
  ...
```

NOTE: Можно установить больше генераторов с помощью гемов генераторов, части плагинов, которые вы, несомненно, установите, и даже можете создать свой собственный!

Использование генераторов поможет сэкономить много времени, написав за вас **шаблонный код** - необходимый для работы приложения.

Давайте создадим свой собственный контроллер с помощью генератора контроллера. Какую же команду использовать? Давайте спросим у генератора:

INFO: Все консольные утилиты Rails имеют текст помощи. Как и с большинством утилит *nix, можно попробовать `--help` или `-h` в конце, например `rails server --help`.

```bash
$ bin/rails generate controller
Usage: rails generate controller NAME [action action] [options]

...
...

Description:
    ...

    To create a controller within a module, specify the controller name as a
    path like 'parent_module/controller_name'.

    ...

Example:
    `rails generate controller CreditCards open debit credit close`

    Credit card controller with URLs like /credit_cards/debit.
        Controller: app/controllers/credit_cards_controller.rb
        Test:       test/controllers/credit_cards_controller_test.rb
        Views:      app/views/credit_cards/debit.html.erb [...]
        Helper:     app/helpers/credit_cards_helper.rb
```

Генератор контроллера ожидает параметры в форме `generate controller ControllerName action1 action2`. Давайте создадим контроллер `Greetings` с экшном **hello**, который скажет нам что-нибудь приятное.

```bash
$ bin/rails generate controller Greetings hello
     create  app/controllers/greetings_controller.rb
      route  get "greetings/hello"
     invoke  erb
     create    app/views/greetings
     create    app/views/greetings/hello.html.erb
     invoke  test_unit
     create    test/controllers/greetings_controller_test.rb
     invoke  helper
     create    app/helpers/greetings_helper.rb
     invoke  assets
     invoke    coffee
     create      app/assets/javascripts/greetings.coffee
     invoke    scss
     create      app/assets/stylesheets/greetings.scss
```

Что это сгенерировало? Создался ряд директорий в нашем приложении, и создались файл контроллера, файл вьюхи, файл функционального теста, хелпер для вьюхи, файл JavaScript и файл таблицы стилей.

Давайте проверим контроллер и немного его модифицируем (в `app/controllers/greetings_controller.rb`):

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
$ bin/rails server
=> Booting Puma...
```

URL должен быть [http://localhost:3000/greetings/hello](http://localhost:3000/greetings/hello).

INFO: В нормальном старом добром приложении Rails, ваши URL будут создаваться по образцу http://(host)/(controller)/(action), и URL, подобный такому http://(host)/(controller), вызовет экшн **index** этого контроллера.

В Rails также есть генератор для моделей данных.

```bash
$ bin/rails generate model
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

NOTE: Список доступных типов полей для параметра `type` можно узнать в [документации API](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column) для метода add_column модуля `SchemaStatements`. Параметр `index` генерирует соответствующий индекс для столбца.

Но вместо генерации модели непосредственно (что мы сделаем еще позже), давайте создадим каркас (scaffold). **Скаффолд** в Rails - это полный набор из модели, миграции базы данных для этой модели, контроллер для воздействия на нее, вьюхи для просмотра и обращения с данными и тестовый набор для всего этого.

Давайте настроим простой ресурс, названный "HighScore", который будет отслеживать наши лучшие результаты в видеоиграх, в которые мы играли.

```bash
$ bin/rails generate scaffold HighScore game:string score:integer
    invoke  active_record
    create    db/migrate/20130717151933_create_high_scores.rb
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
    invoke    jbuilder
    create      app/views/high_scores/index.json.jbuilder
    create      app/views/high_scores/show.json.jbuilder
    invoke  test_unit
    create    test/system/high_scores_test.rb
    invoke  assets
    invoke    coffee
    create      app/assets/javascripts/high_scores.coffee
    invoke    scss
    create      app/assets/stylesheets/high_scores.scss
    invoke  scss
   identical    app/assets/stylesheets/scaffolds.scss
```

Генератор проверил, что существуют директории для моделей, контроллеров, хелперов, макетов, функциональных и юнит-тестов, таблиц стилей, создал вьюхи, контроллер, модель и миграцию базы данных для HighScore (создающую таблицу `high_scores` и поля), позаботился о маршруте для *ресурса*, и создал новые тесты для всего этого.

Миграция требует, чтобы мы **мигрировали ее**, то есть запустили некоторый код Ruby (находящийся в `20130717151933_create_high_scores.rb`), чтобы модифицировать схему базы данных. Какой базы данных? Базы данных SQLite3, которую создаст Rails, когда мы запустим команду `bin/rails db:migrate`. Поговорим о bin/rails чуть позже.

```bash
$ bin/rails db:migrate
==  CreateHighScores: migrating ===============================================
-- create_table(:high_scores)
   -> 0.0017s
==  CreateHighScores: migrated (0.0019s) ======================================
```

INFO: Давайте поговорим о юнит-тестах. Юнит-тесты - это код, который тестирует и делает утверждения о коде. В юнит-тестировании мы берем часть кода, скажем, метод модели, и тестируем его входы и выходы. Юнит-тесты ваши друзья. Чем раньше вы смиритесь с фактом, что качество жизни возрастет, когда станете тестировать свой код с помощью юнит-тестов, тем лучше. Серьезно. Посетите руководство [Тестирование приложений на Rails](/a-guide-to-testing-rails-applications) для более глубокого изучения юнит-тестирования.

Давайте взглянем на интерфейс, который Rails создал для нас.

```bash
$ bin/rails server
```

Перейдите в браузер и откройте [http://localhost:3000/high_scores](http://localhost:3000/high_scores), теперь мы можем создать новый рекорд (55,160 в Space Invaders!)

### `rails console`

Команда `console` позволяет взаимодействовать с приложением на Rails из командной строки. В своей основе `rails console` использует IRB, поэтому, если вы когда-либо его использовали, то будете чувствовать себя уютно. Это полезно для тестирования быстрых идей с кодом и правки данных на сервере не трогая веб-сайт.

INFO: Для вызова консоли также можно использовать псевдоним "c": `rails c`.

Можно указать среду, в которой должна работать команда `console`.

```bash
$ bin/rails console -e staging
```

Если нужно протестировать некоторый код без изменения каких-либо данных, можно это сделать, вызвав `rails console --sandbox`.

```bash
$ bin/rails console --sandbox
Loading development environment in sandbox (Rails 5.1.0)
Any modifications you make will be rolled back on exit
irb(main):001:0>
```

#### Объекты app и helper

Внутри `rails console` имеется доступ к экземплярам `app` и `helper`.

С помощью метода `app` доступны хелперы url и path, а также можно делать запросы.

```bash
>> app.root_path
=> "/"

>> app.get _
Started GET "/" for 127.0.0.1 at 2014-06-19 10:41:57 -0300
...
```

С помощью метода `helper` возможно получить доступ к хелперам Rails и вашего приложения.

```bash
>> helper.time_ago_in_words 30.days.ago
=> "about 1 month"

>> helper.my_custom_helper
=> "my custom helper"
```

### `rails dbconsole`

`rails dbconsole` определяет, какая база данных используется, и перемещает вас в такой интерфейс командной строки, в котором можно ее использовать (и также определяет параметры командной строки, которые нужно передать!). Она поддерживает MySQL (включая MariaDB), PostgreSQL и SQLite3.

INFO: Для вызова консоли базы данных также можно использовать псевдоним "db": `rails db`.

### `rails runner`

`rails runner` запускает код Ruby в контексте неинтерактивности Rails. Для примера:

```bash
$ bin/rails runner "Model.long_running_method"
```

INFO: Можно также использовать псевдоним "r" для вызова runner: `rails r`.

Можно определить среду, в которой будет работать команда `runner`, используя переключатель `-e`:

```bash
$ bin/rails runner -e staging "Model.long_running_method"
```

С помощью runner даже можно выполнять код ruby, написанный в файле.

```bash
$ bin/rails runner lib/code_to_be_run.rb
```

### `rails destroy`

Воспринимайте `destroy` как противоположность `generate`. Она выясняет, что было сгенерировано, и отменяет это.

INFO: Также можно использовать псевдоним "d" для вызова команды destroy: `rails d`.

```bash
$ bin/rails generate model Oops
      invoke  active_record
      create    db/migrate/20120528062523_create_oops.rb
      create    app/models/oops.rb
      invoke    test_unit
      create      test/models/oops_test.rb
      create      test/fixtures/oops.yml
```

```bash
$ bin/rails destroy model Oops
      invoke  active_record
      remove    db/migrate/20120528062523_create_oops.rb
      remove    app/models/oops.rb
      invoke    test_unit
      remove      test/models/oops_test.rb
      remove      test/fixtures/oops.yml
```

bin/rails
----

Начиная с Rails 5.0+ команды rake встроены в исполняемый файл rails, `bin/rails` теперь выполняет команды по умолчанию.

Можно получить список доступных задач bin/rails, который часто зависит от вашей текущей директории, написав `bin/rails --help`. У каждой задачи есть описание, помогающее найти то, что вам необходимо.

```bash
$ bin/rails --help
Usage: rails COMMAND [ARGS]

The most common rails commands are:
generate    Generate new code (short-cut alias: "g")
console     Start the Rails console (short-cut alias: "c")
server      Start the Rails server (short-cut alias: "s")
...

All commands can be run with -h (or --help) for more information.

In addition to those commands, there are:
about                               List versions of all Rails ...
assets:clean[keep]                  Remove old compiled assets
assets:clobber                      Remove compiled assets
assets:environment                  Load asset compile environment
assets:precompile                   Compile all the assets ...
...
db:fixtures:load                    Loads fixtures into the ...
db:migrate                          Migrate the database ...
db:migrate:status                   Display status of migrations
db:rollback                         Rolls the schema back to ...
db:schema:cache:clear               Clears a db/schema_cache.yml file
db:schema:cache:dump                Creates a db/schema_cache.yml file
db:schema:dump                      Creates a db/schema.rb file ...
db:schema:load                      Loads a schema.rb file ...
db:seed                             Loads the seed data ...
db:structure:dump                   Dumps the database structure ...
db:structure:load                   Recreates the databases ...
db:version                          Retrieves the current schema ...
...
restart                             Restart app by touching ...
tmp:create                          Creates tmp directories ...
```

INFO: Для получения списка задач также можно использовать `bin/rails -T`.

### `about`

`bin/rails about` предоставляет информацию о номерах версий Ruby, RubyGems, Rails, подкомпонентов Rails, папке вашего приложения, имени текущей среды Rails, адаптере базы данных вашего приложения и версии схемы. Это полезно, когда нужно попросить помощь, проверить патч безопасности, который может повлиять на вас, или просто хотите узнать статистику о текущей инсталляции Rails.

```bash
$ bin/rails about
About your application's environment
Rails version             6.0.0
Ruby version              2.5.0 (x86_64-linux)
RubyGems version          2.7.3
Rack version              2.0.4
JavaScript Runtime        Node.js (V8)
Middleware                Rack::Sendfile, ActionDispatch::Static, ActionDispatch::Executor, ActiveSupport::Cache::Strategy::LocalCache::Middleware, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, ActionDispatch::RemoteIp, Sprockets::Rails::QuietAssets, Rails::Rack::Logger, ActionDispatch::ShowExceptions, WebConsole::Middleware, ActionDispatch::DebugExceptions, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActionDispatch::Cookies, ActionDispatch::Session::CookieStore, ActionDispatch::Flash, Rack::Head, Rack::ConditionalGet, Rack::ETag
Application root          /home/foobar/commandsapp
Environment               development
Database adapter          sqlite3
Database schema version   20180205173523
```

### `assets`

Можно предварительно компилировать ассеты в `app/assets`, используя `bin/rails assets:precompile`, и удалять эти скомпилированные ассеты, используя `bin/rails assets:clean`. Задача `assets:clean` позволяет откатывать деплои, которые все еще могут быть связаны со старыми ассетами, в то время как создаются новые ассеты.

Если хотите полностью очистить `public/assets`, можно использовать `bin/rails assets:clobber`.

### `db`

Самыми распространенными задачами пространства имен bin/rails `db:` являются `migrate` и `create`, но следует попробовать и остальные миграционные задачи bin/rails (`up`, `down`, `redo`, `reset`). `bin/rails db:version` полезна для решения проблем, показывая текущую версию базы данных.

Более подробно о миграциях написано в руководстве [Миграции Active Record](/rails-database-migrations).

### `notes`

`bin/rails notes` ищет в вашем коде комментарии, начинающиеся с FIXME, OPTIMIZE или TODO. Поиск выполняется в файлах с разрешениями `.builder`, `.rb`, `.rake`, `.yml`, `.yaml`, `.ruby`, `.css`, `.js` и `.erb` для аннотаций как по умолчанию, так и произвольных.

```bash
$ bin/rails notes
(in /home/foobar/commandsapp)
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

app/models/school.rb:
  * [ 13] [OPTIMIZE] refactor this code to make it faster
  * [ 17] [FIXME]
```

Можно добавить поддержку для нового расширения файла с помощью опции `config.annotations.register_extensions`, которая получает список расширений с соответствующим регулярным выражением.

```ruby
config.annotations.register_extensions("scss", "sass", "less") { |annotation| /\/\/\s*(#{annotation}):?\s*(.*)$/ }
```

Если ищете определенную аннотацию, скажем FIXME, используйте `bin/rails notes:fixme`. Отметьте, что имя аннотации использовано в нижнем регистре.

```bash
$ bin/rails notes:fixme
(in /home/foobar/commandsapp)
app/controllers/admin/users_controller.rb:
  * [132] high priority for next deploy

app/models/school.rb:
  * [ 17]
```

Также можно использовать произвольные аннотации в своем коде и выводить их, используя `bin/rails notes:custom`, определив аннотацию, используя переменную среды `ANNOTATION`.

```bash
$ bin/rails notes:custom ANNOTATION=BUG
(in /home/foobar/commandsapp)
app/models/article.rb:
  * [ 23] Have to fix this one before pushing!
```

NOTE. При использовании определенных и произвольных аннотаций, имя аннотации (FIXME, BUG и т.д.) не отображается в строчках результата.

По умолчанию `rails notes` будет искать в директориях `app`, `config`, `db`, `lib` и `test`. Если желаете искать в иных директориях, их можно настроить с помощью опции `config.annotations.register_directories`.

```ruby
config.annotations.register_directories("spec", "vendor")
```

Также можно их предоставить как разделенный запятыми список в переменной среды `SOURCE_ANNOTATION_DIRECTORIES`.

```bash
$ export SOURCE_ANNOTATION_DIRECTORIES='spec,vendor'
$ bin/rails notes
(in /home/foobar/commandsapp)
app/models/user.rb:
  * [ 35] [FIXME] User should have a subscription at this point
spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works
```

### `routes`

`rails routes` отобразит список всех определенных маршрутов, что полезно для отслеживания проблем с роутингом в вашем приложении, или предоставления хорошего обзора URL приложения, с которым вы пытаетесь ознакомиться.

### `test`

INFO: Хорошее описание юнит-тестирования в Rails дано в руководстве [Тестирование приложений на Rails](/a-guide-to-testing-rails-applications).

Rails поставляется с тестовым набором под названием `Minitest`. Rails сохраняет стабильность в связи с использованием тестов. Задачи, доступные в пространстве имен `test:`, помогают с запуском различных тестов, которые вы, несомненно, напишите.

### `tmp`

Директория `Rails.root/tmp` является, как любая *nix директория /tmp, местом для временных файлов, таких как файлы id процессов и кэшированные экшны.

Задачи пространства имен `tmp:` помогут очистить и создать директорию `Rails.root/tmp`:

* `rails tmp:cache:clear` очистит `tmp/cache`.
* `rails tmp:sockets:clear` очистит `tmp/sockets`.
* `rails tmp:screenshots:clear` очистит `tmp/screenshots`.
* `rails tmp:clear` очистит все файлы кэша, сокетов и скриншотов.
* `rails tmp:create` создает временные директории для кэша, сокетов и идентификаторов процесса (pid).

### Прочее

* `rails stats` великолепно для обзора статистики вашего кода, отображает такие вещи, как KLOCs (тысячи строчек кода) и ваш код для тестирования показателей.
* `rails secret` даст псевдо-случайный ключ для использования в качестве секретного ключа сессии.
* `rails time:zones:all` перечислит все временные зоны, о которых знает Rails.

### Пользовательские задачи Rake

Пользовательские задачи rake имеют расширение `.rake` и располагаются в `Rails.root/lib/tasks`. Эти пользовательские задачи rake можно создать с помощью команды `bin/rails generate task`.

```ruby
desc "I am short, but comprehensive description for my cool task"
task task_name: [:prerequisite_task, :another_task_we_depend_on] do
  # Вся магия тут
  # Разрешен любой код Ruby
end
```

Чтобы передать аргументы в ваш задачу rake:

```ruby
task :task_name, [:arg_1] => [:prerequisite_1, :prerequisite_2] do |task, args|
  argument_1 = args.arg_1
end
```

Задачи можно группировать, помещая их в пространства имен:

```ruby
namespace :db do
  desc "This task does nothing"
  task :nothing do
    # Серьезно, ничего
  end
end
```

Вызов задач выглядит так:

```bash
$ bin/rails task_name
$ bin/rails "task_name[value 1]" # весь аргумент в виде строки должен быть в кавычках
$ bin/rails db:nothing
```

NOTE: Если необходимо взаимодействовать с моделями приложения, выполнять запросы в базу данных и так далее, ваша задача должен зависеть от задачи `environment`, который загрузит код вашего приложения.

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
      create  README.md
add 'README.md'
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
# PostgreSQL. Versions 9.1 and up are supported.
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
default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see Rails configuration guide
  # http://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: gitapp_development
...
...
```

Это также сгенерирует несколько строчек в нашей конфигурации `database.yml`, соответствующих нашему выбору PostgreSQL как базы данных.

NOTE. Единственная хитрость с использованием опции SCM состоит в том, что сначала нужно создать директорию для приложения, затем инициализировать ваш SCM, и лишь затем можно запустить команду `rails new` для генерация основы вашего приложения.
