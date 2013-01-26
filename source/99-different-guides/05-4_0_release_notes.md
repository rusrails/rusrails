# Заметки о релизе Ruby on Rails 4.0

Ключевые новинки в Rails 4.0:

Эти заметки о релизе покрывают основные обновления, но не включают все мелкие багфиксы и изменения. Чтобы увидеть все, обратитесь к [списку комитов](https://github.com/rails/rails/commits/master) в главном репозитории Rails на GitHub.

Обновление до Rails 4.0
-----------------------

TODO. Это руководство все еще в разработке.


Если обновляете существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 4.0, необходимо сначала обновиться до Rails 3.2 и убедиться, что приложение все еще выполняется так, как нужно. Затем нужно предпринять следующие изменения:

### Rails 4.0 требует как минимум Ruby 1.9.3

Rails 4.0 требует Ruby 1.9.3 или выше. Поддержка всех прежних версий Ruby была официально прекращена, и следует обновиться как можно быстрее.

### Что обновить в приложении

*   Обновите зависимости в вашем Gemfile
    * `rails = 4.0.0`
    * `sass-rails ~> 3.2.3`
    * `coffee-rails ~> 3.2.1`
    * `uglifier >= 1.0.3`

TODO: Эти версии будут изменены

*   Rails 4.0 полностью убирает `vendor/plugins`. Следует переместить эти плагины, выделяя их в гемы и добавляя в свой Gemfile. Если вы не хотите делать из них гемы, можно их переместить, скажем в `lib/my_plugin/*`, и добавить соответствующий инициализатор в `config/initializers/my_plugin.rb`.

TODO: Configuration changes in environment files

Создание приложения Rails 4.0
-----------------------------

```
 Необходим установленный рубигем 'rails'
$ rails new myapp
$ cd myapp
```

### Сторонние гемы

Сейчас Rails использует `Gemfile` в корне приложения, чтобы определить гемы, требуемые для запуска вашего приложения. Этот `Gemfile` обрабатывается гемом [Bundler](http://github.com/carlhuda/bundler), который затем устанавливает все зависимости. Он может даже установить все зависимости локально в ваше приложение, и оно не будет зависеть от системных гемов.

Подробнее: - [Bundler homepage](http://gembundler.com)

### Живите на грани

`Bundler` и `Gemfile` замораживает ваше приложение Rails с помощью новой отдельной команды `bundle`. Если хотите установить напрямую из репозитория Git, передайте флажок `--edge`:

```
$ rails new myapp --edge
```

Если у вас есть локальная копия репозитория Rails, и вы хотите создать приложение с ее использованием, передайте флажок `--dev`:

```
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

Основные особенности
--------------------

Документация
------------

Railties
--------

*   Позволяет генераторам скаффолда/модели/миграции принимать модификатор `polymorphic` для `references`/`belongs_to`, например

    ```
    rails g model Product supplier:references{polymorphic}
    ```

    создаст модель со связью `belongs_to :supplier, polymorphic: true` и соответствующей миграцией.

*   Устанавливает для среды development `config.active_record.migration_error` как `:page_load`.

*   В `Rails::Railtie` добавлен runner в качестве хука, вызываемого только после запуска runner.

*   Добавляет путь `/rails/info/routes`, который отображает ту же информацию, что и `rake routes`.

*   Улучшает вывод `rake routes` для редиректов.

*   Загружает все доступные среды в `config.paths["config/environments"]`.

*   Добавляет `config.queue_consumer` чтобы позволить настройку потребителя очереди по умолчанию.

*   Добавляет `Rails.queue` как интерфейс с реализацией по умолчанию, выполняющей работы в отдельном треде.

*   Убирает `Rack::SSL` в пользу `ActionDispatch::SSL`.

*   Позволяет установить класс, оторый будет использован для запуска в качестве консоли, иной, чем IRB, с помощью `Rails.application.config.console=`. Лучше всего ее добавить в блок console.

    ```ruby
    # это будет добавлено в config/application.rb
    console do
      # этот блок вызывается только при запуске консоли,
      # поэтому можно тут безопасно вызвать pry
      require "pry"
      config.console = Pry
    end
    ```

*   Добавляет удобный метод `hide!` в генераторы Rails, чтобы скрыть от отображения пространство имен текущего генератора при запуске `rails generate`.

*   Скаффолды теперь используют `content_tag_for` в `index.html.erb`.

*   Убран `Rails::Plugin`. Вместо добавления плагинов в `vendor/plugins`, используйте гемы, или bundler с путем, или зависимости git.

### Устарело

Action Mailer
-------------

*   Позволяет установить опции Action Mailer по умолчанию с помощью `config.action_mailer.default_options=`.

*   Вызывает исключение `ActionView::MissingTemplate`, когда не может быть найден ни один подходящий шаблон.

*   Посылает сообщения асинхронно с помощью Rails Queue.

*   Опции доставки (такие как настройки SMTP) теперь могут устанавливаться динамически для каждого экшна рассыльщика.

    Опции доставки устанавливаются с помощью ключа `:delivery_method_options` на mail.

    ```ruby
    def welcome_mailer(user,company)
      mail to: user.email,
           subject: "Welcome!",
           delivery_method_options: {user_name: company.smtp_user,
                                     password: company.smtp_password,
                                     address: company.smtp_server}
    end
    ```

Action Pack
-----------

### Action Controller

*   Добавлен метод `ActionController::Flash.add_flash_types`, чтобы позволить регистрацию собственный типов flash, т.е.:

    ```ruby
    class ApplicationController
      add_flash_types :error, :warning
    end
    ```

    При добавлении такого кода, можно использовать `<%= error %>` в erb и `redirect_to /foo, :error => 'message'` в контроллере.

*   Из Action Pack убрана зависимость от Active Model.

*   Поддержка символов unicode в маршрутах. Маршруты будут автоматически экранироваться, поэтому вместо ручного экранирования:

    ```ruby
    get Rack::Utils.escape('こんにちは') => 'home#index'
    ```

    Можно всего лишь написать маршрут в unicode:

    ```ruby
    get 'こんにちは' => 'home#index'
    ```

*   Возвращает модходящий формат в исключениях.

*   Из `ActionController::ForceSSL::ClassMethods.force_ssl` логика редиректов извлечена в `ActionController::ForceSSL#force_ssl_redirect`.

*   Параметры пути URL в неправильной кодировке теперь вызывают `ActionController::BadRequest`.

*   Неправильно составленные хэши в строке запроса или в параметрах запроса теперь вызывают `ActionController::BadRequest`.

*   `respond_to` и `respond_with` теперь вызывают `ActionController::UnknownFormat` вместо непосредственного возврата заголовка 406. Исключение отлавливается и конвертируется в 406 в промежуточной программе обработки исключений.

*   JSONP теперь использует `application/javascript` вместо `application/json` в качестве типа MIME.

*   Аргументы сессии, переданные в вызовы процесса в функциональных тестах, теперь объединяются с существующей сессией, в то время как раньше они заменяли существующую сессию. Это изменение может сломать некоторые существующие тесты, если они проверяли точный состав сессии, но не сломает существующие тесты, которые проверяли только отдельные ключи.

*   Формы для сохраненных записей всегда используют PATCH (с помощью хака `_method`).

*   Для ресурсов и PATCH, и PUT ведут на экшн `update`.

*   В режиме development не игнорируется `force_ssl`. Это изменение в поведении - используйте условие `:if`, чтобы воссоздать старое поведение.

    ```ruby
    class AccountsController < ApplicationController
      force_ssl :if => :ssl_configured?

      def ssl_configured?
        !Rails.env.development?
      end
    end
    ```

#### Устарело

*   Устарел `ActionController::Integration` в пользу `ActionDispatch::Integration`.

*   Устарел `ActionController::IntegrationTest` в пользу `ActionDispatch::IntegrationTest`.

*   Устарел `ActionController::PerformanceTest` в пользу `ActionDispatch::PerformanceTest`.

*   Устарел `ActionController::AbstractRequest` в пользу `ActionDispatch::Request`.

*   Устарел `ActionController::Request` в пользу `ActionDispatch::Request`.

*   Устарел `ActionController::AbstractResponse` в пользу `ActionDispatch::Response`.

*   Устарел `ActionController::Response` в пользу `ActionDispatch::Response`.

*   Устарел `ActionController::Routing` в пользу `ActionDispatch::Routing`.

### Action Dispatch

*   Добавлен Routing Concerns для объявления общих маршрутов, которые могут быть повторно использованы в других ресурсах и маршрутах.

    Код до:

    ```ruby
    resources :messages do
      resources :comments
    end

    resources :posts do
      resources :comments
      resources :images, only: :index
    end
    ```

    Код после:

    ```ruby
    concern :commentable do
      resources :comments
    end

    concern :image_attachable do
      resources :images, only: :index
    end

    resources :messages, concerns: :commentable

    resources :posts, concerns: [:commentable, :image_attachable]
    ```

*   Показывает маршруты на странице исключения во время отладки `RoutingError` в режиме development.

*   Включены по умолчанию `mounted_helpers` (хелперы для доступа к монтируемым engine-ам) в `ActionDispatch::IntegrationTest`.

*   Добавлена промежуточная программа `ActionDispatch::SSL`, при включении которой все запросы принуждаются быть под протоколом HTTPS.

*   Заполняет определенные маршрутные ограничения значениями по умолчанию, таким образом при генерации url о них известно. Заполняемыми ограничениями являются `:protocol`, `:subdomain`, `:domain`, `:host` и `:port`.

*   Позволяет `assert_redirected_to` соответствовать регулярному выражению.

*   Добавлена трассировка на странице ошибки роутинга в режиме development.

*   `assert_generates`, `assert_recognizes` и `assert_routing` вызывают `Assertion` вместо `RoutingError`.

*   Позволяет маршрутному хелперу root принимать строковый аргумент. Например, `root 'pages#main'` как ярлык для `root to: 'pages#main'`.

*   Добавлена поддержка метода PATCH: объекты Request отвечают на `patch?`. В маршрутах теперь имеется новый метод `patch`, и понимается `:patch` в существующих местах, где настраивается метод, например `:via`. В функциональных тестах имеется новый метод `patch`, а в интеграционных тестах имеется новый метод `patch_via_redirect`.

    Так как `:patch` является методом по умолчанию для обновлений, правки туннелируются как `PATCH`, а не как `PUT`, и роутинг работает соответственно.

*   Интеграционные тесты поддерживают метод OPTIONS.

*   `expires_in` принимает флажок `must_revalidate`. Если true, в заголовок `Cache-Control` добавляется "must-revalidate".

*   Responder по умолчанию будет всегда использовать переопределенный вами блок в `respond_with` для рендеринга отклика.

*   Выключен многословный режим в `rack-cache`, у нас все еще имеется `X-Rack-Cache` для проверки этой информации.

#### Устарело

### Action View

*   Из Action Pack убрана зависимость от Active Model.

*   Разрешено использование `mounted_helpers` (хелперов для доступа к смонтированным engine-ам) в `ActionView::TestCase`.

*   Сделаны доступными переменные текущего объекта и счетчика (когда это применимо) при рендеринге шаблонов с помощью `:object` или `:collection`.

*   Доступна ленивая загрузка `default_form_builder` при передаче строки вместо константы.

*   Добавлен метод index в класс `FormBuilder`.

*   Добавлена поддержка макетов при рендеринге партиала с заданной коллекцией.

*   Убран `:disable_with` в пользу опции `data-disable-with` из хелперов `submit_tag`, `button_tag` и `button_to`.

*   Убрана опция `:mouseover` из хелпера `image_tag`.

*   Шаблоны без расширения обработчика теперь вызывают предупреждение об устаревании, но все еще по умолчанию `ERb`. В будущих релизах будет просто возвращаться содержимое шаблона.

*   В `grouped_options_for_select` добавлена опция `divider` для автоматической генерации разделителя групп опций, и устаревает подсказка (prompt) в качестве третьего аргумента в пользу использования хэша опций.

*   Добавлены хелперы `time_field` и `time_field_tag`, которые рендерят тег `input[type="time"]`.

*   Убраны старые api `text_helper` для `highlight`, `excerpt` и `word_wrap`.

*   Убран ведущий \n, добавляемый textarea при `assert_select`.

*   Изменено значение по умолчанию для `config.action_view.embed_authenticity_token_in_remote_forms` в false. Это изменение ломает удаленные формы, которые также должны работать без JavaScript, поэтому, если нужно такое поведение, можно либо установить его в true, либо явно передать  `:authenticity_token => true` в опциях формы.

*   Стало возможным использовать блок в хелпере `button_to`, если текст кнопки трудно вместить в параметр name:

    ```ruby
    <%= button_to [:make_happy, @user] do %>
      Make happy <strong><%= @user.name %></strong>
    <% end %>
    # => "<form method="post" action="/users/1/make_happy" class="button_to">
    #      <div>
    #        <button type="submit">
    #          Make happy <strong>Name</strong>
    #        </button>
    #      </div>
    #    </form>"
    ```

*   Заменен булев аргумент `include_seconds` на опцию `:include_seconds => true` в `distance_of_time_in_words` и `time_ago_in_words`.

*   Убраны хелперы `button_to_function` и `link_to_function`.

*   Сейчас `truncate` всегда возвращает экранированную HTML-безопасную строку. Опция `:escape` может быть использована как `false`, чтобы не экранировать результат.

*   Сейчас `truncate` принимает блок для показа дополнительного содержимого, когда текст обрезается.

*   Добавлены хелперы `week_field`, `week_field_tag`, `month_field`, `month_field_tag`, `datetime_local_field`, `datetime_local_field_tag`, `datetime_field` и `datetime_field_tag`.

*   Добавлены хелперы `color_field` и `color_field_tag`.

*   Добавлена опция `include_hidden` в тег select. С `:include_hidden => false` select с множественными атрибутами не создает скрытое поле с пустым значением.

*   Убрана опция size по умолчанию из хелперов `text_field`, `search_field`, `telephone_field`, `url_field`, `email_field`.

*   Убраны опции cols и rows по умолчанию из хелпера `text_area`.

*   Добавлены `image_url`, `javascript_url`, `stylesheet_url`, `audio_url`, `video_url` и `font_url` в хелперы тегов ресурсов. Эти хелперы URL возвратят полный путь к вашим ресурсам. Это полезно, когда вы собираетесь сослаться на этот ресурс с внешнего хоста.

*   Позволяет аргументам `value_method` и `text_method` из `collection_select` и `options_from_collection_for_select` получать объект, отвечающий на `:call`, такой как proc, для вычисления опции в контектсе текущего элемента. Это работает так же, как для `collection_radio_buttons` и `collection_check_boxes`.

* Добавлены хелперы `date_field` и `date_field_tag`, которые рендерят тег `input[type="date"]`.

* Добавлен хелпер формы `collection_check_boxes`, похожий на `collection_select`:

    ```ruby
    collection_check_boxes :post, :author_ids, Author.all, :id, :name
    # Выводит что-то наподобие:
    <input id="post_author_ids_1" name="post[author_ids][]" type="checkbox" value="1" />
    <label for="post_author_ids_1">D. Heinemeier Hansson</label>
    <input id="post_author_ids_2" name="post[author_ids][]" type="checkbox" value="2" />
    <label for="post_author_ids_2">D. Thomas</label>
    <input name="post[author_ids][]" type="hidden" value="" />
    ```

    Пары label/check_box могут быть настроены в блоке.

*   Добавлен хелпер формы `collection_radio_buttons`, похожий на `collection_select`:

    ```ruby
    collection_radio_buttons :post, :author_id, Author.all, :id, :name
    # Выводит что-то наподобие:
    <input id="post_author_id_1" name="post[author_id]" type="radio" value="1" />
    <label for="post_author_id_1">D. Heinemeier Hansson</label>
    <input id="post_author_id_2" name="post[author_id]" type="radio" value="2" />
    <label for="post_author_id_2">D. Thomas</label>
    ```

    Пары label/radio_button могут быть настроены в блоке.

*   `check_box` с атрибутом HTML5 `:form` теперь будет копировать атрибут `:form` также в скрытое поле.

*   хелпер формы label принимает `:for => nil`, чтобы не генерировать аттрибут.

*   Добавлена опция `:format` в `number_to_percentage`.

*   Добавлена `config.action_view.logger` для настройки логгера для `Action View`.

*   Хелпер `check_box` с `:disabled => true` теперь создает скрытое `disabled` поле для приспосабливания к соглашению HTML, что отключенные поля не отправляются формой. Это изменение поведения, раньше скрытый тег имел значение отключенного checkbox.

*   Хелпер `favicon_link_tag` теперь по умолчанию будет использовать favicon в `app/assets`.

*   Теперь `ActionView::Helpers::TextHelper#highlight` по умолчанию элемент HTML5 `mark`.

#### Устарело

### Sprockets

Перемещены в отдельный гем `sprockets-rails`.

Active Record
-------------

*   Добавлены выражения схемы `add_reference` и `remove_reference`. Также принимаются псевдонимы `add_belongs_to` и `remove_belongs_to`. Отношения обратимы.

    ```ruby
    # Создаст столбец user_id
    add_reference(:products, :user)

    # Создаст столбцы supplier_id, supplier_type и соответствующие индексы
    add_reference(:products, :supplier, polymorphic: true, index: true)

    # Уберет полиморфное отношение
    remove_reference(:products, :supplier, polymorphic: true)
    ```

*   Добавлены опции `:default` и `:null` в `column_exists?`.

    ```ruby
    column_exists?(:testings, :taggable_id, :integer, null: false)
    column_exists?(:testings, :taggable_type, :string, default: 'Photo')
    ```

*   `ActiveRecord::Relation#inspect` делает более понятным, что вы работаете с объектом `Relation`, а не с массивом:

    ```ruby
    User.where(:age => 30).inspect
    # => <ActiveRecord::Relation [#<User ...>, #<User ...>]>

    User.where(:age => 30).to_a.inspect
    # => [#<User ...>, #<User ...>]
    ```

    если relation возвратит более 10 элементов, inspect покажет только первые 10 и затем многоточие.

*   Добавлена поддержка `:collation` и `:ctype` в PostgreSQL. Они доступны для PostgreSQL 8.4 или выше.

    ```yaml
    development:
      adapter: postgresql
      host: localhost
      database: rails_development
      username: foo
      password: bar
      encoding: UTF8
      collation: ja_JP.UTF8
      ctype: ja_JP.UTF8
    ```

*   `FinderMethods#exists?` сейчас возвращает `false` с аргументом `false`.

*   Добавлена поддержка для определения точности временной метки в адаптере postgresql. Поэтому вместо неправильного определения точности с помощью опции `:limit`, можно по назначению использовать `:precision`. Например, в миграции:

    ```ruby
    def change
      create_table :foobars do |t|
        t.timestamps :precision => 0
      end
    end
    ```

*   Позволяет `ActiveRecord::Relation#pluck` принимать несколько столбцов. Возвращает массив массивов, содержащих приведенные значения:

    ```ruby
    Person.pluck(:id, :name)
    # SELECT people.id, people.name FROM people
    # => [[1, 'David'], [2, 'Jeremy'], [3, 'Jose']]
    ```

*   Улучшает образование имени соединительной таблицы HABTM, принимая во внимание вложенность. Теперь берутся имена таблиц двух моделей, сортируются по алфавиту и соединяются, отбрасывая любой общий префикс от второго имени таблицы. Несколько примеров:

    ```
    Модели верхнего уровня (Category <=> Product)
    Раньше: categories_products
    Сейчас: categories_products

    Модели верхнего уровня с глобальным global table_name_prefix (Category <=> Product)
    Раньше: site_categories_products
    Сейчас: site_categories_products

    Вложенные модели в модуле без метода table_name_prefix (Admin::Category <=> Admin::Product)
    Раньше: categories_products
    Сейчас: categories_products

    Вложенные модели в модуле с методом table_name_prefix (Admin::Category <=> Admin::Product)
    Раньше: categories_products
    Сейчас: admin_categories_products

    Вложенные модели в родительскую модель (Catalog::Category <=> Catalog::Product)
    Раньше: categories_products
    Сейчас: catalog_categories_products

    Вложенные модели в различные родительские модели (Catalog::Category <=> Content::Page)
    Раньше: categories_pages
    Сейчас: catalog_categories_content_pages
    ```

*   Проверки валидации HABTM перемещены в `ActiveRecord::Reflection`. Побочным эффектом этого является момент, когда вызываются исключения, он перемещен из точки объявления в точку, где создается связь. Это согласуется с проверками валидации других связей.

*   Добавлен хэш `stored_attributes`, содержащий атрибуты, хранящиеся с использованием `ActiveRecord::Store`. Это позволяет получить список атрибутов, которые вы определили.

    ```ruby
    class User < ActiveRecord::Base
      store :settings, accessors: [:color, :homepage]
    end

    User.stored_attributes[:settings] # [:color, :homepage]
    ```

*   Уровень лога по умоланию для PostgreSQL теперь 'warning', чтобы пропустить шумные сообщения notice. Уровень лога можно изменить с использованием опции `min_messages`, доступной в вашем `config/database.yml`.

*   Добавлена поддержка типа данных uuid для адаптера PostgreSQL.

*   Добавлен `ActiveRecord::Migration.check_pending!`, вызывающий ошибку, если миграции ожидают выполнения.

*   Добавлен `#destroy!`, который работает подобно `#destroy`, но вызывает исключение `ActiveRecord::RecordNotDestroyed` вместо возврата `false`.

*   Позволяет блок для count с `ActiveRecord::Relation`, для подобия с `Array#count`: `Person.where("age > 26").count { |person| person.gender == 'female' }`

*   Добавлена поддержка `CollectionAssociation#delete` для передачи числового или строкового значения как идентификаторы записи. Он находит записи, соответствующие идентификаторам и удаляет их.

    ```ruby
    class Person < ActiveRecord::Base
      has_many :pets
    end

    person.pets.delete("1")  # => [#<Pet id: 1>]
    person.pets.delete(2, 3) # => [#<Pet id: 2>, #<Pet id: 3>]
    ```

*   Больше невозможно удалить модель, помеченную как только для чтения.

*   В `ActiveRecord::Relation#from` добавлена возможность принимать другие объекты `ActiveRecord::Relation`.

*   Добавлена поддержка произвольного кодирования для `ActiveRecord::Store`. Тепрье можно установить собственное кодирование следующим образом:

    ```ruby
    store :settings, accessors: [ :color, :homepage ], coder: JSON
    ```

*   Соединения `mysql` и `mysql2` устанавливают по умолчанию `SQL_MODE=STRICT_ALL_TABLES`, чтобы избежать тихой потери данных. Это может быть отключено, определив `strict: false` в `config/database.yml`.

*   Добавлено упорядочивание по умолчанию в `ActiveRecord::Base#first` для обеспечения стабильного результата в разных движках баз данных. Представлен `ActiveRecord::Base#take` как замена старому поведению.

*   Добавлена опция `:index` для автоматического создания индексов для выражений `references` и `belongs_to` в миграциях. Она может быть либо булевым значением, либо хэшем, идентичным опциям, доступным для метода `add_index`:

    ```ruby
    create_table :messages do |t|
      t.references :person, :index => true
    end
    ```

    То же самое, что и:

    ```ruby
    create_table :messages do |t|
      t.references :person
    end
    add_index :messages, :person_id
    ```

    Генераторы также были обновлены для использования нового синтаксиса.

*   Добавлены восклицательные методы для мутации объектов `ActiveRecord::Relation`. Например, если `foo.where(:bar)` возвратит новый объект, оставив foo неизмененным, `foo.where!(:bar)` изменит объект foo.

*   Добавлены `#find_by` и `#find_by!` для отражения функционала, предоставляемого динамическими методами поиска, способом, делающим динамический ввод более простым:

    ```ruby
    Post.find_by name: 'Spartacus', rating: 4
    Post.find_by "published_at < ?", 2.weeks.ago
    Post.find_by! name: 'Spartacus'
    ```

*   Добавлен `ActiveRecord::Base#slice`, возвращающий хэш заданных методов с их именами в качестве ключей и возвращенными значениями в качестве значений.

*   Убрана IdentityMap - IdentityMap так и не стала возможностью "включенной по умолчанию", из-за некоторых несоответствий со связями, как объяснено в этом [коммите](https://github.com/rails/rails/commit/302c912bf6bcd0fa200d964ec2dc4a44abe328a6). Таким образом, она убрана из кода, пока некоторые вопросы не будут решены.

*   Добавлена возможность для выгрузки/загрузки внутреннего состояния экземпляра `SchemaCache`, так как мы хотим более быструю загрузку, когда имеетмя много моделей.

    ```ruby
    # запустите таск rake.
    RAILS_ENV=production bundle exec rake db:schema:cache:dump
    => generate db/schema_cache.dump

    # добавьте config.use_schema_cache_dump = true в config/production.rb. Кстати, true по умолчанию.

    # загрузите rails.
    RAILS_ENV=production bundle exec rails server
    => use db/schema_cache.dump

    # Если нужно убрать выгруженный кеш, запустите таск rake.
    RAILS_ENV=production bundle exec rake db:schema:cache:clear
    => remove db/schema_cache.dump
    ```

*   Добавлена поддержка для частичных индексов в адаптере `PostgreSQL`.

*   Метод `add_index` теперь поддерживает опцию `where`, которая получает строку с критерием частичного индекса.

*   Добавлен класс `ActiveRecord::NullRelation`, реализующий паттерн нулевого объекта для класса Relation.

*   Реализован метод `ActiveRecord::Relation#none`, возвращающий сцепливаемый relation с нулем записей (экземпляр класса `NullRelation`). Любое последующее условие, прицепленное к возвращенному relation, будет продолжать создавать пустой relation, и не будет передавать какие-либо запросы в базу данных.

*   Добавлен миграционный хелпер `create_join_table` для создания соединительных таблиц HABTM.

    ```ruby
    create_join_table :products, :categories
    # =>
    # create_table :categories_products, :id => false do |td|
    #   td.integer :product_id, :null => false
    #   td.integer :category_id, :null => false
    # end
    ```

*   Первичный ключ всегда инициализируется в хэше `@attributes` как nil (пока не будет определено другое значение).

*   В предыдущих релизах следующее создавало один запрос с OUTER JOIN comments, а не два отдельных запроса:

    ```ruby
    Post.includes(:comments).where("comments.name = 'foo'")
    ```

    Это поведение полагалось на соответствии строки SQL, что было изначально порочной идеей, пока мы не написали парсер SQL, что мы не хотели делать. Следовательно, это устарело.

    Чтобы избежать предупрежедний об устаревании и для будущей совместимости, нужно явно отметить, на какие таблицы вы ссылаетесь при использовании фрагмента SQL:

    ```ruby
    Post.includes(:comments).where("comments.name = 'foo'").references(:comments)
    ```

    Отметьте, что в следующих случаях не нужно явно определять ссылки, так как они автоматически подразумеваются:

    ```ruby
    Post.where(comments: { name: 'foo' })
    Post.where('comments.name' => 'foo')
    Post.order('comments.name')
    ```

    Также об этом не нужно беспокоитсья, если вы не делаете ленивой загружки. В общем, не беспокойтесь, если не увидите предупреждения об устарении или (в будущих релизах) ошибки SQL об отсутствующем JOIN.

*   Поддержка таблицы `schema_info` была удалена. Переключитесь на `schema_migrations`.

*   Соединения *должны* быть закрыты в конце треда. Если не так, ваш пул подключений переполнится и будет вызвано исключение.

*   Добавлен модуль `ActiveRecord::Model`, который может быть включен в класс, как альтернатива наследованию от `ActiveRecord::Base`:

    ```ruby
    class Post
      include ActiveRecord::Model
    end
    ```

*   Могут быть созданы записи PostgreSQL hstore.

*   Тип PostgreSQL hstore автоматически десериализуется из базы данных.

### Устарело

* Устарело большинство из методов 'динамического поиска'. Все динамические методы, кроме `find_by_...` и `find_by_...!` устарели. Вот как можно переписать код:

    ```ruby
    find_all_by_... может быть переписан с использованием where(...)
    find_last_by_... может быть переписан с использованием where(...).last
    scoped_by_... может быть переписан с использованием where(...)
    find_or_initialize_by_... может быть переписан с использованием where(...).first_or_initialize
    find_or_create_by_... может быть переписан с использованием where(...).first_or_create
    find_or_create_by_...! может быть переписан с использованием where(...).first_or_create!
    ```

    Реализация устаревших динамических методов поиска была перемещена в гем `active_record_deprecated_finders`.

*   Устарел старый API поиска, основанный на хэше. Это означает, что методы, ранее принимающие "опции поиска", больше так не делают. Например, это:

    ```ruby
    Post.find(:all, :conditions => { :comments_count => 10 }, :limit => 5)
    ```

    должно быть переписано в новом стиле, появившемся в Rails 3:

    ```ruby
    Post.where(comments_count: 10).limit(5)
    ```

    Отметьте, что как промежуточный шаг, возможно переписать вышеуказанное как:

    ```ruby
    Post.scoped(:where => { :comments_count => 10 }, :limit => 5)
    ```

    Это сможет спасти вам много времени, если в вашем приложении много использования методов поиска в старом стиле.

    Вызов `Post.scoped(options)` это ярлык для `Post.scoped.merge(options)`. `Relation#merge` теперь принимает хэш опций, но они должны быть идентичны именам соответствующих методов поиска. Они в основном такие же, как имена опций поиска старого стиля, за исключением следующих случаев:

    ```
    :conditions стал :where
    :include стал :includes
    :extend стал :extending
    ```

    Код, реализующий устаревшие возможности, был перемещен в гем `active_record_deprecated_finders`. Этот гем является зависимостью для Active Record в Rails 4.0. Он больше не будет зависимостью, начиная с Rails 4.1, но если ваше приложение полагается на устаревшие возможности, его можно добавить в ваш Gemfile. Он будет поддерживаться командой Rails до того момента, пока не выйдет Rails 5.0.

*   Устарели лениво вычисляемые скоупы.

    Не используйте это:

    ```ruby
    scope :red, where(color: 'red')
    default_scope where(color: 'red')
    ```

    Используйте это:

    ```ruby
    scope :red, -> { where(color: 'red') }
    default_scope { where(color: 'red') }
    ```

    Предшествующий вариант имел ряд вопросов. Наиболее обычным для новичков был следующим:

    ```ruby
    scope :recent, where(published_at: Time.now - 2.weeks)
    ```

    Или более утонченный вариант:

    ```ruby
    scope :recent, -> { where(published_at: Time.now - 2.weeks) }
    scope :recent_red, recent.where(color: 'red')
    ```

    Ленивые скоупы были также очень сложно реализованы в Active Record, и там всегда были баги. Например, делает не то, что от него ожидается:

    ```ruby
    scope :remove_conditions, except(:where)
    where(...).remove_conditions # => все еще есть условие
    ```

*   Устарела опция связей `:dependent => :restrict`.

*   До сих пор в `has_many` и `has_one`, опция `:dependent => :restrict` вызывала `DeleteRestrictionError` во время уничтожения объекта. Вместо этого, она будет добавлять ошибку в модель.

*   Чтобы исправить это предупреждение, убедитесь, что ваш код не полагается на `DeleteRestrictionError`, и затем добавьте `config.active_record.dependent_restrict_raises = false` в конфиг вашего приложения.

*   Новое приложение rails будет создано с `config.active_record.dependent_restrict_raises = false` в конфиге приложения.

*   Генератор миграции теперь создает соединительную таблицу с (закомментированными) индексами каждый раз, когда имя миграции содержит слово "join_table".

*   `ActiveRecord::SessionStore` убран из Rails 4.0 и теперь является отдельным [гемом](https://github.com/rails/activerecord-session_store).

Active Model
------------

*   Изменено значение по умолчанию `AM::Serializers::JSON.include_root_in_json` в false. Теперь, у сериализаторов AM и объектов AR одинаковое поведение.

    ```ruby
    class User < ActiveRecord::Base; end

    class Person
      include ActiveModel::Model
      include ActiveModel::AttributeMethods
      include ActiveModel::Serializers::JSON

      attr_accessor :name, :age

      def attributes
        instance_values
      end
    end

    user.as_json
    => {"id"=>1, "name"=>"Konata Izumi", "age"=>16, "awesome"=>true}
    # root is not included

    person.as_json
    => {"name"=>"Francesco", "age"=>22}
    # root is not included
    ```

*   Передача значений false в хэше в `validates` больше не будет включать соответствующие валидаторы.

*   Сообщения об ошибке `ConfirmationValidator` будут присоединяться к `:#{attribute}_confirmation` вместо `attribute`.

*   Добавлен `ActiveModel::Model`, примесь, чтобы объекты Ruby могли работать с Action Pack "из коробки".

*   `ActiveModel::Errors#to_json` Поддерживает новый параметр `:full_messages`.

*   Урезано API удалением `valid?` и `errors.full_messages`.

### Устарело

Active Resource
---------------

*   Active Resource удален из Rails 4.0, и теперь это отдельный [гем](https://github.com/rails/activeresource).

Active Support
--------------

*   Добавлены значения по умолчанию во все методы `ActiveSupport::NumberHelper`, чтобы избежать ошибок с пустыми локалями или отсутствующими значениями.

*   Теперь `Time#change` работает со значениями времени со смещениями иными, чем UTC или текущая временная зона.

*   Добавлены `Time#prev_quarter` и `Time#next_quarter` как методы-сокращения для `months_ago(3)` and `months_since(3)`.

*   Убран устаревший и неиспользуемый метод `require_association` из зависимостей.

*   Добавлена опция `:instance_accessor` для `config_accessor`.

    ```ruby
    class User
      include ActiveSupport::Configurable
      config_accessor :allowed_access, instance_accessor: false
    end

    User.new.allowed_access = true # => NoMethodError
    User.new.allowed_access        # => NoMethodError
    ```

*   Методы `ActionView::Helpers::NumberHelper` были перемещены в `ActiveSupport::NumberHelper`, и теперь доступны с помощью `Numeric#to_s`.

*   `Numeric#to_s` теперь принимает опции форматирования :phone, :currency, :percentage, :delimited, :rounded, :human и :human_size.

*   Добавлены `Hash#transform_keys`, `Hash#transform_keys!`, `Hash#deep_transform_keys` и `Hash#deep_transform_keys!`.

*   Изменен тип xml datetime на dateTime (с заглавной буквой T).

*   Добавлена опция `:instance_accessor` для `class_attribute`.

*   Теперь `constantize` ищет в цепочке предков.

*   Добавлены `Hash#deep_stringify_keys` и `Hash#deep_stringify_keys!` для конвертации всех ключей из экземпяра `Hash` в строки.

*   Добавлены `Hash#deep_symbolize_keys` и `Hash#deep_symbolize_keys!` для конвертации всех ключей из экземпяра `Hash` в символы.

*   `Object#try` не вызывает приватные методы.

*   В AS::Callbacks#run_callbacks убран аргумент ключа.

*   Теперь `deep_dup` works работает более предсказуемо и также дублирует значения в экземплярах `Hash` и элементы в экземплярах `Array`.

*   Inflector больше не применяет ice -> ouse к словам, таким как slice, police.

*   Добавлена `ActiveSupport::Deprecations.behavior = :silence` для полного игнорирования устареваний Rails во время выполнения.

*   `Module#delegate` может остановить использование send - больше не поддерживается делегация приватных методов.

*   В AS::Callbacks устарела опция :rescuable.

*   Добавлен `Integer#ordinal`, чтобы получить порядковый суффикс для числа.

*   В AS::Callbacks опция :per_key больше не поддерживается.

*   В AS::Callbacks#define_callbacks добавлена опция :skip_after_callbacks_if_terminated.

*   Добавлен html_escape_once в ERB::Util, и хелпер тега escape_once делегирован на него.

*   Убран метод `ActiveSupport::TestCase#pending`, используйте вместо него `skip`.

*   Удален метод совместимости `Module#method_names`, с этого момента используйте `Module#methods` (который возвращает символы).

*   Удален метод совместимости `Module#instance_method_names`, с этого момента используйте `Module#instance_methods` (который возвращает символы).

*   База данных Unicode обновлена до 6.1.0.

*   Добавлена опция `encode_big_decimal_as_string` для принуждения сериализации JSON для BigDecimals как числового значения вместо оборачивания их в строки для безопасности.

### Устарело

*   `ActiveSupport::Callbacks`: устарело использование объекта фильтра с методами `#before` и `#after` как колбэка `around`.

*   Устарел `BufferedLogger`. Используйте `ActiveSupport::Logger` или `logger` из Ruby stdlib.

*   Устарел метод совместимости `Module#local_constant_names`, используйте вместо него `Module#local_constants` (который возвращает символы).
