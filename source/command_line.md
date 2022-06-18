Командная строка Rails
======================

После прочтения этого руководства, вы узнаете

* Как создать приложение на Rails
* Как генерировать модели, контроллеры, миграции базы данных и юнит-тесты
* Как запустить сервер для разработки
* Как экспериментировать с объектами в интерактивной оболочке

NOTE: Этот самоучитель предполагает, что вы обладаете знаниями основ Rails, которые можно почерпнуть в руководстве [Rails для начинающих](/getting-started).

Создание приложения Rails
-------------------------

Сначала давайте создадим простое приложение на Rails с помощью команды `rails new`.

Мы используем это приложение, чтобы попробовать все команды, описанные в этом руководстве.

INFO: Гем rails можно установив, написав `gem install rails`, если вы еще этого не сделали.

### `rails new`

Первым аргументом, который передается в команду `rails new`, является имя приложения.

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

Если хотите пропустить какие-то файлы или компоненты при генерации, можно добавить следующие аргументы к команде `rails new`:

| Аргумент                | Описание                                            |
| ----------------------- | --------------------------------------------------- |
| `--skip-git`            | Пропустить файл .gitignore                          |
| `--skip-keeps`          | Пропустить файлы для контроля версий .keep          |
| `--skip-action-mailer`  | Пропустить файлы Action Mailer                      |
| `--skip-action-mailbox` | Пропустить гем Action Mailbox                       |
| `--skip-action-text`    | Пропустить гем Action Text                          |
| `--skip-active-record`  | Пропустить файлы Active Record                      |
| `--skip-active-job`     | Пропустить Active Job                               |
| `--skip-active-storage` | Пропустить файлы Active Storage                     |
| `--skip-action-cable`   | Пропустить файлы Action Cable                       |
| `--skip-asset-pipeline` | Пропустить Asset Pipeline                           |
| `--skip-javascript`     | Пропустить файлы JavaScript                         |
| `--skip-hotwire`        | Пропустить интеграцию с Hotwire                     |
| `--skip-jbuilder`       | Пропустить гем jbuilder                             |
| `--skip-test`           | Пропустить файлы тестов                             |
| `--skip-system-test`    | Пропустить файлы системных тестов                   |
| `--skip-bootsnap`       | Пропустить гем bootsnap                             |


Основы командной строки
-----------------------

Имеется несколько команд, абсолютно критичных для повседневного использования в Rails. В порядке возможной частоты использования, они следующие:

* `bin/rails console`
* `bin/rails server`
* `bin/rails test`
* `bin/rails generate`
* `bin/rails db:migrate`
* `bin/rails db:create`
* `bin/rails routes`
* `bin/rails dbconsole`
* `rails new app_name`

Список доступных команд rails, который часто будет зависеть от вашей текущей директории, можно получить, написав `rails --help`. У каждой команды есть описание, это должно помочь найти то, что вам необходимо.

```
$ rails --help
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
 db:schema:dump                      Creates a database schema file (either db/schema.rb or db/structure.sql ...
 db:schema:load                      Loads a database schema file (either db/schema.rb or db/structure.sql ...
 db:seed                             Loads the seed data ...
 db:version                          Retrieves the current schema ...
 ...
 restart                             Restart app by touching ...
 tmp:create                          Creates tmp directories ...
```

### `bin/rails server`

Команда `bin/rails server` запускает веб-сервер Puma, поставляемый с Ruby. Его будем использовать всякий раз, когда захотим увидеть свою работу в веб-браузере.

Безо всякого принуждения, `bin/rails server` запустит наше блестящее приложение на Rails:

```bash
$ cd commandsapp
$ bin/rails server
=> Booting Puma
=> Rails 7.0.0 application starting in development
=> Run `bin/rails server --help` for more startup options
Puma starting in single mode...
* Version 3.12.1 (ruby 2.5.7-p206), codename: Llamas in Pajamas
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://localhost:3000
Use Ctrl-C to stop
```

