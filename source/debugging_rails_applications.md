Отладка приложений на Rails
===========================

Это руководство представляет технику отладки приложений на Ruby on Rails.

После прочтения этого руководства, вы узнаете:

* Цель отладки
* Как отслеживать проблемы и вопросы в вашем приложении, которые не определили ваши тесты
* Различные способы отладки
* Как анализировать трассировку

Хелперы вьюхи для отладки
-------------------------

Одной из обычных задач является проверить содержимое переменной. Rails предоставляет три пути как сделать это:

* `debug`
* `to_yaml`
* `inspect`

### `debug`

Хелпер `debug` возвратит тег \<pre>, который рендерит объект, с использованием формата YAML. Это сгенерирует читаемые данные из объекта. Например, если у вас такой код во вьюхе:

```html+erb
<%= debug @article %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

Вы получите что-то наподобие этого:

```yaml
--- !ruby/object Article
attributes:
  updated_at: 2008-09-05 22:55:47
  body: It's a very helpful guide for debugging your Rails app.
  title: Rails debugging guide
  published: t
  id: "1"
  created_at: 2008-09-05 22:55:47
attributes_cache: {}


Title: Rails debugging guide
```

### `to_yaml`

Другой вариант, вызов `to_yaml` на любом объекте конвертирует его в YAML. Вы можете передать этот сконвертированный объект в метод хелпера `simple_format` для форматирования выходных данных. Именно так и работает метод `debug`.

```html+erb
<%= simple_format @article.to_yaml %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

Код выше отрендерит что-то вроде этого:

```yaml
--- !ruby/object Article
attributes:
updated_at: 2008-09-05 22:55:47
body: It's a very helpful guide for debugging your Rails app.
title: Rails debugging guide
published: t
id: "1"
created_at: 2008-09-05 22:55:47
attributes_cache: {}

Title: Rails debugging guide
```

### `inspect`

Другим полезным методом для отображения значений объекта является `inspect`, особенно при работе с массивами и хэшами. Он напечатает значение объекта как строку. Например:

```html+erb
<%= [1, 2, 3, 4, 5].inspect %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

Отрендерит:

```
[1, 2, 3, 4, 5]

Title: Rails debugging guide
```

Логгер
------

Также может быть полезным сохранять информацию в файл лога в процессе выполнения. Rails поддерживает отдельный файл лога для каждой среды запуска.

### Что такое Логгер?

Rails использует класс `ActiveSupport::Logger` для записи информации в лог. Другие логгеры, такие как `Log4R`, могут так же стать заменой.

Альтернативный логгер можно определить в `config/application.rb` или любом другом файле среды, например:

```ruby
config.logger = Logger.new(STDOUT)
config.logger = Log4r::Logger.new("Application Log")
```

Или в разделе `Initializer` добавьте _одно из_ следующего

```ruby
Rails.logger = Logger.new(STDOUT)
Rails.logger = Log4r::Logger.new("Application Log")
```

TIP: По умолчанию каждый лог создается в `Rails.root/log/` с файлом лога, названным по окружению, в котором запущено приложение.

### Уровни лога

Когда что-то логируется, оно записывается в соответствующий лог, если уровень лога сообщения равен или выше чем настроенный уровень лога. Если хотите узнать текущий уровень лога, вызовите метод `ActiveRecord::Base.logger.level`.

Доступные уровни лога следующие: `:debug`, `:info`, `:warn`, `:error`, `:fatal` и `:unknown`, соответствующие номерам уровня лога от 0 до 5 соответственно. Чтобы изменить уровень лога по умолчанию, используйте

```ruby
config.log_level = :warn # В любом инициализаторе среды, или
ActiveRecord::Base.logger.level = 0 # в любое время
```

Это полезно, когда вы хотите логировать в development или staging, но не хотите захламлять production лог ненужной информацией.

TIP: По умолчанию, уровень лога Rails - `debug` во всех средах.

### Отправка сообщений

Чтобы писать в текущий лог, используйте метод `logger.(debug|info|warn|error|fatal)` внутри контроллера, модели или рассыльщика:

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
logger.info "Processing the request..."
logger.fatal "Terminating application, raised unrecoverable error!!!"
```

