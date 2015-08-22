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

Хелпер `debug` возвратит тег \<pre>, который рендерит объект, с использованием формата YAML. Это создаст читаемые данные из объекта. Например, если у вас такой код во вьюхе:

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

Другой вариант, вызов `to_yaml` на любом объекте конвертирует его в YAML. Вы можете передать этот сконвертированный объект в хэлпер метод `simple_format` для форматирования выходных данных. Именно так и работает метод `debug`.

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

Альтернативный логгер можно определить в `environment.rb` или любом другом файле среды, например:

```ruby
Rails.logger = Logger.new(STDOUT)
Rails.logger = Log4r::Logger.new("Application Log")
```

Или в разделе `Initializer` добавьте _одно из_ следующего

```ruby
config.logger = Logger.new(STDOUT)
config.logger = Log4r::Logger.new("Application Log")
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
    @article = Article.new(params[:article])
    logger.debug "New article: #{@article.attributes.inspect}"
    logger.debug "Article should be valid: #{@article.valid?}"

    if @article.save
      flash[:notice] =  'Article was successfully created.'
      logger.debug "The article was saved and now the user is going to be redirected..."
      redirect_to(@article)
    else
      render action: "new"
    end
  end

  # ...
end
```

Пример лога, сгенерированного при выполнении экшена контроллера:

```
Processing ArticlesController#create (for 127.0.0.1 at 2008-09-08 11:52:54) [POST]
  Session ID: BAh7BzoMY3NyZl9pZCIlMDY5MWU1M2I1ZDRjODBlMzkyMWI1OTg2NWQyNzViZjYiCmZsYXNoSUM6J0FjdGl
vbkNvbnRyb2xsZXI6OkZsYXNoOjpGbGFzaEhhc2h7AAY6CkB1c2VkewA=--b18cd92fba90eacf8137e5f6b3b06c4d724596a4
  Parameters: {"commit"=>"Create", "article"=>{"title"=>"Debugging Rails",
 "body"=>"I'm learning how to print in logs!!!", "published"=>"0"},
 "authenticity_token"=>"2059c1286e93402e389127b1153204e0d1e275dd", "action"=>"create", "controller"=>"articles"}
New article: {"updated_at"=>nil, "title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs!!!",
 "published"=>false, "created_at"=>nil}
Article should be valid: true
  Article Create (0.000443)   INSERT INTO "articles" ("updated_at", "title", "body", "published",
 "created_at") VALUES('2008-09-08 14:52:54', 'Debugging Rails',
 'I''m learning how to print in logs!!!', 'f', '2008-09-08 14:52:54')
The article was saved and now the user is going to be redirected...
Redirected to # Article:0x20af760>
Completed in 0.01224 (81 reqs/sec) | DB: 0.00044 (3%) | 302 Found [http://localhost/articles]
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

В этом примере будет воздействие на производительность, даже если допустимый уровень вывода не включает debug. Причина этого в том, что Ruby вычисляет эти строки, включая инициализацию относительно весомого объекта `String` и интерполяцию переменных. Следовательно, в методы логера рекомендуется передавать блоки, так как они вычисляются только, если уровень вывода такой же или включен в допустимый (т.е. ленивая загрузка). Переписанный тот же код:

```ruby
logger.debug {"Person attributes hash: #{@person.attributes.inspect}"}
```

Содержимое блока и, следовательно, интерполяция строки будут вычислены только, если включен уровень debug. Экономия производительности будет реально заметна только при большом количестве логирования, но это все равно хорошая практика применения.

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

Как только приложение вызывает метод `byebug`, отладчик будет запущен в среде отладчика в окне терминала, в котором запущен сервер приложения, и будет представлена строка отладчика `(byebug)`. Перед строкой ввода будет отображен код возле строчки, которая выполняется, и текущая строчка будет помечена '=>', например так:

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
=> Booting WEBrick
=> Rails 5.0.0 application starting in development on http://0.0.0.0:3000
=> Run `rails server -h` for more startup options
=> Notice: server is listening on all interfaces (0.0.0.0). Consider using 127.0.0.1 (--binding option)
=> Ctrl-C to shutdown server
[2014-04-11 13:11:47] INFO  WEBrick 1.3.1
[2014-04-11 13:11:47] INFO  ruby 2.2.2 (2015-04-13) [i686-linux]
[2014-04-11 13:11:47] INFO  WEBrick::HTTPServer#start: pid=6370 port=3000

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

  h[elp][ <cmd>[ <subcmd>]]

  help                -- prints this help.
  help <cmd>          -- prints help on command <cmd>.
  help <cmd> <subcmd> -- prints help on <cmd>'s subcommand <subcmd>.
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
   10      respond_to do |format|

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

Отладчик создает контекст, когда достигается точка останова или событие. У контекста есть информация о приостановленной программе, которая позволяет отладчику просматривать кадр стека, значения переменных с точки зрения отлаживаемой программы, и знает место, в котором отлаживаемая программа остановилась.

В любое время можете вызвать команду `backtrace` (или ее псевдоним `where`), чтобы напечатать трассировку приложения. Это полезно для того, чтобы знать, где вы находитесь. Если вы когда-нибудь задумывались, как вы получили что-то в коде, то `backtrace` предоставит ответ.

```
(byebug) where
--> #0  ArticlesController.index
      at /PathTo/project/test_app/app/controllers/articles_controller.rb:8
    #1  ActionController::ImplicitRender.send_action(method#String, *args#Array)
      at /PathToGems/actionpack-5.0.0/lib/action_controller/metal/implicit_render.rb:4
    #2  AbstractController::Base.process_action(action#NilClass, *args#Array)
      at /PathToGems/actionpack-5.0.0/lib/abstract_controller/base.rb:189
    #3  ActionController::Rendering.process_action(action#NilClass, *args#NilClass)
      at /PathToGems/actionpack-5.0.0/lib/action_controller/metal/rendering.rb:10
