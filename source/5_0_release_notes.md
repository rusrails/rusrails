Заметки о релизе Ruby on Rails 5.0
==================================

Ключевые новинки в Rails 5.0:

* Action Cable
* Rails API
* API атрибутов Active Record
* Test Runner
* Эксклюзивное использование интерфейса командной строки `rails` вместо Rake
* Sprockets 3
* Turbolinks 5
* Требуется Ruby 2.2.2+

Эти заметки о релизе покрывают только основные изменения. Чтобы узнать о других обновлениях, различных исправлениях программных ошибок и изменениях, обратитесь к логам изменений или к [списку коммитов](https://github.com/rails/rails/commits/5-0-stable) в главном репозитории Rails на GitHub.

--------------------------------------------------------------------------------

Апгрейд до Rails 5.0
--------------------

Прежде чем апгрейдить существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 5.0, необходимо сначала произвести апгрейд до Rails 4.2 и убедиться, что приложение все еще выполняется так, как нужно. Список вещей, которые нужно выполнить для апгрейда доступен в руководстве [Апгрейд Ruby on Rails](/upgrading-ruby-on-rails#upgrading-from-rails-4-2-to-rails-5-0).

Основные особенности
--------------------

### Action Cable
[Pull Request](https://github.com/rails/rails/pull/22586)

Action Cable — это новый фреймворк в Rails 5. Он с легкостью интегрирует [WebSockets](https://ru.wikipedia.org/wiki/WebSocket) с остальными частями вашего приложения Rails.

Action Cable позволяет писать функциональность реального времени на Ruby в стиле и формате остальной части приложения Rails, в то же время являясь производительным и масштабируемым. Он представляет полный стек, включая клиентский фреймворк на JavaScript и серверный фреймворк на Ruby. Вы получаете доступ к моделям предметной области, написанным с помощью Active Record или другой ORM на выбор.

Подробности смотрите в руководстве [Обзор Action Cable](/action-cable-overview).

Теперь можно использовать Rails для создания can now be used to create облегченных только API-приложений. Это полезно для создания и обслуживания API, подобным API [Twitter](https://dev.twitter.com) или [GitHub](https://developer.github.com), которые можно использовать как для публичного доступа, так и для собственных приложений.

Новое api-приложение Rails можно сгенерировать с помощью:

```bash
$ rails new my_api --api
```

Это сделает три основные вещи:

- Настроит ваше приложение для изначального использования с более ограниченным набором промежуточных программ. В частности, по умолчанию оно не включит любые промежуточные программы, полезные для браузерных приложений (такие как поддержка куки).
- Унаследует `ApplicationController` от `ActionController::API` вместо `ActionController::Base`. Как и в случае с промежуточными программами, это отбросит все модули Action Controller, предоставляющие функциональность, в основном используемую браузерными приложениями.
- Настроит генераторы пропускать генерацию вьюх, хелперов и ассетов при генерации нового ресурса.

Приложение представляет основу для API, которая затем может быть [настроена](/api-app) под нужды приложения.

Подробности смотрите в руководстве [Использование Rails для API-приложений](/api-app).

### API атрибутов Active Record

Определяет в модели тип с атрибутом. Это позволит при необходимости переопределить тип существующих атрибутов. Это позволяет контролировать, как значения конвертируются в и из SQL при присвоении модели. Это также изменяет поведение значений, переданных в `ActiveRecord::Base.where`, что позволяет использовать наши доменные объекты в большей части Active Record не полагаясь на особенности реализации или monkey patching.

Некоторые из вещей, которые можно достичь с помощью этого:
- Тип, распознанный Active Record, может быть переопределен.
- Также может быть представлено значение по умолчанию.
- Атрибутам не обязательно должен соответствовать столбец базы данных.

```ruby

# db/schema.rb
create_table :store_listings, force: true do |t|
  t.decimal :price_in_cents
  t.string :my_string, default: "original default"
end

# app/models/store_listing.rb
class StoreListing < ActiveRecord::Base
end

store_listing = StoreListing.new(price_in_cents: '10.1')

# before
store_listing.price_in_cents # => BigDecimal.new(10.1)
StoreListing.new.my_string # => "original default"

class StoreListing < ActiveRecord::Base
  attribute :price_in_cents, :integer # настраиваемый тип
  attribute :my_string, :string, default: "new default" # значение по умаолчанию
  attribute :my_default_proc, :datetime, default: -> { Time.now } # значение по умолчанию
  attribute :field_without_db_column, :integer, array: true
end

# after
store_listing.price_in_cents # => 10
StoreListing.new.my_string # => "new default"
StoreListing.new.my_default_proc # => 2015-05-30 11:04:48 -0600
model = StoreListing.new(field_without_db_column: ["1", "2", "3"])
model.attributes # => {field_without_db_column: [1, 2, 3]}
```

**Создание собственных типов:**

Можно определить свои собственные типы, но они должны отвечать на методы для определенного типа значения. Метод `deserialize` или `cast` будет вызван на вашем объекте типа с необработанными данными из базы данных или от контроллера. Это полезно, к примеру, при осуществлении пользовательских преобразований, таких как данные Money.

**Запросы:**

При вызове `ActiveRecord::Base.where`, он будет использовать тип, определенный классом модели, для конвертации значения в SQL, вызвав `serialize` на вашем объекте типа.

Это дает объектам способность указывать, как конвертировать значения при выполнении запросов SQL.

**Отслеживание изменений (Dirty Tracking):**

Тип атрибута дает возможность изменить способ, как выполняется отслеживание изменений.

Подробности смотрите в его [документации](http://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html).

### Запуск тестов

Был представлен новый запуск тестов, улучшающий возможности запуска тестов из Rails.
Для использования этого запуска тестов просто напишите `bin/rails test`.

Test Runner вдохновлялся `RSpec`, `minitest-reporters`, `maxitest` и другими. Он включает некоторые из этих значимых улучшений:

- Запуск одиночного теста с помощью номера строчки теста.
- Запуск нескольких тестов, определяя номера строчек тестов.
- Улучшенные сообщения об падениях, что также упрощает перезапуск упавших тестов.
- Быстрое падение с помощью опции `-f` для немедленной остановки в случае падения, вместо ожидания полного завершения тестового набора.
- Отложенный вывод теста, пока не закончится полный тестовый прогон, с помощью опции `-d`.
- Вывод полного стека исключения с помощью опции `-b`.
- Интеграция с `Minitest`, чтобы разрешить опции, такие как `-s` для указания seed, `-n` для запуска определенного теста по имени, `-v` для более выразительного вывода, и так далее.
- Цветной тестовый вывод.

Railties
--------

За подробностями обратитесь к [Changelog][railties].

### Удалено

*   Удалена поддержка debugger, используйте вместо него byebug. `debugger` больше не поддерживается Ruby 2.2.
    ([коммит](https://github.com/rails/rails/commit/93559da4826546d07014f8cfa399b64b4a143127))

*   Удалены устаревшие задачи `test:all` и `test:all:db`.
    ([коммит](https://github.com/rails/rails/commit/f663132eef0e5d96bf2a58cec9f7c856db20be7c))

*   Удален устаревший `Rails::Rack::LogTailer`.
    ([коммит](https://github.com/rails/rails/commit/c564dcb75c191ab3d21cc6f920998b0d6fbca623))

*   Удалена устаревшая константа `RAILS_CACHE`.
    ([коммит](https://github.com/rails/rails/commit/b7f856ce488ef8f6bf4c12bb549f462cb7671c08))

*   Удалена устаревшая настройка `serve_static_assets`.
    ([коммит](https://github.com/rails/rails/commit/463b5d7581ee16bfaddf34ca349b7d1b5878097c))

*   Удалены задачи для документации `doc:app`, `doc:rails` и `doc:guides`.
    ([коммит](https://github.com/rails/rails/commit/cd7cc5254b090ccbb84dcee4408a5acede25ef2a))

*   Из стека по умолчанию удалена промежуточная программа `Rack::ContentLength`.
    ([коммит](https://github.com/rails/rails/commit/56903585a099ab67a7acfaaef0a02db8fe80c450))

### Устарело

*   Устарела `config.static_cache_control` в пользу `config.public_file_server.headers`.
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   Устарела `config.serve_static_files` в пользу `config.public_file_server.enabled`.
    ([Pull Request](https://github.com/rails/rails/pull/22173))

*   Устарели задачи в пространстве имен `rails` в пользу пространства имен `app`. (например, задачи `rails:update` и `rails:template` переименованы в `app:update` и `app:template`.)
    ([Pull Request](https://github.com/rails/rails/pull/23439))

### Значимые изменения

*   Добавлен Rails test runner `bin/rails test`.
    ([Pull Request](https://github.com/rails/rails/pull/19216))

*   Вновь сгенерированные приложения и плагины получают `README.md` в формате Markdown.
    ([коммит](https://github.com/rails/rails/commit/89a12c931b1f00b90e74afffcdc2fc21f14ca663),
     [Pull Request](https://github.com/rails/rails/pull/22068))

*   Добавлена задача `bin/rails restart` для перезапуска вашего приложения Rails, изменяя время `tmp/restart.txt`.
    ([Pull Request](https://github.com/rails/rails/pull/18965))

*   Добавлена задача `bin/rails initializers`, выводящая все определенные инициализаторы в том порядке, в котором они вызываются Rails.
    ([Pull Request](https://github.com/rails/rails/pull/19323))

*   Добавлена `bin/rails dev:cache` для включения или отключения кэширования в режиме разработки.
    ([Pull Request](https://github.com/rails/rails/pull/20961))

*   Добавлен скрипт `bin/update` для автоматического обновления среды development.
    ([Pull Request](https://github.com/rails/rails/pull/20972))

*   Проксируются задачи Rake с помощью `bin/rails`.
    ([Pull Request](https://github.com/rails/rails/pull/22457),
     [Pull Request](https://github.com/rails/rails/pull/22288))

*   Новые приложения генерируются с включенным наблюдением событийной файловой системы на Linux и macOS. Эту особенность можно отключить, передав `--skip-listen` в генератор.
    ([коммит](https://github.com/rails/rails/commit/de6ad5665d2679944a9ee9407826ba88395a1003),
    [коммит](https://github.com/rails/rails/commit/94dbc48887bf39c241ee2ce1741ee680d773f202))

*   Генерация приложений с опцией вывода лога в STDOUT в production с помощью переменной среды `RAILS_LOG_TO_STDOUT`.
    ([Pull Request](https://github.com/rails/rails/pull/23734))

*   Для новых приложений включен HSTS с заголовком IncludeSudomains.
    ([Pull Request](https://github.com/rails/rails/pull/23852))

*   Генератор приложения создает новый файл `config/spring.rb`, который сообщает Spring наблюдать за дополнительными распространенными файлами.
    ([коммит](https://github.com/rails/rails/commit/b04d07337fd7bc17e88500e9d6bcd361885a45f8))

*   Добавлена `--skip-action-mailer`, чтобы пропустить Action Mailer при генерации нового приложения.
    ([Pull Request](https://github.com/rails/rails/pull/18288))

*   Убрана директория `tmp/sessions` и задача очистки rake, связанная с ней.
    ([Pull Request](https://github.com/rails/rails/pull/18314))

*   Изменен `_form.html.erb`, генерируемый скаффолдом, чтобы использовались локальные переменные.
    ([Pull Request](https://github.com/rails/rails/pull/13434))

*   Отключена автозагрузка классов в среде production.
    ([commit](https://github.com/rails/rails/commit/a71350cae0082193ad8c66d65ab62e8bb0b7853b))

Action Pack
-----------

За подробностями обратитесь к [Changelog][action-pack].

### Удалено

*   Удален `ActionDispatch::Request::Utils.deep_munge`.
    ([коммит](https://github.com/rails/rails/commit/52cf1a71b393486435fab4386a8663b146608996))

*   Удален `ActionController::HideActions`.
    ([Pull Request](https://github.com/rails/rails/pull/18371))

*   Удалены методы `respond_to` и `respond_with`, эта функциональность была извлечена в гем [responders](https://github.com/plataformatec/responders).
    ([коммит](https://github.com/rails/rails/commit/afd5e9a7ff0072e482b0b0e8e238d21b070b6280))

*   Удалены устаревшие файлы тестовых утверждений.
    ([коммит](https://github.com/rails/rails/commit/92e27d30d8112962ee068f7b14aa7b10daf0c976))

*   Удалено устаревшее использование строковых ключей в хелперах путей.
    ([коммит](https://github.com/rails/rails/commit/34e380764edede47f7ebe0c7671d6f9c9dc7e809))

*   Удалена устаревшая опция `only_path` в хелперах `*_path`.
    ([коммит](https://github.com/rails/rails/commit/e4e1fd7ade47771067177254cb133564a3422b8a))

*   Удален устаревший `NamedRouteCollection#helpers`.
    ([коммит](https://github.com/rails/rails/commit/2cc91c37bc2e32b7a04b2d782fb8f4a69a14503f))

*   Удалена устаревшая поддержка определения маршрутов с помощью опции `:to`, не содержащей `#`.
    ([коммит](https://github.com/rails/rails/commit/1f3b0a8609c00278b9a10076040ac9c90a9cc4a6))

*   Удален устаревший `ActionDispatch::Response#to_ary`.
    ([коммит](https://github.com/rails/rails/commit/4b19d5b7bcdf4f11bd1e2e9ed2149a958e338c01))

*   Удален устаревший `ActionDispatch::Request#deep_munge`.
    ([коммит](https://github.com/rails/rails/commit/7676659633057dacd97b8da66e0d9119809b343e))

*   Удален устаревший `ActionDispatch::Http::Parameters#symbolized_path_parameters`.
    ([коммит](https://github.com/rails/rails/commit/7fe7973cd8bd119b724d72c5f617cf94c18edf9e))

*   Удалена устаревшая опция `use_route` в тестах контроллеров.
    ([коммит](https://github.com/rails/rails/commit/e4cfd353a47369dd32198b0e67b8cbb2f9a1c548))

*   Удалены `assigns` и `assert_template`. Оба метода были извлечены в гем [rails-controller-testing](https://github.com/rails/rails-controller-testing).
    ([Pull Request](https://github.com/rails/rails/pull/20138))

### Устарело

*   Устарели все колбэки `*_filter` в пользу колбэков `*_action`.
    ([Pull Request](https://github.com/rails/rails/pull/18410))

*   Устарели интеграционные методы тестирования `*_via_redirect`. Используйте вручную `follow_redirect!` после вызова запроса для того же поведения.
    ([Pull Request](https://github.com/rails/rails/pull/18693))

*   Устарел `AbstractController#skip_action_callback` в пользу отдельных методов `skip_callback`.
    ([Pull Request](https://github.com/rails/rails/pull/19060))

*   Устарела опция `:nothing` для метода `render`.
    ([Pull Request](https://github.com/rails/rails/pull/20336))

*   Устарела передача первого параметра как `Hash` и код статуса по умолчанию для метода `head`.
    ([Pull Request](https://github.com/rails/rails/pull/20407))

*   Устарело использование строк или символов для имен классов промежуточных программ. Используйте вместо них имена классов.
    ([коммит](https://github.com/rails/rails/commit/83b767ce))

*   Устарел доступ к типам mime с помощью констант (т.е. `Mime::HTML`). Вместо них используйте оператор индексирования с символом (т.е. `Mime[:html]`).
    ([Pull Request](https://github.com/rails/rails/pull/21869))

*   Устарел `redirect_to :back` в пользу `redirect_back`, который принимает аргумент `fallback_location`, устраняющий возможность `RedirectBackError`.
    ([Pull Request](https://github.com/rails/rails/pull/22506))

*   В `ActionDispatch::IntegrationTest` и `ActionController::TestCase` устарели позиционные аргументы в пользу аргументов с ключевым словом. ([Pull Request](https://github.com/rails/rails/pull/18323))

*   Устарели параметры пути `:controller` и `:action`.
    ([Pull Request](https://github.com/rails/rails/pull/23980))

*   Устарел метод env на экземплярах контроллера.
    ([commit](https://github.com/rails/rails/commit/05934d24aff62d66fc62621aa38dae6456e276be))

*   Устарел и был убран из стека промежуточных программ `ActionDispatch::ParamsParser`. Чтобы настроить парсеры параметров, используйте `ActionDispatch::Request.parameter_parsers=`.
    ([commit](https://github.com/rails/rails/commit/38d2bf5fd1f3e014f2397898d371c339baa627b1),
    [commit](https://github.com/rails/rails/commit/5ed38014811d4ce6d6f957510b9153938370173b))

### Значимые изменения

*   Добавлен `ActionController::Renderer` для рендеринга произвольных шаблонов вне экшнов контроллера.
    ([Pull Request](https://github.com/rails/rails/pull/18546))

*   Произошел переход на синтаксис с ключевыми аргументами в методах запроса HTTP `ActionController::TestCase` и `ActionDispatch::Integration`.
    ([Pull Request](https://github.com/rails/rails/pull/18323))

*   В Action Controller добавлен `http_cache_forever`, таким образом можно кэшировать отклик, который никогда не устаревает.
    ([Pull Request](https://github.com/rails/rails/pull/18394))

*   Предоставлен более дружелюбный доступ к вариантам запроса.
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*   Для экшнов без соответствующих шаблонов рендерится `head :no_content` вместо вызова ошибки.
    ([Pull Request](https://github.com/rails/rails/pull/19377))

*   Добавлена возможность переопределить билдер формы по умолчанию для контроллера.
    ([Pull Request](https://github.com/rails/rails/pull/19736))

*   Добавлена поддержка для чистых API-приложений. Добавлен `ActionController::API` в качестве замены `ActionController::Base` для такого типа приложений.
    ([Pull Request](https://github.com/rails/rails/pull/19832))

*   `ActionController::Parameters` больше не наследуется от `HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/20868))

*   Упрощена настройка `config.force_ssl` и `config.ssl_options`, они сделаны менее опасными для пробы и более простыми для отключения.
    ([Pull Request](https://github.com/rails/rails/pull/21520))

*   Добавлена возможность возврата произвольных заголовков в `ActionDispatch::Static`.
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   Изменено значение по умолчанию для опции prepend метода `protect_from_forgery` на `false`.
    ([коммит](https://github.com/rails/rails/commit/39794037817703575c35a75f1961b01b83791191))

*   `ActionController::TestCase` будет перемещен в отдельный гем в Rails 5.1. Вместо него используйте `ActionDispatch::IntegrationTest`.
    ([коммит](https://github.com/rails/rails/commit/4414c5d1795e815b102571425974a8b1d46d932d))

*   Rails генерирует слабые ETag по умолчанию.
    ([Pull Request](https://github.com/rails/rails/pull/17573))

*   Добавлена опция для CSRF токенов для отдельной формы.
    ([Pull Request](https://github.com/rails/rails/pull/22275))

*   Добавлены кодировка запроса и парсинг отклика в интеграционные тесты.
    ([Pull Request](https://github.com/rails/rails/pull/21671))

*   Обновлены политики рендеринга по умолчанию, когда экшн контроллера не указывает явно отклик.
    ([Pull Request](https://github.com/rails/rails/pull/23827))

*   Добавлен `ActionController#helpers` для получения доступа к контексту вьюхи на уровне контроллера.
    ([Pull Request](https://github.com/rails/rails/pull/24866))

*   Показанные сообщения flash убираются перед сохранением в сессию.
    ([Pull Request](https://github.com/rails/rails/pull/18721))

*   Добавлена поддержка передачи коллекции записей в `fresh_when` и `stale?`.
    ([Pull Request](https://github.com/rails/rails/pull/18374))

*   `ActionController::Live` стал `ActiveSupport::Concern`. Это означает, что его нельзя просто включить в другие модули без расширения их с помощью `ActiveSupport::Concern`, иначе `ActionController::Live` не возымеет эффект в production. Также можно использовать другой модуль для включения кода обработки специальных ошибок `Warden`/`Devise`, так как промежуточные программы не могут поймать `:warden`, брошенный в порожденном треде в случае использования `ActionController::Live`.
    ([Подробнее об этой проблеме](https://github.com/rails/rails/issues/25581))

*   Представлены `Response#strong_etag=` и `#weak_etag=`, и аналогичные опции для `fresh_when` и `stale?`.
    ([Pull Request](https://github.com/rails/rails/pull/24387))

Action View
-------------

За подробностями обратитесь к [Changelog][action-view].

### Удалено

*    Уделен устаревший `AbstractController::Base::parent_prefixes`.
    ([коммит](https://github.com/rails/rails/commit/34bcbcf35701ca44be559ff391535c0dd865c333))

*   Удален `ActionView::Helpers::RecordTagHelper`, эта функциональность была извлечена в гем [record_tag_helper](https://github.com/rails/record_tag_helper).
    ([Pull Request](https://github.com/rails/rails/pull/18411))

*   Убрана опция `:rescue_format` для хелпера `translate`, так как она больше не поддерживается I18n.
    ([Pull Request](https://github.com/rails/rails/pull/20019))

### Значимые изменения

*   Изменен обработчик шаблонов по умолчанию с `ERB` на `Raw`.
    ([коммит](https://github.com/rails/rails/commit/4be859f0fdf7b3059a28d03c279f03f5938efc80))

*   Рендеринг коллекций может кэшировать и извлекать несколько партиалов за раз.
    ([Pull Request](https://github.com/rails/rails/pull/18948),
    [коммит](https://github.com/rails/rails/commit/e93f0f0f133717f9b06b1eaefd3442bd0ff43985))

*   Добавлено универсальное сопоставление для явных зависимостей.
    ([Pull Request](https://github.com/rails/rails/pull/20904))

*   `disable_with` сделано поведением по умолчанию для тегов submit. Отключает кнопку при отправке, чтобы предотвратить двойную отправку.
    ([Pull Request](https://github.com/rails/rails/pull/21135))

*   Имя шаблона партиала больше не обязано быть валидным идентификатором Ruby.
    ([коммит](https://github.com/rails/rails/commit/da9038e))

*   Хелпер `datetime_tag` теперь генерирует тег input с типом `datetime-local`.
    ([Pull Request](https://github.com/rails/rails/pull/25469))

*   Разрешены блоки при рендеринге с помощью хелпера `render partial:`.
    ([Pull Request](https://github.com/rails/rails/pull/17974))

Action Mailer
-------------

За подробностями обратитесь к [Changelog][action-mailer].

### Удалено

*   Удалены устаревшие хелперы `*_path` во вьюхах email.
    ([коммит](https://github.com/rails/rails/commit/d282125a18c1697a9b5bb775628a2db239142ac7))

*   Удалены устаревшие методы `deliver` и `deliver!`.
    ([коммит](https://github.com/rails/rails/commit/755dcd0691f74079c24196135f89b917062b0715))

### Значимые изменения

*   Поиск шаблонов теперь учитывает локаль по умолчанию и фолбэки I18n.
    ([коммит](https://github.com/rails/rails/commit/ecb1981b))

*   Рассыльщикам, создаваемым генератором, добавляется суффикс `_mailer`, в соответствии с соглашениями об именовании, использованными в контроллерах и заданиях.
    ([Pull Request](https://github.com/rails/rails/pull/18074))

*   Добавлены `assert_enqueued_emails` и `assert_no_enqueued_emails`.
    ([Pull Request](https://github.com/rails/rails/pull/18403))

*   Добавлена настройка `config.action_mailer.deliver_later_queue_name` для установления имени очереди рассыльщика.
    ([Pull Request](https://github.com/rails/rails/pull/18587))

*   Добавлена поддержка кэширования фрагмента во вьюхах Action Mailer. Добавлена новая конфигурационная опция `config.action_mailer.perform_caching` для определения, должны ли ваши шаблоны осуществлять кэширование или нет.
    ([Pull Request](https://github.com/rails/rails/pull/22825))

Active Record
-------------

За подробностями обратитесь к [Changelog][active-record].

### Удалено

*   Удалено устаревшее поведение, позволяющее передавать вложенные массивы в качестве значений запроса.
    ([Pull Request](https://github.com/rails/rails/pull/17919))

*   Удален устаревший `ActiveRecord::Tasks::DatabaseTasks#load_schema`. Этот метод был заменен `ActiveRecord::Tasks::DatabaseTasks#load_schema_for`.
    ([коммит](https://github.com/rails/rails/commit/ad783136d747f73329350b9bb5a5e17c8f8800da))

*   Удален устаревший `serialized_attributes`.
    ([коммит](https://github.com/rails/rails/commit/82043ab53cb186d59b1b3be06122861758f814b2))

*   Удалены устаревшие автоматические кэши счетчиков на `has_many :through`.
    ([коммит](https://github.com/rails/rails/commit/87c8ce340c6c83342df988df247e9035393ed7a0))

*   Удален устаревший `sanitize_sql_hash_for_conditions`.
    ([коммит](https://github.com/rails/rails/commit/3a59dd212315ebb9bae8338b98af259ac00bbef3))

*   Удален устаревший `Reflection#source_macro`.
    ([коммит](https://github.com/rails/rails/commit/ede8c199a85cfbb6457d5630ec1e285e5ec49313))

*   Удалены устаревшие `symbolized_base_class` и `symbolized_sti_name`.
    ([коммит](https://github.com/rails/rails/commit/9013e28e52eba3a6ffcede26f85df48d264b8951))

*   Удалены устаревшие `ActiveRecord::Base.disable_implicit_join_references=`.
    ([коммит](https://github.com/rails/rails/commit/0fbd1fc888ffb8cbe1191193bf86933110693dfc))

*   Удален устаревший доступ к спецификации соединения с помощью строкового акцессора.
    ([коммит](https://github.com/rails/rails/commit/efdc20f36ccc37afbb2705eb9acca76dd8aabd4f))

*   Удалена устаревшая поддержка предварительной загрузки связей, зависимых от экземпляра.
    ([коммит](https://github.com/rails/rails/commit/4ed97979d14c5e92eb212b1a629da0a214084078))

*   Удалена устаревшая поддержка интервалов PostgreSQL с исключенной нижней границей.
    ([коммит](https://github.com/rails/rails/commit/a076256d63f64d194b8f634890527a5ed2651115))

*   Убрано предупреждение об устаревании при модифицировании relation с кэшированным Arel. Вместо этого вызывается ошибка `ImmutableRelation`.
    ([коммит](https://github.com/rails/rails/commit/3ae98181433dda1b5e19910e107494762512a86c))

*   Из ядра удален `ActiveRecord::Serialization::XmlSerializer`. Эта особенность была извлечена в гем [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml).
    ([Pull Request](https://github.com/rails/rails/pull/21161))

*   Из ядра удалена поддержка старой версии адаптера баз данных `mysql`. Большинству пользователей можно использовать `mysql2`. Он будет конвертирован в отдельный гем, если найдется кто-то, кто будет его поддерживать.
    ([Pull Request 1](https://github.com/rails/rails/pull/22642),
    [Pull Request 2](https://github.com/rails/rails/pull/22715))

*   Удалена поддержка гема `protected_attributes`.
    ([коммит](https://github.com/rails/rails/commit/f4fbc0301021f13ae05c8e941c8efc4ae351fdf9))

*   Удалена поддержка для PostgreSQL версии ниже 9.1.
    ([Pull Request](https://github.com/rails/rails/pull/23434))

*   Удалена поддержка гема `activerecord-deprecated_finders`.
    ([коммит](https://github.com/rails/rails/commit/78dab2a8569408658542e462a957ea5a35aa4679))

*   Удалена константа `ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES`.
    ([commit](https://github.com/rails/rails/commit/a502703c3d2151d4d3b421b29fefdac5ad05df61))

### Устарело

*   Устарела передача класса в качестве значения запроса. Вместо этого нужно передавать строки.
    ([Pull Request](https://github.com/rails/rails/pull/17916))

*   Устарел возврат `false` в качестве способа прервать цепочку колбэков Active Record. Рекомендуемый способ `throw(:abort)`.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Устарел `ActiveRecord::Base.errors_in_transactional_callbacks=`.
    ([коммит](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

*   Устарел `Relation#uniq`, вместо него используйте `Relation#distinct`.
    ([коммит](https://github.com/rails/rails/commit/adfab2dcf4003ca564d78d4425566dd2d9cd8b4f))

*   Устарел тип PostgreSQL `:point` в пользу нового, возвращающего объекты `Point` вместо `Array`
    ([Pull Request](https://github.com/rails/rails/pull/20448))

*   Устарело принуждение к перезагрузке связи с помощью передачи истинного аргумента в метод связи.
    ([Pull Request](https://github.com/rails/rails/pull/20888))

*   Устарели ключи для ошибок связи `restrict_dependent_destroy` в пользу новых имен ключей.
    ([Pull Request](https://github.com/rails/rails/pull/20668))

*   Синхронизировано поведение `#tables`.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Устарели `SchemaCache#tables`, `SchemaCache#table_exists?` и `SchemaCache#clear_table_cache!` в пользу их новых дубликатов `data_source`.
    ([Pull Request](https://github.com/rails/rails/pull/21715))

*   Устарел `connection.tables` в адаптерах SQLite3 и MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Устарела передача аргументов в `#tables` - метод `#tables` в некоторых адаптерах (mysql2, sqlite3) мог возвращать и таблицы, и представления, в то время как другие (postgresql) просто возвращали таблицы. Чтобы сделать их поведение согласующимся, в будущем `#tables` будет возвращать только таблицы.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Устарел `table_exists?` - метод `#table_exists?` мог проверять и таблицы, и представления. Чтобы сделать его поведение согласующимся с `#tables`, в будущем `#table_exists?` будет проверять только таблицы.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Устарела отправка аргумента `offset` в `find_nth`. Вместо этого используйте метод `offset` на relation.
    ([Pull Request](https://github.com/rails/rails/pull/22053))

*   Устарели `{insert|update|delete}_sql` в `DatabaseStatements`. Вместо этого используйте публичные методы `{insert|update|delete}`.
    ([Pull Request](https://github.com/rails/rails/pull/23086))

*   Устарел `use_transactional_fixtures` в пользу `use_transactional_tests` для большей ясности.
    ([Pull Request](https://github.com/rails/rails/pull/19282))

*   Устарела передача столбца в `ActiveRecord::Connection#quote`.
    ([commit](https://github.com/rails/rails/commit/7bb620869725ad6de603f6a5393ee17df13aa96c))

*   В `find_in_batches` добавлена опция `end`, дополняющая параметр `start`, для определения, где следует остановить обработку пакетами.
    ([Pull Request](https://github.com/rails/rails/pull/12257))

### Значимые изменения

*   Добавлена опция `foreign_key` в `references` во время создания таблицы.
    ([коммит](https://github.com/rails/rails/commit/99a6f9e60ea55924b44f894a16f8de0162cf2702))

*   Новый API атрибутов.
    ([коммит](https://github.com/rails/rails/commit/8c752c7ac739d5a86d4136ab1e9d0142c4041e58))

*   Добавлена опция `:_prefix`/`:_suffix` в определении `enum`.
    ([Pull Request](https://github.com/rails/rails/pull/19813),
     [Pull Request](https://github.com/rails/rails/pull/20999))

*   Добавлен `#cache_key` в `ActiveRecord::Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/20884))

*   Изменено значение по умолчанию `null` для `timestamps` на `false`.
    ([коммит](https://github.com/rails/rails/commit/a939506f297b667291480f26fa32a373a18ae06a))

*   Добавлен `ActiveRecord::SecureToken`, чтобы инкапсулировать генерацию уникальных токенов для атрибутов модели с помощью `SecureRandom`.
    ([Pull Request](https://github.com/rails/rails/pull/18217))

*   Добавлена опция `:if_exists` для `drop_table`.
    ([Pull Request](https://github.com/rails/rails/pull/18597))

*   Добавлен `ActiveRecord::Base#accessed_fields`, который может быть использован, чтобы быстро просмотреть, какие поля были прочитаны из модели, когда вы выбираете только те данные из базы данных, которые вам нужны.
    ([коммит](https://github.com/rails/rails/commit/be9b68038e83a617eb38c26147659162e4ac3d2c))

*   Добавлен метод `#or` на `ActiveRecord::Relation`, позволяющий использование оператора OR в сочетании с выражениями WHERE или HAVING.
    ([коммит](https://github.com/rails/rails/commit/b0b37942d729b6bdcd2e3178eda7fa1de203b3d0))

*   Добавлен `ActiveRecord::Base.suppress` предотвращающий получатель от сохранения в заданном блоке.
    ([Pull Request](https://github.com/rails/rails/pull/18910))

*   `belongs_to` по умолчанию теперь вызывает ошибку валидации, если связь не существует. Это можно отключить для конкретной связи с помощью `optional: true`. Также устарела опция `required` в пользу `optional` для `belongs_to`.
    ([Pull Request](https://github.com/rails/rails/pull/18937))

*   Добавлен `config.active_record.dump_schemas` для настройки поведения `db:structure:dump`.
    ([Pull Request](https://github.com/rails/rails/pull/19347))

*   Добавлена опция `config.active_record.warn_on_records_fetched_greater_than`.
    ([Pull Request](https://github.com/rails/rails/pull/18846))

*   Добавлена поддержка нативного типа данных JSON в MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/21110))

*   Добавлена поддержка для конкурентного удаления индексов в PostgreSQL.
    ([Pull Request](https://github.com/rails/rails/pull/21317))

*   Добавлены методы `#views` и `#view_exists?` на адаптерах соединений.
    ([Pull Request](https://github.com/rails/rails/pull/21609))

*   Добавлен `ActiveRecord::Base.ignored_columns`, чтобы сделать некоторые столбцы невидимыми из Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/21720))

*   Добавлены `connection.data_sources` и `connection.data_source_exists?`. Эти методы определяют, какие relation могут быть использованы для создание моделей Active Record (обычно таблицы и представления).
    ([Pull Request](https://github.com/rails/rails/pull/21715))

*   В файлах фикстур можно указать класс модели в самом файле YAML.
    ([Pull Request](https://github.com/rails/rails/pull/20574))

*   Добавлена возможность по умолчанию указать `uuid` в качестве первичного ключа при генерации миграций базы данных.
    ([Pull Request](https://github.com/rails/rails/pull/21762))

*   Добавлены `ActiveRecord::Relation#left_joins` и `ActiveRecord::Relation#left_outer_joins`.
    ([Pull Request](https://github.com/rails/rails/pull/12071))

*   Добавлены колбэки `after_{create,update,delete}_commit`.
    ([Pull Request](https://github.com/rails/rails/pull/22516))

*   Версия API представлена в классах миграций, таким образом можно изменять значения по умолчанию без риска сломать существующие миграции, или принудить переписать их с помощью цикла устаревания.
    ([Pull Request](https://github.com/rails/rails/pull/21538))

*   `ApplicationRecord` - это новый суперкласс для всех моделей приложения, по аналогии с контроллерами приложения, являющимися подклассами `ApplicationController` вместо `ActionController::Base`. Это дает возможность приложениям иметь единое место для настройки специфичного для приложения поведения модели.
    ([Pull Request](https://github.com/rails/rails/pull/22567))

*   Добавлены методы ActiveRecord `#second_to_last` и `#third_to_last`.
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*   Добавлена возможность аннотации объектов базы данных (таблиц, столбцов, индексов) комментариями, хранимыми в метаданных базы данных для PostgreSQL & MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/22911))

*   Добавлена поддержка подготовленных выражений (prepared statements) для адаптера `mysql2`, для mysql2 0.4.4+. Раньше это поддерживалось только устаревшим адаптером `mysql`. Чтобы включить, установите `prepared_statements: true` в `config/database.yml`.
    ([Pull Request](https://github.com/rails/rails/pull/23461))

*   Добавлена возможность вызвать `ActionRecord::Relation#update` на реляционных объектах, который запустит валидации на колбэках на всех объектах в реляции.
    ([Pull Request](https://github.com/rails/rails/pull/11898))

*   Добавлена опция `:touch` в метод `save`, таким образом, записи могут быть сохранены без обновления временных меток.
    ([Pull Request](https://github.com/rails/rails/pull/18225))

*   Добавлена поддержка индексов по выражениям (expression indexes) и классов оператора (operator classes) для PostgreSQL.
    ([коммит](https://github.com/rails/rails/commit/edc2b7718725016e988089b5fb6d6fb9d6e16882))

*   Добавлена опция `:index_errors` для добавления индексов к ошибкам вложенных атрибутов.
    ([Pull Request](https://github.com/rails/rails/pull/19686))

*   Добавлена поддержка для двунаправленных зависимостей при удалении.
    ([Pull Request](https://github.com/rails/rails/pull/18548))

*   Добавлена поддержка колбэков `after_commit` в транзакционных тестах.
    ([Pull Request](https://github.com/rails/rails/pull/18458))

*   Добавлен метод `foreign_key_exists?`, чтобы просмотреть, существует ли внешний ключ на таблицу.
    ([Pull Request](https://github.com/rails/rails/pull/18662))

*   Добавлена опция `:time` для метода `touch`, для затрагивания моделей временем, отличным от текущего времени.
    ([Pull Request](https://github.com/rails/rails/pull/18956))

*   Изменены транзакционные колбэки, чтобы не проглатывали ошибки. До этого изменения любая ошибка в транзакционном колбэке отлавливалась и выводилась в лог, кроме случая использования (сейчас устаревшей) опции `raise_in_transactional_callbacks = true`.

    Сейчас эти ошибки больше не отлавливаются, а просто всплывают, что соответствует поведению других колбэков.
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

Active Model
------------

За подробностями обратитесь к [Changelog][active-model].

### Удалено

*   Удалены устаревшие `ActiveModel::Dirty#reset_#{attribute}` и `ActiveModel::Dirty#reset_changes`.
    ([Pull Request](https://github.com/rails/rails/commit/37175a24bd508e2983247ec5d011d57df836c743))

*   Удалена сериализация XML. Эта особенность была извлечена в гем [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml).
    ([Pull Request](https://github.com/rails/rails/pull/21161))

*   Удален модуль `ActionController::ModelNaming`.
    ([Pull Request](https://github.com/rails/rails/pull/18194))

### Устарело

*   Устарел возврат `false` в качестве способа прервать цепочку колбэков Active Model и `ActiveModel::Validations`. Рекомендуемый способ `throw(:abort)`.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Устарели методы `ActiveModel::Errors#get`, `ActiveModel::Errors#set` и `ActiveModel::Errors#[]=`, имеющие противоречивое поведение.
    ([Pull Request](https://github.com/rails/rails/pull/18634))

*   Устарела опция `:tokenizer` для `validates_length_of` в пользу чистого Ruby.
    ([Pull Request](https://github.com/rails/rails/pull/19585))

*   Устарели `ActiveModel::Errors#add_on_empty` и `ActiveModel::Errors#add_on_blank` без замены.
    ([Pull Request](https://github.com/rails/rails/pull/18996))

### Значимые изменения

*   Добавлен `ActiveModel::Errors#details` для определения, какие валидаторы провалились.
    ([Pull Request](https://github.com/rails/rails/pull/18322))

*   Извлечен `ActiveRecord::AttributeAssignment` в `ActiveModel::AttributeAssignment`, позволяя его использование в любом объекте в качестве включаемого модуля.
    ([Pull Request](https://github.com/rails/rails/pull/10776))

*   Добавлены `ActiveModel::Dirty#[attr_name]_previously_changed?` и `ActiveModel::Dirty#[attr_name]_previous_change` для улучшения доступа в записанные изменения после того, как модель была сохранена.
    ([Pull Request](https://github.com/rails/rails/pull/19847))

*   Валидация нескольких контекстов за раз в `valid?` и `invalid?`.
    ([Pull Request](https://github.com/rails/rails/pull/21069))

*   Изменена `validates_acceptance_of`, чтобы принималось `true` в качестве значения по умолчанию, кроме `1`.
    ([Pull Request](https://github.com/rails/rails/pull/18439))

Active Job
-----------

За подробностями обратитесь к [Changelog][active-job].

### Значимые изменения

*   `ActiveJob::Base.deserialize` делегируется в класс задания. Это позволяет заданиям присоединить произвольные метаданные при сериализации и прочитать их при выполнении.
    ([Pull Request](https://github.com/rails/rails/pull/18260))

*   Добавлена возможность настроить адаптер очереди для каждого задания без взаимного влияния друг на друга.
    ([Pull Request](https://github.com/rails/rails/pull/16992))

*   Сгенерированное задание теперь по умолчанию наследуется от `app/jobs/application_job.rb`.
    ([Pull Request](https://github.com/rails/rails/pull/19034))

*   Позволяет `DelayedJob`, `Sidekiq`, `qu`, `que` и `queue_classic` возвращать `ActiveJob::Base` id задания как `provider_job_id`.
    ([Pull Request](https://github.com/rails/rails/pull/20064),
     [Pull Request](https://github.com/rails/rails/pull/20056),
     [коммит](https://github.com/rails/rails/commit/68e3279163d06e6b04e043f91c9470e9259bbbe0))

*   Реализован простой процессор `AsyncJob` и связанный `AsyncAdapter`, который складывает задания в пул тредов `concurrent-ruby`.
    ([Pull Request](https://github.com/rails/rails/pull/21257))

*   Изменен адаптер по умолчанию со встроенного на асинхронный. Это лучше по умолчанию, так как тогда тесты не будут ошибочно проходить, полагаясь на поведение, проходящее синхронно.
    ([коммит](https://github.com/rails/rails/commit/625baa69d14881ac49ba2e5c7d9cac4b222d7022))

Active Support
--------------

За подробностями обратитесь к [Changelog][active-support].

### Удалено

*   Удален устаревший `ActiveSupport::JSON::Encoding::CircularReferenceError`.
    ([commit](https://github.com/rails/rails/commit/d6e06ea8275cdc3f126f926ed9b5349fde374b10))

*   Удалены устаревшие методы `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string=` и `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string`.
    ([commit](https://github.com/rails/rails/commit/c8019c0611791b2716c6bed48ef8dcb177b7869c))

*   Удален устаревший `ActiveSupport::SafeBuffer#prepend`.
    ([commit](https://github.com/rails/rails/commit/e1c8b9f688c56aaedac9466a4343df955b4a67ec))

*   Удалены устаревшие методы из `Kernel`. `silence_stderr`, `silence_stream`, `capture` и `quietly`.
    ([commit](https://github.com/rails/rails/commit/481e49c64f790e46f4aff3ed539ed227d2eb46cb))

*   Удален устаревший файл `active_support/core_ext/big_decimal/yaml_conversions`.
    ([commit](https://github.com/rails/rails/commit/98ea19925d6db642731741c3b91bd085fac92241))

*   Удалены устаревшие методы `ActiveSupport::Cache::Store.instrument` и `ActiveSupport::Cache::Store.instrument=`.
    ([commit](https://github.com/rails/rails/commit/a3ce6ca30ed0e77496c63781af596b149687b6d7))

*   Удален устаревший `Class#superclass_delegating_accessor`. Вместо него используйте `Class#class_attribute`.
    ([Pull Request](https://github.com/rails/rails/pull/16938))

*   Удален устаревший `ThreadSafe::Cache`. Вместо него используйте `Concurrent::Map`.
    ([Pull Request](https://github.com/rails/rails/pull/21679))

*   Удален `Object#itself`, так как он реализован в Ruby 2.2.
    ([Pull Request](https://github.com/rails/rails/pull/18244))

### Устарело

*   Устарел `MissingSourceFile` в пользу `LoadError`.
    ([commit](https://github.com/rails/rails/commit/734d97d2))

*   Устарел `alias_method_chain` в пользу `Module#prepend`, представленного в Ruby 2.0.
    ([Pull Request](https://github.com/rails/rails/pull/19434))

*   Устарел `ActiveSupport::Concurrency::Latch` в пользу `Concurrent::CountDownLatch` из concurrent-ruby.
    ([Pull Request](https://github.com/rails/rails/pull/20866))

*   Устарела опция `:prefix` для `number_to_human_size` без замены.
    ([Pull Request](https://github.com/rails/rails/pull/21191))

*   Устарел `Module#qualified_const_` в пользу встроенных методов `Module#const_`.
    ([Pull Request](https://github.com/rails/rails/pull/17845))

*   Устарела передача строки для определения колбэков.
    ([Pull Request](https://github.com/rails/rails/pull/22598))

*   Устарели `ActiveSupport::Cache::Store#namespaced_key`, `ActiveSupport::Cache::MemCachedStore#escape_key` и `ActiveSupport::Cache::FileStore#key_file_path`. Вместо них используйте `normalize_key`.
    ([Pull Request](https://github.com/rails/rails/pull/22215),
     [commit](https://github.com/rails/rails/commit/a8f773b0))

*   Устарел `ActiveSupport::Cache::LocaleCache#set_cache_value` в пользу `write_cache_value`.
    ([Pull Request](https://github.com/rails/rails/pull/22215))

*   Устарела передача аргументов в `assert_nothing_raised`.
    ([Pull Request](https://github.com/rails/rails/pull/23789))

*   Устарел `Module.local_constants` в пользу `Module.constants(false)`.
    ([Pull Request](https://github.com/rails/rails/pull/23936))

### Значимые изменения

*   Добавлены методы `#verified` и `#valid_message?` в `ActiveSupport::MessageVerifier`.
    ([Pull Request](https://github.com/rails/rails/pull/17727))

*   Изменен способ, которым прерываются цепочки колбэков. Теперь предпочтительный метод прерывания цепочки колбэков – явный `throw(:abort)`.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Новая конфигурационная опция `config.active_support.halt_callback_chains_on_return_false` для определения, могут ли колбэки ActiveRecord, ActiveModel и ActiveModel::Validations быть прерваны, возвращая `false` в колбэке 'before'.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Изменена сортировка тестов по умолчанию с `:sorted` на `:random`.
    ([commit](https://github.com/rails/rails/commit/5f777e4b5ee2e3e8e6fd0e2a208ec2a4d25a960d))

*   Добавлены методы `#on_weekend?`, `#on_weekday?`, `#next_weekday`, `#prev_weekday` в `Date`, `Time` и `DateTime`.
    ([Pull Request](https://github.com/rails/rails/pull/18335),
     [Pull Request](https://github.com/rails/rails/pull/23687))

*   Добавлена опция `same_time` для `#next_week` и `#prev_week` в `Date`, `Time` и `DateTime`.
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*   Добавлены аналоги `#prev_day` и `#next_day` для `#yesterday` и `#tomorrow` в `Date`, `Time` и `DateTime`.
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*   Добавлен `SecureRandom.base58` для генерации случайных строк base58.
    ([commit](https://github.com/rails/rails/commit/b1093977110f18ae0cafe56c3d99fc22a7d54d1b))

*   Добавлен `file_fixture` в `ActiveSupport::TestCase`. Он представляет простой механизм для доступа к файлам с примерами в ваших тестовых случаях.
    ([Pull Request](https://github.com/rails/rails/pull/18658))

*   Добавлен `#without` в `Enumerable` и `Array`, возвращающий копию перечисления без определенных элементов.
    ([Pull Request](https://github.com/rails/rails/pull/19157))

*   Добавлены `ActiveSupport::ArrayInquirer` и `Array#inquiry`.
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*   Добавлен `ActiveSupport::TimeZone#strptime`, позволяющий парсить время, как будто из заданной временной зоны.
    ([commit](https://github.com/rails/rails/commit/a5e507fa0b8180c3d97458a9b86c195e9857d8f6))

*   Добавлены предикатные методы `Integer#positive?` и `Integer#negative?` в духе `Integer#zero?`.
    ([commit](https://github.com/rails/rails/commit/e54277a45da3c86fecdfa930663d7692fd083daa))

*   Добавлены восклицательные версии методов доступа в `ActiveSupport::OrderedOptions`, вызывающие `KeyError`, если значение `.blank?`.
    ([Pull Request](https://github.com/rails/rails/pull/20208))

*   Добавлен `Time.days_in_year`, возвращающий количество дней в заданном году, или в текущем году, если не указан аргумент.
    ([commit](https://github.com/rails/rails/commit/2f4f4d2cf1e4c5a442459fc250daf66186d110fa))

*   Добавлен событийный мониторинг файлов для асинхронного обнаружения изменений в исходном коде приложения, маршрутах, локалях и так далее.
    ([Pull Request](https://github.com/rails/rails/pull/22254))

*   Добавлен набор методов thread_m/cattr_accessor/reader/writer для объявления переменных класса и модуля, существующих отдельно для каждого треда.
    ([Pull Request](https://github.com/rails/rails/pull/22630))

*   Добавлены методы `Array#second_to_last` и `Array#third_to_last`.
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*   Опубликованы API `ActiveSupport::Executor` и `ActiveSupport::Reloader`, чтобы позволить компонентам и библиотекам управлять и участвовать в выполнении кода приложения и процессе перезагрузки приложения.
    ([Pull Request](https://github.com/rails/rails/pull/23807))

*   Теперь `ActiveSupport::Duration` поддерживает форматирование и парсинг ISO8601.
    ([Pull Request](https://github.com/rails/rails/pull/16917))

*   Теперь `ActiveSupport::JSON.decode` поддерживает парсинг локального времени ISO8601, если включен `parse_json_times`.
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*   Теперь `ActiveSupport::JSON.decode` возвращает объекты `Date` для строк с датой.
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*   В `TaggedLogging` добавлена возможность логгерам быть инициализированными несколько раз, и у них не будет общих тегов между собой.
    ([Pull Request](https://github.com/rails/rails/pull/9065))

Благодарности
-------------

Взгляните [на полный список контрибьюторов Rails](http://contributors.rubyonrails.org/), на людей, которые потратили много часов, сделав Rails стабильнее и надёжнее. Спасибо им всем.

[railties]:       https://github.com/rails/rails/blob/5-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-0-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-0-stable/activesupport/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-0-stable/activejob/CHANGELOG.md