Вот пример метода, оборудованного дополнительным логированием:

```ruby
class ArticlesController < ApplicationController
  # ...

  def create
    @article = Article.new(article_params)
    logger.debug "New article: #{@article.attributes.inspect}"
    logger.debug "Article should be valid: #{@article.valid?}"

    if @article.save
      logger.debug "The article was saved and now the user is going to be redirected..."
      redirect_to @article, notice: 'Article was successfully created.'
    else
      render :new
    end
  end

  # ...

  private
    def article_params
      params.require(:article).permit(:title, :body, :published)
    end
end
```

Пример лога, сгенерированного при выполнении экшна контроллера:

```
Started POST "/articles" for 127.0.0.1 at 2017-08-20 20:53:10 +0900
Processing by ArticlesController#create as HTML
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"xhuIbSBFytHCE1agHgvrlKnSVIOGD6jltW2tO+P6a/ACjQ3igjpV4OdbsZjIhC98QizWH9YdKokrqxBCJrtoqQ==", "article"=>{"title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs!!!", "published"=>"0"}, "commit"=>"Create Article"}
New article: {"id"=>nil, "title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs!!!", "published"=>false, "created_at"=>nil, "updated_at"=>nil}
Article should be valid: true
   (0.1ms)  BEGIN
  SQL (0.4ms)  INSERT INTO "articles" ("title", "body", "published", "created_at", "updated_at") VALUES ($1, $2, $3, $4, $5) RETURNING "id"  [["title", "Debugging Rails"], ["body", "I'm learning how to print in logs!!!"], ["published", "f"], ["created_at", "2017-08-20 11:53:10.010435"], ["updated_at", "2017-08-20 11:53:10.010435"]]
   (0.3ms)  COMMIT
The article was saved and now the user is going to be redirected...
Redirected to http://localhost:3000/articles/1
Completed 302 Found in 4ms (ActiveRecord: 0.8ms)
```

Добавление дополнительного логирования, подобного этому, облегчает поиск неожиданного или необычного поведения в ваших логах. Если добавляете дополнительное логирование, убедитесь в разумном использовании уровней лога, для избежания заполнения ваших рабочих логов ненужными мелочами.

### Тегированное логирование

При запуске многопользовательских приложений часто полезно фильтровать логи с использованием произвольных правил.
`TaggedLogging` в Active Support помогает это сделать, помечая строчки лога с помощью поддомена, идентификаторов запроса, и тому подобного, помогая отладке таких приложений.

```ruby
logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
logger.tagged("BCX") { logger.info "Stuff" }                            # Logs "[BCX] Stuff"
logger.tagged("BCX", "Jason") { logger.info "Stuff" }                   # Logs "[BCX] [Jason] Stuff"
logger.tagged("BCX") { logger.tagged("Jason") { logger.info "Stuff" } } # Logs "[BCX] [Jason] Stuff"
```

### Воздействие логов на производительность

У логирования всегда будет небольшое воздействие на производительность приложения rails, особенно при логировании на диск. Кроме того, тут есть несколько тонкостей:

Использование уровня `:debug` оказывает гораздо большее влияние на производительность, чем использование уровня `:fatal`, так как вычисляется и пишется в лог (т.е. на диск) гораздо большее количество строк.

