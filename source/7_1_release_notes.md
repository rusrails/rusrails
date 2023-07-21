Заметки о релизе Ruby on Rails 7.1
==================================

Ключевые новинки в Rails 7.1:

--------------------------------------------------------------------------------

Апгрейд до Rails 7.1
--------------------

Прежде чем апгрейднуть существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 7.1, необходимо сначала произвести апгрейд до Rails 7.0 и убедиться, что приложение все еще выполняется так, как нужно. Список вещей, которые нужно выполнить для апгрейда доступен в руководстве [Апгрейд Ruby on Rails](/upgrading-ruby-on-rails#upgrading-from-rails-7-0-to-rails-7-1).

Основные особенности
--------------------

Railties
--------

За подробностями обратитесь к [Changelog][railties].

### Удалено

### Устарело

### Значимые изменения

Action Cable
------------

За подробностями обратитесь к [Changelog][action-cable].

### Удалено

### Устарело

### Значимые изменения

Action Pack
-----------

За подробностями обратитесь к [Changelog][action-pack].

### Удалено

*   Удалено устаревшее поведение у `Request#content_type`

*   Удалена устаревшая возможность присвоения одиночного значения `config.action_dispatch.trusted_proxies`.

*   Удалена регистрация устаревших драйверов `poltergeist` и `webkit` (capybara-webkit) для системного тестирования.

### Устарело

*   Устарел `config.action_dispatch.return_only_request_media_type_on_content_type`.

*   Устарел `AbstractController::Helpers::MissingHelperError`

*   Устарел `ActionDispatch::IllegalStateError`.

### Значимые изменения

Action View
-----------

За подробностями обратитесь к [Changelog][action-view].

### Удалено

*   Удалена устаревшая константа `ActionView::Path`.

*   Удалена устаревшая поддержка передачи переменных экземпляра как локальных в партиалы.

### Устарело

### Значимые изменения

Action Mailer
-------------

За подробностями обратитесь к [Changelog][action-mailer].

### Удалено

### Устарело

### Значимые изменения

Active Record
-------------

За подробностями обратитесь к [Changelog][active-record].

### Удалено

*   Удалена поддержка `ActiveRecord.legacy_connection_handling`.

*   Удалены устаревшие методы доступа конфигурации `ActiveRecord::Base`

*   Удалена поддержка `:include_replicas` у `configs_for`. Вместо него используйте `:include_hidden`.

*   Удален устаревший `config.active_record.partial_writes`.

*   Удален устаревший `Tasks::DatabaseTasks.schema_file_type`.

### Устарело

### Значимые изменения

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

Active Model
------------

За подробностями обратитесь к [Changelog][active-model].

### Удалено

### Устарело

### Значимые изменения

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

### Значимые изменения

Active Job
----------

За подробностями обратитесь к [Changelog][active-job].

### Удалено

### Устарело

### Значимые изменения

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

Ruby on Rails Guides
--------------------

За подробностями обратитесь к [Changelog][guides].

### Значимые изменения

Благодарности
-------------

Взгляните [на полный список контрибьюторов Rails](http://contributors.rubyonrails.org/), на людей, которые потратили много часов, сделав Rails стабильнее и надёжнее. Спасибо им всем.

[railties]:       https://github.com/rails/rails/blob/main/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/main/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/main/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/main/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/main/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/main/activerecord/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/main/activestorage/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/main/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/main/activesupport/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/main/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/main/actiontext/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/main/actionmailbox/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/main/guides/CHANGELOG.md
