Отладка приложений на Rails
===========================

Это руководство представляет технику отладки приложений на Ruby on Rails.

После прочтения этого руководства, вы узнаете:

* Цель отладки
* Как отслеживать проблемы и вопросы в вашем приложении, которые не определили ваши тесты
* Различные способы отладки
* Как анализировать трассировку

Хелперы вью для отладки
-------------------------

Одной из обычных задач является проверить содержимое переменной. Rails предоставляет три пути как сделать это:

* `debug`
* `to_yaml`
* `inspect`

### `debug`

Хелпер `debug` возвратит тег \<pre>, который рендерит объект, с использованием формата YAML. Это сгенерирует читаемые данные из объекта. Например, если у вас такой код во вью:

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

Чтобы писать в текущий лог, используйте метод `logger.(debug|info|warn|error|fatal|unknown)` внутри контроллера, модели или рассыльщика:

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
      render :new, status: :unprocessable_entity
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
Started POST "/articles" for 127.0.0.1 at 2018-10-18 20:09:23 -0400
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"XLveDrKzF1SwaiNRPTaMtkrsTzedtebPPkmxEFIU0ordLjICSnXsSNfrdMa4ccyBjuGwnnEiQhEoMN6H1Gtz3A==", "article"=>{"title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs.", "published"=>"0"}, "commit"=>"Create Article"}
New article: {"id"=>nil, "title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs.", "published"=>false, "created_at"=>nil, "updated_at"=>nil}
Article should be valid: true
   (0.0ms)  begin transaction
  ↳ app/controllers/articles_controller.rb:31
  Article Create (0.5ms)  INSERT INTO "articles" ("title", "body", "published", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["title", "Debugging Rails"], ["body", "I'm learning how to print in logs."], ["published", 0], ["created_at", "2018-10-19 00:09:23.216549"], ["updated_at", "2018-10-19 00:09:23.216549"]]
  ↳ app/controllers/articles_controller.rb:31
   (2.3ms)  commit transaction
  ↳ app/controllers/articles_controller.rb:31
The article was saved and now the user is going to be redirected...
Redirected to http://localhost:3000/articles/1
Completed 302 Found in 4ms (ActiveRecord: 0.8ms)
```

Добавление дополнительного логирования, подобного этому, облегчает поиск неожиданного или необычного поведения в ваших логах. Если добавляете дополнительное логирование, убедитесь в разумном использовании уровней лога, для избежания заполнения ваших рабочих логов ненужными мелочами.

### Подробные логи запроса Query Logs

При взгляде на вывод запросов к базе данных в логах, может быть не до конца понятным, почему выполняются несколько запросов при вызове одного метода:

```
irb(main):001:0> Article.pamplemousse
  Article Load (0.4ms)  SELECT "articles".* FROM "articles"
  Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```

После запуска `ActiveRecord.verbose_query_logs = true` в сессии `bin/rails console`, чтобы включить подробные логи, и запуска метода снова, становится ясным, что единственная строчка кода генерирует все эти отдельные запросы к базе данных:

```
irb(main):003:0> Article.pamplemousse
  Article Load (0.2ms)  SELECT "articles".* FROM "articles"
  ↳ app/models/article.rb:5
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  ↳ app/models/article.rb:6
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  ↳ app/models/article.rb:6
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
  ↳ app/models/article.rb:6
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```

Под каждым выражением базы данных можно увидеть стрелки, указывающие на определенное имя файла исходного кода (и номер строчки) метода, приведшего к вызову базы данных. Это может помочь обнаружить и обойти проблемы быстродействия, вызванные N+1 запросом: отдельные запросы к базе данных, генерирующие множество дополнительных запросов.

Подробные логи запросов включены по умолчанию в среде development после Rails 5.2.

WARNING: Мы отговариваем от использования этой настройки в среде production. Она полагается на метод Ruby `Kernel#caller`, который, как правило, использует много памяти для генерации трассировок стека вызовов метода. Вместо этого используйте теги логов (смотрите ниже).

Комментарии в запросе SQL
-------------------------