Другая потенциальная ловушка - частые вызовы `Logger` в вашем коде:

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
```

В этом примере будет воздействие на производительность, даже если допустимый уровень вывода не включает debug. Причина этого в том, что Ruby вычисляет эти строки, включая инициализацию относительно весомого объекта `String` и интерполяцию переменных. Следовательно, в методы логгера рекомендуется передавать блоки, так как они только вычисляются, если уровень вывода такой же или включен в допустимый (т.е. ленивая загрузка). Переписанный тот же код:

```ruby
logger.debug {"Person attributes hash: #{@person.attributes.inspect}"}
```

Содержимое блока и, следовательно, интерполяция строки будут только вычислены, если включен уровень debug. Экономия производительности будет реально заметна только при большом количестве логирования, но это все равно хорошая практика применения.

Отладка с помощью гема "byebug"
---------------------------------

Когда ваш код ведет себя неожиданным образом, можете печатать в логи или консоль, чтобы выявить проблему. К сожалению, иногда бывает, что такой способ отслеживания ошибки не эффективен в поиске причины проблемы. Когда вы фактически нуждаетесь в путешествии вглубь исполняемого кода, отладчик - это ваш лучший напарник.

Отладчик также может помочь, если хотите изучить исходный код Rails, но не знаете с чего начать. Просто отладьте любой запрос к своему приложению и используйте это руководство для изучения, как идет движение от написанного вами кода в основной код Rails.

### Установка

Вы можете использовать гем `byebug` для настройки точек останова и прохождения через живой код. Чтобы установить его, просто запустите:

```bash
$ gem install byebug
```

Внутри любого приложения на Rails можно вызвать отладчик с помощью метода `byebug`.

Вот пример:

```ruby
class PeopleController < ApplicationController
  def new
    byebug
    @person = Person.new
  end
end
```

### Среда

Как только приложение вызывает метод `byebug`, отладчик будет запущен в среде отладчика в окне терминала, в котором запущен сервер приложения, и будет представлена строка отладчика `(byebug)`. Перед строкой ввода будет отображен код возле строчки, которая должна быть запущена, и текущая строчка будет помечена '=>', например так:

```
[1, 10] in /PathTo/project/app/controllers/articles_controller.rb
    3:
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     byebug
=>  8:     @articles = Article.find_recent
    9:
   10:     respond_to do |format|
   11:       format.html # index.html.erb
   12:       format.json { render json: @articles }

(byebug)
```

Если был получен запрос от браузера, закладка браузера, содержащая запрос, будет висеть, пока отладчик не закончит, и трассировка не закончит обрабатывать весь запрос.

Например:

```bash
=> Booting Puma
=> Rails 5.1.0 application starting in development on http://0.0.0.0:3000
=> Run `rails server -h` for more startup options
Puma starting in single mode...
* Version 3.4.0 (ruby 2.3.1-p112), codename: Owl Bowl Brawl
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://localhost:3000
Use Ctrl-C to stop
Started GET "/" for 127.0.0.1 at 2014-04-11 13:11:48 +0200
  ActiveRecord::SchemaMigration Load (0.2ms)  SELECT "schema_migrations".* FROM "schema_migrations"
Processing by ArticlesController#index as HTML

[3, 12] in /PathTo/project/app/controllers/articles_controller.rb
    3:
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     byebug
=>  8:     @articles = Article.find_recent
    9:
   10:     respond_to do |format|
   11:       format.html # index.html.erb
   12:       format.json { render json: @articles }
(byebug)
```

Настало время изучить ваше приложение. Для начала хорошо бы попросить помощь у отладчика. Напишите: `help`

```
(byebug) help

  break      -- Sets breakpoints in the source code
  catch      -- Handles exception catchpoints
  condition  -- Sets conditions on breakpoints
  continue   -- Runs until program ends, hits a breakpoint or reaches a line
  debug      -- Spawns a subdebugger
  delete     -- Deletes breakpoints
  disable    -- Disables breakpoints or displays
  display    -- Evaluates expressions every time the debugger stops
  down       -- Moves to a lower frame in the stack trace
  edit       -- Edits source files
  enable     -- Enables breakpoints or displays
  finish     -- Runs the program until frame returns
  frame      -- Moves to a frame in the call stack
  help       -- Helps you using byebug
  history    -- Shows byebug's history of commands
  info       -- Shows several informations about the program being debugged
  interrupt  -- Interrupts the program
  irb        -- Starts an IRB session
  kill       -- Sends a signal to the current process
  list       -- Lists lines of source code
  method     -- Shows methods of an object, class or module
  next       -- Runs one or more lines of code
  pry        -- Starts a Pry session
  quit       -- Exits byebug
  restart    -- Restarts the debugged program
  save       -- Saves current byebug session to a file
  set        -- Modifies byebug settings
  show       -- Shows byebug settings
  source     -- Restores a previously saved byebug session
  step       -- Steps into blocks or methods one or more times
  thread     -- Commands to manipulate threads
  tracevar   -- Enables tracing of a global variable
  undisplay  -- Stops displaying all or some expressions when program stops
  untracevar -- Stops tracing a global variable
  up         -- Moves to a higher frame in the stack trace
  var        -- Shows variables and its values
  where      -- Displays the backtrace

