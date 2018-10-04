Заметки о релизе Ruby on Rails 5.2
==================================

Ключевые новинки в Rails 5.2:

* Active Storage
* Хранилище кэша Redis
* HTTP/2 Early Hints
* Учетные данные (Credentials)
* Политика безопасности контента (CSP)

Эти заметки о релизе покрывают только основные изменения. Чтобы узнать о других обновлениях, различных исправлениях программных ошибок и изменениях, обратитесь к логам изменений или к [списку коммитов](https://github.com/rails/rails/commits/5-2-stable) в главном репозитории Rails на GitHub.

--------------------------------------------------------------------------------

Апгрейд до Rails 5.2
--------------------

Прежде чем апгрейднуть существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 5.2, необходимо сначала произвести апгрейд до Rails 5.1 и убедиться, что приложение все еще выполняется так, как нужно. Список вещей, которые нужно выполнить для апгрейда доступен в руководстве [Апгрейд Ruby on Rails](/upgrading-ruby-on-rails#upgrading-from-rails-5-1-to-rails-5-2).

Основные особенности
--------------------

### Active Storage

[Pull Request](https://github.com/rails/rails/pull/30020)

[Active Storage](https://github.com/rails/rails/tree/5-2-stable/activestorage) облегчает загрузку файлов в облачные хранилища данных, такие как Amazon S3, Google Cloud Storage или Microsoft Azure Storage, и прикрепляет эти файлы к объектам Active Record. Он поставляется с локальным на основе диска сервисом для разработки и тестирования, и поддерживает отзеркаливание (mirroring) файлов в подчиненных сервисах для резервного копирования и миграций. Подробнее об Active Storage можно прочитать в руководстве [Обзор Active Storage](/active_storage_overview).

### Хранилище кэша Redis

[Pull Request](https://github.com/rails/rails/pull/31134)

Rails 5.2 поставляется со встроенным хранилищем кэша Redis. Подробнее об этом можно прочитать в руководстве [Кэширование с Rails: Обзор](/caching-with-rails-an-overview#activesupport-cache-rediscachestore).

### HTTP/2 Early Hints

[Pull Request](https://github.com/rails/rails/pull/30744)

Rails 5.2 поддерживает [HTTP/2 Early Hints](https://tools.ietf.org/html/rfc8297). Чтобы запустить сервер с включенными Early Hints, необходимо передать `--early-hints` вместе с `bin/rails server`.

### Учетные данные

[Pull Request](https://github.com/rails/rails/pull/30067)

Добавлен файл `config/credentials.yml.enc` для хранения секретов приложения в production. Это разрешает сохранять любые учетные данные аутентификации для сторонних сервисов напрямую в репозиторий, зашифрованный с помощью ключа в файле `config/master.key` или переменной среды `RAILS_MASTER_KEY`. Это в конечном итоге заменит `Rails.application.secrets` и зашифрованные секреты, представленные в Rails 5.1. Кроме того, Rails 5.2 [открывает API соответствующие учетным данным](https://github.com/rails/rails/pull/30940), поэтому можно легко справиться с другими зашифрованными конфигурациями, ключами и файлами.

Подробнее об этом можно узнать в руководстве [Безопасность приложений на Rails](/ruby-on-rails-security-guide#custom-credentials).

### Политика безопасности контента

[Pull Request](https://github.com/rails/rails/pull/31162)

Rails 5.2 поставляется с новым DSL, который разрешает конфигурировать [политику безопасности контента](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy) для приложения. Также можно сконфигурировать глобальную дефолтную политику, а затем переопределить ее отдельно для каждого ресурса и даже использовать лямбды для ввода значений для каждого запроса в заголовок, такой как поддомены аккаунта в многопользовательском (multi-tenant) приложении.

Подробнее об этом можно узнать в руководстве руководстве [Безопасность приложений на Rails](/ruby-on-rails-security-guide#content-security-policy).

Railties
--------

За подробностями обратитесь к [Changelog][railties].

### Устарело

*   Устарел метод `capify!` в генераторах и шаблонах.
    ([Pull Request](https://github.com/rails/rails/pull/29493))

*   Передача имени среды в качестве обычного аргумента устарела для команд `rails dbconsole` и `rails console`. Вместо этого следует использовать опцию `-e`.
    ([Commit](https://github.com/rails/rails/commit/48b249927375465a7102acc71c2dfb8d49af8309))

*   Устарело использование подкласса `Rails::Application` для запуска сервера Rails.
    ([Pull Request](https://github.com/rails/rails/pull/30127))

*   Устарел колбэк `after_bundle` в шаблонах плагина Rails.
    ([Pull Request](https://github.com/rails/rails/pull/29446))

### Значимые изменения

*   Добавлен общий раздел `config/database.yml`, который будет загружен для всех сред.
    ([Pull Request](https://github.com/rails/rails/pull/28896))

*   Добавлен `railtie.rb` в генератор плагина.
    ([Pull Request](https://github.com/rails/rails/pull/29576))

*   Очистка скриншотов в задаче `tmp:clear`.
    ([Pull Request](https://github.com/rails/rails/pull/29534))

*   Пропуск неиспользуемых компонентов при запуске `bin/rails app:update`. Если начальная генерация приложения пропустила Action Cable, Active Record и т.д., задача update учтет эти пропуски тоже.
    ([Pull Request](https://github.com/rails/rails/pull/29645))

*   Разрешает передачу имени собственного соединения в команду `rails dbconsole` при использовании 3-уровневой конфигурации базы данных.
    Пример: `bin/rails dbconsole -c replica`.
    ([Commit](https://github.com/rails/rails/commit/1acd9a6464668d4d54ab30d016829f60b70dbbeb))

*   Правильно расширены краткие формы для имени среды, запускающие команды `console` и `dbconsole`.
    ([Commit](https://github.com/rails/rails/commit/3777701f1380f3814bd5313b225586dec64d4104))

*   Добавлен `bootsnap` в `Gemfile` по умолчанию.
    ([Pull Request](https://github.com/rails/rails/pull/29313))

*   Поддержка `-` как платформо-агностического способа для запуска скрипта из stdin с помощью `rails runner`
    ([Pull Request](https://github.com/rails/rails/pull/26343))

*   Добавлена версия `ruby x.x.x` в `Gemfile` и создан корневой файл `.ruby-version`, содержащий текущую версию Ruby при создании нового приложения Rails.
    ([Pull Request](https://github.com/rails/rails/pull/30016))

*   Добавлена опция `--skip-action-cable` в генератор плагина.
    ([Pull Request](https://github.com/rails/rails/pull/30164))

*   Добавлен `git_source` в `Gemfile` для генератора плагина.
    ([Pull Request](https://github.com/rails/rails/pull/30110))

*   Пропуск неиспользуемых компонентов при запуске `bin/rails` в плагинах Rails.
    ([Commit](https://github.com/rails/rails/commit/62499cb6e088c3bc32a9396322c7473a17a28640))

*   Оптимизированы отступы для экшнов генератора.
    ([Pull Request](https://github.com/rails/rails/pull/30166))

*   Оптимизированы отступы маршрутов.
    ([Pull Request](https://github.com/rails/rails/pull/30241))

*   Добавлена опция `--skip-yarn` в генератор плагина.
    ([Pull Request](https://github.com/rails/rails/pull/30238))

*   Поддержка нескольких версий аргументов для метода `gem` в Generators.
    ([Pull Request](https://github.com/rails/rails/pull/30323))

*   Вынесен `secret_key_base` из имени приложения в средах разработки и тестирования.
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   Добавлен `mini_magick` как комментарий в дефолтный `Gemfile`.
    ([Pull Request](https://github.com/rails/rails/pull/30633))

*   `rails new` и `rails plugin new` получают `Active Storage` по умолчанию. Добавлена возможность пропускать `Active Storage` с помощью `--skip-active-storage` и делать это автоматически, если используется `--skip-active-record`.
    ([Pull Request](https://github.com/rails/rails/pull/30101))

Action Cable
------------

За подробностями обратитесь к [Changelog][action-cable].

### Удалено

*   Удален устаревший событийный адаптер redis.
    ([Commit](https://github.com/rails/rails/commit/48766e32d31651606b9f68a16015ad05c3b0de2c))

### Значимые изменения

*   Добавлена поддержка для опций `host`, `port`, `db` и `password` в cable.yml
    ([Pull Request](https://github.com/rails/rails/pull/29528))

*   Длинные идентификаторы потока хэша при использовании адаптера PostgreSQL.
    ([Pull Request](https://github.com/rails/rails/pull/29297))

Action Pack
-----------

За подробностями обратитесь к [Changelog][action-pack].

### Удалено

*   Удален устаревший `ActionController::ParamsParser::ParseError`.
    ([Commit](https://github.com/rails/rails/commit/e16c765ac6dcff068ff2e5554d69ff345c003de1))

### Устарело

*   Устарели псевдонимы `#success?`, `#missing?` и `#error?` для `ActionDispatch::TestResponse`.
    ([Pull Request](https://github.com/rails/rails/pull/30104))

### Значимые изменения

*   Добавлена поддержка для рециркулируемых (recyclable) ключей кэша с кэшированием фрагментов.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   Изменен формат ключа кэша для фрагментов, чтобы упростить отладку количества отказов (churn) ключа.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   AEAD зашифровывает куки и сессии с помощью GCM.
    ([Pull Request](https://github.com/rails/rails/pull/28132))

*   Защита от подделка запроса по умолчанию.
    ([Pull Request](https://github.com/rails/rails/pull/29742))

*   Принудительное истечение срока действия подписанных/зашифрованных куки на стороне сервера.
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   Опция куки `:expires` поддерживает объект `ActiveSupport::Duration`.
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   Использование зарегистрированной конфигурации сервера `:puma` в Capybara.
    ([Pull Request](https://github.com/rails/rails/pull/30638))

*   Упрощены куки промежуточной программы с помощью поддержки ротации ключа.
    ([Pull Request](https://github.com/rails/rails/pull/29716))

*   Добавлена возможность включения Early Hints для HTTP/2.
    ([Pull Request](https://github.com/rails/rails/pull/30744))

*   Добавлена поддержка headless chrome для системных тестов.
    ([Pull Request](https://github.com/rails/rails/pull/30876))

*   Добавлена опция `:allow_other_host` в метод `redirect_back`.
    ([Pull Request](https://github.com/rails/rails/pull/30850))

*   Делает `assert_recognizes` для обхода монтированных engines.
    ([Pull Request](https://github.com/rails/rails/pull/22435))

*   Добавлен DSL для конфигурирования заголовка Content-Security-Policy.
    ([Pull Request](https://github.com/rails/rails/pull/31162),
    [Commit](https://github.com/rails/rails/commit/619b1b6353a65e1635d10b8f8c6630723a5a6f1a),
    [Commit](https://github.com/rails/rails/commit/4ec8bf68ff92f35e79232fbd605012ce1f4e1e6e))

*   Зарегистрированы самые популярные audio/video/font типы mime, поддерживаемые современными браузерами.
    ([Pull Request](https://github.com/rails/rails/pull/31251))

*   Изменен вывод результата дефолтного системного скриншота теста с `inline` на `simple`.
    ([Commit](https://github.com/rails/rails/commit/9d6e288ee96d6241f864dbf90211c37b14a57632))

*   Добавлена поддержка headless firefox для системных тестов.
    ([Pull Request](https://github.com/rails/rails/pull/31365))

*   Добавлены безопасные `X-Download-Options` и `X-Permitted-Cross-Domain-Policies` в дефолтный набор заголовков.
    ([Commit](https://github.com/rails/rails/commit/5d7b70f4336d42eabfc403e9f6efceb88b3eff44))

*   Изменены системные тесты для установки Puma как сервера по умолчанию, только если пользователь не указал вручную другой сервер.
    ([Pull Request](https://github.com/rails/rails/pull/31384))

*   Добавлен заголовок `Referrer-Policy` в дефолтный набор заголовков.
    ([Commit](https://github.com/rails/rails/commit/428939be9f954d39b0c41bc53d85d0d106b9d1a1))

*   Совпадение поведения `Hash#each` Rails 5.2 с поведением в Rails 4 для `ActionController::Parameters#each`.
    ([Pull Request](https://github.com/rails/rails/pull/27790))

*   Добавлена поддержка автоматического генератора nonce для Rails UJS.
    ([Commit](https://github.com/rails/rails/commit/b2f0a8945956cd92dec71ec4e44715d764990a49))

*   Обновлено дефолтное значение max-age в HSTS до 31536000 секунд (1 год), чтобы приспособиться к минимальному требованию max-age для https://hstspreload.org/.
    ([Commit](https://github.com/rails/rails/commit/30b5f469a1d30c60d1fb0605e84c50568ff7ed37))

*   Добавлен метод псевдонима `to_hash` в `to_h` для `cookies`.
    Добавлен метод псевдонима `to_h` в `to_hash` для `session`.
    ([Commit](https://github.com/rails/rails/commit/50a62499e41dfffc2903d468e8b47acebaf9b500))

Action View
-----------

За подробностями обратитесь к [Changelog][action-view].

### Удалено

*   Удален устаревший обработчик Erubis ERB.
    ([Commit](https://github.com/rails/rails/commit/7de7f12fd140a60134defe7dc55b5a20b2372d06))

### Устарело

*   Устарел хелпер `image_alt`, который использовался для добавления дефолтного тега alt к изображениям, сгенерированным `image_tag`.
    ([Pull Request](https://github.com/rails/rails/pull/30213))

### Значимые изменения

*   Добавлен тип `:json` в `auto_discovery_link_tag` для поддержки [ленты JSON](https://jsonfeed.org/version/1).
    ([Pull Request](https://github.com/rails/rails/pull/29158))

*   Добавлена опция `srcset` в хелпер `image_tag`.
    ([Pull Request](https://github.com/rails/rails/pull/29349))

*   Исправлены проблемы с `field_error_proc` для `optgroup` оборачивания и выбора разделителя `option`.
    ([Pull Request](https://github.com/rails/rails/pull/31088))

*   Изменен `form_with`, чтобы генерировать идентификаторы по умолчанию.
    ([Commit](https://github.com/rails/rails/commit/260d6f112a0ffdbe03e6f5051504cb441c1e94cd))

*   Добавлен хелпер `preload_link_tag`.
    ([Pull Request](https://github.com/rails/rails/pull/31251))

*   Разрешает использование вызываемых объектов как групповых методов для сгруппированных выборок.
    ([Pull Request](https://github.com/rails/rails/pull/31578))

Action Mailer
-------------

За подробностями обратитесь к [Changelog][action-mailer].

### Значимые изменения

*   Разрешает классы Action Mailer для конфигурирования своего задания по доставке.
    ([Pull Request](https://github.com/rails/rails/pull/29457))

*   Добавлен тестовый хелпер `assert_enqueued_email_with`.
    ([Pull Request](https://github.com/rails/rails/pull/30695))

Active Record
-------------

За подробностями обратитесь к [Changelog][active-record].

### Удалено

*   Удален устаревший `#migration_keys`.
    ([Pull Request](https://github.com/rails/rails/pull/30337))

*   Удалена устаревшая поддержка `quoted_id` при приведении типа (typecasting) объекта Active Record.
    ([Commit](https://github.com/rails/rails/commit/82472b3922bda2f337a79cef961b4760d04f9689))

*   Удален устаревший аргумент `default` из `index_name_exists?`.
    ([Commit](https://github.com/rails/rails/commit/8f5b34df81175e30f68879479243fbce966122d7))

*   Удалена устаревшая поддержка для передачи класса `:class_name` в связях.
    ([Commit](https://github.com/rails/rails/commit/e65aff70696be52b46ebe57207ebd8bb2cfcdbb6))

*   Удалены устаревшие методы `initialize_schema_migrations_table` и `initialize_internal_metadata_table`.
    ([Commit](https://github.com/rails/rails/commit/c9660b5777707658c414b430753029cd9bc39934))

*   Удален устаревший метод `supports_migrations?`.
    ([Commit](https://github.com/rails/rails/commit/9438c144b1893f2a59ec0924afe4d46bd8d5ffdd))

*   Удален устаревший метод `supports_primary_key?`.
    ([Commit](https://github.com/rails/rails/commit/c56ff22fc6e97df4656ddc22909d9bf8b0c2cbb1))

*   Удален устаревший метод `ActiveRecord::Migrator.schema_migrations_table_name`.
    ([Commit](https://github.com/rails/rails/commit/7df6e3f3cbdea9a0460ddbab445c81fbb1cfd012))

*   Удален устаревший аргумент `name` из `#indexes`.
    ([Commit](https://github.com/rails/rails/commit/d6b779ecebe57f6629352c34bfd6c442ac8fba0e))

*   Удалены устаревшие аргументы из `#verify!`.
    ([Commit](https://github.com/rails/rails/commit/9c6ee1bed0292fc32c23dc1c68951ae64fc510be))

*   Удалена устаревшая конфигурация `.error_on_ignored_order_or_limit`.
    ([Commit](https://github.com/rails/rails/commit/e1066f450d1a99c9a0b4d786b202e2ca82a4c3b3))

*   Удален устаревший метод `#scope_chain`.
    ([Commit](https://github.com/rails/rails/commit/ef7784752c5c5efbe23f62d2bbcc62d4fd8aacab))

*   Удален устаревший метод `#sanitize_conditions`.
    ([Commit](https://github.com/rails/rails/commit/8f5413b896099f80ef46a97819fe47a820417bc2))

### Устарело

*   Устарел `supports_statement_cache?`.
    ([Pull Request](https://github.com/rails/rails/pull/28938))

*   Устарела одновременная передача аргументов и блока для `count` и `sum` в `ActiveRecord::Calculations`.
    ([Pull Request](https://github.com/rails/rails/pull/29262))

*   Устарело делегирование для `arel` в `Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/29619))

*   Устарел метод `set_state` в `TransactionState`.
    ([Commit](https://github.com/rails/rails/commit/608ebccf8f6314c945444b400a37c2d07f21b253))

*   Устарел `expand_hash_conditions_for_aggregates` без замены.
    ([Commit](https://github.com/rails/rails/commit/7ae26885d96daee3809d0bd50b1a440c2f5ffb69))

### Значимые изменения

*   При вызове динамических фикстур акцессор-метода без аргументов теперь возвращает все фикстуры этого типа. Ранее этот метод всегда возвращал пустой массив.
    ([Pull Request](https://github.com/rails/rails/pull/28692))

*   Исправлена несогласованность с измененными атрибутами при переопределении ридер-атрибута Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/28661))

*   Поддержка убывающих индексов (descending indexes) для MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/28773))

*   Исправлена `bin/rails db:forward` для первой миграции.
    ([Commit](https://github.com/rails/rails/commit/b77d2aa0c336492ba33cbfade4964ba0eda3ef84))

*   Вызов ошибки `UnknownMigrationVersionError` на движении (movement) миграций, когда текущая миграция не существует.
    ([Commit](https://github.com/rails/rails/commit/bb9d6eb094f29bb94ef1f26aa44f145f17b973fe))

*   Соблюдение `SchemaDumper.ignore_tables` в задачах rake для выгрузки структуры баз данных.
    ([Pull Request](https://github.com/rails/rails/pull/29077))

*   Добавлен `ActiveRecord::Base#cache_version`, чтобы поддерживать рециркулируемые ключи кэша с помощью новых версий записей в `ActiveSupport::Cache`. Это также означает, что `ActiveRecord::Base#cache_key` теперь будет возвращать стабильный ключ, который больше не будет содержать временных меток.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   Предотвращено создание связанных параметров (bind param), если приведенное значение равно nil.
    ([Pull Request](https://github.com/rails/rails/pull/29282))

*   Использование массового (bulk) INSERT для вставки фикстур для лучшей производительности.
    ([Pull Request](https://github.com/rails/rails/pull/29504))

*   Слияние двух relations, представляющих вложенные joins, больше не преобразует joins слитого relation в LEFT OUTER JOIN.
    ([Pull Request](https://github.com/rails/rails/pull/27063))

*   Раньше, если имелась вложенная транзакция и для внешней транзакции был сделан откат, запись из внутренней транзакции по-прежнему была бы отмечена как персистентная. Это было исправлено путем применения состояния родительской транзакции к дочерней транзакции, когда был сделан откат родительской транзакции. Это будет правильно отмечать записи из внутренней транзакции, поскольку они не являются персистентными.
    ([Commit](https://github.com/rails/rails/commit/0237da287eb4c507d10a0c6d94150093acc52b03))

*   Исправлена ленивая загрузка/предварительная загрузка связи со скоупом, включающим joins.
    ([Pull Request](https://github.com/rails/rails/pull/29413))

*   Предотвращены ошибки, вызванные подписчиками уведомлений `sql.active_record`, которые будут преобразованы к исключениям `ActiveRecord::StatementInvalid`.
    ([Pull Request](https://github.com/rails/rails/pull/29692))

*   Пропуск кэширования запроса при работе с пакетом записей (`find_each`, `find_in_batches`, `in_batches`).
    ([Commit](https://github.com/rails/rails/commit/b83852e6eed5789b23b13bac40228e87e8822b4d))

*   Изменена булева сериализацию sqlite3 для использования 1 и 0. SQLite изначально распознает 1 и 0 как true и false, но не распознает 't' и 'f' как было сериализовано ранее.
    ([Pull Request](https://github.com/rails/rails/pull/29699))

*   Значения, построенные с использованием многопараметрического назначения, теперь будут использовать значение post-type-cast для рендеринга в полях ввода формы единственного поля.
    ([Commit](https://github.com/rails/rails/commit/1519e976b224871c7f7dd476351930d5d0d7faf6))

*   `ApplicationRecord` больше не генерируется при генерации моделей. Если необходимо сгенерировать его, можно создать с помощью `rails g application_record`.
    ([Pull Request](https://github.com/rails/rails/pull/29916))

*   `Relation#or` теперь принимает два relations, у которых разные значения только для `references`, так как `references` могут быть неявно вызваны `where`.
    ([Commit](https://github.com/rails/rails/commit/ea6139101ccaf8be03b536b1293a9f36bc12f2f7))

*   При использовании `Relation#or`, извлекаются общие условия и помещаются они до условия OR.
    ([Pull Request](https://github.com/rails/rails/pull/29950))

*   Добавлен метод хелпера `binary` для фикстур.
    ([Pull Request](https://github.com/rails/rails/pull/30073))

*   Автоматическое угадывание обратных связей для STI.
    ([Pull Request](https://github.com/rails/rails/pull/23425))

*   Добавлен новый класс ошибок `LockWaitTimeout`, который будет вызываться при превышении ожидания тайм-аута блокировки.
    ([Pull Request](https://github.com/rails/rails/pull/30360))

*   Обновлены имена полезной нагрузки для инструментария `sql.active_record`, чтобы был более наглядным.
    ([Pull Request](https://github.com/rails/rails/pull/30619))

*   Использование заданного алгоритма при убирании индекса из базы данных.
    ([Pull Request](https://github.com/rails/rails/pull/24199))

*   Передача `Set` в `Relation#where` теперь ведет себя так же, как передача массива.
    ([Commit](https://github.com/rails/rails/commit/9cf7e3494f5bd34f1382c1ff4ea3d811a4972ae2))

*   PostgreSQL `tsrange` теперь сохраняет досекундную точность.
    ([Pull Request](https://github.com/rails/rails/pull/30725))

*   Вызывается при вызове `lock!` в грязной (dirty) записи.
    ([Commit](https://github.com/rails/rails/commit/63cf15877bae859ff7b4ebaf05186f3ca79c1863))

*   Исправлена программная ошибка, при которой порядки столбцов для индекса не записывались в `db/schema.rb`, когда используется адаптер sqlite.
    ([Pull Request](https://github.com/rails/rails/pull/30970))

*   Исправлен `bin/rails db:migrate` с указанной `VERSION`. `bin/rails db:migrate` с пустым VERSION ведет себя как без `VERSION`. Проверен формат `VERSION`: Разрешен номер версии миграции или имя файла миграции. Вызывается ошибка, если формат `VERSION` недействителен. Вызывается ошибка, если целевая миграция не существует.
    ([Pull Request](https://github.com/rails/rails/pull/30714))

*   Добавлен новый класс ошибок `StatementTimeout`, который будет вызываться при превышении тайм-аута выражения.
    ([Pull Request](https://github.com/rails/rails/pull/31129))

*   `update_all` теперь передает свои значения в `Type#cast` до передачи их в `Type#serialize`. Это означает, что `update_all(foo: 'true')` будет должным образом делать персистентным булево значение.
    ([Commit](https://github.com/rails/rails/commit/68fe6b08ee72cc47263e0d2c9ff07f75c4b42761))

*   Теперь требуется, чтобы фрагменты на чистом SQL были явно отмечены при использовании в методах запроса relation.
    ([Commit](https://github.com/rails/rails/commit/a1ee43d2170dd6adf5a9f390df2b1dde45018a48),
    [Commit](https://github.com/rails/rails/commit/e4a921a75f8702a7dbaf41e31130fe884dea93f9))

*   Добавлен `#up_only` в миграции базы данных для кода, который актуален только для метода up в миграциях, например, для заполнения нового столбца.
    ([Pull Request](https://github.com/rails/rails/pull/31082))

*   Добавлен новый класс ошибок `QueryCanceled`, который будет вызываться при отмене выражения из-за запроса пользователя.
    ([Pull Request](https://github.com/rails/rails/pull/31235))

*   Теперь не разрешено определять скоупы, которые конфликтовали с методами экземпляра на `Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/31179))

*   Добавлена поддержка для классов оператора PostgreSQL в `add_index`.
    ([Pull Request](https://github.com/rails/rails/pull/19090))

*   Логирование вызывающих методов запроса из базы данных.
    ([Pull Request](https://github.com/rails/rails/pull/26815),
    [Pull Request](https://github.com/rails/rails/pull/31519),
    [Pull Request](https://github.com/rails/rails/pull/31690))

*   Неопределенные методы атрибута на потомках при сбросе информации о столбцах.
    ([Pull Request](https://github.com/rails/rails/pull/31475))

*   Использование subselect для `delete_all` с `limit` или `offset`.
    ([Commit](https://github.com/rails/rails/commit/9e7260da1bdc0770cf4ac547120c85ab93ff3d48))

*   Исправлена несогласованность с `first(n)` при использовании с `limit()`. Метод поиска `first(n)` теперь учитывает `limit()`, делает это в соответствии с `relation.to_a.first(n)`, а также с поведением `last(n)`.
    ([Pull Request](https://github.com/rails/rails/pull/27597))

*   Исправлена вложенная связь `has_many :through` на неперсистентных экземплярах родителя.
    ([Commit](https://github.com/rails/rails/commit/027f865fc8b262d9ba3ee51da3483e94a5489b66))

*   Принятие во внимание условий связи при удалении через записи.
    ([Commit](https://github.com/rails/rails/commit/ae48c65e411e01c1045056562319666384bb1b63))

*   Не разрешает мутировать уничтоженный объект после вызова `save` или `save!`.
    ([Commit](https://github.com/rails/rails/commit/562dd0494a90d9d47849f052e8913f0050f3e494))

*   Исправлена проблема слияния relation с помощью `left_outer_joins`.
    ([Pull Request](https://github.com/rails/rails/pull/27860))

*   Поддержка внешних таблиц PostgreSQL.
    ([Pull Request](https://github.com/rails/rails/pull/31549))

*   Очистка состояние транзакции, когда объект Active Record был дублирован (duped).
    ([Pull Request](https://github.com/rails/rails/pull/31751))

*   Исправлена проблема не расширения при передаче объекта Array как аргумента методу where используя столбец `composed_of`.
    ([Pull Request](https://github.com/rails/rails/pull/31724))

*   Делает вызов `reflection.klass`, если `polymorphic?` не будет использоваться.
    ([Commit](https://github.com/rails/rails/commit/63fc1100ce054e3e11c04a547cdb9387cd79571a))

*   Исправлен `#columns_for_distinct` для MySQL и PostgreSQL, чтобы заставить `ActiveRecord::FinderMethods#limited_ids_for` использовать правильные значения первичного ключа, даже если столбцы `ORDER BY` включают первичный ключ другой таблицы.
    ([Commit](https://github.com/rails/rails/commit/851618c15750979a75635530200665b543561a44))

*   Исправлена проблема `dependent: :destroy` для отношений has_one/belongs_to, где родительский класс удалялся, когда дочернего не было.
    ([Commit](https://github.com/rails/rails/commit/b0fc04aa3af338d5a90608bf37248668d59fc881))

Active Model
------------

За подробностями обратитесь к [Changelog][active-model].

### Значимые изменения

*   Исправлены методы `#keys`, `#values` в `ActiveModel::Errors`.
    Изменен `#keys`, чтобы возвращал только ключи, у которых нет пустых сообщений.
    Изменен `#values`, чтобы возвращал только непустые значения.
    ([Pull Request](https://github.com/rails/rails/pull/28584))

*   Добавлен метод `#merge!` для `ActiveModel::Errors`.
    ([Pull Request](https://github.com/rails/rails/pull/29714))

*   Разрешает передачу Proc или Symbol в опции length валидатора.
    ([Pull Request](https://github.com/rails/rails/pull/30674))

*   Теперь выполняется валидация `ConfirmationValidator`, когда значение `_confirmation` равно `false`.
    ([Pull Request](https://github.com/rails/rails/pull/31058))

*   Модели, использующие API атрибутов с дефолтными proc, теперь могут быть маршализованы.
    ([Commit](https://github.com/rails/rails/commit/0af36c62a5710e023402e37b019ad9982e69de4b))

*   Теперь не теряются все множественные `:includes` с опциями в сериализации.
    ([Commit](https://github.com/rails/rails/commit/853054bcc7a043eea78c97e7705a46abb603cc44))

Active Support
--------------

За подробностями обратитесь к [Changelog][active-support].

### Удалено

*   Убраны устаревшие строковые фильтры `:if` и `:unless` для колбэков.
    ([Commit](https://github.com/rails/rails/commit/c792354adcbf8c966f274915c605c6713b840548))

*   Убрана устаревшая опция `halt_callback_chains_on_return_false`.
    ([Commit](https://github.com/rails/rails/commit/19fbbebb1665e482d76cae30166b46e74ceafe29))

### Устарело

*   Устарел метод `Module#reachable?`.
    ([Pull Request](https://github.com/rails/rails/pull/30624))

*   Устарел `secrets.secret_token`.
    ([Commit](https://github.com/rails/rails/commit/fbcc4bfe9a211e219da5d0bb01d894fcdaef0a0e))

### Значимые изменения

*   Добавлен `fetch_values` для `HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/28316))

*   Добавлена поддержка для `:offset` в `Time#change`.
    ([Commit](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   Добавлена поддержка для `:offset` и `:zone` в `ActiveSupport::TimeWithZone#change`.
    ([Commit](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   Пропуск имени гема и прогноз устаревания для уведомлений об устаревании.
    ([Pull Request](https://github.com/rails/rails/pull/28800))

*   Добавлена поддержка для версионированных записей кэша. Это позволяет хранилищам кэша рециркулировать (recycle) ключи кэша, что значительно экономит на хранении в случаях с частым количеством отказов. Работает вместе с разделением `#cache_key` и `#cache_version` в Active Record и его использованием в кэшировании фрагмента Action Pack.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   Добавлен `ActiveSupport::CurrentAttributes`, чтобы предоставить тредоизолированные атрибуты синглтон. Основные случаи использования это удержание всех атрибутов каждого запроса легко доступными для всей системы.
    ([Pull Request](https://github.com/rails/rails/pull/29180))

*   `#singularize` и `#pluralize` теперь учитывают неисчисляемые существительные для указанной локали.
    ([Commit](https://github.com/rails/rails/commit/352865d0f835c24daa9a2e9863dcc9dde9e5371a))

*   Добавлена дефолтная опция `class_attribute`.
    ([Pull Request](https://github.com/rails/rails/pull/29270))

*   Добавлены `Date#prev_occurring` и `Date#next_occurring`, чтобы возвращать указанный следующий/предыдущий день недели.
    ([Pull Request](https://github.com/rails/rails/pull/26600))

*   Добавлена опция default для атрибутов акцессоров модуля и класса.
    ([Pull Request](https://github.com/rails/rails/pull/29294))

*   Кэш: `write_multi`.
    ([Pull Request](https://github.com/rails/rails/pull/29366))

*   Теперь по умолчанию `ActiveSupport::MessageEncryptor` используется шифрование AES 256 GCM.
    ([Pull Request](https://github.com/rails/rails/pull/29263))

*   Добавлен хелпер `freeze_time`, который замораживает время `Time.now` в тестах.
    ([Pull Request](https://github.com/rails/rails/pull/29681))

*   Делает порядок элементов `Hash#reverse_merge!` в соответствии с `HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/28077))

*   Добавлены поддержка назначения и истечения срока действия для `ActiveSupport::MessageVerifier` и `ActiveSupport::MessageEncryptor`.
    ([Pull Request](https://github.com/rails/rails/pull/29892))

*   Обновлен `String#camelize`, чтобы предоставлять обратную связь передаче неправильной опции.
    ([Pull Request](https://github.com/rails/rails/pull/30039))

*   `Module#delegate_missing_to` теперь вызывает `DelegationError`, если цель равна нулю, аналогично `Module#delegate`.
    ([Pull Request](https://github.com/rails/rails/pull/30191))

*   Добавлены `ActiveSupport::EncryptedFile` и `ActiveSupport::EncryptedConfiguration`.
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   Добавлен `config/credentials.yml.enc`, чтобы хранить секреты приложения в production.
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   Добавлена поддержка ротации ключа в `MessageEncryptor` и `MessageVerifier`.
    ([Pull Request](https://github.com/rails/rails/pull/29716))

*   Теперь возвращается экземпляр `HashWithIndifferentAccess` из `HashWithIndifferentAccess#transform_keys`.
    ([Pull Request](https://github.com/rails/rails/pull/30728))

*   `Hash#slice` теперь вызывает встроенное определение Ruby 2.5+, если оно определено.
    ([Commit](https://github.com/rails/rails/commit/01ae39660243bc5f0a986e20f9c9bff312b1b5f8))

*   `IO#to_json` теперь возвращает представление `to_s`, вместо того, чтобы пытаться преобразовать в массив. Это исправляет программную ошибку, в которой `IO#to_json` вызывает `IOError` при вызове нечитабельного объекта.
    ([Pull Request](https://github.com/rails/rails/pull/30953))

*   Добавлена одинаковая сигнатура метода для `Time#prev_day` и `Time#next_day` в соответствии с `Date#prev_day`, `Date#next_day`. Разрешает аргумент для `Time#prev_day` и `Time#next_day`.
    ([Commit](https://github.com/rails/rails/commit/61ac2167eff741bffb44aec231f4ea13d004134e))

*   Добавлена одинаковая сигнатура метода для `Time#prev_month` и `Time#next_month` в соответствии с `Date#prev_month`, `Date#next_month`. Разрешает аргумент для `Time#prev_month` и `Time#next_month`.
    ([Commit](https://github.com/rails/rails/commit/f2c1e3a793570584d9708aaee387214bc3543530))

*   Добавлена одинаковая сигнатура метода для `Time#prev_year` и `Time#next_year` в соответствии с `Date#prev_year`, `Date#next_year`. Разрешает аргумент для `Time#prev_year` и `Time#next_year`.
    ([Commit](https://github.com/rails/rails/commit/ee9d81837b5eba9d5ec869ae7601d7ffce763e3e))

*   Исправлена поддержка акронима в `humanize`.
    ([Commit](https://github.com/rails/rails/commit/0ddde0a8fca6a0ca3158e3329713959acd65605d))

*   Разрешает `Range#include?` работать на интервалах TWZ.
    ([Pull Request](https://github.com/rails/rails/pull/31081))

*   Кэш: Включено сжатие по умолчанию для значений > 1 Кб.
    ([Pull Request](https://github.com/rails/rails/pull/31147))

*   Хранилище кэша Redis.
    ([Pull Request](https://github.com/rails/rails/pull/31134),
    [Pull Request](https://github.com/rails/rails/pull/31866))

*   Обрабатывает ошибки `TZInfo::AmbiguousTime`.
    ([Pull Request](https://github.com/rails/rails/pull/31128))

*   MemCacheStore: Поддержка истечения сроков действия счетчиков.
    ([Commit](https://github.com/rails/rails/commit/b22ee64b5b30c6d5039c292235e10b24b1057f6d))

*   Теперь `ActiveSupport::TimeZone.all` возвращает только часовых поясов, находящихся в `ActiveSupport::TimeZone::MAPPING`.
    ([Pull Request](https://github.com/rails/rails/pull/31176))

*   Изменяет поведение по умолчанию `ActiveSupport::SecurityUtils.secure_compare`, чтобы не отображать информацию об утечке даже для строки переменной длины. Переименован старый `ActiveSupport::SecurityUtils.secure_compare` в `fixed_length_secure_compare`, и начат вызов `ArgumentError` в случае несоответствия длины переданных строк.
    ([Pull Request](https://github.com/rails/rails/pull/24510))

*   Теперь используется SHA-1 для генерации нечувствительных дайджестов, таких как заголовок ETag.
    ([Pull Request](https://github.com/rails/rails/pull/31289),
    [Pull Request](https://github.com/rails/rails/pull/31651))

*   `assert_changes` всегда будет утверждать, что выражение изменяется, вне зависимости от комбинаций аргументов `from:` и `to:`.
    ([Pull Request](https://github.com/rails/rails/pull/31011))

*   Добавлен отсутствующий инструментарий для `read_multi` в `ActiveSupport::Cache::Store`.
    ([Pull Request](https://github.com/rails/rails/pull/30268))

*   Поддержка хэша как первого аргумента в `assert_difference`. Это разрешает указать несколько числовых различий в одном утверждении.
    ([Pull Request](https://github.com/rails/rails/pull/31600))

*   Кэширование: MemCache и Redis `read_multi` и ускорение (speedup) `fetch_multi`. Чтение из локального кэша, хранящегося в памяти до обращения к бэкенду.
    ([Commit](https://github.com/rails/rails/commit/a2b97e4ffef971607a1be8fc7909f099b6840f36))

Active Job
----------

За подробностями обратитесь к [Changelog][active-job].

### Значимые изменения

*   Разрешить передачу блока в `ActiveJob::Base.discard_on`, чтобы разрешить собственную обработку заданий сброса.
    ([Pull Request](https://github.com/rails/rails/pull/30622))

Ruby on Rails Guides
--------------------

За подробностями обратитесь к [Changelog][guides].

### Значимые изменения

*   Добавлено руководство [Треды и выполнение кода в Rails](/threading_and_code_execution).
    ([Pull Request](https://github.com/rails/rails/pull/27494))

*   Добавлено руководство [Обзор Active Storage](/active_storage_overview).
    ([Pull Request](https://github.com/rails/rails/pull/31037))

Благодарности
-------------

Взгляните [на полный список контрибьюторов Rails](http://contributors.rubyonrails.org/), на людей, которые потратили много часов, сделав Rails стабильнее и надёжнее. Спасибо им всем.

[railties]:       https://github.com/rails/rails/blob/5-2-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-2-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-2-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-2-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-2-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-2-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-2-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-2-stable/activesupport/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-2-stable/activejob/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/5-2-stable/guides/CHANGELOG.md
