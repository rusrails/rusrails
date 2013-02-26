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

Одной из обычных задач является проверить содержимое переменной. В Rails это можно сделать тремя методами:

* `debug`
* `to_yaml`
* `inspect`

### `debug`

Хелпер `debug` возвратит тег \<pre>, который рендерит объект, с использованием формата YAML. Это создаст читаемые данные из объекта. Например, если у вас такой код во вьюхе:

```html+erb
<%= debug @post %>
<p>
  <b>Title:</b>
  <%= @post.title %>
</p>
```

Вы получите что-то наподобие этого:

```yaml
--- !ruby/object:Post
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

Отображение переменной экземпляра или любого другого объекта или метода в формате yaml может быть достигнуто следующим образом:

```html+erb
<%= simple_format @post.to_yaml %>
<p>
  <b>Title:</b>
  <%= @post.title %>
</p>
```

Метод `to_yaml` преобразует метод в формат YAML, оставив его более читаемым, а затем используется хелпер `simple_format` для рендера каждой строки как в консоли. Именно так и работает метод `debug`.

В результате получится что-то вроде этого во вашей вьюхе:

```yaml
--- !ruby/object:Post
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
  <%= @post.title %>
</p>
```

Отрендерит следующее:

```
[1, 2, 3, 4, 5]

Title: Rails debugging guide
```

Логгер
------

Также может быть полезным сохранять информацию в файл лога в процессе выполнения. Rails поддерживает отдельный файл лога для каждой среды запуска.

### Что такое Логгер?

Rails использует класс `ActiveSupport::Logger` для записи информации в лог. Вы также можете заменить его другим логгером, таким как `Log4R`, если хотите.

Альтернативный логгер можно определить в вашем `environment.rb` или любом файле среды:

```ruby
Rails.logger = Logger.new(STDOUT)
Rails.logger = Log4r::Logger.new("Application Log")
```

Или в разделе `Initializer` добавьте _одно из_ следующего

```ruby
config.logger = Logger.new(STDOUT)
config.logger = Log4r::Logger.new("Application Log")
```

TIP: По умолчанию каждый лог создается в `RAILS_ROOT/log/` с именем файла лога `environment_name.log`.

### Уровни лога

Когда что-то логируется, оно записывается в соответствующий лог, если уровень лога сообщения равен или выше чем настроенный уровень лога. Если хотите узнать текущий уровень лога, вызовите метод `ActiveRecord::Base.logger.level`.

Доступные уровни лога следующие: `:debug`, `:info`, `:warn`, `:error`, `:fatal` и `:unknown`, соответствующие номерам уровня лога от 0 до 5 соответственно. Чтобы изменить уровень лога по умолчанию, используйте

```ruby
config.log_level = :warn # В любом инициализаторе среды, или
ActiveRecord::Base.logger.level = 0 # в любое время
```

Это полезно, когда вы хотите логировать при разработке или установке, но не хотите замусорить рабочий лог ненужной информацией.

TIP: Уровень лога Rails по умолчанию это `info` в рабочем режиме и `debug` в режиме разработки и тестирования.

### Отправка сообщений

Чтобы писать в текущий лог, используйте метод `logger.(debug|info|warn|error|fatal)` внутри контроллера, модели или рассыльщика:

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
logger.info "Processing the request..."
logger.fatal "Terminating application, raised unrecoverable error!!!"
```

Вот пример метода, оборудованного дополнительным логированием:

```ruby
class PostsController < ApplicationController
  # ...

  def create
    @post = Post.new(params[:post])
    logger.debug "New post: #{@post.attributes.inspect}"
    logger.debug "Post should be valid: #{@post.valid?}"

    if @post.save
      flash[:notice] = 'Post was successfully created.'
      logger.debug "The post was saved and now the user is going to be redirected..."
      redirect_to(@post)
    else
      render action: "new"
    end
  end

  # ...
end
```

Вот пример лога, созданного этим методом:

```
Processing PostsController#create (for 127.0.0.1 at 2008-09-08 11:52:54) [POST]
  Session ID: BAh7BzoMY3NyZl9pZCIlMDY5MWU1M2I1ZDRjODBlMzkyMWI1OTg2NWQyNzViZjYiCmZsYXNoSUM6J0FjdGl
vbkNvbnRyb2xsZXI6OkZsYXNoOjpGbGFzaEhhc2h7AAY6CkB1c2VkewA=--b18cd92fba90eacf8137e5f6b3b06c4d724596a4
  Parameters: {"commit"=>"Create", "post"=>{"title"=>"Debugging Rails",
 "body"=>"I'm learning how to print in logs!!!", "published"=>"0"},
 "authenticity_token"=>"2059c1286e93402e389127b1153204e0d1e275dd", "action"=>"create", "controller"=>"posts"}
New post: {"updated_at"=>nil, "title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs!!!",
 "published"=>false, "created_at"=>nil}
Post should be valid: true
  Post Create (0.000443)   INSERT INTO "posts" ("updated_at", "title", "body", "published",
 "created_at") VALUES('2008-09-08 14:52:54', 'Debugging Rails',
 'I''m learning how to print in logs!!!', 'f', '2008-09-08 14:52:54')
The post was saved and now the user is going to be redirected...
Redirected to #<Post:0x20af760>
Completed in 0.01224 (81 reqs/sec) | DB: 0.00044 (3%) | 302 Found [http://localhost/posts]
```

Добавление дополнительного логирования, подобного этому, облегчает поиск неожиданного или необычного поведения в ваших логах. Если добавляете дополнительное логирование, убедитесь в разумном использовании уровней лога, для избежания заполнения ваших рабочих логов ненужными мелочами.

### Тегированное логирование

При запуске многопользовательских приложений часто полезно фильтровать логи с использованием произвольных правил. `TaggedLogging` в Active Support помогает это сделать, помечая строчки лога с помощью поддомена, идентификаторов запроса, и тому подобного, помогая отладке таких приложений.

```ruby
logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
logger.tagged("BCX") { logger.info "Stuff" }                            # Logs "[BCX] Stuff"
logger.tagged("BCX", "Jason") { logger.info "Stuff" }                   # Logs "[BCX] [Jason] Stuff"
logger.tagged("BCX") { logger.tagged("Jason") { logger.info "Stuff" } } # Logs "[BCX] [Jason] Stuff"
```

Отладка с помощью гема "debugger"
---------------------------------

Когда ваш код ведет себя неожиданным образом, можете печатать в логи или консоль, чтобы выявить проблему. К сожалению, иногда бывает, что такой способ отслеживания ошибки не эффективен в поиске причины проблемы. Когда вы фактически нуждаетесь в путешествии вглубь исполняемого кода, отладчик - это ваш лучший напарник.

Отладчик также может помочь, если хотите изучить исходный код Rails, но не знаете с чего начать. Просто отладьте любой запрос к своему приложению и используйте это руководство для изучения, как идет движение от написанного вами кода глубже в код Rails.

### Установка

Rails использует гем `debugger` для настройки точек останова и прохождения через живой код. Чтобы установить его, просто запустите:

```bash
$ gem install debugger
```

В Rails есть встроенная поддержка отладки, начиная с Rails 2.0. Внутри любого приложения на Rails можно вызывать отладчик, вызвав метод `debugger`.

Вот пример:

```ruby
class PeopleController < ApplicationController
  def new
    debugger
    @person = Person.new
  end
end
```

Если видите сообщение в консоли или логах:

```
***** Debugger requested, but was not available: Start server with --debugger to enable *****
```

Убедитесь, что запустили свой веб сервер с опцией `--debugger`:

```bash
$ rails server --debugger
=> Booting WEBrick
=> Rails 3.0.0 application starting on http://0.0.0.0:3000
=> Debugger enabled
...
```

TIP: В режиме development можно динамически вызвать `require \'debugger\'` вместо перезапуска сервера, если он был запущен без `--debugger`.

### Среда