(byebug)
```

Чтобы просмотреть предыдущие десять строчек, следует написать `list-` (or `l-`).

```
(byebug) l-

[1, 10] in /PathTo/project/app/controllers/articles_controller.rb
   1  class ArticlesController < ApplicationController
   2    before_action :set_article, only: [:show, :edit, :update, :destroy]
   3
   4    # GET /articles
   5    # GET /articles.json
   6    def index
   7      byebug
   8      @articles = Article.find_recent
   9
   10     respond_to do |format|

```

Таким образом можно перемещаться внутри файла и просматривать код до и после строчки, где вы добавили вызов `byebug`. Наконец, чтобы снова просмотреть, где вы в коде, можно написать `list=`

```
(byebug) list=

[3, 12] in /PathTo/project/app/controllers/articles_controller.rb
    3:
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     byebug
=>  8:     @articles = Article.find_recent
    9:
   10:     respond_to do |format|
   11:       format.html # index.html.erb
   12:       format.json { render json: @articles }
(byebug)
```

### Контекст

Когда начинаете отладку своего приложения, вы будете помещены в различные контексты, так как проходите через различные части стека.

Отладчик создает контекст, когда достигается точка останова или событие. У контекста есть информация о приостановленной программе, которая позволяет отладчику просматривать кадр стека, вычисленных переменных с точки зрения отлаживаемой программы, и знает место, в котором отлаживаемая программа остановилась.

В любое время можете вызвать команду `backtrace` (или ее псевдоним `where`), чтобы напечатать трассировку приложения. Это полезно для того, чтобы знать, где вы находитесь. Если вы когда-нибудь задумывались, как вы получили что-то в коде, то `backtrace` предоставит ответ.

```
(byebug) where
--> #0  ArticlesController.index
      at /PathToProject/app/controllers/articles_controller.rb:8
    #1  ActionController::BasicImplicitRender.send_action(method#String, *args#Array)
      at /PathToGems/actionpack-5.1.0/lib/action_controller/metal/basic_implicit_render.rb:4
    #2  AbstractController::Base.process_action(action#NilClass, *args#Array)
      at /PathToGems/actionpack-5.1.0/lib/abstract_controller/base.rb:181
    #3  ActionController::Rendering.process_action(action, *args)
      at /PathToGems/actionpack-5.1.0/lib/action_controller/metal/rendering.rb:30
...
```

Текущий фрейм помечен `-->`. В этом трейсе можно перемещаться, куда хотите (это изменит контекст), используя команду `frame n`, где _n_ это номер определенного фрейма. Если так сделать, `byebug` отобразит новый контекст.

```
(byebug) frame 2

[176, 185] in /PathToGems/actionpack-5.1.0/lib/abstract_controller/base.rb
   176:       # is the intended way to override action dispatching.
   177:       #
   178:       # Notice that the first argument is the method to be dispatched
   179:       # which is *not* necessarily the same as the action name.
   180:       def process_action(method_name, *args)
=> 181:         send_action(method_name, *args)
   182:       end
   183:
   184:       # Actually call the method associated with the action. Override
   185:       # this method if you wish to change how action methods are called,

