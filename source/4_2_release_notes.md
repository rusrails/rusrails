Заметки о релизе Ruby on Rails 4.2
==================================

Ключевые новинки в Rails 4.2:

* Active Job, Action Mailer #deliver_later
* Adequate Record
* Веб-консоль
* Поддержка внешних ключей

Эти заметки о релизе покрывают только основные обновления. Чтобы узнать о различных багфиксах и изменениях, обратитесь к логам изменений или к
[списку комитов](https://github.com/rails/rails/commits/master) в главном репозитории Rails на GitHub.

--------------------------------------------------------------------------------

NOTE: Это руководство незавершено, оно еще может дополняться и изменяться.


Обновление до Rails 4.2
-----------------------

Если вы обновляете существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 4.2, необходимо сначала обновиться до Rails 4.1 и убедиться, что приложение все еще выполняется так, как нужно.
Список вещей, которые нужно выполнить для обновления доступен в руководстве
[Обновление Rails](/upgrading-ruby-on-rails#upgrading-from-rails-4-1-to-rails-4-2).

Основные изменения
------------------

### Active Job, Action Mailer #deliver_later

Active Job — это новый фреймворк в Rails 4.2. Это адаптер для систем очередей, таких как [Resque](https://github.com/resque/resque), [Delayed Job](https://github.com/collectiveidea/delayed_job), [Sidekiq](https://github.com/mperham/sidekiq) и так далее.

С помощью Active Job API вы можете написать свои задачи, и он запустит все эти очереди неизменными (он поставляется преднастроенным с немедленным исполнением).

Созданный на основе Active Job, сейчас Action Mailer имеет метод `#deliver_later`, добавляющий отсылку вашего письма как задачу в очереди, таким образом, не замедляет контроллер или модель.

Новая библиотека GlobalID позволяет с легкостью передавать объекты Active Record в задачи, сериализуя их в общей форме. Это означает, что больше не нужно самим упаковывать и распаковывать ваши объекты Active Records, передавая id. Просто непосредственно передайте в задачу объект Active Record, и он сериализуется с помощью GlobalID и десериализуется в момент выполнения.

### Adequate Record

Adequate Record — это рефакторинг, сделавший методы Active Record `find` и `find_by`, и некоторые запросы связей до двух раз быстрее.

Он работает, кэшируя образцы запросов SQL во время выполнения вызовов Active Record. Кэш помогает опустить часть вычислений, связанных с преобразованием вызовов в запросы SQL. Подробнее в [публикации Aaron Patterson](http://tenderlovemaking.com/2014/02/19/adequaterecord-pro-like-activerecord.html).

Для активации этой особенности не нужно делать ничего особенного. Большинство вызовов `find`, и `find_by`, и запросы связей будут использовать ее автоматически. Примеры:

```ruby
Post.find 1  # кэширует образец запроса
Post.find 2  # использует кэшированный образец

Post.find_by_title 'first post'  # кэширует образец запроса
Post.find_by_title 'second post' # использует кэшированный образец

post.comments        # кэширует образец запроса
post.comments(true)  # использует кэшированный образец
```

Кэширование не используется в следующих сценариях:

- В модели есть скоуп по умолчанию
- Модель использует наследование с единой таблицей (STI) для наследования от другой модели
- `find` со списком ids. Т.е.:

  ```ruby
  Post.find(1,2,3)
  ИЛИ
  Post.find [1,2]
  ```

- `find_by` с фрагментом sql:

  ```ruby
  Post.find_by "published_at < ?", 2.weeks.ago
  ```

### Веб-консоль

Новые приложения, создаваемые начиная с Rails 4.2, поставляются с гемом Web Console по умолчанию.

Веб-консоль — это набор инструментов отладки вашего приложения Rails. Он добавляет интерактивную консоль на каждой странице ошибки, хелпер вьюх `console` и терминал, совместимый с VT100.

Интерактивная консоль на страницах ошибок позволяет выполнять код в контексте места, где было вызвано исключение. Очень удобно для анализа состояния, которое привело к ошибке.

Хелпер вьюх `console` запускает интерактивную консоль в контексте вьюхи, в которой он вызван.

Наконец, можно запустить терминал VT100, запускающий `rails console`. Если нужно создать или изменить существующие тестовые данные, это можно сделать прямо из браузера.

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

Смотрите полное описание в документации API для  [add_foreign_key](http://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key)
и [remove_foreign_key](http://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key).

Несовместимости
---------------

Ранее устаревшая функциональность была убрана. Обратитесь к отдельным компонентам за информацие о новых устареваниях в этом релизе.

Следующие изменения требуют немедленных действий при обновлении.

### `render` со строковым аргументом

Раньше вызов в контроллере `render "foo/bar"` был эквивалентом `render file: "foo/bar"`. В Rails 4.2 это стало означать `render template: "foo/bar"`. Если нужно рендерить файл, измените свой код на использования явной формы (`render file: "foo/bar"`).

### `respond_with` / метод класса `respond_to`

Методы `respond_with` и соответствующий метод класса `respond_to` были перемещены в гем `responders`. Для использования нижеследующего, добавьте `gem 'responders', '~> 2.0'` в свой Gemfile:

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

Однако, это изменение не позволяет доступ к серверу Rails с другой машины (например, если ваша среда разработки в виртуальной машине, и вы хотите доступ к ней с хоста), вам нужно запускать сервер с помощью `rails server -b 0.0.0.0`, чтобы восстановить старое поведение.

Если так сделаете, не забудьте правильно настроить свой фаирволл, чтобы только доверенные машины вашей сети имели доступ к вашему серверу разработки.

### Логирование на production

Уровень лога в среде `production` теперь `:debug`. Это приносит соответствие с другими средами и обеспечивает достаточность информации для диагностики проблем.

Он может быть возвращен к прежнему уровню, `:info`, в конфигурации среды:

```ruby
# config/environments/production.rb

# Уменьшаем объем лога.
config.log_level = :info
```

### Санитайзер HTML

Санитайзер HTML был заменен новой, более надежной, реализацией, созданной на основе Loofah и Nokogiri. Новый санитайзер более безопасный и его санация более мощная и гибкая.

При новом алгоритме санации, санированный результат может измениться для определенных паталогических входных данных.

Если у вас есть особая необходимость в точном результате от старого санитайзера , можете добавить `rails-deprecated_sanitizer` в свой Gemfile, и он автоматически заменит старую реализацию. Поскольку он опциональный, гем с устаревшим поведением не будет выдавать предостережения об устаревании.

`rails-deprecated_sanitizer` будет поддерживаться только для Rails 4.2; он не будет поддерживаться для Rails 5.0.

Подробнее об изменениях в новом санитайзере смотрите [публикацию в блоге](http://blog.plataformatec.com.br/2014/07/the-new-html-sanitizer-in-rails-4-2/).

### `assert_select`

`assert_select` теперь базируется на Nokogiri, что делает его лучше.

В результате некоторые ранее валидные селекторы теперь не поддерживаются. Если ваше приложение использует любое из этих написаний, их нужно обновить:

*   Значения в слекторах атрибутов необходимо заключать в кавычки, если они содержат не буквенно-цифровые символы.

    ```
    a[href=/]      =>     a[href="/"]
    a[href$=/]     =>     a[href$="/"]
    ```

*   DOM, созданные из источника HTML, содержащего невалидный HTML с неправильно вложенными элементами, могут отличаться.

    Например:

    ``` ruby
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

    ``` ruby
    # содержимое: <p>AT&amp;T</p>

    # раньше:
    assert_select('p', 'AT&amp;T')  # => true
    assert_select('p', 'AT&T')      # => false

    # сейчас:
    assert_select('p', 'AT&T')      # => true
    assert_select('p', 'AT&amp;T')  # => false
    ```


Railties
--------

За подробностями обратитесь к [Changelog][railties].

### Удалено

*   Команда `rails application` была убрана без замены.
    ([Pull Request](https://github.com/rails/rails/pull/11616))

### Устарело

*   Устарел `Rails::Rack::LogTailer` без замены.
    ([Commit](https://github.com/rails/rails/commit/84a13e019e93efaa8994b3f8303d635a7702dbce))

### Значимые изменения

*   Представлен `web-console` в Gemfile приложения по умолчанию.
    ([Pull Request](https://github.com/rails/rails/pull/11667))

*   Добавлена опция `required` для связей в генераторе модели.
    ([Pull Request](https://github.com/rails/rails/pull/16062))

*   Представлен колбэк `after_bundle` для использования в шаблонах Rails.
    ([Pull Request](https://github.com/rails/rails/pull/16359))

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

    # config/production.rb
    Rails.application.configure do
      config.middleware.use ExceptionNotifier, config_for(:exception_notification)
    end
    ```

    ([Pull Request](https://github.com/rails/rails/pull/16129))

*   Представлена опция `--skip-gems` для генератора приложения для пропуска гемов, таких как `turbolinks` и `coffee-rails`, у которых нет своих особенных флажков.
    ([Commit](https://github.com/rails/rails/commit/10565895805887d4faf004a6f71219da177f78b7))

*   Представлен скрипт `bin/setup` для включения кода автоматической настройки для быстрого развертывания вашего приложения.
    ([Pull Request](https://github.com/rails/rails/pull/15189))

*   Изменено значение по умолчанию для `config.assets.digest` на `true` в среде development.
    ([Pull Request](https://github.com/rails/rails/pull/15155))

*   Представлен API для регистрации новых расширений для `rake notes`.
    ([Pull Request](https://github.com/rails/rails/pull/14379))

*   Представлен `Rails.gem_version` как удобный метод для возврата `Gem::Version.new(Rails.version)`.
    ([Pull Request](https://github.com/rails/rails/pull/14101))


Action Pack
-----------

За подробностями обратитесь к [Changelog][action-pack].

### Удалено

*   `respond_with` и метод класса `respond_to` были убраны из Rails и перемещены в гем `responders` (версия 2.0). Добавьте `gem 'responders', '~> 2.0'` в свой `Gemfile`, чтобы продолжать использовать эти особенности.
    ([Pull Request](https://github.com/rails/rails/pull/16526))

*   Убран устаревший `AbstractController::Helpers::ClassMethods::MissingHelperError` в пользу `AbstractController::Helpers::MissingHelperError`.
    ([Commit](https://github.com/rails/rails/commit/a1ddde15ae0d612ff2973de9cf768ed701b594e8))

### Устарело

*   Устарели `assert_tag`, `assert_no_tag`, `find_tag` и `find_all_tag` в пользу `assert_select`.
    ([Commit](https://github.com/rails/rails-dom-testing/commit/b12850bc5ff23ba4b599bf2770874dd4f11bf750))

*   Устарела поддержка опции `:to` в роутере со значением символом или строкой без символа `#`:

    ```ruby
    get '/posts', to: MyRackApp    => (Не требуется изменения)
    get '/posts', to: 'post#index' => (Не требуется изменения)
    get '/posts', to: 'posts'      => get '/posts', controller: :posts
    get '/posts', to: :index       => get '/posts', action: :index
    ```

    ([Commit](https://github.com/rails/rails/commit/cc26b6b7bccf0eea2e2c1a9ebdcc9d30ca7390d9))

### Значимые изменения

*   Rails теперь автоматически включает дайджест шаблона в ETag.
    ([Pull Request](https://github.com/rails/rails/pull/16527))

*   `render nothing: true` или рендеринг тела `nil` больше не добавляет одиночный пробел в тело отклика.
    ([Pull Request](https://github.com/rails/rails/pull/14883))

*   Представлена опция `always_permitted_parameters` для настройки, какие параметры разрешены глобально. Значение по умолчанию для этой настройки `['controller', 'action']`.
    ([Pull Request](https://github.com/rails/rails/pull/15933))

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

*   Добавлен метод HTTP `MKCALENDAR` из RFC-4791
    ([Pull Request](https://github.com/rails/rails/pull/15121))

*   Модификации `*_fragment.action_controller` теперь включают имена контроллера и экшна в payload.
    ([Pull Request](https://github.com/rails/rails/pull/14137))

*   Сегменты, передаваемые в хелперы URL, теперь автоматически экранируются.
    ([Commit](https://github.com/rails/rails/commit/5460591f0226a9d248b7b4f89186bd5553e7768f))

*   Улучшена страница Routing Error с помощью нечеткого (fuzzy) соответствия для поиска маршрутов.
    ([Pull Request](https://github.com/rails/rails/pull/14619))

*   Добавлена опция для отключения логирования ошибок CSRF.
    ([Pull Request](https://github.com/rails/rails/pull/14280))

*   Когда сервер Rails настроен обслуживать статичные файлы, сжатые файлы также будут обслужены, если клиент их поддерживает и эти файлы (.gz) есть на диске. По умолчанию asset pipeline создает файлы `.gz` для всех сжимаемых файлов. Обслуживание сжатых файлов минимизирует передаваемые данные и ускоряет запрос к файлу. Всегда [используйте CDN](/asset-pipeline#cdns) если обслуживаете файлы ресурсов на сервере Rails в production.
    ([Pull Request](https://github.com/rails/rails/pull/16466))

*   Способ, как работал `assert_select`, изменился; в частности используется другая библиотека для интерпретации селекторов css, создания временного DOM, к которому применяются селекторы, и извлечения данных из этого DOM. Эти изменения должны затронуть только крайние случаи. Примеры:
    *  Значения в слекторах атрибутов необходимо заключать в кавычки, если они содержат не буквенно-цифровые символы.
    *  DOM, созданные из источника HTML, содержащего невалидный HTML с неправильно вложенными элементами, могут отличаться.
    *  Если выбираемые данные содержат сущности, значение для сравнения раньше было чистым (т.е. `AT&amp;T`), а сейчас вычисленное (т.е. `AT&T`).

Action View
-------------

За подробностями обратитесь к [Changelog][action-view].

### Устарело

*   Устарели `AbstractController::Base.parent_prefixes`. Переопределите `AbstractController::Base.local_prefixes` когда хотите изменить, где следует искать вьюхи.
    ([Pull Request](https://github.com/rails/rails/pull/15026))

*   Устарел `ActionView::Digestor#digest(name, format, finder, options = {})`. Аргументы должны быть переданы как хэш.
    ([Pull Request](https://github.com/rails/rails/pull/14243))

### Значимые изменения

*   `render "foo/bar"` теперь расширяется до `render template: "foo/bar"` вместо `render file: "foo/bar"`.
    ([Pull Request](https://github.com/rails/rails/pull/16888))

*   Представлена специальная локальная переменная `#{partial_name}_iteration` для использования с партиалами, рендерящимися с коллекцией. Она предоставляет доступ к текущему состоянию итерации с помощью методов `#index`, `#size`, `#first?` и `#last?`.
    ([Pull Request](https://github.com/rails/rails/pull/7698))

*   Хелперы форм больше не создают элемент `<div>` с inline CSS вокруг скрытых полей.
    ([Pull Request](https://github.com/rails/rails/pull/14738))

*   Placeholder I18n следует тем же соглашениям, что и `label` I18n.
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

*   Представлен `deliver_later`, который добавляет в очередь задачу для доставки писем асинхронно.
    ([Pull Request](https://github.com/rails/rails/pull/16485))

*   Добавлена конфигурационная опция `show_previews` для включения предпросмотра писем вне окружения разработки.
    ([Pull Request](https://github.com/rails/rails/pull/15970))


Active Record
-------------

За подробностями обратитесь к [Changelog][active-record].

### Убрано

*   Убран `cache_attributes` и сотоварищи. Все атрибуты кэшируются.
    ([Pull Request](https://github.com/rails/rails/pull/15429))

*   Убран устаревший метод `ActiveRecord::Base.quoted_locking_column`.
    ([Pull Request](https://github.com/rails/rails/pull/15612))

*   Убран устаревший метод `ActiveRecord::Migrator.proper_table_name`. Используйте вместо него метод экземпляра `proper_table_name` на  `ActiveRecord::Migration`.
    ([Pull Request](https://github.com/rails/rails/pull/15512))

*   Убран неиспользуемый тип `:timestamp`. Прозрачно добавлен как псевдоним к `:datetime` во всех случаях. Исправлены несоответсвия, когда типы столбцов используются вне `ActiveRecord`, например для сериализации XML.
    ([Pull Request](https://github.com/rails/rails/pull/15184))

### Устарело

*   Устарело проглатывание ошибок в `after_commit` и `after_rollback`.
    ([Pull Request](https://github.com/rails/rails/pull/16537))

*   Устарел вызов `DatabaseTasks.load_schema` без соединения. Вместо него используйте `DatabaseTasks.load_schema_current`.
    ([Commit](https://github.com/rails/rails/commit/f15cef67f75e4b52fd45655d7c6ab6b35623c608))

*   Устарел `Reflection#source_macro` без замены, так как он больше не требуется в Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/16373))

*   Устарела сломанная поддержка автоматического определения кэширующих счетчиков на связях `has_many :through`. Вместо этого следует вручную указывать кэширующий счетчик на связях `has_many` и `belongs_to` для записей through.
    ([Pull Request](https://github.com/rails/rails/pull/15754))

*   Устарел `serialized_attributes` без замен.
    ([Pull Request](https://github.com/rails/rails/pull/15704))

*   Устарел возврат `nil` от `column_for_attribute` когда не существует столбец. Он будет возвращать null object в Rails 5.0
    ([Pull Request](https://github.com/rails/rails/pull/15878))

*   Устарело использование `.joins`, `.preload` и `.eager_load` со связями, зависящими от состояния экземпляра (т.е. те, которые определены со скоупом, принимающим аргумент) без замены.
    ([Commit](https://github.com/rails/rails/commit/ed56e596a0467390011bc9d56d462539776adac1))

*   Устарела передача объектов Active Record в `.find` или `.exists?`. Вместо этого сначала вызывайте `#id` на объектах.
    (Commit [1](https://github.com/rails/rails/commit/d92ae6ccca3bcfd73546d612efaea011270bd270),
    [2](https://github.com/rails/rails/commit/d35f0033c7dec2b8d8b52058fb8db495d49596f7))

*   Устарела недоделанная поддержка интервальных значений PostgreSQL с исключенными концами (полуинтервалов). Сейчас мы переводим интервалы PostgreSQL в интервалы Ruby. Это преобразование не полностью возможно, поскольку интервалы Ruby не поддерживают исключение концов.

    Текущее решение увеличения конца интервала не корректно и устарело. Для подтипов, в которых мы не знаем как увеличить (т.е. где не определен), он вызовет `ArgumentError` для интервалов с исключенными концами.

    ([Commit](https://github.com/rails/rails/commit/91949e48cf41af9f3e4ffba3e5eecf9b0a08bfc3))

### Значимые изменения

*   Адаптер PostgreSQL теперь поддерживает тип данных `JSONB` в PostgreSQL 9.4+.
    ([Pull Request](https://github.com/rails/rails/pull/16220))

*   Метод `#references` в миграциях теперь поддерживает опцию `type` для указания типа внешнего ключа (например, `:uuid`).
    ([Pull Request](https://github.com/rails/rails/pull/16231))

*   Добавлена опция `:required` к одиночным связям, определяющая наличие валидации для связи.
    ([Pull Request](https://github.com/rails/rails/pull/16056))

*   Представлен `ActiveRecord::Base#validate!`, вызывающий `RecordInvalid`, если запись невалидна.
    ([Pull Request](https://github.com/rails/rails/pull/8639))

*   `ActiveRecord::Base#reload` теперь ведет себя так же, как `m = Model.find(m.id)`, что означает, что он больше не помнит дополнительные атрибуты из кастомного `select`.
    ([Pull Request](https://github.com/rails/rails/pull/15866))

*   Представлен таск `bin/rake db:purge` для опустошения базы данных для текущей среды.
    ([Commit](https://github.com/rails/rails/commit/e2f232aba15937a4b9d14bd91e0392c6d55be58d))

*   `ActiveRecord::Dirty` теперь обнаруживает изменения в мутируемых значениях. Сериализованные атрибуты в моделях ActiveRecord больше не сохраняются, когда не изменились. Это также работает с другими типами, такими как строковые столбцы и json столбцы в PostgreSQL.
    (Pull Requests [1](https://github.com/rails/rails/pull/15674),
    [2](https://github.com/rails/rails/pull/15786),
    [3](https://github.com/rails/rails/pull/15788))

*   Добавлена поддержка для `#pretty_print` в объектах `ActiveRecord::Base`.
    ([Pull Request](https://github.com/rails/rails/pull/15172))

*   Адаптеры PostgreSQL и SQLite больше не добавляют лимит по умолчанию в 255 символов для строковых столбцов.
    ([Pull Request](https://github.com/rails/rails/pull/14579))

*   `sqlite3:///some/path` теперь считается абсолютным системным путем `/some/path`. Для относительных путей используйте `sqlite3:some/path`. (Раньше `sqlite3:///some/path` считался относительным путем `some/path`. Это поведение устарело в Rails 4.1).
    ([Pull Request](https://github.com/rails/rails/pull/14569))

*   Представлен `#validate` в качестве псевдонима для `#valid?`.
    ([Pull Request](https://github.com/rails/rails/pull/14456))

*   `#touch` теперь принимает несколько атрибутов, которые будут затронуты за раз.
    ([Pull Request](https://github.com/rails/rails/pull/14423))

*   Добавлена поддержка для долей секунд в MySQL 5.6 и выше.
    (Pull Request [1](https://github.com/rails/rails/pull/8240),
    [2](https://github.com/rails/rails/pull/14359))

*   Добавлена поддержка для типа столбца `citext` в адаптере PostgreSQL.
    ([Pull Request](https://github.com/rails/rails/pull/12523))

*   Добавлена поддержка для пользовательского интервального типа в адаптере PostgreSQL.
    ([Commit](https://github.com/rails/rails/commit/4cb47167e747e8f9dc12b0ddaf82bdb68c03e032))


Active Model
------------

За подробностями обратитесь к [Changelog][active-model].

### Убрано

*   Убран устаревший `Validator#setup` без замены.
    ([Pull Request](https://github.com/rails/rails/pull/10716))

### Устарело

*   Устарел `reset_#{attribute}` в пользу `restore_#{attribute}`.
    ([Pull Request](https://github.com/rails/rails/pull/16180))

*   Устарел `ActiveModel::Dirty#reset_changes` в пользу `#clear_changes_information`.
    ([Pull Request](https://github.com/rails/rails/pull/16180))

### Значимые изменения

*   Представлен метод `restore_attributes` в `ActiveModel::Dirty` для восстановления измененных (dirty) атрибутов их предыдущими значениями.
    (Pull Request [1](https://github.com/rails/rails/pull/14861),
    [2](https://github.com/rails/rails/pull/16180))

*   `has_secure_password` по умолчанию больше не запрещает пустые пароли (т.е. пароли, содержащие только пробелы).
    ([Pull Request](https://github.com/rails/rails/pull/16412))

*   Теперь `has_secure_password` проверяет, что заданный пароль меньше 72 символов, если включены валидации.
    ([Pull Request](https://github.com/rails/rails/pull/15708))

*   Представлен `#validate` в качестве псевдонима для `#valid?`.
    ([Pull Request](https://github.com/rails/rails/pull/14456))


Active Support
--------------

За подробностями обратитесь к [Changelog][active-support].

### Убрано

*   Убраны устаревшие `Numeric#ago`, `Numeric#until`, `Numeric#since`, `Numeric#from_now`.
    ([Commit](https://github.com/rails/rails/commit/f1eddea1e3f6faf93581c43651348f48b2b7d8bb))

*   Убраны устаревшие ограничители на основе строки для `ActiveSupport::Callbacks`.
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

*   Тестовый хелпер `travel_to` теперь обрезает компонент `usec` до 0.
    ([Commit](https://github.com/rails/rails/commit/9f6e82ee4783e491c20f5244a613fdeb4024beb5))

*   Представлен `Object#itself` как идентифицирующая функция.
    (Commit [1](https://github.com/rails/rails/commit/702ad710b57bef45b081ebf42e6fa70820fdd810),
    [2](https://github.com/rails/rails/commit/64d91122222c11ad3918cc8e2e3ebc4b0a03448a))

*   Теперь `Object#with_options` может использоваться без явного получателя.
    ([Pull Request](https://github.com/rails/rails/pull/16339))

*   Представлен `String#truncate_words` для обрезания строки по количеству слов.
    ([Pull Request](https://github.com/rails/rails/pull/16190))

*   Добавлены `Hash#transform_values` и `Hash#transform_values!` для упрощения обычной практики, когда значения хэша должны измениться, но ключи остаются прежними.
    ([Pull Request](https://github.com/rails/rails/pull/15819))

*   Теперь словообразующий хелпер `humanize` отбрасывает любые начальные знаки подчеркивания.
    ([Commit](https://github.com/rails/rails/commit/daaa21bc7d20f2e4ff451637423a25ff2d5e75c7))

*   Представлен `Concern#class_methods` как альтернатива `module ClassMethods`, а также `Kernel#concern` для избегания шаблонного `module Foo; extend ActiveSupport::Concern; end`.
    ([Commit](https://github.com/rails/rails/commit/b16c36e688970df2f96f793a759365b248b582ad))


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
