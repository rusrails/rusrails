Заметки о релизе Ruby on Rails 6.1
==================================

Ключевые новинки в Rails 6.1:

Эти заметки о релизе покрывают только основные изменения. Чтобы узнать о других обновлениях, различных исправлениях программных ошибок и изменениях, обратитесь к логам изменений или к [списку коммитов](https://github.com/rails/rails/commits/master) в главном репозитории Rails на GitHub.

--------------------------------------------------------------------------------

Апгрейд до Rails 6.1
--------------------

Прежде чем апгрейднуть существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 6.1, необходимо сначала произвести апгрейд до Rails 6.0 и убедиться, что приложение все еще выполняется так, как нужно. Список вещей, которые нужно выполнить для апгрейда доступен в руководстве [Апгрейд Ruby on Rails](/upgrading-ruby-on-rails#upgrading-from-rails-6-0-to-rails-6-1).

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

*   Убран устаревший `force_ssl` на уровне контроллера.

### Устарело

### Значимые изменения

Action View
-----------

За подробностями обратитесь к [Changelog][action-view].

### Удалено

### Устарело

### Значимые изменения

Action Mailer
-------------

За подробностями обратитесь к [Changelog][action-mailer].

### Удалено

*   Убран устаревший `ActionMailer::Base.receive` в пользу [Action Mailbox](https://github.com/rails/rails/tree/master/actionmailbox).

### Устарело

### Значимые изменения

Active Record
-------------

За подробностями обратитесь к [Changelog][active-record].

### Удалено

### Устарело

### Значимые изменения

Active Storage
--------------

За подробностями обратитесь к [Changelog][active-storage].

### Удалено

### Устарело

*   Устарел `Blob.create_after_upload` в пользу `Blob.create_and_upload`.
    ([Pull Request](https://github.com/rails/rails/pull/34827))

### Значимые изменения

*   Добавлен `Blob.create_and_upload` для создания нового бинарного объекта и загрузки данного `io` в сервис.
    ([Pull Request](https://github.com/rails/rails/pull/34827))

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

### Устарело

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

*   Добавлен метод для подтверждения существования обогащенного текста, добавляя `?` после имени атрибута обогащенного текста.
    ([Pull Request](https://github.com/rails/rails/pull/37951))

*   Добавлен системный тестовый хелпер `fill_in_rich_text_area` для поиска редактора trix и его заполнения заданным содержимым HTML.
    ([Pull Request](https://github.com/rails/rails/pull/35885))

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

Credits
-------

Взгляните [на полный список контрибьюторов Rails](http://contributors.rubyonrails.org/), на людей, которые потратили много часов, сделав Rails стабильнее и надёжнее. Спасибо им всем.

[railties]:       https://github.com/rails/rails/blob/master/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/master/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/master/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/master/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/master/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/master/activerecord/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/master/activestorage/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/master/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/master/activesupport/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/master/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/master/actiontext/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/master/actionmailbox/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/master/guides/CHANGELOG.md