Выражения SQL могут быть откомментированы с помощью тегов, содержащих информацию о выполнении, такой как имя контроллера или задачи, чтобы связать проблемные запросы с областью приложения, сгенерировавшей эти выражения. Это полезно, когда вы логируете медленные запросы (например, [MySQL](https://dev.mysql.com/doc/refman/en/slow-query-log.html), [PostgreSQL](https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-MIN-DURATION-STATEMENT)), просматриваете текущие запущенные запросы, или для end-to-end инструментов отслеживания.

Чтобы включить, добавьте в `application.rb` или любом инициализаторе среды:

```rb
config.active_record.query_log_tags_enabled = true
```

По умолчанию логируются имя приложения, имя и экшн контроллера, или имя задачи. Формат по умолчанию [SQLCommenter](https://open-telemetry.github.io/opentelemetry-sqlcommenter/). Например:

```
Article Load (0.2ms)  SELECT "articles".* FROM "articles" /*application='Blog',controller='articles',action='index'*/

Article Update (0.3ms)  UPDATE "articles" SET "title" = ?, "updated_at" = ? WHERE "posts"."id" = ? /*application='Blog',job='ImproveTitleJob'*/  [["title", "Improved Rails debugging guide"], ["updated_at", "2022-10-16 20:25:40.091371"], ["id", 1]]
```

Поведение [`ActiveRecord::QueryLogs`](https://api.rubyonrails.org/classes/ActiveRecord/QueryLogs.html) может быть изменено, чтобы включить все, что поможет идентифицировать запрос SQL, такое как id запроса или задачи для логов приложения, идентификаторы учетной записи и владельца, и так далее.

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

В этом примере будет воздействие на производительность, даже если допустимый уровень вывода не включает debug. Причина этого в том, что Ruby вычисляет эти строки, включая инициализацию относительно весомого объекта `String` и интерполяцию переменных.

Следовательно, в методы логгера рекомендуется передавать блоки, так как они только вычисляются, если уровень вывода такой же или включен в допустимый (т.е. ленивая загрузка). Переписанный тот же код:

```ruby
logger.debug {"Person attributes hash: #{@person.attributes.inspect}"}
```

Содержимое блока и, следовательно, интерполяция строки будут только вычислены, если включен уровень debug. Экономия производительности будет реально заметна только при большом количестве логирования, но это все равно хорошая практика применения.

INFO: Этот подраздел в оригинале был написан [Jon Cairns в ответе на StackOverflow](https://stackoverflow.com/questions/16546730/logging-in-rails-is-there-any-performance-hit/16546935#16546935) и лицензирован по [cc by-sa 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

Отладка с помощью гема "debug"
------------------------------

Когда ваш код ведет себя неожиданным образом, можете печатать в логи или консоль, чтобы выявить проблему. К сожалению, иногда бывает, что такой способ отслеживания ошибки не эффективен в поиске причины проблемы. Когда вы фактически нуждаетесь в путешествии вглубь исполняемого кода, отладчик - это ваш лучший напарник.

Отладчик также может помочь, если хотите изучить исходный код Rails, но не знаете с чего начать. Просто отладьте любой запрос к своему приложению и используйте это руководство для изучения, как идет движение от написанного вами кода в основной код Rails.

Rails 7 включает гем `debug` в `Gemfile` нового приложения, сгенерированного CRuby. По умолчанию он подготовлен к работе в средах `development` и `test`. Чтобы узнать, как его использовать, обратитесь к его [документации](https://github.com/ruby/debug).

### Вход в сессию отладки

По умолчанию сессия отладки начнется после подключения библиотеки `debug`, что происходит при запуске вашего приложения. Но не беспокойтесь, сессия не будет вмешиваться в вашу программу.

Чтобы войти в сессию отладки, можно использовать `binding.break` и его псевдонимы: `binding.b` и `debugger`. Нижеследующие примеры будут использовать `debugger`:

```rb
class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all
    debugger
  end
  # ...
end
```

Как только ваше приложение вычислит выражение отладки, оно войдет в сессию отладки:

```rb
Processing by PostsController#index as HTML
[2, 11] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg)
```

Из сессии отладки можно выйти в любое время и продолжить выполнение вашего приложения с помощью команды `continue` (или `c`).  Или, чтобы выйти и из сессии отладки, и из вашего приложения, используйте команду `quit` (или `q`).

### Контекст

После входа в сессию отладки, можно писать код на Ruby, как будто в консоли Rails или IRB.

```rb
(rdbg) @posts    # ruby
[]
(rdbg) self
#<PostsController:0x0000000000aeb0>
(rdbg)
```

Также можно использовать команду `p` или `pp`, чтобы вычислить выражение Ruby (например, когда имя переменной конфликтует с командой отладчика).

```rb
(rdbg) p headers    # command
=> {"X-Frame-Options"=>"SAMEORIGIN", "X-XSS-Protection"=>"1; mode=block", "X-Content-Type-Options"=>"nosniff", "X-Download-Options"=>"noopen", "X-Permitted-Cross-Domain-Policies"=>"none", "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg) pp headers    # command
{"X-Frame-Options"=>"SAMEORIGIN",
 "X-XSS-Protection"=>"1; mode=block",
 "X-Content-Type-Options"=>"nosniff",
 "X-Download-Options"=>"noopen",
 "X-Permitted-Cross-Domain-Policies"=>"none",
 "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg)
```

Помимо непосредственного вычисления, отладчик также помогает собрать расширенное количество информации с помощью различных команд. Вот только некоторые из них:

- `info` (или `i`) - Информация о текущем фрейме.
- `backtrace` (или `bt`) - Трассировка (с дополнительной информацией).
- `outline` (или `o`, `ls`) - Доступные в текущей области видимости методы, константы, локальные переменные и переменные экземпляра.

#### Команда `info`

Она выдает обзор значений локальных переменных и переменных экземпляра, которые видны в текущем фрейме.

```rb
(rdbg) info    # command
%self = #<PostsController:0x0000000000af78>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fd91a037e38 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fd91a03ea08 @mon_data=#<Monitor:0x00007fd91a03e8c8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = []
@rendered_format = nil
```

#### Команда `backtrace`

При использовании без опций она перечисляет все фреймы стека:

```rb
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/basic_implicit_render.rb:6
  #2    AbstractController::Base#process_action(method_name="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/abstract_controller/base.rb:214
  #3    ActionController::Rendering#process_action(#arg_rest=nil) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/rendering.rb:53
  #4    block in process_action at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/abstract_controller/callbacks.rb:221
  #5    block in run_callbacks at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.1.0.alpha/lib/active_support/callbacks.rb:118
  #6    ActionText::Rendering::ClassMethods#with_renderer(renderer=#<PostsController:0x0000000000af78>) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.1.0.alpha/lib/action_text/rendering.rb:20
  #7    block {|controller=#<PostsController:0x0000000000af78>, action=#<Proc:0x00007fd91985f1c0 /Users/st0012/...|} in <class:Engine> (4 levels) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.1.0.alpha/lib/action_text/engine.rb:69
  #8    [C] BasicObject#instance_exec at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.1.0.alpha/lib/active_support/callbacks.rb:127
  ..... и так далее
```

Каждый фрейм содержит:

- Идентификатор фрейма
- Расположение вызова
- Дополнительную информацию (например, аргументы блока или метода)

Это даст вам хорошее ощущение того, что происходит в вашем приложении. Однако, вы, возможно, заметите, что:

- Фреймов очень много (обычно 50+ в приложении Rails).
- Большинство фреймов из Rails и других используемых библиотек.

Не беспокойтесь, команда `backtrace` предоставляет две опции, чтобы помочь с фильтрацией фреймов:

- `backtrace [num]` - показать только `num` штук фреймов, т.е. `backtrace 10`.
- `backtrace /pattern/` - показывать только фреймы с идентификатором или расположением, соответствующим образцу, т.е. `backtrace /MyModel/`.

Также возможно использовать эти опции вместе: `backtrace [num] /pattern/`.

#### Команда `outline`

Команда похожа на команду `ls` из `pry` и `irb`. Она покажет вам, что доступна в текущем пространстве, включая:

- Локальные переменные
- Переменные экземпляра
- Переменные класса
- Методы и их источники

```rb
ActiveSupport::Configurable#methods: config
AbstractController::Base#methods:
  action_methods  action_name  action_name=  available_action?  controller_path  inspect
  response_body
ActionController::Metal#methods:
  content_type       content_type=  controller_name  dispatch          headers
  location           location=      media_type       middleware_stack  middleware_stack=
  middleware_stack?  performed?     request          request=          reset_session
  response           response=      response_body=   response_code     session
  set_request!       set_response!  status           status=           to_a
ActionView::ViewPaths#methods:
  _prefixes  any_templates?  append_view_path   details_for_lookup  formats     formats=  locale
  locale=    lookup_context  prepend_view_path  template_exists?    view_paths
AbstractController::Rendering#methods: view_assigns

# .....

PostsController#methods: create  destroy  edit  index  new  show  update
instance variables:
  @_action_has_layout  @_action_name    @_config  @_lookup_context                      @_request
  @_response           @_response_body  @_routes  @marked_for_same_origin_verification  @posts
  @rendered_format
class variables: @@raise_on_missing_translations  @@raise_on_open_redirects
```

### Точки останова

Есть множество способов вставить и вызвать точку останова в отладчике. В дополнение к добавлению отладочных выражений (т.е. `debugger`) непосредственно в вашем коде, также можно вставить точки останова с помощью команд:

- `break` (или `b`)
  - `break` - отобразит все точки останова
  - `break <num>` - установит точку останова на строчке `num` текущего файла
  - `break <file:num>` - установит точку останова на строчке `num` в `file`
  - `break <Class#method>` или `break <Class.method>` - установит точку останова на `Class#method` или `Class.method`
  - `break <expr>.<method>` - установит точку останова на методе `<method>` результата `<expr>`.
- `catch <Exception>` - установит точку останова, которая остановится, когда вызовется исключение `Exception`
- `watch <@ivar>` - установит точку останова изменится результат `@ivar` текущего объекта (это медленно)

И чтобы их убрать, можно использовать:

- `delete` (или `del`)
  - `delete` - удалить все точки останова
  - `delete <num>` - удалить точку останова с идентификатором `num`

#### Команда `break`

**Устанавливаем точку останова на указанном номере строчки - т.е. `b 28`**

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg) b 28    # команда break
#0  BP - Line  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (line)
```

```rb
(rdbg) c    # команда continue
[23, 32] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    23|   def create
    24|     @post = Post.new(post_params)
    25|     debugger
    26|
    27|     respond_to do |format|
=>  28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
    30|         format.json { render :show, status: :created, location: @post }
    31|       else
    32|         format.html { render :new, status: :unprocessable_entity }
=>#0    block {|format=#<ActionController::MimeResponds::Collec...|} in create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:28
  #1    ActionController::MimeResponds#respond_to(mimes=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/mime_responds.rb:205
  # and 74 frames (use `bt' command for all frames)

Stop by #0  BP - Line  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (line)
```

**Устанавливаем точку останова на заданном вызове метода - т.е. `b @post.save`**

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg) b @post.save    # команда break
#0  BP - Method  @post.save at /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43

```

```rb
(rdbg) c    # команда continue
[39, 48] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb
    39|         SuppressorRegistry.suppressed[name] = previous_state
    40|       end
    41|     end
    42|
    43|     def save(**) # :nodoc:
=>  44|       SuppressorRegistry.suppressed[self.class.name] ? true : super
    45|     end
    46|
    47|     def save!(**) # :nodoc:
    48|       SuppressorRegistry.suppressed[self.class.name] ? true : super
=>#0    ActiveRecord::Suppressor#save(#arg_rest=nil) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:44
  #1    block {|format=#<ActionController::MimeResponds::Collec...|} in create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:28
  # and 75 frames (use `bt' command for all frames)

Stop by #0  BP - Method  @post.save at /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43
```

#### Команда `catch`

**Останавливаем при вызове исключения - т.е. `catch ActiveRecord::RecordInvalid`**

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save!
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg) catch ActiveRecord::RecordInvalid    # команда
#1  BP - Catch  "ActiveRecord::RecordInvalid"
```

```rb
(rdbg) c    # команда continue
[75, 84] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb
    75|     def default_validation_context
    76|       new_record? ? :create : :update
    77|     end
    78|
    79|     def raise_validation_error
=>  80|       raise(RecordInvalid.new(self))
    81|     end
    82|
    83|     def perform_validations(options = {})
    84|       options[:validate] == false || valid?(options[:context])
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  # and 88 frames (use `bt' command for all frames)

Stop by #1  BP - Catch  "ActiveRecord::RecordInvalid"
```

#### Команда `watch`

**Останавливаем, когда изменяется переменная экземпляра - т.е. `watch @_response_body`**

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save!
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg) watch @_response_body    # команда
#0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =
```

```rb
(rdbg) c    # команда continue
[173, 182] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal.rb
   173|       body = [body] unless body.nil? || body.respond_to?(:each)
   174|       response.reset_body!
   175|       return unless body
   176|       response.body = body
   177|       super
=> 178|     end
   179|
   180|     # Tests if render or redirect has already happened.
   181|     def performed?
   182|       response_body || response.committed?
=>#0    ActionController::Metal#response_body=(body=["<html><body>You are being <a href=\"ht...) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal.rb:178 #=> ["<html><body>You are being <a href=\"ht...
  #1    ActionController::Redirecting#redirect_to(options=#<Post id: 13, title: "qweqwe", content:..., response_options={:allow_other_host=>false}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/redirecting.rb:74
  # and 82 frames (use `bt' command for all frames)

Stop by #0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =  -> ["<html><body>You are being <a href=\"http://localhost:3000/posts/13\">redirected</a>.</body></html>"]
(rdbg)
```

#### Опции точки останова

В дополнение к различным типам точек останова, также можно указать опции для достижения более продвинутого процесса отладки. В настоящий момент отладчик поддерживает 4 опции:

- `do: <cmd or expr>` - когда срабатывает точка останова, выполнить заданную команду/выражение и продолжить программу:
  - `break Foo#bar do: bt` - когда вызывается `Foo#bar`, вывести фреймы стека
- `pre: <cmd or expr>` - когда срабатывает точка останова, выполнить заданную команду/выражение перед остановкой:
  - `break Foo#bar pre: info` - когда вызывается `Foo#bar`, вывести окружающие ее переменные перед остановкой.
- `if: <expr>` - точка останова останавливается, только если результат `<expr`> истинный:
  - `break Post#save if: params[:debug]` - останавливается на `Post#save`, если `params[:debug]` истинный
- `path: <path_regexp>` - точка останова останавливается, только если событие, ее вызывающее (например, вызов метода), происходит по заданному пути:
  - `break Post#save if: app/services/a_service` - останавливается на `Post#save`, если вызов метода происходит в методе, соответствующему регулярному выражению Ruby `/app\/services\/a_service/`.

Также отметьте, что первые 3 опции: `do:`, `pre:` и `if:` также доступны для выражений отладки, упомянутые ранее. Например:

```rb
[2, 11] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger(do: "info")
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg:binding.break) info
%self = #<PostsController:0x00000000017480>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fce3ad336b8 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fce3ad397e8 @mon_data=#<Monitor:0x00007fce3ad396a8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = #<ActiveRecord::Relation [#<Post id: 2, title: "qweqwe", content: "qweqwe", created_at: "...
@rendered_format = nil
```

#### Программируйте свой рабочий процесс отладки

С помощью этих опций можно записать свой процесс отладки в одну строчку, наподобие:

```rb
def create
  debugger(do: "catch ActiveRecord::RecordInvalid do: bt 10")
  # ...
end
```

И затем отладчик запустит записанную команду и вставит точку останова catch

```rb
(rdbg:binding.break) catch ActiveRecord::RecordInvalid do: bt 10
#0  BP - Catch  "ActiveRecord::RecordInvalid"
[75, 84] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb
    75|     def default_validation_context
    76|       new_record? ? :create : :update
    77|     end
    78|
    79|     def raise_validation_error
=>  80|       raise(RecordInvalid.new(self))
    81|     end
    82|
    83|     def perform_validations(options = {})
    84|       options[:validate] == false || valid?(options[:context])
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  # and 88 frames (use `bt' command for all frames)
```

Как только точка останова catch сработает, он выведет стек фреймов

```rb
Stop by #0  BP - Catch  "ActiveRecord::RecordInvalid"

(rdbg:catch) bt 10
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  #2    block in save! at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/transactions.rb:302
```

Такая техника может спасти вас от повторяющихся вводов вручную, и сделает опыт отладки более сглаженным.

Больше команд и конфигурационных опций можно найти в его [документации](https://github.com/ruby/debug).

Отладка с помощью гема `web-console`
------------------------------------

Web Console немного похож на `debug`, но запускается в браузере. Вы можете запустить консоль в контексте вью или контроллера на любой странице. Консоль отрендерит содержимое HTML.

### Консоль

Внутри экшна контроллера или вью, вы можете вызвать консоль с помощью метода `console`.

Например, в контроллере:

```ruby
class PostsController < ApplicationController
  def new
    console
    @post = Post.new
  end
end
```

Или во вью:

```html+erb
<% console %>

<h2>New Post</h2>
```

Это отрендерит консоль внутри вью. Вам не нужно беспокоится о месте расположения вызова `console`, это не будет отрисовано на месте команды, а после вашего HTML содержимого.

Консоль выполняет чистый Ruby code: вы можете определить или инициализировать собственные классы, создавать новые модели и проверять переменные.

NOTE: Только одна консоль может быть отрисована за один запрос. Иначе `web-console` вызовет ошибку при выполнении второго `console`.

### Проверка переменных

Вы можете вызвать `instance_variables` для вывода всех переменных экземпляра, доступных в контексте. Если вы хотите получить список всех локальных переменных, вы можете сделать это с помощью `local_variables`.

### Настройки

* `config.web_console.allowed_ips`: Список авторизованных адресов IPv4 или IPv6 и сетей (по умолчанию: `127.0.0.1/8, ::1`).
* `config.web_console.whiny_requests`: Выводить сообщение, когда консоль не может быть отрисована (по умолчанию: `true`).

Поскольку `web-console` вычисляет чистый Ruby-код удаленно на сервере, не пытайтесь использовать это в production.

Отладка утечки памяти
---------------------

Приложение Ruby (на Rails или нет), может съедать память - или в коде Ruby, или на уровне кода C.

В этом разделе вы научитесь находить и исправлять такие утечки, используя инструменты отладки, такие как Valgrind.

### Valgrind

[Valgrind](http://valgrind.org/) - это приложение для обнаружения утечек памяти, связанных с языком C, и состоянием гонки.

Имеются инструменты Valgrind, которые могут автоматически обнаруживать многие программные ошибки управления памятью и тредами, и подробно профилировать ваши программы. Например, если расширение C в интерпретаторе вызывает `malloc()`, но не вызывает должным образом `free()`, эта память не будет доступна пока приложение не будет остановлено.

Чтобы узнать подробности, как установить Valgrind и использовать его с Ruby, обратитесь к [Valgrind and Ruby](https://blog.evanweaver.com/2008/02/05/valgrind-and-ruby/) by Evan Weaver.

### Поиск утечек памяти

Есть отличная статья об обнаружении и починке утечек памяти в Derailed, [которую можно прочесть тут](https://github.com/schneems/derailed_benchmarks#is-my-app-leaking-memory).

Плагины для отладки
-------------------

Имеются некоторые плагины Rails, помогающие в поиске ошибок и отладке вашего приложения. Вот список полезных плагинов для отладки:

* [Query Trace](https://github.com/ruckus/active-record-query-trace/tree/master): Добавляет трассировку запросов в ваши логи.
* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master): Предоставляет объект рассыльщика и набор шаблонов по умолчанию для отправки уведомлений по email, когда происходят ошибки в приложении в Rails.
* [Better Errors](https://github.com/charliesome/better_errors): Заменяет стандартную страницу ошибки Rails новой, содержащей больше контекстной информации, такой как исходный код и просмотр переменных.
* [RailsPanel](https://github.com/dejan/rails_panel): Расширение для Chrome для разработки на Rails, которое подхватывает изменения в development.log. Всю информацию о запросах к приложению Rails можно смотреть в браузере, в панели Developer Tools. Предоставляет обзор времени db/rendering/total, списка параметров, отрендеренных вью и так далее.
* [Pry](https://github.com/pry/pry) альтернатива IRB и интерактивная консоль для разработчиков.

Ссылки
------

* [Домашняя страница ruby-debug](http://bashdb.sourceforge.net/ruby-debug/home-page.html)
* [Домашняя страница debugger](https://github.com/cldwalker/debugger)
* [Домашняя страница web-console](https://github.com/rails/web-console)
* [Статья: Debugging a Rails application with ruby-debug](http://www.sitepoint.com/debug-rails-app-ruby-debug/)
* [Скринкаст Ryan Bates' debugging ruby (revised)](http://railscasts.com/episodes/54-debugging-ruby-revised)
* [Скринкаст Ryan Bates' stack trace](http://railscasts.com/episodes/24-the-stack-trace)
* [Скринкаст Ryan Bates' logger](http://railscasts.com/episodes/56-the-logger)
* [Debugging with ruby-debug](http://bashdb.sourceforge.net/ruby-debug.html)
* [домашняя страница debug](https://github.com/ruby/debug)
