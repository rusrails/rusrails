Заметки о релизе Ruby on Rails 3.1
==================================

Ключевые новинки в Rails 3.1:

* Streaming
* Обратимые миграции
* Файлопровод (Assets Pipeline)
* jQuery как библиотека JavaScript по умолчанию

Эти заметки о релизе покрывают только основные изменения. Чтобы узнать о различных исправлениях программных ошибок и изменениях, обратитесь к логам изменений или к [списку коммитов](https://github.com/rails/rails/commits/3-1-stable) в главном репозитории Rails на GitHub.

--------------------------------------------------------------------------------

(Upgrading to Rails 3.1) Апгрейд до Rails 3.1
---------------------------------------------

Прежде чем апгрейднуть существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 3.1, необходимо сначала произвести апгрейд до Rails 3 и убедиться, что приложение все еще выполняется так, как нужно. Затем обратите внимание на следующие изменения:

### Rails 3.1 требует как минимум Ruby 1.8.7

Rails 3.1 требует Ruby 1.8.7 или выше. Поддержка всех прежних версий Ruby была официально прекращена, и следует произвести апгрейд как можно раньше. Rails 3.1 также совместим с Ruby 1.9.2.

TIP: Отметьте, что в Ruby 1.8.7 p248 и p249 имеются программные ошибки маршалинга, ломающие Rails. Хотя в Ruby Enterprise Edition это было исправлено, начиная с релиза 1.8.7-2010.02. В ветке 1.9, Ruby 1.9.1 не пригоден к использованию, поскольку он иногда вылетает, поэтому, если хотите использовать 1.9.x перепрыгивайте на 1.9.2 для гладкой работы.

### Что обновить в приложении

Следующие изменения предназначены для апгрейда приложения до Rails 3.1.3, последней версии 3.1.x Rails.

#### Gemfile

Сделайте изменения в вашем `Gemfile`.

```ruby
gem 'rails', '= 3.1.3'
gem 'mysql2'

# Needed for the new asset pipeline
group :assets do
  gem 'sass-rails',   "~> 3.1.5"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier',     ">= 1.0.3"
end

# jQuery is the default JavaScript library in Rails 3.1
gem 'jquery-rails'
```

#### config/application.rb

* Файлопровод требует следующие добавления:

    ```ruby
    config.assets.enabled = true
    config.assets.version = '1.0'
    ```

* Если ваше приложение использует маршрут "/assets", можно изменить префикс, используемый для ассетов, чтобы избежать конфликтов:

    ```ruby
    # Defaults to '/assets'
    config.assets.prefix = '/asset-files'
    ```

#### config/environments/development.rb

* Уберите настройку RJS `config.action_view.debug_rjs = true`.

* Добавьте следующее, если хотите включить файлопровод.

    ```ruby
    # Do not compress assets
    config.assets.compress = false

    # Expands the lines which load the assets
    config.assets.debug = true
    ```

#### config/environments/production.rb

* Снова, большинство изменений относится к файлопроводу. Подробнее о них можно прочитать в руководстве [Asset Pipeline](/asset-pipeline).

    ```ruby
    # Compress JavaScripts and CSS
    config.assets.compress = true

    # Don't fallback to assets pipeline if a precompiled asset is missed
    config.assets.compile = false

    # Generate digests for assets URLs
    config.assets.digest = true

    # Defaults to Rails.root.join("public/assets")
    # config.assets.manifest = YOUR_PATH

    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    # config.assets.precompile `= %w( admin.js admin.css )

    # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
    # config.force_ssl = true
    ```

#### config/environments/test.rb

```ruby
# Configure static asset server for tests with Cache-Control for performance
config.serve_static_assets = true
config.static_cache_control = "public, max-age=3600"
```

#### config/initializers/wrap_parameters.rb

* Добавьте этот файл со следующим содержимым, если хотите оборачивать параметры во вложенный хэш. По умолчанию это включено в новых приложениях.

    ```ruby
    # Be sure to restart your server when you modify this file.
    # This file contains settings for ActionController::ParamsWrapper which
    # is enabled by default.

    # Enable parameter wrapping for JSON. You can disable this by setting :format to an empty array.
    ActiveSupport.on_load(:action_controller) do
      wrap_parameters :format => [:json]
    end

    # Disable root element in JSON by default.
    ActiveSupport.on_load(:active_record) do
      self.include_root_in_json = false
    end
    ```

#### Уберите опции :cache и :concat в хелперах ассетов во вьюхах

* Вместе с Asset Pipeline опции :cache и :concat больше не используются, удалите эти опции из своих вьюх.

Создание приложения Rails 3.1
-----------------------------

```bash
# Нужен установленный руби-гем 'rails'
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

Архитектурные изменения Rails
-----------------------------

### Файлопровод (Assets Pipeline)

Основное изменение в Rails 3.1 это Assets Pipeline. Он делает CSS и JavaScript первосортным кодом, и делает доступной надлежащую организацию, включая использование в плагинах и engine-ах.

Файлопровод работает с помощью [Sprockets](https://github.com/rails/sprockets) и раскрывается в руководстве [Asset Pipeline](/asset-pipeline).

### HTTP Streaming

HTTP Streaming это другое новшество в Rails 3.1. Он позволяет браузеру загружать таблицы стилей и файлы JavaScript, пока сервер все еще генерирует отклик. Это требует Ruby 1.9.2, является опциональным, а также требует настройки веб-сервера, но популярная связка NGINX и Unicorn уже готова предоставлять это преимущество.

### Библиотека JS по умолчанию теперь jQuery

jQuery является библиотекой JavaScript по умолчанию, которая поставляется вместе с Rails 3.1. Но если вы используете Prototype, это просто переключить.

```bash
$ rails new myapp -j prototype
```

### Identity Map

В Active Record имеется Identity Map в Rails 3.1. Identity map содержит ранее загруженные экземпляры записей и возвращает объект, связанный с записью, если к нему обращаются снова. Identity map создается при каждом запросе и уничтожается при его завершении.

Rails 3.1 поставляется с отключенной по умолчанию identity map.

Railties
--------

* jQuery является новой библиотекой JavaScript по умолчанию.

* jQuery и Prototype более не встроенные, а предоставляются как гемы `jquery-rails` и `prototype-rails`.

* Генератор приложения принимает опцию `-j`, которая может быть произвольной строкой. Если передать "foo", в `Gemfile` будет добавлен гем "foo-rails", и манифест JavaScript приложения затребует "foo" и "foo_ujs". В данный момент существуют только "prototype-rails" и "jquery-rails", и эти файлы предоставляются через файлопровод.

* Генерация приложение или плагина запускает `bundle install`, если не определено `--skip-gemfile` или `--skip-bundle`.

* Генераторы контроллера и ресурса теперь автоматически создадут заглушки для ассетов (это может быть отключено с помощью `--skip-assets`). Эти заглушки будут использовать CoffeeScript и Sass, если эти библиотеки доступны.

* Генераторы скаффолда и приложения используют стиль хэшей из Ruby 1.9, когда запущены на Ruby 1.9. Чтобы генерировать старый стиль хэшей, должно быть передано `--old-style-hash`.

* Генератор скаффолда контроллера создает блок формата для JSON вместо XML.

* Логирование Active Record направлено в STDOUT и показывается в консоли.

* Добавлена конфигурация `config.force_ssl`, загружающая промежуточную программу `Rack::SSL` и принуждающую все запросы быть под протоколом HTTPS.

* Добавлена команда `rails plugin new`, генерирующая плагин Rails с gemspec, тестами и пустым приложением для тестирования.

* К стеку промежуточных программ по умолчанию добавлены `Rack::Etag` и `Rack::ConditionalGet`.

* К стеку промежуточных программ по умолчанию добавлена `Rack::Cache`.

* Engine-ы получили большое обновление - их можно монтировать на любой путь, включать ассеты. запускать генераторы и т.д.

Action Pack
-----------

### Action Controller

* Выдается предупреждение, если токен аутентификации CSRF не может быть верифицирован.

* Определите `force_ssl` в контроллере. чтобы принудить браузер передавать данные через протокол HTTPS на конкретно этот контроллер. Для ограничения отдельных экшнов могут быть использованы `:only` или `:except`.

* Чувствительные параметры строки запроса, определенные в `config.filter_parameters`, теперь будут отфильтрованы в логе и из пути запроса.

* Параметры URL, возвращающие `nil` на `to_param`. теперь будут убраны из строки запроса.

* Добавлен `ActionController::ParamsWrapper` для оборачивания параметров во вложенный хэш, и он будет включен в новых приложениях по умолчанию для запроса JSON. Это может быть настроено в `config/initializers/wrap_parameters.rb`.

* Добавлен `config.action_controller.include_all_helpers`. По умолчанию выполняет `helper :all` в `ActionController::Base`, что включает все хелперы по умолчанию. Установка `include_all_helpers` в `false` приведет к включению только application_helper и хелпера. соответствующего контроллеру (подобно foo_helper для foo_controller).

* `url_for` и именованные хелперы _url теперь принимают как опции `:subdomain` и `:domain`.

* Добавлен `Base.http_basic_authenticate_with` для базовой аутентификации HTTP с помощью единственного вызова метода класса.

    ```ruby
    class PostsController < ApplicationController
      USER_NAME, PASSWORD = "dhh", "secret"

      before_filter :authenticate, :except => [ :index ]

      def index
        render :text => "Everyone can see me!"
      end

      def edit
        render :text => "I'm only accessible if you know the password"
      end

      private
        def authenticate
          authenticate_or_request_with_http_basic do |user_name, password|
            user_name == USER_NAME && password == PASSWORD
          end
        end
    end
    ```

    ..теперь может быть написано как

    ```ruby
    class PostsController < ApplicationController
      http_basic_authenticate_with :name => "dhh", :password => "secret", :except => :index

      def index
        render :text => "Everyone can see me!"
      end

      def edit
        render :text => "I'm only accessible if you know the password"
      end
    end
    ```

* Добавлена поддержка streaming, ее можно включить с помощью:

    ```ruby
    class PostsController < ActionController::Base
      stream
    end
    ```

    Можно ограничить некоторые экшны от этого с использованием `:only` или `:except`. Подробности можно прочитать в документации по [`ActionController::Streaming`](http://api.rubyonrails.org/v3.1.0/classes/ActionController/Streaming.html).

* Маршрутный метод redirect теперь принимает хэш опций, меняющих только рассматриваемые части url, или объект, отвечающий на вызов, позволяя повторно использовать редиректы.

### Action Dispatch

* `config.action_dispatch.x_sendfile_header` теперь по умолчанию `nil` и `config/environments/production.rb` не устанавливает какое-либо значение для этого. Это позволяет серверам устанавливать его через `X-Sendfile-Type`.

* `ActionDispatch::MiddlewareStack` теперь использует наследуемую структуру, и больше не является массивом.

* Добавлен `ActionDispatch::Request.ignore_accept_header` для игнорирования заголовков accept.

* Добавлена `Rack::Cache` в стек по умолчанию.

* Ответственность за etag перенесена от `ActionDispatch::Response` в стек промежуточных программ.

* API хранения `Rack::Session` стало более совместимым с остальным в мире Ruby. Оно обратно несовместимо, так как теперь в `Rack::Session` ожидается, что `#get_session` принимает четыре аргумента, и требует `#destroy_session` вместо простого `#destroy`.

* Поиск шаблонов теперь ищет глубже в цепи наследования.

### Action View

* Добавлена опция `:authenticity_token` к `form_tag` для ручного управления, или для отмены, если передать `:authenticity_token => false`.

* Создан `ActionView::Renderer` и определен API для `ActionView::Context`.

* Встроенные мутации `SafeBuffer` запрещены в Rails 3.1.

* Добавлен HTML5 хелпер `button_tag`.

* `file_field` автоматически добавляет `:multipart => true` к внешним формам.

* Добавлена удобная идиома генерировать HTML5 атрибуты data-* в хелперах тегов с хэшем опций `:data`:

    ```ruby
    tag("div", :data => {:name => 'Stephen', :city_state => %w(Chicago IL)})
    # => <div data-name="Stephen" data-city-state="[&quot;Chicago&quot;,&quot;IL&quot;]" />
    ```

Ключи преобразуются в дефисные. Значения кодируются в JSON, кроме строк и символов.

* `csrf_meta_tag` переименован в `csrf_meta_tags` и для него сделан псевдоним `csrf_meta_tag` для обратной совместимости.

* Старое API обработки шаблонов устарело, а новое API просто требует обработчик шаблонов для отклика на вызов.

* rhtml и rxml окончательно убраны из обработчиков шаблонов.

* Вернули `config.action_view.cache_template_loading`, позволяющий решить, должны ли быть кэшированы шаблоны, или нет.

* Хелпер формы submit больше не генерирует id "object_name_id".

* Позволяет `FormHelper#form_for` определить `:method` как опцию первого уровня вместо вкладывания в хэш `:html`. `form_for(==@==post, remote: true, method: :delete)` вместо `form_for(==@==post, remote: true, html: { method: :delete })`.

* Предоставлен `JavaScriptHelper#j()` как псевдоним для `JavaScriptHelper#escape_javascript()`. Это заменило метод `Object#j()`, добавляемый гемом JSON в шаблоны при использовании JavaScriptHelper.

* Позволяет формат AM/PM в datetime selectors.

* `auto_link` был убран из Rails и выделен в [гем rails_autolink](https://github.com/tenderlove/rails_autolink)

Active Record
-------------

* Добавлен метод класса `pluralize_table_names` для склонения по числу имен таблиц отдельных моделей. Ранее это можно было сделать только глобально для всех моделей с помощью `ActiveRecord::Base.pluralize_table_names`.

    ```ruby
    class User < ActiveRecord::Base
      self.pluralize_table_names = false
    end
    ```

* Добавлен блок настроек для одиночных связей. Блок будет вызван после того, как экземпляр будет инициализирован.

    ```ruby
    class User < ActiveRecord::Base
      has_one :account
    end

    user.build_account{ |a| a.credit_limit = 100.0 }
    ```

* Добавлен `ActiveRecord::Base.attribute_names`, возвращающий список имен атрибутов. Он возвратит пустой массив, если модель абстрактная, или таблица не существует.

* Фикстуры CSV устарели и их поддержка будет убрана в Rails 3.2.0.

* `ActiveRecord#new`, `ActiveRecord#create` и `ActiveRecord#update_attributes` принимают второй хэш как опцию, позволяющую определить рассматриваемую роль при назначении атрибутов. Это основа новой возможности массового назначения Active Model:

    ```ruby
    class Post < ActiveRecord::Base
      attr_accessible :title
      attr_accessible :title, :published_at, :as => :admin
    end

    Post.new(params[:post], :as => :admin)
    ```

* `default_scope` теперь может принимать блок, lambda или любой другой объект, отвечающий на call для ленивых вычислений.

* Дефолтные скоупы теперь вычисляются в самый последний момент для избегания проблем, когда могут быть созданы скоупы, которые неявно содержат дефолтный скоуп, от которого впоследствии невозможно будет избавиться с помощью Model.unscoped.

* Адаптер PostgreSQL теперь поддерживает только PostgreSQL версии 8.2 и выше.

* Промежуточная программа `ConnectionManagement` изменилась, чтобы очищать пул соединения после того, как тело rack было уничтожено.

* В Active Record добавлен метод `update_column`. Этот новый метод обновляет заданный атрибут у объекта, пропуская валидации и колбэки. Рекомендовано использовать `update_attributes` или `update_attribute` если вы не уверенны, что не хотите выполнять какой-либо колбэк, включая модификацию столбца `updated_at`. Он не может быть вызван на новых записях.

* Связи с опцией `:through` теперь могут использовать любые связи как посредника или источника, включая другие связи, имеющие опцию `:through`, и связи `has_and_belongs_to_many`.

* Конфигурация для текущего соединения с базой данных теперь доступна с помощью `ActiveRecord::Base.connection_config`.

* Лимиты и смещения убираются из запросов COUNT, кроме случая, когда они оба представлены.

    ```ruby
    People.limit(1).count           # => 'SELECT COUNT(*) FROM people'
    People.offset(1).count          # => 'SELECT COUNT(*) FROM people'
    People.limit(1).offset(1).count # => 'SELECT COUNT(*) FROM people LIMIT 1 OFFSET 1'
    ```

* `ActiveRecord::Associations::AssociationProxy` был разделен. Теперь имеется класс `Association` (и подклассы), ответственные за работу со связями, и отдельная "тонкая" обертка по имени `CollectionProxy`, передающая связи коллекции. Это предотвращает загрязнение пространства имен, разделяет решаемые проблемы, и позволяет дальнейший рефакторинг.

* Одиночные связи (`has_one`, `belongs_to`) больше не имеют прокси, и просто возвращают связанную запись или `nil`. Это означает, что больше не следует использовать недокументированные методы наподобие `bob.mother.create` - используйте вместо этого `bob.create_mother`.

* Поддержка опции `:dependent` для связи `has_many :through`. По историческим и практическим причинам, `:delete_all` является стратегией удаления по умолчанию, используемой в `association.delete(*records)`, несмотря на то, что стратегией по умолчанию для обычного has_many является `:nullify`. Кроме того, это работает только при условии, что вторая сторона связи belongs_to. В других ситуациях следует напрямую модифицировать связь through.

* Изменилось поведение `association.destroy` для `has_and_belongs_to_many` и `has_many :through`. Теперь 'destroy' или 'delete' на связи будет означать 'избавиться от связи', а не (обязательно) 'избавиться от связанных записей'.

* Раньше `has_and_belongs_to_many.destroy(*records)` уничтожал сами записи. Он не удалял какие-либо записи в соединительной таблице. Теперь он удаляет записи в соединительной таблице.

* Раньше `has_many_through.destroy(*records)` удалял сами записи и записи в соединительной таблице. [Отметьте: Это не всегда было так; ранние версии Rails удаляли только сами записи.] Теперь от уничтожает только записи в соединительной таблице.

* Отметьте, что это изменение в некоторой степени обратно не совместимо, но, к сожалению, нет никакого способа объявить его 'deprecate' перед изменением. Изменение было сделано для единообразия в понятиях 'destroy' или 'delete' для различных типов связи. Если хотите уничтожить сами записи, следует выполнить `records.association.each(&:destroy)`.

* В `change_table` добавлена опция `:bulk => true`, чтобы выполнить все изменения схемы, определенные в блоке, с использование одного выражения ALTER.

    ```ruby
    change_table(:users, :bulk => true) do |t|
      t.string :company_name
      t.change :birthdate, :datetime
    end
    ```

* Убрана поддержка доступа к атрибутами в соединительной таблице `has_and_belongs_to_many`. Следует использовать `has_many :through`.

* Добавлен метод `create_association!` для связей `has_one` и `belongs_to`.

* Миграции теперь обратимы, что означает, что Rails теперь понимает, как обратить ваши миграции. Для использования обратимых миграций просто определите метод `change`.

    ```ruby
    class MyMigration < ActiveRecord::Migration
      def change
        create_table(:horses) do |t|
          t.column :content, :text
          t.column :remind_at, :datetime
        end
      end
    end
    ```

* Некоторые вещи не могут быть автоматически обратимы. Если вы знаете, как их обратить. следует в миграциях определить `up` и `down`. Если вы определите какое-либо изменение в change, которое не может быть обращено, при откате миграции будет вызвано исключение `IrreversibleMigration`.

* Теперь миграции используют методы экземпляра вместо методов класса:

    ```ruby
    class FooMigration < ActiveRecord::Migration
      def up # Не self.up
        ...
      end
    end
    ```

* Файлы миграции, сгенерированные с помощью генераторов модели и конструктивной миграции (для примера, add_name_to_users), используют метод обратимой миграции `change` вместо обычных методов `up` и `down`.

* Убрана поддержка интерполяции строк с условиями SQL на связях. Вместо этого должен быть использован proc.

    ```ruby
    has_many :things, :conditions => 'foo = #{bar}'          # до
    has_many :things, :conditions => proc { "foo = #{bar}" } # после
    ```

    Внутри proc, `self` это объект, являющийся владельцем связи, за исключением случая, когда связь лениво загружается, в этом случае `self` это класс, в котором определена связь.

    Внутри proc можно иметь "нормальные" условия, поэтому следующее будет работать:

    ```ruby
    has_many :things, :conditions => proc { ["foo = ?", bar] }
    ```

* Ранее `:insert_sql` и `:delete_sql` на связи `has_and_belongs_to_many` позволяли вызвать 'record' для получения записи, которую нужно вставить или удалить. Теперь это передается как аргумент в proc.

* Добавлен `ActiveRecord::Base#has_secure_password` (через `ActiveModel::SecurePassword`) для инкапсуляции элементарного пароля с использованием шифрования BCrypt и соли.

    ```ruby
    # Schema: User(name:string, password_digest:string, password_salt:string)
    class User < ActiveRecord::Base
      has_secure_password
    end
    ```

* При генерации модели по умолчанию добавляется `add_index` для столбцов `belongs_to` или `references`.

* Установление id для объекта в `belongs_to` обновляет связь с объектом.

* Изменилась семантика `ActiveRecord::Base#dup` и `ActiveRecord::Base#clone`, чтобы более соответствовать семантике обычных методов Ruby dup и clone.

* Вызов `ActiveRecord::Base#clone` приведет к неполной копии записи, включая копирования состояния заморозки. Ни один колбэк не будет вызван.

* Вызов `ActiveRecord::Base#dup` продублирует запись, включая вызов пост-инициализационных хуков. Состояние заморозки не будет скопировано, и все связи будут очищены. Дублированная запись возвратит `true` для `new_record?`, будет иметь `nil` в поле id, и ее можно будет сохранить.

* Кэш запросов теперь работает с prepared statements. Никаких изменений в приложении не требуется.

Active Model
------------

* `attr_accessible` принимает опцию `:as` для определении роли.

* Теперь `InclusionValidator`, `ExclusionValidator` и `FormatValidator` принимают опцию, которая может быть proc, lambda или что угодно, что отвечает на `call`. Эта опция будет вызвана с текущей записью в качестве аргумента, и возвратит объект, отвечающий на `include?` для `InclusionValidator` и `ExclusionValidator`, и возвратит регулярное выражение для `FormatValidator`.

* Добавлен `ActiveModel::SecurePassword` для инкапсуляции элементарного пароля с использованием шифрования BCrypt и соли.

* `ActiveModel::AttributeMethods` Допускает атрибуты, определяемые по требованию.

* Добавлена поддержка для выборочного включения и отключения обсерверов.

* Альтернативный поиск в пространстве имен `I18n` более не поддерживается.

Active Resource
---------------

* Для всех запросов формат по умолчанию был изменен на JSON. Если хотите продолжить использование XML, следует установить `self.format = :xml` в классе. Например,

    ```ruby
    class User < ActiveResource::Base
      self.format = :xml
    end
    ```

Active Support
--------------

* `ActiveSupport::Dependencies` теперь вызывает `NameError`, если находит существующую константу в `load_missing_constant`.

* Добавлен новый метод `Kernel#quietly`, приглушающий `STDOUT` и `STDERR`.

* Добавлен `String#inquiry` как удобный метод для преобразования String в объект `StringInquirer`.

* Добавлен `Object#in?` для проверки, включен ли объект в другой объект.

* Теперь стратегия `LocalCache` является настоящим классом промежуточной программы, а не анонимным классом.

* Был представлен класс `ActiveSupport::Dependencies::ClassCache` как содержащий ссылки на перегружаемые классы.

* Был отрефакторен `ActiveSupport::Dependencies::Reference`, чтобы пользоваться преимуществами нового `ClassCache`.

* Бэкпортирован `Range#cover?` как псевдоним `Range#include?` в Ruby 1.8.

* Добавлены `weeks_ago` и `prev_week` в Date/DateTime/Time.

* Добавлен колбэк `before_remove_const` к `ActiveSupport::Dependencies.remove_unloadable_constants!`.

Устарело:

* `ActiveSupport::SecureRandom` устарел в пользу `SecureRandom` из стандартной библиотеки Ruby.
