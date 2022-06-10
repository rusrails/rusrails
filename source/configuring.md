Конфигурирование приложений на Rails
====================================

Это руководство раскрывает особенности конфигурирования и инициализации, доступные приложениям на Rails.

После прочтения этого руководства, вы узнаете:

* Как конфигурировать поведение ваших приложений на Rails.
* Как добавить дополнительный код, запускаемый при старте приложения.

Расположение инициализационного кода
------------------------------------

Rails предлагает четыре стандартных места для размещения инициализационного кода:

* config/application.rb
* Конфигурационные файлы конкретных сред
* Инициализаторы
* Пост-инициализаторы

Запуск кода до Rails
--------------------

В тех редких случаях, когда вашему приложению необходимо запустить некоторый код до того, как сам Rails загрузится, поместите его до вызова `require "rails/all"` в `config/application.rb`.

Конфигурирование компонентов Rails
----------------------------------

В целом, работа по конфигурированию Rails означает как настройку компонентов Rails, так и настройку самого Rails. Конфигурационный файл `config/application.rb` и конфигурационные файлы конкретных сред (такие как `config/environments/production.rb`) позволяют определить различные настройки, которые можно придать всем компонентам.

Например, можно добавить эту настройку в файл `config/application.rb`:

```ruby
config.time_zone = 'Central Time (US & Canada)'
```

Это настройка для самого Rails. Если хотите передать настройки для отдельных компонентов Rails, это также осуществляется через объект `config` в `config/application.rb`:

```ruby
config.active_record.schema_format = :ruby
```

Rails будет использовать эту конкретную настройку для конфигурирования Active Record.

WARNING: Используйте публичные методы конфигурации, а не вызывайте на связанном классе. Т.е. `Rails.application.config.action_mailer.options` вместо `ActionMailer::Base.options`.