Как только приложение вызывает метод `debugger`, отладчик будет запущен в среде отладчика в окне терминала, в котором запущен сервер приложения, и будет представлена строка debugger `(rdb:n)`. _n_ это число тредов. Строка также показывает следующую линию кода, которая ожидает выполнения.

Если был получен запрос от браузера, закладка браузера, содержащая запрос, будет висеть, пока отладчик не закончит, и трассировка не закончит обрабатывать весь запрос.

Например:

```bash
@posts = Post.all
(rdb:7)
```

Настало время изучить и покопаться в вашем приложении. Для начала хорошо бы попросить помощь у отладчика... поэтому напишите: `help` (Неожиданно, правда?)

```
(rdb:7) help
ruby-debug help v0.10.2
Type 'help <command-name>' for help on a specific command

Available commands:
backtrace  delete   enable  help    next  quit     show    trace
break      disable  eval    info    p     reload   source  undisplay
catch      display  exit    irb     pp    restart  step    up
condition  down     finish  list    ps    save     thread  var
continue   edit     frame   method  putl  set      tmate   where
```

TIP: Чтобы просмотреть помощь для любой команды, используйте `help <имя команды>` в активном режиме отладки. Например: _`help var`_

Следующая команда, которую мы изучим, одна из самых полезных: `list`. Можно сокращать любые отладочные команды, предоставляя только достаточные буквы для отличения их от других команд, поэтому можно использовать `l` для команды `list`.

Эта команда показывает, где вы сейчас в коде, печатая 10 линий с текущей линией в центре; текущая линия в этом случая шестая и помеченная `=>`.

```
(rdb:7) list
[1, 10] in /PathToProject/posts_controller.rb
   1  class PostsController < ApplicationController
   2    # GET /posts
   3    # GET /posts.json
   4    def index
   5      debugger
=> 6      @posts = Post.all
   7
   8      respond_to do |format|
   9        format.html # index.html.erb
   10        format.json { render :json => @posts }
```

Если повторите команду `list`, сейчас уже используем лишь `l`, будут выведены следующие 10 линий файла.

```
(rdb:7) l
[11, 20] in /PathTo/project/app/controllers/posts_controller.rb
   11      end
   12    end
   13
   14    # GET /posts/1
   15    # GET /posts/1.json
   16    def show
   17      @post = Post.find(params[:id])
   18
   19      respond_to do |format|
   20        format.html # show.html.erb
```

И так далее до конца текущего файла. Когда достигнут конец файла, команда `list` запустится снова с начала файла и продолжится опять до конца, обрабатывая файл как цикличный буфер.

С другой стороны, чтобы увидеть предыдущие десять линий, следует написать `list-` или `l-`.

```
(rdb:7) l-
[1, 10] in /PathToProject/posts_controller.rb
   1  class PostsController < ApplicationController
   2    # GET /posts
   3    # GET /posts.json
   4    def index
   5      debugger
   6      @posts = Post.all
   7
   8      respond_to do |format|
   9        format.html # index.html.erb
   10        format.json { render :json => @posts }
```

Таким образом можно перемещаться внутри файла, просматривая код до и после строки, в которую вы добавили `debugger`. Наконец, чтобы снова увидеть, где вы в коде сейчас, можно написать `list=`.

```
(rdb:7) list=
[1, 10] in /PathToProject/posts_controller.rb
   1  class PostsController < ApplicationController
   2    # GET /posts
   3    # GET /posts.json
   4    def index
   5      debugger
=> 6      @posts = Post.all
   7
   8      respond_to do |format|
   9        format.html # index.html.erb
   10        format.json { render :json => @posts }
```

### Контекст

Когда начинаете отладку своего приложения, вы будете помещены в различные контексты, так как проходите через различные части стека.

debugger создает контекст, когда достигается точка останова или событие. У контекста есть информация о приостановленной программе, которая позволяет отладчику просматривать кадр стека, значения переменных с точки зрения отлаживаемой программы, и в нем содержится информация о месте, в котором отлаживаемая программа остановилась.

