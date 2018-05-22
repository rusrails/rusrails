Заметки о релизе Ruby on Rails 4.1
==================================

Ключевые новинки в Rails 4.1:

* Spring прелоадер
* `config/secrets.yml`
* Action Pack Variants (шаблоны, для разных устройств)
* Предпросмотр писем Action Mailer

Эти заметки о релизе покрывают только основные изменения. Чтобы узнать о различных исправлениях программных ошибок и изменениях, обратитесь к логам изменений или к [списку коммитов](https://github.com/rails/rails/commits/4-1-stable) в главном репозитории Rails на GitHub.

--------------------------------------------------------------------------------

Апгрейд до Rails 4.1
--------------------

Прежде чем апгрейдить существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 4.1, необходимо сначала произвести апгрейд до Rails 4.0 и убедиться, что приложение все еще выполняется так, как нужно.
Список вещей, которые нужно выполнить для апгрейда доступен в руководстве
[Апгрейд Ruby on Rails](/upgrading-ruby-on-rails#upgrading-from-rails-4-0-to-rails-4-1).

Основные особенности
--------------------

### Spring Application Preloader

Spring является прелоадером для Rails приложений. Он увеличивает скорость разработки, храня приложение запущенным в фоновом режиме, поэтому при запуске тестов, задач rake или миграций, теперь загружать приложение каждый раз больше нет необходимости.

Новое Rails 4.1 приложение будет по умолчанию идти с "springified" бинстабами. Это означает, что
`bin/rails` и `bin/rake`, будут автоматически использовать преимущества предзагруженной среды spring.

**Запуск rake задач:**

```
bin/rake test:models
```

**Запуск Rails команд:**

```
bin/rails console
```

**Spring интроспекция:**

```
$ bin/spring status
Spring is running:

 1182 spring server | my_app | started 29 mins ago
 3656 spring app    | my_app | started 23 secs ago | test mode
 3746 spring app    | my_app | started 10 secs ago | development mode
```

Обратитесь к [Spring README](https://github.com/jonleighton/spring/blob/master/README.md),
чтобы увидеть все возможности.

Обратитесь к руководству [Апгрейд Ruby on Rails](/upgrading-ruby-on-rails#spring)
- как мигрировать существующее приложение, чтобы использовать данную возможность.

### `config/secrets.yml`

Rails 4.1 генерирует новый файл `secrets.yml` в директории `config`. По умолчанию,
этот файл содержит `secret_key_base` приложения, но он так же может использоваться
для хранения других секретов, таких как ключи доступа к внешним API.

Секреты, добавляемые в этот файл, будут доступны с помощью `Rails.application.secrets`.
Например, для `config/secrets.yml`:

```yaml
development:
  secret_key_base: 3b7cd727ee24e8444053437c36cc66c3
  some_api_key: SOMEKEY
```

`Rails.application.secrets.some_api_key` вернёт `SOMEKEY` в development окружении.

Обратитесь к руководству [Апгрейд Ruby on Rails](/upgrading-ruby-on-rails#config-secrets-yml)
- как мигрировать существующее приложение, чтобы использовать данную возможность.

### Action Pack Variants

Мы часто хотим рендерить разные типы шаблонов HTML/JSON/XML для телефонов,
планшетов и десктопных браузеров. С помощью Variants - это легко.

Запрос Variants - это специальный формат запроса, например `:tablet`,
`:phone`, или `:desktop`.

Вы можете установить вариант шаблона в `before_action`:

```ruby
request.variant = :tablet if request.user_agent =~ /iPad/
```

Отклик на варианты в экшне похож на отклик на форматы:

```ruby
respond_to do |format|
  format.html do |html|
    html.tablet # renders app/views/projects/show.html+tablet.erb
    html.phone { extra_setup; render ... }
  end
end
```

Создайте отдельные шаблоны для каждого формата и варианта шаблона:

```
app/views/projects/show.html.erb
app/views/projects/show.html+tablet.erb
app/views/projects/show.html+phone.erb
```

Также можно упростить определение вариантов с помощью строчного синтаксиса:

```ruby
respond_to do |format|
  format.js         { render "trash" }
  format.html.phone { redirect_to progress_path }
  format.html.none  { render "trash" }
end
```

### Предпросмотр писем Action Mailer

Предпросмотр писем Action Mailer, это возможность увидеть как будет выглядеть email,
посетив специальный URL адрес, который покажет ваше письмо.

Вы реализуете класс, методы которого возвращают email объект,
который необходимо проверить:

```ruby
class NotifierPreview < ActionMailer::Preview
  def welcome
    Notifier.welcome(User.first)
  end
end
```

Предпросмотр данного письма доступен по адресу http://localhost:3000/rails/mailers/notifier/welcome,
так же можно увидеть полный список писем - http://localhost:3000/rails/mailers.

По умолчанию, эти превью-классы располагаются в `test/mailers/previews`.
Директорию можно легко изменить используя опцию `preview_path`.

Обратитесь к [документации](http://api.rubyonrails.org/v4.1.0/classes/ActionMailer/Base.html)
за подробным описанием.

### Enum поля в Active Record

Объявляйте в базе данных enum поле, в котором числа связываются со значениями,
но могут быть запрошены по имени

```ruby
class Conversation < ActiveRecord::Base
  enum status: [ :active, :archived ]
end

conversation.archived!
conversation.active? # => false
conversation.status  # => "archived"

Conversation.archived # => Связь для всех архивированных бесед

Conversation.statuses # => { "active" => 0, "archived" => 1 }

```

Обратитесь к [документации](http://api.rubyonrails.org/v4.1.0/classes/ActiveRecord/Enum.html)
за подробным описанием.

### Message Verifiers

Message verifiers могут быть использованы для генерации и верификации подписанных сообщений.
Это полезно для безопасной передачи чувствительных данных, таких как токены remember-me и прочие подобные.

Метод `Rails.application.message_verifier` возвращает новый Message Verifier, который подписывает сообщения с помощью ключа, созданного из secret_key_base и имени верификационного сообщения:

```ruby
signed_token = Rails.application.message_verifier(:remember_me).generate(token)
Rails.application.message_verifier(:remember_me).verify(signed_token) # => token

Rails.application.message_verifier(:remember_me).verify(tampered_token)
# raises ActiveSupport::MessageVerifier::InvalidSignature
```

### Module#concerning

Естественный и быстрый способ разделить ответственность внутри класса:

```ruby
class Todo < ActiveRecord::Base
  concerning :EventTracking do
    included do
      has_many :events
    end

    def latest_event
      ...
    end

    private
      def some_internal_method
        ...
      end
  end
end
```

Этот пример является эквивалентом определения модуля `EventTracking` внутри класса,
расширение его `ActiveSupport::Concern`, и дальнейшего смешивания его с классом
`Todo`.

Обратитесь к [документации](http://api.rubyonrails.org/v4.1.0/classes/Module/Concerning.html)
за подробным описанием и способами использования.

### CSRF защита от `<script>` тегов

Защита от межсайтовой подделки запроса (CSRF) сейчас также покрывает GET-запросы с откликами JavaScript. Это предотвращает от ссылок сторонних сайтов на ваши JavaScript URL и попыток запуска его для извлечения чувствительных данных.

Это означает, что каждый из ваших тестов, который использует `.js` URL, теперь будет провален CSRF защитой, если не используется `xhr`. Произведите апгрейд тестов, чтобы быть уверенными в XmlHttpRequests. Вместо `post :create, format: :js`, переключитесь на явное
`xhr :post, :create, format: :js`.

Railties
--------

Пожалуйста, обратитесь к
[Changelog](https://github.com/rails/rails/blob/4-1-stable/railties/CHANGELOG.md)
для просмотра всех изменений.

### Удалено

* Удалёна задача rake `update:application_controller`.

* Удалён устаревший `Rails.application.railties.engines`.

* Удалён устаревший `threadsafe!` из конфигурации Rails.

* Удалён устаревший метод `ActiveRecord::Generators::ActiveModel#update_attributes` в пользу `ActiveRecord::Generators::ActiveModel#update`.

* Удалёна устаревшая опция `config.whiny_nils`.

* Удалёны устаревшая задача rake для запуска тестов: `rake test:uncommitted` и
  `rake test:recent`.

### Значимые изменения

* [Spring прелоадер](https://github.com/rails/spring) теперь устанавливается по умолчанию
  для новых приложений. Он использует группу development в `Gemfile`, поэтому не будет установлен в
  production. ([Pull Request](https://github.com/rails/rails/pull/12958))

* Переменная окружения `BACKTRACE`, которая показывает нефильтрованные бэктрейсы для проваленных тестов.
  ([Commit](https://github.com/rails/rails/commit/84eac5dab8b0fe9ee20b51250e52ad7bfea36553))

* Возможность конфигурирования `MiddlewareStack#unshift`.
  ([Pull Request](https://github.com/rails/rails/pull/12479))

* Добавлен метод `Application#message_verifier` которы возвращает верификационное
  сообщение. ([Pull Request](https://github.com/rails/rails/pull/12995))

* Файл `test_help.rb`, который требуется сгенерированным по умолчанию тестом, автоматически сохраняет тестовую базу данных актуальной `db/schema.rb` (или `db/structure.sql`). Он вызывает ошибку, если перезагрузка схемы не решает проблемы отложенных миграций. Настраивается с помощью опции `config.active_record.maintain_test_schema = false`. ([Pull Request](https://github.com/rails/rails/pull/13528))

Action Pack
-----------

Пожалуйста обратитесь к
[Changelog](https://github.com/rails/rails/blob/4-1-stable/actionpack/CHANGELOG.md)
для просмотра всех изменений.

### Удалено

* Удалён устаревший Rails fallback для интеграционных тестов, используйте `ActionDispatch.test_app`.

* Удалена устаревшая конфигурация `page_cache_extension`.

* Удалён устаревший `ActionController::RecordIdentifier`, используйте вместо него
  `ActionView::RecordIdentifier`.

* Удалены устаревшие константы из Action Controller:

| Удалено                            | Преемник                        |
| -----------------------------------| --------------------------------|
| ActionController::AbstractRequest  | ActionDispatch::Request         |
| ActionController::Request          | ActionDispatch::Request         |
| ActionController::AbstractResponse | ActionDispatch::Response        |
| ActionController::Response         | ActionDispatch::Response        |
| ActionController::Routing          | ActionDispatch::Routing         |
| ActionController::Integration      | ActionDispatch::Integration     |
| ActionController::IntegrationTest  | ActionDispatch::IntegrationTest |

### Значимые изменения

* `protect_from_forgery` также предотвращает от CSRF атак, проводимых через `<script>` теги.
  Обновите ваши тесты и используйте `xhr :get, :foo, format: :js` вместо
  `get :foo, format: :js`.
  ([Pull Request](https://github.com/rails/rails/pull/13345))

* `#url_for` принимает хэш с опциями внутри массива.
  ([Pull Request](https://github.com/rails/rails/pull/9599))

* Добавлен метод `session#fetch` который ведёт себя аналогично
  [Hash#fetch](http://www.ruby-doc.org/core-1.9.3/Hash.html#method-i-fetch),
  за исключением того, что возвращаемое значение всегда сохраняется в сессию.
  ([Pull Request](https://github.com/rails/rails/pull/12692))

* Полностью отделён Action View от Action Pack.
  ([Pull Request](https://github.com/rails/rails/pull/11032))

* Логируется, какие ключи были затронуты при "deep munging". ([Pull Request](https://github.com/rails/rails/pull/13813))

* Новая конфигурационная опция `config.action_dispatch.perform_deep_munge` для включения "deep munging" параметров, использующегося в связи с уязвимостью безопасности CVE-2013-0155. ([Pull Request](https://github.com/rails/rails/pull/13188))

* Новая конфигурационная опция `config.action_dispatch.cookies_serializer` для определения сериализатора для подписанных и зашифрованных куки. (Pull Requests [1](https://github.com/rails/rails/pull/13692), [2](https://github.com/rails/rails/pull/13945) / [Подробнее](/upgrading-ruby-on-rails#cookies-serializer))

* Добавлены `render :plain`, `render :html` и `render :body`. ([Pull Request](https://github.com/rails/rails/pull/14062) /
  [Подробнее](/upgrading-ruby-on-rails#rendering-content-from-string))

Action Mailer
-------------

Пожалуйста обратитесь к
[Changelog](https://github.com/rails/rails/blob/4-1-stable/actionmailer/CHANGELOG.md)
для просмотра всех изменений.

### Значимые изменения

* Добавлена особенность предварительного просмотра писем на основе гема mail_view от 37 Signals. ([Commit](https://github.com/rails/rails/commit/d6dec7fcb6b8fddf8c170182d4fe64ecfc7b2261))

* Инструмент генерации сообщений Action Mailer. Время, потраченное на генерацию сообщения,
  записывается в лог. ([Pull Request](https://github.com/rails/rails/pull/12556))

Active Record
-------------

Пожалуйста обратитесь к
[Changelog](https://github.com/rails/rails/blob/4-1-stable/activerecord/CHANGELOG.md)
для просмотра всех изменений.

### Удалено

* Удалена устаревшая возможность передачи nil следующим методам `SchemaCache`:
  `primary_keys`, `tables`, `columns` и `columns_hash`.

* Удалён устаревший блок фильтр из `ActiveRecord::Migrator#migrate`.

* Удалён устаревший конструктор строк из `ActiveRecord::Migrator`.

* Удалёно устаревшее использование `scope` без передачи вызываемого объекта.

* Удалён устаревший метод `transaction_joinable=` в пользу `begin_transaction`
  с опцией `:joinable`.

* Удалён устаревший метод `decrement_open_transactions`.

* Удалён устаревший метод `increment_open_transactions`.

* Удалён устаревший метод `PostgreSQLAdapter#outside_transaction?`.
  Вместо него вы можете использовать `#transaction_open?`.

* Удалён устаревший метод `ActiveRecord::Fixtures.find_table_name` в пользу
  `ActiveRecord::Fixtures.default_fixture_model_name`.

* Удален устаревший метод `columns_for_remove` из `SchemaStatements`.

* Удалён устаревший `SchemaStatements#distinct`.

* Перемещён устаревший `ActiveRecord::TestCase` в тестовый набор Rails. Данный класс больше не публичный и используется только для внутреннего тестирования Rails.

* Удалена поддержка устаревшей опции `:restrict` для `:dependent`
  в ассоциациях.

* Удалена поддержка устаревших опций `:delete_sql`, `:insert_sql`, `:finder_sql`
  и `:counter_sql` в ассоциациях.

* Удален устаревший метод `type_cast_code` из ActiveRecord::ConnectionAdapters::Column.

* Удален устаревший метод `ActiveRecord::Base#connection`.
  Убедитесь, что вы обращаетесь к соединению через класс.

* Удалены устаревшие предупреждения `auto_explain_threshold_in_seconds`.

* Удалена устаревшая опция `:distinct` из `Relation#count`.

* Удалены устаревшие методы `partial_updates`, `partial_updates?` и
  `partial_updates=`.

* Удален устаревший метод `scoped`.

* Удален устаревший метод `default_scopes?`.

* Удалено неявное соединение связей, которое были объявлено устаревшим в 4.0.

* Удален из зависимостей гем `activerecord-deprecated_finders`. За подробностями обратитесь [в README гема](https://github.com/rails/activerecord-deprecated_finders#active-record-deprecated-finders).

* `implicit_readonly` больше не используется. Пожалуйста, используйте метод `readonly` для явной пометки записи как
  `readonly`. ([Pull Request](https://github.com/rails/rails/pull/10769))

### Устарело

* Устарел неиспользуемый метод `quoted_locking_column`.

* Устарел метод `ConnectionAdapters::SchemaStatements#distinct`,
  так как больше не используется внутри Rails. ([Pull Request](https://github.com/rails/rails/pull/10556))

* Устарели задачи `rake db:test:*`, так как теперь тестовая база данных автоматически поддерживается. Смотрите заметки о релизе к railties. ([Pull
  Request](https://github.com/rails/rails/pull/13528))

* Устарели неиспользуемые `ActiveRecord::Base.symbolized_base_class` и `ActiveRecord::Base.symbolized_sti_name` без какой-либо замены. [Commit](https://github.com/rails/rails/commit/97e7ca48c139ea5cce2fa9b4be631946252a1ebd)

### Значимые изменения

* Скоупы по умолчанию больше не переопределяются присоединенными условиями.

  До этого изменения, при определении в модели `default_scope`, он переопределялся присоединенными условиями на то же поле. Теперь он объединяется, как и любой другой скоуп. [Подробнее](/upgrading-ruby-on-rails#changes-on-default-scopes).

* Добавлен метод `ActiveRecord::Base.to_param` для удобного создания "красивых" URL, используя
  атрибуты или методы модели.
  ([Pull Request](https://github.com/rails/rails/pull/12891))

* Добавлена опция `ActiveRecord::Base.no_touching`, которая позволяет игнорировать "touch"
  на модели. ([Pull Request](https://github.com/rails/rails/pull/12772))

* Унификация преобразования булевых типов для `MysqlAdapter` и `Mysql2Adapter`.
  `type_cast` вернёт `1` для `true` и `0` для `false`. ([Pull Request](https://github.com/rails/rails/pull/12425))

* `.unscope` теперь удаляет условия, определённые в скоупе по умолчанию
  `default_scope`. ([Commit](https://github.com/rails/rails/commit/94924dc32baf78f13e289172534c2e71c9c8cade))

* Добавлен метод `ActiveRecord::QueryMethods#rewhere`, который перезаписывает существующее условие where,
  использовавшееся ранее в цепочке запросов. ([Commit](https://github.com/rails/rails/commit/f950b2699f97749ef706c6939a84dfc85f0b05f2))

* Расширен метод `ActiveRecord::Base#cache_key`, который теперь принимает опциональный список timestamp
  атрибутов, из которых будет использоваться самое больше. ([Commit](https://github.com/rails/rails/commit/e94e97ca796c0759d8fcb8f946a3bbc60252d329))

* Добавлен `ActiveRecord::Base#enum` для описания enum атрибутов, в которых значения связаны с числами в базе данных, но могут быть запрошены с помощью имени. ([Commit](https://github.com/rails/rails/commit/db41eb8a6ea88b854bf5cd11070ea4245e1639c5))

* Приведение типов для значений json при записи, таким образом значение не изменится при чтении из базы данных. ([Pull Request](https://github.com/rails/rails/pull/12643))

* Приведение типов для значений hstore при записи, таким образом значение не изменится при чтении из базы данных. ([Commit](https://github.com/rails/rails/commit/5ac2341fab689344991b2a4817bd2bc8b3edac9d))

* Стало возможным использование `next_migration_number` для сторонних
  генераторов. ([Pull Request](https://github.com/rails/rails/pull/12407))

* Вызов `update_attributes` теперь бросает исключение `ArgumentError`, когда
  получит аргумент `nil`. Более конкретно - будет ошибка, если передаваемый аргумент
  не отвечает на `stringify_keys`. ([Pull Request](https://github.com/rails/rails/pull/9860))

* `CollectionAssociation#first`/`#last` (например `has_many`) ограничивает
  результат запроса оператором `LIMIT` в запросе на выборку, вместо загрузки полной коллекции.
  ([Pull Request](https://github.com/rails/rails/pull/12137))

* Метод `inspect` вызываемый на моделях Active Record не инициализирует нового
  подключения. Это означает, что вызов `inspect` больше не вызывает исключения, когда база данных
  отсутствует. ([Pull Request](https://github.com/rails/rails/pull/11014))

* Удалено ограничение столбцов для `count`, позволив базе данных вызвать исключение, если SQL
  не валидный. ([Pull Request](https://github.com/rails/rails/pull/10710))

* Rails теперь автоматически определяет противоположные связи. Если вы не установили опцию
  `:inverse_of`, Active Record самостоятельно определит противоположную связь, основываясь на эвристике.
  ([Pull Request](https://github.com/rails/rails/pull/10886))

* Обработка псевдоним-атрибутов в ActiveRecord::Relation. При использовании символьных ключей ActiveRecord теперь переведет имена псевдоним-атрибутов к фактическим именам столбцов, используемых в базе данных. ([Pull Request](https://github.com/rails/rails/pull/7839))

* Шаблоны ERB в фикстурах больше не вычисляются в контексте главного объекта.
  Методы хелперов, использующиеся в нескольких фикстурах, должны объявляться в модулях, включённых в `ActiveRecord::FixtureSet.context_class`. ([Pull Request](https://github.com/rails/rails/pull/13022))

* Не создается или сбрасывается тестовая база данных, если явно определен RAILS_ENV. ([Pull Request](https://github.com/rails/rails/pull/13629))

* У `Relation` больше нет мутирующих методов (мутаторов), таких как `#map!` и `#delete_if`. Преобразовывайте в массив с помощью `#to_a` перед использованием этих методов. ([Pull Request](https://github.com/rails/rails/pull/13314))

* `find_in_batches`, `find_each`, `Result#each` и `Enumerable#index_by` теперь возвращают `Enumerator`, который может вычислять свой размер. ([Pull Request](https://github.com/rails/rails/pull/13938))

* `scope`, `enum` и связи теперь вызовут ошибку при "опасном" конфликте имен. ([Pull Request](https://github.com/rails/rails/pull/13450),
  [Pull Request](https://github.com/rails/rails/pull/13896))

* Методы с `second` по `fifth`работают так же, как метод поиска `first`. ([Pull Request](https://github.com/rails/rails/pull/13757))

* Метод `touch` вызывает колбэки `after_commit` и `after_rollback`. ([Pull Request](https://github.com/rails/rails/pull/12031))

* Доступны частичные индексы для `sqlite >= 3.8.0`. ([Pull Request](https://github.com/rails/rails/pull/13350))

* Миграция `change_column_null` стала обратимой. ([Commit](https://github.com/rails/rails/commit/724509a9d5322ff502aefa90dd282ba33a281a96))

* Добавлен флажок для отключения выгрузки схемы после миграции. Он установлен `false` по умолчанию в среде production для новых приложений. ([Pull Request](https://github.com/rails/rails/pull/13948))

Active Model
------------

Пожалуйста обратитесь к
[Changelog](https://github.com/rails/rails/blob/4-1-stable/activemodel/CHANGELOG.md)
для просмотра всех изменений.

### Устарело

* Устарел `Validator#setup`. Теперь необходимые настройки устанавливаются вручную в конструкторе валидатора. ([Commit](https://github.com/rails/rails/commit/7d84c3a2f7ede0e8d04540e9c0640de7378e9b3a))

### Значимые изменения

* В `ActiveModel::Dirty` добавлены новые методы API `reset_changes` и `changes_applied`, которые контролируют изменения состояния.

* Возможность определить несколько контекстов при определении валидации. ([Pull Request](https://github.com/rails/rails/pull/13754))

* Теперь `attribute_changed?` принимает хэш для проверки, изменился ли атрибут `:from` и/или `:to` заданного значения. ([Pull Request](https://github.com/rails/rails/pull/13131))


Active Support
--------------

Пожалуйста обратитесь к
[Changelog](https://github.com/rails/rails/blob/4-1-stable/activesupport/CHANGELOG.md)
для просмотра всех изменений.


### Удалено

* Удалена зависимость `MultiJSON`. Теперь, `ActiveSupport::JSON.decode`
  больше не принимает хэш опций для `MultiJSON`. ([Pull Request](https://github.com/rails/rails/pull/10576) / [Подробнее](/upgrading-ruby-on-rails#changes-in-json-handling))

* Удалена поддержка для хука `encode_json`, используемого для преобразования произвольных объектов в JSON. Данная функциональность извлечена в гем [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder).
  ([Связанный Pull Request](https://github.com/rails/rails/pull/12183) /
  [Подробнее](/upgrading-ruby-on-rails#changes-in-json-handling))

* Удалено без замены `ActiveSupport::JSON::Variable`.

* Удалено устаревшее расширение ядра `String#encoding_aware?` (`core_ext/string/encoding`).

* Удалён устаревший метод `Module#local_constant_names` в пользу `Module#local_constants`.

* Удалён устаревший метод `DateTime.local_offset` в пользу `DateTime.civil_from_format`.

* Удалено устаревшее расширение ядра `Logger` (`core_ext/logger.rb`).

* Удалены устаревшие методы `Time#time_with_datetime_fallback`, `Time#utc_time` и
  `Time#local_time` в пользу `Time#utc` и `Time#local`.

* Удалён устаревший метод `Hash#diff` без замены.

* Удалён устаревший метод `Date#to_time_in_current_zone` в пользу `Date#in_time_zone`.

* Удалён устаревший метод `Proc#bind` без замены.

* Удалены устаревшие методы `Array#uniq_by` и `Array#uniq_by!`, используйте нативные методы класса
  `Array#uniq` и `Array#uniq!`.

* Удалён устаревший `ActiveSupport::BasicObject`, используйте
  `ActiveSupport::ProxyObject` взамен.

* Удалён устаревший `BufferedLogger`, используйте `ActiveSupport::Logger` взамен.

* Удалены устаревшие методы `assert_present` и `assert_blank`, используйте `assert
  object.blank?` и `assert object.present?` взамен.

* Удалён устаревший метод `#filter` для объектов фильтра, используйте взамен соответствующие методы (т.е. `#before` для предварительного фильтра).

* Убран нерегулярный инфлектор 'cow' => 'kine' из инфлектора по умолчанию. ([Commit](https://github.com/rails/rails/commit/c300dca9963bda78b8f358dbcb59cabcdc5e1dc9))

### Устарело

* Устарели `Numeric#{ago,until,since,from_now}`, пользователь должен явно
  преобразовывать значение в AS::Duration, например. `5.ago` => `5.seconds.ago`
  ([Pull Request](https://github.com/rails/rails/pull/12389))

* Устарело имя подключаемой директории `active_support/core_ext/object/to_json`. Подключайте
  `active_support/core_ext/object/json` взамен. ([Pull Request](https://github.com/rails/rails/pull/12203))

* Устарело `ActiveSupport::JSON::Encoding::CircularReferenceError`. Данная функциональность
  была выделена в гем [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder).
  ([Pull Request](https://github.com/rails/rails/pull/12785) /
  [Подробности](/upgrading-ruby-on-rails#changes-in-json-handling))

* Устарела опция `ActiveSupport.encode_big_decimal_as_string`. Данная функциональность
  была выделена в гем [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder).
  ([Pull Request](https://github.com/rails/rails/pull/13060) /
  [Подробности](/upgrading-ruby-on-rails#changes-in-json-handling))

* Устарела произвольная сериализация `BigDecimal`. ([Pull Request](https://github.com/rails/rails/pull/13911))

### Значимые изменения

* JSON encoder из `ActiveSupport` был переписан, для того, чтобы воспользоваться
  гемом JSON, а не создавать свой велосипед.
  ([Pull Request](https://github.com/rails/rails/pull/12183) /
  [Подробности](/upgrading-ruby-on-rails#changes-in-json-handling))

* Улучшена совместимость с гемом JSON.
  ([Pull Request](https://github.com/rails/rails/pull/12862) /
  [Подробности](/upgrading-ruby-on-rails#changes-in-json-handling))

* Добавлены методы `ActiveSupport::Testing::TimeHelpers#travel` и `#travel_to`. Которые
  изменяют текущее время на заданное время или продолжительность, который вы укажите, с помощью стаба `Time.now` и
  `Date.today`. ([Pull Request](https://github.com/rails/rails/pull/12824))

* Добавлен `ActiveSupport::Testing::TimeHelpers#travel_back`. Этот метод возвращает текущее время к оригинальному состоянию, убирая стабы, добавленные `travel` и `travel_to`. ([Pull Request](https://github.com/rails/rails/pull/13884))

* Добавлен метод `Numeric#in_milliseconds`, например `1.hour.in_milliseconds`, результат которого можно скармливать в функции JavaScript, такие как `getTime()`. ([Commit](https://github.com/rails/rails/commit/423249504a2b468d7a273cbe6accf4f21cb0e643))

* Добавлены методы `Date#middle_of_day`, `DateTime#middle_of_day` и `Time#middle_of_day`.
  Также добавлены псевдонимы `midday`, `noon`, `at_midday`, `at_noon` и
  `at_middle_of_day`. ([Pull Request](https://github.com/rails/rails/pull/10879))

* Добавлены `Date#all_week/month/quarter/year` для генерации интервалов дат. ([Pull Request](https://github.com/rails/rails/pull/9685))

* Добавлены `Time.zone.yesterday` и `Time.zone.tomorrow`. ([Pull Request](https://github.com/rails/rails/pull/12822))

* Добавлен метод `String#remove(pattern)` как сокращение для
  `String#gsub(pattern,'')`. ([Commit](https://github.com/rails/rails/commit/5da23a3f921f0a4a3139495d2779ab0d3bd4cb5f))

* Добавлены `Hash#compact` и `Hash#compact!` для устранения из хэша элементов со значением nil. ([Pull Request](https://github.com/rails/rails/pull/13632))

* `blank?` и `present?` гарантированно возвращают булевы синглтоны. ([Commit](https://github.com/rails/rails/commit/126dc47665c65cd129967cbd8a5926dddd0aa514))

* По умолчанию новая конфигурация `I18n.enforce_available_locales` равна `true`, что означает, что `I18n` убедится, что все локали, передаваемые в него, должны быть объявлены в списке `available_locales`. ([Pull Request](https://github.com/rails/rails/commit/8e21ae37ad9fef6b7393a84f9b5f2e18a831e49a))

* Представлен Module#concerning: естественный и простой способ разделить ответственность внутри класса. ([Commit](https://github.com/rails/rails/commit/1eee0ca6de975b42524105a59e0521d18b38ab81))

* Добавлен `Object#present_in` для упрощения ведения белых списков значений. ([Commit](https://github.com/rails/rails/commit/4edca106daacc5a159289eae255207d160f22396))


Благодарности
-------------

Взгляните [на полный список контрибьюторов Rails](http://contributors.rubyonrails.org/), на людей, которые потратили много часов, сделав Rails стабильнее и надёжнее. Спасибо им всем.
