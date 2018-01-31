Заметки о релизе Ruby on Rails 5.2
==================================

Ключевые новинки в Rails 5.2:

* Active Storage
* Хранилище кэша Redis
* Поддержка HTTP/2 Early hints
* Credentials
* Default Content Security Policy

Эти заметки о релизе покрывают только основные изменения. Чтобы узнать о различных багфиксах и изменениях, обратитесь к логам изменений или к [списку коммитов](https://github.com/rails/rails/commits/5-2-stable) в главном репозитории Rails на GitHub.

--------------------------------------------------------------------------------

Апгрейд до Rails 5.2
--------------------

Прежде чем апгрейдить существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 5.2, необходимо сначала произвести апгрейд до Rails 5.1 и убедиться, что приложение все еще выполняется так, как нужно. Список вещей, которые нужно выполнить для апгрейда доступен в руководстве [Апгрейд Ruby on Rails](/upgrading-ruby-on-rails#upgrading-from-rails-5-1-to-rails-5-2).

Основные особенности
--------------------

### Active Storage

[README](https://github.com/rails/rails/blob/d3893ec38ec61282c2598b01a298124356d6b35a/activestorage/README.md)

### Хранилище кэша Redis

[Pull Request](https://github.com/rails/rails/pull/31134)


### Поддержка HTTP/2 Early hints

[Pull Request](https://github.com/rails/rails/pull/30744)


### Credentials

[Pull Request](https://github.com/rails/rails/pull/30067)


### Default Content Security Policy

[Pull Request](https://github.com/rails/rails/pull/31162)

Несовместимости
---------------

ToDo

Railties
--------

За подробностями обратитесь к [Changelog][railties].

### Устарело

*   Устарел метод `capify!` в генераторах и шаблонах.
    ([Pull Request](https://github.com/rails/rails/pull/29493))

*   Устарела передача имени окружения как регулярного аргумента в команды
    `rails dbconsole` и `rails console`.
    ([Pull Request](https://github.com/rails/rails/pull/29358))

*   Устарело использование подкласса `Rails::Application` для старта сервера Rails.
    ([Pull Request](https://github.com/rails/rails/pull/30127))

*   Устарел колбэк `after_bundle` в шаблонах плагинов Rails.
    ([Pull Request](https://github.com/rails/rails/pull/29446))

### Значимые изменения

ToDo

Action Cable
------------

За подробностями обратитесь к [Changelog][action-cable].

### Удалено

*   Удалены устаревшие событийные адаптеры redis.
    ([Commit](https://github.com/rails/rails/commit/48766e32d31))

### Значимые изменения

*   Добавлена поддержка для опций `host`, `port`, `db` и `password` в cable.yml
    ([Pull Request](https://github.com/rails/rails/pull/29528))

*   Добавлена поддержка для совместимости с гемом redis-rb для версии 4.0.
    ([Pull Request](https://github.com/rails/rails/pull/30748))

Action Pack
-----------

За подробностями обратитесь к [Changelog][action-pack].

### Удалено

*   Удалена устаревшая `ActionController::ParamsParser::ParseError`.
    ([Commit](https://github.com/rails/rails/commit/e16c765ac6d))

### Устарело

*   Удалены алиасы `#success?`, `#missing?` и `#error?` в
    `ActionDispatch::TestResponse`.
    ([Pull Request](https://github.com/rails/rails/pull/30104))

### Значимые изменения

ToDo

Action View
-----------

За подробностями обратитесь к [Changelog][action-view].

### Удалено

*   Удален устаревший обработчик ERB Erubis.
    ([Commit](https://github.com/rails/rails/commit/7de7f12fd14))

### Устарело

*   Устарел хелпер `image_alt`, который использовался для добавления дефолтного текста alt
    к изображениям, сгенерированным с помощью `image_tag`.
    ([Pull Request](https://github.com/rails/rails/pull/30213))

### Значимые изменения

ToDo

Action Mailer
-------------

За подробностями обратитесь к [Changelog][action-mailer].

### Значимые изменения

ToDo

Active Record
-------------

За подробностями обратитесь к [Changelog][active-record].

ToDo

### Устарело

ToDo

### Значимые изменения

ToDo

Active Model
------------

За подробностями обратитесь к [Changelog][active-model].

### Удалено

ToDo

### Значимые изменения

ToDo

Active Support
--------------

За подробностями обратитесь к [Changelog][active-support].

### Удалено

ToDo

### Устарело

ToDo

### Значимые изменения

ToDo

Active Job
----------

За подробностями обратитесь к [Changelog][active-job].

### Удалено

ToDo

### Значимые изменения

ToDo

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