В любое время можете вызвать команду `backtrace` (или ее псевдоним `where`), чтобы напечатать трассировку приложения. Это полезно для того, чтобы знать, где вы есть. Если вы когда-нибудь задумывались, как вы получили что-то в коде, то `backtrace` предоставит ответ.

```
(rdb:5) where
    #0 PostsController.index
       at line /PathTo/project/app/controllers/posts_controller.rb:6
    #1 Kernel.send
       at line /PathTo/project/vendor/rails/actionpack/lib/action_controller/base.rb:1175
    #2 ActionController::Base.perform_action_without_filters
       at line /PathTo/project/vendor/rails/actionpack/lib/action_controller/base.rb:1175
    #3 ActionController::Filters::InstanceMethods.call_filters(chain#ActionController::Fil...,...)
       at line /PathTo/project/vendor/rails/actionpack/lib/action_controller/filters.rb:617
...
```

Можете перейти, куда хотите в этой трассировке (это изменит контекст) с использованием команды `frame _n_`, где _n_ это определенный номер кадра.

```
(rdb:5) frame 2
#2 ActionController::Base.perform_action_without_filters
       at line /PathTo/project/vendor/rails/actionpack/lib/action_controller/base.rb:1175
```

Доступные переменные те же самые, как если бы вы запускали код строка за строкой. В конце концов, это то, что отлаживается.

Перемещение по кадру стека: можете использовать команды `up [n]` (скоращенно `u`) и `down [n]` для того, чтобы изменить контекст на _n_ кадров вверх или вниз по стеку соответственно. _n_ по умолчанию равно одному. Up в этом случае перейдет к кадрам стека с большим номером, а down к кадрам с меньшим номером.

### Нити (threads)

Отладчик может просматривать, останавливать, возобновлять и переключаться между запущенными нитями с использованием команды `thread` (или сокращенно `th`). У этой команды есть несколько опций:

* `thread` показывает текущую нить
* `thread list` используется для отображения всех нитей и их статусов. Символ плюс ` и число показывают текущую нить выполнения.
* `thread stop _n_` останавливает нить _n_.
* `thread resume _n_` возобновляет нить _n_.
* `thread switch _n_` переключает контекст текущей нити на _n_.

Эта команда очень полезна, в частности когда вы отлаживаете параллельные нити и нужно убедиться, что в коде нет состояния гонки.

### Просмотр переменных

Любое выражение может быть вычислено в текущем контексте. Чтобы вычислить выражение, просто напечатайте его!

Этот пример покажет, как можно напечатать instance_variables, определенные в текущем контексте:

```
@posts = Post.all
(rdb:11) instance_variables
["@_response", "@action_name", "@url", "@_session", "@_cookies", "@performed_render", "@_flash", "@template", "@_params", "@before_filter_chain_aborted", "@request_origin", "@_headers", "@performed_redirect", "@_request"]
```

Как вы уже поняли, отображены все переменные, к которым есть доступ из контроллера. Этот перечень динамически обновляется по мере выполнения кода. Например, запустим следующую строку, используя `next` (мы рассмотрим эту команду чуть позднее в этом руководстве).

```
(rdb:11) next
Processing PostsController#index (for 127.0.0.1 at 2008-09-04 19:51:34) [GET]
  Session ID: BAh7BiIKZmxhc2hJQzonQWN0aW9uQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7AA==--b16e91b992453a8cc201694d660147bba8b0fd0e
  Parameters: {"action"=>"index", "controller"=>"posts"}