Всего лишь тремя командами мы развернули сервер Rails, прослушивающий порт 3000. Перейдите в браузер и зайдите на [http://localhost:3000](http://localhost:3000), вы увидите простое приложение, запущенное на rails.

INFO: Для запуска сервера также можно использовать псевдоним "s": `bin/rails s`.

Сервер может быть запущен на другом порту, при использовании опции `-p`. Среда по умолчанию может быть изменена с использованием `-e`.

```bash
$ bin/rails server -e production -p 4000
```

Опция `-b` привязывает Rails к определенному IP, по умолчанию это localhost. Можете запустить сервер, как демона, передав опцию `-d`.

### `bin/rails generate`

Команда `bin/rails generate` использует шаблоны для создания целой кучи вещей. Запуск `bin/rails generate` выдаст список доступных генераторов:

INFO: Также можно использовать псевдоним "g" для вызова команды `generate`: `bin/rails g`.

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

INFO: Все консольные утилиты Rails имеют текст помощи. Как и с большинством утилит \*nix, можно попробовать `--help` или `-h` в конце, например `bin/rails server --help`.

```bash
$ bin/rails generate controller
Usage: bin/rails generate controller NAME [action action] [options]

...
...

Description:
    ...

    To create a controller within a module, specify the controller name as a
    path like 'parent_module/controller_name'.

    ...

Example:
    `bin/rails generate controller CreditCards open debit credit close`

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
      route  get 'greetings/hello'
     invoke  erb
     create    app/views/greetings
     create    app/views/greetings/hello.html.erb
     invoke  test_unit
     create    test/controllers/greetings_controller_test.rb
     invoke  helper
     create    app/helpers/greetings_helper.rb
     invoke    test_unit
```

Что это сгенерировало? Создался ряд директорий в нашем приложении, и создались файл контроллера, файл вью, файл функционального теста, хелпер для вью, файл JavaScript и файл таблицы стилей.

Давайте проверим контроллер и немного его модифицируем (в `app/controllers/greetings_controller.rb`):

```ruby
class GreetingsController < ApplicationController
  def hello
    @message = "Hello, how are you today?"
  end
end
```

Затем вью для отображения нашего сообщения (в `app/views/greetings/hello.html.erb`):

```html+erb
<h1>A Greeting for You!</h1>
<p><%= @message %></p>
```

Запустим сервер с помощью `bin/rails server`.

```bash
$ bin/rails server
=> Booting Puma...
```

URL должен быть [http://localhost:3000/greetings/hello](http://localhost:3000/greetings/hello).

INFO: В нормальном старом добром приложении Rails, ваши URL будут создаваться по образцу http://(host)/(controller)/(action), и URL, подобный такому http://(host)/(controller), вызовет экшн **index** этого контроллера.

В Rails также есть генератор для моделей данных.

```
$ bin/rails generate model
Usage:
  bin/rails generate model NAME [field[:type][:index] field[:type][:index]] [options]

...

ActiveRecord options:
      [--migration], [--no-migration]        # Indicates when to generate migration
                                             # Default: true

...

Description:
    Generates a new model. Pass the model name, either CamelCased or
    under_scored, and an optional list of attribute pairs as arguments.

...
```

NOTE: Список доступных типов полей для параметра `type` можно узнать в [документации API](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column) для метода add_column модуля `SchemaStatements`. Параметр `index` генерирует соответствующий индекс для столбца.

Но вместо генерации модели непосредственно (что мы сделаем еще позже), давайте создадим каркас (scaffold). **Скаффолд** в Rails - это полный набор из модели, миграции базы данных для этой модели, контроллер для воздействия на нее, вью для просмотра и обращения с данными и тестовый набор для всего этого.

Давайте настроим простой ресурс, названный "HighScore", который будет отслеживать наши лучшие результаты в видеоиграх, в которые мы играли.

```bash
$ bin/rails generate scaffold HighScore game:string score:integer
    invoke  active_record
    create    db/migrate/20190416145729_create_high_scores.rb
    create    app/models/high_score.rb
    invoke    test_unit
    create      test/models/high_score_test.rb
    create      test/fixtures/high_scores.yml
    invoke  resource_route
     route    resources :high_scores
    invoke  scaffold_controller
    create    app/controllers/high_scores_controller.rb
    create      test/system/high_scores_test.rb
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
    invoke    jbuilder
    create      app/views/high_scores/index.json.jbuilder
    create      app/views/high_scores/show.json.jbuilder
    create      app/views/high_scores/_high_score.json.jbuilder
```

Генератор создал модель, вью, контроллер, **ресурсный** маршрут и миграцию базы данных (создающую таблицу `high_scores`) для HighScore. Он также добавил тесты для них.

Миграция требует, чтобы мы **мигрировали ее**, то есть запустили некоторый код Ruby (файл `20190416145729_create_high_scores.rb` из вышеприведенного вывода), чтобы модифицировать схему базы данных. Какой базы данных? Базы данных SQLite3, которую создаст Rails, когда мы запустим команду `bin/rails db:migrate`. Поговорим об этой команде ниже.

```bash
$ bin/rails db:migrate
==  CreateHighScores: migrating ===============================================
-- create_table(:high_scores)
   -> 0.0017s
==  CreateHighScores: migrated (0.0019s) ======================================
```

INFO: Давайте поговорим о юнит-тестах. Юнит-тесты - это код, который тестирует и делает утверждения о коде. В юнит-тестировании мы берем часть кода, скажем, метод модели, и тестируем его входы и выходы. Юнит-тесты ваши друзья. Чем раньше вы смиритесь с фактом, что качество жизни возрастет, когда станете тестировать свой код с помощью юнит-тестов, тем лучше. Серьезно. Посетите руководство [Тестирование приложений на Rails](/testing) для более глубокого изучения юнит-тестирования.

Давайте взглянем на интерфейс, который Rails создал для нас.

```bash
$ bin/rails server
```

Перейдите в браузер и откройте [http://localhost:3000/high_scores](http://localhost:3000/high_scores), теперь мы можем создать новый рекорд (55,160 в Space Invaders!)

### `bin/rails console`

Команда `console` позволяет взаимодействовать с приложением на Rails из командной строки. В своей основе `bin/rails console` использует IRB, поэтому, если вы когда-либо его использовали, то будете чувствовать себя уютно. Это полезно для тестирования быстрых идей с кодом и правки данных на сервере не трогая веб-сайт.

INFO: Для вызова консоли также можно использовать псевдоним "c": `bin/rails c`.

Можно указать среду, в которой должна работать команда `console`.

```bash
$ bin/rails console -e staging
```

Если нужно протестировать некоторый код без изменения каких-либо данных, можно это сделать, вызвав `bin/rails console --sandbox`.

```bash
$ bin/rails console --sandbox
Loading development environment in sandbox (Rails 7.1.0)
Any modifications you make will be rolled back on exit
irb(main):001:0>
```

#### Объекты app и helper

Внутри `bin/rails console` имеется доступ к экземплярам `app` и `helper`.

С помощью метода `app` доступны хелперы именованных маршрутов, а также можно делать запросы.

```irb
irb> app.root_path
=> "/"

irb> app.get _
Started GET "/" for 127.0.0.1 at 2014-06-19 10:41:57 -0300
...
```

С помощью метода `helper` возможно получить доступ к хелперам Rails и вашего приложения.

```irb
irb> helper.time_ago_in_words 30.days.ago
=> "about 1 month"

irb> helper.my_custom_helper
=> "my custom helper"
```

### `bin/rails dbconsole`

`bin/rails dbconsole` определяет, какая база данных используется, и перемещает вас в такой интерфейс командной строки, в котором можно ее использовать (и также определяет параметры командной строки, которые нужно передать!). Она поддерживает MySQL (включая MariaDB), PostgreSQL и SQLite3.

INFO: Для вызова консоли базы данных также можно использовать псевдоним "db": `bin/rails db`.

При использовании нескольких баз данных, `bin/rails dbconsole` по умолчанию соединит с основной базой данных. Можно указать, с какой базой данных соединить, с помощью `--database` или `--db`:

```bash
$ bin/rails dbconsole --database=animals
```

### `bin/rails runner`

`runner` запускает код Ruby в контексте неинтерактивности Rails. Для примера:

```bash
$ bin/rails runner "Model.long_running_method"
```

INFO: Можно также использовать псевдоним "r" для вызова runner: `bin/rails r`.

Можно определить среду, в которой будет работать команда `runner`, используя переключатель `-e`:

```bash
$ bin/rails runner -e staging "Model.long_running_method"
```

С помощью runner даже можно выполнять код ruby, написанный в файле.

```bash
$ bin/rails runner lib/code_to_be_run.rb
```

### `bin/rails destroy`

Воспринимайте `destroy` как противоположность `generate`. Она выясняет, что было сгенерировано, и отменяет это.

INFO: Также можно использовать псевдоним "d" для вызова команды destroy: `bin/rails d`.

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

### `bin/rails about`

`bin/rails about` предоставляет информацию о номерах версий Ruby, RubyGems, Rails, подкомпонентов Rails, папке вашего приложения, имени текущей среды Rails, адаптере базы данных вашего приложения и версии схемы. Это полезно, когда нужно попросить помощь, проверить патч безопасности, который может повлиять на вас, или просто хотите узнать статистику о текущей инсталляции Rails.

```
$ rails about
About your application's environment
Rails version             7.0.0
Ruby version              2.7.0 (x86_64-linux)
RubyGems version          2.7.3
Rack version              2.0.4
JavaScript Runtime        Node.js (V8)
Middleware:               Rack::Sendfile, ActionDispatch::Static, ActionDispatch::Executor, ActiveSupport::Cache::Strategy::LocalCache::Middleware, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, ActionDispatch::RemoteIp, Sprockets::Rails::QuietAssets, Rails::Rack::Logger, ActionDispatch::ShowExceptions, WebConsole::Middleware, ActionDispatch::DebugExceptions, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActionDispatch::Cookies, ActionDispatch::Session::CookieStore, ActionDispatch::Flash, Rack::Head, Rack::ConditionalGet, Rack::ETag
Application root          /home/foobar/commandsapp
Environment               development
Database adapter          sqlite3
Database schema version   20180205173523
```

### `bin/rails assets:`

Можно предварительно компилировать ассеты в `app/assets`, используя `bin/rails assets:precompile`, и удалять эти скомпилированные ассеты, используя `bin/rails assets:clean`. Команда `assets:clean` позволяет откатывать деплои, которые все еще могут быть связаны со старыми ассетами, в то время как создаются новые ассеты.

Если хотите полностью очистить `public/assets`, можно использовать `bin/rails assets:clobber`.

### `bin/rails db:`

Самыми распространенными командами пространства имен rails `db:` являются `migrate` и `create`, но следует попробовать и остальные миграционные команды rails (`up`, `down`, `redo`, `reset`). Команда `bin/rails db:version` полезна для решения проблем, показывая текущую версию базы данных.

Более подробно о миграциях написано в руководстве [Миграции Active Record](/active-record-migrations).

### `bin/rails notes`

`bin/rails notes` ищет в вашем коде комментарии, начинающиеся с определенного ключевого слова. Обратитесь к `bin/rails notes --help` за подробностями об использовании.

По умолчанию она будет искать в директориях `app`, `config`, `db`, `lib` и `test` аннотации FIXME, OPTIMIZE и TODO в файлах с расширениями `.builder`, `.rb`, `.rake`, `.yml`, `.yaml`, `.ruby`, `.css`, `.js` и `.erb`.

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 13] [OPTIMIZE] refactor this code to make it faster
  * [ 17] [FIXME]
```

#### Аннотации

Можно указать определенные аннотации с помощью аргумента `--annotations`. По умолчанию, она будет искать FIXME, OPTIMIZE и TODO. Отметьте, что аннотации являются чувствительными к регистру.

```bash
$ bin/rails notes --annotations FIXME RELEASE
app/controllers/admin/users_controller.rb:
  * [101] [RELEASE] We need to look at this before next release
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 17] [FIXME]
```

#### Теги

Можно добавить больше тегов для поиска по умолчанию, используя `config.annotations.register_tags`. Он получает список тегов.

```ruby
config.annotations.register_tags("DEPRECATEME", "TESTME")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] do A/B testing on this
  * [ 42] [TESTME] this needs more functional tests
  * [132] [DEPRECATEME] ensure this method is deprecated in next release
