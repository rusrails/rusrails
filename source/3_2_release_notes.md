Заметки о релизе Ruby on Rails 3.2
==================================

Ключевые новинки в Rails 3.2:

* Режим Development стал быстрее
* Новый Engine для роутинга
* Автоматические Explain для запросов
* Тегированное логирование

Эти заметки о релизе покрывают только основные изменения. Чтобы узнать о различных исправлениях программных ошибок и изменениях, обратитесь к логам изменений или к [списку коммитов](https://github.com/rails/rails/commits/3-2-stable) в главном репозитории Rails на GitHub.

--------------------------------------------------------------------------------

Апгрейд до Rails 3.2
--------------------

Прежде чем апгрейднуть существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 3.2, необходимо сначала произвести апгрейд до Rails 3.1 и убедиться, что приложение все еще выполняется так, как нужно. Затем обратите внимание на следующие изменения:

### Rails 3.2 требует как минимум Ruby 1.8.7

Rails 3.2 требует Ruby 1.8.7 или выше. Поддержка всех прежних версий Ruby была официально прекращена, и следует произвести апгрейд как можно раньше. Rails 3.2 также совместим с Ruby 1.9.2.

TIP: Отметьте, что в Ruby 1.8.7 p248 и p249 имеются программные ошибки маршалинга, ломающие Rails. Хотя в Ruby Enterprise Edition это было исправлено, начиная с релиза 1.8.7-2010.02. В ветке 1.9, Ruby 1.9.1 не пригоден к использованию, поскольку он иногда вылетает, поэтому, если хотите использовать 1.9.x перепрыгивайте на 1.9.2 для гладкой работы.

### Что обновить в приложении

* Обновите зависимости в вашем `Gemfile`
    * `rails = 3.2.0`
    * `sass-rails ~> 3.2.3`
    * `coffee-rails ~> 3.2.1`
    * `uglifier >= 1.0.3`

* В Rails 3.2 устаревает `vendor/plugins`, а в Rails 4.0 будет убрано окончательно. Можете начинать перемещать эти плагины, выделяя их в гемы и добавляя в свой `Gemfile`. Если вы не хотите делать из них гемы, можно их переместить, скажем в `lib/my_plugin/*`, и добавить соответствующий инициализатор в `config/initializers/my_plugin.rb`.

* Имеется ряд новых конфигурационных изменений, которые можно добавить в `config/environments/development.rb`:

    ```ruby
    # Raise exception on mass assignment protection for Active Record models
    config.active_record.mass_assignment_sanitizer = :strict

    # Log the query plan for queries taking more than this (works
    # with SQLite, MySQL, and PostgreSQL)
    config.active_record.auto_explain_threshold_in_seconds = 0.5
    ```

    Также необходимо добавить конфиг `mass_assignment_sanitizer` в `config/environments/test.rb`:

    ```ruby
    # Raise exception on mass assignment protection for Active Record models
    config.active_record.mass_assignment_sanitizer = :strict
    ```

### Что обновить в ваших engine-ах

Замените код ниже комментариев в `script/rails` следующим содержимым:

```ruby
ENGINE_ROOT = File.expand_path('../..', __FILE__)
ENGINE_PATH = File.expand_path('../../lib/your_engine_name/engine', __FILE__)

require 'rails/all'
require 'rails/engine/commands'
```

Создание приложения Rails 3.2
-----------------------------

```bash
# Необходим установленный рубигем 'rails'
$ rails new myapp
$ cd myapp
```

### Сторонние гемы

Сейчас Rails использует `Gemfile` в корне приложения, чтобы определить гемы, требуемые для запуска вашего приложения. Этот `Gemfile` обрабатывается [Bundler](http://github.com/carlhuda/bundler), который затем устанавливает все зависимости. Он может даже установить все зависимости локально в ваше приложение, и оно не будет зависеть от системных гемов.

Подробнее: - [домашняя страница Bundler](https://bundler.io/)

### Живите на грани

`Bundler` и `Gemfile` замораживает ваше приложение Rails с помощью новой отдельной команды `bundle`. Если хотите установить напрямую из репозитория Git, передайте флажок `--edge`:

```bash
$ rails new myapp --edge
```

Если имеется локальная копия репозитория Rails, и необходимо сгенерировать приложение используя ее, передайте флажок `--dev`:

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

Основные особенности
--------------------

### Быстрый режим Development и роутинг

В Rails 3.2 режим development стал ощутимо быстрее. Вдохновившись работой [Active Reload](https://github.com/paneq/active_reload), Rails перезагружает классы только тогда, когда файлы фактически изменились. В больших приложениях наблюдается существенный прирост производительности. Распознавание маршрутов также получило прирост скорости, благодаря новому engine [Journey](https://github.com/rails/journey).

### Автоматические Explain запросов

Rails 3.2 поставляется с прекрасной возможностью раскрытия запросов, сгенерированных Arel, определив метод `explain` в `ActiveRecord::Relation`. Для примера, можно запустить что-то наподобие `puts Person.active.limit(5).explain` и результат запроса Arel будет раскрыт. Это позволяет проверку правильности индексирования и дальнейшую оптимизацию.

Запросы, выполняющиеся более чем пол секунды, *автоматически* раскрываются в режиме development. Это поведение, разумеется, может быть изменено.

### Тегированное логирование

При запуске многопользовательского приложения может сильно помочь фильтрация в логе, кто что делал. TaggedLogging в Active Support помогает это сделать точным, помечая строчки лога поддоменами, id запросов и чем угодно, что поможет вам отладить такие приложения.

Документация
------------

Начиная с Rails 3.2, руководства по Rails доступны для Kindle, и как бесплатные Kindle Reading Apps для iPad, iPhone, Mac, Android и т.д.

Railties
--------

* Ускорен режим development за счет перезагрузки классов только при изменении зависимых файлов. Это может быть отключено, если установить `config.reload_classes_only_on_change` в false.

* Новые приложения получают флажок `config.active_record.auto_explain_threshold_in_seconds` в файлах конфигурации среды. Со значением `0.5` в `development.rb` и закомментированным в `production.rb`. Не упоминается в `test.rb`.

* Добавлена `config.exceptions_app` для указания приложения для обработки исключений, вызываемого промежуточной программой `ShowException` при вызове исключения. По умолчанию `ActionDispatch::PublicExceptions.new(Rails.public_path)`.

* Добавлена промежуточная программа `DebugExceptions`, содержащая особенности, извлеченные из промежуточной программы `ShowExceptions`.

* Отображает маршруты монтированных engine-ов в `rake routes`.

* Позволяет изменить порядок загрузки railties с помощью `config.railties_order` следующим образом:

    ```ruby
    config.railties_order = [Blog::Engine, :main_app, :all]
    ```

* Скаффолд возвращает 204 No Content для API запросов без содержимого. Это позволяет скаффолду работать с jQuery "из коробки".

* Обновлена промежуточная программа `Rails::Rack::Logger`, чтобы добавлять любые теги, установленные в `config.log_tags`, в `ActiveSupport::TaggedLogging`. Это позволяет легко тегировать строчки лога отладочной информацией, такой как поддомен и id запроса -- оба очень полезны при отладке production многопользовательских приложений.

* Опции по умолчанию для `rails new` могут быть установлены в `~/.railsrc`. Можно указать дополнительные аргументы командной строки, используемые каждый раз при запуске 'rails new', в конфигурационном файле `.railsrc` в домашней директории.

* Добавлен псевдоним `d` для `destroy`. Это также работает для engine.

* Атрибуты генераторов скаффолда и модели по умолчанию строковые. Это позволяет следующее: `rails g scaffold Post title body:text author`

* Позволяет генераторам скаффолда/модели/миграции принимать модификаторы "index" и "uniq". Например,

    ```ruby
    rails g scaffold Post title:string:index author:uniq price:decimal{7,2}
    ```

    создаст индексы для `title` и `author`, причем последний будет уникальным индексом. Некоторые типы, такие как decimal, принимают произвольные опции. В примере `price` будет столбцом decimal с установленными точностью и масштабом 7 и 2 соответственно.

* Гем Turn был убран из дефолтного `Gemfile`.

* Убран старый генератор плагинов `rails generate plugin` в пользу команды `rails plugin new`.

* Убрано старое `config.paths.app.controller` API в пользу `config.paths["app/controller"]`.

### Устаревания

* `Rails::Plugin` устарел и будет убран в Rails 4.0. Вместо добавления плагинов в `vendor/plugins`, используйте гемы, или bundler с путем, или зависимости git.

Action Mailer
-------------

* Апгрейд версия `mail` до 2.4.0.

* Убрано старое Action Mailer API, которое было объявлено устаревшим в Rails 3.0.

Action Pack
-----------

### Action Controller

* `ActiveSupport::Benchmarkable` стал модулем по умолчанию для `ActionController::Base,` таким образом, метод `#benchmark` снова доступен в контексте контроллера, как это было раньше.

* Добавлена опция `:gzip` в `caches_page`. Дефолтная опция может быть настроена глобально с использованием `page_cache_compression`.

* Теперь Rails будет использовать ваш макет по умолчанию (такой как "layouts/application") при определенных условий `:only` и `:except`, и если они не выполняются.

    ```ruby
    class CarsController
      layout 'single_car', :only => :show
    end
    ```

    Rails будет использовать 'layouts/single_car' если запрос придет в экшн `:show`, и использовать `layouts/application` (или `layouts/cars`, если он существует), если запрос придет в любой другой экшн.

* `form_for` изменился и использует `#{action}_#{as}` как класс css и id, если предоставлена опция `:as`. Ранние версии использовали `#{as}_#{action}`.

* `ActionController::ParamsWrapper` на моделях Active Record теперь оборачивают атрибуты `attr_accessible`, только если они существуют. Если нет, будут обернуты только атрибуты, возвращенные методом класса `attribute_names`. Это устраняет оборачивание вложенных атрибутов при помещении их в `attr_accessible`.

* Пишет в лог "Filter chain halted as CALLBACKNAME rendered or redirected" каждый раз при прерывании предварительного колбэка.

* Проведен рефакторинг `ActionDispatch::ShowExceptions`. Контроллер ответственен за выбор как показывать исключения. В контроллере возможно переопределить `show_detailed_exceptions?`, чтобы определить, какие запросы должны предоставлять отладочную информацию при ошибках.

* Responders теперь возвращают 204 No Content для API запросов без тела отклика (как в новых скаффолдах).

* Проведен рефакторинг куки `ActionController::TestCase`. Назначаемые куки для тестовых случаев теперь должны использовать `cookies[]`

    ```ruby
    cookies[:email] = 'user@example.com'
    get :index
    assert_equal 'user@example.com', cookies[:email]
    ```

    Для очистки куки используйте `clear`.

    ```ruby
    cookies.clear
    get :index
    assert_nil cookies[:email]
    ```

    Больше не пишется HTTP_COOKIE и куки теперь персистентные между запросами, поэтому если нужно манипулировать средой для вашего теста, это нужно сделать до того, как куки будут созданы.

* `send_file` теперь угадывает тип MIME по расширению файла, если не предоставлен `:type`.

* Добавлены записи типов MIME для PDF, ZIP и других форматов.

* Позволяет `fresh_when/stale?` принимать запись вместо хэша опций.

* Изменен уровень лога для предупреждения об отсутствующем токене CSRF с `:debug` до `:warn`.

* По умолчанию ассеты должны использовать протокол запроса или протокол по умолчанию, если запрос недоступен.

#### Устаревания

* Устарел поиск подразумеваемого макета в контроллерах, чей родитель имеет явно установленный макет:

    ```ruby
    class ApplicationController
      layout "application"
    end

    class PostsController < ApplicationController
    end
    ```

    В вышеуказанном примере `PostsController` больше не будет автоматически искать макет posts. Если вам нужна такая функциональность, следует либо убрать `layout "application"` из `ApplicationController` или явно установить его в `nil` в `PostsController`.

* Устарел `ActionController::UnknownAction` в пользу `AbstractController::ActionNotFound`.

* Устарел `ActionController::DoubleRenderError` в пользу `AbstractController::DoubleRenderError`.

* Устарел `method_missing` в пользу `action_missing` для отсутствующих экшнов.

* Устарели `ActionController#rescue_action`, `ActionController#initialize_template_class` и `ActionController#assign_shortcuts`.

### Action Dispatch

* Добавлена `config.action_dispatch.default_charset` для настройки кодировки по умолчанию для `ActionDispatch::Response`.

* Добавлена промежуточная программа `ActionDispatch::RequestId`, создающая уникальный заголовок X-Request-Id, доступный в отклике, и включает метод `ActionDispatch::Request#uuid`. Это позволяет легко отслеживать запросы от начала до конца в стеке и идентифицировать отдельные запросы в смешанных логах, наподобие Syslog.

* Промежуточная программа `ShowExceptions` теперь принимает приложение для обработки исключений, ответственное за рендеринг исключения при ошибках приложения. Приложение запускается с копией исключения в `env["action_dispatch.exception"]`, и с переписанным `PATH_INFO` в код статуса.

* Позволяет настроить отклики rescue с помощью railtie, как в `config.action_dispatch.rescue_responses`.

#### Устаревания

* Устарела возможность установить кодировку по умолчанию на уровне контроллера, вместо этого используйте новую `config.action_dispatch.default_charset`.

### Action View

* В `ActionView::Helpers::FormBuilder` добавлена поддержка `button_tag`. Эта поддержка повторяет поведение по умолчанию `submit_tag`.

    ```ruby
    <%= form_for @post do |f| %>
      <%= f.button %>
    <% end %>
    ```

* Хелперы дат принимают новую опцию `:use_two_digit_numbers => true`, отрисовывающую селект-боксы для месяцев и дней с ведущим нулем без изменения соответствующих value. Для примера, это полезно для отображения дат в стиле ISO 8601, таких как '2011-08-01'.

* Для вашей формы можно предоставить пространство имен для обеспечения уникальности атрибута id у элементов формы. В сгенерированном HTML id пространство имен атрибута будет идти впереди с подчеркиванием.

    ```ruby
    <%= form_for(@offer, :namespace => 'namespace') do |f| %>
      <%= f.label :version, 'Version' %>:
      <%= f.text_field :version %>
    <% end %>
    ```

* Ограничено количество пунктов списка для `select_year` в 1000. Передайте опцию `:max_years_allowed` для установки своего лимита.

* Теперь `content_tag_for` и `div_for` могут принимать коллекцию записей. Они также передадут запись как первый аргумент, если вы вставите получаемый аргумент в блок. Таким образом, вместо этого:

    ```ruby
    @items.each do |item|
      content_tag_for(:li, item) do
        Title: <%= item.title %>
      end
    end
    ```

    Можно сделать так:

    ```ruby
    content_tag_for(:li, @items) do |item|
      Title: <%= item.title %>
    end
    ```

* Добавлен метод хелпера `font_path`, вычисляющий путь к ассету шрифта в `public/fonts`.

#### Устаревания

* Передача форматов или обработчиков в render :template и тому подобные методы, например `render :template => "foo.html.erb"`, устарела. Вместо этого можно предоставить непосредственно :handlers и :formats как опции: ` render :template => "foo", :formats => [:html, :js], :handlers => :erb`.

### Sprockets

* Добавлена конфигурационная опция `config.assets.logger` для контроля над логированием Sprockets. Установите ее `false` для отключения логирования, и `nil` для дефолтного `Rails.logger`.

Active Record
-------------

* Булевы столбцы со значениями 'on' и 'ON' считаются за true.

* Когда метод `timestamps` создает столбцы `created_at` и `updated_at`, по умолчанию он их делает non-nullable.

* Реализован `ActiveRecord::Relation#explain`.

* Реализован `ActiveRecord::Base.silence_auto_explain`, позволяющий пользователю выборочно отключать автоматические EXPLAIN в блоке.

* Реализовано логирование автоматического EXPLAIN для медленных запросов. Новый конфигурационный параметр `config.active_record.auto_explain_threshold_in_seconds` определяет, что рассматривается как медленный запрос. Установите ему nil, чтобы отключить эту возможность. По умолчанию 0.5 в режиме development, и nil в режимах test и production. Rails 3.2 поддерживает эту возможность для SQLite, MySQL (адаптер mysql2) и PostgreSQL.

* Добавлен `ActiveRecord::Base.store` для определения простых key/value хранилищ с одним столбцом.

    ```ruby
    class User < ActiveRecord::Base
      store :settings, accessors: [ :color, :homepage ]
    end

    u = User.new(color: 'black', homepage: '37signals.com')
    u.color                          # Акцессор хранимого атрибута
    u.settings[:country] = 'Denmark' # Любой атрибут, даже если не указать через акцессор
    ```

* Добавлена возможность запуска миграций только для определенного пространства имен, позволяющая запустить миграции только для одного engine (например, чтобы откатить изменения от engine, чтобы убрать его).

    ```ruby
    rake db:migrate SCOPE=blog
    ```

* Миграции, скопированные из engine-ов, теперь помещаются в пространство имен с именем engine, например `01_create_posts.blog.rb`.

* Реализован метод `ActiveRecord::Relation#pluck`, возвращающий массив значений столбца непосредственно из лежащей в основе таблицы. Он также работает с сериализованными атрибутами.

    ```ruby
    Client.where(:active => true).pluck(:id)
    # SELECT id from clients where active = 1
    ```

* Методы сгенерированных связей создаются в отдельном модуле, чтобы позволить переопределение и компоновку. Для класса с именем MyModel, модель будет называться `MyModel::GeneratedFeatureMethods`. Он включается в класс модели сразу после модуля `generated_attributes_methods`, определенного в Active Model, таким образом, методы связей переопределяют методы атрибутов с таким же именем.

* Добавлен `ActiveRecord::Relation#uniq` для генерации уникальных запросов.

    ```ruby
    Client.select('DISTINCT name')
    ```

    ..может быть записано так:

    ```ruby
    Client.select(:name).uniq
    ```

    В relation также можно отменить уникальность:

    ```ruby
    Client.select(:name).uniq.uniq(false)
    ```

* Поддержка порядка сортировки по индексу в адаптерах SQLite, MySQL и PostgreSQL.

* Опция `:class_name` для связей может принимать символ, в дополнение к строке. Это сделано, чтобы не смущать новичков, и быть последовательными в том факте, что другие опции, такие как `:foreign_key`, уже допускают символ или строку.

    ```ruby
    has_many :clients, :class_name => :Client # Отметьте, что символ должен начинаться с заглавной буквы
    ```

* В режиме development, `db:drop` также уничтожает тестовую базу данных, чтобы быть симметричной с `db:create`.

* Не чувствительные к регистру валидации уникальности избегают вызов LOWER в MySQL, когда столбец уже использует не чувствительное к регистру сопоставление.

* Транзакционные фикстуры выполняются во все активные соединения с базой данных. Можно тестировать модели на различных соединениях без отключения транзакционных фикстур.

* В Active Record добавлены методы `first_or_create`, `first_or_create!`, `first_or_initialize`. Этот подход лучше, чем старые динамические методы `find_or_create_by`, поскольку очевиднее, какие аргументы использованы для поиска записи, а какие для ее создания.

    ```ruby
    User.where(:first_name => "Scarlett").first_or_create!(:last_name => "Johansson")
    ```

* К объектам Active Record добавлен метод `with_lock`, начинающий транзакцию, блокирующий объект (пессимистично) и вызывающий блок. Метод принимает один (опциональный) параметр и передает его в `lock!`.

    Поэтому возможно написать следующее:

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        transaction do
          lock!
          # ... cancelling logic
        end
      end
    end
    ```

    как:

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        with_lock do
          # ... cancelling logic
        end
      end
    end
    ```

### Устаревания

* Устарело автоматическое закрытие соединений в тредах. Для примера, следующий код устарел:

    ```ruby
    Thread.new { Post.find(1) }.join
    ```

    Он должен быть изменен, чтобы закрывать соединение с базой данных в конце треда:

    ```ruby
    Thread.new {
      Post.find(1)
      Post.connection.close
    }.join
    ```

    Об этом должны беспокоиться только те, кто в своих приложениях создает треды.

* Методы `set_table_name`, `set_inheritance_column`, `set_sequence_name`, `set_primary_key`, `set_locking_column` устарели. Используйте вместо них методы назначения. Для примера, вместо `set_table_name` используйте `self.table_name=`.

    ```ruby
    class Project < ActiveRecord::Base
      self.table_name = "project"
    end
    ```

    Или определите собственный метод `self.table_name`:

    ```ruby
    class Post < ActiveRecord::Base
      def self.table_name
        "special_" ` super
      end
    end

    Post.table_name # => "special_posts"

    ```

Active Model
------------

* Добавлен `ActiveModel::Errors#added?` для проверки, была ли добавлена определенная ошибка.

* Добавлена возможность определить строгие валидации с помощью `strict => true`, которые всегда вызывают исключение, когда не проходят.

* Представлен mass_assignment_sanitizer как простое API для замены возможности экранизатора. Также поддерживаются возможность экранизатора :logger (по умолчанию) и :strict.

### Устаревания

* Устарел `define_attr_method` в `ActiveModel::AttributeMethods`, поскольку он использовался только во вспомогательных методах, таких как `set_table_name` в Active Record, которые сами устарели.

* Устарел `Model.model_name.partial_path` в пользу `model.to_partial_path`.

Active Resource
---------------

* Отклики перенаправления: 303 See Other и 307 Temporary Redirect теперь ведут себя как 301 Moved Permanently и 302 Found.

Active Support
--------------

* Добавлен `ActiveSupport:TaggedLogging`, который может обернуть любой стандартный класс `Logger`, чтобы предоставить возможности тегирования.

    ```ruby
    Logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

    Logger.tagged("BCX") { Logger.info "Stuff" }
    # Logs "[BCX] Stuff"

    Logger.tagged("BCX", "Jason") { Logger.info "Stuff" }
    # Logs "[BCX] [Jason] Stuff"

    Logger.tagged("BCX") { Logger.tagged("Jason") { Logger.info "Stuff" } }
    # Logs "[BCX] [Jason] Stuff"
    ```

* Метод `beginning_of_week` в `Date`, `Time` и `DateTime` принимает опциональный аргумент, представляющий день, в который начинается неделя.

* `ActiveSupport::Notifications.subscribed` предоставляет подписки на события, пока выполняется блок.

* Определены новые методы `Module#qualified_const_defined?`, `Module#qualified_const_get` и `Module#qualified_const_set`, являющиеся аналогами соответствующих методов в стандартном API, но принимающие ограниченные имена констант.

* Добавлен `#deconstantize`, дополняющий `#demodulize` в словообразовании. Он убирает самый правый сегмент в ограниченном имени константы.

* Добавлен `safe_constantize`, преобразующий строку в константу, но возвращающий `nil` вместо исключения, если константа (или ее часть) не существует.

* `ActiveSupport::OrderedHash` теперь помечается как extractable при использовании `Array#extract_options!`.

* Добавлены `Array#prepend` как псевдоним для `Array#unshift` и `Array#append` как псевдоним для `Array#<<`.

* Определение пустой строки для Ruby 1.9 было расширено пробелом Unicode. А также в Ruby 1.8 идеографический пробел U`3000 рассматривается как пробел.

* Инфлектор понимает акронимы.

* Добавлены `Time#all_day`, `Time#all_week`, `Time#all_quarter` и `Time#all_year` как способ генерации интервалов.

    ```ruby
    Event.where(:created_at => Time.now.all_week)
    Event.where(:created_at => Time.now.all_day)
    ```

* Добавлена `instance_accessor: false` как опция в `Class#cattr_accessor` и схожих методах.

* Теперь у `ActiveSupport::OrderedHash` иное поведение для `#each` и `#each_pair` при передаче блока, принимающего свои параметры расплющенными.

* Добавлен `ActiveSupport::Cache::NullStore` для использования при разработке и тестировании.

* Убран `ActiveSupport::SecureRandom` в пользу `SecureRandom` из стандартной библиотеки.

### Устаревания

* `ActiveSupport::Base64` устарел в пользу `::Base64`.

* `ActiveSupport::Memoizable` устарел в пользу паттерна запоминания из Ruby.

* `Module#synchronize` устарел без какой-либо замены. Пожалуйста, используйте monitor из стандартной библиотеки ruby.

* Устарели `ActiveSupport::MessageEncryptor#encrypt` и `ActiveSupport::MessageEncryptor#decrypt`.

* Устарел `ActiveSupport::BufferedLogger#silence`. Если хотите приглушить лог в определенном блоке, измените для него уровень лога.

* Устарел `ActiveSupport::BufferedLogger#open_log`. Прежде всего, этот метод не должен быть публичным.

* Поведение `ActiveSupport::BufferedLogger's` в части автоматического создания директории для файла лога устарело. Пожалуйста, убедитесь до инициализации, что директория для файла лога создана.

* Устарел `ActiveSupport::BufferedLogger#auto_flushing`. Или установите уровень синхронизации на соответствующем файловом дескрипторе следующим образом. Или настройте свою файловую систему. Теперь очистку контролирует кэш файловой системы.

    ```ruby
    f = File.open('foo.log', 'w')
    f.sync = true
    ActiveSupport::BufferedLogger.new f
    ```

* Устарел `ActiveSupport::BufferedLogger#flush`. Установите sync на ваш дескриптор или настройте свою файловую систему.
