Заметки о релизе Ruby on Rails 4.0
==================================

Ключевые новинки в Rails 4.0:

* Ruby 2.0 предпочтителен; 1.9.3+ требуется
* Строгие параметры (Strong Parameters)
* Turbolinks
* Кэширование "матрешкой" (Russian Doll Caching)

Эти заметки о релизе покрывают только основные изменения. Чтобы узнать о различных исправлениях программных ошибок и изменениях, обратитесь к логам изменений или к [списку коммитов](https://github.com/rails/rails/commits/4-0-stable) в главном репозитории Rails на GitHub.

Апгрейд до Rails 4.0
--------------------

Прежде чем апгрейднуть существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 4.0, необходимо сначала произвести апгрейд до Rails 3.2 и убедиться, что приложение все еще выполняется так, как нужно. Список вещей, которые нужно выполнить для апгрейда доступен в руководстве [Апгрейд Ruby on Rails](/upgrading-ruby-on-rails#upgrading-from-rails-3-2-to-rails-4-0)

Создание приложения Rails 4.0
-----------------------------

```
 Необходим установленный RubyGem 'rails'
$ rails new myapp
$ cd myapp
```

### Сторонние гемы

Сейчас Rails использует `Gemfile` в корне приложения, чтобы определить гемы, требуемые для запуска вашего приложения. Этот `Gemfile` обрабатывается гемом [Bundler](http://github.com/carlhuda/bundler), который затем устанавливает все зависимости. Он может даже установить все зависимости локально в ваше приложение, и оно не будет зависеть от системных гемов.

Подробнее: - [домашняя страница Bundler](https://bundler.io)

### Живите на грани

`Bundler` и `Gemfile` замораживает ваше приложение Rails с помощью новой отдельной команды `bundle`. Если хотите установить напрямую из репозитория Git, передайте флажок `--edge`:

```
$ rails new myapp --edge
```

Если имеется локальная копия репозитория Rails, и необходимо сгенерировать приложение используя ее, передайте флажок `--dev`:

```
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

Основные особенности
--------------------

[![Rails 4.0](/images/4_0_release_notes/rails4_features.png)](/images/4_0_release_notes/rails4_features.png)

### Апгрейд

* **Ruby 1.9.3** ([коммит](https://github.com/rails/rails/commit/a0380e808d3dbd2462df17f5d3b7fcd8bd812496)) - Предпочтителен Ruby 2.0; требуется 1.9.3+
* **[Новая политика устареваний](https://www.youtube.com/watch?v=z6YgD6tVPQs)** - Устаревшие особенности показывают предупреждения в Rails 4.0, и будут убраны в Rails 4.1.
* **Кэширование страниц и экшнов ActionPack** ([коммит](https://github.com/rails/rails/commit/b0a7068564f0c95e7ef28fc39d0335ed17d93e90)) - Кэширование страниц и экшнов было извлечено в отдельный гем. Кэширование страниц и экшнов требовало слишком много человеческого вмешательства (вручную прекращать кэш, когда обновляются лежащие в основе объекты модели). Вместо этого используйте кэширование по принципу "русской матрешки" (Russian doll caching).
* **Обсерверы ActiveRecord** ([коммит](https://github.com/rails/rails/commit/ccecab3ba950a288b61a516bf9b6962e384aae0b)) - Обсерверы извлечены в отдельный гем. Обсерверы требовались только для кэширования страниц и экшнов и могли привести к спагетти-коду.
* **Хранилище сессии ActiveRecord** ([коммит](https://github.com/rails/rails/commit/0ffe19056c8e8b2f9ae9d487b896cad2ce9387ad)) - Хранилище сессии ActiveRecord извлечено в отдельный гем. Хранение сессий в SQL затратное. Используйте вместо него сессии куки, сессии memcache или произвольные хранилища сессии.
* **Защита от массового назначения ActiveModel** ([коммит](https://github.com/rails/rails/commit/f8c9a4d3e88181cee644f91e1342bfe896ca64c6)) - Защита от массового назначения Rails 3 устарела. Вместо нее используйте строгие параметры (strong parameters).
* **ActiveResource** ([коммит](https://github.com/rails/rails/commit/f1637bf2bb00490203503fbd943b73406e043d1d)) - ActiveResource извлечен в отдельный гем. ActiveResource не был широко используемым.
* **убраны vendor/plugins** ([коммит](https://github.com/rails/rails/commit/853de2bd9ac572735fa6cf59fcf827e485a231c3)) - Для управления установленными гемами используйте `Gemfile`.

### ActionPack

* **Strong parameters** ([коммит](https://github.com/rails/rails/commit/a8f6d5c6450a7fe058348a7f10a908352bb6c7fc)) - Позволяет обновлять объекты модели только разрешенными параметрами (`params.permit(:title, :text)`).
* **Routing concerns** ([коммит](https://github.com/rails/rails/commit/0dd24728a088fcb4ae616bb5d62734aca5276b1b)) - В маршрутном DSL, выделяет общие подмаршруты (`comments` из `/posts/1/comments` and `/videos/1/comments`).
* **ActionController::Live** ([коммит](https://github.com/rails/rails/commit/af0a9f9eefaee3a8120cfd8d05cbc431af376da3)) - Потоковый JSON с помощью `response.stream`.
* **Декларативные ETags** ([коммит](https://github.com/rails/rails/commit/ed5c938fa36995f06d4917d9543ba78ed506bb8d)) - Добавляет на уровне контроллера дополнения к etag, которые будут частью вычисления etag.
* **[Кэширование Russian doll](http://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works)** ([коммит](https://github.com/rails/rails/commit/4154bf012d2bec2aae79e4a49aa94a70d3e91d49)) - Кэширует вложенные фрагменты вьюх. Каждый фрагмент прекращается на основе набора зависимостей (ключа кэширования). Ключ кэширования - это обычно версия шаблона и объект модели.
* **Turbolinks** ([коммит](https://github.com/rails/rails/commit/e35d8b18d0649c0ecc58f6b73df6b3c8d0c6bb74)) - Обслуживает только первую страницу HTML. Когда пользователь переходит на следующую страницу, использует pushState для обновления URL и использует AJAX для обновления title и body.
* **Извлечение ActionView из ActionController** ([коммит](https://github.com/rails/rails/commit/78b0934dd1bb84e8f093fb8ef95ca99b297b51cd)) - ActionView был отделен от ActionPack, и будет вынесен в отдельный гем в Rails 4.1.
* **Независимость от ActiveModel** ([коммит](https://github.com/rails/rails/commit/166dbaa7526a96fdf046f093f25b0a134b277a68)) - ActionPack больше не зависит от ActiveModel.

### Основное

* **ActiveModel::Model** ([коммит](https://github.com/rails/rails/commit/3b822e91d1a6c4eab0064989bbd07aae3a6d0d08)) - `ActiveModel::Model` - это миксин, чтобы обычные объекты Ruby могли работать с ActionPack "из коробки" (например, `form_for`).
* **Новый API скоупов** ([коммит](https://github.com/rails/rails/commit/50cbc03d18c5984347965a94027879623fc44cce)) - Скоупы должны быть всегда вызываемыми.
* **Выгрузка кэша схемы** ([коммит](https://github.com/rails/rails/commit/5ca4fc95818047108e69e22d200e7a4a22969477)) - Чтобы улучшить время загрузки Rails, вместо загрузки схемы непосредственно из базы данных, загружает схему из файла выгрузки.
* **Поддержка указания уровня изоляции транзакции** ([коммит](https://github.com/rails/rails/commit/392eeecc11a291e406db927a18b75f41b2658253)) - Выбирайте, что более важно - повторяемые чтения или улучшенное быстродействие (менее блокирующее).
* **Dalli** ([коммит](https://github.com/rails/rails/commit/82663306f428a5bbc90c511458432afb26d2f238)) - Используется клиент Dalli в качестве хранилища сессии в memcache.
* **start &amp; finish для уведомлений** ([коммит](https://github.com/rails/rails/commit/f08f8750a512f741acb004d0cebe210c5f949f28)) - Инструменты Active Support сообщают подписчикам о начале и завершении уведомлений.
* **Тредобезопасность по умолчанию** ([коммит](https://github.com/rails/rails/commit/5d416b907864d99af55ebaa400fff217e17570cd)) - Rails может быть запущен на тредовых серверах приложений без дополнительных настроек. Заметка: Проверьте, что используемые вами гемы тредобезопасны.

NOTE: Убедитесь, что используемые вами гемы тредобезопасны.

* **Метод PATCH** ([коммит](https://github.com/rails/rails/commit/eed9f2539e3ab5a68e798802f464b8e4e95e619e)) - В Rails PATCH заменил PUT. PATCH используется для частичного обновления ресурсов.

### Безопасность

* **match не соответствует всем методам** ([коммит](https://github.com/rails/rails/commit/90d2802b71a6e89aedfe40564a37bd35f777e541)) - В маршрутном DSL, match требует указания метода или методов HTTP.
* **Сущности html экранируются по умолчанию** ([коммит](https://github.com/rails/rails/commit/5f189f41258b83d49012ec5a0678d827327e7543)) - Строки, рендерящиеся в erb, экранируются, если не обернуты в `raw`, или вызван `html_safe`.
* **Новые заголовки безопасности** ([коммит](https://github.com/rails/rails/commit/6794e92b204572d75a07bd6413bdae6ae22d5a82)) - Rails посылает следующие заголовки с каждым запросом HTTP: `X-Frame-Options` (предотвращает кликджекинг, запрещая браузеру встраивать страницу в фрейм), `X-XSS-Protection` (говорит браузеру прерывать инъекцию скрипта) и `X-Content-Type-Options` (предотвращает открытие браузером jpeg как exe).

Извлечение особенностей в гемы
---------------------------

В Rails 4.0 некоторые особенности были извлечены в гемы. Можно просто добавить извлеченный гем в свой `Gemfile`, чтобы вернуть функциональность.

* Динамические и основанные на хэше методы поиска ([Github](https://github.com/rails/activerecord-deprecated_finders))
* Защита от массового назначения в моделях Active Record ([Github](https://github.com/rails/protected_attributes), [Pull Request](https://github.com/rails/rails/pull/7251))
* ActiveRecord::SessionStore ([Github](https://github.com/rails/activerecord-session_store), [Pull Request](https://github.com/rails/rails/pull/7436))
* Обсерверы Active Record ([Github](https://github.com/rails/rails-observers), [Commit](https://github.com/rails/rails/commit/39e85b3b90c58449164673909a6f1893cba290b2))
* Active Resource ([Github](https://github.com/rails/activeresource), [Pull Request](https://github.com/rails/rails/pull/572), [Blog](http://yetimedia-blog-blog.tumblr.com/post/35233051627/activeresource-is-dead-long-live-activeresource))
* Кэширование экшна ([Github](https://github.com/rails/actionpack-action_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Кэширование страницы ([Github](https://github.com/rails/actionpack-page_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Sprockets ([Github](https://github.com/rails/sprockets-rails))
* Тесты производительности ([Github](https://github.com/rails/rails-perftest), [Pull Request](https://github.com/rails/rails/pull/8876))

Документация
------------

* Руководства были переписаны на GitHub Flavored Markdown.

* Руководства имеют адаптивный дизайн.


Railties
--------

Обратитесь к [Changelog](https://github.com/rails/rails/blob/4-0-stable/railties/CHANGELOG.md) за полными изменениями.

### Значимые изменения

* Новые места расположения для тестов `test/models`, `test/helpers`, `test/controllers` и `test/mailers`. Также добавлены соответствующие задачи rake. ([Pull Request](https://github.com/rails/rails/pull/7878))

* Исполняемые файлы приложения теперь находятся в директории `bin/`. Запустите `rake rails:update:bin` чтобы получить `bin/bundle`, `bin/rails` и `bin/rake`.

* Тредобезопасность включена по умолчанию

* Была убрана возможность использования произвольного билдера, передав `--builder` (или `-b`) в `rails new`. Вместо нее рассмотрите шаблоны приложения. ([Pull Request](https://github.com/rails/rails/pull/9401))

### Устаревания

* `config.threadsafe!` устарело в пользу `config.eager_load`, которая предоставляет более тонкую настройку того, что будет лениво загружаться.

* `Rails::Plugin` больше нет. Вместо добавления плагинов в `vendor/plugins`, используйте гемы, или bundler с путем, или зависимости git.

Action Mailer
-------------

Обратитесь к [Changelog](https://github.com/rails/rails/blob/4-0-stable/actionmailer/CHANGELOG.md) за полными изменениями.

### Значимые изменения

### Устаревания

Active Model
------------

Обратитесь к [Changelog](https://github.com/rails/rails/blob/4-0-stable/activemodel/CHANGELOG.md) за полными изменениями.

### Значимые изменения

* Добавлен `ActiveModel::ForbiddenAttributesProtection`, простой модуль для защиты атрибутов от массового назначения, когда передаются неразрешенные атрибуты.

* Добавлен `ActiveModel::Model`, примесь, чтобы объекты Ruby могли работать с Action Pack "из коробки".

### Устаревания

Active Support
--------------

Обратитесь к [Changelog](https://github.com/rails/rails/blob/4-0-stable/activesupport/CHANGELOG.md) за полными изменениями.

### Значимые изменения

* Заменен устаревший гем `memcache-client` на `dalli` в `ActiveSupport::Cache::MemCacheStore`.

* Оптимизирован `ActiveSupport::Cache::Entry` для уменьшения расхода памяти и процессора.

* Словоизменения теперь могут быть определены для локали. `singularize` и `pluralize` принимают локаль как дополнительный аргумент.

* `Object#try` теперь будет возвращать nil вместо вызова NoMethodError, если вызывающий объект не реализует этот метод, но все еще можно получить старое поведение, используя новый метод `Object#try!`.

* `String#to_date` теперь вызывает `ArgumentError: invalid date` вместо `NoMethodError: undefined method 'div' for nil:NilClass` при получения неверной даты. Это то же самое, что и `Date.parse`, и он принимает больше неправильных дат, чем 3.x, такие как:

  ```ruby
  # ActiveSupport 3.x
  "asdf".to_date # => NoMethodError: undefined method `div' for nil:NilClass
  "333".to_date # => NoMethodError: undefined method `div' for nil:NilClass

  # ActiveSupport 4
  "asdf".to_date # => ArgumentError: invalid date
  "333".to_date # => Fri, 29 Nov 2013
  ```

### Устаревания

* Устарел метод `ActiveSupport::TestCase#pending`, используйте вместо него `skip` из MiniTest.

* `ActiveSupport::Benchmarkable#silence` устарел из-за недостатков в тредобезопасности. Он будет убран без замен в Rails 4.1.

* Устарел `ActiveSupport::JSON::Variable`. Определяйте собственные методы `#as_json` и `#encode_json` для собственных строковых литер JSON.

* Устарел метод совместимости `Module#local_constant_names`, используйте вместо него `Module#local_constants` (который возвращает символы).

* Устарел `BufferedLogger`. Используйте `ActiveSupport::Logger` или `logger` из стандартной библиотеки Ruby.

* Устарели `assert_present` и `assert_blank` в пользу `assert object.blank?` и `assert object.present?`

Action Pack
-----------

Обратитесь к [Changelog](https://github.com/rails/rails/blob/4-0-stable/actionpack/CHANGELOG.md) за полными изменениями.

### Значимые изменения

* Изменена таблица стилей для страниц исключений для режима development. Также дополнительно отображается строчка кода и фрагмент, который вызвал исключение на всех страницах исключений.

### Устаревания

Active Record
-------------

Обратитесь к [Changelog](https://github.com/rails/rails/blob/4-0-stable/activerecord/CHANGELOG.md) за полными изменениями.

### Значимые изменения

* Улучшены способы написания миграций `change`, что делает старые методы `up` & `down` больше не нужными.

    * Методы `drop_table` и `remove_column` теперь обратимые, если дана вся необходимая информация.
      Метод `remove_column` принимает несколько имен столбцов; вместо использования `remove_columns` (который необратимый).
      Метод `change_table` также обратимый, если его блок не вызывает `remove`, `change` или `change_default`

    * Новый метод `reversible` делает возможным определить код для исполнения при выполнении или откате миграции.
      Смотрите руководство [Миграции Active Record](/rails-database-migrations#using-reversible)

    * Новый метод `revert` обратит всю миграцию или предоставленный блок.
      Если миграция откатывается, данная миграция / блок выполняется обычно.
      Смотрите руководство [Миграции Active Record](/rails-database-migrations#reverting-previous-migrations)

* Добавлена поддержка массивов PostgreSQL. Для создания столбца array может быть использован любой тип данных, с полной поддержкой миграций и выгрузкой схемы.

* Добавлен `Relation#load` для явной загрузки записи и возврата `self`.

* `Model.all` теперь возвращает `ActiveRecord::Relation`, а не массив с записями. Используйте `Relation#to_a`, если вы действительно хотите массив. В некоторых особенных случаях это может вызвать повреждения при апгрейде.

* Добавлен `ActiveRecord::Migration.check_pending!`, вызывающий ошибку, если миграции ожидают выполнения.

* Добавлена поддержка произвольного кодирования для `ActiveRecord::Store`. Теперь можно установить собственное кодирование следующим образом:

        store :settings, accessors: [ :color, :homepage ], coder: JSON

* Соединения `mysql` и `mysql2` будут по умолчанию устанавливать `SQL_MODE=STRICT_ALL_TABLES`, чтобы избежать тихих потерь данных. Это может быть отключено, определив `strict: false` в `database.yml`.

* Убрана IdentityMap.

* Убрано автоматическое выполнение запросов EXPLAIN. Опция `active_record.auto_explain_threshold_in_seconds` больше не используется и должна быть убрана.

* Добавлены `ActiveRecord::NullRelation` и `ActiveRecord::Relation#none`, реализующие паттерн нулевого объекта для класса Relation.

* Добавлен миграционный хелпер `create_join_table` для создания соединительных таблиц HABTM.

* Могут быть созданы записи PostgreSQL hstore.

### Устаревания

* Устарел старый API поиска, основанный на хэше. Это означает, что методы, ранее принимающие "опции поиска", больше так не делают.

* Устарели все динамические методы, кроме `find_by_...` и `find_by_...!` устарели. Вот как можно переписать код:

      * `find_all_by_...` может быть переписан с использованием `where(...)`.
      * `find_last_by_...` может быть переписан с использованием `where(...).last`.
      * `scoped_by_...` может быть переписан с использованием `where(...)`.
      * `find_or_initialize_by_...` может быть переписан с использованием `find_or_initialize_by(...)`.
      * `find_or_create_by_...` может быть переписан с использованием `find_or_create_by(...)`.
      * `find_or_create_by_...!` может быть переписан с использованием `find_or_create_by!(...)`.
