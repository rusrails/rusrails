Заметки о релизе Ruby on Rails 4.2
==================================

Ключевые новинки в Rails 4.2:

* Active Job
* Асинхронные письма
* Adequate Record
* Веб-консоль
* Поддержка внешних ключей

Эти заметки о релизе покрывают только основные изменения. Чтобы узнать о других обновлениях, различных исправлениях программных ошибок и изменениях, обратитесь к логам изменений или к [списку коммитов](https://github.com/rails/rails/commits/4-2-stable) в главном репозитории Rails на GitHub.

--------------------------------------------------------------------------------

Апгрейд до Rails 4.2
--------------------

Прежде чем апгрейднуть существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 4.2, необходимо сначала произвести апгрейд до Rails 4.1 и убедиться, что приложение все еще выполняется так, как нужно. Список вещей, которые нужно выполнить для апгрейда доступен в руководстве [Апгрейд Ruby on Rails](/upgrading-ruby-on-rails#upgrading-from-rails-4-1-to-rails-4-2).

Основные особенности
--------------------

### Active Job

Active Job — это новый фреймворк в Rails 4.2. Это обычный интерфейс для систем очередей, таких как [Resque](https://github.com/resque/resque), [Delayed Job](https://github.com/collectiveidea/delayed_job), [Sidekiq](https://github.com/mperham/sidekiq) и так далее.

Задания, написанные с помощью Active Job API, запускаются в любой поддерживаемой очереди благодаря их соответствующим адаптерам. Active Job поставляется преднастроенным с встроенным исполнителем, выполняющим задания сразу.

Часто заданиям необходимо принимать объекты Active Record в качестве аргументов. Active Job передает ссылки на объект как URI (единые идентификаторы ресурса) вместо маршалинга самого объекта. Новая библиотека [Global ID](https://github.com/rails/globalid) создает URI и ищет объекты, на которые они ссылаются. Передача объектов Active Record как атрибутов задания внутри устроена как использование Global ID.

Например, если `trashable` это объект Active Record, тогда это задание будет запускаться без необходимости сериализации:

```ruby
class TrashableCleanupJob < ActiveJob::Base
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

За подробностями обратитесь к руководству [Основы Active Job](/active_job_basics).

### Асинхронные письма

Созданный на основе Active Job, сейчас Action Mailer имеет метод `deliver_later`, добавляющий отсылку вашего письма с помощью очереди, таким образом, не блокируя контроллер или модель. если очередь асинхронная (встроенная очередь по умолчанию будет блокировать).

Отсылка писем прямо сейчас все еще возможна с помощью `deliver_now`.

### Adequate Record

Adequate Record — это набор улучшений производительности в Active Record, сделавший обычные вызовы методов `find` и `find_by` и некоторых запросов связей до двух раз быстрее.

Он работает, кэшируя обычные запросы SQL как подготовленные выражения (prepared statements) и повторно используя их при подобных вызовах, опуская большую часть работы по генерации запроса при последующих вызовах. За подробностями обратитесь к [публикации Aaron Patterson](http://tenderlovemaking.com/2014/02/19/adequaterecord-pro-like-activerecord.html).

Active Record будет пользоваться преимуществами этой особенности на поддерживаемых операциях автоматически, без какого-либо вовлечения пользователя или изменения кода. Вот несколько примеров поддерживаемых операций:

```ruby
Post.find(1)  # Первый вызов генерирует и кэширует подготовленное выражение
Post.find(2)  # Последующие вызовы повторно используют закэшированное подготовленное выражение

Post.find_by_title('first post')
Post.find_by_title('second post')

Post.find_by(title: 'first post')
Post.find_by(title: 'second post')

post.comments
post.comments(true)
```

Важно подчеркнуть то, что, как подчеркивают вышеприведенные примеры, подготовленные выражения не кэшируют значения, переданные в вызов метода, они только являются местозаполнителями для них.

Кэширование не используется в следующих сценариях:

- В модели есть скоуп по умолчанию
- Модель использует наследование с единой таблицей (STI)
- `find` со списком ids. Т.е.:

  ```ruby
  # не кэшируются
  Post.find(1,2,3)
  Post.find([1,2])
  ```

- `find_by` с фрагментом SQL:

  ```ruby
  Post.find_by('published_at < ?', 2.weeks.ago)
  ```

### Веб-консоль

Новые приложения, генерируемые начиная с Rails 4.2, поставляются с гемом [Web Console](https://github.com/rails/web-console) по умолчанию. Веб-консоль добавляет интерактивную консоль Ruby на каждой странице ошибки и хелпер вьюх и контроллеров `console`.

Интерактивная консоль на страницах ошибок позволяет выполнять код в контексте места, где было вызвано исключение. Хелпер вьюх `console` при вызове в любом месте вьюхи или контроллера запускает интерактивную консоль в последнем контексте, как только завершится рендеринг.

### Поддержка внешних ключей

DSL миграций теперь поддерживает добавление или удаление внешних ключей. Также они выгружаются в `schema.rb`. В настоящее время внешние ключи поддерживаются только адаптерами `mysql`, `mysql2` и `postgresql`.

```ruby
# добавляет внешний ключ на `articles.author_id`, ссылающийся на `authors.id`
add_foreign_key :articles, :authors

# добавляет внешний ключ на `articles.author_id`, ссылающийся на `users.lng_id`
add_foreign_key :articles, :users, column: :author_id, primary_key: "lng_id"

# удаляет внешний ключ на `accounts.branch_id`
remove_foreign_key :accounts, :branches

# удаляет внешний ключ на `accounts.owner_id`
remove_foreign_key :accounts, column: :owner_id
```

Смотрите полное описание в документации API для [add_foreign_key](http://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key)
и [remove_foreign_key](http://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key).

Несовместимости
---------------

Ранее устаревшая функциональность была убрана. Обратитесь к отдельным компонентам за информацией о новых устареваниях в этом релизе.

Следующие изменения требуют немедленных действий при апгрейде.

### `render` со строковым аргументом

Раньше вызов в контроллере `render "foo/bar"` был эквивалентом `render file: "foo/bar"`. В Rails 4.2 это стало означать `render template: "foo/bar"`. Если нужно рендерить файл, измените свой код на использования явной формы (`render file: "foo/bar"`).

### `respond_with` / метод класса `respond_to`

Методы `respond_with` и соответствующий метод класса `respond_to` были перемещены в гем [responders](https://github.com/plataformatec/responders). Добавьте `gem 'responders', '~> 2.0'` в свой `Gemfile` для использования:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

Метод экземпляра `respond_to` не был затронут:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

### Хост по умолчанию для `rails server`

Из-за [изменения в Rack](https://github.com/rack/rack/commit/28b014484a8ac0bbb388e7eaeeef159598ec64fc), по умолчанию `rails server` теперь ждет запросов на `localhost` вместо `0.0.0.0`. Это минимально затрагивает стандартный процесс разработки, так как и http://127.0.0.1:3000, и http://localhost:3000 будут работать, как и прежде на вашей машине.

Однако, это изменение не позволяет доступ к серверу Rails с другой машины, например, если ваша среда разработки в виртуальной машине, и вы хотите доступ к ней с хоста. В таких случаях запускайте сервер с помощью `rails server -b 0.0.0.0`, чтобы восстановить старое поведение.

Если так сделаете, не забудьте правильно настроить свой файервол, чтобы только доверенные машины вашей сети имели доступ к вашему серверу разработки.

### Изменены символы для опции статуса у `render`

Из-за [изменения в Rack](https://github.com/rack/rack/commit/be28c6a2ac152fe4adfbef71f3db9f4200df89e8), символы, которые метод `render` принимает для опции `:status`, были изменены:

- 306: `:reserved` был убран.
- 413: `:request_entity_too_large` был переименован в `:payload_too_large`.
- 414: `:request_uri_too_long` был переименован в `:uri_too_long`.
- 416: `:requested_range_not_satisfiable` был переименован в `:range_not_satisfiable`.

Имейте в виду, что если вызывается `render` с неизвестным символом, статус отклика будет по умолчанию 500.

### Санитайзер HTML

Санитайзер HTML был заменен новой, более надежной, реализацией, созданной на основе [Loofah](https://github.com/flavorjones/loofah) и [Nokogiri](https://github.com/sparklemotion/nokogiri). Новый санитайзер более безопасный и его санация более мощная и гибкая.

Из-за нового алгоритма, санированный результат может быть различным для определенных патологических входных данных.

Если у вас есть особая необходимость в точном результате от старого санитайзера , можете добавить гем [rails-deprecated_sanitizer](https://github.com/kaspth/rails-deprecated_sanitizer) в свой `Gemfile`, и получите старое поведение. Этот гем не будет выдавать предостережения об устаревании, поскольку он опциональный.

`rails-deprecated_sanitizer` будет поддерживаться только для Rails 4.2; он не будет поддерживаться для Rails 5.0.

Подробнее об изменениях в новом санитайзере смотрите [эту публикацию в блоге](http://blog.plataformatec.com.br/2014/07/the-new-html-sanitizer-in-rails-4-2/).

### `assert_select`

`assert_select` теперь базируется на [Nokogiri](https://github.com/sparklemotion/nokogiri).

В результате некоторые ранее валидные селекторы теперь не поддерживаются. Если ваше приложение использует любое из этих написаний, их нужно обновить:

*   Значения в селекторах атрибутов необходимо заключать в кавычки, если они содержат не буквенно-цифровые символы.

    ```ruby
    # до
    a[href=/]
    a[href$=/]

    # теперь
    a[href="/"]
    a[href$="/"]
    ```

*   DOM, созданные из источника HTML, содержащего невалидный HTML с неправильно вложенными элементами, могут отличаться.

    Например:

    ```ruby
    # содержимое: <div><i><p></i></div>

    # раньше:
    assert_select('div > i')  # => true
    assert_select('div > p')  # => false
    assert_select('i > p')    # => true

    # сейчас:
    assert_select('div > i')  # => true
    assert_select('div > p')  # => true
    assert_select('i > p')    # => false
    ```

*   Если выбираемые данные содержат сущности, значение для сравнения раньше было чистым (т.е. `AT&amp;T`), а сейчас вычисленное (т.е. `AT&T`).

    ```ruby
    # содержимое: <p>AT&amp;T</p>

    # раньше:
    assert_select('p', 'AT&amp;T')  # => true
    assert_select('p', 'AT&T')      # => false

    # сейчас:
    assert_select('p', 'AT&T')      # => true
    assert_select('p', 'AT&amp;T')  # => false
    ```

Кроме того, у замен изменился синтаксис.

Теперь можно использовать селектор `:match`, схожий с CSS:

```ruby
assert_select ":match('id', ?)", 'comment_1'
```

Кроме того, замены Regexp выглядят иначе, когда проваливается оператор контроля. Обратите внимание, как `/hello/` тут:

```ruby
assert_select(":match('id', ?)", /hello/)
```

становится `"(?-mix:hello)"`:

```
Expected at least 1 element matching "div:match('id', "(?-mix:hello)")", found 0..
Expected 0 to be >= 1.
```

Подробнее об `assert_select` смотрите в документации по [тестированию Dom в Rails](https://github.com/rails/rails-dom-testing/tree/8798b9349fb9540ad8cb9a0ce6cb88d1384a210b).

Railties
--------

За подробностями обратитесь к [Changelog][railties].

### Удалено

*   Опция `--skip-action-view` была убрана из генератора приложения.
    ([Pull Request](https://github.com/rails/rails/pull/17042))

*   Команда `rails application` была убрана без замены.
    ([Pull Request](https://github.com/rails/rails/pull/11616))

### Устарело

*   Устарел отсутствующий `config.log_level` для окружений production.
    ([Pull Request](https://github.com/rails/rails/pull/16622))

*   Устарел `rake test:all` в пользу `rake test`, так как он теперь запускает все тесты в папке `test`.
    ([Pull Request](https://github.com/rails/rails/pull/17348))

*   Устарел `rake test:all:db` в пользу `rake test:db`.
    ([Pull Request](https://github.com/rails/rails/pull/17348))

*   Устарел `Rails::Rack::LogTailer` без замены.
    ([Commit](https://github.com/rails/rails/commit/84a13e019e93efaa8994b3f8303d635a7702dbce))

### Значимые изменения

*   Представлен `web-console` в `Gemfile` приложения по умолчанию.
    ([Pull Request](https://github.com/rails/rails/pull/11667))

*   Добавлена опция `required` для связей в генераторе модели.
    ([Pull Request](https://github.com/rails/rails/pull/16062))

*   Представлено пространство имен `x` для определения произвольных конфигурационных опций:

    ```ruby
    # config/environments/production.rb
    config.x.payment_processing.schedule = :daily
    config.x.payment_processing.retries  = 3
    config.x.super_debugger              = true
    ```

    Затем эти опции доступны в объекте configuration:

    ```ruby
    Rails.configuration.x.payment_processing.schedule # => :daily
    Rails.configuration.x.payment_processing.retries  # => 3
    Rails.configuration.x.super_debugger              # => true
    ```

    ([Commit](https://github.com/rails/rails/commit/611849772dd66c2e4d005dcfe153f7ce79a8a7db))

*   Представлен `Rails::Application.config_for` для загрузки конфигурации для текущего окружения.

    ```ruby
    # config/exception_notification.yml:
    production:
      url: http://127.0.0.1:8080
      namespace: my_app_production
    development:
      url: http://localhost:3001
      namespace: my_app_development

    # config/environments/production.rb
    Rails.application.configure do
      config.middleware.use ExceptionNotifier, config_for(:exception_notification)
    end
    ```

    ([Pull Request](https://github.com/rails/rails/pull/16129))

*   Представлена опция `--skip-turbolinks` для генератора приложения, чтобы не генерировать интеграцию с turbolinks.
    ([Commit](https://github.com/rails/rails/commit/bf17c8a531bc8059d50ad731398002a3e7162a7d))

*   Представлен скрипт `bin/setup` как соглашение для автоматической настройки для быстрого развертывания вашего приложения.
    ([Pull Request](https://github.com/rails/rails/pull/15189))

*   Изменено значение по умолчанию для `config.assets.digest` на `true` в среде development.
    ([Pull Request](https://github.com/rails/rails/pull/15155))

*   Представлен API для регистрации новых расширений для `rake notes`.
    ([Pull Request](https://github.com/rails/rails/pull/14379))

*   Представлен колбэк `after_bundle` для использования в шаблонах Rails.
    ([Pull Request](https://github.com/rails/rails/pull/16359))

*   Представлен `Rails.gem_version` как удобный метод для возврата `Gem::Version.new(Rails.version)`.
    ([Pull Request](https://github.com/rails/rails/pull/14101))


Action Pack
-----------

За подробностями обратитесь к [Changelog][action-pack].

### Удалено

*   `respond_with` и метод класса `respond_to` были убраны из Rails и перемещены в гем `responders` (версия 2.0). Добавьте `gem 'responders', '~> 2.0'` в свой `Gemfile`, чтобы продолжать использовать эти особенности.
    ([Pull Request](https://github.com/rails/rails/pull/16526),
     [подробнее](/upgrading-ruby-on-rails#responders))

*   Убран устаревший `AbstractController::Helpers::ClassMethods::MissingHelperError` в пользу `AbstractController::Helpers::MissingHelperError`.
    ([Commit](https://github.com/rails/rails/commit/a1ddde15ae0d612ff2973de9cf768ed701b594e8))

### Устарело

*   Устарела опция `only_path` в хелперах `*_path`.
    ([Commit](https://github.com/rails/rails/commit/aa1fadd48fb40dd9396a383696134a259aa59db9))

*   Устарели `assert_tag`, `assert_no_tag`, `find_tag` и `find_all_tag` в пользу `assert_select`.
    ([Commit](https://github.com/rails/rails-dom-testing/commit/b12850bc5ff23ba4b599bf2770874dd4f11bf750))

*   Устарела поддержка опции `:to` в роутере со значением символом или строкой без символа "#":

    ```ruby
    get '/posts', to: MyRackApp    => (Не требуется изменения)
    get '/posts', to: 'post#index' => (Не требуется изменения)
    get '/posts', to: 'posts'      => get '/posts', controller: :posts
    get '/posts', to: :index       => get '/posts', action: :index
    ```

    ([Commit](https://github.com/rails/rails/commit/cc26b6b7bccf0eea2e2c1a9ebdcc9d30ca7390d9))

*   Устарела поддержка строковых ключей в хелперах URL:

    ```ruby
    # плохо
    root_path('controller' => 'posts', 'action' => 'index')

    # хорошо
    root_path(controller: 'posts', action: 'index')
    ```

    ([Pull Request](https://github.com/rails/rails/pull/17743))

### Значимые изменения

*   Семейство методов `*_filter` убраны из документации. Их использование не рекомендуется в пользу семейства методов `*_action`:

    ```
    after_filter          => after_action
    append_after_filter   => append_after_action
    append_around_filter  => append_around_action
    append_before_filter  => append_before_action
    around_filter         => around_action
    before_filter         => before_action
    prepend_after_filter  => prepend_after_action
    prepend_around_filter => prepend_around_action
    prepend_before_filter => prepend_before_action
    skip_after_filter     => skip_after_action
    skip_around_filter    => skip_around_action
    skip_before_filter    => skip_before_action
    skip_filter           => skip_action_callback
    ```

    Если ваше приложение в настоящее время зависит от этих методов, следует их заменить на методы `*_action`. Они будут объявлены устаревшими в будущем и когда-нибудь будут убраны из Rails.

    (Commit [1](https://github.com/rails/rails/commit/6c5f43bab8206747a8591435b2aa0ff7051ad3de),
    [2](https://github.com/rails/rails/commit/489a8f2a44dc9cea09154ee1ee2557d1f037c7d4))

*   `render nothing: true` или рендеринг тела `nil` больше не добавляет одиночный пробел в тело отклика.
    ([Pull Request](https://github.com/rails/rails/pull/14883))

*   Rails теперь автоматически включает дайджест шаблона в ETag.
    ([Pull Request](https://github.com/rails/rails/pull/16527))

*   Сегменты, передаваемые в хелперы URL, теперь автоматически экранируются.
    ([Commit](https://github.com/rails/rails/commit/5460591f0226a9d248b7b4f89186bd5553e7768f))

*   Представлена опция `always_permitted_parameters` для настройки, какие параметры разрешены глобально. Значение по умолчанию для этой настройки `['controller', 'action']`.
    ([Pull Request](https://github.com/rails/rails/pull/15933))

*   Добавлен метод HTTP `MKCALENDAR` из [RFC 4791](https://tools.ietf.org/html/rfc4791).
    ([Pull Request](https://github.com/rails/rails/pull/15121))

*   Уведомления `*_fragment.action_controller` теперь включают имена контроллера и экшна в payload.
    ([Pull Request](https://github.com/rails/rails/pull/14137))

*   Улучшена страница Routing Error с помощью нечеткого (fuzzy) соответствия для поиска маршрутов.
    ([Pull Request](https://github.com/rails/rails/pull/14619))

*   Добавлена опция для отключения логирования ошибок CSRF.
    ([Pull Request](https://github.com/rails/rails/pull/14280))

*   Когда сервер Rails настроен обслуживать статичные ассеты, gzip ассеты также будут обслужены, если клиент их поддерживает и предварительно генерирует файл gzip (`.gz`) на диск. По умолчанию asset pipeline генерирует файлы `.gz` для всех сжимаемых ассетов. Обслуживание gzip файлов минимизирует передаваемые данные и ускоряет запрос к ассету. Всегда [используйте CDN](/asset-pipeline#cdns), если обслуживаете файлы ассетов на сервере Rails в production.
    ([Pull Request](https://github.com/rails/rails/pull/16466))

*   При вызове хелперов `process` в интеграционном тесте, пути необходим начальный слэш. Раньше его можно было опустить, но это был побочный продукт реализации, а не специальная особенность, т.е.:

    ```ruby
    test "list all posts" do
      get "/posts"
      assert_response :success
    end
    ```

Action View
-----------

За подробностями обратитесь к [Changelog][action-view].

### Устарело

*   Устарели `AbstractController::Base.parent_prefixes`. Переопределите `AbstractController::Base.local_prefixes` когда хотите изменить, где следует искать вьюхи.
    ([Pull Request](https://github.com/rails/rails/pull/15026))

*   Устарел `ActionView::Digestor#digest(name, format, finder, options = {})`. Аргументы должны быть переданы как хэш.
    ([Pull Request](https://github.com/rails/rails/pull/14243))

### Значимые изменения

*   `render "foo/bar"` теперь расширяется до `render template: "foo/bar"` вместо `render file: "foo/bar"`.
    ([Pull Request](https://github.com/rails/rails/pull/16888))

*   Хелперы форм больше не генерируют элемент `<div>` со встроенным CSS вокруг скрытых полей.
    ([Pull Request](https://github.com/rails/rails/pull/14738))

*   Представлена специальная локальная переменная `#{partial_name}_iteration` для использования с партиалами, рендерящимися с коллекцией. Она предоставляет доступ к текущему состоянию итерации с помощью методов `index`, `size`, `first?` и `last?`.
    ([Pull Request](https://github.com/rails/rails/pull/7698))

*   Местозаполнитель I18n следует тем же соглашениям, что и `label` I18n.
    ([Pull Request](https://github.com/rails/rails/pull/16438))


Action Mailer
-------------

За подробностями обратитесь к [Changelog][action-mailer].

### Устарело

*   Устарели хелперы `*_path` в рассыльщиках. Всегда используйте вместо них хелперы `*_url`.
    ([Pull Request](https://github.com/rails/rails/pull/15840))

*   Устарели `deliver` / `deliver!` в пользу `deliver_now` / `deliver_now!`.
    ([Pull Request](https://github.com/rails/rails/pull/16582))

### Значимые изменения

*   `link_to` и `url_for` по умолчанию генерируют абсолютные URL в шаблонах, больше нет необходимости передавать `only_path: false`.
    ([Commit](https://github.com/rails/rails/commit/9685080a7677abfa5d288a81c3e078368c6bb67c))

*   Представлен `deliver_later`, который добавляет в очередь задание для доставки писем асинхронно.
    ([Pull Request](https://github.com/rails/rails/pull/16485))

*   Добавлена конфигурационная опция `show_previews` для включения предпросмотра писем вне окружения разработки.
    ([Pull Request](https://github.com/rails/rails/pull/15970))


Active Record
-------------

За подробностями обратитесь к [Changelog][active-record].

### Удалено

*   Удален `cache_attributes` и сотоварищи. Все атрибуты кэшируются.
    ([Pull Request](https://github.com/rails/rails/pull/15429))

*   Удален устаревший метод `ActiveRecord::Base.quoted_locking_column`.
    ([Pull Request](https://github.com/rails/rails/pull/15612))

*   Удален устаревший метод `ActiveRecord::Migrator.proper_table_name`. Используйте вместо него метод экземпляра `proper_table_name` на `ActiveRecord::Migration`.
    ([Pull Request](https://github.com/rails/rails/pull/15512))

*   Удален неиспользуемый тип `:timestamp`. Прозрачно добавлен как псевдоним к `:datetime` во всех случаях. Исправлены несоответствия, когда типы столбцов используются вне Active Record, например для сериализации XML.
    ([Pull Request](https://github.com/rails/rails/pull/15184))

### Устарело

*   Устарело проглатывание ошибок в `after_commit` и `after_rollback`.
    ([Pull Request](https://github.com/rails/rails/pull/16537))

*   Устарела сломанная поддержка автоматического определения кэширующих счетчиков на связях `has_many :through`. Вместо этого следует вручную указывать кэширующий счетчик на связях `has_many` и `belongs_to` для записей through.
    ([Pull Request](https://github.com/rails/rails/pull/15754))

*   Устарела передача объектов Active Record в `.find` или `.exists?`. Вместо этого сначала вызывайте `id` на объектах.
    (Commit [1](https://github.com/rails/rails/commit/d92ae6ccca3bcfd73546d612efaea011270bd270),
    [2](https://github.com/rails/rails/commit/d35f0033c7dec2b8d8b52058fb8db495d49596f7))

*   Устарела недоделанная поддержка интервальных значений PostgreSQL с исключенными концами (полуинтервалов). Сейчас мы переводим интервалы PostgreSQL в интервалы Ruby. Это преобразование не полностью возможно, поскольку интервалы Ruby не поддерживают исключение концов.

    Текущее решение увеличения конца интервала неправильное и устарело. Для подтипов, в которых мы не знаем как увеличить (т.е. где не определен `succ`), он вызовет `ArgumentError` для интервалов с исключенными концами.

    ([Commit](https://github.com/rails/rails/commit/91949e48cf41af9f3e4ffba3e5eecf9b0a08bfc3))

*   Устарел вызов `DatabaseTasks.load_schema` без соединения. Вместо него используйте `DatabaseTasks.load_schema_current`.
    ([Commit](https://github.com/rails/rails/commit/f15cef67f75e4b52fd45655d7c6ab6b35623c608))

*   Устарел `sanitize_sql_hash_for_conditions` без замены. Для выполнения запросов и обновлений предпочтительным API является использование `Relation`.
    ([Commit](https://github.com/rails/rails/commit/d5902c9e))

*   Устарели `add_timestamps` и `t.timestamps` без передачи опции `:null`. Значение по умолчанию `null: true` изменится в Rails 5 на `null: false`.
    ([Pull Request](https://github.com/rails/rails/pull/16481))

*   Устарел `Reflection#source_macro` без замены, так как он больше не требуется в Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/16373))

*   Устарел `serialized_attributes` без замен.
    ([Pull Request](https://github.com/rails/rails/pull/15704))

*   Устарел возврат `nil` от `column_for_attribute` когда не существует столбец. Он будет возвращать null object в Rails 5.0
    ([Pull Request](https://github.com/rails/rails/pull/15878))

*   Устарело использование `.joins`, `.preload` и `.eager_load` со связями, зависящими от состояния экземпляра (т.е. те, которые определены со скоупом, принимающим аргумент) без замены.
    ([Commit](https://github.com/rails/rails/commit/ed56e596a0467390011bc9d56d462539776adac1))

### Значимые изменения

*   `SchemaDumper` использует `force: :cascade` на `create_table`. Это позволяет перезагрузить схему с внешними ключами.

*   Добавлена опция `:required` к одиночным связям, определяющая наличие валидации для связи.
    ([Pull Request](https://github.com/rails/rails/pull/16056))

*   `ActiveRecord::Dirty` теперь обнаруживает изменения в мутируемых значениях. Сериализованные атрибуты в моделях Active Record больше не сохраняются, когда не изменились. Это также работает с другими типами, такими как строковые столбцы и json столбцы в PostgreSQL.
    (Pull Requests [1](https://github.com/rails/rails/pull/15674),
    [2](https://github.com/rails/rails/pull/15786),
    [3](https://github.com/rails/rails/pull/15788))

*   Представлена задача Rake `db:purge` для опустошения базы данных для текущей среды.
    ([Commit](https://github.com/rails/rails/commit/e2f232aba15937a4b9d14bd91e0392c6d55be58d))

*   Представлен `ActiveRecord::Base#validate!`, вызывающий `ActiveRecord::RecordInvalid`, если запись невалидна.
    ([Pull Request](https://github.com/rails/rails/pull/8639))

*   Представлен `validate` в качестве псевдонима для `valid?`.
    ([Pull Request](https://github.com/rails/rails/pull/14456))

*   `touch` теперь принимает несколько атрибутов, которые будут затронуты за раз.
    ([Pull Request](https://github.com/rails/rails/pull/14423))

*   Адаптер PostgreSQL теперь поддерживает тип данных `jsonb` в PostgreSQL 9.4+.
    ([Pull Request](https://github.com/rails/rails/pull/16220))

*   Адаптеры PostgreSQL и SQLite больше не добавляют лимит по умолчанию в 255 символов для строковых столбцов.
    ([Pull Request](https://github.com/rails/rails/pull/14579))

*   Добавлена поддержка для типа столбца `citext` в адаптере PostgreSQL.
    ([Pull Request](https://github.com/rails/rails/pull/12523))

*   Добавлена поддержка для пользовательского интервального типа в адаптере PostgreSQL.
    ([Commit](https://github.com/rails/rails/commit/4cb47167e747e8f9dc12b0ddaf82bdb68c03e032))

*   `sqlite3:///some/path` теперь считается абсолютным системным путем `/some/path`. Для относительных путей используйте `sqlite3:some/path`. (Раньше `sqlite3:///some/path` считался относительным путем `some/path`. Это поведение устарело в Rails 4.1).
    ([Pull Request](https://github.com/rails/rails/pull/14569))

*   Добавлена поддержка для долей секунд в MySQL 5.6 и выше.
    (Pull Request [1](https://github.com/rails/rails/pull/8240),
    [2](https://github.com/rails/rails/pull/14359))

*   Добавлен `ActiveRecord::Base#pretty_print` для красивого отображения моделей.
    ([Pull Request](https://github.com/rails/rails/pull/15172))

*   `ActiveRecord::Base#reload` теперь ведет себя так же, как `m = Model.find(m.id)`, что означает, что он больше не помнит дополнительные атрибуты из собственного `SELECT`.
    ([Pull Request](https://github.com/rails/rails/pull/15866))

*   `ActiveRecord::Base#reflections` теперь возвращает хэш со строковыми ключами вместо символьных ключей.
    ([Pull Request](https://github.com/rails/rails/pull/17718))

*   Метод `references` в миграциях теперь поддерживает опцию `type` для указания типа внешнего ключа (например, `:uuid`).
    ([Pull Request](https://github.com/rails/rails/pull/16231))


Active Model
------------

За подробностями обратитесь к [Changelog][active-model].

### Удалено

*   Удален устаревший `Validator#setup` без замены.
    ([Pull Request](https://github.com/rails/rails/pull/10716))

### Устарело

*   Устарел `reset_#{attribute}` в пользу `restore_#{attribute}`.
    ([Pull Request](https://github.com/rails/rails/pull/16180))

*   Устарел `ActiveModel::Dirty#reset_changes` в пользу `clear_changes_information`.
    ([Pull Request](https://github.com/rails/rails/pull/16180))

### Значимые изменения

*   Представлен `validate` в качестве псевдонима для `valid?`.
    ([Pull Request](https://github.com/rails/rails/pull/14456))

*   Представлен метод `restore_attributes` в `ActiveModel::Dirty` для восстановления измененных (dirty) атрибутов их предыдущими значениями.
    (Pull Request [1](https://github.com/rails/rails/pull/14861),
    [2](https://github.com/rails/rails/pull/16180))

*   `has_secure_password` по умолчанию больше не запрещает пустые пароли (т.е. пароли, содержащие только пробелы).
    ([Pull Request](https://github.com/rails/rails/pull/16412))

*   Теперь `has_secure_password` проверяет, что заданный пароль меньше 72 символов, если включены валидации.
    ([Pull Request](https://github.com/rails/rails/pull/15708))


Active Support
--------------

За подробностями обратитесь к [Changelog][active-support].

### Удалено

*   Удалены устаревшие `Numeric#ago`, `Numeric#until`, `Numeric#since`, `Numeric#from_now`.
    ([Commit](https://github.com/rails/rails/commit/f1eddea1e3f6faf93581c43651348f48b2b7d8bb))

*   Удалены устаревшие ограничители на основе строки для `ActiveSupport::Callbacks`.
    ([Pull Request](https://github.com/rails/rails/pull/15100))

### Устарело

*   Устарели `Kernel#silence_stderr`, `Kernel#capture` и `Kernel#quietly` без замены.
    ([Pull Request](https://github.com/rails/rails/pull/13392))

*   Устарел `Class#superclass_delegating_accessor`, вместо него используйте `Class#class_attribute`.
    ([Pull Request](https://github.com/rails/rails/pull/14271))

*   Устарел `ActiveSupport::SafeBuffer#prepend!` так как `ActiveSupport::SafeBuffer#prepend` теперь выполняет ту же самую функцию.
    ([Pull Request](https://github.com/rails/rails/pull/14529))

### Значимые изменения

*   Представлена новая конфигурационная опция `active_support.test_order` для определения порядка, в котором выполняются тестовые случаи. В настоящее время эта опция по умолчанию `:sorted`, но будет изменена на `:random` в Rails 5.0.
    ([Commit](https://github.com/rails/rails/commit/53e877f7d9291b2bf0b8c425f9e32ef35829f35b))

*   `Object#try` и `Object#try!` теперь могут использоваться без явного получателя в блоке.
    ([Commit](https://github.com/rails/rails/commit/5e51bdda59c9ba8e5faf86294e3e431bd45f1830),
    [Pull Request](https://github.com/rails/rails/pull/17361))

*   Тестовый хелпер `travel_to` теперь обрезает компонент `usec` до 0.
    ([Commit](https://github.com/rails/rails/commit/9f6e82ee4783e491c20f5244a613fdeb4024beb5))

*   Представлен `Object#itself` как идентифицирующая функция.
    (Commit [1](https://github.com/rails/rails/commit/702ad710b57bef45b081ebf42e6fa70820fdd810),
    [2](https://github.com/rails/rails/commit/64d91122222c11ad3918cc8e2e3ebc4b0a03448a))

*   Теперь `Object#with_options` может использоваться без явного получателя в блоке.
    ([Pull Request](https://github.com/rails/rails/pull/16339))

*   Представлен `String#truncate_words` для обрезания строки по количеству слов.
    ([Pull Request](https://github.com/rails/rails/pull/16190))

*   Добавлены `Hash#transform_values` и `Hash#transform_values!` для упрощения обычной практики, когда значения хэша должны измениться, но ключи остаются прежними.
    ([Pull Request](https://github.com/rails/rails/pull/15819))

*   Теперь словообразующий хелпер `humanize` отбрасывает любые начальные знаки подчеркивания.
    ([Commit](https://github.com/rails/rails/commit/daaa21bc7d20f2e4ff451637423a25ff2d5e75c7))

*   Представлен `Concern#class_methods` как альтернатива `module ClassMethods`, а также `Kernel#concern` для избегания шаблонного `module Foo; extend ActiveSupport::Concern; end`.
    ([Commit](https://github.com/rails/rails/commit/b16c36e688970df2f96f793a759365b248b582ad))

*   Новое [руководство](/constant_autoloading_and_reloading) про автозагрузку и перезагрузку констант.

Благодарности
-------------

Взгляните [на полный список контрибьюторов Rails](http://contributors.rubyonrails.org/), на людей, которые потратили много часов, сделав Rails стабильнее и надёжнее. Спасибо им всем.

[railties]:       https://github.com/rails/rails/blob/4-2-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/4-2-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/4-2-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/4-2-stable/actionmailer/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/4-2-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/4-2-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
