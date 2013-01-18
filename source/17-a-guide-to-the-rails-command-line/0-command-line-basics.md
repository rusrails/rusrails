# Основы командной строки

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

Опция `-b` привязывает Rails к определенному ip, по умолчанию это 0.0.0.0. Можете запустить сервер, как демона, передав опцию `-d`.

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