(byebug)
```

Доступные переменные такие же, как если бы был запущен код строчка за строчкой. В конце концов, это то, что отлаживается.

Также можно использовать команды `up [n]` и `down [n]` чтобы изменить контекст на _n_ фреймов в стеке вверх или вниз соответственно. _n_ по умолчанию один. Вверх в этом случае обозначает фреймы с большим числом, а вниз — с меньшим числом.

### Треды (threads)

Отладчик может просматривать, останавливать, возобновлять и переключаться между запущенными тредами с использованием команды `thread` (или сокращенно `th`). У этой команды есть несколько опций:

* `thread`: показывает текущий тред
* `thread list`: используется для отображения всех тредов и их статусов. Текущий тред помечается знаком плюс (+).
* `thread stop n`: останавливает тред _n_.
* `thread resume n`: возобновляет тред _n_.
* `thread switch n`: переключает контекст текущего треда на _n_.

Эта команда очень полезна при отлаживании конкурентных тредов и когда необходимо убедиться, что в коде нет состояния гонки.

### Просмотр переменных

Любое выражение может быть вычислено в текущем контексте. Чтобы вычислить выражение, просто напечатайте его!

Следующий пример показывает, как вывести переменные экземпляра, определенные в текущем контексте:

```
[3, 12] in /PathTo/project/app/controllers/articles_controller.rb
    3:
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     byebug
=>  8:     @articles = Article.find_recent
    9:
   10:     respond_to do |format|
   11:       format.html # index.html.erb
   12:       format.json { render json: @articles }

(byebug) instance_variables
[:@_action_has_layout, :@_routes, :@_request, :@_response, :@_lookup_context,
 :@_action_name, :@_response_body, :@marked_for_same_origin_verification,
 :@_config]
```

Как вы могли заметить, отображены все переменные, к которым есть доступ из контроллера. Этот список обновляется динамически по мере выполнения кода.
Например, выполним следующую строчку с помощью `next` (эту команду мы изучим позже).

```
(byebug) next

[5, 14] in /PathTo/project/app/controllers/articles_controller.rb
   5     # GET /articles.json
   6     def index
   7       byebug
   8       @articles = Article.find_recent
   9
=> 10      respond_to do |format|
   11        format.html # index.html.erb
   12        format.json { render json: @articles }
   13      end
   14    end
   15
(byebug)
```

И затем снова спросим instance_variables:

```
(byebug) instance_variables
[:@_action_has_layout, :@_routes, :@_request, :@_response, :@_lookup_context,
 :@_action_name, :@_response_body, :@marked_for_same_origin_verification,
 :@_config, :@articles]
```

Теперь `@articles` включена в переменные экземпляра, поскольку определяющая ее строчка была выполнена.

TIP: Также можно шагнуть в режим **irb** с командой `irb` (конечно!). Это запустит сессию irb в контексте, который ее вызвал.

Метод `var` это более удобный способ показать переменные и их значения. Пускай `byebug` поможет нам с ней.

```
(byebug) help var

  [v]ar <subcommand>

  Shows variables and its values


  var all      -- Shows local, global and instance variables of self.
  var args     -- Information about arguments of the current scope
  var const    -- Shows constants of an object.
  var global   -- Shows global variables.
  var instance -- Shows instance variables of self or a specific object.
  var local    -- Shows local variables in current scope.

```

Это отличный способ просмотреть значения переменных текущего контекста. Например, чтобы проверить, что у нас нет локально определенных переменных в настоящий момент:

```
(byebug) var local
(byebug)
```

Также можно просмотреть метод объекта следующим образом:

```
(byebug) var instance Article.new
@_start_transaction_state = {}
@aggregation_cache = {}
@association_cache = {}
@attributes = #<ActiveRecord::AttributeSet:0x007fd0682a9b18 @attributes={"id"=>#<ActiveRecord::Attribute::FromDatabase:0x007fd0682a9a00 @name="id", @value_be...
@destroyed = false
@destroyed_by_association = nil
@marked_for_destruction = false
@new_record = true
@readonly = false
@transaction_state = nil
```

Можете также использовать `display` для запуска просмотра переменных. Это хороший способ трассировки значений переменной на протяжении выполнения.

```
(byebug) display @articles
1: @articles = nil
```

Переменные в отображаемом перечне будут печататься с их значениями после помещения в стек. Чтобы остановить отображение переменной, используйте `undisplay n`, где _n_ это номер переменной (1 в последнем примере).

### Шаг за шагом

Теперь вы знаете, где находитесь в запущенной трассировке, и способны напечатать доступные переменные. Давайте продолжим и ознакомимся с выполнением приложения.

Используйте `step` (сокращенно `s`) для продолжения запуска вашей программы до следующей логической точки останова и возврата контроля debugger. `_next_` похожа на `step`, но `step` останавливается на следующей строчке выполняемого кода, делая лишь один шаг, а `next` перемещает на следующую строчку без входа внутрь методов.

Например, рассмотрим следующую ситуацию:

```
Started GET "/" for 127.0.0.1 at 2014-04-11 13:39:23 +0200
Processing by ArticlesController#index as HTML