NOTE: Если необходимо применить конфигурацию непосредственно на классе, используйте [ленивый хук загрузки](https://api.rubyonrails.org/classes/ActiveSupport/LazyLoadHooks.html) в инициализаторе, чтобы избежать автоматической загрузки класса до завершения инициализации. Это ломает приложение, так как автозагрузка в течение инициализации не может быть безопасно повторена при перезагрузке приложения.

### Версионированные значения по умолчанию

[`config.load_defaults`] загружает конфигурационные значения для целевой и всех предыдущих версий. Например, `config.load_defaults 6.1` загрузит значения по умолчанию для всех ранних версий и версии 6.1.

[`config.load_defaults`]: https://api.rubyonrails.org/classes/Rails/Application/Configuration.html#method-i-load_defaults

Ниже перечислены значения по умолчанию, связанные с каждой целевой версией. В случае конфликтующих значений, новый версии имеют приоритет над старыми версиями.

#### Значения по умолчанию для целевой версии 7.1

- [`config.action_dispatch.default_headers`](#config-action-dispatch-default-headers): `{ "X-Frame-Options" => "SAMEORIGIN", "X-XSS-Protection" => "0", "X-Content-Type-Options" => "nosniff", "X-Permitted-Cross-Domain-Policies" => "none", "Referrer-Policy" => "strict-origin-when-cross-origin" }`
- [`config.add_autoload_paths_to_load_path`](#config-add-autoload-paths-to-load-path): `false`

#### Значения по умолчанию для целевой версии 7.0

- [`config.action_controller.raise_on_open_redirects`](#config-action-controller-raise-on-open-redirects): `true`
- [`config.action_view.button_to_generates_button_tag`](#config-action-view-button-to-generates-button-tag): `true`
- [`config.action_view.apply_stylesheet_media_default`](#config-action-view-apply-stylesheet-media-default): `false`
- [`config.active_support.key_generator_hash_digest_class`](#config-active-support-key-generator-hash-digest-class): `OpenSSL::Digest::SHA256`
- [`config.active_support.hash_digest_class`](#config-active-support-hash-digest-class): `OpenSSL::Digest::SHA256`
- [`config.active_support.cache_format_version`](#config-active-support-cache-format-version): `7.0`
- [`config.active_support.remove_deprecated_time_with_zone_name`](#config-active-support-remove-deprecated-time-with-zone-name): `true`
- [`config.active_support.executor_around_test_case`](#config-active-support-executor-around-test-case): `true`
- [`config.active_support.use_rfc4122_namespaced_uuids`](#config-active-support-use-rfc4122-namespaced-uuids): `true`
- [`config.active_support.disable_to_s_conversion`](#config-active-support-disable-to-s-conversion): `true`
- [`config.action_dispatch.return_only_request_media_type_on_content_type`](#config-action-dispatch-return-only-request-media-type-on-content-type): `false`
- [`config.action_dispatch.cookies_serializer`](#config-action-dispatch-cookies-serializer): `:json`
- [`config.action_mailer.smtp_timeout`](#config-action-mailer-smtp-timeout): `5`
- [`config.active_storage.video_preview_arguments`](#config-active-storage-video-preview-arguments): `"-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015),loop=loop=-1:size=2,trim=start_frame=1' -frames:v 1 -f image2"`
- [`config.active_storage.multiple_file_field_include_hidden`](#config-active-storage-multiple-file-field-include-hidden): `true`
- [`config.active_record.automatic_scope_inversing`](#config-active-record-automatic-scope-inversing): `true`
- [`config.active_record.verify_foreign_keys_for_fixtures`](#config-active-record-verify-foreign-keys-for-fixtures): `true`
- [`config.active_record.partial_inserts`](#config-active-record-partial-inserts): `false`
- [`config.active_storage.variant_processor`](#config-active-storage-variant-processor): `:vips`
- [`config.action_controller.wrap_parameters_by_default`](#config-action-controller-wrap-parameters-by-default): `true`
- [`config.action_dispatch.default_headers`](#config-action-dispatch-default-headers): `{ "X-Frame-Options" => "SAMEORIGIN", "X-XSS-Protection" => "0", "X-Content-Type-Options" => "nosniff", "X-Download-Options" => "noopen", "X-Permitted-Cross-Domain-Policies" => "none", "Referrer-Policy" => "strict-origin-when-cross-origin" }`

#### Значения по умолчанию для целевой версии 6.1

- [`config.active_record.has_many_inversing`](#config-active-record-has-many-inversing): `true`
- [`config.active_record.legacy_connection_handling`](#config-active-record-legacy-connection-handling): `false`
- [`config.active_storage.track_variants`](#config-active-storage-track-variants): `true`
- [`config.active_storage.queues.analysis`](#config-active-storage-queues-analysis): `nil`
- [`config.active_storage.queues.purge`](#config-active-storage-queues-purge): `nil`
- [`config.action_mailbox.queues.incineration`](#config-action-mailbox-queues-incineration): `nil`
- [`config.action_mailbox.queues.routing`](#config-action-mailbox-queues-routing): `nil`
- [`config.action_mailer.deliver_later_queue_name`](#config-action-mailer-deliver-later-queue-name): `nil`
- [`config.active_job.retry_jitter`](#config-active-job-retry-jitter): `0.15`
- [`config.action_dispatch.cookies_same_site_protection`](#config-action-dispatch-cookies-same-site-protection): `:lax`
- [`config.action_dispatch.ssl_default_redirect_status`](`config.action_dispatch.ssl_default_redirect_status`) = `308`
- [`ActiveSupport.utc_to_local_returns_utc_offset_times`](#activesupport-utc-to-local-returns-utc-offset-times): `true`
- [`config.action_controller.urlsafe_csrf_tokens`](#config-action-controller-urlsafe-csrf-tokens): `true`
- [`config.action_view.form_with_generates_remote_forms`](#config-action-view-form-with-generates-remote-forms): `false`
- [`config.action_view.preload_links_header`](#config-action-view-preload-links-header): `true`

#### Значения по умолчанию для целевой версии 6.0

- [`config.action_view.default_enforce_utf8`](#config-action-view-default-enforce-utf8): `false`
- [`config.action_dispatch.use_cookies_with_metadata`](#config-action-dispatch-use-cookies-with-metadata): `true`
- [`config.action_mailer.delivery_job`](#config-action-mailer-delivery-job): `"ActionMailer::MailDeliveryJob"`
- [`config.active_storage.queues.analysis`](#config-active-storage-queues-analysis): `:active_storage_analysis`
- [`config.active_storage.queues.purge`](#config-active-storage-queues-purge): `:active_storage_purge`
- [`config.active_storage.replace_on_assign_to_many`](#config-active-storage-replace-on-assign-to-many): `true`
- [`config.active_record.collection_cache_versioning`](#config-active-record-collection-cache-versioning): `true`

#### Значения по умолчанию для целевой версии 5.2

- [`config.active_record.cache_versioning`](#config-active-record-cache-versioning): `true`
- [`config.action_dispatch.use_authenticated_cookie_encryption`](#config-action-dispatch-use-authenticated-cookie-encryption): `true`
- [`config.active_support.use_authenticated_message_encryption`](#config-active-support-use-authenticated-message-encryption): `true`
- [`config.active_support.hash_digest_class`](#config-active-support-hash-digest-class): `OpenSSL::Digest::SHA1`
- [`config.action_controller.default_protect_from_forgery`](#config-action-controller-default-protect-from-forgery): `true`
- [`config.action_view.form_with_generates_ids`](#config-action-view-form-with-generates-ids): `true`

#### Значения по умолчанию для целевой версии 5.1

- [`config.assets.unknown_asset_fallback`](#config-assets-unknown-asset-fallback): `false`
- [`config.action_view.form_with_generates_remote_forms`](#config-action-view-form-with-generates-remote-forms): `true`

#### Значения по умолчанию для целевой версии 5.0

- [`config.action_controller.per_form_csrf_tokens`](#config-action-controller-per-form-csrf-tokens): `true`
- [`config.action_controller.forgery_protection_origin_check`](#config-action-controller-forgery-protection-origin-check): `true`
- [`ActiveSupport.to_time_preserves_timezone`](#activesupport-to-time-preserves-timezone): `true`
- [`config.active_record.belongs_to_required_by_default`](#config-active-record-belongs-to-required-by-default): `true`
- [`config.ssl_options`](#config-ssl-options): `{ hsts: { subdomains: true } }`

### (rails-general-configuration) Общие настройки Rails

Следующие конфигурационные методы вызываются на объекте `Rails::Railtie`, таком как подкласс `Rails::Engine` или `Rails::Application`.

#### `config.after_initialize`

Принимает блок, который будет запущен _после того_, как Rails закончит инициализацию приложения. Это включает инициализацию самого фреймворка, engine-ов и всех инициализаторов приложения из `config/initializers`. Отметьте, что этот блок _будет_ запущен для Rake задач. Полезно для конфигурирования настроек, установленных другими инициализаторами:

```ruby
config.after_initialize do
  ActionView::Base.sanitized_allowed_tags.delete 'div'
end
```

#### `config.asset_host`

Устанавливает хост для ассетов. Полезна, когда для хостинга ассетов используются CDN, или когда необходимо обойти встроенные в браузеры конкурентные ограничения, используя различные псевдонимы доменов. Укороченная версия `config.action_controller.asset_host`.

#### `config.autoload_once_paths`

Принимает массив путей, по которым Rails будет загружать константы, не стирающиеся между запросами. Уместна, если `config.cache_classes` является `false`, что является в среде development по умолчанию. В противном случае все автозагрузки происходят только раз. Все элементы этого массива также должны быть в `autoload_paths`. По умолчанию пустой массив.

#### `config.autoload_paths`

Принимает массив путей, по которым Rails будет автоматически загружать константы. По умолчанию пустой массив. Начиная с [Rails 6](/upgrading-ruby-on-rails#autoloading) не рекомендуется настраивать это. Подробнее смотрите в руководстве [Автозагрузка и перезагрузка констант](/constant_autoloading_and_reloading#autoload-paths)

#### `config.add_autoload_paths_to_load_path`

Сообщает, должны ли пути автозагрузки быть добавлены в `$LOAD_PATH`. Рекомендуется установить его `false` в режиме `:zeitwerk` как можно раньше, в `config/application.rb`. Внутри Zeitwerk используются абсолютные пути, и приложения, запущенные в режиме `:zeitwerk`, не требуют `require_dependency`, поэтому модели, контроллеры, задания и т.д. не должны быть в `$LOAD_PATH`. Настройка `false` предотвращает Ruby от проверок этих директорий при разрешении вызовов `require` с относительными путями, и экономит работу Bootsnap и RAM, так как ему не нужно их индексировать.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `true`                |
| 7.1              | `false`               |

#### `config.cache_classes`

Контролирует, будут ли классы и модули приложения перезагружены при изменении. Когда кэш включен (`true`), перезагрузка не случится. По умолчанию `false` в среде development и true в production. В среде test по умолчанию `false`, если установлен Spring, в противном случае `true`.

#### `config.beginning_of_week`

Устанавливает начало недели по умолчанию для приложения. Принимает валидный день недели как символ (например, `:monday`).

#### `config.cache_store`

Конфигурирует, какое хранилище кэша использовать для кэширования Rails. Опции включают один из символов `:memory_store`, `:file_store`, `:mem_cache_store`, `:null_store`, `:redis_cache_store` или объект, реализующий API кэша. По умолчанию `:file_store`. Специфичные опции смотрите в [Хранилища кэша](caching_with_rails.html#cache-stores).

#### `config.colorize_logging`

Определяет, использовать ли коды цвета ANSI при логировании информации. По умолчанию `true`.

#### `config.consider_all_requests_local`

Это флажок. Если `true`, тогда любая ошибка вызовет детальную отладочную информацию, которая будет выгружена в отклик HTTP, и контроллер `Rails::Info` покажет контекст выполнения приложения в `/rails/info/properties`. По умолчанию `true` в средах development и test, и `false` в production. Для более детального контроля, установите ее в `false` и реализуйте `show_detailed_exceptions?` в контроллерах для определения, какие запросы должны предоставлять отладочную информацию при ошибках.

#### `config.console`

Позволяет установить класс, который будет использован как консоль при вызове `bin/rails console`. Лучше всего запускать его в блоке `console`:

```ruby
console do
  # этот блок вызывается только при запуске консоли,
  # поэтому можно безопасно поместить тут pry
  require "pry"
  config.console = Pry
end
```

#### `config.disable_sandbox`

Контролирует, сможет ли кто-нибудь запустить консоль в режиме песочницы. Это полезно длинных сессий в песочнице, что может привести к дефициту памяти сервера базы данных. По умолчанию false.

#### `config.eager_load`

Когда `true`, лениво загружает все зарегистрированные `config.eager_load_namespaces`. Они включают ваше приложение, engine-ы, фреймворки Rails и любые другие зарегистрированные пространства имен.

#### `config.eager_load_namespaces`

Регистрирует пространства имен, которые лениво загружаются, когда `config.eager_load` установлен `true`. Все пространства имен в этом списке должны отвечать на метод `eager_load!`.

#### `config.eager_load_paths`

Принимает массив путей, из которых Rails будет нетерпеливо загружать при загрузке, если `config.cache_classes` установлен `true`. По умолчанию каждая папка в директории `app` приложения.

#### `config.enable_dependency_loading`

Когда true, включает автозагрузку, даже если приложение нетерпеливо загружено и `config.cache_classes` установлена как `true`. По умолчанию false.

#### `config.encoding`

Настраивает кодировку приложения. По умолчанию UTF-8.

#### `config.exceptions_app`

Устанавливает приложение по обработке исключений, вызываемое промежуточной программой ShowException, когда происходит исключение. По умолчанию `ActionDispatch::PublicExceptions.new(Rails.public_path)`.

#### `config.debug_exception_response_format`

Устанавливает формат, используемый в откликах, когда возникают ошибки в среде development. По умолчанию `:api` для только API приложений и `:default` для нормальных приложений.

#### `config.file_watcher`

Это класс, используемый для обнаружения обновлений файлов в файловой системе, когда `config.reload_classes_only_on_change` равно `true`. Rails поставляется с `ActiveSupport::FileUpdateChecker` (по умолчанию) и `ActiveSupport::EventedFileUpdateChecker` (этот зависит от гема [listen](https://github.com/guard/listen)). Пользовательские классы должны соответствовать `ActiveSupport::FileUpdateChecker` API.

#### (config-filter-parameters) `config.filter_parameters`

Используется для фильтрации параметров, которые не должны быть показаны в логах, такие как пароли или номера кредитных карт. Он также фильтрует чувствительные параметры в столбцах базы данных при вызове `#inspect` на объектах Active Record. По умолчанию Rails фильтрует пароли, добавляя `Rails.application.config.filter_parameters += [:password]` в `config/initializers/filter_parameter_logging.rb`. Фильтр параметров работает как частично соответствующее регулярное выражение.

#### (config-force-ssl) `config.force_ssl`

Принуждает все запросы обслуживаться протоколом HTTPS и устанавливает "https://" как протокол по умолчанию при генерации URL. Принуждение к HTTPS обрабатывается промежуточной программой `ActionDispatch::SSL`, которая может быть настроена с помощью `config.ssl_options`.

#### `config.javascript_path`

Устанавливает путь, по которому располагается JavaScript приложения относительно директории `app`. По умолчанию `javascript`, используемый [webpacker](https://github.com/rails/webpacker). Сконфигурированный `javascript_path` приложения будет убран из `autoload_paths`.

#### `config.log_formatter`

Определяет форматер для логгера Rails. Эта опция по умолчанию равна экземпляру `ActiveSupport::Logger::SimpleFormatter` для всех сред. Если установите значение для `config.logger`, вы должны вручную передать значение вашего форматера для вашего логгера до того, как он будет обернут в экземпляр `ActiveSupport::TaggedLogging`, Rails не сделает это за вас.

#### `config.log_level`

Определяет многословность логгера Rails. Эта опция по умолчанию `:debug` для всех сред, кроме production, где он по умолчанию `:info`. Доступные уровни лога: `:debug`, `:info`, `:warn`, `:error`, `:fatal`, and `:unknown`.

#### `config.log_tags`

Принимает список методов, на которые отвечает объект `request`, объект `Proc`, который принимает `request` объект, или что-то, отвечающее на `to_s`. С помощью этого становится просто тегировать строчки лога отладочной информацией, такой как поддомен и id запроса - очень полезно для отладки многопользовательского приложения.

#### `config.logger`

Это логгер, который будет использован для `Rails.logger` и любого логирования, относящегося к Rails, такого как `ActiveRecord::Base.logger`. По умолчанию это экземпляр `ActiveSupport::TaggedLogging`, оборачивающий экземпляр `ActiveSupport::Logger`, который пишет лог в директорию `log/`. Можно предоставить произвольный логгер, чтобы получить полную совместимость, нужно следовать следующим рекомендациям:

* Чтобы поддерживался форматер, необходимо в логгере вручную назначить форматер из значения `config.log_formatter`.
* Чтобы поддерживались тегированные логи, экземпляр лога должен быть обернут в `ActiveSupport::TaggedLogging`.
* Чтобы поддерживалось глушение, логгер должен включать модуль `ActiveSupport::LoggerSilence`. Класс `ActiveSupport::Logger` уже включает эти модули.

```ruby
class MyLogger < ::Logger
  include ActiveSupport::LoggerSilence
end

mylogger           = MyLogger.new(STDOUT)
mylogger.formatter = config.log_formatter
config.logger      = ActiveSupport::TaggedLogging.new(mylogger)
```

#### `config.middleware`

Позволяет настроить промежуточные программы приложения. Это подробнее раскрывается в разделе [Конфигурирование промежуточных программ](#configuring-middleware) ниже.

#### `config.rake_eager_load`

Когда `true`, нетерпеливо загружает приложении при запуске задач Rake. По умолчанию `false`.

#### `config.reload_classes_only_on_change`

Включает или отключает перезагрузку классов только при изменении отслеживаемых файлов. По умолчанию отслеживает все по путям автозагрузки и установлена `true`. Если `config.cache_classes` установлена `true`, эта опция игнорируется.

#### `config.credentials.content_path`

Настраивает путь поиска зашифрованных учетных данных.

#### `config.credentials.key_path`

Настраивает путь поиска ключа шифрования.

#### `secret_key_base`

Используется для определения ключа, позволяющего сессиям приложения быть верифицированными по известному ключу безопасности, чтобы избежать подделки. Приложения получают случайно сгенерированный ключ в test и development средах, другие среды должны устанавливать это в `config/credentials.yml.enc`.

#### `config.require_master_key`

Приложение не будет загружено, если главный ключ не доступен в `ENV["RAILS_MASTER_KEY"]` или файле `config/master.key`.

#### `config.public_file_server.enabled`

Конфигурирует Rails на обслуживание статичных файлов из директории public. Эта опция по умолчанию `true`, но в среде production устанавливается `false`, так как серверные программы (например, NGINX или Apache), используемые для запуска приложения, должны обслуживать статичные ресурсы вместо Rails. Если запускаете или тестируете приложение в production с помощью WEBrick (не рекомендуется использовать WEBrick в production), установите эту опцию в `true`. В противном случае нельзя воспользоваться кэшированием страниц и запросами файлов, существующих в директории public.

#### `config.session_store`

Определяет, какой класс использовать для хранения сессии. Возможные значения `:cookie_store`, которое по умолчанию, `:mem_cache_store` и `:disabled`. Последнее говорит Rails не связываться с сессиями. По умолчанию равно хранилищу куки с именем приложения в качестве ключа сессии. Произвольные хранилища сессии также могут быть определены:

```ruby
config.session_store :my_custom_store
```

Это произвольное хранилище должно быть определено как `ActionDispatch::Session::MyCustomStore`.

#### `config.ssl_options`

Конфигурационные опции для промежуточной программы [`ActionDispatch::SSL`](https://api.rubyonrails.org/classes/ActionDispatch/SSL.html).

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `{}`                  |
| 5.0              | `{ hsts: { subdomains: true } }` |

#### `config.time_zone`

Устанавливает временную зону по умолчанию для приложения и включает понимание временных зон для Active Record.

### Настройка ассетов

#### `config.assets.enabled`

Флажок, контролирующий, будет ли включен файлопровод (asset pipeline). По умолчанию он устанавливается `true`.

#### `config.assets.css_compressor`

Определяет используемый компрессор CSS. По умолчанию установлен `sass-rails`. Единственное альтернативное значение в настоящий момент это `:yui`, использующее гем `yui-compressor`.

#### `config.assets.js_compressor`

Определяет используемый компрессор JavaScript. Возможные варианты `:terser`, `:closure`, `:uglifier` и `:yui` требуют использование гемов `terser`, `closure-compiler`, `uglifier` или `yui-compressor` соответственно.

#### `config.assets.gzip`

Флажок, включающий создание сжатых версий скомпилированных ассетов вместе с несжатыми ассетами. По умолчанию установлено `true`.

#### `config.assets.paths`

Содержит пути, используемые для поиска ассетов. Присоединение путей к этой конфигурационной опции приведет к тому, что эти пути будут использованы в поиске ассетов.

#### `config.assets.precompile`

Позволяет определить дополнительные ассеты (иные, чем `application.css` и `application.js`), которые будут предварительно компилированы при запуске `rake assets:precompile`.

#### `config.assets.unknown_asset_fallback`

Позволяет модифицировать поведение файлопровода, когда ассет не в нем, если вы используете sprockets-rails 3.2.0 или новее.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `true`                |
| 5.1              | `false`               |

#### `config.assets.prefix`

Определяет префикс из которого будут обслуживаться ассеты. По умолчанию `/assets`.

#### `config.assets.manifest`

Определяет полный путь для использования файлом манифеста прекомпилятора ассетов. По умолчанию файл называется `manifest-<random>.json` в директории `config.assets.prefix` в папке public.

#### `config.assets.digest`

Включает использование меток SHA256 в именах ассетов. Установлено по умолчанию `true`.

#### `config.assets.debug`

Отключает объединение и сжатие ассетов. Установлено по умолчанию `true` в `development.rb`.

#### `config.assets.version`

Опция, используемая в генерации хэша SHA256. Ее можно использовать чтобы принудительно перекомпилировать все файлы.

#### `config.assets.compile`

Булево значение, используемое для включения компиляции Sprockets на лету в production.

#### `config.assets.logger`

Принимает логгер, соответствующий интерфейсу Log4r, или дефолтный Ruby класс `Logger`. По умолчанию такой же, как указан в `config.logger`. Установка `config.assets.logger` в `false` отключает логирование отдаваемых ассетов.

#### `config.assets.quiet`

Отключает логирование запросов к ассетам. Установлено `true` по умолчанию в `development.rb`.

### Конфигурирование генераторов

Rails позволяет изменить, какие генераторы следует использовать, с помощью метода `config.generators`. Этот метод принимает блок:

```ruby
config.generators do |g|
  g.orm :active_record
  g.test_framework :test_unit
end
```

Полный перечень методов, которые можно использовать в этом блоке, следующий:

* `force_plural` позволяет имена моделей во множественном числе. По умолчанию `false`.

* `helper` определяет, генерировать ли хелперы. По умолчанию `true`.

* `integration_tool` определяет интеграционный инструмент, используемый для генерации интеграционных тестов. По умолчанию `:test_unit`.

* `system_tests` определяет интеграционный инструмент, используемый для генерации системных тестов. По умолчанию `:test_unit`.

* `orm` определяет используемую orm. По умолчанию `false` и используется Active Record.

* `resource_controller` определяет используемый генератор для генерация контроллера при использовании `bin/rails generate resource`. По умолчанию `:controller`.

* `resource_route` определяет нужно ли генерировать определение ресурсного маршрута или нет. По умолчанию `true`.

* `scaffold_controller`, отличающийся от `resource_controller`, определяет используемый генератор для генерации контроллера _скаффолда_ при использовании `bin/rails generate scaffold`. По умолчанию `:scaffold_controller`.

* `test_framework` определяет используемый тестовый фреймворк. По умолчанию `false`, и используется minitest.

* `template_engine` определяет используемый движок шаблонов, такой как ERB или Haml. По умолчанию `:erb`.

### (configuring-middleware) Конфигурирование промежуточных программ (middleware)

Каждое приложение Rails имеет стандартный набор промежуточных программ, используемых в следующем порядке в среде development:

#### `ActionDispatch::HostAuthorization`

Предотвращает от перепривязывания DNS и других атак, связанных с заголовком `Host`. Это включено по умолчанию в среде development с помощью следующей конфигурации:

```ruby
Rails.application.config.hosts = [
  IPAddr.new("0.0.0.0/0"),        # All IPv4 addresses.
  IPAddr.new("::/0"),             # All IPv6 addresses.
  "localhost",                    # The localhost reserved domain.
  ENV["RAILS_DEVELOPMENT_HOSTS"]  # Additional comma-separated hosts for development.
]
```

В других средах `Rails.application.config.hosts` пустой, и никаких проверок заголовка `Host` не производится. Если хотите защититься от атак на заголовок в production, нужно вручную разрешить допустимые хосты с помощью:

```ruby
Rails.application.config.hosts << "product.com"
```

Хост запроса сверяется с записями `hosts` с помощью case-оператора (`#===`), который позволяет `hosts` поддерживать записи типа  `Regexp`, `Proc`, `IPAddr` и так далее. Вот пример с регулярным выражением.

```ruby
# Разрешает запросы с поддоменов, наподобие `www.product.com` и `beta1.product.com`.
Rails.application.config.hosts << /.*\.product\.com/
```

Предоставленное регулярное выражение будет обернуто обоими якорями (`\A` и `\z`), поэтому оно должно соответствовать полному имени хоста. К примеру, `/product.com/`, будучи обернутым, не будет соответствовать `www.product.com`.

Поддерживается особенный случай, позволяющий разрешить все поддомены:

```ruby
# Разрешает запросы с поддоменов, наподобие `www.product.com` и `beta1.product.com`.
Rails.application.config.hosts << ".product.com"
```

Можно исключить определенные запросы из проверок Host Authorization, установив `config.host_configuration.exclude`:

```ruby
# Исключает запросы для пути /healthcheck/ из проверки хоста
Rails.application.config.host_configuration = {
  exclude: ->(request) { request.path =~ /healthcheck/ }
}
```

Когда запрос приходит с неавторизованного хоста, запустится приложение Rack по умолчанию, которое ответит `403 Forbidden`. Это можно настроить, установив `config.host_configuration.response_app`. Например:

```ruby
Rails.application.config.host_configuration = {
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Bad Request"]]
  end
}
```

#### `ActionDispatch::SSL`

Принуждает каждый запрос быть обслуженным с помощью HTTPS. Включен, если `config.force_ssl` установлена `true`. Передаваемые сюда опции могут быть настроены с помощью `config.ssl_options`.

#### `ActionDispatch::Static`

Используется для обслуживания статичных ассетов. Отключено, если `config.public_file_server.enabled` равна `false`. Установите `config.public_file_server.index_name` если вам нужно обслуживать индексный файл статичной директории, который называется не `index`. Например, для обслуживания `main.html` вместо `index.html` для запросов, установите `config.public_file_server.index_name` в `"main"`.

#### `ActionDispatch::Executor`

Позволяет тредобезопасную перезагрузку кода. Отключено, если `config.allow_concurrency` установлена `false`, что загружает `Rack::Lock`. `Rack::Lock` оборачивает приложение в мьютекс, таким образом оно может быть вызвано только в одном треде одновременно.

#### `ActiveSupport::Cache::Strategy::LocalCache`

Служит простым кэшем в памяти. Этот кэш не является тредобезопасным и предназначен только как временное хранилище кэша для отдельного треда.

#### `Rack::Runtime`

Устанавливает заголовок `X-Runtime`, содержащий время (в секундах), затраченное на выполнение запроса.

#### `Rails::Rack::Logger`

Пишет в лог, что начался запрос. После выполнения запроса сбрасывает логи.

#### `ActionDispatch::ShowExceptions`

Ловит исключения, возвращаемые приложением, и рендерит прекрасные страницы исключения, если запрос локальный, или если `config.consider_all_requests_local` установлена `true`. Если `config.action_dispatch.show_exceptions` установлена `false`, исключения будут вызваны несмотря ни на что.

#### `ActionDispatch::RequestId`

Создает уникальный заголовок X-Request-Id, доступный для отклика, и включает метод `ActionDispatch::Request#uuid`. Настраивается с помощью `config.action_dispatch.request_id_header`.

#### `ActionDispatch::RemoteIp`

Проверяет на атаки с ложных IP и получает валидный `client_ip` из заголовков запроса. Конфигурируется с помощью опций `config.action_dispatch.ip_spoofing_check` и `config.action_dispatch.trusted_proxies`.

#### `Rack::Sendfile`

Перехватывает отклики, чьи тела были обслужены из файла, и заменяет их специфичным для сервером заголовком X-Sendfile. Конфигурируется с помощью `config.action_dispatch.x_sendfile_header`.

#### `ActionDispatch::Callbacks`

Запускает подготовленные колбэки до обслуживания запроса.

#### `ActionDispatch::Cookies`

Устанавливает куки для каждого запроса.

#### `ActionDispatch::Session::CookieStore`

Ответственна за хранение сессии в куки. Для этого может использоваться альтернативная промежуточная программа, при изменении `config.action_controller.session_store` на альтернативное значение. Кроме того, переданные туда опции могут быть сконфигурированы `config.action_controller.session_options`.

#### `ActionDispatch::Flash`

Настраивает ключи `flash`. Доступно, только если у `config.action_controller.session_store` установлено значение.

#### `Rack::MethodOverride`

Позволяет методу быть переопределенным, если установлен `params[:_method]`. Это промежуточная программа, поддерживающая типы методов HTTP PATCH, PUT и DELETE.

#### `Rack::Head`

Преобразует запросы HEAD в запросы GET и обслуживает их соответствующим образом.

#### Добавление собственных промежуточных программ

Кроме этих полезных промежуточных программ можно добавить свои, используя метод `config.middleware.use`:

```ruby
config.middleware.use Magical::Unicorns
```

Это поместит промежуточную программу `Magical::Unicorns` в конец стека. Можно использовать `insert_before`, если желаете добавить промежуточную программу перед другой.

```ruby
config.middleware.insert_before Rack::Head, Magical::Unicorns
```

Или можно вставить промежуточную программу на конкретное место с помощью индексов. Например, если хотите вставить промежуточную программу `Magical::Unicorns` наверх стека, это можно сделать так:

```ruby
config.middleware.insert_before 0, Magical::Unicorns
```

Также есть `insert_after`, который вставляет промежуточную программу после другой:

```ruby
config.middleware.insert_after Rack::Head, Magical::Unicorns
```

Промежуточные программы также могут быть полностью переставлены и заменены другими:

```ruby
config.middleware.swap ActionController::Failsafe, Lifo::Failsafe
```

Промежуточные программы могут быть перемещены:

```ruby
config.middleware.move_before ActionDispatch::Flash, Magical::Unicorns
```

Это поставит промежуточную программу `Magical::Unicorns` перед `ActionDispatch::Flash`. Можно поставить после:

```ruby
config.middleware.move_after ActionDispatch::Flash, Magical::Unicorns
```

Они также могут быть убраны из стека полностью:

```ruby
config.middleware.delete Rack::MethodOverride
```

### Конфигурирование i18n

Все эти конфигурационные опции делегируются в библиотеку `I18n`.

#### `config.i18n.available_locales`

Определяет разрешенные доступные локали приложения. По умолчанию все ключи локалей, обнаруженные в файлах локалей, обычно только `:en` для нового приложения.

#### `config.i18n.default_locale`

Устанавливает локаль по умолчанию для приложения, используемого для интернационализации. По умолчанию `:en`.

#### `config.i18n.enforce_available_locales`

Обеспечивает, что все локали, переданные из i18n, должны быть объявлены в списке `available_locales`, вызывая исключение `I18n::InvalidLocale` при установке недоступной локали. По умолчанию `true`. Рекомендуется не отключать эту опцию, если этого не сильно требуется, так как она работает в качестве меры безопасности от установки неверной локали на основе пользовательских данных.

#### `config.i18n.load_path`

Устанавливает путь, используемый Rails для поиска файлов локали. По умолчанию `config/locales/*.{yml,rb}`.

#### `config.i18n.raise_on_missing_translations`

Определяет, должна ли вызываться ошибка на отсутствующих переводах в контроллерах и вью. По умолчанию `false`.

#### `config.i18n.fallbacks`

Устанавливает поведение фолбэка для отсутствующих переводов. Вот 3 примера использования этой опции:

  * Можно установить опции `true` для использования локали по умолчанию в качестве фолбэка следующим образом:

    ```ruby
    config.i18n.fallbacks = true
    ```

  * Или можно установить массив локалей в качестве фолбэка так:

    ```ruby
    config.i18n.fallbacks = [:tr, :en]
    ```

  * Или можно установить различные фолбэки для различных локалей. Например, если хотите использовать `:tr` для `:az` и `:de`, `:en` для `:da` в качестве фолбэков, можно сделать так:

    ```ruby
    config.i18n.fallbacks = { az: :tr, da: [:de, :en] }
    # или
    config.i18n.fallbacks.map = { az: :tr, da: [:de, :en] }
    ```

### Конфигурирование Active Model

#### `config.active_model.i18n_customize_full_message`

Это булево значение, управляющее, может ли формат ошибки `full_message` быть переопределен на уровне атрибута или модели в файлах локали. По умолчанию `false`.

### Конфигурирование Active Record

`config.active_record` включает ряд конфигурационных опций:

#### `config.active_record.logger`

Принимает логгер, соответствующий интерфейсу Log4r или дефолтного класса Ruby Logger, который затем передается на любые новые сделанные соединения с базой данных. Можете получить этот логгер, вызвав `logger` или на любом классе модели Active Record, или на экземпляре модели Active Record. Установите его в nil, чтобы отключить логирование.

#### `config.active_record.primary_key_prefix_type`

Позволяет настроить именование столбцов первичного ключа. По умолчанию Rails полагает, что столбцы первичного ключа именуются `id` (и эта конфигурационная опция не нуждается в установке). Есть два возможных варианта:

* `:table_name` сделает первичный ключ для класса Customer как `customerid`
* `:table_name_with_underscore` сделает первичный ключ для класса Customer как `customer_id`

#### `config.active_record.table_name_prefix`

Позволяет установить глобальную строку, добавляемую в начало имен таблиц. Если установить ее равным `northwest_`, то класс Customer будет искать таблицу `northwest_customers`. По умолчанию это пустая строка.

#### `config.active_record.table_name_suffix`

Позволяет установить глобальную строку, добавляемую в конец имен таблиц. Если установить ее равным `_northwest`, то класс Customer будет искать таблицу `customers_northwest`. По умолчанию это пустая строка.

#### `config.active_record.schema_migrations_table_name`

Позволяет установить строку, которая будет использоваться как имя таблицы для миграций схемы.

#### `config.active_record.internal_metadata_table_name`

Позволяет установить строку, которая будет использоваться как имя таблицы для внутренних метаданных.

#### `config.active_record.protected_environments`

Позволяет установить массив имен сред, где деструктивные экшны должны быть запрещены.

#### `config.active_record.pluralize_table_names`

Определяет, должен Rails искать имена таблиц базы данных в единственном или множественном числе. Если установлено `true` (по умолчанию), то класс Customer будет использовать таблицу `customers`. Если установить `false`, то класс Customers будет использовать таблицу `customer`.

#### `config.active_record.default_timezone`

Определяет, использовать `Time.local` (если установлено `:local`) или `Time.utc` (если установлено `:utc`) для считывания даты и времени из базы данных. По умолчанию `:utc`.

#### `config.active_record.schema_format`

Регулирует формат для выгрузки схемы базы данных в файл. Опции следующие: `:ruby` (по умолчанию) для независимой от типа базы данных версии, зависимой от миграций, или `:sql` для набора (потенциально зависимого от типа БД) выражений SQL.

#### (config-active-record-error-on-ignored-order) `config.active_record.error_on_ignored_order`

Определяет, должна ли быть вызвана ошибка, если во время порционного (batch) запроса была проигнорирована сортировка или лимит. Опцией может быть либо `true` (вызывается ошибка), либо `false` (предупреждение). По умолчанию `false`.

#### `config.active_record.timestamped_migrations`

Регулирует, должны ли миграции нумероваться серийными номерами или временными метками. По умолчанию `true` для использования временных меток, которые более предпочтительны, если над одним проектом работают несколько разработчиков.

#### `config.active_record.lock_optimistically`

Регулирует, должен ли Active Record использовать оптимистическую блокировку. По умолчанию `true`.

#### `config.active_record.cache_timestamp_format`

Управляет форматом значения временной метки в ключе кэширования. По умолчанию `:usec`.

#### `config.active_record.record_timestamps`

Это булево значение, управляющее, должна ли происходить временная метка операций модели `create` и `update`. Значение по умолчанию `true`.

#### `config.active_record.partial_inserts`

Это булево значение, управляющее, должны ли использоваться частичные записи при создании новых записей (т.е. вставлять ли только те атрибуты, которые отличаются от дефолтных).

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `true`                |
| 7.0              | `false`               |

#### `config.active_record.partial_updates`

Это булево значение, управляющее, должны ли использоваться частичные записи при обновлении существующих записей (т.е. обновления только тех атрибутов, которые помечены dirty). Отметьте, что при использовании частичной записи также следует использовать оптимистическую блокировку `config.active_record.lock_optimistically`, так как конкурентные обновления могут записывать атрибуты, основываясь на возможном устаревшем статусе чтения. Значение по умолчанию `true`.

#### `config.active_record.maintain_test_schema`

Это булево значение, управляющее, должен ли Active Record пытаться сохранять вашу тестовую базу данных актуальной с `db/schema.rb` (или `db/structure.sql`) при запуске тестов. По умолчанию `true`.

#### `config.active_record.dump_schema_after_migration`

Это флажок, который контролирует, должна ли происходить выгрузка схемы (`db/schema.rb` или `db/structure.sql`) при запуске миграций. Он установлен `false` в `config/environments/production.rb`, генерируемом Rails. Значение по умолчанию `true`, если эта конфигурация не установлена.

#### `config.active_record.dump_schemas`

Управляет, какие схемы баз данных будут выгружаться при вызове `db:schema:dump`. Опции: `:schema_search_path` (по умолчанию), при которой выгружается любая схема, перечисленная в `schema_search_path`, `:all`, при которой выгружаются все схемы, независимо от `schema_search_path`, или строки со схемами, разделенными через запятую.

#### `config.active_record.belongs_to_required_by_default`

Это булево значение и управляет, будет ли валидация записи падать, если отсутствует связь `belongs_to`.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `nil`                 |
| 5.0              | `true`                |

#### `config.active_record.action_on_strict_loading_violation`

Включает вызов или логирование исключения, если на связи установлено strict_loading. Значение по умолчанию `:raise` во всех средах. Можно изменить на `:log`, чтобы посылать нарушения в логгер вместо вызова ошибки.

#### `config.active_record.strict_loading_by_default`

Это булево значение, включающее или отключающее режим strict_loading по умолчанию. По умолчанию `false`.

#### `config.active_record.warn_on_records_fetched_greater_than`

Позволяет установить порог для предупреждения для итогового размера запроса. Если количество возвращаемых записей в запросе будет превышать пороговое значение, запишется предупреждение. Это может быть полезным для выявления запросов, которые могут быть причиной увеличения требуемой памяти.

#### `config.active_record.index_nested_attribute_errors`

Позволяет ошибкам для вложенных отношений `has_many` также быть отраженными с индексом. По умолчанию `false`.

#### `config.active_record.use_schema_cache_dump`

Позволяет пользователям получить информацию о кэше схемы из `db/schema_cache.yml` (сгенерированного с помощью `bin/rails db:schema:cache:dump`), вместо отправления запроса в базу данных для получения этой информации. По умолчанию `true`.

#### `config.active_record.cache_versioning`

Обозначает, нужно ли использовать стабильный метод `#cache_key`, сопровождаемый изменившейся версией в методе `#cache_version`.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 5.2              | `true`                |

#### `config.active_record.collection_cache_versioning`

Позволяет повторное использование того же ключа кэширования, когда объект, кэшированный с типом `ActiveRecord::Relation`, изменяется из-за перемещения волатильной информации (максимальной даты обновления и количества) из ключа кэширования relation в версию кэша для поддержки повторного использования ключа кэширования.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 6.0              | `true`                |

#### `config.active_record.has_many_inversing`

Включает настройку инверсии записи при переходе по связям `belongs_to` и `has_many`.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 6.1              | `true`                |

#### `config.active_record.automatic_scope_inversing`

Включает автоматическое определение `inverse_of` для связей со скоупом.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 7.0              | `true`                |

#### `config.active_record.legacy_connection_handling`

Позволяет включить новый API обработки подключения. Для приложений, использующих несколько баз данных, этот новый API предоставляет поддержку гранулированного переключения соединения.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `true`                |
| 6.1              | `false`               |

#### `config.active_record.destroy_association_async_job`

Позволяет указывать задание, используемое для удаления связанных записей в фоновом режиме. По умолчанию `ActiveRecord::DestroyAssociationAsyncJob`.

#### `config.active_record.queues.destroy`

Позволяет указывать очередь Active Job, используемую для заданий уничтожения. Когда эта опция `nil`, задания уничтожения посылаются в очередь Active Job по умолчанию (смотрите `config.active_job.default_queue_name`). По умолчанию `nil`.

#### `config.active_record.enumerate_columns_in_select_statements`

Когда true, имена столбцов будут всегда включаться в выражения `SELECT`, и будут избегаться запросы с подстановкой `SELECT * FROM ...`. Это помогает избежать ошибок кэширования в prepared statement при добавлении столбцов в базу данных PostgreSQL, к примеру. По умолчанию `false`.

#### `config.active_record.verify_foreign_keys_for_fixtures`

Обеспечивает, что все ограничения внешних ключей валидны, после того, как в тестах загружены фикстуры. Поддерживается только для PostgreSQL и SQLite.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 7.0              | `true`                |

#### `config.active_record.query_log_tags_enabled`

Указывает, включать ли комментарии на уровне адаптера. По умолчанию `false`.

#### `config.active_record.query_log_tags`

Определяет массив, указывающий теги ключа/значения для вставки в комментарий SQL. По умолчанию `[ :application ]`, предопределенный тег, возвращающий имя приложения.

#### `config.active_record.cache_query_log_tags`

Указывает, включать ли кэширование тегов лога запроса. Для приложений с большим количеством запросов кэширование тегов лога запроса может предоставить улучшение производительности, когда контекст не меняется на протяжение жизненного цикла запроса или выполнения задания. По умолчанию `false`.

#### `config.active_record.schema_cache_ignored_tables`

Определяет список таблиц, которые должны игнорироваться при генерации кэша схемы. Она принимает массив строк, представляющих имена таблицы, или регулярных выражений.

#### `config.active_record.verbose_query_logs`

Определяет, должно ли логироваться место расположение методов, осуществляющих запросы к базе данных, под соответствующими запросами. По умолчанию флажок `true` в development и `false` во всех других средах.

#### `config.active_record.async_query_executor`

Определяет, как организуется пул асинхронных запросов.

По умолчанию `nil`, что означает, что `load_async` отключен, и вместо этого запросы выполняются непосредственно в фоновом режиме. Для фактического выполнения запросов асинхронно, она должна быть установлена как либо `:global_thread_pool`, или `:multi_thread_pool`.

`:global_thread_pool` будет использовать единый пул для всех баз данных, с которым соединено приложение. Это предпочтительная конфигурация для приложений с единственной базой данных, или приложений, которые всегда запрашивают только один шард базы данных за раз.

`:multi_thread_pool` будет использовать один пул на каждую базу данных, и размер каждого пула может быть сконфигурирован отдельно в `database.yml` с помощью свойств `max_threads` и `min_thread`. Это полезно для приложений, регулярно запрашивающих несколько баз данных за раз, и которым нужно более подробное определение максимального параллелизма.

#### `config.active_record.global_executor_concurrency`

Используется в связке с `config.active_record.async_query_executor = :global_thread_pool`, определяет, сколько асинхронных запросов может быть запущенно параллельно.

По умолчанию `4`.

Это количество должно рассматриваться с учетом размера пула базы данных, сконфигурированного в `database.yml`. Пул соединений должен быть достаточно большим, чтобы вместить и основные треды (т.е. треды веб сервера или обработчика заданий), и фоновые треды.

#### `ActiveRecord::ConnectionAdapters::Mysql2Adapter.emulate_booleans`

Регулирует, должен ли Active Record рассматривать все столбцы `tinyint(1)` как boolean. По умолчанию `true`.

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.create_unlogged_table`

Регулирует, должны ли таблицы базы данных создаваться "нелогируемыми", что может ускорить быстродействие, но добавляет риск потери данных, если база данных ломается. Очень рекомендуется на включать это в среде production. По умолчанию `false` во всех средах.

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.datetime_type`

Управляет встроенным типом, который должен использовать адаптер Active Record PostgreSQL при вызове `datetime` в миграции или схеме. Она принимает символ, который должен соответствовать одному из настроенных `NATIVE_DATABASE_TYPES`. По умолчанию `:timestamp`, что означает, что `t.datetime` в миграции создаст столбец "timestamp without time zone". Чтобы использовать "timestamp with time zone", измените ее на `:timestamptz` в инициализаторе. Если вы ее меняете, следует запустить `bin/rails db:migrate`, чтобы перестроить schema.rb.

#### `ActiveRecord::SchemaDumper.ignore_tables`

Принимает массив таблиц, которые _не_ должны быть включены в любой генерируемый файл схемы.

#### `ActiveRecord::SchemaDumper.fk_ignore_pattern`

Позволяет настроить другое регулярное выражение, которое будет использоваться для определения того, следует ли выгружать имя внешнего ключа из db/schema.rb или нет. По умолчанию имена внешних ключей, начинающиеся с `fk_rails_`, не экспортируются в выгрузку схемы базы данных. По умолчанию используется `/^fk_rails_[0-9a-f]{10}$/`.

### Конфигурирование Action Controller

`config.action_controller` включает несколько конфигурационных настроек:

#### `config.action_controller.asset_host`

Устанавливает хост для ассетов. Полезна, когда для хостинга ассетов используются CDN, или когда вы хотите обойти встроенную в браузеры политику ограничения домена при использовании различных псевдонимов доменов.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `:mailers`            |
| 6.1              | `nil`                 |

#### `config.action_controller.perform_caching`

Конфигурирует, должно ли приложение выполнять возможность кэширования, предоставленную компонентом Action Controller. Установлено `false` в среде development, `true` в production. Если не указано, значение по умолчанию всегда будет `true`.

#### `config.action_controller.default_static_extension`

Конфигурирует расширение, используемое для кэшированных страниц. По умолчанию `.html`.

#### `config.action_controller.include_all_helpers`

Устанавливает, должны ли быть все хелперы вью доступны везде или только в соответствующем контроллере. Если установлен `false`, методы `UsersHelper` будут доступны только во вью, рендерящихся как часть `UsersController`. Если `true`, методы `UsersHelper` будут доступны везде. Поведением настройки по умолчанию (когда этой опции явно не установлено `true` или `false`) является то, что все хелперы вью доступны в каждом контроллере.

#### `config.action_controller.logger`

Принимает логгер, соответствующий интерфейсу Log4r или дефолтного класса Ruby Logger, который затем используется для логирования информации от Action Controller. Установите его в `nil`, чтобы отключить логирование.

#### `config.action_controller.request_forgery_protection_token`

Устанавливает имя параметра токена для RequestForgery. Вызов `protect_from_forgery` по умолчанию устанавливает его в `:authenticity_token`.

#### `config.action_controller.allow_forgery_protection`

Включает или отключает защиту от CSRF. По умолчанию `false` в среде test и `true` в остальных средах.

#### `config.action_controller.forgery_protection_origin_check`

Настраивает, должен ли сверяться заголовок HTTP `Origin` с доменом сайта в качестве дополнительной защиты от межсайтовой подделки запроса.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 5.0              | `true`                |

#### `config.action_controller.per_form_csrf_tokens`

Настраивает, должны ли токены CSRF быть валидными только для метода/экшна, для которого они сгенерированы.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 5.0              | `true`                |

#### `config.action_controller.default_protect_from_forgery`

Определяет, будет ли добавлена защита от подделки в `ActionController:Base`.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 5.2              | `true`                |

#### `config.action_controller.urlsafe_csrf_tokens`

Настраивает, должны ли быть генерируемые токены CSRF URL-безопасными.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 6.1              | `true`                |

#### `config.action_controller.relative_url_root`

Может использоваться, чтобы сообщить Rails, что [деплой происходит в поддиректорию](#deploy-to-a-subdirectory-relative-url-root). По умолчанию `ENV['RAILS_RELATIVE_URL_ROOT']`.

#### `config.action_controller.permit_all_parameters`

Устанавливает все параметры для массового назначения как разрешенные по умолчанию. Значение по умолчанию `false`.

#### `config.action_controller.action_on_unpermitted_parameters`

Управляет поведением, когда обнаружены параметр, не разрешенные явно. Значение по умолчанию `:log` в средах test и development, в остальных `false`. Значениями могут быть:

* `false` чтобы ничего не предпринимать
* `:log` чтобы вызвать событие `ActiveSupport::Notifications.instrument` на тему `unpermitted_parameters.action_controller`, и логировать на уровне DEBUG
* `:raise` чтобы вызвать исключение `ActionController::UnpermittedParameters`

`config.action_controller.always_permitted_parameters`

Устанавливает список разрешенных параметров, которые разрешены по умолчанию. Значениями по умолчанию являются `['controller', 'action']`.

#### `config.action_controller.enable_fragment_cache_logging`

Определяет, нужно ли логировать чтение и запись в кэш фрагментов в следующем расширенном формате:

```
Read fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/d0bdf2974e1ef6d31685c3b392ad0b74 (0.6ms)
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Write fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/3b4e249ac9d168c617e32e84b99218b5 (1.1ms)
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```

По умолчанию установлено `false`, что выводит результаты следующим образом:

```
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```

#### `config.action_controller.raise_on_open_redirects`

Вызывает `ArgumentError`, когда происходит неразрешенный открытый редирект.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 7.0              | `true`                |

#### `config.action_controller.log_query_tags_around_actions`

Определяет, будет ли автоматически обновлен контекст контроллера для тегов запроса с помощью `around_filter`. Значение по умолчанию `true`.

#### `config.action_controller.wrap_parameters_by_default`

Конфигурирует [`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html) для оборачивания запросов json по умолчанию.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 7.0              | `true`                |

#### `ActionController::Base.wrap_parameters`

Конфигурирует [`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html). Он может быть вызван на верхнем уровне или на отдельных контроллерах.

### Конфигурирование Action Dispatch

#### `config.action_dispatch.session_store`

Устанавливает имя хранилища данных сессии. По умолчанию `:cookie_store`; другие валидные опции включают `:active_record_store`, `:mem_cache_store` или имя вашего собственного класса.

#### `config.action_dispatch.cookies_serializer`

Указывает, какой сериализатор использовать для куки. Подробности смотрите в [куки Action Controller](/action-controller-overview#cookies).

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 7.0              | `true`                |

#### `config.action_dispatch.default_headers`

Это хэш с заголовками HTTP, которые по умолчанию устанавливаются для каждого отклика.

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "1; mode=block",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.0              | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.1              | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |

#### `config.action_dispatch.default_charset`

Указывает кодировку по умолчанию для всех рендеров. По умолчанию `nil`.

#### `config.action_dispatch.tld_length`

Устанавливает длину TLD (домена верхнего уровня) для приложения. По умолчанию `1`.

#### `config.action_dispatch.ignore_accept_header`

Используется для определения, нужно ли игнорировать заголовки accept запроса. По умолчанию `false`.

#### `config.action_dispatch.x_sendfile_header`

Определяет специфичный для сервера заголовок X-Sendfile. Это полезно для ускоренной отдачи файлов с сервера. Например, можно установить 'X-Sendfile' для Apache.

#### `config.action_dispatch.http_auth_salt`

Устанавливает значение соли HTTP Auth. По умолчанию `'http authentication'`.

#### `config.action_dispatch.signed_cookie_salt`

Устанавливает значение соли для подписанных куки. По умолчанию `'signed cookie'`.

#### `config.action_dispatch.encrypted_cookie_salt`

Устанавливает значение соли для зашифрованных куки. По умолчанию `'encrypted cookie'`.

#### `config.action_dispatch.encrypted_signed_cookie_salt`

Устанавливает значение соли для подписанных зашифрованных куки. По умолчанию `'signed encrypted cookie'`.

#### `config.action_dispatch.authenticated_encrypted_cookie_salt`

Устанавливает значение соли для аутентификационных зашифрованных куки. По умолчанию `'authenticated encrypted cookie'`.

#### `config.action_dispatch.encrypted_cookie_cipher`

Устанавливает алгоритм шифрования, который будет использоваться для зашифрованных куки. По умолчанию `"aes-256-gcm"`.

#### `config.action_dispatch.signed_cookie_digest`

Устанавливает дайджест, который будет использоваться для подписанных куки. По умолчанию `"SHA1"`.

#### `config.action_dispatch.cookies_rotations`

Позволяет чередовать секреты, шифры и дайджесты для зашифрованных и подписанных куки.

#### `config.action_dispatch.use_authenticated_cookie_encryption`

Определяет, используют подписанные и зашифрованные куки шифр AES-256-GCM или более старый шифр AES-256-CBC.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 5.2              | `true`                |

#### `config.action_dispatch.use_cookies_with_metadata`

Включает запись куки с включенными метаданными о назначении.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 6.0              | `true`                |

#### `config.action_dispatch.perform_deep_munge`

Конфигурирует, должен ли применяться метод `deep_munge` на параметрах. Подробнее смотрите в руководстве [Безопасность приложений на Rails](/ruby-on-rails-security-guide#unsafe-query-generation). По умолчанию `true`.

#### `config.action_dispatch.rescue_responses`

Конфигурирует, какие исключения назначаются статусу HTTP. Он принимает хэш и можно указать пары исключение/статус. По умолчанию он определен как:

```ruby
config.action_dispatch.rescue_responses = {
  'ActionController::RoutingError'
    => :not_found,
  'AbstractController::ActionNotFound'
    => :not_found,
  'ActionController::MethodNotAllowed'
    => :method_not_allowed,
  'ActionController::UnknownHttpMethod'
    => :method_not_allowed,
  'ActionController::NotImplemented'
    => :not_implemented,
  'ActionController::UnknownFormat'
    => :not_acceptable,
  'ActionController::InvalidAuthenticityToken'
    => :unprocessable_entity,
  'ActionController::InvalidCrossOriginRequest'
    => :unprocessable_entity,
  'ActionDispatch::Http::Parameters::ParseError'
    => :bad_request,
  'ActionController::BadRequest'
    => :bad_request,
  'ActionController::ParameterMissing'
    => :bad_request,
  'Rack::QueryParser::ParameterTypeError'
    => :bad_request,
  'Rack::QueryParser::InvalidParameterError'
    => :bad_request,
  'ActiveRecord::RecordNotFound'
    => :not_found,
  'ActiveRecord::StaleObjectError'
    => :conflict,
  'ActiveRecord::RecordInvalid'
    => :unprocessable_entity,
  'ActiveRecord::RecordNotSaved'
    => :unprocessable_entity
}
```

Любое ненастроенное исключение приведет к 500 Internal Server Error.

#### `config.action_dispatch.return_only_request_media_type_on_content_type`

Изменяет возвращаемое значение `ActionDispatch::Request#content_type` на заголовок Content-Type без модификаций.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `true`                |
| 7.0              | `false`               |

#### `config.action_dispatch.cookies_same_site_protection`

Настраивает значение по умолчанию атрибута `SameSite` при установке куки. Когда установлено `nil`, атрибут `SameSite` не будет добавляться. Чтобы разрешить значению атрибута `SameSite` быть динамически настраиваемым на основе запроса, может быть указан proc. Например:

```ruby
config.action_dispatch.cookies_same_site_protection = ->(request) do
  :strict unless request.user_agent == "TestAgent"
end
```

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `nil`                 |
| 6.1              | `:lax`                |

#### `config.action_dispatch.ssl_default_redirect_status`

Настраивает код статуса HTTP по умолчанию, используемый при перенаправлении не-GET/HEAD запросов от HTTP к HTTPS в промежуточной программе `ActionDispatch::SSL`.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `307`                 |
| 6.1              | `308`                |

#### `config.action_dispatch.log_rescued_responses`

Включает логирование необработанных исключений, настроенных в `rescue_responses`. По умолчанию `true`.

#### `ActionDispatch::Callbacks.before`

Принимает блок кода для запуска до запроса.

#### `ActionDispatch::Callbacks.after`

Принимает блок кода для запуска после запроса.

### Конфигурирование Action View

`config.action_view` включает несколько конфигурационных настроек:

#### `config.action_view.cache_template_loading`

Контролирует, будут ли шаблоны перезагружены при каждом запросе. Значение по умолчанию устанавливается для `config.cache_classes`.

#### `config.action_view.field_error_proc`

Предоставляет генератор HTML для отображения ошибок, приходящих от Active Model. Блок вычисляется в контексте шаблона Action View. По умолчанию:

```ruby
Proc.new { |html_tag, instance| content_tag :div, html_tag, class: "field_with_errors" }
```

#### `config.action_view.default_form_builder`

Сообщает Rails, какой form builder использовать по умолчанию. По умолчанию это `ActionView::Helpers::FormBuilder`. Если хотите, чтобы после инициализации загружался ваш класс form builder (и, таким образом, перезагружался с каждым запросом в development), можно передать его как строку.

#### `config.action_view.logger`

Принимает логгер, соответствующий интерфейсу Log4r или классу Ruby по умолчанию Logger, который затем используется для логирования информации от Action View. Установите `nil` для отключения логирования.

#### `config.action_view.erb_trim_mode`

Задает режим обрезки, который будет использоваться ERB. По умолчанию `'-'`, которая включает обрезку висячих пробелов и новых строчек при использовании `<%= -%>` или `<%= =%>`. Подробнее смотрите в [документации по Erubis](http://www.kuwata-lab.com/erubis/users-guide.06.html#topics-trimspaces).

#### `config.action_view.frozen_string_literal`

Компилирует шаблон ERB с волшебным комментарием `# frozen_string_literal: true`, что делает все литералы строки замороженными, что предохраняет от выделения памяти. Установите `true`, чтобы включить ее для всех вью.

#### `config.action_view.embed_authenticity_token_in_remote_forms`

Позволяет установить поведение по умолчанию для `authenticity_token` в формах с `remote: true`. По умолчанию установлен `false`, что означает, что remote формы не включают `authenticity_token`, что полезно при фрагментарном кэшировании формы. Remote формы получают аутентификацию из тега `meta`, поэтому встраивание бесполезно, если, конечно, вы не поддерживаете браузеры без JavaScript. В противном случае можно либо передать `authenticity_token: true` как опцию для формы, либо установить эту настройку в `true`.

#### `config.action_view.prefix_partial_path_with_controller_namespace`

Определяет должны ли партиалы искаться в поддиректории шаблонов для контроллеров в пространстве имен, или нет. Например, рассмотрим контроллер с именем `Admin::ArticlesController`, который рендерит этот шаблон:

```erb
<%= render @article %>
```

Настройка по умолчанию `true`, что использует партиал в `/admin/articles/_article.erb`. Установка значение в `false` будет рендерить `/articles/_article.erb`, что является тем же поведением, что и рендеринг из контроллера не в пространстве имен, такого как `ArticlesController`.

#### `config.action_view.automatically_disable_submit_tag`

Определяет, должен ли `submit_tag` автоматически отключаться при клике, это по умолчанию `true`.

#### `config.action_view.debug_missing_translation`

Определяет, должны ли ключи отсутствующих переводов оборачиваться в тег `<span>`. Это по умолчанию `true`.

#### `config.action_view.form_with_generates_remote_forms`

Определяет, должны ли `form_with` генерировать remote формы или нет.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| 5.1              | `true`                |
| 6.1              | `false`               |

#### `config.action_view.form_with_generates_ids`

Определяет, должны ли `form_with` генерировать ids на inputs.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`                |
| 5.2              | `true`               |

#### `config.action_view.default_enforce_utf8`

Определяет, генерируются ли формы со скрытым тегом, который заставляет старые версии Internet Explorer отправлять формы, закодированные в UTF-8.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `true`                |
| 6.0              | `false`               |

#### `config.action_view.image_loading`

Указывает значение по умолчанию для атрибута `loading` тегов `<img>`, создаваемых хелпером `image_tag`. Например, когда установлено `"lazy"`, теги `<img>`, создаваемые `image_tag`, будут включать `loading="lazy"`, который [информирует браузер подождать, пока изображение не окажется рядом с областью просмотра, чтобы загрузить его](https://html.spec.whatwg.org/#lazy-loading-attributes). (Это значение все еще может быть переопределено для изображения, передавая, например, `loading: "eager"` в `image_tag`.) По умолчанию `nil`.

#### `config.action_view.image_decoding`

Указывает значение по умолчанию для атрибута `decoding` тегов `<img>`, создаваемых хелпером `image_tag`. По умолчанию `nil`.

#### `config.action_view.annotate_rendered_view_with_filenames`

Определяет, должны ли отрендеренные вью аннотироваться именем файла шаблона. Это по умолчанию `false`.

#### `config.action_view.preload_links_header`

Определяет, должны ли `javascript_include_tag` и `stylesheet_link_tag` генерировать заголовок `Link`, для предварительной загрузки ассетов.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     |  `nil`                |
| 6.1              | `true`                |

#### `config.action_view.button_to_generates_button_tag`

Определяет, должен ли `button_to` отрисовывать элемент `<button>` независимо от того, было ли содержимое передано как первый аргумент или как блок.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 7.0              | `true`                |

#### `config.action_view.apply_stylesheet_media_default`

Определяет, должен ли `stylesheet_link_tag` отрисовывать `screen` как значение по умолчанию для атрибута `media`, когда он не предоставлен.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `true`                |
| 7.0              | `false`               |

### Конфигурирование Action Mailbox

`config.action_mailbox` предоставляет следующие конфигурационные опции:

#### `config.action_mailbox.logger`

Содержит логгер, используемый Action Mailbox. Он принимает логгер, соответствующий интерфейсу Log4r или стандартного класса Ruby Logger. По умолчанию `Rails.logger`.

```ruby
config.action_mailbox.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.action_mailbox.incinerate_after`

Принимает `ActiveSupport::Duration`, указывающий, через какое время после обработки `ActionMailbox::InboundEmail` записи должны быть уничтожены. По умолчанию `30.days`.

```ruby
# Уничтожить входяще письма через 14 дней после обработки.
config.action_mailbox.incinerate_after = 14.days
```

#### `config.action_mailbox.queues.incineration`

Принимает символ, указывающий очередь Active Job для использования для заданий уничтожения. Когда эта опция `nil`, задания уничтожения посылаются в очередь Active Job по умолчанию (смотрите `config.active_job.default_queue_name`).

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `:action_mailbox_incineration` |
| 6.1              | `nil`                 |

#### `config.action_mailbox.queues.routing`

Принимает символ, указывающий очередь Active Job для использования для заданий маршрутизации. Когда эта опция `nil`, задания маршрутизации посылаются в очередь Active Job по умолчанию (смотрите `config.active_job.default_queue_name`).

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `:action_mailbox_routing` |
| 6.1              | `nil`                 |

### (configuring-action-mailer) Конфигурирование Action Mailer

Имеется несколько доступных настроек `ActionMailer::Base`:

#### `config.action_mailer.asset_host`

Устанавливает хост для ассетов. Полезно, когда для размещения ассетов используются CDN, а не сервер самого приложения. Следует использовать ее, если у вас другая конфигурация для Action Controller, в противном случае используйте `config.asset_host`.

#### `config.action_mailer.logger`

Принимает логгер, соответствующий интерфейсу Log4r или класса Ruby по умолчанию Logger, который затем используется для логирования информации от Action Mailer. Установите его в `nil`, чтобы отключить логирование.

#### `config.action_mailer.smtp_settings`

Позволяет детально сконфигурировать метод доставки `:smtp`. Она принимает хэш опций, который может включать любые из следующих опций:

* `:address` - Позволяет использовать удаленный почтовый сервер. Просто измените его значение по умолчанию "localhost".
* `:port` - В случае, если почтовый сервер не работает с портом 25, можно изменить это.
* `:domain` - Если нужно определить домен HELO, это делается здесь.
* `:user_name` - Если почтовый сервер требует аутентификацию, установите имя пользователя этой настройкой.
* `:password` - Если почтовый сервер требует аутентификацию, установите пароль этой настройкой.
* `:authentication` - Если почтовый сервер требует аутентификацию, здесь необходимо установить тип аутентификации. Это должен быть один из символов `:plain`, `:login`, `:cram_md5`.
* `:enable_starttls` - Использовать STARTTLS при соединении с вашим сервером SMTP и выдавать ошибку, если не поддерживается. По умолчанию `false`.
* `:enable_starttls_auto` - Определяет, включен ли STARTTLS на вашем сервере SMTP и начинает его использовать. По умолчанию `true`.
* `:openssl_verify_mode` - При использовании TLS, можно установить, как OpenSSL проверяет сертификат. Это полезно, если необходимо валидировать самоподписанный и/или wildcard сертификат. Это может быть одна из констант проверки OpenSSL, `:none` или `:peer` -- или сама константа `OpenSSL::SSL::VERIFY_NONE` или `OpenSSL::SSL::VERIFY_PEER`, соответственно.
* `:ssl/:tls` - Позволяет соединению SMTP использовать SMTP/TLS (SMTPS: SMTP поверх прямого соединения TLS).
* `:open_timeout` - Количество секунд ожидания перед попыткой открыть соединение.
* `:read_timeout` - Количество секунд ожидания до тайм-аута вызова read(2).

Кроме этого можно передавать любые [поддерживаемые опции настройки `Mail::SMTP`](https://github.com/mikel/mail/blob/master/lib/mail/network/delivery_methods/smtp.rb).

#### `config.action_mailer.smtp_timeout`

Позволяет настроить оба значения `:open_timeout` и `:read_timeout` для метода доставки `:smtp`.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `nil`                 |
| 7.1              | `5`                   |

#### `config.action_mailer.sendmail_settings`

Позволяет детально сконфигурировать метод доставки `sendmail`. Она принимает хэш опций, который может включать любые из этих опций:

* `:location` - Место расположения исполняемого файла sendmail. По умолчанию `/usr/sbin/sendmail`.
* `:arguments` - Аргументы командной строки. По умолчанию `-i`.

#### `config.action_mailer.raise_delivery_errors`

Определяет, должна ли вызываться ошибка, если доставка письма не может быть завершена. По умолчанию `true`.

#### `config.action_mailer.delivery_method`

Определяет метод доставки, по умолчанию `:smtp`. За подробностями обращайтесь к разделу по настройке в руководстве [Основы Action Mailer](/action_mailer_basics#action-mailer-configuration)

#### `config.action_mailer.perform_deliveries`

Определяет, должна ли почта фактически доставляться. По умолчанию `true`; удобно установить ее `false` при тестировании.

#### `config.action_mailer.default_options`

Конфигурирует значения по умолчанию Action Mailer. Используется для установки таких опций, как `from` или`reply_to` для каждого рассыльщика. Эти значения по умолчанию следующие:

```ruby
mime_version:  "1.0",
charset:       "UTF-8",
content_type: "text/plain",
parts_order:  ["text/plain", "text/enriched", "text/html"]
```

Присвойте хэш для установки дополнительных опций:

```ruby
config.action_mailer.default_options = {
  from: "noreply@example.com"
}
```

#### `config.action_mailer.observers`

Регистрирует обсерверы, которые будут уведомлены при доставке почты.

```ruby
config.action_mailer.observers = ["MailObserver"]
```

#### `config.action_mailer.interceptors`

Регистрирует перехватчики, которые будут вызваны до того, как почта будет отослана.

```ruby
config.action_mailer.interceptors = ["MailInterceptor"]
```

#### `config.action_mailer.preview_interceptors`

Регистрирует перехватчики, которые будут вызваны до того, как почта будет предварительно просмотрена.

```ruby
config.action_mailer.preview_interceptors = ["MyPreviewMailInterceptor"]
```

#### `config.action_mailer.preview_path`

Определяет место расположения превью рассыльщика.

```ruby
config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"
```

#### `config.action_mailer.show_previews`

Включает или отключает превью рассыльщика. По умолчанию `true` в development.

```ruby
config.action_mailer.show_previews = false
```

#### `config.action_mailer.deliver_later_queue_name`

Указывает очередь Active Job для заданий доставки. Когда эта опция установлена `nil`, задания доставки направляются в очередь Active Job по умолчанию (смотрите `config.active_job.default_queue_name`). Убедитесь, что ваш адаптер Active Job также настроен на обработку указанной очереди, иначе задания доставки могут быть молчаливо проигнорированы.

#### `config.action_mailer.perform_caching`

Указывает, должно ли выполняться кэширование фрагментов для шаблонов рассыльщиков. Если не указано, значение по умолчанию всегда будет `true`.

#### `config.action_mailer.delivery_job`

Указывает задание для доставки писем.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `ActionMailer::MailDeliveryJob` |
| 6.0              | `"ActionMailer::MailDeliveryJob"` |

### (configuring-active-support) Конфигурирование Active Support

Имеется несколько конфигурационных настроек для Active Support:

#### `config.active_support.bare`

Включает или отключает загрузку `active_support/all` при загрузке Rails. По умолчанию `nil`, что означает, что `active_support/all` загружается.

#### `config.active_support.test_order`

Устанавливает порядок, в котором выполняются тестовые случаи. Возможные значения `:random` и `:sorted`. По умолчанию `:random`.

#### `config.active_support.escape_html_entities_in_json`

Включает или отключает экранирование сущностей HTML в сериализации JSON. По умолчанию `true`.

#### `config.active_support.use_standard_json_time_format`

Включает или отключает сериализацию дат в формат ISO 8601. По умолчанию `true`.

#### `config.active_support.time_precision`

Устанавливает точность значений времени, кодируемого в JSON. По умолчанию `3`.

#### `config.active_support.hash_digest_class`

Позволяет настроить класс дайджеста для генерации дайджестов для не конфиденциальных (non-sensitive) данных, таких как заголовок ETag.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `OpenSSL::Digest::MD5` |
| 5.2              | `OpenSSL::Digest::SHA1` |
| 7.0              | `OpenSSL::Digest::SHA256` |

#### `config.active_support.key_generator_hash_digest_class`

Позволяет настройку класса дайджеста для использования в создании производных секретных данных от настроенных базовых, таких как зашифрованные куки.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `OpenSSL::Digest::SHA1` |
| 7.0              | `OpenSSL::Digest::SHA256` |

#### `config.active_support.use_authenticated_message_encryption`

Указывает, следует ли использовать аутентификационное шифрование AES-256-GCM в качестве шифра по умолчанию для шифрования сообщений вместо AES-256-CBC.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 5.2              | `true`                |

#### `config.active_support.cache_format_version`

Указывает, какую версию сериализации кэша использовать. Возможные значения `6.1` и `7.0`.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `6.1`                 |
| 7.0              | `7.0`                 |

#### `config.active_support.deprecation`

Настраивает поведение предупреждений об устаревании. Возможные значения `:raise`, `:stderr`, `:log`, `:notify` или `:silence`. По умолчанию `:stderr`. Альтернативно можно настроить `ActiveSupport::Deprecation.behavior`.

#### `config.active_support.disallowed_deprecation`

Настраивает поведение неразрешенных предупреждений об устаревании. Значения `:raise`, `:stderr`, `:log`, `:notify` или `:silence`. По умолчанию `:raise`. Альтернативно можно настроить `ActiveSupport::Deprecation.disallowed_behavior`.

#### `config.active_support.disallowed_deprecation_warnings`

Настраивает предупреждения об устаревании, которые рассматриваются неразрешенными в приложении. Это позволяет, например, трактовать определенные устаревания как серьезные ошибки. Альтернативно можно настроить `ActiveSupport::Deprecation.disallowed_warnings`.

#### `config.active_support.report_deprecations`

Позволяет отключить все предупреждения об устаревании (включая неразрешенные устаревания); это отключит `ActiveSupport::Deprecation.warn`. Включено по умолчанию в production.

#### `config.active_support.remove_deprecated_time_with_zone_name`

Определяет, нужно ли убирать устаревшее переопределение метода [`ActiveSupport::TimeWithZone.name`](https://api.rubyonrails.org/classes/ActiveSupport/TimeWithZone.html#method-c-name), чтобы избежать предупреждения об его устаревании.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `nil`                 |
| 7.0              | `true`                |

#### `config.active_support.isolation_level`

Конфигурирует расположение большей части внутреннего состояния Rails. Если используете сервер или обработчик заданий, основанные на файберах (например, `falcon`), следует установить `:fiber`. В противном случае, лучше использовать расположение `:thread`. По умолчанию `:thread`.

#### `config.active_support.use_rfc4122_namespaced_uuids`

Определяет, будут ли сгенерированные UUID пространств имен следовать стандарту RFC 4122 для идентификаторов пространства имен, переданных как строка в вызовы методов `Digest::UUID.uuid_v3` или `Digest::UUID.uuid_v5`.

Если установлено `true`:

* В качестве идентификаторов пространства имен допускаются только UUID. Если предоставленный идентификатор пространства имен недопустим, будет вызвана `ArgumentError`.
* Никакое предупреждение об устаревании не будет сгенерировано, не важно, если используемый идентификатор пространства имен это константа, определенная в `Digest::UUID` или `String`.
* Идентификаторы пространств имен не чувствительны к регистру.
* Все сгенерированные UUID в пространстве имен должны соответствовать стандарту.

Если установлено `false`:

* Любое строковое значение может быть использовано в качестве идентификатора пространства имен (хотя не рекомендуется). В этом случае никакая `ArgumentError` не будет вызвана, чтобы сохранить обратную совместимость.
* Будет сгенерировано предупреждение об устаревании, если предоставленный идентификатор пространства имен не является одной из констант, определенной в `Digest::UUID`.
* Идентификаторы пространств имен чувствительны к регистру.
* Только те сгенерированные UUID в пространстве имен, которые используют одну из констант, определенных в `Digest::UUID`, должны соответствовать стандарту.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 7.0              | `true`                |

#### `config.active_support.executor_around_test_case`

Конфигурирует тестовый набор, чтобы тестовые случаи оборачивались в `Rails.application.executor.wrap`. Это позволяет тестовым случаям вести себя приближенно к фактическому запросу или заданию. Некоторые особенности, которые обычно отключены в тесте, такие как кэш запросов Active Record и асинхронные запросы, будут тогда включены.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 7.0              | `true`                |

#### `config.active_support.disable_to_s_conversion`

Отключает переопределение методов `#to_s` некоторых ключевых классов Ruby. Эта конфигурация для приложений, которые хотят как можно быстрее воспользоваться преимуществом [оптимизации Ruby 3.1](https://github.com/ruby/ruby/commit/b08dacfea39ad8da3f1fd7fdd0e4538cc892ec44). Эта конфигурация должна быть установлена в `config/application.rb` внутри класса приложения, в противном случае она не сработает.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 7.0              | `true`                |

#### `ActiveSupport::Logger.silencer`

Устанавливают `false`, чтобы отключить возможность silence logging в блоке. По умолчанию `true`.

#### `ActiveSupport::Cache::Store.logger`

Определяет логгер, используемый в операциях хранения кэша.

#### `ActiveSupport.to_time_preserves_timezone`

Определяет, должен ли метод `to_time` сохранять сдвиг UTC его получателя. Если `false`, методы `to_time` конвертируют в сдвиг UTC локальной системы.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 5.0              | `true`                |

#### `ActiveSupport.utc_to_local_returns_utc_offset_times`

Настраивает `ActiveSupport::TimeZone.utc_to_local` возвращать время со сдвигом UTC, вместо времени UTC, включающего этот сдвиг.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 6.1              | `true`                |

### Конфигурирование Active Job

`config.active_job` предоставляет следующие конфигурационные опции:

#### `config.active_job.queue_adapter`

Устанавливает адаптер для бэкенда очередей. По умолчанию адаптер `:async`. Актуальный список встроенных адаптеров смотрите в [документации ActiveJob::QueueAdapters API](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html).

```ruby
# Убедитесь, что гем адаптера есть в вашем Gemfile
# и следуйте определенным инструкция по установке
# и деплою.
config.active_job.queue_adapter = :sidekiq
```

#### `config.active_job.default_queue_name`

Может быть использована для того, чтобы изменить название очереди по умолчанию. По умолчанию это `"default"`.

```ruby
config.active_job.default_queue_name = :medium_priority
```

#### `config.active_job.queue_name_prefix`

Позволяет установить опциональный непустой префикс к названию очереди для всех заданий. По умолчанию пустой и не используется.

Со следующей настройкой задания будут добавляться в очередь `production_high_priority`, при запуске в production:

```ruby
config.active_job.queue_name_prefix = Rails.env
```

```ruby
class GuestsCleanupJob < ActiveJob::Base
  queue_as :high_priority
  #....
end
```

#### `config.active_job.queue_name_delimiter`

Имеет значение по умолчанию `'_'`. Если `queue_name_prefix` установлена, тогда `queue_name_delimiter` соединяет префикс и название очереди без префикса.

Со следующей настройкой задания будут добавлять в очередь `video_server.low_priority`:

```ruby
# префикс должен быть установлен для использования разделителя
config.active_job.queue_name_prefix = 'video_server'
config.active_job.queue_name_delimiter = '.'
```

```ruby
class EncoderJob < ActiveJob::Base
  queue_as :low_priority
  #....
end
```

#### `config.active_job.logger`

Принимает логгер, соответствующий интерфейсу Log4r или дефолтного класса Ruby Logger, который затем используется для логирования информации от Action Job. Вы можете получить этот логгер вызвав `logger` в классе Active Job или экземпляре Active Job. Установите его в `nil`, чтобы отключить логирование.

#### `config.active_job.custom_serializers`

Позволяет устанавливать собственные сериализаторы аргументов. По умолчанию используется `[]`.

#### `config.active_job.log_arguments`

Управляет, логировать ли аргументы задания. По умолчанию `true`.

#### `config.active_job.retry_jitter`

Управляет количеством "jitter" (случайного распределения), применяемого к задержке, вычисляемой при повторе упавших заданий.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `0.0`                 |
| 6.1              | `0.15`                |

#### `config.active_job.log_query_tags_around_perform`

Определяет, будет ли автоматически обновлен контекст задания для тегов запроса с помощью `around_perform`. Значение по умолчанию `true`.

### Конфигурация Action Cable

#### `config.action_cable.url`

Принимает строку с URL, на котором размещается ваш сервер Action Cable. Следует использовать эту опцию, если вы запускаете серверы Action Cable отдельно от основного приложения.

#### `config.action_cable.mount_path`

Принимает строку, куда монтировать Action Cable, как часть процесса основного сервера. По умолчанию `/cable`. Ей можно указать nil, чтобы не монтировать Action Cable как часть вашего обычного сервера Rails.

Конфигурационные опции описаны подробнее в [Обзор Action Cable](/action-cable-overview#configuration).

#### `config.action_cable.precompile_assets`

Определяет, должны ли ассеты Action Cable быть добавлены в прекомпиляцию файлопровода. Ничего не делает, если не используется Sprockets. Значение по умолчанию `true`.

### (configuring-active-storage) Конфигурирование Active Storage

`config.active_storage` предоставляет следующие опции конфигурации:

#### `config.active_storage.variant_processor`

Принимает символ `:mini_magick` или `:vips`, указывая, будут ли варианты преобразования выполняться с помощью MiniMagick или ruby-vips.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `:mini_magick`        |
| 7.0              | `:vips`               |

#### `config.active_storage.analyzers`

Принимает массив классов, указывающий анализаторы, доступные для бинарных объектов в Active Storage. По умолчанию определен как:

```ruby
config.active_storage.analyzers = [ActiveStorage::Analyzer::ImageAnalyzer::Vips, ActiveStorage::Analyzer::ImageAnalyzer::ImageMagick, ActiveStorage::Analyzer::VideoAnalyzer, ActiveStorage::Analyzer::AudioAnalyzer]
```

Анализатор изображения может извлекать ширину и высоту бинарного объекта изображения; анализатор видео может извлекать ширину, высоту, длительность, угол и соотношение сторон бинарного объекта видео; анализатор аудио может извлекать продолжительность и битрейт бинарного объекта аудио.

#### `config.active_storage.previewers`

Принимает массив классов, указывающий на средства предварительного просмотра изображений, доступные для бинарных объектов в Active Storage. По умолчанию определен как:

```ruby
config.active_storage.previewers = [ActiveStorage::Previewer::PopplerPDFPreviewer, ActiveStorage::Previewer::MuPDFPreviewer, ActiveStorage::Previewer::VideoPreviewer]
```

`PopplerPDFPreviewer` и `MuPDFPreviewer` могут генерировать миниатюру из первой страницы бинарного объекта PDF; `VideoPreviewer` из соответствующего кадра бинарного объекта видео.

#### `config.active_storage.paths`

Принимает хэш опций, с указанием мест расположения команд средств предварительного просмотра/анализатора. По умолчанию используется `{}`, что означает, что команды будут искать по дефолтному пути. Можно включить любую из следующих опций:

* `:ffprobe` - Место расположения исполняемого ffprobe.
* `:mutool` - Место расположения исполняемого mutool.
* `:ffmpeg` - Место расположения исполняемого ffmpeg.

```ruby
config.active_storage.paths[:ffprobe] = '/usr/local/bin/ffprobe'
```

#### `config.active_storage.variable_content_types`

Принимает массив строк, указывающий типы содержимого, которые Active Storage может преобразовывать через ImageMagick. По умолчанию определен как:

```ruby
config.active_storage.variable_content_types = %w(image/png image/gif image/jpeg image/tiff image/vnd.adobe.photoshop image/vnd.microsoft.icon image/webp image/avif image/heic image/heif)
```

#### `config.active_storage.web_image_content_types`

Принимает массив строк, рассматриваемый в качестве типов содержимого веб изображений, для которых варианты могут бать обработаны без конвертации в формат PNG. Если хотите использовать варианты `WebP` в своем приложении, можете добавить `image/webp` в этот массив. По умолчанию определен как:

```ruby
config.active_storage.web_image_content_types = %w(image/png image/jpeg image/gif)
```

#### `config.active_storage.content_types_to_serve_as_binary`

Принимает массив строк, указывающий типы содержимого, которые Active Storage всегда будет отдавать в качестве прикрепленного файла, а не встроенного. По умолчанию определен как:

```ruby
config.active_storage.content_types_to_serve_as_binary = %w(text/html image/svg+xml application/postscript application/x-shockwave-flash text/xml application/xml application/xhtml+xml application/mathml+xml text/cache-manifest)
```

#### `config.active_storage.content_types_allowed_inline`

Принимает массив строк, указывающий типы содержимого, которые Active Storage всегда будет отдавать в качестве встроенного файла. По умолчанию определен как:

```ruby
config.active_storage.content_types_allowed_inline = %w(image/png image/gif image/jpeg image/tiff image/vnd.adobe.photoshop image/vnd.microsoft.icon application/pdf)
```

#### `config.active_storage.silence_invalid_content_types_warning`

Начиная с Rails 7, Active Storage предупредит, если вы используете неправильный тип содержимого, который некорректно поддерживался в Rails 6. Можно использовать эту настройку, чтобы отключить предупреждение.

```ruby
config.active_storage.silence_invalid_content_types_warning = false
```

#### `config.active_storage.queues.analysis`

Принимает символ, указывающий очередь Active Job для использования заданиями анализа. Когда эта опция `nil`, задания анализа направляются в очередь Active Job по умолчанию (смотрите `config.active_job.default_queue_name`).

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| 6.0              | `:active_storage_analysis` |
| 6.1              | `nil`                 |

#### `config.active_storage.queues.purge`

Принимает символ, указывающий очередь Active Job для использования заданиями очистки. Когда эта опция `nil`, задания очистки направляются в очередь Active Job по умолчанию (смотрите `config.active_job.default_queue_name`).

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| 6.0              | `:active_storage_purge` |
| 6.1              | `nil`                 |

#### `config.active_storage.queues.mirror`

Принимает символ, указывающий очередь Active Job для использования заданиями отзеркаливания. По умолчанию `:active_storage_mirror`.

#### `config.active_storage.logger`


Может быть использован для установки логгера, используемого Active Storage. Принимает логгер, соответствующий интерфейсу Log4r или дефолтному классу Logger в Ruby.

```ruby
config.active_storage.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.active_storage.service_urls_expire_in`

Определяет срок действия по умолчанию для URL, генерируемых с помощью:

* `ActiveStorage::Blob#url`
* `ActiveStorage::Blob#service_url_for_direct_upload`
* `ActiveStorage::Variant#url`

По умолчанию 5 минут.

#### `config.active_storage.urls_expire_in`

Определяет срок действия по умолчанию для URL в приложении Rails, генерируемых с помощью Active Storage. По умолчанию nil.

#### `config.active_storage.routes_prefix`

Может быть использована для установки префикса маршрута для маршрутов, обслуживаемых Active Storage. Принимает строку, с которой будут начинаться генерируемые маршруты.

```ruby
config.active_storage.routes_prefix = '/files'
```

По умолчанию `/rails/active_storage`.

#### `config.active_storage.replace_on_assign_to_many`

Определяет, должно ли присвоение к коллекции с вложениями, объявленной с помощью `has_many_attached`, заменять любые существующие вложения, или добавлять к ним.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 6.0              | `true`                |

#### `config.active_storage.track_variants`

Определяет, должны ли варианты записываться в базу данных.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 6.1              | `true`                |

#### `config.active_storage.draw_routes`

Может быть использована, чтобы включить генерацию маршрутов Active Storage. По умолчанию `true`.

#### `config.active_storage.resolve_model_to_route`

Может быть использована для глобального изменения, как загружаются файлы Active Storage.

Допустимые значения:

* `:rails_storage_redirect`: Перенаправляет на подписанный короткоживущий URL сервиса.
* `:rails_storage_proxy`: Проксирует файлы, загружая их.

По умолчанию `:rails_storage_redirect`.

#### `config.active_storage.video_preview_arguments`

Может быть использована для изменения способа, которым ffmpeg генерирует изображения предпросмотра видео.

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `"-y -vframes 1 -f image2"` |
| 7.0              | `"-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015)"`<sup><mark><strong><em>1</em></strong></mark></sup> <br> `+ ",loop=loop=-1:size=2,trim=start_frame=1'"`<sup><mark><strong><em>2</em></strong></mark></sup><br> `+ " -frames:v 1 -f image2"` <br><br> <ol><li>Выбирает первый кадр видео, плюс ключевые кадры, плюс кадры, соответствующие порогу смены сцены.</li> <li>Использует первый кадр, как фолбэк, если другие кадры не отвечают критериям, закольцовывает первые (один или) два выбранных кадра, затем отбрасывает первый закольцованный кадр.</li></ol> |

#### `config.active_storage.multiple_file_field_include_hidden`

В Rails 7.1 и выше, отношения Active Storage `has_many_attached` по умолчанию будут _заменять_ текущую коллекцию, вместо _добавления_ к ней. Поэтому, для поддержки отправки _пустой_ коллекции, когда `multiple_file_field_include_hidden` `true`, хелпер [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field) отрендерит вспомогательное скрытое поле, похожее на вспомогательное поле, отрендеренное хелпером [`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box).

Значение по умолчанию зависит от целевой версии `config.load_defaults`:

| Начиная с версии | Значение по умолчанию |
| ---------------- | --------------------- |
| (изначально)     | `false`               |
| 7.0              | `true`                |

#### `config.active_storage.precompile_assets`

Определяет, должны ли ассеты Active Storage быть добавлены в прекомпиляцию файлопровода. Ничего не делает, если не используется Sprockets. Значение по умолчанию `true`.

### Конфигурация Action Text

#### `config.action_text.attachment_tag_name`

Принимает строку для тега HTML, используемого для оборачивания вложений. По умолчанию `"action-text-attachment"`.

### Конфигурирование базы данных

Почти каждое приложение на Rails взаимодействует с базой данных. Можно подключаться к базе данных с помощью установки переменной окружения `ENV['DATABASE_URL']` или с помощью использования файла `config/database.yml`.

При использовании файла `config/database.yml` можно указать всю информацию, необходимую для доступа к базе данных:

```yaml
development:
  adapter: postgresql
  database: blog_development
  pool: 5
```

Это будет подключаться к базе данных по имени `blog_development` при помощи адаптера `postgresql`. Та же самая информация может быть сохранена в URL и предоставлена с помощью переменной среды следующим образом:

```ruby
ENV['DATABASE_URL'] # => "postgresql://localhost/blog_development?pool=5"
```

Файл `config/database.yml`содержит разделы для трех различных сред, в которых по умолчанию может быть запущен Rails:

* Среда `development` используется на вашем компьютере для разработки или локальном компьютере для того, чтобы вы могли взаимодействовать с приложением.
* Среда `test` используется при запуске автоматических тестов.
* Среда `production` используется, когда вы развертываете свое приложение во всемирной сети для использования.

Если хотите, можно указать URL внутри `config/database.yml`

```yaml
development:
  url: postgresql://localhost/blog_development?pool=5
```

Файл `config/database.yml` может содержать теги ERB `<%= %>`. Все внутри тегов будет вычислено как код Ruby. Это можно использовать для вставки данных из переменных среды или для выполнения вычислений для генерации необходимой информации о соединении.

TIP: Вам не нужно обновлять конфигурации баз данных вручную. Если взглянете на опции генератора приложения, то увидите, что одна из опций называется `--database`. Эта опция позволяет выбрать адаптер из списка наиболее часто используемых реляционных баз данных. Можно даже запускать генератор неоднократно: `cd .. && rails new blog --database=mysql`. После того, как подтвердите перезапись `config/database.yml`, ваше приложение станет использовать MySQL вместо SQLite. Подробные примеры распространенных соединений с базой данных указаны ниже.

### Предпочтение соединения

Так как существует два способа настройки соединения (с помощью `config/database.yml` или с помощью переменной среды), важно понять, как они могут взаимодействовать.

Если имеется пустой файл `config/database.yml`, но существует `ENV['DATABASE_URL']`, Rails соединится с базой данных с помощью переменной среды:

```bash
$ cat config/database.yml

$ echo $DATABASE_URL
postgresql://localhost/my_database
```

Если имеется `config/database.yml`, но нет `ENV['DATABASE_URL']`, тогда для соединения с базой данных будет использован этот файл:

```bash
$ cat config/database.yml
development:
  adapter: postgresql
  database: my_database
  host: localhost

$ echo $DATABASE_URL
```

Если имеется и `config/database.yml`, и `ENV['DATABASE_URL']`, Rails будет объединять конфигурации вместе. Чтобы лучше понять, обратимся к примерам.

При дублирующей информации о соединении, приоритет имеет переменная среды:

```bash
$ cat config/database.yml
development:
  adapter: sqlite3
  database: NOT_my_database
  host: localhost

$ echo $DATABASE_URL
postgresql://localhost/my_database

$ bin/rails runner 'puts ActiveRecord::Base.configurations'
#<ActiveRecord::DatabaseConfigurations:0x00007fd50e209a28>

$ bin/rails runner 'puts ActiveRecord::Base.configurations.inspect'
#<ActiveRecord::DatabaseConfigurations:0x00007fc8eab02880 @configurations=[
  #<ActiveRecord::DatabaseConfigurations::UrlConfig:0x00007fc8eab020b0
    @env_name="development", @spec_name="primary",
    @config={"adapter"=>"postgresql", "database"=>"my_database", "host"=>"localhost"}
    @url="postgresql://localhost/my_database">
  ]
```

Здесь адаптер, хост и база данных соответствуют информации в `ENV['DATABASE_URL']`.

Если предоставлена недублирующая информация, вы получите все уникальные значения, в случае любых конфликтов переменная среды также имеет приоритет.

```bash
$ cat config/database.yml
development:
  adapter: sqlite3
  pool: 5

$ echo $DATABASE_URL
postgresql://localhost/my_database

$ bin/rails runner 'puts ActiveRecord::Base.configurations'
#<ActiveRecord::DatabaseConfigurations:0x00007fd50e209a28>

$ bin/rails runner 'puts ActiveRecord::Base.configurations.inspect'
#<ActiveRecord::DatabaseConfigurations:0x00007fc8eab02880 @configurations=[
  #<ActiveRecord::DatabaseConfigurations::UrlConfig:0x00007fc8eab020b0
    @env_name="development", @spec_name="primary",
    @config={"adapter"=>"postgresql", "database"=>"my_database", "host"=>"localhost", "pool"=>5}
    @url="postgresql://localhost/my_database">
  ]
```

Поскольку pool не содержится в предоставленной информации о соединении в `ENV['DATABASE_URL']`, его информация объединяется. Так как `adapter` дублирован, информация о соединении взята из `ENV['DATABASE_URL']`.

Единственных способ явно не использовать информацию о соединении из `ENV['DATABASE_URL']`, это определить явный URL соединения с использованием ключа `"url"`:

```bash
$ cat config/database.yml
development:
  url: sqlite3:NOT_my_database

$ echo $DATABASE_URL
postgresql://localhost/my_database

$ bin/rails runner 'puts ActiveRecord::Base.configurations'
#<ActiveRecord::DatabaseConfigurations:0x00007fd50e209a28>

$ bin/rails runner 'puts ActiveRecord::Base.configurations.inspect'
#<ActiveRecord::DatabaseConfigurations:0x00007fc8eab02880 @configurations=[
  #<ActiveRecord::DatabaseConfigurations::UrlConfig:0x00007fc8eab020b0
    @env_name="development", @spec_name="primary",
    @config={"adapter"=>"sqlite3", "database"=>"NOT_my_database"}
    @url="sqlite3:NOT_my_database">
  ]
```

Тут игнорируется информация о соединении из `ENV['DATABASE_URL']`.

Так как возможно встроить ERB в `config/database.yml`, хорошей практикой является явно показать, что вы используете `ENV['DATABASE_URL']` для соединения с вашей базой данных. Это особенно полезно в production, так как вы не должны показывать секреты, такие как пароль от базы данных, в системе управления версиями (такой как Git).

```bash
$ cat config/database.yml
production:
  url: <%= ENV['DATABASE_URL'] %>
```

Теперь поведение понятное, что мы используем только информацию о соединении из `ENV['DATABASE_URL']`.

#### Конфигурирование базы данных SQLite3

В Rails есть встроенная поддержка [SQLite3](http://www.sqlite.org), являющейся легким несерверным приложением по управлению базами данных. Хотя нагруженная среда production может перегрузить SQLite, она хорошо работает для разработки и тестирования. Rails при создании нового проекта использует базу данных SQLite, но вы всегда можете изменить это позже.

Вот раздел дефолтного конфигурационного файла (`config/database.yml`) с информацией о соединении для среды development:

```yaml
development:
  adapter: sqlite3
  database: db/development.sqlite3
  pool: 5
  timeout: 5000
```

NOTE: В этом руководстве мы используем базу данных SQLite3 для хранения данных, поскольку эта база данных работает с нулевыми настройками. Rails также поддерживает MySQL (включая MariaDB) и PostgreSQL "из коробки", и имеет плагины для многих СУБД. Если вы уже используете базу данных в работе, в Rails скорее всего есть адаптер для нее.

#### Конфигурирование базы данных MySQL или MariaDB

Если вы выбрали MySQL или MariaDB вместо SQLite3, ваш `config/database.yml` будет выглядеть немного по-другому. Вот раздел development:

```yaml
development:
  adapter: mysql2
  encoding: utf8mb4
  database: blog_development
  pool: 5
  username: root
  password:
  socket: /tmp/mysql.sock
```

Если в вашей базе для разработки есть пользователь root с пустым паролем, эта конфигурация у вас заработает. В противном случае измените username и password в разделе `development` на правильные.

NOTE: Если версия MySQL 5.5 или 5.6, и вы хотите использовать кодировку `utf8mb4` по умолчанию, настройте ваш сервер MySQL, чтобы он поддерживал более длинные префиксы ключей, включив системную переменную `innodb_large_prefix`.

Advisory Locks в MySQL по умолчанию включены и используются, чтобы сделать миграции базы данных безопасными. Их можно отключить, установив `advisory_locks` в `false`:

```yaml
production:
  adapter: mysql2
  advisory_locks: false
```

#### Конфигурирование базы данных PostgreSQL

Если вы выбрали PostgreSQL, ваш `config/database.yml` будет модифицирован для использования базы данных PostgreSQL:

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: blog_development
  pool: 5
```

По умолчанию Active Record использует особенности базы данных, такие как prepared statements и advisory locks. Вам может потребоваться отключить эти особенности, если вы используете внешний пул соединения, такой как PgBouncer:

```yaml
production:
  adapter: postgresql
  prepared_statements: false
  advisory_locks: false
```

Если включены, Active Record по умолчанию создаст до `1000` prepared statements на соединение с базой данных. Чтобы модифицировать это поведение, можно установить `statement_limit` в другое значение:

```yaml
production:
  adapter: postgresql
  statement_limit: 200
```

Чем больше используется prepared statements, тем больше нужно памяти вашей базе данных. Если ваша база данных PostgreSQL достигает лимитов памяти, попробуйте снизить `statement_limit` или отключить prepared statements.

#### Конфигурирование базы данных SQLite3 для платформы JRuby

Если вы выбрали SQLite3 и используете JRuby, ваш `config/database.yml` будет выглядеть немного по-другому. Вот раздел development:

```yaml
development:
  adapter: jdbcsqlite3
  database: db/development.sqlite3
```

#### Конфигурирование базы данных MySQL или MariaDB для платформы JRuby

Если вы выбрали MySQL или MariaDB и используете JRuby, ваш `config/database.yml` будет выглядеть немного по-другому. Вот раздел development:

```yaml
development:
  adapter: jdbcmysql
  database: blog_development
  username: root
  password:
```

#### Конфигурирование базы данных PostgreSQL для платформы JRuby

Если вы выбрали PostgreSQL и используете JRuby, ваш `config/database.yml` будет выглядеть немного по-другому. Вот раздел development:

```yaml
development:
  adapter: jdbcpostgresql
  encoding: unicode
  database: blog_development
  username: blog
  password:
```

Измените username и password в разделе `development` на правильные.

#### Настройка хранилища метаданных

По умолчанию Rails будет хранить информацию о среде и схеме Rails в служебной таблице по имени `ar_internal_metadata`.

Чтобы отключить это для соединения, установите `use_metadata_table` в конфигурации базы данных. Это полезно при работе с совместной базой данных и/или пользователем базы данных, который не может создавать таблицы.

```yaml
development:
  adapter: postgresql
  use_metadata_table: false
```


### (creating-rails-environments) Создание сред Rails

По умолчанию Rails поставляется с тремя средами: "development", "test" и "production". Хотя в большинстве случаев их достаточно, бывают условия, когда нужно больше сред.

Представим, что у вас есть сервер, отражающий среду production, но используемый только для тестирования. Такой сервер обычно называется "staging server". Для определения среды с именем "staging" для этого сервера, просто создайте файл с именем `config/environments/staging.rb`. В качестве исходного содержимого используйте любой файл, существующий в `config/environments`, а затем сделайте в нем необходимые изменения.

Эта среда ничем не отличается от одной из стандартных, сервер запускается с помощью `bin/rails server -e staging`, консоль с помощью `bin/rails console -e staging`, работает `Rails.env.staging?`, и т.д.


### (Deploy to a subdirectory relative url root) Деплой в поддиректорию (относительно корневого URL)

По умолчанию Rails ожидает, что ваше приложение запускается в корне (т.е. `/`). Этот раздел объяснит, как запустить ваше приложение внутри директории.

Допустим, мы хотим задеплоить наше приложение в "/app1". Rails необходимо знать эту директорию для генерации подходящих маршрутов:

```ruby
config.relative_url_root = "/app1"
```

альтернативно можно установить переменную среды `RAILS_RELATIVE_URL_ROOT`.

Теперь Rails будет добавлять "/app1" в начало каждой сгенерированной ссылки.

#### Использование Passenger

В Passenger запустить приложение в поддиректории просто. Подходящую конфигурацию можно найти в [руководстве по Passenger](https://www.phusionpassenger.com/library/deploy/apache/deploy/ruby/#deploying-an-app-to-a-sub-uri-or-subdirectory).

#### Использование обратного прокси

Размещение вашего приложения с использованием обратного прокси имеет определенные преимущества перед традиционным размещением. Они позволяют больше контролировать ваш сервер, располагая по слоям компоненты, требуемые вашему приложению.

Многие веб-серверы могут быть использованы в качестве прокси сервера для балансировки сторонних элементов, таких как кэширующие сервера или сервера приложений.

Одним из таких серверов приложений является [Unicorn](https://unicorn.bogomips.org/), запущенный за обратным прокси.

В этом случае необходимо настроить прокси сервер (NGINX, Apache и т.д.) принимать соединения из вашего сервера приложения (Unicorn). По умолчанию Unicorn будет слушать соединения TCP на 8080 порту, но можно изменить порт, или настроить использование сокетов.

Можно найти подробности в [Unicorn readme](https://unicorn.bogomips.org/README.html) и понять лежащую в основе [философию](https://unicorn.bogomips.org/PHILOSOPHY.html).

Как только вы настроили сервер приложения, необходимо проксировать запросы к нему, настроив надлежащим образом веб-сервер. Например, ваш конфиг NGINX может включать:

```nginx
upstream application_server {
  server 0.0.0.0:8080;
}

server {
  listen 80;
  server_name localhost;

  root /root/path/to/your_app/public;

  try_files $uri/index.html $uri.html @app;

  location @app {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://application_server;
  }

  # прочая конфигурация
}
```

Прочитайте актуальную информацию в [документации NGINX](https://nginx.org/en/docs/).

Настройка среды Rails
---------------------

Некоторые части Rails также могут быть сконфигурированы извне, предоставив переменные среды. Следующие переменные среды распознаются различными частями Rails:

* `ENV["RAILS_ENV"]` определяет среду Rails (production, development, test и так далее), под которой будет запущен Rails.

* `ENV["RAILS_RELATIVE_URL_ROOT"]` используется кодом роутинга для распознания URL при [деплое вашего приложение в поддиректории](#deploy-to-a-subdirectory-relative-url-root).

* `ENV["RAILS_CACHE_ID"]` и `ENV["RAILS_APP_VERSION"]` используются для генерация расширенных ключей кэша в коде кэширования Rails. Это позволит иметь несколько отдельных кэшей в одном и том же приложении.

(initialization) Использование файлов инициализаторов
-----------------------------------------------------

После загрузки фреймворка и любых гемов в вашем приложении, Rails приступает к загрузке инициализаторов. Инициализатор это любой файл с кодом ruby, хранящийся в `/config/initializers` вашего приложения. Инициализаторы могут использоваться для хранения конфигурационных настроек, которые должны быть выполнены после загрузки фреймворков и гемов, таких как опции для конфигурирования настроек для этих частей.

Файлы в `config/initializers` (и любых поддиректориях `config/initializers`) упорядочиваются и загружаются один за другим как часть инициализатора `load_config_initializers`.

Если в инициализаторе есть код, полагающийся на код другого инициализатора, можно объединить их в один инициализатор. Это сделает эти зависимости более явными, и может помочь выявить новые концепции для вашего приложения. Rails также поддерживает нумерацию имен файлов инициализаторов, но это может привести к запутанности имен файлов. Явная загрузка инициализаторов с помощью `require` не рекомендуется, так как это вызовет повторную загрузку этого инициализатора.

NOTE: Не гарантируется, что ваши инициализаторы будут запущены после всех инициализаторов гемов, поэтому любой код инициализатора, зависящий от инициализации какого-либо гема, должен быть помещен в блок `config.after_initialize`.

События инициализации
---------------------

В Rails имеется 5 событий инициализации, которые могут быть встроены в разные моменты (отображено в порядке запуска):

* `before_configuration`: Это запустится как только константа приложения унаследуется от `Rails::Application`. Вызовы `config` будут вычислены до того, как это произойдет.

* `before_initialize`: Это запустится непосредственно перед процессом инициализации с помощью инициализатора `:bootstrap_hook`, расположенного рядом с началом процесса инициализации Rails.

* `to_prepare`: Запустится после того, как инициализаторы будут запущены для всех Railties (включая само приложение), но до нетерпеливой загрузки и построения стека промежуточных программ. Что еще более важно, запустится после каждой перезагрузке кода в `development`, но только раз (при загрузке) в `production` и `test`.

* `before_eager_load`: Это запустится непосредственно после нетерпеливой загрузки, что является поведением по умолчанию для среды `production`, но не `development`.

* `after_initialize`: Запустится сразу после инициализации приложения, после запуска инициализаторов приложения из `config/initializers`.

Чтобы определить событие для них, используйте блочный синтаксис в подклассе `Rails::Application`, `Rails::Railtie` или `Rails::Engine`:

```ruby
module YourApp
  class Application < Rails::Application
    config.before_initialize do
      # тут идет инициализационный код
    end
  end
end
```

Это можно сделать также с помощью метода `config` на объекте `Rails.application`:

```ruby
Rails.application.config.before_initialize do
  # тут идет инициализационный код
end
```

WARNING: Некоторые части вашего приложения, в частности роутинг, пока еще не настроены в месте, где вызывается блок `after_initialize`.

### `Rails::Railtie#initializer`

В Rails имеется несколько инициализаторов, выполняющихся при запуске, все они определены с использованием метода `initializer` из `Rails::Railtie`. Вот пример инициализатора `initialize_whiny_nils` из Action Controller:

```ruby
initializer "action_controller.set_helpers_path" do |app|
  ActionController::Helpers.helpers_path = app.helpers_paths
end
```

Метод `initializer` принимает три аргумента: имя инициализатора, хэш опций (здесь не показан) и блок. В хэше опций может быть определен ключ `:before` для указания, перед каким инициализатором должен быть запущен новый инициализатор, и ключ `:after` определяет, после какого инициализатора запустить этот.

Инициализаторы, определенные методом `initializer`, будут запущены в порядке, в котором они определены, за исключением тех, в которых использованы методы `:before` или `:after`.

WARNING: Можно помещать свои инициализаторы до или после других инициализаторов в цепочки, пока это логично. Скажем, имеется 4 инициализатора, названные от "one" до "four" (определены в этом порядке), и вы определяете "four" идти _before_ "two", но _after_ "three", это не логично, и Rails не сможет установить ваш порядок инициализаторов.

Блочный аргумент метода `initializer` это экземпляр самого приложение, таким образом, можно получить доступ к его конфигурации, используя метод `config`, как это сделано в примере.

Поскольку `Rails::Application` унаследован от `Rails::Railtie` (опосредованно), можно использовать метод `initializer` в `config/application.rb` для определения инициализаторов для приложения.

### (initializers) Инициализаторы

Ниже приведен полный список всех инициализаторов, присутствующих в Rails в порядке, в котором они определены (и, следовательно, запущены, если не указано иное).

* `load_environment_hook`: Служит в качестве местозаполнителя, так что `:load_environment_config` может быть определено для запуска до него.

* `load_active_support`: Требует `active_support/dependencies`, настраивающий основу для Active Support. Опционально требует `active_support/all`, если `config.active_support.bare` не истинно, что является значением по умолчанию.

* `initialize_logger`: Инициализирует логгер (объект `ActiveSupport::Logger`) для приложения и делает его доступным как `Rails.logger`, если до него другой инициализатор не определит `Rails.logger`.

* `initialize_cache`: Если `Rails.cache` еще не установлен, инициализирует кэш, обращаясь к значению `config.cache_store` и сохраняя результат как `Rails.cache`. Если этот объект отвечает на метод `middleware`, его промежуточная программа вставляется до `Rack::Runtime` в стеке промежуточных программ.

* `set_clear_dependencies_hook`: Этот инициализатор - запускающийся, только если `cache_classes` установлена `false` - использует `ActionDispatch::Callbacks.after` для удаления констант, на которые ссылались на протяжении запроса от пространства объекта, так что они могут быть перезагружены в течение следующего запроса.

* `bootstrap_hook`: Запускает все сконфигурированные блоки `before_initialize`.

* `i18n.callbacks`: В среде development, настраивает колбэк `to_prepare`, вызывающий `I18n.reload!`, если любая из локалей изменилась с последнего запроса. В production этот колбэк запускается один раз при первом запросе.

* `active_support.deprecation_behavior`: Настраивает отчеты об устаревании для сред, по умолчанию `:log` для development, `:silence` для production и `:stderr` для test. Можно установить массив значений. Этот инициализатор также настраивает поведение неразрешенных устареваний, по умолчанию `:raise` для development и test, и `:silence` для production. Предупреждения о неразрешенных устареваниях по умолчанию это пустой массив.

* `active_support.initialize_time_zone`: Устанавливает для приложения временную зону по умолчанию, основываясь на настройке `config.time_zone`, которая по умолчанию равна "UTC".

* `active_support.initialize_beginning_of_week`: Устанавливает начало недели по умолчанию для приложения, основываясь на настройке `config.beginning_of_week`, которая по умолчанию `:monday`.

* `active_support.set_configs`: Настраивает Active Support с помощью настроек в `config.active_support` посылая имена методов в качестве сеттеров в `ActiveSupport` и передавая им значения.

* `action_dispatch.configure`: Конфигурирует `ActionDispatch::Http::URL.tld_length` быть равным значению `config.action_dispatch.tld_length`.

* `action_view.set_configs`: Устанавливает, чтобы Action View использовал настройки в `config.action_view`, посылая имена методов через `send` как сеттер в `ActionView::Base` и передавая в него значения.

* `action_controller.assets_config`: Инициализирует `config.action_controller.assets_dir` директорией public приложения, если не сконфигурирована явно.

* `action_controller.set_helpers_path`: Устанавливает helpers_path у Action Controller равным helpers_path приложения.

* `action_controller.parameters_config`: Конфигурирует опции strong parameters для `ActionController::Parameters`.

* `action_controller.set_configs`: Устанавливает, чтобы Action Controller использовал настройки в `config.action_controller`, посылая имена методов через `send` как сеттер в `ActionController::Base` и передавая в него значения.

* `action_controller.compile_config_methods`: Инициализирует методы для указанных конфигурационных настроек, чтобы доступ к ним был быстрее.

* `active_record.initialize_timezone`: Устанавливает `ActiveRecord::Base.time_zone_aware_attributes` `true`, а также `ActiveRecord::Base.default_timezone` UTC. Когда атрибуты считываются из базы данных, они будут конвертированы во временную зону с использованием `Time.zone`.

* `active_record.logger`: Устанавливает `ActiveRecord::Base.logger` - если еще не установлен - как `Rails.logger`.

* `active_record.migration_error`: Конфигурирует промежуточную программу для проверки невыполненных миграций.

* `active_record.check_schema_cache_dump`: Загружает кэш выгрузки схемы, если настроен и доступен.

* `active_record.warn_on_records_fetched_greater_than`: Включает предупреждения, когда запросы возвращают большое количество записей.

* `active_record.set_configs`: Устанавливает, чтобы Active Record использовал настройки в `config.active_record`, посылая имена методов через `send` как сеттер в `ActiveRecord::Base` и передавая в него значения.

* `active_record.initialize_database`: Загружает конфигурацию базы данных (по умолчанию) из `config/database.yml` и устанавливает соединение для текущей среды.

* `active_record.log_runtime`: Включает `ActiveRecord::Railties::ControllerRuntime`, ответственный за отчет в логгер по времени, затраченному вызовом Active Record для запроса.

* `active_record.set_reloader_hooks`: Сбрасывает все перезагружаемые соединения к базе данных, если `config.cache_classes` установлена `false`.

* `active_record.add_watchable_files`: Добавляет файлы `schema.rb` и `structure.sql` в отслеживаемые.

* `active_job.logger`: Устанавливает `ActiveRecord::Base.logger` - если еще не установлен - как `Rails.logger`.

* `active_job.set_configs`: Устанавливает, чтобы Active Job использовал настройки `config.active_job`, посылая имена методов через `send` как сеттер в `ActiveRecord::Base` и передавая в него значения.

* `action_mailer.logger`: Устанавливает `ActionMailer::Base.logger` - если еще не установлен - как `Rails.logger`.

* `action_mailer.set_configs`: Устанавливает, чтобы Action Mailer использовал настройки в `config.action_mailer`, посылая имена методов через `send` как сеттер в `ActionMailer::Base` и передавая в него значения.

* `action_mailer.compile_config_methods`: Инициализирует методы для указанных конфигурационных настроек, чтобы доступ к ним был быстрее.

* `set_load_path`: Этот инициализатор запускается перед `bootstrap_hook`. Добавляет пути, определенные `config.load_paths`, и пути автозагрузки к `$LOAD_PATH`.

* `set_autoload_paths`: Этот инициализатор запускается перед `bootstrap_hook`. Добавляет все поддиректории `app` и пути, определенные `config.autoload_paths`, `config.eager_load_paths` и `config.autoload_once_paths` в `ActiveSupport::Dependencies.autoload_paths`.

* `add_routing_paths`: Загружает (по умолчанию) все файлы `config/routes.rb` (в приложении и railties, включая engine-ы) и настраивает маршруты для приложения.

* `add_locales`: Добавляет файлы в `config/locales` (из приложения, railties и engine-ов) в `I18n.load_path`, делая доступными переводы в этих файлах.

* `add_view_paths`: Добавляет директорию `app/views` из приложения, railties и engine-ов в путь поиска файлов вью приложения.

* `load_environment_config`: Загружает файл `config/environments` для текущей среды.

* `prepend_helpers_path`: Добавляет директорию `app/helpers` из приложения, railties и engine-ов в путь поиска файлов хелперов приложения.

* `load_config_initializers`: Загружает все файлы Ruby из `config/initializers` в приложении, railties и engine-ах. Файлы в этой директории могут использоваться для хранения конфигурационных настроек, которые нужно сделать после загрузки всех фреймворков.

* `engines_blank_point`: Предоставляет точку инициализации для хука, если нужно что-то сделать до того, как загрузятся engine-ы. После этой точки будут запущены все инициализаторы railties и engine-ов.

* `add_generator_templates`: Находит шаблоны для генераторов в `lib/templates` приложения, railties и engine-ов, и добавляет их в настройку `config.generators.templates`, что делает шаблоны доступными для всех ссылающихся генераторов.

* `ensure_autoload_once_paths_as_subset`: Убеждается, что `config.autoload_once_paths` содержит пути только из `config.autoload_paths`. Если она содержит другие пути, будет вызвано исключение.

* `add_to_prepare_blocks`: Блок для каждого вызова `config.to_prepare` в приложении, railtie или engine добавляется в колбэк `to_prepare` для Action Dispatch, который будет запущен при каждом запросе в development или перед первым запросом в production.

* `add_builtin_route`: Если приложение запускается в среде development, то в маршруты приложения будет добавлен маршрут для `rails/info/properties`. Этот маршрут предоставляет подробную информацию, такую как версию Rails и Ruby для `public/index.html` в приложении Rails по умолчанию.

* `build_middleware_stack`: Создает стек промежуточных программ для приложения, возвращает объект, у которого есть метод `call`, принимающий объект среды Rack для запроса.

* `eager_load!`: Если `config.eager_load` `true`, запускает хуки `config.before_eager_load`, а затем вызывает `eager_load!`, загружающий все `config.eager_load_namespaces`.

* `finisher_hook`: Представляет хук после завершения процесса инициализации приложения, а также запускает все блоки `config.after_initialize` для приложения, railties и engine-ов.

* `set_routes_reloader`: Конфигурирует Action Dispatch, перезагружая файл маршрутов с использованием `ActiveSupport::Callbacks.to_run`.

* `disable_dependency_loading`: Отключает автоматическую загрузку зависимостей, если `config.eager_load` установлена true.

Настройка пула подключений к базе данных
----------------------------------------

Соединения с базой данных Active Record управляются с помощью `ActiveRecord::ConnectionAdapters::ConnectionPool`, который обеспечивает, что пул подключений синхронизирует количество тредов, получающих доступ, с ограниченным количеством подключений к базе данных. Этот лимит по умолчанию 5, и может быть настроен в `database.yml`.

```yaml
development:
  adapter: sqlite3
  database: db/development.sqlite3
  pool: 5
  timeout: 5000
```

Поскольку управление пулом подключений по умолчанию происходит внутри Active Record, все серверы приложения (Thin, Puma, Unicorn и т.д.) должны вести себя так же. В самом начале пул подключений к базе данных пуст. По мере роста запросов на дополнительные подключения, он будет создавать их, пока не достигнет ограничения на подключения.

Каждый новый запрос займет подключение, как только он впервые запросит доступ в базу данных. В конце запроса он освободит подключение. Это означает, что дополнительный слот подключения будет снова доступен для следующего запроса в очереди.

Если попытаться использовать больше соединений, чем доступно, Active Record заблокируется и подождет соединение из пула. Если он не сможет получить соединение, будет вызвана следующая ошибка тайм-аута.

```ruby
ActiveRecord::ConnectionTimeoutError - could not obtain a database connection within 5.000 seconds (waited 5.000 seconds)
```

Если вы получаете вышеприведенную ошибку, можно попытаться увеличить размер пула соединений, увеличив опцию `pool` в `database.yml`

NOTE: Если вы запускаете многотредовую среду, есть вероятность, что несколько тредов могут получить доступ к нескольким подключениям одновременно. Поэтому, в зависимости от текущей загрузки, вы можете легко получить несколько тредов, претендующих на ограниченное количество подключений.

Произвольные настройки
----------------------

Можно настроить свой собственный код с помощью конфигурационного объекта Rails с произвольными настройками или в пространстве имен `config.x`, либо непосредственно в `config`. Ключевой разницей между этими двумя вариантами является то, что необходимо использовать `config.x`, если вы определяете _вложенную_ конфигурацию (например, `config.x.nested.hi`), и просто `config` для _одноуровневой_ конфигурации (например, `config.hello`).

```ruby
config.x.payment_processing.schedule = :daily
config.x.payment_processing.retries  = 3
config.super_debugger = true
```

Эти конфигурационные настройки доступны с помощью конфигурационного объекта:

```ruby
Rails.configuration.x.payment_processing.schedule # => :daily
Rails.configuration.x.payment_processing.retries  # => 3
Rails.configuration.x.payment_processing.not_set  # => nil
Rails.configuration.super_debugger                # => true
```

Также можно использовать `Rails::Application.config_for` для загрузки целых конфигурационных файлов:

```yaml
# config/payment.yml:
production:
  environment: production
  merchant_id: production_merchant_id
  public_key:  production_public_key
  private_key: production_private_key

development:
  environment: sandbox
  merchant_id: development_merchant_id
  public_key:  development_public_key
  private_key: development_private_key
```

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    config.payment = config_for(:payment)
  end
end
```

```ruby
Rails.configuration.payment['merchant_id'] # => production_merchant_id или development_merchant_id
```

`Rails::Application.config_for` поддерживает конфигурацию `shared` для группировки общих конфигураций. Конфигурация shared будет влита в конфигурации среды.

```yaml
# config/example.yml
shared:
  foo:
    bar:
      baz: 1

development:
  foo:
    bar:
      qux: 2
```


```ruby
# среда development
Rails.application.config_for(:example)[:foo][:bar] #=> { baz: 1, qux: 2 }
```

Индексирование поисковыми движками
----------------------------------

Иногда вы можете захотеть, чтобы некоторые страницы вашего приложения не были видимыми для поисковых сайтов, таких как Google, Bing, Yahoo или Duck Duck Go. Роботы, которые индексируют для этих сайтов, сначала анализируют файл `http://your-site.com/robots.txt`, который знает, какие страницы доступны для индексации.

Rails создает этот файл для вас внутри папки `/public`. По умолчанию все страницы вашего приложения доступны для индексации поисковыми движками. Если бы хотите запретить индексировать все страницы вашего приложения, используйте следующее:

```
User-agent: *
Disallow: /
```

Чтобы запретить только определенные страницы, необходимо использовать более сложный синтаксис. Изучите его в [официальной документации](https://www.robotstxt.org/robotstxt.html).

Наблюдение событийной файловой системы
--------------------------------------

Если загружен [гем listen](https://github.com/guard/listen), Rails использует наблюдение событийной файловой системы для обнаружения изменений, когда `config.cache_classes` равен `false`:

```ruby
group :development do
  gem 'listen', '~> 3.3'
end
```

В противном случае, в каждом запросе Rails проходит по дереву приложения для проверки, не было ли что-то изменено.

Для Linux и macOS не нужны дополнительные гемы, но требуются [для *BSD](https://github.com/guard/listen#on-bsd) и
[для Windows](https://github.com/guard/listen#on-windows).

Отметьте, что [некоторые настройки не поддерживаются](https://github.com/guard/listen#issues--limitations).