/PathToProject/posts_controller.rb:8
respond_to do |format|
```

И затем снова спросим instance_variables:

```
(rdb:11) instance_variables.include? "@posts"
true
```

Теперь `@posts` включена в переменные экземпляра, поскольку определяющая ее строка была выполнена.

TIP: Также можно шагнуть в режим **irb** с командой `irb` (конечно!). Таким образом, сессия irb будет запущена в контексте, который ее вызвал. Но предупреждаем: это эксперементальная особенность.

Метод `var` это более удобный способ показать переменные и их значения:

```
var
(rdb:1) v[ar] const <object>            показывает константы объекта
(rdb:1) v[ar] g[lobal]                  показывает глобальные переменные
(rdb:1) v[ar] i[nstance] <object>       показывает переменные экземпляра объекта
(rdb:1) v[ar] l[ocal]                   показывает локальные переменные
```

Это отличный способ просмотреть значения переменных текущего контекста. Например:

```
(rdb:9) var local
  __dbg_verbose_save => false
```

Также можно просмотреть метод объекта следующим образом:

```
(rdb:9) var instance Post.new
@attributes = {"updated_at"=>nil, "body"=>nil, "title"=>nil, "published"=>nil, "created_at"...
@attributes_cache = {}
@new_record = true
```

TIP: Команды `p` (print) и `pp` (pretty print) могут использоваться для вычисления выражений Ruby и отображения значения переменных в консоли.

Можете также использовать `display` для запуска просмотра переменных. Это хороший способ трассировки значений переменной на протяжении выполнения.

```
(rdb:1) display @recent_comments
1: @recent_comments =
```

Переменные в отображаемом перечне будут печататься с их значениями после помещения в стек. Чтобы остановить отображение переменной, используйте `undisplay _n_`, где _n_ это номер переменной (1 в последнем примере).

### Шаг за шагом

Теперь вы знаете, где находитесь в запущенной трассировке, и способны напечатать доступные переменные. Давайте продолжим и ознакомимся с выполнением приложения.

Используйте `step` (сокращенно `s`) для продолжения запуска вашей программы до следующей логической точки останова и возврата контроля debugger.

TIP: Также можно использовать <tt>step+ n</tt> и <tt>step- n</tt> для движения вперед или назад на `n` шагов соответственно.

Также можете использовать _next_, которая похожа на step, но вызовы функции или метода, выполняемые в строке кода, выполняются без остановки. Как и со step, можно использовать знак плюса для перемещения на _n_ шагов.

Разница между `next` и `step` в том, что `step` останавливается на следующей линии выполняемого кода, делая лишь один шаг, в то время как `next` перемещает на следующую строку без входа внутрь методов.

Например, рассмотрим этот блок кода с включенным выражением `debugger`:

```ruby
class Author < ActiveRecord::Base
  has_one :editorial
  has_many :comments

  def find_recent_comments(limit = 10)
    debugger
    @recent_comments ||= comments.where("created_at > ?", 1.week.ago).limit(limit)
  end
end
```

TIP: Можете использовать debugger при использовании `rails console`. Просто не забудьте вызвать `require "debugger"` перед вызовом метода `debugger`.

```
$ rails console
Loading development environment (Rails 3.1.0)
>> require "debugger"
=> []
>> author = Author.first
=> #<Author id: 1, first_name: "Bob", last_name: "Smith", created_at: "2008-07-31 12:46:10", updated_at: "2008-07-31 12:46:10">
>> author.find_recent_comments
/PathTo/project/app/models/author.rb:11
)
```

С остановленным кодом, давайте оглянемся:

```
(rdb:1) list
[2, 9] in /PathTo/project/app/models/author.rb
   2    has_one :editorial
   3    has_many :comments
   4
   5    def find_recent_comments(limit = 10)
   6      debugger
=> 7      @recent_comments ||= comments.where("created_at > ?", 1.week.ago).limit(limit)
   8    end
   9  end