[1, 6] in /PathToProject/app/models/article.rb
   1: class Article < ApplicationRecord
   2:   def self.find_recent(limit = 10)
   3:     byebug
=> 4:     where('created_at > ?', 1.week.ago).limit(limit)
   5:   end
   6: end

(byebug)
```

Если используем `next`, мы хотим уйти глубже в вызовы метода. Вместо этого, `byebug` перейдет на следующую строчку в том же контексте. В этом случае это будет последней строчкой текущего метода, поэтому `byebug` перейдет на следующую строчку вызывающего метода.

```
(byebug) next
[4, 13] in /PathToProject/app/controllers/articles_controller.rb
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     @articles = Article.find_recent
    8:
=>  9:     respond_to do |format|
   10:       format.html # index.html.erb
   11:       format.json { render json: @articles }
   12:     end
   13:   end

(byebug)
```

Если используем `step` в той же ситуации, `byebug` буквально шагнет на следующую инструкцию ruby для выполнения -- в этом случае, в метод Active Support `week`.

```
(byebug) step

[49, 58] in /PathToGems/activesupport-5.1.0/lib/active_support/core_ext/numeric/time.rb
   49:
   50:   # Returns a Duration instance matching the number of weeks provided.
   51:   #
   52:   #   2.weeks # => 14 days
   53:   def weeks
=> 54:     ActiveSupport::Duration.weeks(self)
   55:   end
   56:   alias :week :weeks
   57:
   58:   # Returns a Duration instance matching the number of fortnights provided.

