Заметки о релизе Ruby on Rails 6.0
==================================

Ключевые новинки в Rails 6.0:

* Action Mailbox
* Action Text
* Параллельное тестирование
* Тестирование Action Cable

Эти заметки о релизе покрывают только основные изменения. Чтобы узнать о других обновлениях, различных исправлениях программных ошибок и изменениях, обратитесь к логам изменений или к [списку коммитов](https://github.com/rails/rails/commits/6-0-stable) в главном репозитории Rails на GitHub.

--------------------------------------------------------------------------------

Апгрейд до Rails 6.0
----------------------

Прежде чем апгрейднуть существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 6.0, необходимо сначала произвести апгрейд до Rails 5.2 и убедиться, что приложение все еще выполняется так, как нужно. Список вещей, которые нужно выполнить для апгрейда доступен в руководстве [Апгрейд Ruby on Rails](/upgrading-ruby-on-rails#upgrading-from-rails-5-2-to-rails-6-0).

Основные особенности
--------------------

### Action Mailbox

[Pull Request](https://github.com/rails/rails/pull/34786)

[Action Mailbox](https://github.com/rails/rails/tree/6-0-stable/actionmailbox) позволяет направлять входящие письма в подобные контроллерам почтовые ящики. Подробнее об Action Mailbox можно прочитать в руководстве [Основы Action Mailbox](/action-mailbox-basics).

### Action Text

[Pull Request](https://github.com/rails/rails/pull/34873)

[Action Text](https://github.com/rails/rails/tree/6-0-stable/actiontext) добавляет возможность хранения и редактирования обогащенного текста в Rails. Это включает [редактор Trix](https://trix-editor.org), обрабатывающий все от форматирования до ссылок, цитирования, списков, вложенных изображений и галерей. Содержимое обогащенного текста, сгенерированного редактором Trix, сохраняется в собственной модели RichText, которая связывается с существующими моделями Active Record в приложении. Любые встроенные изображения (или другие вложения) автоматически сохраняются с помощью Active Storage и связываются с включающей моделью RichText.

Подробнее об Action Text можно прочитать в руководстве [Обзор Action Text](/action-text-overview).

### Параллельное тестирование

[Pull Request](https://github.com/rails/rails/pull/31900)

[Параллельное тестирование](/a-guide-to-testing-rails-applications#parallel-testing) позволяет распараллелить тестовый набор. Хотя форк процессов является методом по умолчанию, треды также поддерживаются. Запуск тестов параллельно сокращает время, затрачиваемое на запуск всего тестового набора.

### Тестирование Action Cable

[Pull Request](https://github.com/rails/rails/pull/33659)

[Инструменты тестирования Action Cable](/a-guide-to-testing-rails-applications#testing-action-cable) позволяют тестировать функционал Action Cable на любом уровне: соединения, каналы, трансляции.

Railties
--------

За подробностями обратитесь к [Changelog][railties].

### Удалено

*   Удален устаревший хелпер `after_bundle` в шаблонах плагинов.
    ([Commit](https://github.com/rails/rails/commit/4d51efe24e461a2a3ed562787308484cd48370c7))

*   Удалена устаревшая поддержка `config.ru`, использующая класс приложения в качестве аргумента для `run`.
    ([Commit](https://github.com/rails/rails/commit/553b86fc751c751db504bcbe2d033eb2bb5b6a0b))

*   Удален устаревший аргумент `environment` из команд rails.
    ([Commit](https://github.com/rails/rails/commit/e20589c9be09c7272d73492d4b0f7b24e5595571))

*   Удален устаревший метод `capify!` в генераторах и шаблонах.
    ([Commit](https://github.com/rails/rails/commit/9d39f81d512e0d16a27e2e864ea2dd0e8dc41b17))

*   Удален устаревший `config.secret_token`.
    ([Commit](https://github.com/rails/rails/commit/46ac5fe69a20d4539a15929fe48293e1809a26b0))

### Устарело

*   Устарела передача имени сервера Rack в качестве обычного аргумента в `rails server`.
    ([Pull Request](https://github.com/rails/rails/pull/32058))

*   Устарела поддержка использования переменной среды `HOST` для определения IP сервера.
    ([Pull Request](https://github.com/rails/rails/pull/32540))

*   Устарел доступ к кэшам, возвращаемым `config_for`, по не символьным ключам.
    ([Pull Request](https://github.com/rails/rails/pull/35198))

### Значимые изменения

*   Добавлена явная опция `--using` или `-u` для указания сервера для команды `rails server`.
    ([Pull Request](https://github.com/rails/rails/pull/32058))

*   Добавлена возможность увидеть вывод `rails routes` в расширенном формате.
    ([Pull Request](https://github.com/rails/rails/pull/32130))

*   Запуск задачи заполнения базы данных с помощью встроенного адаптера Active Job.
    ([Pull Request](https://github.com/rails/rails/pull/34953))

*   Добавлена команда `rails db:system:change` для изменения базы данных приложения.
    ([Pull Request](https://github.com/rails/rails/pull/34832))

*   Добавлена команда `rails test:channels` для тестирования только каналов Action Cable.
    ([Pull Request](https://github.com/rails/rails/pull/34947))

*   Представлена защита против атак перепривязывания DNS.
    ([Pull Request](https://github.com/rails/rails/pull/33145))

*   Добавлена возможность прерваться при неудаче во время запуска команд генератора.
    ([Pull Request](https://github.com/rails/rails/pull/34420))

*   Webpacker сделан компилятором JavaScript по умолчанию в Rails 6.
    ([Pull Request](https://github.com/rails/rails/pull/33079))

*   Добавлена поддержка нескольких баз данных для команды `rails db:migrate:status`.
    ([Pull Request](https://github.com/rails/rails/pull/34137))

*   Добавлена возможность использования различных путей миграции из нескольких баз данных в генераторах.
    ([Pull Request](https://github.com/rails/rails/pull/34021))

*   Добавлена поддержка учетных данных для нескольких сред.
    ([Pull Request](https://github.com/rails/rails/pull/33521))

*   `null_store` сделан хранилищем кэша по умолчанию в тестовой среде.
    ([Pull Request](https://github.com/rails/rails/pull/33773))

Action Cable
------------

За подробностями обратитесь к [Changelog][action-cable].

### Удалено

*   Заменены `ActionCable.startDebugging()` и `ActionCable.stopDebugging()` с помощью `ActionCable.logger.enabled`.
    ([Pull Request](https://github.com/rails/rails/pull/34370))

### Устарело

*   Для Action Cable не было устареваний в Rails 6.0.

### Значимые изменения

*   Добавлена поддержка опции `channel_prefix` для адаптеров подписки PostgreSQL в `cable.yml`.
    ([Pull Request](https://github.com/rails/rails/pull/35276))

*   Разрешена передача произвольной конфигурации в `ActionCable::Server::Base`.
    ([Pull Request](https://github.com/rails/rails/pull/34714))

*   Добавлены хуки загрузки `:action_cable_connection` и `:action_cable_channel`.
    ([Pull Request](https://github.com/rails/rails/pull/35094))

*   Добавлены `Channel::Base#broadcast_to` и `Channel::Base.broadcasting_for`.
    ([Pull Request](https://github.com/rails/rails/pull/35021))

*   Закрытие соединения при вызове `reject_unauthorized_connection` из `ActionCable::Connection`.
    ([Pull Request](https://github.com/rails/rails/pull/34194))

*   Пакет Action Cable JavaScript преобразован из CoffeeScript в ES2015, и его исходники опубликованы в npm.
    ([Pull Request](https://github.com/rails/rails/pull/34370))

*   Конфигурация адаптера WebSocket и адаптера logger перемещена из свойств `ActionCable` в `ActionCable.adapters`.
    ([Pull Request](https://github.com/rails/rails/pull/34370))

*   Добавлена опция `id` в адаптере Redis для различения Redis-соединений Action Cable.
    ([Pull Request](https://github.com/rails/rails/pull/33798))

Action Pack
-----------

За подробностями обратитесь к [Changelog][action-pack].

### Удалено

*   Удален устаревший хелпер `fragment_cache_key` в пользу `combined_fragment_cache_key`.
    ([Commit](https://github.com/rails/rails/commit/e70d3df7c9b05c129b0fdcca57f66eca316c5cfc))

*   Удалены устаревшие методы в `ActionDispatch::TestResponse`: `#success?` в пользу `#successful?`, `#missing?` в пользу `#not_found?`, `#error?` в пользу `#server_error?`.
    ([Commit](https://github.com/rails/rails/commit/13ddc92e079e59a0b894e31bf5bb4fdecbd235d1))

### Устарело

*   Устарел `ActionDispatch::Http::ParameterFilter` в пользу `ActiveSupport::ParameterFilter`.
    ([Pull Request](https://github.com/rails/rails/pull/34039))

*   Устарел `force_ssl` на уровне контроллера в пользу `config.force_ssl`.
    ([Pull Request](https://github.com/rails/rails/pull/32277))

### Значимые изменения

*   Изменен `ActionDispatch::Response#content_type`. возвращающий заголовок Content-Type как есть.
    ([Pull Request](https://github.com/rails/rails/pull/36034))

*   Вызывается `ArgumentError`, если параметр ресурса содержит двоеточие.
    ([Pull Request](https://github.com/rails/rails/pull/35236))

*   Разрешено вызывать `ActionDispatch::SystemTestCase.driven_by` с блоком для определения специфичных возможностей браузера.
    ([Pull Request](https://github.com/rails/rails/pull/35081))

*   Добавлена промежуточная программа `ActionDispatch::HostAuthorization`, защищающая от атак перепривязывания DNS.
    ([Pull Request](https://github.com/rails/rails/pull/33145))

*   Разрешено использование `parsed_body` в `ActionController::TestCase`.
    ([Pull Request](https://github.com/rails/rails/pull/34717))

*   Вызывается `ArgumentError`, когда существуют несколько корневых маршрутов в том же контексте без использования указаний именования `as:`.
    ([Pull Request](https://github.com/rails/rails/pull/34494))

*   Разрешено использование `#rescue_from` для обработки ошибок парсинга параметра.
    ([Pull Request](https://github.com/rails/rails/pull/34341))

*   Добавлен `ActionController::Parameters#each_value` для перебора параметров.
    ([Pull Request](https://github.com/rails/rails/pull/33979))

*   Имена файлов кодируются в Content-Disposition при `send_data` и `send_file`.
    ([Pull Request](https://github.com/rails/rails/pull/33829))

*   Раскрыт `ActionController::Parameters#each_key`.
    ([Pull Request](https://github.com/rails/rails/pull/33758))

*   Добавлены метаданные назначения и прекращения внутри подписанных/зашифрованных куки для предотвращения копирования значения из одного в другое куки.
    ([Pull Request](https://github.com/rails/rails/pull/32937))

*   Вызывается `ActionController::RespondToMismatchError` для конфликтующих вызовов `respond_to`.
    ([Pull Request](https://github.com/rails/rails/pull/33446))

*   Добавлена явная страница ошибки когда отсутствует шаблон для формата запроса.
    ([Pull Request](https://github.com/rails/rails/pull/29286))

*   Представлен `ActionDispatch::DebugExceptions.register_interceptor`, способ вклиниться в DebugExceptions и обработать исключение, перед тем, как оно будет отрендерено.
    ([Pull Request](https://github.com/rails/rails/pull/23868))

*   Выводится только один заголовок Content-Security-Policy на запрос.
    ([Pull Request](https://github.com/rails/rails/pull/32602))

*   Добавлен модуль, специальный для конфигурации Rails для заголовков по умолчанию, который может быть явно включен в контроллерах.
    ([Pull Request](https://github.com/rails/rails/pull/32484))

*   Добавлен `#dig` в `ActionDispatch::Request::Session`.
    ([Pull Request](https://github.com/rails/rails/pull/32446))

Action View
-----------

За подробностями обратитесь к [Changelog][action-view].

### Удалено

*   Удален устаревший хелпер `image_alt`.
    ([Commit](https://github.com/rails/rails/commit/60c8a03c8d1e45e48fcb1055ba4c49ed3d5ff78f))

*   Убран пустой модуль `RecordTagHelper`, функционал которого уже был перенесен в гем `record_tag_helper`.
    ([Commit](https://github.com/rails/rails/commit/5c5ddd69b1e06fb6b2bcbb021e9b8dae17e7cb31))

### Устарело

*   Устарел `ActionView::Template.finalize_compiled_template_methods` без замены.
    ([Pull Request](https://github.com/rails/rails/pull/35036))

*   Устарел `config.action_view.finalize_compiled_template_methods` без замены.
    ([Pull Request](https://github.com/rails/rails/pull/35036))

*   Устарел вызов приватных методов модели из хелпера вью `options_from_collection_for_select`.
    ([Pull Request](https://github.com/rails/rails/pull/33547))

### Значимые изменения

*   Кэш Action View очищается в разработке только при изменении файла, что ускоряет режим разработки.
    ([Pull Request](https://github.com/rails/rails/pull/35629))

*   Все npm-пакеты Rails перемещены в пространстве имен `@rails`.
    ([Pull Request](https://github.com/rails/rails/pull/34905))

*   Принимаются только форматы из зарегистрированных типов MIME.
    ([Pull Request](https://github.com/rails/rails/pull/35604), [Pull Request](https://github.com/rails/rails/pull/35753))

*   В вывод сервера о рендере шаблона и партиала добавлены allocations.
    ([Pull Request](https://github.com/rails/rails/pull/34136))

*   В тег `date_select` добавлена опция `year_format`, позволяющая настроить имена годов.
    ([Pull Request](https://github.com/rails/rails/pull/32190))

*   Для хелпера `javascript_include_tag` добавлена опция `nonce: true` для поддержки автоматической генерации nonce для Политики безопасности контента.
    ([Pull Request](https://github.com/rails/rails/pull/32607))

*   Добавлена конфигурация `action_view.finalize_compiled_template_methods`, чтобы включить или отключить финализаторы `ActionView::Template`.
    ([Pull Request](https://github.com/rails/rails/pull/32418))

*   Вызов JavaScript `confirm` извлечен в собственный переопределяемый метод в `rails_ujs`.
    ([Pull Request](https://github.com/rails/rails/pull/32404))

*   Добавлена конфигурационная опция `action_controller.default_enforce_utf8` для управления принуждением кодировки UTF-8. По умолчанию `false`.
    ([Pull Request](https://github.com/rails/rails/pull/32125))

*   Добавлена поддержка ключей локалей I18n для тегов submit.
    ([Pull Request](https://github.com/rails/rails/pull/26799))

Action Mailer
-------------

За подробностями обратитесь к [Changelog][action-mailer].

### Удалено

### Устарело

*   Устарел `ActionMailer::Base.receive` в пользу Action Mailbox.
    ([Commit](https://github.com/rails/rails/commit/e3f832a7433a291a51c5df397dc3dd654c1858cb))

*   Устарели `DeliveryJob` и `Parameterized::DeliveryJob` в пользу `MailDeliveryJob`.
    ([Pull Request](https://github.com/rails/rails/pull/34591))

### Значимые изменения

*   Добавлен `MailDeliveryJob` для отправки и обычных, и параметризованных писем.
    ([Pull Request](https://github.com/rails/rails/pull/34591))

*   Позволена работа произвольных заданий доставки с тестовыми утверждениями Action Mailer.
    ([Pull Request](https://github.com/rails/rails/pull/34339))

*   Позволено указание имени шаблона для multipart писем с блоками вместо просто имени экшна.
    ([Pull Request](https://github.com/rails/rails/pull/22534))

*   В полезную нагрузку уведомления `deliver.action_mailer` добавлены `perform_deliveries`.
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   Улучшено сообщение лога, когда `perform_deliveries` является false, чтобы указать, что отправка письма была пропущена.
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   Позволен вызов `assert_enqueued_email_with` без блока.
    ([Pull Request](https://github.com/rails/rails/pull/33258))

*   Выполняются задания доставки писем из очереди в блоке `assert_emails`.
    ([Pull Request](https://github.com/rails/rails/pull/32231))

*   `ActionMailer::Base` позволено отменять регистрацию обсерверов и перехватчиков.
    ([Pull Request](https://github.com/rails/rails/pull/32207))

Active Record
-------------

За подробностями обратитесь к [Changelog][active-record].

### Удалено

*   Убран устаревший `#set_state` из объекта транзакции.
    ([Commit](https://github.com/rails/rails/commit/6c745b0c5152a4437163a67707e02f4464493983))

*   Убран устаревший `#supports_statement_cache?` из адаптеров базы данных.
    ([Commit](https://github.com/rails/rails/commit/5f3ed8784383fb4eb0f9959f31a9c28a991b7553))

*   Убран устаревший `#insert_fixtures` из адаптеров базы данных.
    ([Commit](https://github.com/rails/rails/commit/400ba786e1d154448235f5f90183e48a1043eece))

*   Убран устаревший `ActiveRecord::ConnectionAdapters::SQLite3Adapter#valid_alter_table_type?`.
    ([Commit](https://github.com/rails/rails/commit/45b4d5f81f0c0ca72c18d0dea4a3a7b2ecc589bf))

*   Убрана поддержка передачи имени столбца в `sum`, когда передан блок.
    ([Commit](https://github.com/rails/rails/commit/91ddb30083430622188d76eb9f29b78131df67f9))

*   Убрана поддержка передачи имени столбца в `count`, когда передан блок.
    ([Commit](https://github.com/rails/rails/commit/67356f2034ab41305af7218f7c8b2fee2d614129))

*   Убрана поддержка делегации отсутствующих методов в relation к Arel.
    ([Commit](https://github.com/rails/rails/commit/d97980a16d76ad190042b4d8578109714e9c53d0))

*   Убрана поддержка делегации отсутствующих методов в relation к приватным методам класса.
    ([Commit](https://github.com/rails/rails/commit/a7becf147afc85c354e5cfa519911a948d25fc4d))

*   Убрана поддержка указания имени временной метки для `#cache_key`.
    ([Commit](https://github.com/rails/rails/commit/0bef23e630f62e38f20b5ae1d1d5dbfb087050ea))

*   Убран устаревший `ActiveRecord::Migrator.migrations_path=`.
    ([Commit](https://github.com/rails/rails/commit/90d7842186591cae364fab3320b524e4d31a7d7d))

*   Убран устаревший `expand_hash_conditions_for_aggregates`.
    ([Commit](https://github.com/rails/rails/commit/27b252d6a85e300c7236d034d55ec8e44f57a83e))


### Устарело

*   Устарели сопоставительные сравнения с несоответствующей чувствительностью к регистру для валидатора уникальности.
    ([Commit](https://github.com/rails/rails/commit/9def05385f1cfa41924bb93daa187615e88c95b9))

*   Устарело использование запрашивающих методов, если получающий скоуп утек.
    ([Pull Request](https://github.com/rails/rails/pull/35280))

*   Устарел `config.active_record.sqlite3.represent_boolean_as_integer`.
    ([Commit](https://github.com/rails/rails/commit/f59b08119bc0c01a00561d38279b124abc82561b))

*   Устарела передача `migrations_paths` в `connection.assume_migrated_upto_version`.
    ([Commit](https://github.com/rails/rails/commit/c1b14aded27e063ead32fa911aa53163d7cfc21a))

*   Устарел `ActiveRecord::Result#to_hash` в пользу `ActiveRecord::Result#to_a`.
    ([Commit](https://github.com/rails/rails/commit/16510d609c601aa7d466809f3073ec3313e08937))

*   Устарели методы в `DatabaseLimits`: `column_name_length`, `table_name_length`,
    `columns_per_table`, `indexes_per_table`, `columns_per_multicolumn_index`,
    `sql_query_length` и `joins_per_query`.
    ([Commit](https://github.com/rails/rails/commit/e0a1235f7df0fa193c7e299a5adee88db246b44f))

*   Устарел `update_attributes`/`!` в пользу `update`/`!`.
    ([Commit](https://github.com/rails/rails/commit/5645149d3a27054450bd1130ff5715504638a5f5))

### Значимые изменения

*   Установлена минимальная версия гема `sqlite3` 1.4.
    ([Pull Request](https://github.com/rails/rails/pull/35844))

*   Добавлена `rails db:prepare`, чтобы создать базу данных, если она не существует, и запустить ее миграции.
    ([Pull Request](https://github.com/rails/rails/pull/35768))

*   Добавлен колбэк `after_save_commit` в качестве сокращения для `after_commit :hook, on: [ :create, :update ]`.
    ([Pull Request](https://github.com/rails/rails/pull/35804))

*   Добавлен `ActiveRecord::Relation#extract_associated` для извлечения связанных записей из relation.
    ([Pull Request](https://github.com/rails/rails/pull/35784))

*   Добавлен `ActiveRecord::Relation#annotate` для добавления комментариев SQL в запросы ActiveRecord::Relation.
    ([Pull Request](https://github.com/rails/rails/pull/35617))

*   Добавлена поддержка для настройки Optimizer Hints на базах данных.
    ([Pull Request](https://github.com/rails/rails/pull/35615))

*   Добавлены методы `insert_all`/`insert_all!`/`upsert_all` для выполнения массовых вставок.
    ([Pull Request](https://github.com/rails/rails/pull/35631))

*   Добавлена `rails db:seed:replant`, которая очищает таблицы каждой базы данных для текущего окружения и загружает сиды.
    ([Pull Request](https://github.com/rails/rails/pull/34779))

*   Добавлен метод `reselect`, являющийся сокращением для `unscope(:select).select(fields)`.
    ([Pull Request](https://github.com/rails/rails/pull/33611))

*   Добавлены отрицающие скоупы для всех значений enum.
    ([Pull Request](https://github.com/rails/rails/pull/35381))

*   Добавлены `#destroy_by` и `#delete_by` для условных удалений.
    ([Pull Request](https://github.com/rails/rails/pull/35316))

*   Добавлена возможность автоматически переключать соединения с базой данной.
    ([Pull Request](https://github.com/rails/rails/pull/35073))

*   Добавлена возможность предотвращать записи в базу данных на протяжении блока.
    ([Pull Request](https://github.com/rails/rails/pull/34505))

*   Добавлен API для переключения соединений для поддержки нескольких баз данных.
    ([Pull Request](https://github.com/rails/rails/pull/34052))

*   Временные метки с точностью сделаны по умолчанию в миграциях.
    ([Pull Request](https://github.com/rails/rails/pull/34970))

*   Поддерживается опция `:size` для изменения размера текста и бинарного объекта в MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/35071))

*   Столбцы внешнего ключа и внешнего типа устанавливаются NULL для полиморфных связей при стратегии `dependent: :nullify`.
    ([Pull Request](https://github.com/rails/rails/pull/28078))

*   Разрешенному экземпляру `ActionController::Parameters` разрешается быть переданным в качестве аргумента в `ActiveRecord::Relation#exists?`.
    ([Pull Request](https://github.com/rails/rails/pull/34891))

*   В `#where` добавлена поддержка бесконечных диапазонов, представленных в Ruby 2.6.
    ([Pull Request](https://github.com/rails/rails/pull/34906))

*   `ROW_FORMAT=DYNAMIC` сделан опцией создания таблиц по умолчанию для MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/34742))

*   Добавлена возможность отключить скоупы, генерируемые `ActiveRecord.enum`.
    ([Pull Request](https://github.com/rails/rails/pull/34605))

*   Неявное упорядочивание для столбца сделано настраиваемым.
    ([Pull Request](https://github.com/rails/rails/pull/34480))

*   Установлена минимальная версия PostgreSQL как 9.3, отброшена поддержка для 9.1 и 9.2.
    ([Pull Request](https://github.com/rails/rails/pull/34520))

*   Значения перечисления сделаны замороженными, вызывая ошибку при попытке их изменить.
    ([Pull Request](https://github.com/rails/rails/pull/34517))

*   SQL ошибок `ActiveRecord::StatementInvalid` сделан свойством ошибки, и подстановки в SQL отдельным свойством ошибки.
    ([Pull Request](https://github.com/rails/rails/pull/34468))

*   В `create_table` добавлена опция `:if_not_exists`.
    ([Pull Request](https://github.com/rails/rails/pull/31382))

*   Добавлена поддержка нескольких баз данных в `rails db:schema:cache:dump` и `rails db:schema:cache:clear`.
    ([Pull Request](https://github.com/rails/rails/pull/34181))

*   Добавлена поддержка хэшей и конфигов url в хэше базы данных `ActiveRecord::Base.connected_to`.
    ([Pull Request](https://github.com/rails/rails/pull/34196))

*   Добавлена поддержка для выражений по умолчанию и индексов выражений для MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/34307))

*   Добавлена опция `index` для хелперов миграции `change_table`.
    ([Pull Request](https://github.com/rails/rails/pull/23593))

*   Починен откат `transaction` для миграций. Ранее команды внутри `transaction` в откатываемой миграции запускались не в обратном порядке. Изменение чинит это.
    ([Pull Request](https://github.com/rails/rails/pull/31604))

*   Разрешено настраивать `ActiveRecord::Base.configurations=` с помощью символьного хэша.
    ([Pull Request](https://github.com/rails/rails/pull/33968))

*   Починен кэш счетчика, чтобы он обновлялся, только когда запись фактически сохраняется.
    ([Pull Request](https://github.com/rails/rails/pull/33913))

*   Добавлена поддержка индексов выражений для адаптера SQLite.
    ([Pull Request](https://github.com/rails/rails/pull/33874))

*   Подклассам разрешено переопределять колбэки автоматического сохранения для связанных записей.
    ([Pull Request](https://github.com/rails/rails/pull/33378))

*   Установлена минимальная версия MySQL как 5.5.8.
    ([Pull Request](https://github.com/rails/rails/pull/33853))

*   В MySQL используется кодировка по умолчанию utf8mb4.
    ([Pull Request](https://github.com/rails/rails/pull/33608))

*   Добавлена возможность фильтровать чувствительные данные в `#inspect`
    ([Pull Request](https://github.com/rails/rails/pull/33756), [Pull Request](https://github.com/rails/rails/pull/34208))

*   Изменен `ActiveRecord::Base.configurations`, чтобы возвращать объект вместо хэша.
    ([Pull Request](https://github.com/rails/rails/pull/33637))

*   Добавлена настройка базы данных, чтобы отключать рекомендательные блокировки.
    ([Pull Request](https://github.com/rails/rails/pull/33691))

*   Обновлен метод адаптера SQLite3 `alter_table`, чтобы восстанавливались внешние ключи.
    ([Pull Request](https://github.com/rails/rails/pull/33585))

*   Опции `:to_table` метода `remove_foreign_key` разрешено быть откатанной.
    ([Pull Request](https://github.com/rails/rails/pull/33530))

*   Починено значение по умолчанию для типов времени MySQL с указанной точностью.
    ([Pull Request](https://github.com/rails/rails/pull/33280))

*   Починена опция `touch`, чтобы вести себя в соответствии с методом `Persistence#touch`.
    ([Pull Request](https://github.com/rails/rails/pull/33107))

*   Вызывается исключение для определений дубликата столбца в миграциях.
    ([Pull Request](https://github.com/rails/rails/pull/33029))

*   Установлена минимальная версия SQLite как 3.8.
    ([Pull Request](https://github.com/rails/rails/pull/32923))

*   Починено, что родительские записи не сохранялись с дубликатами дочерних записей.
    ([Pull Request](https://github.com/rails/rails/pull/32952))

*   Гарантируется, что `Associations::CollectionAssociation#size` и `Associations::CollectionAssociation#empty?` используют загруженные связи, если они присутствуют.
    ([Pull Request](https://github.com/rails/rails/pull/32617))

*   Добавлена поддержка предварительной загрузки полиморфных связей, когда не у всех записей имеются требуемые связи.
    ([Commit](https://github.com/rails/rails/commit/75ef18c67c29b1b51314b6c8a963cee53394080b))

*   В `ActiveRecord::Relation` добавлен метод `touch_all`.
    ([Pull Request](https://github.com/rails/rails/pull/31513))

*   Добавлен предикат `ActiveRecord::Base.base_class?`.
    ([Pull Request](https://github.com/rails/rails/pull/32417))

*   Добавлены опции пользовательского префикса/суффикса в `ActiveRecord::Store.store_accessor`.
    ([Pull Request](https://github.com/rails/rails/pull/32306))

*   Добавлены `ActiveRecord::Base.create_or_find_by`/`!`, чтобы разобраться с SELECT/INSERT состоянием гонки в    `ActiveRecord::Base.find_or_create_by`/`!` на основе ограничений уникальности в базе данных.
    ([Pull Request](https://github.com/rails/rails/pull/31989))

*   Добавлен `Relation#pick` в качестве сокращения для pluck одиночного значения.
    ([Pull Request](https://github.com/rails/rails/pull/31941))

Active Storage
--------------

За подробностями обратитесь к [Changelog][active-storage].

### Удалено

### Устарело

*   Устарел  `config.active_storage.queue` в пользу `config.active_storage.queues.analysis` и `config.active_storage.queues.purge`.
    ([Pull Request](https://github.com/rails/rails/pull/34838))

*   Устарел `ActiveStorage::Downloading` в пользу `ActiveStorage::Blob#open`.
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

*   Устарело непосредственное использование `mini_magick` для генерации вариантов изображения в пользу `image_processing`.
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

*   Устарела `:combine_options` в преобразователе ImageProcessing в Active Storage без замены.
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

### Значимые изменения

*   Добавлена поддержка для генерации вариантов изображения BMP.
    ([Pull Request](https://github.com/rails/rails/pull/36051))

*   Добавлена поддержка для генерации вариантов изображения TIFF.
    ([Pull Request](https://github.com/rails/rails/pull/34824))

*   Добавлена поддержка для генерации вариантов изображения прогрессивного JPEG.
    ([Pull Request](https://github.com/rails/rails/pull/34455))

*   Добавлен `ActiveStorage.routes_prefix` для настройки генерируемых маршрутов Active Storage.
    ([Pull Request](https://github.com/rails/rails/pull/33883))

*   В `ActiveStorage::DiskController#show` генерируется отклик 404 Not Found, когда запрашиваемый файл отсутствует на дисковом сервисе.
    ([Pull Request](https://github.com/rails/rails/pull/33666))

*   Для `ActiveStorage::Blob#download` и `ActiveStorage::Blob#open` вызывается `ActiveStorage::FileNotFoundError`, когда запрашиваемый файл отсутствует.
    ([Pull Request](https://github.com/rails/rails/pull/33666))

*   Добавлен общий класс `ActiveStorage::Error`, от которого наследуются исключения Active Storage.
    ([Commit](https://github.com/rails/rails/commit/18425b837149bc0d50f8d5349e1091a623762d6b))

*   Файлы модели, предназначенные для хранения, сохраняются, когда сохраняется модель, а не немедленно.
    ([Pull Request](https://github.com/rails/rails/pull/33303))

*   Существующие изображения опционально заменяются вместо добавления к ним при присвоении к коллекции вложений (как в `@user.update!(images: [ … ])`). Используйте `config.active_storage.replace_on_assign_to_many` для контроля этого поведения.
    ([Pull Request](https://github.com/rails/rails/pull/33303),
     [Pull Request](https://github.com/rails/rails/pull/36716))

*   Добавлена способность отражать на определенных вложениях с помощью существующего механизма отражения Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/33018))

*   Добавлен `ActiveStorage::Blob#open`, который загружает бинарный объект во временный файл на диске, и передает этот временный файл.
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

*   Поддержка потоковых загрузок из Google Cloud Storage. Требуется версия 1.11+ гема `google-cloud-storage`.
    ([Pull Request](https://github.com/rails/rails/pull/32788))

*   Использован гем `image_processing` для вариантов Active Storage. Это заменяет непосредственное использование `mini_magick`.
    ([Pull Request](https://github.com/rails/rails/pull/32471))

Active Model
------------

За подробностями обратитесь к [Changelog][active-model].

### Удалено

### Устарело

### Значимые изменения

*   Добавлена конфигурационная опция для настройки формата `ActiveModel::Errors#full_message`.
    ([Pull Request](https://github.com/rails/rails/pull/32956))

*   Добавлена поддержка настройки имени атрибута для `has_secure_password`.
    ([Pull Request](https://github.com/rails/rails/pull/26764))

*   В `ActiveModel::Errors` добавлен метод `#slice!`.
    ([Pull Request](https://github.com/rails/rails/pull/34489))

*   Добавлен `ActiveModel::Errors#of_kind?` для проверки существования конкретной ошибки.
    ([Pull Request](https://github.com/rails/rails/pull/34866))

*   Починен метод `ActiveModel::Serializers::JSON#as_json` для временных меток.
    ([Pull Request](https://github.com/rails/rails/pull/31503))

*   Починен валидатор численности, чтобы использовать значение до приведения типов, кроме Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/33654))

*   Починена валидация равенства численности для `BigDecimal` и `Float`, приводя к `BigDecimal` обе стороны валидации.
    ([Pull Request](https://github.com/rails/rails/pull/32852))

*   Починено значение года при приведении многопараметрового хэша времени.
    ([Pull Request](https://github.com/rails/rails/pull/34990))

*   Ложные булевы символы на булевых атрибутах приводятся как false.
    ([Pull Request](https://github.com/rails/rails/pull/35794))

*   Возвращается правильная дата при конвертировании параметров в `value_from_multiparameter_assignment` для `ActiveModel::Type::Date`.
    ([Pull Request](https://github.com/rails/rails/pull/29651))

*   Берется родительская локаль, перед тем как взять пространство имен `:errors` при извлечении переводов ошибки.
    ([Pull Request](https://github.com/rails/rails/pull/35424))

Active Support
--------------

За подробностями обратитесь к [Changelog][active-support].

### Удалено

*   Удален устаревший метод `#acronym_regex` из `Inflections`.
    ([Commit](https://github.com/rails/rails/commit/0ce67d3cd6d1b7b9576b07fecae3dd5b422a5689))

*   Удален устаревший метод `Module#reachable?`.
    ([Commit](https://github.com/rails/rails/commit/6eb1d56a333fd2015610d31793ed6281acd66551))

*   Удален `` Kernel#` `` без каких-либо замен.
    ([Pull Request](https://github.com/rails/rails/pull/31253))

### Устарело

*   Устарело использование отрицательных числовых аргументов для `String#first` и `String#last`.
    ([Pull Request](https://github.com/rails/rails/pull/33058))

*   Устарел `ActiveSupport::Multibyte::Unicode#downcase/upcase/swapcase` в пользу `String#downcase/upcase/swapcase`.
    ([Pull Request](https://github.com/rails/rails/pull/34123))

*   Устарели `ActiveSupport::Multibyte::Unicode#normalize` и `ActiveSupport::Multibyte::Chars#normalize` в пользу `String#unicode_normalize`.
    ([Pull Request](https://github.com/rails/rails/pull/34202))

*   Устарел `ActiveSupport::Multibyte::Chars.consumes?` в пользу `String#is_utf8?`.
    ([Pull Request](https://github.com/rails/rails/pull/34215))

*   Устарели `ActiveSupport::Multibyte::Unicode#pack_graphemes(array)` и `ActiveSupport::Multibyte::Unicode#unpack_graphemes(string)` в пользу `array.flatten.pack("U*")` и `string.scan(/\X/).map(&:codepoints)` соответственно.
    ([Pull Request](https://github.com/rails/rails/pull/34254))

### Значимые изменения

*   Добавлена поддержка параллельного тестирования.
    ([Pull Request](https://github.com/rails/rails/pull/31900))

*   Обеспечивается, что `String#strip_heredoc` сохраняет замороженность строк.
    ([Pull Request](https://github.com/rails/rails/pull/32037))

*   Добавлен `String#truncate_bytes` для обрезания строки до максимального байтового размера без разбивания многобайтовых символов или кластеров графемы.
    ([Pull Request](https://github.com/rails/rails/pull/27319))

*   В метод `delegate` добавлена опция `private`, чтобы делегировать к приватным методам. Эта опция принимает значения `true/false`.
    ([Pull Request](https://github.com/rails/rails/pull/31944))

*   Добавлена поддержка переводов с помощью I18n для `ActiveSupport::Inflector#ordinal` и `ActiveSupport::Inflector#ordinalize`.
    ([Pull Request](https://github.com/rails/rails/pull/32168))

*   В `Date`, `DateTime`, `Time` и `TimeWithZone` добавлены методы `before?` и `after?`.
    ([Pull Request](https://github.com/rails/rails/pull/32185))

*   Починена ошибка, когда `URI.unescape` мог упасть при смешанном Unicode/escaped символьном вводе.
    ([Pull Request](https://github.com/rails/rails/pull/32183))

*   Починена ошибка, когда `ActiveSupport::Cache` мог сильно раздуть размер хранилища, когда включено сжатие.
    ([Pull Request](https://github.com/rails/rails/pull/32539))

*   Хранилище кэша Redis: `delete_matched` больше не блокирует сервер Redis.
    ([Pull Request](https://github.com/rails/rails/pull/32614))

*   Починена ошибка, когда `ActiveSupport::TimeZone.all` мог упасть, когда отсутствовали данные tzinfo для любой временной зоны, определенной в `ActiveSupport::TimeZone::MAPPING`.
    ([Pull Request](https://github.com/rails/rails/pull/32613))

*   Добавлен `Enumerable#index_with`, позволяющий создать хэш из перечисления с помощью значения из переданного блока или аргумента по умолчанию.
    ([Pull Request](https://github.com/rails/rails/pull/32523))

*   Методам `Range#===` и `Range#cover?` разрешено работать с аргументом `Range`.
    ([Pull Request](https://github.com/rails/rails/pull/32938))

*   Поддерживается устаревание ключа в операциях `increment/decrement` в RedisCacheStore.
    ([Pull Request](https://github.com/rails/rails/pull/33254))

*   В события подписчика лога добавлены время cpu, время простоя и особенности аллокаций.
    ([Pull Request](https://github.com/rails/rails/pull/33449))

*   В систему нотификаций Active Support добавлена поддержка объекта события.
    ([Pull Request](https://github.com/rails/rails/pull/33451))

*   Добавлена поддержка для отсутствия кэширования вхождений `nil`, с помощью новой опции `skip_nil` для `ActiveSupport::Cache#fetch`.
    ([Pull Request](https://github.com/rails/rails/pull/25437))

*   Добавлен метод `Array#extract!`, убирающий и возвращающий элементы, для которых блок возвращает истинное значение.
    ([Pull Request](https://github.com/rails/rails/pull/33137))

*   HTML-безопасная строка остается HTML-безопасной после нарезки (slice).
    ([Pull Request](https://github.com/rails/rails/pull/33808))

*   Добавлена поддержка отслеживания автозагрузки констант с помощью логирования.
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   Определен `unfreeze_time` в качестве псевдонима для `travel_back`.
    ([Pull Request](https://github.com/rails/rails/pull/33813))

*   Изменен `ActiveSupport::TaggedLogging.new`, чтобы возвращался экземпляр нового логгера вместо мутации полученного в качестве аргумента.
    ([Pull Request](https://github.com/rails/rails/pull/27792))

*   Методы `#delete_prefix`, `#delete_suffix` и `#unicode_normalize` трактуются не как HTML-безопасные.
    ([Pull Request](https://github.com/rails/rails/pull/33990))

*   Починена ошибка, когда `#without` для `ActiveSupport::HashWithIndifferentAccess` падал с символьными аргументам.
    ([Pull Request](https://github.com/rails/rails/pull/34012))

*   Переименованы `Module#parent`, `Module#parents` и `Module#parent_name` в `module_parent`, `module_parents` и `module_parent_name`.
    ([Pull Request](https://github.com/rails/rails/pull/34051))

*   Добавлен `ActiveSupport::ParameterFilter`.
    ([Pull Request](https://github.com/rails/rails/pull/34039))

*   Починена проблема, когда продолжительность округлялась до полной секунды, когда float добавлялось к продолжительности.
    ([Pull Request](https://github.com/rails/rails/pull/34135))

*   `#to_options` сделан псевдонимом `#symbolize_keys` в `ActiveSupport::HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/34360))

*   БОльше не вызывается ошибка, если тот же самый блок включается несколько раз для Concern.
    ([Pull Request](https://github.com/rails/rails/pull/34553))

*   Сохраняется порядок ключей, переданных в `ActiveSupport::CacheStore#fetch_multi`.
    ([Pull Request](https://github.com/rails/rails/pull/34700))

*   Починен `String#safe_constantize`, чтобы не вызывалась `LoadError` для ссылок на константу в некорректном регистре.
    ([Pull Request](https://github.com/rails/rails/pull/34892))

*   Добавлены `Hash#deep_transform_values` и `Hash#deep_transform_values!`.
    ([Commit](https://github.com/rails/rails/commit/b8dc06b8fdc16874160f61dcf58743fcc10e57db))

*   Добавлен `ActiveSupport::HashWithIndifferentAccess#assoc`.
    ([Pull Request](https://github.com/rails/rails/pull/35080))

*   Добавлен колбэк `before_reset` в `CurrentAttributes` и симметрично определен `after_reset` как псевдоним `resets`.
    ([Pull Request](https://github.com/rails/rails/pull/35063))

*   Пересмотрен `ActiveSupport::Notifications.unsubscribe`, чтобы корректно обрабатывать Regex или другие multiple-pattern подписчики.
    ([Pull Request](https://github.com/rails/rails/pull/32861))

*   Добавлен новый механизм автозагрузки с помощью Zeitwerk.
    ([Commit](https://github.com/rails/rails/commit/e53430fa9af239e21e11548499d814f540d421e5))

*   Добавлены `Array#including` и `Enumerable#including` для удобства увеличения коллекции.
    ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

*   Переименованы `Array#without` и `Enumerable#without` в `Array#excluding` и `Enumerable#excluding`. Старые имена методов оставлены в качестве псевдонимов.
    ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

*   Добавлена поддержка доставления `locale` в `transliterate` и `parameterize`.
    ([Pull Request](https://github.com/rails/rails/pull/35571))

*   Починен `Time#advance` для работы с датами до 1001-03-07.
    ([Pull Request](https://github.com/rails/rails/pull/35659))

*   Обновлен `ActiveSupport::Notifications::Instrumenter#instrument`. чтобы позволить не передавать блок.
    ([Pull Request](https://github.com/rails/rails/pull/35705))

*   В трекере потомков используются слабые ссылки, чтобы позволить анонимным подклассам быть собранным сборщиком мусора.
    ([Pull Request](https://github.com/rails/rails/pull/31442))

*   Вызов тестовых методов с помощью метода `with_info_handler`, чтобы позволить работать плагинам minitest-hooks.
    ([Commit](https://github.com/rails/rails/commit/758ba117a008b6ea2d3b92c53b6a7a8d7ccbca69))

*   Сохраняется статус `html_safe?` на `ActiveSupport::SafeBuffer#*`.
    ([Pull Request](https://github.com/rails/rails/pull/36012))

Active Job
----------

За подробностями обратитесь к [Changelog][active-job].

### Удалено

*   удалена поддержка гема Qu.
    ([Pull Request](https://github.com/rails/rails/pull/32300))

### Устарело

### Значимые изменения

*   Добавлена поддержка пользовательских сериализаторов для аргументов Active Job.
    ([Pull Request](https://github.com/rails/rails/pull/30941))

*   Добавлена поддержка для запуска Active Jobs во временной зоне, в которой они были поставлены в очередь.
    ([Pull Request](https://github.com/rails/rails/pull/32085))

*   Разрешена передача нескольких исключений в `retry_on`/`discard_on`.
    ([Commit](https://github.com/rails/rails/commit/3110caecbebdad7300daaf26bfdff39efda99e25))

*   Разрешен вызов `assert_enqueued_with` и `assert_enqueued_email_with` без блока.
    ([Pull Request](https://github.com/rails/rails/pull/33258))

*   Уведомления для `enqueue` и `enqueue_at` обернуты в колбэк `around_enqueue` вместо колбэка `after_enqueue`.
    ([Pull Request](https://github.com/rails/rails/pull/33171))

*   Разрешен вызов `perform_enqueued_jobs` без блока.
    ([Pull Request](https://github.com/rails/rails/pull/33626))

*   Разрешен вызов `assert_performed_with` без блока.
    ([Pull Request](https://github.com/rails/rails/pull/33635))

*   Добавлена опция `:queue` к хелперам и утверждениям задач.
    ([Pull Request](https://github.com/rails/rails/pull/33635))

*   Добавлены хуки вокруг попыток и отмен Active Job.
    ([Pull Request](https://github.com/rails/rails/pull/33751))

*   Добавлен способ тестирования для набора аргументов при выполнении задач.
    ([Pull Request](https://github.com/rails/rails/pull/33995))

*   В задания, возвращаемых тестовыми хелперами Active Job, включаются десериализованные аргументы.
    ([Pull Request](https://github.com/rails/rails/pull/34204))

*   Хелперам утверждений Active Job разрешается принимать Proc для ключевого слова `only`.
    ([Pull Request](https://github.com/rails/rails/pull/34339))

*   В хелперах утверждений отбрасываются микросекунды и наносекунды из аргументов задачи.
    ([Pull Request](https://github.com/rails/rails/pull/35713))

Руководства Ruby on Rails
-------------------------

За подробностями обратитесь к [Changelog][guides].

### Значимые изменения

*   Добавлено руководство по нескольким базам данных с Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/36389))

*   Добавлен раздел о разрешении проблем автозагрузки констант.
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   Добавлено руководство по основам Action Mailbox.
    ([Pull Request](https://github.com/rails/rails/pull/34812))

*   Добавлено обзорное руководство по Action Text.
    ([Pull Request](https://github.com/rails/rails/pull/34878))

Благодарности
-------------

Взгляните [на полный список контрибьюторов Rails](http://contributors.rubyonrails.org/), на людей, которые потратили много часов, сделав Rails стабильнее и надёжнее. Спасибо им всем.

[railties]:       https://github.com/rails/rails/blob/6-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-0-stable/activerecord/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-0-stable/activestorage/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-0-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-0-stable/activesupport/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-0-stable/activejob/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-0-stable/guides/CHANGELOG.md
