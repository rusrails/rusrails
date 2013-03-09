Руководство по обновлению Ruby on Rails
=======================================

Это руководство раскрывает шаги, которые нужно сделать, чтобы обновить свое приложение на новую версию Ruby on Rails. Эти шаги также доступны в отдельных руководствах по релизам.

Общий совет
-----------

Перед попыткой обновить существующее приложение, сперва следует убедиться, что есть хорошая причина для обновления. Нужно соблюсти баланс между несколькими факторами: необходимостью в новых особенностях, увеличением сложности в поиске поддержки для старого кода, доступностью вашего времени и навыков - это только некоторые из сногих.

### Тестовое покрытие

Лучшим способом убедиться, что ваше приложение продолжает работать после обновления, это иметь хорошее тестовое покрытие до начала обновления. Если у вас нет автоматических тестов, проверяющих большую часть вашего приложения, тогда нужно потратить время, проверяя все части, которые изменились. В случае обновления Rails это означает каждый отдельный кусок функционала приложения. Пожалейте себя и убедитесь в хорошем тестовом покрытии _до_ начала обновления.

### Версии Ruby

В основном Rails использует последние выпущенные версии Ruby:

* Rails 3 и выше требует Ruby 1.8.7 или выше. Поддержка всех прежних версий Ruby была официально прекращена, и следует обновиться как можно быстрее
* Rails 3.2.x был последней веткой с поддержкой Ruby 1.8.7.
* Rails 4 будет поддерживать только Ruby 1.9.3.

TIP: В Ruby 1.8.7 p248 и p249 имеются ошибки маршализации, ломающие Rails. Хотя в Ruby Enterprise Edition это было исправлено, начиная с релиза 1.8.7-2010.02. В ветке 1.9, Ruby 1.9.1 не пригоден к использованию, поскольку он иногда вылетает, поэтому, если хотите использовать 1.9.x перепрыгивайте на 1.9.2 или 1.9.3 для гладкой работы.

(upgrading-from-rails-3-2-to-rails-4-0) Обновление с Rails 3.2 на Rails 4.0
-------------------------------------

NOTE: This section is a work in progress.

Если версия Rails вашего приложения сейчас старше чем 3.2.x, следует сперва обновиться до Rails 3.2, перед попыткой обновиться до Rails 4.0.

Следующие изменения предназначены для обновления вашего приложения на Rails 4.0.

### vendor/plugins

Rails 4.0 больше не поддерживает загрузку плагинов из `vendor/plugins`. Следует переместить любые плагины, извлекая их в гемы и помещая их в Gemfile. Если решаете не делать гемы, можно переместить их, скажем, в `lib/my_plugin/*` и добавить соответствующий инициализатор в `config/initializers/my_plugin.rb`.

### Active Record

