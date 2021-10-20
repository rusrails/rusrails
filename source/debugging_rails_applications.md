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

После запуска `ActiveRecord::Base.verbose_query_logs = true` в сессии `bin/rails console`, чтобы включить подробные логи, и запуска метода снова, становится ясным, что единственная строчка кода генерирует все эти отдельные запросы к базе данных:

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

WARNING: Мы отговариваем от использования этой настройки в среде production. Она полагается на метод Ruby `Kernel#caller`, который, как правило, использует много памяти для генерации трассировок стека вызовов метода.

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

Отладка с помощью гема `web-console`
------------------------------------

Web Console немного похож на `debug`, но запускается в браузере. На любой разрабатываемой вами странице, вы можете запустить консоль в контексте вью или контроллера. Консоль отрендерит содержимое HTML.

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