```

Вы в конце линии, но была ли эта линия выполнена? Можете просмотреть переменные экземпляра.

```
(rdb:1) var instance
@attributes = {"updated_at"=>"2008-07-31 12:46:10", "id"=>"1", "first_name"=>"Bob", "las...
@attributes_cache = {}
```

`@recent_comments` пока еще не определена, поэтому ясно, что эта линия еще не выполнялась. Используем команду `next` для движения дальше по коду:

```
(rdb:1) next
/PathTo/project/app/models/author.rb:12
@recent_comments
(rdb:1) var instance
@attributes = {"updated_at"=>"2008-07-31 12:46:10", "id"=>"1", "first_name"=>"Bob", "las...
@attributes_cache = {}
@comments = []
@recent_comments = []
```

Теперь мы видим, что связь `@comments` была загружена и @recent_comments определена, поскольку линия была выполнена.

Если хотите войти глубже в трассировку стека, можете переместиться на один шаг `step`, через ваши вызывающие методы и в код Rails. Это лучший способ поиска багов в вашем коде, а возможно и в Ruby or Rails.

### Точки останова

Точка останова останавливает ваше приложение, когда достигается определенная точка в программе. В этой линии вызывается оболочка отладчика.

Можете добавлять точки останова динамически с помощью команды `break` (или просто `b`). Имеются 3 возможных способа ручного добавления точек останова:

* `break line`: устанавливает точку останова в линии _line_ в текущем файле исходника.
* `break file:line [if expression]`: устанавливает точку останова в линии номер _line_ в файле _file_. Если задано условие _expression_, оно должно быть вычислено и равняться _true_, чтобы запустить отладчик.
* `break class(.|#)method [if expression]`: устанавливает точку останова в методе _method_ (. и # для метода класса и экземпляра соответственно), определенного в классе _class_. _expression_ работает так же, как и с file:line.

```
(rdb:5) break 10
Breakpoint 1 file /PathTo/project/vendor/rails/actionpack/lib/action_controller/filters.rb, line 10
```

Используйте `info breakpoints _n_` или `info break _n_` для отображения перечня точек останова. Если укажете номер, отобразится только эта точка останова. В противном случае отобразятся все точки останова.

```
(rdb:5) info breakpoints
Num Enb What
  1 y   at filters.rb:10
```

Чтобы удалить точки останова: используйте команду `delete _n_` для устранения точки останова номер _n_. Если номер не указан, удалятся все точки останова, которые в данный момент активны..

```
(rdb:5) delete 1
(rdb:5) info breakpoints
No breakpoints.
```

Также можно включить или отключить точки останова:

* `enable breakpoints`: позволяет перечню _breakpoints_ или всем им, если перечень не определен, останавливать вашу программу. Это состояние по умолчанию для создаваемых точек останова.
* `disable breakpoints`: _breakpoints_ не будут влиять на вашу программу.

### Вылов исключений

Команда `catch exception-name` (или просто `cat exception-name`) может использоваться для перехвата исключения типа _exception-name_, когда в противном случае был бы вызван обработчик для него.

Чтобы просмотреть все активные точки перехвата, используйте `catch`.

### Возобновление исполнения

Есть два способа возобновления выполнения приложения, которое было остановлено отладчиком:

* `continue` [line-specification] (или `c`): возобновляет выполнение программы с адреса, где ваш скрипт был последний раз остановлен; любые точки останова, установленные на этом адресе будут пропущены. Дополнительный аргумент line-specification позволяет вам определить число линий для установки одноразовой точки останова, которая удаляется после того, как эта точка будет достигнута.
* `finish` [frame-number] (или `fin`): выполняет, пока не возвратится выделенный кадр стека. Если номер кадра не задан, приложение будет запущено пока не возвратиться текущий выделенный кадр. Текущий выделенный кадр начинается от самых последних, или с 0, если позиционирование кадров (т.е. up, down или frame) не было выполнено. Если задан номер кадра, будет выполняться, пока не вернется указанный кадр.

### Редактирование

Две команды позволяют открыть код из отладчика в редакторе:

* `edit [file:line]`: редактирует файл _file_, используя редактор, определенный переменной среды EDITOR. Определенная линия _line_ также может быть задана.
* `tmate _n_` (сокращенно `tm`): открывает текущий файл в TextMate. Она использует n-ный кадр, если задан _n_.

### Выход

Чтобы выйти из отладчика, используйте команду `quit` (сокращенно `q`), или ее псевдоним `exit`.

Простой выход пытается прекратить все нити в результате. Поэтому ваш сервер будет остановлен и нужно будет стартовать его снова.

### Настройки

Гем `debugger` может автоматически показывать код, через который вы проходите, и перегружать его, когда вы изменяете его в редакторе. Вот несколько доступных опций:

* `set reload`: презагрузить исходный код при изменении.
* `set autolist`: Запускать команду `list` на каждой точке останова.
* `set listsize _n_`: Установить количество линий кода для отображения по умолчанию _n_.
* `set forcestep`: Убеждаться, что команды `next` и `step` всегда переходят на новую линию

Можно просмотреть полный перечень, используя `help set`. Используйте `help set _subcommand_` для изучения определенной команды `set`.

TIP: Эти настройки могут быть сохранены в файле `.rdebugrc` в домашней директории. debugger считывает эти глобальные настройки при запуске.

Вот хорошее начало для `.rdebugrc`:

```bash
set autolist
set forcestep
set listsize 25
```

Отладка утечки памяти
---------------------

Приложение Ruby (на Rails или нет), может съедать память - или в коде Ruby, или на уровне кода C.

В этом разделе вы научитесь находить и исправлять такие утечки, используя инструмент отладки Valgrind.

### Valgrind

[Valgrind](http://valgrind.org/) это приложение для Linux для обнаружения утечек памяти, основанных на C, и гонки условий.

Имеются инструменты Valgrind, которые могут автоматически обнаруживать многие баги управления памятью и тредами, и подробно профилировать ваши программы. Например, расширение C в интерпретаторе вызывает `malloc()` но не вызывает должным образом `free()`, эта память не будет доступна, пока приложение не будет остановлено.

Чтобы узнать подробности, как установить Valgrind и использовать его с Ruby, обратитесь к [Valgrind and Ruby](http://blog.evanweaver.com/articles/2008/02/05/valgrind-and-ruby/) by Evan Weaver.

Плагины для отладки
-------------------

Имеются некоторые плагины Rails, помогающие в поиске ошибок и отладке вашего приложения. Вот список полезных плагинов для отладки:

* [Footnotes](https://github.com/josevalim/rails-footnotes): У каждой страницы Rails есть сноска, дающая информацию о запросе и ссылку на исходный код через TextMate.
* [Query Trace](https://github.com/ntalbott/query_trace/tree/master): Добавляет трассировку запросов в ваши логи.
* [Query Reviewer](https://github.com/nesquena/query_reviewer): Этот плагин rails не только запускает "EXPLAIN" перед каждым из ваших запросов select в development, но и представляет небольшой DIV в отрендеренном результате каждой страницы со сводкой предупреждений по каждому проанализированному запросу.
* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master): Предоставляет объект рассыльщика и набор шаблонов по умолчанию для отправки уведомлений по email, когда происходят ошибки в приложении в Rails.

Ссылки
------

* [Домашняя страница ruby-debug](http://bashdb.sourceforge.net/ruby-debug/home-page.html)
* [Домашняя страница debugger](https://github.com/cldwalker/debugger)
* [Статья: Debugging a Rails application with ruby-debug](http://www.sitepoint.com/article/debug-rails-app-ruby-debug/)
* [Скринкаст ruby-debug Basics](http://brian.maybeyoureinsane.net/blog/2007/05/07/ruby-debug-basics-screencast/)
* [Скринкаст Ryan Bates' debugging ruby (revised)](http://railscasts.com/episodes/54-debugging-ruby-revised)
* [Скринкаст Ryan Bates' stack trace](http://railscasts.com/episodes/24-the-stack-trace)
* [Скринкаст Ryan Bates' logger](http://railscasts.com/episodes/56-the-logger)
* [Debugging with ruby-debug](http://bashdb.sourceforge.net/ruby-debug.html)
* [ruby-debug cheat sheet](http://cheat.errtheblog.com/s/rdebug/)
* [Вики Ruby on Rails: How to Configure Logging](http://wiki.rubyonrails.org/rails/pages/HowtoConfigureLogging)
