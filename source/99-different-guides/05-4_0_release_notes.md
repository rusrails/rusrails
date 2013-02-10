# Заметки о релизе Ruby on Rails 4.0

Ключевые новинки в Rails 4.0:

* Только Ruby 1.9.3
* Строгие параметры (Strong Parameters)
* Турболинки (Turbolinks)
* Кэширование "матрешкой" (Russian Doll Caching)

Эти заметки о релизе покрывают только основные обновления. Чтобы узнать о различных багфиксах и изменениях, обратитесь к логам изменений или к [списку комитов](https://github.com/rails/rails/commits/master) в главном репозитории Rails на GitHub.

Обновление до Rails 4.0
-----------------------

Если обновляете существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 4.0, необходимо сначала обновиться до Rails 3.2 и убедиться, что приложение все еще выполняется так, как нужно. Список вещей, которые нужно выполнить при обновлении доступен в руководстве [Обновление Rails](/different-guides/upgrading_ruby_on_rails#upgrading-from-rails-3-2-to-rails-4-0).

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

TODO. Give a list and then talk about each of them briefly. We can point to relevant code commits or documentation from these sections.

![Rails 4.0](/assets/guides/rails4_features.png)

Извлечение особенностей в гемы
---------------------------

В Rails 4.0 некоторые особенности были извлечены в гемы. Можно просто добавить извлеченный гем в свой `Gemfile`, чтобы вернуть функциональность.

* Динамические и основанные на хэше методы поиска ([Github](https://github.com/rails/activerecord-deprecated_finders))
* Защита от массового назначения в моделях Active Record ([Github](https://github.com/rails/protected_attributes), [Pull Request](https://github.com/rails/rails/pull/7251))
* ActiveRecord::SessionStore ([Github](https://github.com/rails/activerecord-session_store), [Pull Request](https://github.com/rails/rails/pull/7436))
* Обсерверы Active Record ([Github](https://github.com/rails/rails-observers), [Commit](https://github.com/rails/rails/commit/39e85b3b90c58449164673909a6f1893cba290b2))
* Active Resource ([Github](https://github.com/rails/activeresource), [Pull Request](https://github.com/rails/rails/pull/572), [Blog](http://yetimedia.tumblr.com/post/35233051627/activeresource-is-dead-long-live-activeresource))
* Кэширование экшна ([Github](https://github.com/rails/actionpack-action_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Кэширование страницы ([Github](https://github.com/rails/actionpack-page_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Sprockets ([Github](https://github.com/rails/sprockets-rails))

Документация
------------

* Руководства были переписаны на GitHub Flavored Markdown.

* Руководства имеют адаптивный дизайн.


Railties
--------

Обратитесь к [Changelog](https://github.com/rails/rails/blob/master/railties/CHANGELOG.md) за полными изменениями.

### Значимые изменения

*   Новые места для тестов `test/models`, `test/helpers`, `test/controllers` и `test/mailers`. Также добавлены соответствующие рейк-таски. ([Pull Request](https://github.com/rails/rails/pull/7878))

*   Исполняемые файлы приложения теперь находятся в директории `bin/`. Запустите `rake update:bin` чтобы получить `bin/bundle`, `bin/rails` и `bin/rake`.

*   Тредобезопасность включена по умолчанию

### Устаревания

*   `config.threadsafe!` устарело в пользу `config.eager_load`, которая предоставляет более тонкую настройку того, что будет лениво загружаться.

*   `Rails::Plugin` больше нет. Вместо добавления плагинов в `vendor/plugins`, используйте гемы, или bundler с путем, или зависимости git.

Action Mailer
-------------

Обратитесь к [Changelog](https://github.com/rails/rails/blob/master/actionmailer/CHANGELOG.md) за полными изменениями.

### Значимые изменения

### Устаревания

Active Model
------------

Обратитесь к [Changelog](https://github.com/rails/rails/blob/master/activemodel/CHANGELOG.md) за полными изменениями.

### Значимые изменения

*   Добавлен `ActiveModel::ForbiddenAttributesProtection`, простой модуль для защиты атрибутов от массового назначения, когда передаются неразрешенные атрибуты.

*   Добавлен `ActiveModel::Model`, примесь, чтобы объекты Ruby могли работать с Action Pack "из коробки".

### Устаревания

Active Support
--------------

Обратитесь к [Changelog](https://github.com/rails/rails/blob/master/activesupport/CHANGELOG.md) за полными изменениями.

### Значимые изменения

*   Заменен устаревший гем `memcache-client` на  `dalli` в ActiveSupport::Cache::MemCacheStore.

*   Оптимизирован ActiveSupport::Cache::Entry для уменьшения расхода памяти и процессора.

*   Словоизменения теперь могут быть определены для локали. `singularize` и `pluralize` принимают локаль как дополнительный аргумент.

*   `Object#try` теперь будет возвращать nil вместо вызова NoMethodError, если вызывающий объект не реализует этот метод, но все еще можно получить старое поведение, используя новый метод `Object#try!`.

### Устаревания

*   Устарел метод `ActiveSupport::TestCase#pending`, используйте вместо него `skip` из MiniTest.

*   ActiveSupport::Benchmarkable#silence устарел из-за недостатков в тредобезопасности. Он будет убран без замен в Rails 4.1.

*   Устарел `ActiveSupport::JSON::Variable`. Определяйте собственные методы `#as_json` и `#encode_json` для собственных строковых литер JSON.

*   Устарел метод совместимости `Module#local_constant_names`, используйте вместо него `Module#local_constants` (который возвращает символы).

*   Устарел `BufferedLogger`. Используйте `ActiveSupport::Logger` или `logger` из Ruby stdlib.

*   Устарели `assert_present` и `assert_blank` в пользу `assert object.blank?` и `assert object.present?`

Action Pack
-----------

Обратитесь к [Changelog](https://github.com/rails/rails/blob/master/actionpack/CHANGELOG.md) за полными изменениями.

### Значимые изменения

* Изменена таблица стилей для страниц исключений для режима development. Также дополнительно отображается строчка кода и фрагмент, который вызвал исключение на всех страницах исключений.

### Устаревания

Active Record
-------------

Обратитесь к [Changelog](https://github.com/rails/rails/blob/master/activerecord/CHANGELOG.md) за полными изменениями.

### Значимые изменения

*   Улучшены способы написания миграций `change`, что делает старые методы `up` & `down` больше не нужными.

    * Методы `drop_table` и `remove_column` теперь обратимые, если дана вся необходимая информация.
      Метод `remove_column` принимает несколько имен столбцов; вместо использования `remove_columns` (который необратимый).
      Метод `change_table` также обратимый, если его блок не вызывает `remove`, `change` или `change_default`

    * Новый метод `reversible` делает возможным определить код для исполнения при выполении или откате миграции.
      Смотрите [Руководство по миграциям](/rails-database-migrations/writing-a-migration)

    * Новый метод `revert` обратит всю миграцию или  предоставленный блок.
      Если миграция откатывается, данная миграция / блок выполняется обычно.
      Смотрите [Руководство по миграциям](/rails-database-migrations/writing-a-migration)

*   Добавлены некоторые столбцы метаданных в таблицу `schema_migrations`.

    * `migrated_at`
    * `fingerprint` - хэш md5 миграции.
    * `name` - имя файла минус версия и расширение.

*   Добавлена поддержка массивов PostgreSQL. Для создания столбца array может быть использован любой тип данных, с полной поддержкой миграций и выгрузкой схемы.

*   Добавлен `Relation#load` для явной загрузки записи и возврата `self`.

*   `Model.all` теперь возвращает `ActiveRecord::Relation`, а не массив с записями. Используйте `Relation#to_a`, если вы действительно хотите массив. В некоторых особенных случаях это может вызвать повреждения при обновлении.

*   Добавлен `ActiveRecord::Migration.check_pending!`, вызывающий ошибку, если миграции ожидают выполнения.

*   Добавлена поддержка произвольного кодирования для `ActiveRecord::Store`. Теперь можно установить собственное кодирование следующим образом:

        store :settings, accessors: [ :color, :homepage ], coder: JSON

*   Соединения `mysql` и `mysql2` будут по умолчанию устанавливать `SQL_MODE=STRICT_ALL_TABLES`, чтобы избежать тихих потерь данных. Это может быть отключено, определив `strict: false` в `database.yml`.

*   Убрана IdentityMap.

*   Добавлены `ActiveRecord::NullRelation` и `ActiveRecord::Relation#none`, реализующие паттерн нулевого объекта для класса Relation.

*   Добавлен миграционный хелпер `create_join_table` для создания соединительных таблиц HABTM.

*   Могут быть созданы записи PostgreSQL hstore.

### Устаревания

*   Устарел старый API поиска, основанный на хэше. Это означает, что методы, ранее принимающие "опции поиска", больше так не делают.

* Устарели все динамические методы, кроме `find_by_...` и `find_by_...!` устарели. Вот как можно переписать код:

      * `find_all_by_...` может быть переписан с использованием `where(...)`.
      * `find_last_by_...` может быть переписан с использованием `where(...).last`.
      * `scoped_by_...` может быть переписан с использованием `where(...)`.
      * `find_or_initialize_by_...` может быть переписан с использованием `where(...).first_or_initialize`.
      * `find_or_create_by_...` может быть переписан с использованием `find_or_create_by(...)` or `where(...).first_or_create`.
      * `find_or_create_by_...!` может быть переписан с использованием `find_or_create_by!(...)` or `where(...).first_or_create!`.
