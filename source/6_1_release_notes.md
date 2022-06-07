Заметки о релизе Ruby on Rails 6.1
==================================

Ключевые новинки в Rails 6.1:

* Переключения соединения для отдельной базы данных
* Горизонтальный шардинг
* Строгая загрузка связей
* Делегированные типы
* Асинхронное удаление связей

Эти заметки о релизе покрывают только основные изменения. Чтобы узнать о других обновлениях, различных исправлениях программных ошибок и изменениях, обратитесь к логам изменений или к [списку коммитов](https://github.com/rails/rails/commits/6-1-stable) в главном репозитории Rails на GitHub.

--------------------------------------------------------------------------------

Апгрейд до Rails 6.1
--------------------

Прежде чем апгрейднуть существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 6.1, необходимо сначала произвести апгрейд до Rails 6.0 и убедиться, что приложение все еще выполняется так, как нужно. Список вещей, которые нужно выполнить для апгрейда доступен в руководстве [Апгрейд Ruby on Rails](/upgrading-ruby-on-rails#upgrading-from-rails-6-0-to-rails-6-1).

Основные особенности
--------------------

### Переключения соединения для отдельной базы данных

Rails 6.1 предоставляет вам возможность [переключать соединения для отдельной базы данных](https://github.com/rails/rails/pull/40370). В 6.0, если вы переключались на роль `reading`, то все соединения с базами данных также переключались на читающую роль. Теперь в 6.1 при установленном `legacy_connection_handling` в `false` в конфигурации, Rails позволит переключать соединение для отдельной базы данных с помощью вызова `connected_to` на соответствующем абстрактном классе.

### Горизонтальный шардинг

Rails 6.0 предоставлял возможность функционального разделения (несколько разделов, разные схемы) вашей базы данных, но не был способен поддерживать горизонтальный шардинг (та же схема, несколько разделов). Rails не был способен поддерживать горизонтальный шардинг, так как модели в Active Record могли иметь только одно соединение на роль на класс. Теперь это исправлено и [горизонтальный шардинг](https://github.com/rails/rails/pull/38531) доступен в Rails.

### Strict Loading Associations

[Строгая загрузка связей](https://github.com/rails/rails/pull/37400) позволяет убедиться, что все связи нетерпеливо загружены, что предотвратит дальнейшее выполнение при N+1.

### Делегированные типы

[Делегированные типы](https://github.com/rails/rails/pull/39341) это альтернатива наследованию с одной таблицей. Это помогает представлению иерархий классов, позволяя суперклассу быть конкретным классом, представленным собственной таблицей. У каждого подкласса есть собственная таблица для дополнительных атрибутов.

### Асинхронное удаление связей

[Асинхронное удаление связей](https://github.com/rails/rails/pull/40157) добавляет возможность приложение вызывать `destroy` на связях в фоновом задании. Это может помочь избежать таймаутов и других проблем с производительностью при удалении данных.

Railties
--------

За подробностями обратитесь к [Changelog][railties].

### Удалено

*   Удалены устаревшие задачи `rake notes`.

*   Удалена устаревшая опция `connection` в команде `rails dbconsole`.

*   Из `rails notes` удалена устаревшая поддержка переменной среды `SOURCE_ANNOTATION_DIRECTORIES` .

*   Из команды rails server удален устаревший аргумент `server`.

*   Удалена устаревшая поддержка использования переменной среды `HOST` для указания IP сервера.

*   Удалены устаревшие задачи `rake dev:cache`.

*   Удалены устаревшие задачи `rake routes`.

*   Удалены устаревшие задачи `rake initializers`.

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

*   Удален устаревший `ActionDispatch::Http::ParameterFilter`.

*   Удален устаревший `force_ssl` на уровне контроллера.

### Устарело

*   Устарел `config.action_dispatch.return_only_media_type_on_content_type`.

### Значимые изменения

*   Изменен `ActionDispatch::Response#content_type`, чтобы возвращался полный заголовок Content-Type.

Action View
-----------

За подробностями обратитесь к [Changelog][action-view].

### Удалено

*   Удален устаревший `escape_whitelist` из `ActionView::Template::Handlers::ERB`.

*   Удален устаревший `find_all_anywhere` из `ActionView::Resolver`.

*   Удален устаревший `formats` из `ActionView::Template::HTML`.

*   Удален устаревший `formats` из `ActionView::Template::RawFile`.

*   Удален устаревший `formats` из `ActionView::Template::Text`.

*   Удален устаревший `find_file` из `ActionView::PathSet`.

*   Удален устаревший `rendered_format` из `ActionView::LookupContext`.

*   Удален устаревший `find_file` из `ActionView::ViewPaths`.

*   Удалена устаревшая поддержка передачи объекта, не являющегося `ActionView::LookupContext`, в качестве первого аргумента в `ActionView::Base#initialize`.

*   Удален устаревший аргумент `format` в `ActionView::Base#initialize`.

*   Удален устаревший `ActionView::Template#refresh`.

*   Удален устаревший `ActionView::Template#original_encoding`.

*   Удален устаревший `ActionView::Template#variants`.

*   Удален устаревший `ActionView::Template#formats`.

*   Удален устаревший `ActionView::Template#virtual_path=`.

*   Удален устаревший `ActionView::Template#updated_at`.

*   Удален устаревший аргумент `updated_at`, требуемый в `ActionView::Template#initialize`.

*   Удален устаревший `ActionView::Template.finalize_compiled_template_methods`.

*   Удален устаревший `config.action_view.finalize_compiled_template_methods`

*   Удалена устаревшая поддержка вызова `ActionView::ViewPaths#with_fallback` с блоком.

*   Удалена устаревшая поддержка передачи абсолютных путей в `render template:`.

*   Удалена устаревшая поддержка передачи относительных путей в `render file:`.

*   Удалена поддержка обработчиков шаблона, не принимающих два аргумента.

*   Удален устаревший аргумент шаблона в `ActionView::Template::PathResolver`.

*   Удалена устаревшая поддержка вызова приватных методов объекта в некоторых хелперах вью.

### Устарело

### Значимые изменения

*   Требуется, чтобы подклассы `ActionView::Base` реализовывали `#compiled_method_container`.

*   Аргумент `locals` сделан обязательным в `ActionView::Template#initialize`.

*   Хелперы ассетов `javascript_include_tag` и `stylesheet_link_tag` генерируют заголовок `Link`, подсказывающий современным браузерам о предварительной загрузке ассетов. Это можно отключить, установив `config.action_view.preload_links_header` в `false`.

Action Mailer
-------------

За подробностями обратитесь к [Changelog][action-mailer].

### Удалено

*   Убран устаревший `ActionMailer::Base.receive` в пользу [Action Mailbox](https://github.com/rails/rails/tree/6-1-stable/actionmailbox).

### Устарело

### Значимые изменения

Active Record
-------------

За подробностями обратитесь к [Changelog][active-record].

### Удалено

*   Удалены устаревшие методы из `ActiveRecord::ConnectionAdapters::DatabaseLimits`.

    `column_name_length`
    `table_name_length`
    `columns_per_table`
    `indexes_per_table`
    `columns_per_multicolumn_index`
    `sql_query_length`
    `joins_per_query`

*   Удален устаревший `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_multi_insert?`.

*   Удален устаревший `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_foreign_keys_in_create?`.

*   Удален устаревший `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#supports_ranges?`.

*   Удалены устаревшие `ActiveRecord::Base#update_attributes` и `ActiveRecord::Base#update_attributes!`.

*   Удален устаревший аргумент `migrations_path` в `ActiveRecord::ConnectionAdapter::SchemaStatements#assume_migrated_upto_version`.

*   Удален устаревший `config.active_record.sqlite3.represent_boolean_as_integer`.

*   Удалены устаревшие методы из `ActiveRecord::DatabaseConfigurations`.

    `fetch`
    `each`
    `first`
    `values`
    `[]=`

*   Удален устаревший метод `ActiveRecord::Result#to_hash`.

*   Удалена устаревшая поддержка использования небезопасного необработанного SQL в методах `ActiveRecord::Relation`.

### Устарело

*   Устарел `ActiveRecord::Base.allow_unsafe_raw_sql`.

*   Устарело ключевое слово `database` в `connected_to`.

*   Устарел `connection_handlers`, когда `legacy_connection_handling` установлен false.

### Значимые изменения

*   MySQL: Валидатор уникальности теперь учитывает сопоставление (collation) базы данных по умолчанию, больше не принуждает к чувствительному к регистру сравнению по умолчанию.

*   Из `relation.create` больше не утекает скоуп в методы запроса уровня класса в блоках инициализации и колбэках.

    До:

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => nil
    end
    ```

    После:

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => #<User name: "David", ...>
    end
    ```

*   Из цепочки именованных скоупов больше не утекает скоуп в методы запроса уровня класса.

    ```ruby
    class User < ActiveRecord::Base
      scope :david, -> { User.where(name: "David") }
    end
    ```

    До:

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'John' AND name = 'David'
    ```

    После:

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'David'
    ```

*   `where.not` теперь генерирует предикаты NAND вместо NOR.

    До:

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE name != 'Jon' AND role != 'admin'
    ```

    После:

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE NOT (name == 'Jon' AND role == 'admin')
    ```

*   Чтобы использовать новые соединения для отдельной базы данных, в приложении нужно изменить `legacy_connection_handling` на false и удалить устаревшие методы доступа на `connection_handlers`. Публичные методы для `connects_to` и `connected_to` менять не нужно.


Active Storage
--------------

За подробностями обратитесь к [Changelog][active-storage].

### Удалено

*   Удалена устаревшая поддержка передачи операций `:combine_options` в `ActiveStorage::Transformers::ImageProcessing`.

*   Удален устаревший `ActiveStorage::Transformers::MiniMagickTransformer`.

*   Удален устаревший `config.active_storage.queue`.

*   Удален устаревший `ActiveStorage::Downloading`.

### Устарело

*   Устарел `Blob.create_after_upload` в пользу `Blob.create_and_upload`.
    ([Pull Request](https://github.com/rails/rails/pull/34827))

### Значимые изменения

*   Добавлен `Blob.create_and_upload` для создания нового бинарного объекта и загрузки данного `io` в сервис.
    ([Pull Request](https://github.com/rails/rails/pull/34827))

*   Был добавлен столбец `ActiveStorage::Blob#service_name`. Требуется запустить миграцию после апгрейда. Запустите `bin/rails app:update`, чтобы сгенерировать эту миграцию.

Active Model
------------

За подробностями обратитесь к [Changelog][active-model].

### Удалено

### Устарело

### Значимые изменения

*   Ошибки Active Model теперь объекты с интерфейсом, позволяющим вашему приложению проще обрабатывать и взаимодействовать с ошибками, выбрасываемыми моделями. [Эта особенность](https://github.com/rails/rails/pull/32313) включает интерфейс запросов, включает более аккуратное тестирование и доступ к подробностям об ошибке.

Active Support
--------------

За подробностями обратитесь к [Changelog][active-support].

### Удалено

*   Удален устаревший фолбэк к `I18n.default_locale`, когда `config.i18n.fallbacks` пустой.

*   Удалена устаревшая константа `LoggerSilence`.

*   Удален устаревший `ActiveSupport::LoggerThreadSafeLevel#after_initialize`.

*   Удалены устаревшие `Module#parent_name`, `Module#parent` и `Module#parents`.

*   Удален устаревший файл `active_support/core_ext/module/reachable`.

*   Удален устаревший файл `active_support/core_ext/numeric/inquiry`.

*   Удален устаревший файл `active_support/core_ext/array/prepend_and_append`.

*   Удален устаревший файл `active_support/core_ext/hash/compact`.

*   Удален устаревший файл `active_support/core_ext/hash/transform_values`.

*   Удален устаревший файл `active_support/core_ext/range/include_range`.

*   Удалены устаревшие `ActiveSupport::Multibyte::Chars#consumes?` и `ActiveSupport::Multibyte::Chars#normalize`.

*   Удалены устаревшие `ActiveSupport::Multibyte::Unicode.pack_graphemes`, `ActiveSupport::Multibyte::Unicode.unpack_graphemes`, `ActiveSupport::Multibyte::Unicode.normalize`, `ActiveSupport::Multibyte::Unicode.downcase`, `ActiveSupport::Multibyte::Unicode.upcase` и `ActiveSupport::Multibyte::Unicode.swapcase`.

*   Удален устаревший `ActiveSupport::Notifications::Instrumenter#end=`.

### Устарело

*   Устарел `ActiveSupport::Multibyte::Unicode.default_normalization_form`.

### Значимые изменения

Active Job
----------

За подробностями обратитесь к [Changelog][active-job].

### Удалено

### Устарело

*   Устарел `config.active_job.return_false_on_aborted_enqueue`.

### Значимые изменения

*   Возвращается `false`, когда постановка задания в очередь прерывается.

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

*   Добавлен `ActionText::FixtureSet.attachment` для генерации элементов `<action-text-attachment>` в фикстурах базы данных.
    ([Pull Request](https://github.com/rails/rails/pull/40289))

Action Mailbox
----------

За подробностями обратитесь к [Changelog][action-mailbox].

### Удалено

### Устарело

*   Устарели `Rails.application.credentials.action_mailbox.api_key` и `MAILGUN_INGRESS_API_KEY` в пользу `Rails.application.credentials.action_mailbox.signing_key` и `MAILGUN_INGRESS_SIGNING_KEY`.

### Значимые изменения

Ruby on Rails Guides
--------------------

За подробностями обратитесь к [Changelog][guides].

### Значимые изменения

Благодарности
-------------

Взгляните [на полный список контрибьюторов Rails](http://contributors.rubyonrails.org/), на людей, которые потратили много часов, сделав Rails стабильнее и надёжнее. Спасибо им всем.

[railties]:       https://github.com/rails/rails/blob/6-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-1-stable/activerecord/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-1-stable/activestorage/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-1-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-1-stable/activesupport/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-1-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/6-1-stable/actiontext/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/6-1-stable/actionmailbox/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-1-stable/guides/CHANGELOG.md