(byebug)
```

Это один из лучших способов найти программные ошибки в коде.

TIP: Также можно использовать `step n` или `next n` для продвижения вперед на `n` шагов за раз.

### Точки останова

Точка останова останавливает приложение, когда достигается определенная точка в программе. В этой строчке вызывается оболочка отладчика.

Можете добавлять точки останова динамически с помощью команды `break` (или просто `b`). Имеются 3 возможных способа ручного добавления точек останова:

* `break n`: устанавливает точку останова в строчке номер _n_ в текущем файле исходника.
* `break file:n [if expression]`: устанавливает точку останова в строчке номер _n_ в файле с именем _file_. Если задано выражение _expression_, оно должно быть вычислено в _true_, чтобы запустить отладчик.
* `break class(.|\#)method [if expression]`: устанавливает точку останова в методе _method_ (. и # для метода класса и экземпляра соответственно), определенного в классе _class_. Выражение _expression_ работает так же, как и с file:n.

Например, в предыдущей ситуации

```
[4, 13] in /PathToProject/app/controllers/articles_controller.rb
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     @articles = Article.find_recent
    8:
=>  9:     respond_to do |format|
   10:       format.html # index.html.erb
   11:       format.json { render json: @articles }
   12:     end
   13:   end

(byebug) break 11
Successfully created breakpoint with id 1
```

Используйте `info breakpoints` для отображения перечня точек останова. Если укажете номер, отобразится только эта точка останова. В противном случае отобразятся все точки останова.

```
(byebug) info breakpoints
Num Enb What
1   y   at /PathToProject/app/controllers/articles_controller.rb:11
```

Чтобы удалить точки останова: используйте команду `delete n` для устранения точки останова номер _n_. Если номер не указан, удалятся все точки останова, которые в данный момент активны.

```
(byebug) delete 1
(byebug) info breakpoints
No breakpoints.
```

Также можно включить или отключить точки останова:

* `enable breakpoints [n [m [...]]]`: позволяет указанному перечню точек останова или всем им останавливать вашу программу. Это состояние по умолчанию для создаваемых точек останова.
* `disable breakpoints [n [m [...]]]`: определенные (или все) точки останова не будут влиять на вашу программу.

### Ловля исключений

Команда `catch exception-name` (или просто `cat exception-name`) может использоваться для перехвата исключения типа _exception-name_, когда в противном случае был бы вызван обработчик для него.

Чтобы просмотреть все активные точки перехвата, используйте `catch`.

### Возобновление выполнения

Есть два способа возобновления выполнения приложения, которое было остановлено отладчиком:

* `continue [n]`: возобновляет выполнение программы с адреса, где ваш скрипт был последний раз остановлен; любые точки останова, установленные на этом адресе будут пропущены. Опциональный аргумент `n` позволяет вам определить номер строчки для установки одноразовой точки останова, которая удаляется после того, как эта точка будет достигнута.
* `finish [n]`: выполняет, пока не возвратится выделенный кадр стека. Если номер кадра не задан, приложение будет запущено пока не возвратится текущий выделенный кадр. Текущий выделенный кадр начинается от самых последних, или с 0, если позиционирование кадров (т.е. up, down или frame) не было выполнено. Если задан номер кадра, будет выполняться, пока не вернется указанный кадр.

### Редактирование

Две команды позволяют открыть код из отладчика в редакторе:

* `edit [file:n]`: редактирует файл _file_, используя редактор, определенный переменной среды EDITOR. Также может быть задана определенная строчка _n_.

### Выход

Чтобы выйти из отладчика, используйте команду `quit` (сокращенно `q`). Или напишите `q!` чтобы пропустить подсказку `Really quit? (y/n)` и безусловно выйти.

Простой выход пытается прекратить все нити в результате. Поэтому ваш сервер будет остановлен и нужно будет стартовать его снова.

### Настройки

У `byebug` имеется несколько доступных опций для настройки его поведения:

```
(byebug) help set

  set <setting> <value>

  Modifies byebug settings

  Boolean values take "on", "off", "true", "false", "1" or "0". If you
  don't specify a value, the boolean setting will be enabled. Conversely,
  you can use "set no<setting>" to disable them.

  You can see these environment settings with the "show" command.

  List of supported settings:

  autosave       -- Automatically save command history record on exit
  autolist       -- Invoke list command on every stop
  width          -- Number of characters per line in byebug's output
  autoirb        -- Invoke IRB on every stop
  basename       -- <file>:<line> information after every stop uses short paths
  linetrace      -- Enable line execution tracing
  autopry        -- Invoke Pry on every stop
  stack_on_error -- Display stack trace when `eval` raises an exception
  fullpath       -- Display full file names in backtraces
  histfile       -- File where cmd history is saved to. Default: ./.byebug_history
  listsize       -- Set number of source lines to list by default
  post_mortem    -- Enable/disable post-mortem mode
  callstyle      -- Set how you want method call parameters to be displayed
  histsize       -- Maximum number of commands that can be stored in byebug history
  savefile       -- File where settings are saved to. Default: ~/.byebug_save
```

TIP: Эти настройки могут быть сохранены в файле `.byebugrc` в домашней директории. debugger считывает эти глобальные настройки при запуске. Например:

```bash
set callstyle short
set listsize 25
```

Отладка с помощью гема `web-console`
------------------------------------

Web Console немного похож на `byebug`, но запускается в браузере. На любой разрабатываемой вами странице, вы можете запустить консоль в контексте вьюхи или контроллера. Консоль отрендерит содержимое HTML.

### Консоль

Внутри экшна контроллера или вьюхи, вы можете вызвать консоль с помощью метода `console`.

Например, в контроллере:

```ruby
class PostsController < ApplicationController
  def new
    console
    @post = Post.new
  end
end
```

Или во вьюхе:

```html+erb
<% console %>

<h2>New Post</h2>
```

Это отрендерит консоль внутри вьюхи. Вам не нужно беспокоится о месте расположения вызова `console`, это не будет отрисовано на месте команды, а после вашего HTML содержимого.

Консоль выполняет чистый Ruby code: вы можете определить или инициализировать собственные классы, создавать новые модели и проверять переменные.

NOTE: Только одна консоль может быть отрисована за один запрос. Иначе `web-console` вызовет ошибку при выполнении второго `console`.

### Проверка переменных

Вы можете вызвать `instance_variables` для вывода всех переменных экземпляра, доступных в контексте. Если вы хотите получить список всех локальных переменных, вы можете сделать это с помощью `local_variables`.

### Настройки

* `config.web_console.whitelisted_ips`: Список авторизованных IPv4 или IPv6
адресов и сетей (по умолчанию: `127.0.0.1/8, ::1`).
* `config.web_console.whiny_requests`: Выводить сообщение, когда консоль не может быть отрисована (по умолчанию: `true`).

Поскольку `web-console` вычисляет чистый Ruby-код удаленно на сервере, не пытайтесь использовать это в production.

Отладка утечки памяти
---------------------

Приложение Ruby (на Rails или нет), может съедать память - или в коде Ruby, или на уровне кода C.

В этом разделе вы научитесь находить и исправлять такие утечки, используя инструмент отладки Valgrind.

### Valgrind

[Valgrind](http://valgrind.org/) - это приложение для обнаружения утечек памяти, связанных с языком C, и состоянием гонки.

Имеются инструменты Valgrind, которые могут автоматически обнаруживать многие программные ошибки управления памятью и тредами, и подробно профилировать ваши программы. Например, если расширение C в интерпретаторе вызывает `malloc()`, но не вызывает должным образом `free()`, эта память не будет доступна пока приложение не будет остановлено.

Чтобы узнать подробности, как установить Valgrind и использовать его с Ruby, обратитесь к [Valgrind and Ruby](http://blog.evanweaver.com/articles/2008/02/05/valgrind-and-ruby/) by Evan Weaver.

Плагины для отладки
-------------------

Имеются некоторые плагины Rails, помогающие в поиске ошибок и отладке вашего приложения. Вот список полезных плагинов для отладки:

* [Footnotes](https://github.com/josevalim/rails-footnotes): У каждой страницы Rails есть сноска, дающая информацию о запросе и ссылку на исходный код через TextMate.
* [Query Trace](https://github.com/ruckus/active-record-query-trace/tree/master): Добавляет трассировку запросов в ваши логи.
* [Query Reviewer](https://github.com/nesquena/query_reviewer): Этот плагин Rails не только запускает "EXPLAIN" перед каждым из ваших запросов select в development, но и представляет небольшой DIV в отрендеренном результате каждой страницы со сводкой предупреждений по каждому проанализированному запросу.
* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master): Предоставляет объект рассыльщика и набор шаблонов по умолчанию для отправки уведомлений по email, когда происходят ошибки в приложении в Rails.
* [Better Errors](https://github.com/charliesome/better_errors): Заменяет стандартную страницу ошибки Rails новой, содержащей больше контекстной информации, такой как исходный код и просмотр переменных.
* [RailsPanel](https://github.com/dejan/rails_panel): Расширение для Chrome для разработки на Rails, которое подхватывает изменения в development.log. Всю информацию о запросах к приложению Rails можно смотреть в браузере, в панели Developer Tools. Предоставляет обзор времени db/rendering/total, списка параметров, отрендеренных вьюх и так далее.
* [Pry](https://github.com/pry/pry) альтернатива IRB и интерактивная консоль для разработчиков.

Ссылки
------

* [Домашняя страница ruby-debug](http://bashdb.sourceforge.net/ruby-debug/home-page.html)
* [Домашняя страница debugger](https://github.com/cldwalker/debugger)
* [Домашняя страница byebug](https://github.com/deivid-rodriguez/byebug)
* [Домашняя страница web-console](https://github.com/rails/web-console)
* [Статья: Debugging a Rails application with ruby-debug](http://www.sitepoint.com/debug-rails-app-ruby-debug/)
* [Скринкаст Ryan Bates' debugging ruby (revised)](http://railscasts.com/episodes/54-debugging-ruby-revised)
* [Скринкаст Ryan Bates' stack trace](http://railscasts.com/episodes/24-the-stack-trace)
* [Скринкаст Ryan Bates' logger](http://railscasts.com/episodes/56-the-logger)
* [Debugging with ruby-debug](http://bashdb.sourceforge.net/ruby-debug.html)
