Заметки о релизе Ruby on Rails 7.1
==================================

Ключевые новинки в Rails 7.1:

* Генерация Dockerfile для новых приложений Rails
* Добавлен `ActiveRecord::Base.normalizes`
* Добавлен `ActiveRecord::Base.generates_token_for`
* Добавлен `perform_all_later` для одновременной постановки в очередь нескольких заданий
* Составные первичные ключи
* Представлен адаптер для `Trilogy`
* Добавлен `ActiveSupport::MessagePack`
* Представлены `config.autoload_lib` и `config.autoload_lib_once` для улучшенной автозагрузки
* API Active Record для обычных асинхронных запросов
* Возможность для шаблонов устанавливать строгие `locals`
* Добавлен `Rails.application.deprecators`
* Поддержка сопоставления с образцом для JSON `response.parsed_body`
* Расширение `response.parsed_body` для парсинга HTML с помощью Nokogiri
* Представлен `ActionView::TestCase.register_parser`

Эти заметки о релизе покрывают только основные изменения. Чтобы узнать о других обновлениях, различных исправлениях программных ошибок и изменениях, обратитесь к логам изменений или к [списку коммитов](https://github.com/rails/rails/commits/7-1-stable) в главном репозитории Rails на GitHub.

--------------------------------------------------------------------------------

Апгрейд до Rails 7.1
--------------------

Прежде чем апгрейднуть существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 7.1, необходимо сначала произвести апгрейд до Rails 7.0 и убедиться, что приложение все еще выполняется так, как нужно. Список вещей, которые нужно выполнить для апгрейда доступен в руководстве [Апгрейд Ruby on Rails](/upgrading-ruby-on-rails#upgrading-from-rails-7-0-to-rails-7-1).

Основные особенности
--------------------

### Генерация Dockerfile для новых приложений Rails

[Поддержка Docker по умолчанию](https://github.com/rails/rails/pull/46762) для новых приложений Rails. При генерации нового приложения, Rails теперь включит файлы для Docker в приложение.

Эти файлы служат основополагающей настройкой для развертывания вашего приложения Rails в среде production с помощью Docker. Важно отметить, что эти файлы не предназначены для целей разработки.

Вот быстрый пример того, как собрать и запустить ваше приложение Rails с помощью этих файлов Docker:

```bash
$ docker build -t app .
$ docker volume create app-storage
$ docker run --rm -it -v app-storage:/rails/storage -p 3000:3000 --env RAILS_MASTER_KEY=<your-config-master-key> app
```

Также из этого образа Docker можно запустить console или runner:

```bash
$ docker run --rm -it -v app-storage:/rails/storage --env RAILS_MASTER_KEY=<your-config-master-key> app console
```

Те, кто ищет, как создать мультиплатформенный образ (например, развертывание на Apple Silicon для AMD или Intel), и передать его на Docker Hub, следуйте этим шагам:

```bash
$ docker login -u <your-user>
$ docker buildx create --use
$ docker buildx build --push --platform=linux/amd64,linux/arm64 -t <your-user/image-name> .
```

Это улучшение упрощает процесс развертывания, предоставляя удобную стартовую точку для поднятия и запуска вашего приложения Rails в среде production.

### Добавлен `ActiveRecord::Base.normalizes`

[`ActiveRecord::Base.normalizes`][] объявляет нормализацию атрибутов. Нормализация применяется, когда атрибут назначается или обновляется, и нормализованное значение будет записано в базу данных. Нормализация также применяется к соответствующему аргументу с ключом в методах запроса, позволяя запрашивать записи с помощью неформализованных значений.

Например:

```ruby
class User < ActiveRecord::Base
  normalizes :email, with: -> email { email.strip.downcase }
  normalizes :phone, with: -> phone { phone.delete("^0-9").delete_prefix("1") }
end

user = User.create(email: " CRUISE-CONTROL@EXAMPLE.COM\n")
user.email                  # => "cruise-control@example.com"

user = User.find_by(email: "\tCRUISE-CONTROL@EXAMPLE.COM ")
user.email                  # => "cruise-control@example.com"
user.email_before_type_cast # => "cruise-control@example.com"

User.where(email: "\tCRUISE-CONTROL@EXAMPLE.COM ").count         # => 1
User.where(["email = ?", "\tCRUISE-CONTROL@EXAMPLE.COM "]).count # => 0

User.exists?(email: "\tCRUISE-CONTROL@EXAMPLE.COM ")         # => true
User.exists?(["email = ?", "\tCRUISE-CONTROL@EXAMPLE.COM "]) # => false

User.normalize_value_for(:phone, "+1 (555) 867-5309") # => "5558675309"
```

[`ActiveRecord::Base.normalizes`]: https://api.rubyonrails.org/v7.1/classes/ActiveRecord/Normalization/ClassMethods.html#method-i-normalizes

### Добавлен `ActiveRecord::Base.generates_token_for`

[`ActiveRecord::Base.generates_token_for`][] определяет генерацию токенов для определенной цели. Сгенерированные токены могут стать просроченными, а также содержать данные записи. При использовании токена для получения записи, будут сравнены данные из токена и данные из записи. Если они не совпадут, токен будет считаться невалидным, и то же самое, если он просрочен.

Вот пример реализации одноразового токена сброса пароля:

```ruby
class User < ActiveRecord::Base
  has_secure_password

  generates_token_for :password_reset, expires_in: 15.minutes do
    # `password_salt` (определенный `has_secure_password`) возвращает соль для
    # пароля. Соль изменяется при изменении пароля, таким образом, токен
    # будет просрочен, если пароль изменится.
    password_salt&.last(10)
  end
end

user = User.first
token = user.generate_token_for(:password_reset)

User.find_by_token_for(:password_reset, token) # => user

user.update!(password: "new password")
User.find_by_token_for(:password_reset, token) # => nil
```

[`ActiveRecord::Base.generates_token_for`]: https://api.rubyonrails.org/v7.1/classes/ActiveRecord/TokenFor/ClassMethods.html#method-i-generates_token_for

### Добавлен `perform_all_later`, чтобы поместит в очередь несколько заданий за раз

[Метод `perform_all_later` в Active Job](https://github.com/rails/rails/pull/46603) разработан, чтобы упростить процесс помещения в очередь нескольких заданий одновременно. Это мощное дополнение позволяет эффективно помещать задания в очередь без запуска колбэков. Это в особенности полезно, когда необходимо поместить набор заданий в очередь за раз, что уменьшает накладные расходы на несколько запросов к хранилищу данных очереди.

Вот как можно воспользоваться преимуществом `perform_all_later`:

```ruby
# Постановка в очередь отдельных заданий
ActiveJob.perform_all_later(MyJob.new("hello", 42), MyJob.new("world", 0))

# Постановка в очередь массива заданий
user_jobs = User.pluck(:id).map { |id| UserJob.new(user_id: id) }
ActiveJob.perform_all_later(user_jobs)
```

Пользуясь `perform_all_later`, можно оптимизировать процесс постановки заданий в очередь и пользоваться преимуществом улучшенной эффективности, в особенности при работе с большими наборами заданий. Стоит отметить, что в адаптерах очереди, поддерживающих новый метод `enqueue_all`, таких как адаптер Sidekiq, процесс постановки в очередь еще более оптимизирован с помощью `push_bulk`.

Предупреждаем, что этот новый метод представляет отдельное событие, `enqueue_all.active_job`, и не использует существующее событие `enqueue.active_job`. С помощью этого достигается точное отслеживание и отчетность о процессе массовой постановки в очередь.

### Составные первичные ключи

Составные первичные ключи теперь поддерживаются и на уровне базы данных, и приложения. Rails способен извлечь эти ключи напрямую из схемы. Эта функция особенно полезна для отношений many-to-many и других сложных моделей данных, когда единственного столбца недостаточно для уникальной идентификации записи.

SQL, генерируемый методами запроса в Active Record (например, `#reload`, `#update`, `#delete`) будет содержать все части составного первичного ключа. Методы, наподобие `#first` и `#last`, будут использовать полный составной первичный ключ в выражениях `ORDER BY`.

Можно использовать макрос `query_constraints` в качестве "виртуального первичного ключа", чтобы достичь того же поведения без изменения схемы базы данных. Пример:

```ruby
class TravelRoute < ActiveRecord::Base
  query_constraints :origin, :destination
end
```

Схожим образом связи принимают опцию `query_constraints:`. Эта опция служит в качестве составного внешнего ключа, настраивая список столбцов, используемых для доступа к связанной записи.

Example:

```ruby
class TravelRouteReview < ActiveRecord::Base
  belongs_to :travel_route, query_constraints: [:travel_route_origin, :travel_route_destination]
end
```

### Представлен адаптер для `Trilogy`

[Был представлен новый адаптер](https://github.com/rails/rails/pull/47880) для содействия бесшовной интеграции `Trilogy`, клиента базы данных, совместимой с MySQL, с приложением Rails. Теперь у приложений Rails есть вариант включения функционала `Trilogy`, настраивая их файл `config/database.yml`. К примеру:

```yaml
development:
  adapter: trilogy
  database: blog_development
  pool: 5
```

Альтернативно можно достичь интеграции с помощью переменной среды `DATABASE_URL`:

```ruby
ENV['DATABASE_URL'] # => "trilogy://localhost/blog_development?pool=5"
```

### Add `ActiveSupport::MessagePack`

[`ActiveSupport::MessagePack`][] это сериализатор, интегрированный с [гемом `msgpack`][]. `ActiveSupport::MessagePack` может сериализовывать базовые типы Ruby, поддерживаемые `msgpack`, а также несколько дополнительных типов, таких как `Time`, `ActiveSupport::TimeWithZone` и `ActiveSupport::HashWithIndifferentAccess`.
По сравнению с `JSON` и `Marshal`, `ActiveSupport::MessagePack` может уменьшить размер полезной нагрузки и улучшить производительность.

`ActiveSupport::MessagePack` можно использовать в качестве [сериализатора сообщения](/configuring#config-active-support-message-serializer):

```ruby
config.active_support.message_serializer = :message_pack

# Или отдельно:
ActiveSupport::MessageEncryptor.new(secret, serializer: :message_pack)
ActiveSupport::MessageVerifier.new(secret, serializer: :message_pack)
```

В качестве [сериализатора куки](/configuring#config-action-dispatch-cookies-serializer):

```ruby
config.action_dispatch.cookies_serializer = :message_pack
```

И в качестве [сериализатора кэша](/caching-with-rails#configuration):

```ruby
config.cache_store = :file_store, "tmp/cache", { serializer: :message_pack }

# Или отдельно:
ActiveSupport::Cache.lookup_store(:file_store, "tmp/cache", serializer: :message_pack)
```

[`ActiveSupport::MessagePack`]: https://api.rubyonrails.org/v7.1/classes/ActiveSupport/MessagePack.html
[гемом `msgpack`]: https://github.com/msgpack/msgpack-ruby

### Представлены `config.autoload_lib` и `config.autoload_lib_once` для улучшенной автоматической загрузки

Был представлен [новый конфигурационный метод, `config.autoload_lib(ignore:)`](https://github.com/rails/rails/pull/48572). Этот метод используется для улучшения путей автозагрузки приложений, с помощью включения директории `lib`, которая по умолчанию не включена. А также для новых приложений генерируется `config.autoload_lib(ignore: %w(assets tasks))`.

При вызове из `config/application.rb`, либо `config/environments/*.rb`, этот метод добавляет директорию `lib` в `config.autoload_paths` и `config.eager_load_paths`. Важно отметить, что эта особенность не доступно для engine.

Для обеспечения гибкости можно использовать ключевой аргумент `ignore`, чтобы указать поддиректории в директории `lib`, которые не должны управляться автозагрузчиками. К примеру, можно исключить директории, такие как `assets`, `tasks` и `generators`, передав их в качестве аргумента `ignore`:

```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

[Метод `config.autoload_lib_once`](https://github.com/rails/rails/pull/48610) подобен `config.autoload_lib`, за исключением того, что он добавляет `lib` в `config.autoload_once_paths`.

За подробностями обратитесь к [руководству по автоматической загрузке](autoloading-and-reloading-constants#config-autoload-lib-ignore)

### Active Record API для обычных асинхронных запросов

Было представлено значительное улучшение для Active Record API, расширяющее его [поддержку асинхронных запросов](https://github.com/rails/rails/pull/44446). Это улучшение посвящено необходимости более эффективной обработки не очень быстрых запросов, в частности фокусируясь на аггрегирующих (таких как `count`, `sum` и т.д.) и всех методах, возвращающих единственную запись, или что-то отличающееся от `Relation`.

Новый API включает следующие асинхронные методы:

- `async_count`
- `async_sum`
- `async_minimum`
- `async_maximum`
- `async_average`
- `async_pluck`
- `async_pick`
- `async_ids`
- `async_find_by_sql`
- `async_count_by_sql`

Вот краткий пример того, как использовать один из этих методов, `async_count`, чтобы подсчитать количество опубликованных сообщений асинхронным образом:

```ruby
# Синхронный подсчет
published_count = Post.where(published: true).count # => 10

# Асинхронный подсчет
promise = Post.where(published: true).async_count # => #<ActiveRecord::Promise status=pending>
promise.value # => 10
```

Эти методы позволяют запускать эти операции асинхронным образом, что может значительно улучшить эффективность определенных типов запросов к базе данных.

### Разрешены шаблоны для установки строгих `locals`

Представлена новая особенность, [позволяющая шаблонам устанавливать явные `locals`](https://github.com/rails/rails/pull/45602). Это улучшение предоставляет большее управление и ясность при передаче переменных в ваши шаблоны.

По умолчанию шаблоны принимают любые `locals` как ключевые аргументы. Однако, теперь можно определить, какие `locals` шаблон должен принимать, добавляя магический комментарий `locals` в начале файла шаблона.

Вот как это работает:

```erb
<%# locals: (message:) -%>
<%= message %>
```

Также можно установить значения по умолчанию для этих локальных переменных:

```erb
<%# locals: (message: "Hello, world!") -%>
<%= message %>
```

Необязательные ключевые аргументы могут быть расплющены:

```erb
<%# locals: (message: "Hello, world!", **attributes) -%>
<%= tag.p(message, **attributes) %>
```

Если хотите отключить использование локальных переменных полностью, это можно сделать так:

```erb
<%# locals: () %>
```

Action View будет обрабатывать магический комментарий `locals:` в любом шаблонизаторе, который поддерживает комментарии с префиксом `#`. Он может считывать этот комментарий с любой строки в партиале.

CAUTION: Поддерживаются только ключевые аргументы. Определение позиционных или блочных аргументов вызовет ошибку Action View во время отрисовки.

### Добавлен `Rails.application.deprecators`

Новый [метод `Rails.application.deprecators`](https://github.com/rails/rails/pull/46049) возвращает коллекцию управляемых депрекаторов в вашем приложении и позволяет добавлять и получать отдельные депрекаторы:

```ruby
Rails.application.deprecators[:my_gem] = ActiveSupport::Deprecation.new("2.0", "MyGem")
Rails.application.deprecators[:other_gem] = ActiveSupport::Deprecation.new("3.0", "OtherGem")
```

Конфигурационные настройки коллекции влияют на все депрекаторы в коллекции.

```ruby
Rails.application.deprecators.debug = true

Rails.application.deprecators[:my_gem].debug
# => true

Rails.application.deprecators[:other_gem].debug
# => true
```

Есть сценарии, в которых нужно приглушить все сообщения об устаревании для определенного блока кода. С помощью коллекции депрекаторов возможно с легкостью заглушить все предупреждения депрекаторов в пределах блока:

```ruby
Rails.application.deprecators.silence do
  Rails.application.deprecators[:my_gem].warn    # Нет предупреждения (заглушено)
  Rails.application.deprecators[:other_gem].warn # Нет предупреждения (заглушено)
end
```

### Поддержка сопоставлений с образцом (pattern matching) для JSON `response.parsed_body`

Когда блоки тестов `ActionDispatch::IntegrationTest` вызывают `response.parsed_body` для откликов JSON, их полезная нагрузка будет доступна с indifferent access. Это включает интеграцию с [Pattern Matching в Ruby][pattern-matching], и встроенной [поддержкой Minitest для pattern matching][minitest-pattern-matching]:

```ruby
get "/posts.json"

response.content_type         # => "application/json; charset=utf-8"
response.parsed_body.class    # => Array
response.parsed_body          # => [{"id"=>42, "title"=>"Title"},...

assert_pattern { response.parsed_body => [{ id: 42 }] }

get "/posts/42.json"

response.content_type         # => "application/json; charset=utf-8"
response.parsed_body.class    # => ActiveSupport::HashWithIndifferentAccess
response.parsed_body          # => {"id"=>42, "title"=>"Title"}

assert_pattern { response.parsed_body => [{ title: /title/i }] }
```

[pattern-matching]: https://docs.ruby-lang.org/en/master/syntax/pattern_matching_rdoc.html
[minitest-pattern-matching]: https://docs.seattlerb.org/minitest/Minitest/Assertions.html#method-i-assert_pattern

### Расширен `response.parsed_body`, чтобы парсить HTML с помощью Nokogiri

[Расширен модуль `ActionDispatch::Testing`][#47144], чтобы поддерживать парсинг значения HTML `response.body` в экземпляр `Nokogiri::HTML5::Document`:

```ruby
get "/posts"

response.content_type         # => "text/html; charset=utf-8"
response.parsed_body.class    # => Nokogiri::HTML5::Document
response.parsed_body.to_html  # => "<!DOCTYPE html>\n<html>\n..."
```

Недавно добавленная [поддержка Nokogiri для pattern matching][nokogiri-pattern-matching], вместе со встроенной [поддержкой Minitest для pattern matching][minitest-pattern-matching] представляют возможности для тестовых утверждений о структуре и содержимом отклика HTML:

```ruby
get "/posts"

html = response.parsed_body # => <html>
                            #      <head></head>
                            #        <body>
                            #          <main><h1>Some main content</h1></main>
                            #        </body>
                            #     </html>

assert_pattern { html.at("main") => { content: "Some main content" } }
assert_pattern { html.at("main") => { content: /content/ } }
assert_pattern { html.at("main") => { children: [{ name: "h1", content: /content/ }] } }
```

[#47144]: https://github.com/rails/rails/pull/47144
[nokogiri-pattern-matching]: https://nokogiri.org/rdoc/Nokogiri/XML/Attr.html#method-i-deconstruct_keys
[minitest-pattern-matching]: https://docs.seattlerb.org/minitest/Minitest/Assertions.html#method-i-assert_pattern

### Представлен `ActionView::TestCase.register_parser`

[Расширен `ActionView::TestCase`][#49194] для поддержки парсинга содержимого, отрендеренного партиалами вью, в известные структуры. По умолчанию определяет `rendered_html` для парсинга HTML в `Nokogiri::XML::Node` и `rendered_json` для парсинга JSON в `ActiveSupport::HashWithIndifferentAccess`:

```ruby
test "renders HTML" do
  article = Article.create!(title: "Hello, world")

  render partial: "articles/article", locals: { article: article }

  assert_pattern { rendered_html.at("main h1") => { content: "Hello, world" } }
end

test "renders JSON" do
  article = Article.create!(title: "Hello, world")

  render formats: :json, partial: "articles/article", locals: { article: article }

  assert_pattern { rendered_json => { title: "Hello, world" } }
end
```

Чтобы парсить отрендеренное содержимое в RSS, зарегистрируйте вызов к `RSS::Parser.parse`:

```ruby
register_parser :rss, -> rendered { RSS::Parser.parse(rendered) }

test "renders RSS" do
  article = Article.create!(title: "Hello, world")

  render formats: :rss, partial: article, locals: { article: article }

  assert_equal "Hello, world", rendered_rss.items.last.title
end
```

Чтобы парсить отрендеренное содержимое в Capybara::Simple::Node, перерегистрируйте парсер `:html` с помощью вызова к `Capybara.string`:

```ruby
register_parser :html, -> rendered { Capybara.string(rendered) }

test "renders HTML" do
  article = Article.create!(title: "Hello, world")

  render partial: article

  rendered_html.assert_css "main h1", text: "Hello, world"
end
```

[#49194]: https://github.com/rails/rails/pull/49194

Railties
--------

За подробностями обратитесь к [Changelog][railties].

### Удалено

*   Удалена устаревшая команда `bin/rails secrets:setup`.

*   Удален заголовок по умолчанию `X-Download-Options`, так как он использовался только Internet Explorer.

### Устарело

*   Устарело использование `Rails.application.secrets`.

*   Устарели команды `secrets:show` и `secrets:edit` в пользу `credentials`.

*   Устарел `Rails::Generators::Testing::Behaviour` в пользу `Rails::Generators::Testing::Behavior`.

### Значимые изменения

*   Добавлена опция `sandbox_by_default`, чтобы запускать консоль rails в режиме песочницы по умолчанию.

*   Добавлен новый синтаксис для поддержки фильтрации тестов по диапазону строк.

*   Добавлена опция `DATABASE`, включающая определение целевой базы данных при запуске команды `rails railties:install:migrations`, чтобы скопировать миграции.

*   Добавлена поддержка Bun в генераторе `rails new --javascript`.

    ```bash
    $ rails new my_new_app --javascript=bun
    ```

*   Добавлена возможность показывать медленные тесты запускающему тесты.

Action Cable
------------

За подробностями обратитесь к [Changelog][action-cable].

### Удалено

### Устарело

### Значимые изменения

*   Добавлен тестовый вспомогательный метод `capture_broadcasts` для отлова всех сообщений, транслируемых в блоке.

*   Добавлена возможность адаптеру Redis для pub/sub автоматически пересоединяться, когда соединение Redis потеряно.

*   Добавлены управляющие колбэки `before_command`, `after_command` и `around_command` к `ActionCable::Connection::Base`.

Action Pack
-----------

За подробностями обратитесь к [Changelog][action-pack].

### Удалено

*   Удалено устаревшее поведение у `Request#content_type`

*   Удалена устаревшая возможность присвоения одиночного значения `config.action_dispatch.trusted_proxies`.

*   Удалена регистрация устаревших драйверов `poltergeist` и `webkit` (capybara-webkit) для системного тестирования.

### Устарело

*   Устарел `config.action_dispatch.return_only_request_media_type_on_content_type`.

*   Устарел `AbstractController::Helpers::MissingHelperError`.

*   Устарел `ActionDispatch::IllegalStateError`.

*   Устарели директивы политики разрешений `speaker`, `vibrate` и `vr`.

*   Устарели значения `true` и `false` для `config.action_dispatch.show_exceptions` в пользу `:all`, `:rescuable` или `:none`.

### Значимые изменения

*   Добавлен метод `exclude?` в `ActionController::Parameters`. Он противоположен методу `include?`.

*   Добавлен метод `ActionController::Parameters#extract_value`, чтобы позволять извлечение сериализуемы значений из параметров.

*   Добавлена возможность использования пользовательской логики для хранения и получения токенов CSRF.

*   Добавлены ключевые аргументы `html` и `screenshot` для вспомогательного метода системного тестирования скриншотов.

Action View
-----------

За подробностями обратитесь к [Changelog][action-view].

### Удалено

*   Удалена устаревшая константа `ActionView::Path`.

*   Удалена устаревшая поддержка передачи переменных экземпляра как локальных в партиалы.

### Устарело

### Значимые изменения

*   `check_box_tag` и `radio_button_tag` теперь принимают `checked` как ключевой аргумент.

*   Добавлен вспомогательный метод `picture_tag`, чтобы генерировать теги HTML `<picture>`.

*   Вспомогательный метод `simple_format` теперь принимает функционал `:sanitize_options`, позволяя добавление дополнительных опций для процесса обработки.

    ```ruby
    simple_format("<a target=\"_blank\" href=\"http://example.com\">Continue</a>", {}, { sanitize_options: { attributes: %w[target href] } })
    # => "<p><a target=\"_blank\" href=\"http://example.com\">Continue</a></p>"
    ```

Action Mailer
-------------

За подробностями обратитесь к [Changelog][action-mailer].

### Удалено

### Устарело

*   Устарел `config.action_mailer.preview_path`.

*   Устарела передача параметров в `assert_enqueued_email_with` с помощью ключевого аргумента `:args`. Теперь поддерживается ключевой аргумент `:params`, используйте его для передачи параметров.

### Значимые изменения

*   Добавлен `config.action_mailer.preview_paths` для поддержки нескольких путей предварительного просмотра.

*   Добавлен `capture_emails` в тестовые вспомогательные методы, чтобы для отлова всех писем, отправленных в блоке.

*   Добавлен `deliver_enqueued_emails` к `ActionMailer::TestHelper` для доставки всех отложенных заданий почты.

Active Record
-------------

За подробностями обратитесь к [Changelog][active-record].

### Удалено

*   Удалена поддержка `ActiveRecord.legacy_connection_handling`.

*   Удалены устаревшие методы доступа конфигурации `ActiveRecord::Base`

*   Удалена поддержка `:include_replicas` у `configs_for`. Вместо него используйте `:include_hidden`.

*   Удален устаревший `config.active_record.partial_writes`.

*   Удален устаревший `Tasks::DatabaseTasks.schema_file_type`.

*   Убран флажок `--no-comments` в структурных выгрузках для PostgreSQL.

### Устарело

*   Устарел аргумент `name` у `#remove_connection`.

*   Устарел `check_pending!` в пользу `check_all_pending!`.

*   Устарела опция `deferrable: true` у `add_foreign_key` в пользу `deferrable: :immediate`.

*   Устарел `TestFixtures#fixture_path` в пользу `TestFixtures#fixture_paths`.

*   Устарела делегация из `Base` к `connection_handler`.

*   Устарела `config.active_record.suppress_multiple_database_warning`.

*   Устарело использование `ActiveSupport::Duration` в качестве интерполируемого связанного параметра в строковом шаблоне SQL.

*   Устарел `all_connection_pools` и `connection_pool_list` сделан более явным.

*   Устарело, что `read_attribute(:id)` возвращает первичный ключ, если первичный ключ не `:id`.

*   Устарел аргумент `rewhere` у `#merge`.

*   Устарело создание псевдонимов не-атрибутов с помощью `alias_attribute`.

### Значимые изменения

*   Добавлен `TestFixtures#fixture_paths` для поддержки нескольких путей фикстур.

*   Добавлен `authenticate_by` при использовании `has_secure_password`.

*   Добавлен `update_attribute!` к `ActiveRecord::Persistence`, похожий на `update_attribute`, но вызывающий `ActiveRecord::RecordNotSaved`, если колбэк `before_*` выкидывает `:abort`.

*   Разрешено использование псевдонимов атрибутов в `insert_all`/`upsert_all`.

*   Добавлена опция `:include` к `add_index`.

*   Добавлен метод запроса `#regroup`, как сокращение для `.unscope(:group).group(fields)`.

*   Добавлена поддержка автозаполняемых столбцов и произвольных первичных ключей адаптеру `SQLite3`.

*   Добавлены современные производительные значения по умолчанию для соединений с базой данных `SQLite3`.

*   Разрешено указывать выражения where с синтаксисом кортежа столбцов.

    ```ruby
    Topic.where([:title, :author_name] => [["The Alchemist", "Paulo Coelho"], ["Harry Potter", "J.K Rowling"]])
    ```

*   Автоматически генерируемые имена индексов теперь ограничены 62 байтами, что вписывается в лимиты длины имени индекса по умолчанию для MySQL, PostgreSQL и SQLite.

*   Представлен адаптер для клиента базы данных Trilogy.

*   Добавлен метод `ActiveRecord.disconnect_all!` для немедленного закрытия всех соединений у всех пулов.

*   Добавлены команды миграции PostgreSQL для переименования enum, добавления значения и переименования значения.

*   Добавлен псевдоним `ActiveRecord::Base#id_value` для доступа к необработанному значению столбца id записи.

*   Добавлена опция валидации для `enum`.

Active Storage
--------------

За подробностями обратитесь к [Changelog][active-storage].

### Удалено

*   Удалены устаревшие неправильные типы содержимого в конфигурациях Active Storage.

*   Удалены устаревшие методы `ActiveStorage::Current#host` и `ActiveStorage::Current#host=`.

*   Удалено устаревшие поведение при присвоении коллекции вложений. Вместо добавления к коллекции, сейчас коллекция заменяется.

*   Удалены устаревшие методы `purge` и `purge_later` из связи с вложениями.

### Устарело

### Значимые изменения

*   `ActiveStorage::Analyzer::AudioAnalyzer` теперь выводит `sample_rate` и `tags` в хэше вывода `metadata`.

*   Добавлена опция использования предопределенных вариантов при вызове методов `preview` или `representation` на вложении.

*   Добавлена опция `preprocessed` при объявлении вариантов к предобработанным вариантам.

*   Добавлена возможность уничтожать варианты Active Storage.

    ```ruby
    User.first.avatar.variant(resize_to_limit: [100, 100]).destroy
    ```

Active Model
------------

За подробностями обратитесь к [Changelog][active-model].

### Удалено

### Устарело

### Значимые изменения

*   Добавлена поддержка бесконечных рядов в опции `LengthValidator` `:in`/`:within`.

    ```ruby
    validates_length_of :first_name, in: ..30
    ```

*   Добавлена поддержка безначальных рядов в валидаторах `inclusivity/exclusivity`.

    ```ruby
    validates_inclusion_of :birth_date, in: -> { (..Date.today) }
    ```

    ```ruby
    validates_exclusion_of :birth_date, in: -> { (..Date.today) }
    ```

*   Добавлена поддержка для вызовов (challenges) пароля в `has_secure_password`. Когда установлена, проверяет, что вызов пароля соответствует сохраненному `password_digest`.

*   Разрешает валидаторам принимать lambda без аргумента записи.

    ```ruby
    # До
    validates_comparison_of :birth_date, less_than_or_equal_to: ->(_record) { Date.today }

    # После
    validates_comparison_of :birth_date, less_than_or_equal_to: -> { Date.today }
    ```

Active Support
--------------

За подробностями обратитесь к [Changelog][active-support].

### Удалено

*   Удалено устаревшее переопределение `Enumerable#sum`.

*   Удален устаревший `ActiveSupport::PerThreadRegistry`.

*   Удалены устаревшие опции для передачи формата в `#to_s` в `Array`, `Range`, `Date`, `DateTime`, `Time`, `BigDecimal`, `Float` и `Integer`.

*   Удалено устаревшее переопределение `ActiveSupport::TimeWithZone.name`.

*   Удален устаревший файл `active_support/core_ext/uri`.

*   Удален устаревший файл `active_support/core_ext/range/include_time_with_zone`.

*   Удалено неявное преобразование объектов в `String` в `ActiveSupport::SafeBuffer`.

*   Удалена устаревшая поддержка генерации несоответствующих RFC 4122 UUID при предоставлении ID пространства имен, не являющегося одной из констант, определенных в `Digest::UUID`.

### Устарело

*   Устарел `config.active_support.disable_to_s_conversion`.

*   Устарел `config.active_support.remove_deprecated_time_with_zone_name`.

*   Устарел `config.active_support.use_rfc4122_namespaced_uuids`.

*   Устарел `SafeBuffer#clone_empty`.

*   Устарело использование синглтона `ActiveSupport::Deprecation`.

*   Устарела инициализация `ActiveSupport::Cache::MemCacheStore` с помощью экземпляра `Dalli::Client`.

*   Устарели методы `Notification::Event` `#children` и `#parent_of?`.

### Значимые изменения

Active Job
----------

За подробностями обратитесь к [Changelog][active-job].

### Удалено

*   Удален `QueAdapter`.

### Устарело

### Значимые изменения

*   Добавлен `perform_all_later` для постановки в очередь нескольких задания за раз.

*   Добавлена опция `--parent` к генератору задания, чтобы указать родительский класс задания.

*   Добавлен метод `after_discard` к `ActiveJob::Base`, чтобы запустить колбэк, перед тем, как задание будет сброшено.

*   Добавлена поддержка логирования вызова добавления в очередь фонового задания.

Action Text
----------

За подробностями обратитесь к [Changelog][action-text].

### Удалено

### Устарело

### Значимые изменения

Action Mailbox
----------

За подробностями обратитесь к [Changelog][action-mailbox].

### Удалено

### Устарело

### Значимые изменения

*   Добавлены адреса `X-Forwarded-To` к получателям.

*   Добавлен метод `bounce_now_with` к `ActionMailbox::Base`, чтобы посылать возвращенное письмо без прохождения через очередь рассыльщика.

Ruby on Rails Guides
--------------------

За подробностями обратитесь к [Changelog][guides].

### Значимые изменения

Благодарности
-------------

Взгляните [на полный список контрибьюторов Rails](http://contributors.rubyonrails.org/), на людей, которые потратили много часов, сделав Rails стабильнее и надёжнее. Спасибо им всем.

[railties]:       https://github.com/rails/rails/blob/7-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/7-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/7-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/7-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/7-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/7-1-stable/activerecord/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/7-1-stable/activestorage/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/7-1-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/7-1-stable/activesupport/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/7-1-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/7-1-stable/actiontext/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/7-1-stable/actionmailbox/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/7-1-stable/guides/CHANGELOG.md