...
```

Текущий фрейм помечен `-->`. В этом трейсе можно перемещаться, куда хотите (это изменит контекст), используя команду `frame _n_`, где _n_ это номер определенного фрейма. Если так сделать, `byebug` отобразит новый контекст.

```
(byebug) frame 2

[184, 193] in /PathToGems/actionpack-5.0.0/lib/abstract_controller/base.rb
   184:       # is the intended way to override action dispatching.
   185:       #
   186:       # Notice that the first argument is the method to be dispatched
   187:       # which is *not* necessarily the same as the action name.
   188:       def process_action(method_name, *args)
=> 189:         send_action(method_name, *args)
   190:       end
   191:
   192:       # Actually call the method associated with the action. Override
   193:       # this method if you wish to change how action methods are called,

(byebug)
```

Доступные переменные те же самые, как если бы вы запускали код строка за строкой. В конце концов, это то, что отлаживается.

Также можно использовать команды `up [n]` (сокращенно `u`) и `down [n]` чтобы изменить контекст на _n_ фреймов в стеке вверх или вниз соответственно. _n_ по умолчанию один. Вверх в этом случае обозначает фреймы с большим числом, а вниз — с меньшим числом.

### Треды (threads)

Отладчик может просматривать, останавливать, возобновлять и переключаться между запущенными тредами с использованием команды `thread` (или сокращенно `th`). У этой команды есть несколько опций:

* `thread`: показывает текущий тред
* `thread list`: используется для отображения всех тредов и их статусов. Символ плюс + и число показывают текущий тред выполнения.
* `thread stop _n_`: останавливает тред _n_.
* `thread resume _n_`: возобновляет тред _n_.
* `thread switch _n_`: переключает контекст текущего треда на _n_.

Эта команда очень полезна, когда вы отлаживаете параллельные треды и нужно убедиться, что в коде нет состояния гонки.

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
[:@_action_has_layout, :@_routes, :@_headers, :@_status, :@_request,
 :@_response, :@_env, :@_prefixes, :@_lookup_context, :@_action_name,
 :@_response_body, :@marked_for_same_origin_verification, :@_config]
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
=> 10       respond_to do |format|
   11         format.html # index.html.erb
   12        format.json { render json: @articles }
   13      end
   14    end
   15
(byebug)
```