```


#### Директории

Можно добавить больше директорий по умолчанию для поиска с помощью `config.annotations.register_directories`. Она получает список имен директорий.

```ruby
config.annotations.register_directories("spec", "vendor")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 13] [OPTIMIZE] Refactor this code to make it faster
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works

vendor/tools.rb:
  * [ 56] [TODO] Get rid of this dependency
```

#### Расширения

Можно добавить больше расширений файлов по умолчанию с помощью `config.annotations.register_extensions`. Она получает список расширений с соответствующими регулярными выражениями для сопоставления.

```ruby
config.annotations.register_extensions("scss", "sass") { |annotation| /\/\/\s*(#{annotation}):?\s*(.*)$/ }
```

```bash
+$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

app/assets/stylesheets/application.css.sass:
  * [ 34] [TODO] Use pseudo element for this class

app/assets/stylesheets/application.css.scss:
  * [  1] [TODO] Split into multiple components

lib/school.rb:
  * [ 13] [OPTIMIZE] Refactor this code to make it faster
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works

vendor/tools.rb:
  * [ 56] [TODO] Get rid of this dependency
```

### `bin/rails routes`

`bin/rails routes` отобразит список всех определенных маршрутов, что полезно для отслеживания проблем с роутингом в вашем приложении, или предоставления хорошего обзора URL приложения, с которым вы пытаетесь ознакомиться.

### `bin/rails test`

INFO: Хорошее описание юнит-тестирования в Rails дано в руководстве [Тестирование приложений на Rails](/testing).

Rails поставляется с тестовым фреймворком под названием minitest. Rails сохраняет стабильность в связи с использованием тестов. Команды, доступные в пространстве имен `test:`, помогают с запуском различных тестов, которые вы, несомненно, напишите.

### `bin/rails tmp:`

Директория `Rails.root/tmp` является, как любая \*nix директория /tmp, местом для временных файлов, таких как файлы id процессов и кэшированные экшны.

Команды пространства имен `tmp:` помогут очистить и создать директорию `Rails.root/tmp`:

* `bin/rails tmp:cache:clear` очистит `tmp/cache`.
* `bin/rails tmp:sockets:clear` очистит `tmp/sockets`.
* `bin/rails tmp:screenshots:clear` очистит `tmp/screenshots`.
* `bin/rails tmp:clear` очистит все файлы кэша, сокетов и скриншотов.
* `bin/rails tmp:create` создает временные директории для кэша, сокетов и идентификаторов процесса (pid).

### Прочее

* `bin/rails initializers` выведет все определенные инициализаторы в порядке вызова Rails.
* `bin/rails middleware` выведет стек промежуточных программ Rack, включенных в вашем приложении.
* `bin/rails stats` великолепно для обзора статистики вашего кода, отображает такие вещи, как KLOCs (тысячи строчек кода) и ваш код для тестирования показателей.
* `bin/rails secret` даст псевдо-случайный ключ для использования в качестве секретного ключа сессии.
* `bin/rails time:zones:all` перечислит все временные зоны, о которых знает Rails.

### (custom-rake-tasks) Пользовательские задачи Rake

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
$ bin/rails "task_name[value 1,value2,value3]" # несколько аргументов, разделенных запятой
$ bin/rails db:nothing
```

NOTE: Если необходимо взаимодействовать с моделями приложения, выполнять запросы в базу данных и так далее, ваша задача должна зависеть от задачи `environment`, которая загрузит код вашего приложения.

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
# PostgreSQL. Versions 9.3 and up are supported.
#
# Install the pg driver:
#   gem install pg
# On macOS with Homebrew:
#   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
# On macOS with MacPorts:
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
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: gitapp_development
...
...
```

Это также сгенерирует несколько строчек в нашей конфигурации `database.yml`, соответствующих нашему выбору PostgreSQL как базы данных.

NOTE. Единственная хитрость с использованием опции SCM состоит в том, что сначала нужно создать директорию для приложения, затем инициализировать ваш SCM, и лишь затем можно запустить команду `rails new` для генерация основы вашего приложения.
