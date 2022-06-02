Заметки о релизе Ruby on Rails 7.0
==================================

Ключевые новинки в Rails 7.0:

* Требуется Ruby 2.7.0+, предпочтителен Ruby 3.0+

--------------------------------------------------------------------------------

Апгрейд до Rails 7.0
--------------------

Прежде чем апгрейднуть существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 7.0, необходимо сначала произвести апгрейд до Rails 6.1 и убедиться, что приложение все еще выполняется так, как нужно. Список вещей, которые нужно выполнить для апгрейда доступен в руководстве [Апгрейд Ruby on Rails](/upgrading-ruby-on-rails#upgrading-from-rails-6-1-to-rails-7-0).

Основные особенности
--------------------

Railties
--------

За подробностями обратитесь к [Changelog][railties].

### Удалено

*   Удален устаревший `config` в `dbconsole`.

### Устарело

### Значимые изменения

*   Sprockets теперь опциональная зависимость

    Гем `rails` больше не зависим от `sprockets-rails`. Если вашему приложению все еще необходимо использовать Sprockets, убедитесь, что добавили `sprockets-rails` в свой Gemfile.

    ```
    gem "sprockets-rails"
    ```

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

*   Удален устаревший `ActionDispatch::Response.return_only_media_type_on_content_type`.

*   Удален устаревший `Rails.config.action_dispatch.hosts_response_app`.

*   Удален устаревший `ActionDispatch::SystemTestCase#host!`.

*   Удалена устаревшая поддержка передачи пути в `fixture_file_upload` относительно `fixture_path`.

### Устарело

### Значимые изменения

Action View
-----------

За подробностями обратитесь к [Changelog][action-view].

### Удалено

*   Удален устаревший `Rails.config.action_view.raise_on_missing_translations`.

### Устарело

### Значимые изменения

*  `button_to` выводит действие HTTP [метод] из объекта Active Record, если для создания URL использован объект

    ```ruby
    button_to("Do a POST", [:do_post_action, Workshop.find(1)])
    # До
    #=>   <input type="hidden" name="_method" value="post" autocomplete="off" />
    # После
    #=>   <input type="hidden" name="_method" value="patch" autocomplete="off" />
    ```

Action Mailer
-------------

За подробностями обратитесь к [Changelog][action-mailer].

### Удалено

*   Удалены устаревшие `ActionMailer::DeliveryJob` и `ActionMailer::Parameterized::DeliveryJob` в пользу `ActionMailer::MailDeliveryJob`.

### Устарело

### Значимые изменения

Active Record
-------------

За подробностями обратитесь к [Changelog][active-record].

### Удалено

*   Удален устаревший аргумент - ключевое слово `database` из `connected_to`.

*   Удален устаревший `ActiveRecord::Base.allow_unsafe_raw_sql`.

*   Удалена устаревшая опция `:spec_name` в методе `configs_for`.

*   Удалена устаревшая поддержка загрузки YAML экземпляра `ActiveRecord::Base` в форматах Rails 4.2 и 4.1.

*   Удалены предупреждения об устаревании, когда столбец `:interval` используется в базе данных PostgreSQL.

    Теперь интервальные столбцы будут возвращать объекты `ActiveSupport::Duration` вместо строк.

    Чтобы оставить старое поведение, можно добавить эту строчку в вашу модель:

    ```ruby
    attribute :column, :string
    ```

*   Удалена устаревшая поддержка разрешения соединения используя `"primary"` в качестве имени спецификации соединения.

*   Удалена устаревшая поддержка обрамления объектов `ActiveRecord::Base`.

*   Удалена устаревшая поддержка приведения типа к значениям базы данных для объектов `ActiveRecord::Base`.

*   Удалена устаревшая поддержка передачи столбца в `type_cast`.

*   Удален устаревший метод `DatabaseConfig#config`.

*   Удалены устаревшие задачи rake:

    * `db:schema:load_if_ruby`
    * `db:structure:dump`
    * `db:structure:load`
    * `db:structure:load_if_sql`
    * `db:structure:dump:#{name}`
    * `db:structure:load:#{name}`
    * `db:test:load_structure`
    * `db:test:load_structure:#{name}`

*   Удалена устаревшая поддержка в `Model.reorder(nil).first` искать с помощью недетерминированного упорядочивания.

*   Удалены устаревшие аргументы `environment` и `name` из `Tasks::DatabaseTasks.schema_up_to_date?`.

*   Удален устаревший `Tasks::DatabaseTasks.dump_filename`.

*   Удален устаревший `Tasks::DatabaseTasks.schema_file`.

*   Удален устаревший `Tasks::DatabaseTasks.spec`.

*   Удален устаревший `Tasks::DatabaseTasks.current_config`.

*   Удален устаревший `ActiveRecord::Connection#allowed_index_name_length`.

*   Удален устаревший `ActiveRecord::Connection#in_clause_length`.

*   Удален устаревший `ActiveRecord::DatabaseConfigurations::DatabaseConfig#spec_name`.

*   Удален устаревший `ActiveRecord::Base.connection_config`.

*   Удален устаревший `ActiveRecord::Base.arel_attribute`.

*   Удален устаревший `ActiveRecord::Base.configurations.default_hash`.

*   Удален устаревший `ActiveRecord::Base.configurations.to_h`.

*   Удалены устаревшие `ActiveRecord::Result#map!` и `ActiveRecord::Result#collect!`.

*   Удален устаревший `ActiveRecord::Base#remove_connection`.

### Устарело

*   Устарел `Tasks::DatabaseTasks.schema_file_type`.

### Значимые изменения

*   Откат транзакций, когда блок возвращает раньше, чем ожидается.

    До этого изменения, когда блок транзакции возвращал рано, транзакция подтверждалась.

    Проблема в том, что таймауты, вызванные внутри блока транзакции, также приводили к тому, что незавершенная транзакция была подтверждена, поэтому для избежания этой ошибки, блок транзакции будет откачен.

*   Слияние условий на тот же самый столбец больше не поддерживает оба условия, и будет последовательно заменено на более позднее условие.

    ```ruby
    # Rails 6.1 (условие IN заменяется после слияния на равное условие)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    # Rails 6.1 (существуют оба конфликтующих условия, устарело)
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => []
    # Rails 6.1 с rewhere, чтобы мигрировать на поведение 7.0
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob), rewhere: true) # => [bob]
    # Rails 7.0 (то же поведение с условием IN, условие на слияемой части последовательно заменено)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => [bob]
    ```

Active Storage
--------------

За подробностями обратитесь к [Changelog][active-storage].

### Удалено

### Устарело

### Значимые изменения

Active Model
------------

За подробностями обратитесь к [Changelog][active-model].

### Удалено

*   Удален устаревший перебор экземпляров `ActiveModel::Errors` как Hash.

*   Удален устаревший `ActiveModel::Errors#to_h`.

*   Удален устаревший `ActiveModel::Errors#slice!`.

*   Удален устаревший `ActiveModel::Errors#values`.

*   Удален устаревший `ActiveModel::Errors#keys`.

*   Удален устаревший `ActiveModel::Errors#to_xml`.

*   Удалена устаревшая поддержка соединения ошибок в `ActiveModel::Errors#messages`.

*   Удалена устаревшая поддержка `clear` для ошибок из `ActiveModel::Errors#messages`.

*   Удалена устаревшая поддержка `delete` для ошибок из `ActiveModel::Errors#messages`.

*   Удалена устаревшая поддержка использования `[]=` в `ActiveModel::Errors#messages`.

*   Удалена поддержка в загрузке Marshal и YAML формата ошибок Rails 5.x.

*   Удалена поддержка в загрузке Marshal формата Rails 5.x `ActiveModel::AttributeSet`.

### Устарело

### Значимые изменения

Active Support
--------------

За подробностями обратитесь к [Changelog][active-support].

### Удалено

*   Удален устаревший `config.active_support.use_sha1_digests`.

*   Удален устаревший `URI.parser`.

*   Удалена устаревшая поддержка использования `Range#include?` для проверки включения значения в интервал даты/времени.

*   Удален устаревший `ActiveSupport::Multibyte::Unicode.default_normalization_form`.

### Устарело

*   Устарела передача формата в `#to_s` в пользу `#to_fs` в `Array`, `Range`, `Date`, `DateTime`, `Time`, `BigDecimal`, `Float` и `Integer`.

    Это устаревание для того, чтобы позволить приложениям Rails воспользоваться [оптимизацией](https://github.com/ruby/ruby/commit/b08dacfea39ad8da3f1fd7fdd0e4538cc892ec44) Ruby 3.1, которая делает интерполяцию для некоторых типов объектов быстрее.

    Новые приложения не будут иметь переопределенный метод `#to_s` на этих классах, в существующих приложениях можно использовать `config.active_support.disable_to_s_conversion`.

### Значимые изменения

Active Job
----------

За подробностями обратитесь к [Changelog][active-job].

### Удалено

*   Удалено устаревшее поведение, не прерывающее колбэки `after_enqueue`/`after_perform`, когда предыдущий колбэк был прерван с помощью `throw :abort`.

*   Удалена устаревшая опция `:return_false_on_aborted_enqueue`.

### Устарело

*   Устарел `Rails.config.active_job.skip_after_callbacks_if_terminated`.

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

*   Удален устаревший `Rails.application.credentials.action_mailbox.mailgun_api_key`.

*   Удалена устаревшая переменная окружения `MAILGUN_INGRESS_API_KEY`.

### Устарело

### Значимые изменения

Ruby on Rails Guides
--------------------

За подробностями обратитесь к [Changelog][guides].

### Значимые изменения

Благодарности
-------------

Взгляните [на полный список контрибьюторов Rails](http://contributors.rubyonrails.org/), на людей, которые потратили много часов, сделав Rails стабильнее и надёжнее. Спасибо им всем.

[railties]:       https://github.com/rails/rails/blob/7-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/7-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/7-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/7-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/7-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/7-0-stable/activerecord/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/7-0-stable/activestorage/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/7-0-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/7-0-stable/activesupport/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/7-0-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/7-0-stable/actiontext/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/7-0-stable/actionmailbox/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/7-0-stable/guides/CHANGELOG.md