И затем снова спросим instance_variables:

```
(byebug) instance_variables
[:@_action_has_layout, :@_routes, :@_headers, :@_status, :@_request,
 :@_response, :@_env, :@_prefixes, :@_lookup_context, :@_action_name,
 :@_response_body, :@marked_for_same_origin_verification, :@_config,
 :@articles]
```

Теперь `@articles` включена в переменные экземпляра, поскольку определяющая ее строка была выполнена.

TIP: Также можно шагнуть в режим **irb** с командой `irb` (конечно!). Это запустит сессию irb в контексте, который ее вызвал. Но предупреждаем: это эксперементальная особенность.

Метод `var` это более удобный способ показать переменные и их значения. Пускай `byebug` поможет нам с ней.

```
(byebug) help var
v[ar] cl[ass]                   show class variables of self
v[ar] const <object>            show constants of object
v[ar] g[lobal]                  show global variables
v[ar] i[nstance] <object>       show instance variables of object
v[ar] l[ocal]                   show local variables
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
@attributes = {"id"=>nil, "created_at"=>nil, "updated_at"=>nil}
@attributes_cache = {}
@changed_attributes = nil
...
```

TIP: Команды `p` (print) и `pp` (pretty print) могут использоваться для вычисления выражений Ruby и отображения значения переменных в консоли.

Можете также использовать `display` для запуска просмотра переменных. Это хороший способ трассировки значений переменной на протяжении выполнения.

```
(byebug) display @articles
1: @articles = nil
```

Переменные в отображаемом перечне будут печататься с их значениями после помещения в стек. Чтобы остановить отображение переменной, используйте `undisplay _n_`, где _n_ это номер переменной (1 в последнем примере).

### Шаг за шагом

Теперь вы знаете, где находитесь в запущенной трассировке, и способны напечатать доступные переменные. Давайте продолжим и ознакомимся с выполнением приложения.

Используйте `step` (сокращенно `s`) для продолжения запуска вашей программы до следующей логической точки останова и возврата контроля debugger.

Также можете использовать `_next_`, которая похожа на `step`, но вызовы функции или метода, выполняемые в строке кода, выполняются без остановки.

TIP: А также можно использовать `step n` или `next n` для перемещения на `n` шагов за раз.

Разница между `next` и `step` в том, что `step` останавливается на следующей линии выполняемого кода, делая лишь один шаг, в то время как `next` перемещает на следующую строку без входа внутрь методов.

Например, рассмотрим следующую ситуацию:

```ruby
Started GET "/" for 127.0.0.1 at 2014-04-11 13:39:23 +0200
Processing by ArticlesController#index as HTML

[1, 8] in /home/davidr/Proyectos/test_app/app/models/article.rb
   1: class Article < ActiveRecord::Base
   2:
   3:   def self.find_recent(limit = 10)
   4:     byebug
=> 5:     where('created_at > ?', 1.week.ago).limit(limit)
   6:   end
   7:
   8: end

(byebug)
```

Если используем `next`, мы хотим уйти глубже в вызовы метода. Вместо этого, byebug перейдет на следующую строчку в том же контесте. В этом случае это будет последней строчкой метода, поэтому `byebug` перепрыгнет на следующую строчку предыдущего фрейма.

```
(byebug) next
Next went up a frame because previous frame finished

[4, 13] in /PathTo/project/test_app/app/controllers/articles_controller.rb
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

Если используем `step` в той же ситуации, мы буквально шагнем на следующую инструкцию ruby для выполнения. В этом случае, в метод Active Support `week`.

```
(byebug) step

[50, 59] in /PathToGems/activesupport-5.0.0/lib/active_support/core_ext/numeric/time.rb
   50:     ActiveSupport::Duration.new(self * 24.hours, [[:days, self]])
   51:   end
   52:   alias :day :days
   53:
   54:   def weeks
=> 55:     ActiveSupport::Duration.new(self * 7.days, [[:days, self * 7]])
   56:   end
   57:   alias :week :weeks
   58:
   59:   def fortnights