* Rails 4.0 убрал identity map из Active Record, из-за [некоторых несоответствий со связями](https://github.com/rails/rails/commit/302c912bf6bcd0fa200d964ec2dc4a44abe328a6). Если вы вручную включали это в своем приложении, нужно убрать соответствующую настройку, так как от нее больше не будет эффекта: `config.active_record.identity_map`.

* Метод `delete` в связях коллекции может получать аргументы `Fixnum` или `String` в качестве id записей, кроме самих записей, так же, как делает метод `destroy`. Раньше он вызывал `ActiveRecord::AssociationTypeMismatch` для таких аргументов. Начиная с Rails 4.0, `delete` пытается автоматически найти записи, соответствующие переданным id, до их удаления.

* Rails 4.0 изменил то, как складывается упорядочивание в `ActiveRecord::Relation`. В прежних версиях Rails, новый порядок применялся после предыдуще определенного. Но теперь это не так. Обратитесь к [Руководству по интерфейсу запросов Active Record](/active-record-query-interface#ordering) за дальнейшей информацией.

* Rails 4.0 изменил `serialized_attributes` и `attr_readonly` быть только методами класса. Теперь не следует использовать методы экземпляра, они устарели. Их следует изменить, т.е. `self.serialized_attributes` на `self.class.serialized_attributes`.

### Active Model

* Rails 4.0 изменил то, как прикрепляются ошибки с помощью `ActiveModel::Validations::ConfirmationValidator`. Теперь, когда не проходят валидации подтверждения, ошибка будет прикреплена к `:#{attribute}_confirmation` вместо `attribute`.

* Rails 4.0 изменил значение по умолчанию для `ActiveModel::Serializers::JSON.include_root_in_json` на `false`. Теперь сериализаторы Active Model и объекты Active Record имеют одинаковое значение по умолчанию. Это означает, что вы можете закомментировать или убрать следующую опцию в файле `config/initializers/wrap_parameters.rb`:

```ruby
# Disable root element in JSON by default.
# ActiveSupport.on_load(:active_record) do
#   self.include_root_in_json = false
# end
```

### Action Pack

* Имеется хранилище куки для обновления `UpgradeSignatureToEncryptionCookieStore`, помогающее обновить приложение, использующее `CookieStore`, на новое дефолтное `EncryptedCookieStore`. Для использования этого `CookieStore`, установите `Myapp::Application.config.session_store :upgrade_signature_to_encryption_cookie_store, key: '_myapp_session'` в `config/initializers/session_store.rb`. Дополнительно добавьте `Myapp::Application.config.secret_key_base = 'some secret'` в `config/initializers/secret_token.rb`. Не убирайте `Myapp::Application.config.secret_token = 'some secret'`.

* Rails 4.0 убрал опцию `ActionController::Base.asset_path`. Используйте особенность файлопровода (assets pipeline).

* В Rails 4.0 устарела опция `ActionController::Base.page_cache_extension`. Используйте вместо нее `ActionController::Base.default_static_extension`.

* Rails 4.0 убрал кэширование страниц и экшнов из Action Pack. Необходимо добавить гем `actionpack-action_caching` для использования `caches_action` и `actionpack-page_caching` для использования `caches_pages` в контроллерах.

* Rails 4.0 изменил работу `assert_generates`, `assert_recognizes` и `assert_routing`. Теперь все эти операторы контроля вызывают `Assertion` вместо `ActionController::RoutingError`.

* Rails 4.0 также изменил способ отрисовки маршрутов с символами unicode. Теперь можно непосредственно отрисовывать симвлы unicode character. Если вы уже отрисовываете такие маршруты, их нужно изменить, например:

```ruby
get Rack::Utils.escape('こんにちは'), controller: 'welcome', action: 'index'
```

станет

```ruby
get 'こんにちは', controller: 'welcome', action: 'index'
```

### Active Support

Rails 4.0 убрал псевдоним `j` для `ERB::Util#json_escape`, так как `j` уже используется для `ActionView::Helpers::JavaScriptHelper#escape_javascript`.

### Порядок загрузки хелперов

В Rails 4.0 изменился порядок, в котором загружались хелперы из более чем одной директории. Ранее они собирались, а затем сортировались по алфавиту. После обновления на Rails 4.0, хелперы будут сохранять порядок загружаемых директорий и будут сортироваться по алфавиту только в пределах каждой директории. Если вы явно не используете параметр `helpers_path`, Это изменение повлияет только на способ загрузки хелперов из engine-ов. Если вы полагаетесь на порядок загрузки, следует проврить, что после обновления доступны правильные методы. Если хотите изменить порядок, в котором загружаются engine, Можно использовать метод `config.railties_order=`.

Обновление с Rails 3.1 на Rails 3.2
-------------------------------------

Если версия Rails вашего приложения сейчас старше чем 3.1.x, следует сперва обновиться до Rails 3.1, перед попыткой обновиться до Rails 3.2.

Следующие изменения предназначены для обновления вашего приложения на Rails 3.2.2.

### Gemfile

Сделайте следующие изменения в своем `Gemfile`.

```ruby
gem 'rails', '= 3.2.2'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier',     '>= 1.0.3'
end
```

### config/environments/development.rb

Имеется ряд новых конфигурационных настроек, которые следует добавить в среде development:

```ruby
# Raise exception on mass assignment protection for Active Record models
config.active_record.mass_assignment_sanitizer = :strict

# Log the query plan for queries taking more than this (works
# with SQLite, MySQL, and PostgreSQL)
config.active_record.auto_explain_threshold_in_seconds = 0.5
```

### config/environments/test.rb

Также должна быть добавлена конфигурационная настройка `mass_assignment_sanitizer` в `config/environments/test.rb`:

```ruby
# Raise exception on mass assignment protection for Active Record models
config.active_record.mass_assignment_sanitizer = :strict
```

### vendor/plugins

В Rails 3.2 устаревает `vendor/plugins`, а в Rails 4.0 будет убрана полностью. Хотя это и не требуется строго при обновлении на Rails 3.2, можно начать перемещать любые плагины, извлекая их в гемы и помещая их в Gemfile. Если решаете не делать гемы, можно переместить их, скажем, в `lib/my_plugin/*` и добавить соответствующий инициализатор в `config/initializers/my_plugin.rb`.

Обновление с Rails 3.0 на Rails 3.1
-------------------------------------

Если версия Rails вашего приложения сейчас старше чем 3.0.x, следует сперва обновиться до Rails 3.0, перед попыткой обновиться до Rails 3.1.

Следующие изменения предназначены для обновления вашего приложения на Rails 3.1.3.

### Gemfile

Сделайте следующие изменения в своем `Gemfile`.

```ruby
gem 'rails', '= 3.1.3'
gem 'mysql2'

# Needed for the new asset pipeline
group :assets do
  gem 'sass-rails',   "~> 3.1.5"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier',     ">= 1.0.3"
end

# jQuery is the default JavaScript library in Rails 3.1
gem 'jquery-rails'
```

### config/application.rb

Файлопровод (asset pipeline) требует следующих добавлений:

```ruby
config.assets.enabled = true
config.assets.version = '1.0'
```

Если ваше приложение использует маршрут "/assets" для ресурса, можно изменить префикс, используемый для файлов, чтобы избежать конфликтов:

```ruby
# Defaults to '/assets'
config.assets.prefix = '/asset-files'
```

### config/environments/development.rb

Уберите настройку для RJS `config.action_view.debug_rjs = true`.

Добавьте эти настройки, если вы включили файлопровод:

```ruby
# Do not compress assets
config.assets.compress = false

# Expands the lines which load the assets
config.assets.debug = true
```

### config/environments/production.rb

Снова, большая часть изменений относится к файлопроводу. Подробнее о них можно прочитать в руководстве по [Asset Pipeline](/asset-pipeline).

```ruby
# Compress JavaScripts and CSS
config.assets.compress = true

# Don't fallback to assets pipeline if a precompiled asset is missed
config.assets.compile = false

# Generate digests for assets URLs
config.assets.digest = true

# Defaults to Rails.root.join("public/assets")
# config.assets.manifest = YOUR_PATH

# Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
# config.assets.precompile += %w( search.js )

# Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
# config.force_ssl = true
```

### config/environments/test.rb

Можно увеличить производительность тестов, добавив следующее в среде test:

```ruby
# Configure static asset server for tests with Cache-Control for performance
config.serve_static_assets = true
config.static_cache_control = "public, max-age=3600"
```

### config/initializers/wrap_parameters.rb

Добавьте эти файлы со следующим содержимым, если хотите оборачивать параметры во вложенный хэш. Для новых приложений это включено по умолчанию.

```ruby
# Be sure to restart your server when you modify this file.
# This file contains settings for ActionController::ParamsWrapper which
# is enabled by default.

# Enable parameter wrapping for JSON. You can disable this by setting :format to an empty array.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# Disable root element in JSON by default.
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
```

### config/initializers/session_store.rb

Необходимо изменить ключ сессии на другой, или удалить все сессии:

```ruby
# in config/initializers/session_store.rb
AppName::Application.config.session_store :cookie_store, key: 'SOMETHINGNEW'
```

или

```bash
$ rake db:sessions:clear
```

### Убрать опции :cache и :concat в ресурсных хелперах во вьюхах

* Вместе с Asset Pipeline опции :cache и :concat больше не используются, удалите их из вьюх.
