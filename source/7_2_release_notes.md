Заметки о релизе Ruby on Rails 7.2
==================================

Ключевые новинки в Rails 7.2:

* Конфигурация контейнеров разработки для приложений.
* По умолчанию добавлена проверка версии браузера.
* Ruby 3.1 сделан новой минимальной версией.
* Файлы прогрессивного веб-приложения (PWA) по умолчанию.
* По умолчанию добавлены правила omakase RuboCop.
* По умолчанию добавлен рабочий процесс GitHub CI в новые приложения.
* По умолчанию добавлен Brakeman в новые приложения.
* Установлено новое значение по умолчанию для количества тредов Puma.
* Предотвращено планирование заданий внутри транзакций.
* Колбэки подтверждения и отката транзакций.
* Включен YJIT по умолчанию при работе с Ruby 3.3+.
* Новый дизайн руководств по Rails.
* Настроен jemalloc в Dockerfile по умолчанию для оптимизации выделения памяти.
* Предложена конфигурацию puma-dev в bin/setup.

Эти заметки о релизе покрывают только основные изменения. Чтобы узнать о других обновлениях, различных исправлениях программных ошибок и изменениях, обратитесь к логам изменений или к [списку коммитов](https://github.com/rails/rails/commits/7-2-stable) в главном репозитории Rails на GitHub.

--------------------------------------------------------------------------------

Апгрейд до Rails 7.2
--------------------

Прежде чем апгрейднуть существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 7.2, необходимо сначала произвести апгрейд до Rails 7.1 и убедиться, что приложение все еще выполняется так, как нужно. Список вещей, которые нужно выполнить для апгрейда доступен в руководстве [Апгрейд Ruby on Rails](/upgrading-ruby-on-rails#upgrading-from-rails-7-1-to-rails-7-2).

Основные особенности
--------------------

### Конфигурация контейнеров разработки для приложений

[Контейнер разработки](https://containers.dev/) (dev container) позволяет использовать контейнер в качестве полноценной среды разработки.

Rails 7.2 добавляет возможность генерировать конфигурацию контейнера разработки для вашего приложения. Эта конфигурация включает папку `.devcontainer` с файлами `Dockerfile`, `docker-compose.yml` и `devcontainer.json`.

По умолчанию контейнер разработки содержит:

* Контейнер Redis для использования с Kredis, Action Cable и т.д.
* Базу данных (SQLite, Postgres, MySQL или MariaDB)
* Контейнер Headless Chrome для системных тестов
* Active Storage, настроенный для использования локального диска с работающими функциями предварительного просмотра

Для создания нового приложения с контейнером разработки вы можете выполнить команду:

```bash
rails new myapp --devcontainer
```

Для существующих приложений теперь доступна команда `devcontainer`.

```bash
rails devcontainer
```

Подробности смотрите в руководстве [TODO: Getting Started with Dev Containers](/getting_started_with_devcontainer).

### По умолчанию добавлена проверка версии браузера

Rails теперь добавляет возможность указывать версии браузеров, которым будет разрешен доступ ко всем экшнам (или некоторым из них, ограниченным `only:` или `except:`).

Только браузеры, соответствующие хэшу или именованному набору, переданному в `versions:`, будут заблокированы, если их версии ниже указанных.

Это означает, что всем другим неизвестным браузерам, а также агентам, которые не сообщают заголовок user-agent, будет разрешен доступ.

Заблокированному браузеру по умолчанию будет предоставлен файл `public/406-unsupported-browser.html` с HTTP-кодом состояния "406 Not Acceptable".

Примеры:

```ruby
class ApplicationController < ActionController::Base
  # Разрешить только браузеры с родной поддержкой webp images, web push, badges, import maps, CSS nesting + :has
  allow_browser versions: :modern
end

class ApplicationController < ActionController::Base
  # Все версии Chrome и Opera будут разрешены, но ни одна версия "internet explorer" (ie). Safari должен быть версии 16.4 и выше, а Firefox - 121 и выше.
  allow_browser versions: { safari: 16.4, firefox: 121, ie: false }
end

class MessagesController < ApplicationController
  # В дополнение к браузерам, заблокированным в ApplicationController, также блокируется Opera ниже версии 104 и Chrome ниже версии 119 для действия show.
  allow_browser versions: { opera: 104, chrome: 119 }, only: :show
end
```

В новых приложениях эта защита установлена в `ApplicationController`.

Для получения дополнительной информации смотрите документацию по [allow_browser](https://api.rubyonrails.org/classes/ActionController/AllowBrowser/ClassMethods.html#method-i-allow_browser).

### Ruby 3.1 сделан новой минимальной версией

До сих пор Rails прекращал поддержку старых версий Ruby только при выпуске новых мажорных версий. Мы меняем эту политику, потому что она вынуждает нас либо поддерживать устаревшие версии Ruby, либо слишком часто выпускать новые мажорные версии Rails, а также отказываться от нескольких версий Ruby одновременно при переходе на новую мажорную версию.

Теперь мы будем прекращать поддержку версий Ruby, достигших конца жизненного цикла, на минорных версиях Rails во время их выпуска.

Для Rails 7.2 минимальной версией Ruby становится 3.1.

### Файлы прогрессивного веб-приложения (PWA) по умолчанию

Для подготовки к более эффективной поддержке создания PWA-приложений с Rails, мы теперь генерируем стандартные PWA-файлы для манифеста и service worker. Эти файлы доступны из `app/views/pwa` и могут динамически рендериться с помощью ERB. Эти файлы монтируются явно в корневом каталоге с использованием стандартных маршрутов в сгенерированном файле маршрутов.

Для получения дополнительной информации смотрите [пул реквест на включение функции](https://github.com/rails/rails/pull/50528).

### По умолчанию добавлены правила omakase RuboCop

Rails теперь поставляется с [RuboCop](https://rubocop.org/), настроенным с набором правил из [rubocop-rails-omakase](https://github.com/rails/rubocop-rails-omakase) по умолчанию.

Ruby - это красивый и выразительный язык, который не только допускает множество различных диалектов, но и приветствует их многообразие. Он никогда не задумывался как язык, который нужно писать исключительно в одном стиле во всех библиотеках, фреймворках или приложениях. Если у вас или вашей команды есть свой особый стиль, который вам нравится, вам следует его ценить.

Этот набор стилей RuboCop предназначен для тех, кто еще не привержен какому-либо конкретному диалекту. Кто просто хочет иметь разумную отправную точку и кому будут полезны некоторые правила по умолчанию, чтобы хотя бы начать последовательный подход к стилизации Ruby.

Эти конкретные правила не являются ни правильными, ни неправильными, а просто отражают идиосинкразические эстетические чувства создателя Rails. Используйте их целиком, используйте их как отправную точку, используйте их как вдохновение или как вам будет угодно.

### По умолчанию добавлен рабочий процесс GitHub CI в новые приложения

Rails теперь по умолчанию добавляет файл рабочего процесса GitHub CI в новые приложения. Это, безусловно, поможет новичкам начать работу с автоматическим сканированием, анализом кода и тестированием. Мы считаем это естественным продолжением для современной эпохи того, что мы делали с самого начала с юнит-тестами.

Конечно, верно, что GitHub Actions - это коммерческий облачный продукт для частных репозиториев после того, как вы потратили бесплатные токены. Однако, учитывая связь между GitHub и Rails, подавляющее использование платформы новичками и ценность обучения их хорошим привычкам CI, мы считаем это приемлемым компромиссом.

### По умолчанию добавлен Brakeman в новые приложения

[Brakeman](https://brakemanscanner.org/) - это отличный способ предотвратить попадание в production распространенных уязвимостей безопасности в Rails.

Brakeman по умолчанию установлен в новых приложениях и в сочетании с рабочим процессом GitHub CI будет автоматически запускаться при каждом push-е.

### Установлено новое значение по умолчанию для количества тредов Puma

Rails изменил количество тредов по умолчанию в Puma с 5 на 3.

Из-за природы хорошо оптимизированных приложений Rails, с быстрыми SQL-запросами и медленными вызовами сторонних библиотек, работающих через задания, Ruby может тратить значительное время, ожидая освобождения Global VM Lock (GVL), когда количество тредов слишком велико, что негативно влияет на задержку (время ответа на запросы).

После тщательного рассмотрения, изучения и на основе опыта, полученного в приложениях, работающих в production, мы решили, что значение по умолчанию 3 треда - это хороший баланс между параллелизмом и производительностью.

Вы можете ознакомиться с очень подробным обсуждением этого изменения в [этой проблеме](https://github.com/rails/rails/issues/50450).

### Предотвращено планирование заданий внутри транзакций

Частая ошибка при работе с Active Job заключается в том, что задания ставятся в очередь внутри транзакции, что может привести к тому, что другой процесс подхватит и выполнит задание до завершения транзакции, что, в свою очередь, может вызвать различные ошибки.

```ruby
Topic.transaction do
  topic = Topic.create

  NewTopicNotificationJob.perform_later(topic)
end
```

Теперь Active Job автоматически откладывает постановку в очередь до завершения транзакции. Если транзакция откатывается, задание будет сброшено.

Некоторые реализации очередей могут отключить это поведение. Пользователи также могут отключить его или принудительно включить для отдельных заданий:

```ruby
class NewTopicNotificationJob < ApplicationJob
  self.enqueue_after_transaction_commit = false
end
```

### Колбэки подтверждения и отката транзакций

Эта возможность появилась благодаря новой функции, позволяющей регистрировать колбэки транзакций вне записи.

Теперь `ActiveRecord::Base.transaction` возвращает объект `ActiveRecord::Transaction`, который позволяет регистрировать на нем колбэки.

```ruby
Article.transaction do |transaction|
  article.update(published: true)

  transaction.after_commit do
    PublishNotificationMailer.with(article: article).deliver_later
  end
end
```

Также добавлен метод `ActiveRecord::Base.current_transaction`, который позволяет регистрировать колбэки на текущей транзакции.

```ruby
Article.current_transaction.after_commit do
  PublishNotificationMailer.with(article: article).deliver_later
end
```

И, наконец, был добавлен `ActiveRecord.after_all_transactions_commit` для кода, который может выполняться как внутри, так и вне транзакции, и которому необходимо выполнить работу после того, как изменения состояния будут успешно сохранены.

```ruby
def publish_article(article)
  article.update(published: true)

  ActiveRecord.after_all_transactions_commit do
    PublishNotificationMailer.with(article: article).deliver_later
  end
end
```

Подробности смотрите в [#51474](https://github.com/rails/rails/pull/51474) и [#51426](https://github.com/rails/rails/pull/51426).

### Включен YJIT по умолчанию при работе с Ruby 3.3+

YJIT, компилятор JIT Ruby, доступный в CRuby начиная с версии 3.1. Он может значительно повысить производительность Rails-приложений, сокращая задержки на 15-25%.

В Rails 7.2 YJIT включен по умолчанию при использовании Ruby 3.3 или более поздней версии.

Однако вы можете отключить YJIT с помощью:

```ruby
Rails.application.config.yjit = false
```

### Новый дизайн руководств по Rails

Когда Rails 7.0 вышел в декабре 2021 года, он появился с новой домашней страницей и новым экраном загрузки. Однако дизайн руководств оставался практически нетронутым с 2009 года, что не осталось незамеченным (мы услышали ваши отзывы).

Поскольку сейчас ведется большая работа по устранению сложности фреймворка Rails и обеспечению единообразия, ясности и актуальности документации, пришло время заняться дизайном руководств и сделать их такими же современными, простыми и свежими.

Мы сотрудничали с UX-дизайнером [John Athayde](https://meticulous.com/), чтобы перенести внешний вид домашней страницы на руководства по Rails, сделав их чистыми, элегантными и современными.

Разметка останется прежней, но с сегодняшнего дня вы увидите следующие изменения в руководствах:

* Более чистый и менее загруженный дизайн.
* Шрифты, цветовая схема и логотип больше соответствуют главной странице.
* Обновленная иконография.
* Упрощенная навигация.
* Панель навигации "Chapters" с фиксацией при прокрутке.

Посмотрите [сообщение блога с анонсом, где представлены изображения до и после изменений](https://rubyonrails.org/2024/3/20/rails-guides-get-a-facelift).

### Настроен jemalloc в Dockerfile по умолчанию для оптимизации выделения памяти
Использование malloc в Ruby может привести к проблемам фрагментации памяти, особенно при использовании нескольких потоков
[Использование `malloc` в Ruby может привести к проблемам фрагментации памяти, особенно при использовании нескольких тредов](https://www.speedshop.co/2017/12/04/malloc-doubles-ruby-memory.html) как в Puma. Переключение на выделение памяти, которое использует другие шаблоны для избежания фрагментации, может значительно снизить использование памяти.

Rails 7.2 теперь включает [jemalloc](https://jemalloc.net/) в Dockerfile по умолчанию для оптимизации выделения памяти.

### Предложена конфигурацию puma-dev в bin/setup

[Puma-dev](https://github.com/puma/puma-dev) — это золотой стандарт для локальной разработки нескольких Rails-приложений, если вы не используете Docker.

Rails теперь предлагает, как получить эту конфигурацию, в новом комментарии, который вы найдете в файле `bin/setup`.

Railties
--------

За подробностями обратитесь к [Changelog][railties].

### Удалено

*   Удален устаревший `Rails::Generators::Testing::Behaviour`.

*   Удален устаревший `Rails.application.secrets`.

*   Удален устаревший `Rails.config.enable_dependency_loading`.

*   Удален устаревший хелпер консоли `find_cmd_and_exec`.

*   Удалена поддержка `oracle`, `sqlserver` и адаптеров, специфичных для JRuby, из команд `rails` `new` и `db:system:change`.

*   Удалена опция `config.public_file_server.enabled` из генераторов.

### Устарело

### Значимые изменения

*   Добавлен RuboCop с правилами из [rubocop-rails-omakase](https://github.com/rails/rubocop-rails-omakase) по умолчанию как в новых приложениях, так и плагинов.

*   Добавлен Brakeman с конфигурацией по умолчанию для проверок безопасности в новых приложениях.

*   Добавлены файлы GitHub CI для Dependabot, Brakeman, RuboCop и запуска тестов по умолчанию для новых приложений и плагинов.

*   YJIT теперь включен по умолчанию для новых приложений, запущенных на Ruby 3.3+.

*   Генерируется папка `.devcontainer` для запуска приложения в контейнере с помощью Visual Studio Code.

    ```bash
    $ rails new myapp --devcontainer
    ```

*   Представлен `Rails::Generators::Testing::Assertions#assert_initializer` для инициализаторов теста.

*   Системные тесты теперь используют Headless Chrome по умолчанию для новых приложений.

*   Поддержка переменной среды `BACKTRACE` для отключения очистки трассировки при обычных запусках сервера. Ранее это было доступно только для тестирования.

*   По умолчанию добавлены файлы Progressive Web App (PWA) для манифеста и service worker, доступные из `app/views/pwa`, и их возможно динамически рендерить в ERB.

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

*   Удалена устаревшая константа `ActionDispatch::IllegalStateError`.

*   Удалена устаревшая константа `AbstractController::Helpers::MissingHelperError`.

*   Удалено устаревшее сравнение между `ActionController::Parameters` и `Hash`.

*   Удален устаревший `Rails.application.config.action_dispatch.return_only_request_media_type_on_content_type`.

*   Удалены устаревшие директивы политики разрешений `speaker`, `vibrate` и `vr`.

*   Удалена устаревшая поддержка назначения `Rails.application.config.action_dispatch.show_exceptions` как `true` и `false`.

### Устарело

*   Устарел `Rails.application.config.action_controller.allow_deprecated_parameters_hash_equality`.

### Значимые изменения

Action View
-----------

За подробностями обратитесь к [Changelog][action-view].

### Удалено

*   Удален устаревший `@rails/ujs` в пользу Turbo.

### Устарело

*  Устарела передача контекста в пустые элементы при использовании билдеров типа тега `tag.br`.

### Значимые изменения

Action Mailer
-------------

За подробностями обратитесь к [Changelog][action-mailer].

### Удалено

*   Удален устаревший `config.action_mailer.preview_path`.

*   Удалены устаревшие параметры с помощью `:args` для `assert_enqueued_email_with`.

### Устарело

### Значимые изменения

Active Record
-------------

За подробностями обратитесь к [Changelog][active-record].

### Удалено

*   Удален устаревший `Rails.application.config.active_record.suppress_multiple_database_warning`.

*   Удалена устаревшая поддержка вызова `alias_attribute` с несуществующими именами атрибута.

*   Удален устаревший аргумент `name` из `ActiveRecord::Base.remove_connection`.

*   Удален устаревший `ActiveRecord::Base.clear_active_connections!`.

*   Удален устаревший `ActiveRecord::Base.clear_reloadable_connections!`.

*   Удален устаревший `ActiveRecord::Base.clear_all_connections!`.

*   Удален устаревший `ActiveRecord::Base.flush_idle_connections!`.

*   Удален устаревший `ActiveRecord::ActiveJobRequiredError`.

*   Удалена устаревшая поддержка определения `explain` в адаптере соединения с 2 аргументами.

*   Удален устаревший метод `ActiveRecord::LogSubscriber.runtime`.

*   Удален устаревший метод `ActiveRecord::LogSubscriber.runtime=`.

*   Удален устаревший метод `ActiveRecord::LogSubscriber.reset_runtime`.

*   Удален устаревший метод `ActiveRecord::Migration.check_pending`.

*   Удалена устаревшая поддержка передачи классов `SchemaMigration` и `InternalMetadata` в качестве аргентов в `ActiveRecord::MigrationContext`.

*   Удалено устаревшее поведение поддержки ссылки на одиночную связь по ее множественному имени.

*   Удален устаревший `TestFixtures.fixture_path`.

*   Удалена устаревшая поддержка `ActiveRecord::Base#read_attribute(:id)` возвращения значения пользовательского первичного ключа.

*   Удалена устаревшая поддержка передачи кодировщика и класса в качестве второго аргумента в `serialize`.

*   Удален устаревший `#all_foreign_keys_valid?` из адаптеров базы данных.

*   Удален устаревший `ActiveRecord::ConnectionAdapters::SchemaCache.load_from`.

*   Удален устаревший `ActiveRecord::ConnectionAdapters::SchemaCache#data_sources`.

*   Удален устаревший `#all_connection_pools`.

*   Удалена устаревшая поддержка применения `#connection_pool_list`, `#active_connections?`, `#clear_active_connections!`,     `#clear_reloadable_connections!`, `#clear_all_connections!` и `#flush_idle_connections!` на пуле соединений для текущей роли, когда не предоставлен аргумент `role`.

*   Удален устаревший `ActiveRecord::ConnectionAdapters::ConnectionPool#connection_klass`.

*   Удален устаревший `#quote_bound_value`.

*   Удалена устаревшая поддержка экранирования `ActiveSupport::Duration`.

*   Удалена устаревшая поддержка передачи `deferrable: true` в `add_foreign_key`.

*   Удалена устаревшая поддержка передачи `rewhere` в `ActiveRecord::Relation#merge`.

*   Удалена устаревшая поддержка, откатывающая блок транзакции при выходе с помощью `return`, `break` или `throw`.

### Устарело

*   Устарел `Rails.application.config.active_record.allow_deprecated_singular_associations_name`

*   Устарел `Rails.application.config.active_record.commit_transaction_on_non_local_return`

### Значимые изменения

Active Storage
--------------

За подробностями обратитесь к [Changelog][active-storage].

### Удалено

*   Удален устаревший `config.active_storage.replace_on_assign_to_many`.

*   Удален устаревший `config.active_storage.silence_invalid_content_types_warning`.

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

*   Удалены устаревшие `ActiveSupport::Notifications::Event#children` и  `ActiveSupport::Notifications::Event#parent_of?`.

*   Удалена устаревшая поддержка вызова следующих методов без передачи депрекатора:

    - `deprecate`
    - `deprecate_constant`
    - `ActiveSupport::Deprecation::DeprecatedObjectProxy.new`
    - `ActiveSupport::Deprecation::DeprecatedInstanceVariableProxy.new`
    - `ActiveSupport::Deprecation::DeprecatedConstantProxy.new`
    - `assert_deprecated`
    - `assert_not_deprecated`
    - `collect_deprecations`

*   Удалена устаревшая делегация `ActiveSupport::Deprecation` на экземпляр.

*   Удален устаревший `SafeBuffer#clone_empty`.

*   Удален устаревший `#to_default_s` из `Array`, `Date`, `DateTime` и `Time`.

*   Удалены устаревшие опции `:pool_size` и `:pool_timeout` для хранилища кэша.

*   Удалена устаревшая поддержка `config.active_support.cache_format_version = 6.1`.

*   Удалены устаревшие константы `ActiveSupport::LogSubscriber::CLEAR` и `ActiveSupport::LogSubscriber::BOLD`.

*   Удалена устаревшая поддержка жирного текста с помощью позиционного флага в `ActiveSupport::LogSubscriber#color`.

*   Удален устаревший `config.active_support.disable_to_s_conversion`.

*   Удален устаревший `config.active_support.remove_deprecated_time_with_zone_name`.

*   Удален устаревший `config.active_support.use_rfc4122_namespaced_uuids`.

*   Удалена устаревшая поддержка передачи экземпляров `Dalli::Client` в `MemCacheStore`.

*   Удалена устаревшая поддержка поведения до Ruby 2.4 метода `to_time`, возвращающего объект `Time` с местной временной зоной.

### Устарело

*   Устарел `config.active_support.to_time_preserves_timezone`.

*   Устарел `DateAndTime::Compatibility.preserve_timezone`.

### Значимые изменения

Active Job
----------

За подробностями обратитесь к [Changelog][active-job].

### Удалено

*   Удален устаревший примитивный сериализатор для аргументов `BigDecimal`.

*   Удалена устаревшая поддержка установки числовых значений атрибуту `scheduled_at`.

*   Удалено устаревшее значение `:exponentially_longer` для `:wait` в `retry_on`.

### Устарело

*   Устарел `Rails.application.config.active_job.use_big_decimal_serialize`.

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

Credits
-------

Взгляните [на полный список контрибьюторов Rails](http://contributors.rubyonrails.org/), на людей, которые потратили много часов, сделав Rails стабильнее и надёжнее. Спасибо им всем.

[railties]:       https://github.com/rails/rails/blob/7-2-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/7-2-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/7-2-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/7-2-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/7-2-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/7-2-stable/activerecord/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/7-2-stable/activestorage/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/7-2-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/7-2-stable/activesupport/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/7-2-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/7-2-stable/actiontext/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/7-2-stable/actionmailbox/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/7-2-stable/guides/CHANGELOG.md