(byebug)
```

Это один из лучших способов найти ошибки в вашем коде.

### Точки останова

Точка останова останавливает ваше приложение, когда достигается определенная точка в программе. В этой линии вызывается оболочка отладчика.

Можете добавлять точки останова динамически с помощью команды `break` (или просто `b`). Имеются 3 возможных способа ручного добавления точек останова:

* `break line`: устанавливает точку останова в строчке номер _line_ в текущем файле исходника.
* `break file:line [if expression]`: устанавливает точку останова в строчке номер _line_ в файле _file_. Если задано выражение _expression_, оно должно быть вычислено в _true_, чтобы запустить отладчик.
* `break class(.|\#)method [if expression]`: устанавливает точку останова в методе _method_ (. и # для метода класса и экземпляра соответственно), определенного в классе _class_. Выражение _expression_ работает так же, как и с file:line.

Например, в предыдущей ситуации

```
[4, 13] in /PathTo/project/app/controllers/articles_controller.rb
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
Created breakpoint 1 at /PathTo/project/app/controllers/articles_controller.rb:11
```

Используйте `info breakpoints _n_` или `info break _n_` для отображения перечня точек останова. Если укажете номер, отобразится только эта точка останова. В противном случае отобразятся все точки останова.

```
(byebug) info breakpoints
Num Enb What
1   y   at /PathTo/project/app/controllers/articles_controller.rb:11
```

Чтобы удалить точки останова: используйте команду `delete _n_` для устранения точки останова номер _n_. Если номер не указан, удалятся все точки останова, которые в данный момент активны.

```
(byebug) delete 1
(byebug) info breakpoints
No breakpoints.
```

Также можно включить или отключить точки останова:

* `enable breakpoints`: позволяет перечню _breakpoints_ или всем им, если перечень не определен, останавливать вашу программу. Это состояние по умолчанию для создаваемых точек останова.
* `disable breakpoints`: _breakpoints_ не будут влиять на вашу программу.

### Ловля исключений

Команда `catch exception-name` (или просто `cat exception-name`) может использоваться для перехвата исключения типа _exception-name_, когда в противном случае был бы вызван обработчик для него.

Чтобы просмотреть все активные точки перехвата, используйте `catch`.

### Возобновление исполнения

Есть два способа возобновления выполнения приложения, которое было остановлено отладчиком:

* `continue [line-specification]` (или `c`): возобновляет выполнение программы с адреса, где ваш скрипт был последний раз остановлен; любые точки останова, установленные на этом адресе будут пропущены. Дополнительный аргумент line-specification позволяет вам определить число линий для установки одноразовой точки останова, которая удаляется после того, как эта точка будет достигнута.
* `finish [frame-number]` (или `fin`): выполняет, пока не возвратится выделенный кадр стека. Если номер кадра не задан, приложение будет запущено пока не возвратится текущий выделенный кадр. Текущий выделенный кадр начинается от самых последних, или с 0, если позиционирование кадров (т.е. up, down или frame) не было выполнено. Если задан номер кадра, будет выполняться, пока не вернется указанный кадр.

### Редактирование

Две команды позволяют открыть код из отладчика в редакторе:

* `edit [file:line]`: редактирует файл _file_, используя редактор, определенный переменной среды EDITOR. Определенная линия _line_ также может быть задана.

### Выход

Чтобы выйти из отладчика, используйте команду `quit` (сокращенно `q`), или ее псевдоним `exit`.

Простой выход пытается прекратить все нити в результате. Поэтому ваш сервер будет остановлен и нужно будет стартовать его снова.

### Настройки

У `byebug` имеется несколько доступных опций для настройки его поведения:

* `set autoreload`: Перезагрузить исходный код при изменении (по умолчанию true).
* `set autolist`: Запускать команду `list` на каждой точке останова (по умолчанию true).
* `set listsize _n_`: Установить количество строчек кода для отображения по умолчанию _n_
(по умолчанию 10).
* `set forcestep`: Убеждаться, что команды `next` и `step` всегда переходят на новую строчку.

Можно просмотреть полный перечень, используя `help set`. Используйте `help set _subcommand_` для изучения определенной команды `set`.

TIP: Эти настройки могут быть сохранены в файле `.byebugrc` в домашней директории. debugger считывает эти глобальные настройки при запуске. Например:

```bash
set forcestep
set listsize 25
```

Отладка с помощью гема `web-console`
------------------------------------

Web Console немного похож на `byebug`, но запускается в браузере. На любой разрабатываемой вами странице, вы можете запустить консоль в контексте вьюхи или контроллера. Консоль отрендерит содержимое HTML.

### Консоль

Внутри экшена контроллера или вьюхи, вы можете вызвать консоль с помощью метода `console`.

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

Это отрендерит консоль внутри вьюхи. Вам не нужно беспокоится о месте вызова `console`, это не будет отрисовано на месте команды, а после вашего HTML содержимого.

Консоль выполняет чистый Ruby code: вы можете определить или инициализировать собственные классы, создавать новые модели и проверять переменные.

NOTE: Только одна консоль может быть отрисована за один запрос. Иначе `web-console` вызовет ошибку при выполнении второго `console`.

### Проверка переменных

Вы можете вызвать `instance_variables` для вывода всех инстанс переменных, доступных в контексте. Если вы хотите получить список всех локальных переменных, вы можете сделать это с помощью `local_variables`.

### Настройки

* `config.web_console.whitelisted_ips`: Список авторизованных IPv4 или IPv6
адресов и сетей (по умолчанию: `127.0.0.1/8, ::1`).
* `config.web_console.whiny_requests`: Выводить сообщение, когда консоль не может быть отрисована (по умолчанию: `true`).

Поскольку `web-console` выполняет чистый Ruby код удаленно на сервере, не пытайтесь использовать это в production.

Отладка утечки памяти
---------------------

Приложение Ruby (на Rails или нет), может съедать память - или в коде Ruby, или на уровне кода C.

В этом разделе вы научитесь находить и исправлять такие утечки, используя инструмент отладки Valgrind.

### Valgrind

[Valgrind](http://valgrind.org/) - это приложение для Linux для обнаружения утечек памяти, основанных на C, и гонки условий.

Имеются инструменты Valgrind, которые могут автоматически обнаруживать многие баги управления памятью и тредами, и подробно профилировать ваши программы. Например, если расширение C в интерпретаторе вызывает `malloc()`, но не вызывает должным образом `free()`, эта память не будет доступна, пока приложение не будет остановлено.

Чтобы узнать подробности, как установить Valgrind и использовать его с Ruby, обратитесь к [Valgrind and Ruby](http://blog.evanweaver.com/articles/2008/02/05/valgrind-and-ruby/) by Evan Weaver.

Плагины для отладки
-------------------

Имеются некоторые плагины Rails, помогающие в поиске ошибок и отладке вашего приложения. Вот список полезных плагинов для отладки:

* [Footnotes](https://github.com/josevalim/rails-footnotes): У каждой страницы Rails есть сноска, дающая информацию о запросе и ссылку на исходный код через TextMate.
* [Query Trace](https://github.com/ruckus/active-record-query-trace/tree/master): Добавляет трассировку запросов в ваши логи.
* [Query Reviewer](https://github.com/nesquena/query_reviewer): Этот плагин Rails не только запускает "EXPLAIN" перед каждым из ваших запросов select в development, но и представляет небольшой DIV в отрендеренном результате каждой страницы со сводкой предупреждений по каждому проанализированному запросу.
* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master): Предоставляет объект рассыльщика и набор шаблонов по умолчанию для отправки уведомлений по email, когда происходят ошибки в приложении в Rails.
* [Better Errors](https://github.com/charliesome/better_errors): Заменяет стандартную страницу ошибки Rails новой, содержащей больше контекстной информации, такой как исходный код и просмотр переменных.
* [RailsPanel](https://github.com/dejan/rails_panel): Расширение для Chrome для разработки на Rails, которое подхватывает изменения в development.log. Всю информацию о запросах к приложинеию Rails можно смотреть в браузере, в панели Developer Tools. Предоставляет обзор времени db/rendering/total, списка параметров, отрендеренных вьюх и так далее.

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
