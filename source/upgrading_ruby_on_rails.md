Апгрейд Ruby on Rails
=====================

В этом руководстве приведены шаги, которые необходимо выполнить, чтобы апгрейднуть приложение на новую версию Ruby on Rails. Эти шаги также доступны в отдельных руководствах по релизам.

Общий совет
-----------

Перед попыткой апгрейда существующего приложения, следует убедиться, что есть хорошая причина для апгрейда. Нужно соблюсти баланс между несколькими факторами: необходимостью в новых особенностях, увеличением сложности в поиске поддержки для старого кода, доступностью вашего времени и навыков - это только некоторые из многих.

### Тестовое покрытие

Лучшим способом убедиться, что приложение продолжит работать после апгрейда, это иметь хорошее тестовое покрытие до начала апгрейда. Если у вас нет автоматических тестов, проверяющих большую часть вашего приложения, тогда нужно потратить время, проверяя все части, которые изменились. В случае обновления Rails это означает каждый отдельный кусок функциональности приложения. Пожалейте себя и убедитесь в хорошем тестовом покрытии _до_ начала апгрейда.

### Версии Ruby

В основном Rails использует последние выпущенные версии Ruby:

* Rails 7.2 требует Ruby 3.1.0 или новее.
* Rails 7.0 и 7.1 требуют Ruby 2.7.0 или новее.
* Rails 6 требует Ruby 2.5.0 или новее.
* Rails 5 требует Ruby 2.2.2 или новее.

Хорошей идеей будет обновлять Ruby и Rails раздельно. Сначала обновитесь на последний Ruby, а потом обновляйте Rails.

### Процесс апгрейда

При изменении версий Rails лучше двигаться медленно, одна второстепенная версия за раз, чтобы результативно использовать предупреждения об устаревании. Версии Rails записываются в форме Major.Minor.Patch. В главной (Major) и второстепенной (Minor) версиях допустимо делать изменения в публичном API, и это может вызвать ошибки в вашем приложении. Версии Patch включают только исправления ошибок и не изменяют публичное API.

Процесс должен быть следующим:

1. Пишете тесты и убеждаетесь, что они проходят.
2. Переходите к последней версии патча, следующую после вашей текущей версии.
3. Чините тесты и устаревшие особенности.
4. Переходите к последней версии патча следующей второстепенной версии.

Повторяйте этот процесс, пока не достигнете целевой версии Rails.

#### Переход между версиями

Чтобы перейти к версии:

1. Измените номер версии Rails в `Gemfile` и запустите `bundle update`.
2. Измените версии для пакетов Rails JavaScript в `package.json` и запустите `bin/rails javascript:install`, если вы на jsbundling-rails.
3. Запустите [задачу Update](#the-update-task).
4. Запустите свои тесты.

Полный список всех выпущенных версий Rails можно найти [тут](https://rubygems.org/gems/rails/versions).

### (the-update-task) Задача Update

Rails предоставляет команду `rails app:update`. После обновления версии Rails в `Gemfile`, запустите эту команду. Она поможет вам с созданием новых файлов и изменением старых файлов в интерактивной сессии.

```bash
$ bin/rails app:update
       exist  config
    conflict  config/application.rb
Overwrite /myapp/config/application.rb? (enter "h" for help) [Ynaqdh]
       force  config/application.rb
      create  config/initializers/new_framework_defaults_7_2.rb
...
```

Не забывайте просматривать разницу, чтобы увидеть какие-либо неожидаемые изменения.

### Настройка умолчаний фреймворка

Возможно, что новая версия Rails будет иметь другие настройки по умолчанию, чем в предыдущей версии. Однако, после следования шагам, описанным ниже, ваше приложение все еще будет запускаться с настройками по умолчанию из *предыдущей* версии Rails. Это так, потому что значения для `config.load_defaults` в `config/application.rb` не были пока изменены.

Чтобы позволить обновиться до новых значений по умолчанию один за другим, задача обновления создала файл `config/initializers/new_framework_defaults_X.Y.rb` (с желаемой версией Rails в имени файла). Следует включать новые конфигурационные значения по умолчанию, снимая комментарий с них в этом файле; это можно сделать постепенно на протяжение нескольких развертываний. Как только ваше приложение готово быть запущенным с новыми значениями по умолчанию, этот файл можно удалить и изменить значение `config.load_defaults`.

(Upgrading from Rails 7.1 to Rails 7.2) Апгрейд с Rails 7.1 на Rails 7.2
------------------------------------------------------------------------

Подробнее о внесенных изменениях в Rails 7.2 смотрите в [заметках о релизе](/7_2_release_notes).

(Upgrading from Rails 7.0 to Rails 7.1) Апгрейд с Rails 7.0 на Rails 7.1
------------------------------------------------------------------------

Подробнее о внесенных изменениях в Rails 7.1 смотрите в [заметках о релизе](/7_1_release_notes).

### Пути автозагрузки больше не в $LOAD_PATH

Начиная с Rails 7.1, директории, управляемые автозагрузчиками, больше не добавляются в `$LOAD_PATH`. Это означает, что их файлы больше невозможно загрузить вручную с помощью вызова `require`, что, впрочем, и не следовало делать.

Уменьшение размера `$LOAD_PATH` ускоряет вызовы `require` для приложений, не использующих `bootsnap`, и уменьшает размер кэша `bootsnap` для остальных.

Если все еще желаете иметь эти пути в `$LOAD_PATH`, можно включить:

```ruby
config.add_autoload_paths_to_load_path = true
```

но мы не одобряем так делать, классы и модули в путях автозагрузки подразумеваются быть автозагруженными. Для этого нужно всего лишь на них сослаться.

Директория `lib` не затрагивается этим флажком, она всегда добавлена в `$LOAD_PATH`.

### config.autoload_lib и config.autoload_lib_once

Если в вашем приложении `lib` не находится в путях автозагрузки или однократной автозагрузки, можете опустить этот раздел. Это можно узнать, просмотрев вывод

```bash
# Печатает пути автозагрузки.
$ bin/rails runner 'pp Rails.autoloaders.main.dirs'

# Печатает пути однократной автозагрузки.
$ bin/rails runner 'pp Rails.autoloaders.once.dirs'
```

Если в вашем приложении `lib` в путях автозагрузки, обычно в `config/application.rb` есть конфигурация, которая выглядит наподобие

```ruby
# Автоматически загружать lib, но не загружать нетерпеливо (возможно, что забыли).
config.autoload_paths << config.root.join("lib")
```

или

```ruby
# Автоматически, а также нетерпеливо загружать lib.
config.autoload_paths << config.root.join("lib")
config.eager_load_paths << config.root.join("lib")
```

или

```ruby
# То же самое, потому что все пути нетерпеливой загрузки также становятся путями автозагрузки.
config.eager_load_paths << config.root.join("lib")
```

Это все еще работает, но рекомендуется заменить эти строчки более выразительным

```ruby
config.autoload_lib(ignore: %w(assets tasks))
```

Пожалуйста, добавьте к списку `ignore` любые другие поддиректории `lib`, не содержащие файлы `.rb`, или которые не должны быть перезагружены или нетерпеливо загружены. Например, если в приложении есть `lib/templates`, `lib/generators` или `lib/middleware`, нужно добавить их имя относительно `lib`:

```ruby
config.autoload_lib(ignore: %w(assets tasks templates generators middleware))
```

С помощью этой строчки код (не игнорируемый) в `lib` также будет нетерпеливо загружен, если `config.eager_load` `true` (по умолчанию в режиме `production`). Обычно это то, что необходимо, но если `lib` не добавлялся ранее в пути нетерпеливой загрузки, и вы все еще желаете, чтобы так и оставалось, выключите:

```ruby
Rails.autoloaders.main.do_not_eager_load(config.root.join("lib"))
```

Метод `config.autoload_lib_once` аналогичен тому, если бы в приложении `lib` был в `config.autoload_once_paths`.

### `ActiveStorage::BaseController` больше не включает потоковый модуль

Контроллеры приложения, наследуемые от `ActiveStorage::BaseController`, и использующие потоки для реализации пользовательской логики отдачи файлов, теперь должны явно включать модуль `ActiveStorage::Streaming`.

### `MemCacheStore` и `RedisCacheStore` теперь по умолчанию используют пулы соединений

Гем `connection_pool` был добавлен как зависимость гема `activesupport`, и `MemCacheStore` и `RedisCacheStore` теперь по умолчанию используют пулы соединений.

Если не желаете использовать пулы соединений, установите опции `:pool` `false` при конфигурировании хранилища кэша:

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", { pool: false }
```

Подробности смотрите в руководстве [по кэшированию с Rails](/caching-with-rails#connection-pool-options).

### `SQLite3Adapter` теперь конфигурируется, чтобы использоваться в режиме строгих строк

Использование режима строгих строк отключает строковые литералы с двойными кавычками.

В SQLite есть несколько причуд, связанных со строковыми литералами с двойными кавычками. Сначала он пытается рассматривать строки с двойными кавычками в качестве имен переменных, но, если они не существуют, он рассматривает их в качестве строковых литералов. Из-за этого опечатки могут быть незамечены. Например, возможно создать индекс для несуществующего столбца. Подробности смотрите в [документации SQLite](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted).

Если вы не хотите использовать `SQLite3Adapter` в строгом режиме, это поведение можно отключить:

```ruby
# config/application.rb
config.active_record.sqlite3_adapter_strict_strings_by_default = false
```

### Поддержка нескольких путей предварительного просмотра для `ActionMailer::Preview`

Опция `config.action_mailer.preview_path` устарела в пользу `config.action_mailer.preview_paths`. Добавление путей к этой конфигурационной опции вызовет, что эти пути будут использованы в поиске для предварительного просмотра писем.

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### `config.i18n.raise_on_missing_translations = true` теперь вызывает ошибку для любого отсутствующего перевода.

Раньше он вызывал ошибку только при вызове во вью или контроллере. Теперь он будет вызывать ошибку всякий раз, когда в `I18n.t` предоставлен нераспознанный ключ.

```ruby
# с config.i18n.raise_on_missing_translations = true

# во вью или контроллере:
t("missing.key") # вызывает ошибку в 7.0, вызывает ошибку в 7.1
I18n.t("missing.key") # не вызывает ошибку в 7.0, вызывает ошибку в 7.1

# где угодно:
I18n.t("missing.key") # не вызывает ошибку в 7.0, вызывает ошибку в 7.1
```

Если не желаете такое поведение, можно установить `config.i18n.raise_on_missing_translations = false`:

```ruby
# с config.i18n.raise_on_missing_translations = false

# во вью или контроллере:
t("missing.key") # не вызывает ошибку в 7.0, не вызывает ошибку в 7.1
I18n.t("missing.key") # не вызывает ошибку в 7.0, не вызывает ошибку в 7.1

# где угодно:
I18n.t("missing.key") # не вызывает ошибку в 7.0, не вызывает ошибку в 7.1
```

Альтернативно можно настроить `I18n.exception_handler`. Подробности смотрите в [руководстве i18n](/i18n#using-different-exception-handlers).

`AbstractController::Translation.raise_on_missing_translations` был убран. Это был приватный API, если вы полагались на него, следует мигрировать на `config.i18n.raise_on_missing_translations` или пользовательский обработчик исключения.

### `bin/rails test` теперь запускает задачу `test:prepare`

При запуске тестов с помощью `bin/rails test` до запуска тестов будет запущена задача `rake test:prepare`. Если задача `test:prepare` была усовершенствована, эти усовершенствования будут запущены до тестов. `tailwindcss-rails`, `jsbundling-rails` и `cssbundling-rails` совершенствуют эту задачу, также как и другие сторонние гемы.

Подробности смотрите в руководстве [Тестирование приложений на Rails](/testing#running-tests-in-continuous-integration-ci).

Если запускаете тесты одного файла (`bin/rails test test/models/user_test.rb`), `test:prepare` не будет запущен перед этим.

### Изменен синтаксис импорта из `@rails/ujs`

Начиная с Rails 7.1, изменился синтаксис для импорта модулей из `@rails/ujs`. Rails больше не поддерживает прямой импорт модуля из `@rails/ujs`.

Например, попытка импорта функции из библиотеки будет неудачной:

```javascript
import { fileInputSelector } from "@rails/ujs"
// ERROR: export 'fileInputSelector' (imported as 'fileInputSelector') was not found in '@rails/ujs' (possible exports: default)
 ```
В Rails 7.1 пользователи сначала импортируют объект Rails непосредственно из `@rails/ujs`. Затем пользователи могут импортировать определенные модули из объекта Rails.

Пример импорта в Rails 7.1 показан ниже:

```javascript
import Rails from "@rails/ujs"
// Псевдоним метода
const fileInputSelector = Rails.fileInputSelector
// Альтернативно ссылаться на него из объекта Rails, в котором он использован
Rails.fileInputSelector(...)
```

### `Rails.logger` теперь возвращает экземпляр `ActiveSupport::BroadcastLogger`

Класс `ActiveSupport::BroadcastLogger` это новый логгер, позволяющий простым образом транслировать логи в разные сливы (STDOUT, файл лога...).

API трансляции логов (с помощью метода `ActiveSupport::Logger.broadcast`) был убран, и был приватным раньше. Если ваше приложение или библиотека полагались на этот API, необходимо сделать следующие изменения:

```ruby
logger = Logger.new("some_file.log")

# До

Rails.logger.extend(ActiveSupport::Logger.broadcast(logger))

# После

Rails.logger.broadcast_to(logger)
```

Если ваше приложение конфигурирует пользовательский логгер, `Rails.logger` обернет или проксирует все методы к нему. На вашей стороне не требуются никаких изменений.

Если необходим доступ к вашему экземпляру пользовательского логгера, можно использовать метод `broadcasts`:

```ruby
# config/application.rb
config.logger = MyLogger.new

# Где угодно в вашем приложении
puts Rails.logger.class #=> BroadcastLogger
puts Rails.logger.broadcasts #=> [MyLogger]
```

[assert_match]: https://docs.seattlerb.org/minitest/Minitest/Assertions.html#method-i-assert_match

### Изменились алгоритмы шифрования Active Record

Шифрование Active Record теперь использует SHA-256 в качестве алгоритма дайджеста хэша. Если у вас имеются данные, зашифрованные предыдущими версиями Rails, можно рассмотреть два сценария:

1. Если у вас `config.active_support.key_generator_hash_digest_class` сконфигурирован как SHA-1 (по умолчанию до Rails 7.0), нужно также сконфигурировать SHA-1 для шифрования Active Record:

    ```ruby
    config.active_record.encryption.hash_digest_class = OpenSSL::Digest::SHA1
    ```

2. Если у вас `config.active_support.key_generator_hash_digest_class` сконфигурирован как SHA-256 (новое умолчание в 7.0), вам необходимо сконфигурировать SHA-256 для шифрования Active Record:

    ```ruby
    config.active_record.encryption.hash_digest_class = OpenSSL::Digest::SHA256
    ```

Смотрите руководство [Configuring Rails Applications](/configuring#config-active-record-encryption-hash-digest-class) о подробностях по `config.active_record.encryption.hash_digest_class`.

В дополнение была представлена новая конфигурация [`config.active_record.encryption.support_sha1_for_non_deterministic_encryption`](/configuring#config-active-record-encryption-support-sha1-for-non-deterministic-encryption) чтобы починить [баг](https://github.com/rails/rails/issues/42922), вызывающий то, что некоторые атрибуты были зашифрованы с помощью SHA-1, даже если был настроен SHA-256 с помощью вышеупомянутой конфигурации `hash_digest_class`.

По умолчанию `config.active_record.encryption.support_sha1_for_non_deterministic_encryption` отключена в Rails 7.1. Если у вас есть данные, зашифрованные в версии Rails < 7.1, которые, вы считаете, могут быть затронуты вышеупомянутым багом, эта конфигурация должна быть включена:

```ruby
config.active_record.encryption.support_sha1_for_non_deterministic_encryption = true
```

Если вы работаете с зашифрованными данными, пожалуйста, внимательно прочитайте вышеизложенное.

### Новые способы обработки исключений в тестах контроллера, интеграционных и системных

Конфигурация `config.action_dispatch.show_exceptions` контролирует, как Action Pack обрабатывает исключения, вызванные во время отклика на запросы.

До Rails 7.1 установка `config.action_dispatch.show_exceptions = true` конфигурировала Action Pack ловить исключения и рендерить подходящие HTML страницы ошибки, наподобие рендера `public/404.html` со кодом статуса `404 Not found` вместо вызова исключения `ActiveRecord::RecordNotFound`. Установка `config.action_dispatch.show_exceptions = false` конфигурировала Action Pack не ловить исключение. До Rails 7.1 новые приложения генерировались со строчкой в `config/environments/test.rb`, устанавливающей `config.action_dispatch.show_exceptions = false`.

Rails 7.1 изменяет приемлемые значения с `true` и `false` на `:all`, `:rescuable` и `:none`.

* `:all` - рендерить HTML страницы ошибки для всех исключений (эквивалентно `true`)
* `:rescuable` - рендерить HTML страницы ошибки для исключений, объявленных в [`config.action_dispatch.rescue_responses`](/configuring#config-action-dispatch-rescue-responses)
* `:none` (эквивалентно `false`) - не ловить любые исключения

Приложения, генерируемые Rails 7.1 или более поздними, устанавливают `config.action_dispatch.show_exceptions = :rescuable` в их `config/environments/test.rb`. При обновлении существующим приложениям можно изменить `config.action_dispatch.show_exceptions = :rescuable`, чтобы воспользоваться новым поведением, или заменить старые значения соответствующими новыми (`true` заменяется на `:all`, `false` заменяется на `:none`).

(Upgrading from Rails 6.1 to Rails 7.0) Апгрейд с Rails 6.1 на Rails 7.0
------------------------------------------------------------------------

Подробнее о внесенных изменениях в Rails 7.0 смотрите в [заметках о релизе](/7_0_release_notes).

### Изменившееся поведение `ActionView::Helpers::UrlHelper#button_to`

Начиная с Rails 7.0 `button_to` рендерит тег `form` с методом HTTP `patch`, если использован сохраненный объект Active Record, чтобы создать URL кнопки. Чтобы оставить текущее поведение, рассмотрите явную передачу опции `method:`:

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)], method: :post)
```

или используйте хелпер для создания URL:

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", my_custom_post_action_on_workshop_workshop_path(Workshop.find(1)))
```

### Spring

Если ваше приложение использует Spring, он должен быть обновлен до, как минимум, версии 3.0.0. В противном случае вы получите

```
undefined method `mechanism=' for ActiveSupport::Dependencies:Module
```

А также убедитесь, что [`config.cache_classes`][] установлен `false` в `config/environments/test.rb`.

[`config.cache_classes`]: /configuring#config-cache-classes

### Sprockets теперь опциональная зависимость

Гем `rails` больше не зависит от `sprockets-rails`. Если вашему приложению все еще нужно использовать Sprockets, убедитесь, что добавили `sprockets-rails` в свой Gemfile.

```ruby
gem "sprockets-rails"
```

### Приложения должны запускаться в режиме `zeitwerk`

Приложения, все еще запущенные в режиме `classic`, должны быть переключены в режим `zeitwerk`. Пожалуйста, обратитесь к руководству [Как перейти с Classic на Zeitwerk](/classic-to-zeitwerk-howto).

### Метод назначения `config.autoloader=` был удален

В Rails 7 больше нет конфигурационной настройки для установки режима автоматической загрузки, `config.autoloader=` был удален. Если вам нужно было назначить `:zeitwerk` по какой-то причине, просто уберите ее.

### Приватный API `ActiveSupport::Dependencies` был удален

Приватный API `ActiveSupport::Dependencies` был удален. Он включал методы, такие как `hook!`, `unhook!`, `depend_on`, `require_or_load`, `mechanism` и многие другие.

Немного основных моментов:

* Если вы использовали `ActiveSupport::Dependencies.constantize` или `ActiveSupport::Dependencies.safe_constantize`, просто измените их на `String#constantize` или `String#safe_constantize`.

  ```ruby
  ActiveSupport::Dependencies.constantize("User") # БОЛЬШЕ НЕВОЗМОЖНО
  "User".constantize # 👍
  ```

* Любое использование `ActiveSupport::Dependencies.mechanism`, чтение или запись, должно быть заменено доступом к `config.cache_classes`, соответственно.

* Если хотите отследить активность автоматического загрузчика, `ActiveSupport::Dependencies.verbose=` больше не доступен, просто передайте в `Rails.autoloaders.log!` в `config/application.rb`.

Вспомогательные внутренние классы или модули тоже исчезли, такие как `ActiveSupport::Dependencies::Reference`, `ActiveSupport::Dependencies::Blamable` и прочие.

### Автоматическая загрузка во время инициализации

Приложения, которые автоматически загружают перезагружаемые константы во время инициализации вне блоков `to_prepare`, получали эти константы выгруженными, и получали это предупреждение, начиная с Rails 6.0:

```
DEPRECATION WARNING: Initialization autoloaded the constant ....

Being able to do this is deprecated. Autoloading during initialization is going
to be an error condition in future versions of Rails.

...
```

Если вы все еще получаете это предупреждение в логах, обратитесь к разделу об автоматической загрузки при запуске приложения в [руководстве по автозагрузке](/autoloading-and-reloading-constants#autoloading-when-the-application-boots). В противном случае вы получите `NameError` в Rails 7.

Константы, управляемые автозагрузчиком `once` могут быть автоматически загружены в течение инициализации, и их можно использовать нормально, блок `to_prepare` не нужен. Однако, для поддержки этого автозагрузчик `once` теперь настраивается раньше. Если в приложении имеются пользовательское словообразование, и автозагрузчик `once` должен быть в курсе о нем, необходимо перенести код из `config/initializers/inflections.rb` в тело определения класса приложения в `config/application.rb`:

```ruby
module MyApp
  class Application < Rails::Application
    # ...

    ActiveSupport::Inflector.inflections(:en) do |inflect|
      inflect.acronym "HTML"
    end
  end
end
```

### Возможность настроить `config.autoload_once_paths`

Можно установить [`config.autoload_once_paths`][] в классе приложения, определенном в `config/application.rb`, или в конфигурациях для сред в `config/environments/*`.

Схожим образом в engine можно настроить эту коллекцию в классе engine или в конфигурациях для сред.

После этого коллекция замораживается, и вы можете автоматически загружать из этих путей. В частности, оттуда можно загружать во время инициализации. Они управляются автоматическим загрузчиком `Rails.autoloaders.once`, который не перезагружает, а только автоматически/нетерпеливо загружает.

Если вы установили эту настройку после того, как конфигурации для сред были обработаны, и получили `FrozenError`, просто переместите этот код.

[`config.autoload_once_paths`]: /configuring#config-autoload-once-paths

### `ActionDispatch::Request#content_type` теперь возвращает заголовок Content-Type как есть.

Раньше возвращаемое значение `ActionDispatch::Request#content_type` НЕ содержало часть charset. Это поведение изменилось, и возвращаемый заголовок Content-Type содержит часть charset как его часть.

Если вам нужен только тип MIME, используйте вместо этого `ActionDispatch::Request#media_type`.

До:

```ruby
request = ActionDispatch::Request.new("CONTENT_TYPE" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv"
```

После:

```ruby
request = ActionDispatch::Request.new("Content-Type" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv; header=present; charset=utf-16"
request.media_type   #=> "text/csv"
```

### Изменение класса дайджеста для генерации ключей требует ротатор куки

Класс дайджеста по умолчанию для генерации ключей изменили с SHA1 на SHA256. Последствия этого в любых зашифрованных сообщениях, генерируемых Rails, включая зашифрованные куки.

Для возможности читать сообщения с помощью старого класса дайджеста необходимо зарегистрировать ротатор. Если этого не получится сделать, это приведет к тому, что сессии пользователей станут недействительными в течение обновления.

Вот пример ротатора для зашифрованных и подписанных куки.

```ruby
# config/initializers/cookie_rotator.rb
Rails.application.config.after_initialize do
  Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
    authenticated_encrypted_cookie_salt = Rails.application.config.action_dispatch.authenticated_encrypted_cookie_salt
    signed_cookie_salt = Rails.application.config.action_dispatch.signed_cookie_salt

    secret_key_base = Rails.application.secret_key_base

    key_generator = ActiveSupport::KeyGenerator.new(
      secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    )
    key_len = ActiveSupport::MessageEncryptor.key_len

    old_encrypted_secret = key_generator.generate_key(authenticated_encrypted_cookie_salt, key_len)
    old_signed_secret = key_generator.generate_key(signed_cookie_salt)

    cookies.rotate :encrypted, old_encrypted_secret
    cookies.rotate :signed, old_signed_secret
  end
end
```

### Класс дайджеста для ActiveSupport::Digest изменили на SHA256

Класс дайджеста по умолчанию для ActiveSupport::Digest изменили с SHA1 на SHA256. Последствия этого в том, что такие вещи как Etag или ключи хэша, изменяться. Изменение этих ключей влияет на обращение к хэшу, будьте осторожны и следите за этим при обновлении на новый хэш.

### Новый формат сериализации ActiveSupport::Cache

Был представлен более быстрый и компактный формат сериализации.

Чтобы его включить, вы должны установить `config.active_support.cache_format_version = 7.0`:

```ruby
# config/application.rb

config.load_defaults 6.1
config.active_support.cache_format_version = 7.0
```

Или просто:

```ruby
# config/application.rb

config.load_defaults 7.0
```

Однако, приложения Rails 6.1 не способны прочитать этот новый формат сериализации, поэтому, чтобы обеспечить бесшовный апгрейд, нужно сперва задеплоить ваш обновленный Rails 7.0 с `config.active_support.cache_format_version = 6.1`, и только после того, как все процессы Rails были обновлены, можно установить `config.active_support.cache_format_version = 7.0`.

Rails 7.0 может прочитать оба формата, поэтому не нужно инвалидировать кэш во время апгрейда.

### Генерация изображения предварительного просмотра видео в Active Storage

Генерация изображения предварительного просмотра видео теперь использует обнаружение смены сцен FFmpeg для генерации более значимых предварительны изображений. До этого использовался первый кадр видео, и это вызывало проблемы, если видео постепенно появлялось из черного экрана. Это изменение требует FFmpeg v3.4+.

### Обработчик варианта по умолчанию Active Storage изменился на `:vips`

Для новых приложений трансформация изображения будет использовать libvips вместо ImageMagick. Это уменьшит время генерации вариантов, а также потребление CPU и памяти, улучшит время отклика в приложениях, полагающихся на Active Storage для раздачи своих изображений.

Опция `:mini_magick` не стала устаревшей, это нормально продолжать ее использование.

Чтобы мигрировать существующее приложение на libvips, установите:

```ruby
Rails.application.config.active_storage.variant_processor = :vips
```

Затем вам нужно изменить существующий код преобразования на макрос `image_processing` и заменить опции ImageMagick на опции libvips.

#### Замените resize на resize_to_limit

```diff
- variant(resize: "100x")
+ variant(resize_to_limit: [100, nil])
```

Если вы не сделаете это, при переключении на vips увидите эту ошибку: `no implicit conversion to float from string`.

#### Используйте массив при обрезке

```diff
- variant(crop: "1920x1080+0+0")
+ variant(crop: [0, 0, 1920, 1080])
```

Если вы не сделаете это, при переключении на vips увидите эту ошибку: `unable to call crop: you supplied 2 arguments, but operation needs 5`.

#### Пересмотрите значения обрезки:

Vips более строгий, чем ImageMagick, в отношение обрезки:

1. Он не обрежет, если `x` и/или `y` имеют отрицательные значения. Например: `[-10, -10, 100, 100]`
2. Он не обрежет, если (`x` или `y`) плюс размерность (`width`, `height`) больше, чем изображение. Например: изображение 125x125 и обрезка `[50, 50, 100, 100]`

Если вы не сделаете это, при переходе на vips увидите эту ошибку: `extract_area: bad extract area`

#### Исправьте фоновый цвет, используемый для `resize_and_pad`

Vips использует черный в качестве фонового цвета `resize_and_pad` по умолчанию, вместо белого в ImageMagick. Исправьте это с помощью опции `background`:

```diff
- variant(resize_and_pad: [300, 300])
+ variant(resize_and_pad: [300, 300, background: [255]])
```

#### Уберите любые ротации, основанные на EXIF

Vips будет осуществлять автоматическую ротацию с помощью значения EXIF при обработке вариантов. Если вы хранили значения ротации от загруженных пользователем изображений, чтобы применить ротацию в ImageMagick, это нужно перестать делать:

```diff
- variant(format: :jpg, rotate: rotation_value)
+ variant(format: :jpg)
```

#### Замените monochrome на colourspace
Vips другую опцию для создания монохромных изображений:

```diff
- variant(monochrome: true)
+ variant(colourspace: "b-w")
```

#### Переключитесь на опции libvips при сжатии изображений

JPEG

```diff
- variant(strip: true, quality: 80, interlace: "JPEG", sampling_factor: "4:2:0", colorspace: "sRGB")
+ variant(saver: { strip: true, quality: 80, interlace: true })
```

PNG

```diff
- variant(strip: true, quality: 75)
+ variant(saver: { strip: true, compression: 9 })
```

WEBP

```diff
- variant(strip: true, quality: 75, define: { webp: { lossless: false, alpha_quality: 85, thread_level: 1 } })
+ variant(saver: { strip: true, quality: 75, lossless: false, alpha_q: 85, reduction_effort: 6, smart_subsample: true })
```

GIF

```diff
- variant(layers: "Optimize")
+ variant(saver: { optimize_gif_frames: true, optimize_gif_transparency: true })
```

#### Деплой на production

Active Storage кодирует в url изображения список трансформаций, которые нужно выполнить. Если ваше приложение кэширует эти url, ваши изображения сломаются после деплоя нового кода на production. Поэтому вам нужно вручную инвалидировать затронутые ключи кэширования.

Например, Если у вас есть что-то наподобие этого во вью:

```erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= image_tag product.cover_photo.variant(resize: "200x") %>
  <% end %>
<% end %>
```

Можно инвалидировать кэш, либо обновив product, или изменив ключ кэширования:

```erb
<% @products.each do |product| %>
  <% cache ["v2", product] do %>
    <%= image_tag product.cover_photo.variant(resize_to_limit: [200, nil]) %>
  <% end %>
<% end %>
```

### Версия Rails теперь включается в дамп схемы Active Record

Rails 7.0 изменяет некоторые значения по умолчанию для некоторых типов столбца. Чтобы избежать, чтобы приложение, обновляемое с 6.1 на 7.0, загружало текущую схему, используя новые умолчания для 7.0, теперь Rails включает версию фреймворка в дампе схемы.

До первой загрузки схемы в Rails 7.0, убедитесь, что при запуске `rails app:update` версия схемы включена в дамп схемы.

Файл схемы будет выглядеть так:

```ruby
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[6.1].define(version: 2022_01_28_123512) do
  # ...
end
```

NOTE: При первом дампе схемы с Rails 7.0, вы увидите множество изменений в этот файл, включая некоторую информацию о столбцах. Убедитесь, что вы просмотрели содержимое файла новой схемы, и отправили его в свой репозиторий.

(Upgrading from Rails 6.0 to Rails 6.1) Апгрейд с Rails 6.0 на Rails 6.1
------------------------------------------------------------------------

Подробнее о внесенных изменениях в Rails 6.1 смотрите в [заметках о релизе](/6_1_release_notes).

### Возвращаемое значение `Rails.application.config_for` больше не поддерживает доступ с помощью строковых ключей.

Допустим, у нас есть такой конфигурационный файл:

```yaml
# config/example.yml
development:
  options:
    key: value
```

```ruby
Rails.application.config_for(:example).options
```

Раньше это возвращало хэш, значения которого можно было получить с помощью строковых ключей. Это устарело в 6.0, а теперь вообще не работает.

Можно вызвать `with_indifferent_access` на возвращаемом значении `config_for`, если все еще хотите получать значения по строковым ключам, например:

```ruby
Rails.application.config_for(:example).with_indifferent_access.dig('options', 'key')
```

### Content-Type отклика при использовании `respond_to#any`

Заголовок Content-Type, возвращаемый в отклике, может отличаться от возвращаемого в Rails 6.0, особенно если приложение использует `respond_to { |format| format.any }`.
Теперь Content-Type будет основан на предоставленном блоке, а не формате запроса.

Example:

```ruby
def my_action
  respond_to do |format|
    format.any { render(json: { foo: 'bar' }) }
    end
  end
end
```

```ruby
get('my_action.csv')
```

Прежним поведением был возврат `text/csv` в Content-Type отклика, что является неверным, так как рендерили отклик JSON. Текущее поведение правильно возвращает `application/json` в Content-Type отклика.

Если ваше приложение полагалось на прежнее некорректное поведение, следует указать, какие форматы принимает ваш экшн, т.е.

```ruby
format.any(:xml, :json) { render request.format.to_sym => @people }
```

### `ActiveSupport::Callbacks#halted_callback_hook` теперь принимает второй аргумент

Active Support позволяет переопределить `halted_callback_hook` для вызова всякий раз, когда колбэк прерывает цепочку. Теперь этот метод принимает второй аргумент, являющийся именем прерываемого колбэка. Если у вас есть классы, переопределяющие этот метод, убедитесь, что он принимает два аргумента. Отметьте, что это значимое изменение без предшествующего цикла устаревания (по причинам быстродействия).

Пример:

```ruby
class Book < ApplicationRecord
  before_save { throw(:abort) }
  before_create { throw(:abort) }

  def halted_callback_hook(filter, callback_name) # => Теперь этот метод принимает 2 аргумента вместо 1
    Rails.logger.info("Book couldn't be #{callback_name}d")
  end
end
```

### Метод класса `helper` в контроллерах использует `String#constantize`

Концептуально, до Rails 6.1

```ruby
helper "foo/bar"
```

приводил к

```ruby
require_dependency "foo/bar_helper"
module_name = "foo/bar_helper".camelize
module_name.constantize
```

Вместо этого, теперь он делает это:

```ruby
prefix = "foo/bar".camelize
"#{prefix}Helper".constantize
```

Это изменение обратно совместимо с большинством приложений, в этом случае ничего делать не нужно.

Технически, однако, контроллеры могут настроить `helpers_path` на директорию в `$LOAD_PATH`, которая не в путях автозагрузки. Такой случай не поддерживается из коробки. Если модуль хелпера не загружается автоматически, приложение ответственно за его загрузку до вызова `helper`.

### Перенаправление к HTTPS от HTTP теперь будет использовать  308

Код статуса HTTP по умолчанию, используемый в `ActionDispatch::SSL` при перенаправлении не-GET/HEAD запросов от HTTP к HTTPS был изменен на `308`, как определено в https://tools.ietf.org/html/rfc7538.

### Active Storage теперь требует Image Processing

При обработке вариантов в Active Storage, теперь нужно иметь [гем image_processing](https://github.com/janko/image_processing) вместо непосредственного использования `mini_magick`. Image Processing настроен использовать `mini_magick` по умолчанию, поэтому проще всего для апгрейда будет заменить гем `mini_magick` на гем `image_processing`, и убедиться, что убрали явное использование `combine_options`, так как это больше не нужно.

Для читаемости можно изменить необработанные вызовы `resize` на макросы `image_processing`. Например, вместо:

```ruby
video.preview(resize: "100x100")
video.preview(resize: "100x100>")
video.preview(resize: "100x100^")
```

можно, соответственно, сделать:

```ruby
video.preview(resize_to_fit: [100, 100])
video.preview(resize_to_limit: [100, 100])
video.preview(resize_to_fill: [100, 100])
```

### Класс `ActiveModel::Error`

Ошибки теперь экземпляры класса `ActiveModel::Error`, с измененным API. Некоторые из этих изменений могут вызывать ошибки, в зависимости от того, как вы взаимодействуете с ошибками, в то время как другие будут печатать предупреждения об устаревании, которые нужно починить для Rails 7.0.

Подробности об этом изменении и об изменениях в API можно найти [в этом PR](https://github.com/rails/rails/pull/32313).

(Upgrading from Rails 5.2 to Rails 6.0) Апгрейд с Rails 5.2 на Rails 6.0
------------------------------------------------------------------------

Подробнее о внесенных изменениях в Rails 6.0 смотрите в [заметках о релизе](/6_0_release_notes).

### Использование Webpacker

[Webpacker](https://github.com/rails/webpacker) это компилятор JavaScript по умолчанию для Rails 6. Но если вы обновляете приложение, он не активирован по умолчанию. Если хотите использовать Webpacker, включите его в Gemfile и установите:

```ruby
gem "webpacker"
```

```bash
$ bin/rails webpacker:install
```

### Навязывание SSL

Метод `force_ssl` для контроллеров устарел и будет убран в Rails 6.1. Рекомендуется включить [`config.force_ssl`][] для обеспечения подключения HTTPS во всем приложении. Если необходимо освободить определенные конечные точки от перенаправления, можно использовать [`config.ssl_options`][] для конфигурирования этого поведения.

[`config.force_ssl`]: /configuring#config-force-ssl
[`config.ssl_options`]: /configuring#config-ssl-options

### Для увеличения безопасности, метаданные о назначении и истечении теперь встроены в подписанные и зашифрованные куки

Чтобы улучшить безопасность, Rails встраивает метаданные о назначении и истечении внутри зашифрованного или подписанного значения куки.

Затем Rails может помешать исполнению атак, пытающихся скопировать подписанное/зашифрованное значение куки и использовать его как значение другого куки.

Эти новые встроенные метаданные делает куки несовместимыми с версиями Rails старше чем 6.0.

Если необходимо, чтобы куки читались Rails 5.2 и старше, или вы все еще проверяете деплой 6.0 и хотите возможность отката, установите `Rails.application.config.action_dispatch.use_cookies_with_metadata` в `false`.

### Все пакеты npm были перемещены в пространство имен `@rails`

Если вы раньше загружали любые из пакетов `actioncable`, `activestorage` или `rails-ujs` с помощью npm/yarn, вам нужно обновить имена этих зависимостей до их обновления до `6.0.0`:

```
actioncable   → @rails/actioncable
activestorage → @rails/activestorage
rails-ujs     → @rails/ujs
```

### Изменения Action Cable JavaScript API

Пакет Action Cable JavaScript был конвертирован из CoffeeScript в ES2015, и исходный код теперь опубликован в дистрибуции npm.

Этот релиз включает некоторые переломные изменения опциональных частей Action Cable JavaScript API:

- Настройки адаптера WebSocket и адаптера логгера были перемещены из свойств `ActionCable` в свойства `ActionCable.adapters`. Если вы настраивали эти адаптеры, необходимы следующие изменения:

    ```diff
    -    ActionCable.WebSocket = MyWebSocket
    +    ActionCable.adapters.WebSocket = MyWebSocket
    ```
    ```diff
    -    ActionCable.logger = myLogger
    +    ActionCable.adapters.logger = myLogger
    ```

- Методы `ActionCable.startDebugging()` и `ActionCable.stopDebugging()` были убраны и заменены свойством `ActionCable.logger.enabled`. Если вы использовали эти методы, необходимы следующие изменения:

    ```diff
    -    ActionCable.startDebugging()
    +    ActionCable.logger.enabled = true
    ```
    ```diff
    -    ActionCable.stopDebugging()
    +    ActionCable.logger.enabled = false
    ```

### `ActionDispatch::Response#content_type` теперь возвращает заголовок Content-Type без изменений

Ранее, возвращаемое значение `ActionDispatch::Response#content_type` НЕ содержало часть charset. Это поведение было изменено, чтобы также возвращать ранее опускаемую часть charset.

Если необходим только тип MIME, используйте вместо этого `ActionDispatch::Response#media_type`.

До:

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present"
```

После:

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present; charset=utf-16"
resp.media_type   #=> "text/csv"
```

### Новая настройка `config.hosts`

В Rails теперь есть новая настройка `config.hosts` для целей безопасности. По умолчанию эта настройка `localhost` в development. Если вы используете другие домены в development, вам нужно их разрешить:

```ruby
# config/environments/development.rb

config.hosts << 'dev.myapp.com'
config.hosts << /[a-z0-9-]+\.myapp\.com/ # Опционально разрешен regexp
```

Для других сред `config.hosts` пустой по умолчанию, что означает, что Rails не проверяет хост вообще. Опционально можно их добавить, если хотите проверять их в production.

### (autoloading) Автозагрузка

Конфигурация по умолчанию для Rails 6

```ruby
# config/application.rb

config.load_defaults 6.0
```

включает режим автозагрузки `zeitwerk` на CRuby. В этом режиме автозагрузка, перезагрузка и нетерпеливая загрузка управляются [Zeitwerk](https://github.com/fxn/zeitwerk).

Если вы используете умолчания из предыдущей версии Rails, можно включить zeitwerk так:

```ruby
# config/application.rb

config.autoloader = :zeitwerk
```

#### Публичный API

В целом, приложениям не нужно использовать API Zeitwerk напрямую. Rails настраивает его в соответствии с существующими контрактами: `config.autoload_paths`, `config.cache_classes` и т.д.

Хотя приложения должны придерживаться этого интерфейса, фактический объект загрузки Zeitwerk доступен как

```ruby
Rails.autoloaders.main
```

Это может быть удобным, к примеру, если необходимо предварительно загрузить наследование с единой таблицей (Single Table Inheritance, STI) или настроить пользовательский инфлектор.

#### Структура проекта

Если в приложение автозагрузки были обновлены корректно, структура проекта должна быть, в основном, совместимой.

Однако, режим `classic` производит имена файлов из имен отсутствующих констант (`underscore`), в то время как режим `zeitwerk` производит имена констант из имен файлов (`camelize`). Эти хелперы не всегда противоположны друг другу, в частности для сокращений. Например, `"FOO".underscore` это `"foo"`, но `"foo".camelize` это `"Foo"`, а не `"FOO"`.

Совместимость можно проверить с помощью задачи `zeitwerk:check`:

```bash
$ bin/rails zeitwerk:check
Hold on, I am eager loading the application.
All is good!
```

#### require_dependency

Все известные случаи применений `require_dependency` были устранены, следует найти и удалить их во всем проекте.

Если в вашем приложении есть Single Table Inheritance, посмотрите на [раздел о наследовании с единой таблицей](/autoloading-and-reloading-constants#single-table-inheritance) руководства Автозагрузка и перезагрузка констант (режим Zeitwerk).

#### Ограниченные имена в определениях класса и модуля

Теперь можно без проблем использовать пути констант в определениях класса и модуля:

```ruby
# Автозагрузка в теле этого класса теперь соответствует семантике Ruby.
class Admin::UsersController < ApplicationController
  # ...
end
```

Особенность, о которой нужно знать, в том, что классический автозагрузчик мог иногда автоматически загружать `Foo::Wadus` в

```ruby
class Foo::Bar
  Wadus
end
```

Это не соответствует семантике Ruby, так как `Foo` не во вложенности, и это вообще не будет работать в режиме `zeitwerk`. Если вы найдете такие частные случаи, можете использовать ограниченное имя `Foo::Wadus`:

```ruby
class Foo::Bar
  Foo::Wadus
end
```

или добавить `Foo` во вложенность:

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

#### Концерны

Можно автоматически загружать и нетерпеливо загружать их стандартной структуры, наподобие

```
app/models
app/models/concerns
```

В этом случае, `app/models/concerns` полагается корневой директорией (так как она принадлежит путям автозагрузки), и будет игнорироваться в качестве пространства имен. Поэтому, `app/models/concerns/foo.rb` должен определять `Foo`, а не `Concerns::Foo`.

Пространство имен `Concerns::` работало с классическим автозагрузчиком как побочный эффект реализации, но это никогда не было желаемым поведением. Приложение, использующее `Concerns::`, нуждается в переименовании этих классов и модулей, чтобы их можно было использовать в режиме `zeitwerk`.

#### `app` в путях автоматической загрузки

В некоторых проектах когда мы хотели что-то вроде `app/api/base.rb` для определения `API::Base`, то добавляли `app` в пути автозагрузки, для того, чтобы это работало в режиме `classic`. С тех пор, как Rails автоматически добавляет все поддиректории `app` в пути автозагрузки, у нас теперь другая ситуация, в которой есть вложенные корневые директории, поэтому такая настройка больше не работает. Похожий принцип мы объяснили выше про `concerns`.

Если хотите сохранить эту структуру, необходимо удалить поддиректорию из путей автозагрузки в инициализаторе:

```ruby
ActiveSupport::Dependencies.autoload_paths.delete("#{Rails.root}/app/api")
```

#### Автоматическая загрузка констант и явные пространства имен

Если пространство имен определено в файле, как `Hotel` тут:

```
app/models/hotel.rb         # Defines Hotel.
app/models/hotel/pricing.rb # Defines Hotel::Pricing.
```

константа `Hotel` должна быть установлена с помощью ключевых слов `class` или `module`. Например:

```ruby
class Hotel
end
```

это хорошо.

Альтернативы, наподобие

```ruby
Hotel = Class.new
```

или

```ruby
Hotel = Struct.new
```

не будут работать, дочерние объекты, такие как `Hotel::Pricing`, не будут найдены.

Это ограничение применяется только к явным пространствам имен. Классы и модули, не определяющие пространство имен, могут быть определены с помощью этих идиом.

#### Один файл, одна константа (на том же уровне)

В режиме `classic` технически было возможно определить несколько констант на том же уровне, и они все перезагружались. Например, для

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

хотя `Bar` не мог быть автоматически загружен, автозагрузка `Foo` также помечала `Bar` как автоматически загруженный. Это не так в режиме `zeitwerk`, необходимо переместить `Bar` в собственный файл `bar.rb`. Один файл, одна константа.

Это только применимо к константам на том же уровне, как в вышеописанном примере. Внутренние классы и модули — это нормально. Например, рассмотрим

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

Если приложение перезагрузит `Foo`, оно также перезагрузит `Foo::InnerClass`.

#### Spring и среда `test`

Spring перезагружает код приложения, если что-то меняется. В среде `test` нужно включить перезагрузку, чтобы это работало:

```ruby
# config/environments/test.rb

config.cache_classes = false
```

Иначе, вы получите такую ошибку:

```
reloading is disabled because config.cache_classes is true
```

#### Bootsnap

Bootsnap должен быть как минимум версии 1.4.2.

Помимо этого, для Bootsnap необходимо отключить кэш iseq из-за ошибки в интерпретаторе, если запускается Ruby 2.5. Убедитесь, что зависимы от минимум Bootsnap 1.4.4 в таком случае.

#### `config.add_autoload_paths_to_load_path`

Новый конфигурационный пункт [`config.add_autoload_paths_to_load_path`][] по умолчанию `true` для обратной совместимости, но позволяет уйти от добавления путей автозагрузки в `$LOAD_PATH`.

Это имеет смысл в большинстве приложений, так как никогда не следует требовать файл в `app/models`, к примеру, и Zeitwerk использует только абсолютные имена файлов.

Уходя от этого, вы оптимизируете поиск `$LOAD_PATH` (меньше директорий для проверки), и экономите работу Bootsnap и потребление памяти, поскольку ему не нужно строить индекс для этих директорий.

[`config.add_autoload_paths_to_load_path`]: /configuring#config-add-autoload-paths-to-load-path

#### Тредобезопасность

В классическом режиме автоматическая загрузка констант не является тредобезопасной, хотя в Rails есть локальные блокировки, например, чтобы сделать веб запросы тредобезопасными, когда включена автоматическая загрузка, так как это принято в среде development.

Автоматическая загрузка констант является тредобезопасной в режиме `zeitwerk`. Например, теперь можно автоматически загружать в многотредовых скриптах, запускаемых с помощью команды `runner`.

#### Шаблоны поиска в config.autoload_paths

Остерегайтесь конфигураций, таких как

```ruby
config.autoload_paths += Dir["#{config.root}/lib/**/"]
```

Каждый элемент `config.autoload_paths` должен представлять пространство имен верхнего уровня (`Object`) и они не могут быть последовательно вложенными (с исключением директорий `concerns`, описанных выше).

Чтобы это починить, просто уберите подстановки:

```ruby
config.autoload_paths << "#{config.root}/lib"
```

#### Нетерпеливая загрузка и автоматическая загрузка согласуются

В режиме `classic`, если `app/models/foo.rb` определяет `Bar`, вы не сможете автоматически загрузить этот файл, но нетерпеливая загрузка будет работать, так как она загружает файлы вслепую. Это может быть источником ошибок, если вы сначала тестируете с помощью нетерпеливой загрузки, потом выполнение может сломаться при автоматической загрузке.

В режиме `zeitwerk` оба режима загрузки согласуются, они выдадут ошибки в тех же файлах.

#### Как использовать классический автозагрузчик в Rails 6

Приложения могут загружать умолчания Rails 6 и все еще использовать классический автозагрузчик, настроив `config.autoloader` следующим образом:

```ruby
# config/application.rb

config.load_defaults 6.0
config.autoloader = :classic
```

При использовании Classic Autoloader в приложении Rails 6 рекомендовано установить уровень concurrency на 1 в среде development, для веб-серверов и фоновых обработчиков, по причинам тредобезопасности.

### Изменение поведения присвоения Active Storage

С настройками по умолчанию для Rails 5.2, присвоение к коллекции вложений, объявленное с помощью `has_many_attached`, добавляет новые файлы:

```ruby
class User < ApplicationRecord
  has_many_attached :highlights
end

user.highlights.attach(filename: "funky.jpg")
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg")
user.update!(highlights: [ blob ])

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

С настройками по умолчанию для Rails 6.0, присвоение к коллекции вложений заменяет существующие файлы вместо добавления к ним. Это соответствует поведению Active Record при присвоении к связанной коллекции:

```ruby
user.highlights.attach(filename: "funky.jpg")
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg")
user.update!(highlights: [ blob ])

user.highlights.count # => 1
user.highlights.first.filename # => "town.jpg"
```

Для добавления новых вложений вместо удаления существующих можно использовать `#attach`:

```ruby
blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg")
user.highlights.attach(blob)

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

Существующие приложения могут включить это новое поведение установив [`config.active_storage.replace_on_assign_to_many`][] в `true`. Старое поведение будет устаревшим в Rails 7.0 и убрано в Rails 7.1.

[`config.active_storage.replace_on_assign_to_many`]: /configuring#config-active-storage-replace-on-assign-to-many

### Пользовательские приложения обработки исключений

Неправильные заголовки запроса `Accept` или `Content-Type` теперь будут вызывать исключение. Приложение по умолчанию [`config.exceptions_app`][] специфически обрабатывает эту ошибку и компенсирует ее. Пользовательским приложениям обработки исключений также необходимо обрабатывать эту ошибку, иначе такие запросы вызовут то, что Rails будет использовать резервное приложение обработки ошибок, возвращающее `500 Internal Server Error`.

[`config.exceptions_app`]: /configuring#config-exceptions-app

(Upgrading from Rails 5.1 to Rails 5.2) Апгрейд с Rails 5.1 на Rails 5.2
------------------------------------------------------------------------

Подробнее о внесенных изменениях в Rails 5.2 смотрите в [заметках о релизе](/5_2_release_notes).

### Bootsnap

Rails 5.2 добавляет гем bootsnap во [вновь сгенерированный Gemfile приложения](https://github.com/rails/rails/pull/29313).
Команда `app:update` устанавливает его в `boot.rb`. Если необходимо использовать его, добавьте в Gemfile:

```ruby
# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false
```

Иначе измените `boot.rb`, чтобы не использовать bootsnap.

### Истечение срока действия в подписанных или зашифрованных куки теперь встроено в значения куки

Чтобы повысить безопасность, Rails теперь встраивает информацию об истечении срока действия также в зашифрованное или подписанное значение куки.

Эта новая встроенная информация делает эти куки несовместимыми с версиями Rails до 5.2.

Если необходимо, чтобы куки читались в версии 5.1 и раньше, или если все еще проверяется деплой 5.2 и необходимо оставить возможность сделать откат, установите `Rails.application.config.action_dispatch.use_authenticated_cookie_encryption` в `false`.

(Upgrading from Rails 5.0 to Rails 5.1) Апгрейд с Rails 5.0 на Rails 5.1
------------------------------------------------------------------------

Подробнее о внесенных изменениях в Rails 5.1 смотрите в [заметках о релизе](/5_1_release_notes).

### Верхнеуровневый `HashWithIndifferentAccess` в скором времени устареет.

Если ваше приложение использует верхнеуровневый класс `HashWithIndifferentAccess`, то вам следует вместо него постепенно переходить на `ActiveSupport::HashWithIndifferentAccess`.

Это всего лишь постепенное устаревание, которое означает, что ваш код не будет прерываться в данный момент и не будет отображаться предостережение об устаревании, но эта константа в будущем будет удалена.

Кроме того, если имеются довольно старые документы YAML, содержащие выгрузки таких объектов, может понадобиться загрузить и выгрузить их снова, чтобы убедиться, что они ссылаются на нужную константу и что их загрузка не будет прерываться в будущем.

### `application.secrets` теперь загружается со всеми ключами в качестве символов

Если ваше приложение хранит вложенную конфигурацию в `config/secrets.yml`, все ключи теперь загружаются как символы, поэтому доступ с использованием строк должен быть изменен.

С:

```ruby
Rails.application.secrets[:smtp_settings]["address"]
```

На:

```ruby
Rails.application.secrets[:smtp_settings][:address]
```

### Убрана устаревшая поддержка `:text` и `:nothing` в `render`

Если ваши контроллеры используют `render :text`, они перестанут работать. Новый способ рендерить вью с типом MIME `text/plain` — использовать `render :plain`.

Похожим образом, `render :nothing` также убран, и следует использовать метод `head` для отправки откликов, содержащих только заголовки. Например, `head :ok` посылает отклик 200 без тела.

### Убрана устаревшая поддержка `redirect_to :back`

В Rails 5.0, `redirect_to :back` устарел. В Rails 5.1 он был убран полностью.

В качестве альтернативы используйте `redirect_back`. Важно отметить, что `redirect_back` также принимает опцию `fallback_location`, которая будет использована в случае отсутствия `HTTP_REFERER`.

```ruby
redirect_back(fallback_location: root_path)
```

(Upgrading from Rails 4.2 to Rails 5.0) Апгрейд с Rails 4.2 на Rails 5.0
------------------------------------------------------------------------

Подробнее о внесенных изменениях в Rails 5.0 смотрите в [заметках о релизе](/5_0_release_notes).

### Требуется Ruby 2.2.2+

Начиная с Ruby on Rails 5.0, Ruby 2.2.2+ являются единственными поддерживаемыми версиями Ruby. Перед тем, как продолжить, убедитесь, что вы на Ruby версии 2.2.2 или выше.

### Модели Active Record теперь по умолчанию наследуются от ApplicationRecord

В Rails 4.2 модель Active Record наследуется от `ActiveRecord::Base`. В Rails 5.0 все модели наследуются от `ApplicationRecord`.

`ApplicationRecord` - это новый суперкласс для всех моделей приложения, аналогично контроллерам, наследуемым от `ApplicationController` вместо `ActionController::Base`. Это дает приложению единое место для настройки специфичного для приложения поведения моделей.

При апгрейде с Rails 4.2 на Rails 5.0 необходимо создать файл `application_record.rb` в `app/models/` и добавить следующее содержимое:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

Затем убедитесь, что все ваши модели наследуются от него.

### Прерывание цепочек колбэков с помощью `throw(:abort)`

В Rails 4.2 в Active Record и Active Model, когда колбэк 'before' возвращает `false`, вся цепочка цепочка колбэков прерывалась. Другими словами, последующие колбэки 'before' не выполнялись, как и экшн, обернутый в колбэки.

В Rails 5.0, возврат `false` колбэком Active Record или Active Model не будет иметь этого побочного эффекта прерывания цепочки колбэков. Вместо этого, цепочки колбэков должны быть явно прерваны вызовом `throw(:abort)`.

При апгрейде с Rails 4.2 на Rails 5.0, возврат `false` в этих типах колбэков все еще будет прерывать цепочку колбэков, но вы получите предостережение об устаревании об этом грядущем изменении.

Когда вы будете готовы, можно переключиться на новое поведение и убрать предостережение об устаревании, добавив следующую конфигурацию в `config/application.rb`:

```ruby
ActiveSupport.halt_callback_chains_on_return_false = false
```

Отметим, что эта опция не влияет на колбэки Active Support, так как они никогда не прерывались в зависимости от возвращаемого значения.

За подробностями обратитесь к [#17227](https://github.com/rails/rails/pull/17227).

### ActiveJob теперь по умолчанию наследуется от ApplicationJob

В Rails 4.2 Active Job наследуется от `ActiveJob::Base`. В Rails 5.0 это поведение было изменено на наследование от `ApplicationJob`.

При апгрейде с Rails 4.2 на Rails 5.0 необходимо создать файл `application_job.rb` в `app/jobs/` со следующим содержимым:

```ruby
class ApplicationJob < ActiveJob::Base
end
```

Затем убедитесь, что все классы заданий наследуются от него.

За подробностями обратитесь к [#19034](https://github.com/rails/rails/pull/19034).

### Тестирование контроллеров Rails

#### Извлечение некоторых методов хелпера в `rails-controller-testing`

`assigns` и `assert_template` были извлечены в гем `rails-controller-testing`. Чтобы продолжить использование этих методов, добавьте `gem "rails-controller-testing"` в свой `Gemfile`.

Если вы используете RSpec для тестирования, обратитесь к документации гема по требуемой дополнительной конфигурации.

#### Новое поведение при загрузке файлов

Если вы используете `ActionDispatch::Http::UploadedFile` в своих тестах для загрузки файлов, то вам нужно будет использовать вместо него аналогичный класс `Rack::Test::UploadedFile`.

За подробностями обратитесь к [#26404](https://github.com/rails/rails/issues/26404).

### Автозагрузка отключена после загрузки в среде production

Автозагрузка теперь отключена после загрузки в среде production по умолчанию.

Нетерпеливая загрузка приложения - это часть процесса загрузки, поэтому константы верхнего уровня все еще автоматически загружаются, их файлы не нужно требовать.

Более глубокие константы выполняются только во время выполнения, как содержимое обычных методов, и это нормально, так как содержащий их файл был нетерпеливо загружен при начальной загрузке.

Для абсолютного большинства приложений это изменение не требует каких-либо действий. Но, в очень редком случае, когда вашему приложению требуется автозагрузка в production, установите `Rails.application.config.enable_dependency_loading` в true.

### Сериализация в XML

`ActiveModel::Serializers::Xml` был извлечен из Rails в гем `activemodel-serializers-xml`. Чтобы продолжить сериализацию в XML в вашем приложении, добавьте `gem "activemodel-serializers-xml"`в свой `Gemfile`.

### Убрана поддержка старой версии адаптера `mysql`

В Rails 5 убрана поддержка старой версии адаптера БД `mysql`. Большинство пользователей могут использовать вместо него `mysql2`. Он будет сконвертирован в отдельный гем, если найдется кто-то для его поддержки.

### Убрана поддержка Debugger

`debugger` не поддерживается Ruby 2.2, который требуется для Rails 5. Вместо него используйте `byebug`.

### Использование `bin/rails` для запуска задач и тестов

Rails 5 добавляет возможность запускать задачи и тесты с помощью `bin/rails` вместо rake. В основном эти изменения были внесены параллельно с rake, но некоторые были перенесены полностью.

Чтобы запустить тесты, просто напишите `bin/rails test`.

`rake dev:cache` теперь `bin/rails dev:cache`.

Запустите `bin/rails` в директории вашего приложения, чтобы просмотреть список доступных команд.

### `ActionController::Parameters` больше не наследуется от `HashWithIndifferentAccess`

Вызов `params` в вашем приложении теперь возвращает объект, а не хэш. Если ваши параметры уже дозволены, вам не нужно вносить каких-либо изменений. Если вы используете `map` и другие методы, зависящие от возможности читать хэш, не смотря на `permitted?`, нужно апгрейднуть ваше приложение, чтобы сначала сделать permit, а затем конвертировать в хэш.

```ruby
params.permit([:proceed_to, :return_to]).to_h
```

### Теперь в `protect_from_forgery` по умолчанию `prepend: false`

`protect_from_forgery` по умолчанию `prepend: false`, что означает, что он буден вставлен в цепочку колбэков в том месте, в котором он вызывается в вашем приложении. Если вы хотите, чтобы `protect_from_forgery` всегда запускался первым, следует изменить приложение, чтобы использовался `protect_from_forgery prepend: true`.

### Обработчик шаблона по умолчанию теперь RAW

Файлы без обработчика шаблона в их расширении будут рендериться с помощью обработчика raw. Раньше Rails рендерил бы файлы с помощью обработчика шаблона ERB.

Если вы не хотите, чтобы ваш файл обрабатывался с помощью обработчика raw, следует добавить расширение к своему файлу, чтобы он анализировался подходящим обработчиком шаблона.

### Добавлено совпадение с подстановкой для зависимостей шаблонов

Теперь можно использовать совпадение с подстановкой для зависимостей ваших шаблонов. Например, если вы определяли ваши шаблоны так:

```erb
<% # Template Dependency: recordings/threads/events/subscribers_changed %>
<% # Template Dependency: recordings/threads/events/completed %>
<% # Template Dependency: recordings/threads/events/uncompleted %>
```

Теперь можно вызвать зависимость единожды с помощью символа подстановки.

```erb
<% # Template Dependency: recordings/threads/events/* %>
```

### `ActionView::Helpers::RecordTagHelper` перемещен в отдельный гем (record_tag_helper)

`content_tag_for` и `div_for` были убраны в пользу использования `content_tag`. Чтобы продолжить использование старых методов, добавьте гем `record_tag_helper` в свой `Gemfile`:

```ruby
gem "record_tag_helper", "~> 1.0"
```

За подробностями обратитесь к [#18411](https://github.com/rails/rails/issues/18411).

### Убрана поддержка гема `protected_attributes`

Гем `protected_attributes` больше не поддерживается в Rails 5.

### Убрана поддержка гема `activerecord-deprecated_finders`

Гем `activerecord-deprecated_finders` больше не поддерживается в Rails 5.

### Порядок тестов `ActiveSupport::TestCase` по умолчанию сейчас случайный

Когда в вашем приложении запускаются тесты, порядок по умолчанию сейчас `:random` вместо `:sorted`. Используйте следующую конфигурационную опцию, чтобы установить `:sorted` обратно.

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted
end
```

### `ActionController::Live` стал `Concern`

Если вы включали `ActionController::Live` в другой модуль, который включался в ваш контроллер, то вы также должны расширить модуль с помощью `ActiveSupport::Concern`. Альтернативно можно использовать хук `self.included`, чтобы включить `ActionController::Live` непосредственно в контроллер, как только включится `StreamingSupport`.

Это означает, что если в вашем приложении должен быть собственный модуль потоковой передачи, следующий код сломается в production:

```ruby
# Это обертка для потоковых контроллеров, выполняющих аутентификацию с помощью Warden/Devise.
# Смотрите https://github.com/plataformatec/devise/issues/2332
# Другим решением является аутентификация в роутере, как предложено в тщй проблеме
class StreamingSupport
  include ActionController::Live # это не будет работать в production для Rails 5
  # extend ActiveSupport::Concern # пока вы не раскомментируете эту строчку.
  def process(name)
    super(name)
  rescue ArgumentError => e
    if e.message == 'uncaught throw :warden'
      throw :warden
    else
      raise e
    end
  end
end
```

### Новые значения по умолчанию фреймворка

#### Опция Active Record для `belongs_to` - требуется по умолчанию

`belongs_to` по умолчанию теперь вызывает ошибку валидации, если связь не присутствует.

Это можно отключить для каждой связи с помощью `optional: true`.

Это значение по умолчанию можно автоматически сконфигурировать в новых приложениях. Если существующее приложение хочет добавить эту особенность, ее нужно включить в инициализаторе.

```ruby
config.active_record.belongs_to_required_by_default = true
```

Эта конфигурация по умолчанию глобальна для всех моделей, но ее можно переопределить в модели. Это может помочь мигрировать все ваши модели на связи, требуемые по умолчанию.

```ruby
class Book < ApplicationRecord
  # модель пока не готова к связям, требуемым по умолчанию

  self.belongs_to_required_by_default = false
  belongs_to(:author)
end

class Car < ApplicationRecord
  # модель готова к связям, требуемым по умолчанию

  self.belongs_to_required_by_default = true
  belongs_to(:pilot)
end
```

#### Токены CSRF для формы

Rails 5 теперь поддерживает токены CSRF для формы, чтобы ослабить атаки с помощью внедрения кода с использованием форм, созданными JavaScript. Со включенной опцией формы вашего приложения будут иметь собственный токен CSRF, который специфичен для экшна и метода этой формы.

```ruby
config.action_controller.per_form_csrf_tokens = true
```

#### Защита от подделки с помощью проверки домена

Можно настроить свое приложение для проверки, что заголовок HTTP `Origin` должен быть сверен с доменом сайта, в качестве дополнительной защиты от CSRF. Установите следующей настройке true:

```ruby
config.action_controller.forgery_protection_origin_check = true
```

#### Разрешена настройка имени очереди Action Mailer

Имя очереди рассыльщика по умолчанию `mailers`. Эта конфигурационная опция позволяет глобально изменить имя очереди. Установите следующее в своих настройках:

```ruby
config.action_mailer.deliver_later_queue_name = :new_queue_name
```

#### Поддержка кэширования фрагментов во вью Action Mailer

Установите [`config.action_mailer.perform_caching`][] в своих настройках, чтобы определить, должны ли вью Action Mailer поддерживать кэширование.

```ruby
config.action_mailer.perform_caching = true
```

[`config.action_mailer.perform_caching`]: /configuring#config-action-mailer-perform-caching

#### Настройка вывода `db:structure:dump`

Если используется `schema_search_path` или другие расширения PostgreSQL, можно контролировать, как выгружается схема. Установите `:all`, чтобы генерировать все выгрузки, или `:schema_search_path`, чтобы генерировать из пути поиска схемы.

```ruby
config.active_record.dump_schemas = :all
```

#### Настройка опций SSL, чтобы включить HSTS с поддоменами

Установите следующее в своих настройках, чтобы включить HSTS при использовании поддоменов:

```ruby
config.ssl_options = { hsts: { subdomains: true } }
```

#### Сохранение временной зоны получателя

При использовании Ruby 2.4 можно сохранять временную зону получателя, когда вызывается `to_time`.

```ruby
ActiveSupport.to_time_preserves_timezone = false
```

### Изменения с сериализацией JSON/JSONB

В Rails 5.0 изменено то, как атрибуты JSON/JSONB сериализованы и десериализованы. Теперь, если задать тип столбца, равный `String`, Active Record больше не будет превращать эту строку в `Hash` и будет вместо этого только возвращать строку. Это не ограничивается кодом, взаимодействующим с моделями, а также влияет на настройки столбца `:default` в `db/schema.rb`. Рекомендуется не задавать столбцы, равные `String`, а вместо этого передавать `Hash`, который будет автоматически преобразован в строку JSON и обратно.

(Upgrading from Rails 4.1 to Rails 4.2) Апгрейд с Rails 4.1 на Rails 4.2
------------------------------------------------------------------------

### Web Console

Сначала добавьте `gem "web-console", "~> 2.0"` в группу `:development` своего `Gemfile` и запустите `bundle install` (он не включится при апгрейде Rails). Как только он будет установлен, можно просто оставлять обращение к хелперу консоли (т.е., `<%= console %>`) в любой вью, в которой вы ее хотите включить. Консоль также предоставляется на любой странице ошибок в среде development.

### Responders

Метод `respond_with` и метод класса `respond_to` были извлечены в гем `responders`. Для их использования просто добавьте `gem "responders", "~> 2.0"` в свой `Gemfile`. Вызовы `respond_with` и `respond_to` (на уровне класса) больше не будут работать без подключения гема `responders` к зависимостям:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

Метод экземпляра `respond_to` не затронут и не требует дополнительного гема:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

Подробнее смотрите [#16526](https://github.com/rails/rails/pull/16526).

### Обработка ошибок в транзакционных колбэках

В настоящий момент Active Record замалчивает ошибки, вызванные в колбэках `after_rollback` или `after_commit`, и только пишет их в логи. В следующей версии эти ошибки больше не будут замалчиваться. Вместо этого ошибки будут распространяться обычным образом, как в других колбэках Active Record.

При определении колбэка `after_rollback` или `after_commit` вы получите предупреждение об устаревании об этом предстоящем изменении. Когда будете готовы, можно будет переключиться на новое поведение и убрать предупреждение об устаревании с помощью следующей настройки в вашем `config/application.rb`:

```ruby
config.active_record.raise_in_transactional_callbacks = true
```

Подробнее смотрите в [#14488](https://github.com/rails/rails/pull/14488) и [#16537](https://github.com/rails/rails/pull/16537).

### Упорядочивание тестовых случаев

В Rails 5.0 тестовые случаи будут по умолчанию выполняться в случайном порядке. В предвкушении этого изменения Rails 4.2 представил новую конфигурационную опцию `active_support.test_order` для явного указания упорядочивания тестов. Это позволит вам или заблокировать текущее поведение, установив этой опции `:sorted`, или переключиться на будущее поведение, установив этой опции `:random`.

Если не указать значение для этой опции, будет сформировано сообщение об устаревании. Чтобы этого избежать, добавьте следующую строчку в своей тестовой среде:

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted # или `:random`, если хотите
end
```

### Сериализованные атрибуты

При использовании произвольного кодировщика (например, `serialize :metadata, JSON`), назначение `nil` сериализованному атрибуту сохранит его в базу данных как `NULL`, вместо того, чтобы пропустить значение `nil` через кодировщик (например, `"null"` при использовании кодировщика `JSON`).

### Уровень лога в Production

В Rails 5 по умолчанию уровень лога для среды production будет изменен на `:debug` (с `:info`). Для сохранения текущего уровня по умолчанию, добавьте следующую строчку в свой `production.rb`:

```ruby
# Установите `:info`, соответствующий текущему значению по умолчанию, или
# ecnfyjdbnt `:debug` для переключения в будущее значение по умолчанию.
config.log_level = :info
```

### `after_bundle` в шаблонах Rails

Если у вас есть шаблон Rails, добавляющий все файлы в систему контроля версии, у него не получится добавить сгенерированные бинстабы, так как это выполняется до Bundler:

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }
```

Теперь можно обернуть вызовы `git` в блок `after_bundle`. Он запустится после того, как будут сгенерированы бинстабы.

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

### Санитайзер HTML в Rails

Появился выбор для санации фрагментов HTML в вашем приложении. Старый подход сканирования html официально устарел в пользу [`Rails HTML Sanitizer`](https://github.com/rails/rails-html-sanitizer).

Это означает, что методы `sanitize`, `sanitize_css`, `strip_tags` и `strip_links` теперь реализованы по-новому.

Новый санитайзер внутри использует [Loofah](https://github.com/flavorjones/loofah). Loofah, в свою очередь, использует Nokogiri, который является оберткой для парсеров, написанных на C и Java, таким образом, санирование должно стать быстрее, вне зависимости от того, на какой версии Ruby она запущена.

Новая версия обновляет `sanitize` таким образом, что он может принимать `Loofah::Scrubber` для мощной очистки. [Несколько примеров скраберов тут](https://github.com/flavorjones/loofah#loofahscrubber).

Также добавлены два новых скрабера: `PermitScrubber` и `TargetScrubber`. Подробнее читайте в [readme гема](https://github.com/rails/rails-html-sanitizer).

Документация для `PermitScrubber` и `TargetScrubber` объясняет, как можно получить полный контроль над тем, когда и как элементы должны быть отброшены.

Если вашему приложению необходима реализация старого санитайзера, включите `rails-deprecated_sanitizer` в свой `Gemfile`:

```ruby
gem "rails-deprecated_sanitizer"
```

### Тестирование DOM в Rails

[Модуль `TagAssertions`](https://api.rubyonrails.org/v4.1/classes/ActionDispatch/Assertions/TagAssertions.html) (содержащий методы, такие как `assert_tag`), [устарел](https://github.com/rails/rails/blob/6061472b8c310158a2a2e8e9a6b81a1aef6b60fe/actionpack/lib/action_dispatch/testing/assertions/dom.rb) в пользу методов `assert_select` из модуля `SelectorAssertions`, который был извлечен в [гем rails-dom-testing](https://github.com/rails/rails-dom-testing).

### Маскировка токенов аутентификации

В целях уменьшения атак SSL, `form_authenticity_token` теперь маскируется так, что он изменяется с каждым запросом. Таким образом, токены проверяются демаскируясь, а затем дешифруясь. Как последствие, любые стратегии проверки запросов из не-rails форм, которые полагались на статичный для сессии токен CSRF, должны принять это во внимание.

### Action Mailer

Раньше вызов метода рассыльщика на классе рассыльщика приводил к непосредственному выполнению соответствующего метода экземпляра. С представлением Active Job и `#deliver_later`, это больше не так. В Rails 4.2 вызов методов экземпляра откладывается, пока не будут вызваны методы `deliver_now` или `deliver_later`. Например:

```ruby
class Notifier < ActionMailer::Base
  def notify(user)
    puts "Called"
    mail(to: user.email)
  end
end
```

```ruby
mail = Notifier.notify(user) # Notifier#notify в этом месте пока еще не вызван
mail = mail.deliver_now      # Напишет "Called"
```

Это не должно привести к каким-либо значимым изменениям для большинства приложений. Однако, если необходимо синхронно выполнить некоторые не рассылающие методы, и раньше вы полагались на синхронное проксирующее поведение, следует объявить их как методы класса:

```ruby
class Notifier < ActionMailer::Base
  def self.broadcast_notifications(users)
    users.each { |user| Notifier.notify(user) }
  end
end
```

### Поддержка внешних ключей

DSL миграций был расширен поддержкой определений внешнего ключа. Если вы использовали гем Foreigner, рассмотрите его удаление. Отметьте, что поддержка внешних ключей в Rails это подмножество Foreigner. Это означает, что не каждое определение Foreigner может быть полностью заменено его аналогом DSL миграций Rails.

Процедура миграции следующая:

1. убрать `gem "foreigner"` из `Gemfile`.
2. запустить `bundle install`.
3. запустить `bin/rake db:schema:dump`.
4. убедиться, что `db/schema.rb` содержит каждое определение внешнего ключа с необходимыми опциями.

(upgrading-from-rails-4-0-to-rails-4-1) Апгрейд с Rails 4.0 на Rails 4.1
------------------------------------------------------------------------

### Защита CSRF от внешних тегов `<script>`

Или, "а-а-а-а, почему мои тесты падают!!!?", или "мой виджет `<script>` сломался!!"

Защита от межсайтовой подделки запроса (CSRF) сейчас также покрывает GET-запросы с откликами JavaScript. Это запрещает сторонним сайтам ссылаться на ваши JavaScript с помощью тега `<script>` для извлечения чувствительных данных.

Это означает, что ваши функциональные и интеграционные тесты, использующие

```ruby
get :index, format: :js
```

теперь будут вызывать защиту CSRF. Переключитесь на

```ruby
xhr :get, :index, format: :js
```

чтобы явно тестировать `XmlHttpRequest`.

NOTE: Ваши собственные теги `<script>` трактуются как межсайтовые и по умолчанию также блокируются. Если вы действительно хотите загружать JavaScript в тегах `<script>`, теперь нужно явно отключить защиту CSRF для этого экшна.

### Spring

Если хотите использовать Spring в качестве прелоадера своего приложения, вам необходимо:

1. Добавить `gem "spring", group: :development` в свой `Gemfile`.
2. Установить spring с помощью `bundle install`.
3. Сгенерировать бинстабы Spring с помощью `bundle exec spring binstub`.

NOTE: Пользовательские задачи rake по умолчанию будут запущены в окружении `development`. Если хотите запускать их в других средах, проконсультируйтесь со [Spring README](https://github.com/rails/spring#rake).

### `config/secrets.yml`

Если хотите использовать новое соглашение по хранению секретов приложения в `secrets.yml`, вам необходимо:

1. Создать файл `secrets.yml` в директории `config` со следующим содержимым:

    ```yaml
    development:
      secret_key_base:

    test:
      secret_key_base:

    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
    ```

2. Использовать существующий `secret_key_base` из инициализатора `secret_token.rb`, чтобы установить переменную среды `SECRET_KEY_BASE` для всех пользователей, под которыми запускается приложение Rails в production. Альтернативно, можно просто скопировать существующий `secret_key_base` из инициализатора `secret_token.rb` в `secrets.yml` в разделе `production`, заменив `<%= ENV["SECRET_KEY_BASE"] %>`.

3. Убрать инициализатор `secret_token.rb`.

4. Использовать `rake secret` для генерации ключей для раздела `development` и `test`.

5. Перезапустить сервер.

### Изменения в тестовом хелпере

Если ваш тестовый хелпер содержит вызов `ActiveRecord::Migration.check_pending!`, его можно убрать. Проверка теперь выполняется автоматически при `require "rails/test_help"`, хотя наличие этой строчки в вашим хелпере ничему не навредит.

### (cookies-serializer) Сериализатор куки

Приложения, созданные до Rails 4.1, используют `Marshal` для сериализации значений куки при хранении подписанных и зашифрованных куки. Если хотите использовать новый, основанный на `JSON`, формат, можно добавить файл инициализатора со следующим содержимым:

```ruby
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
```

Он прозрачно мигрирует ваши существующие куки, сериализованные `Marshal`, в новый формат, основанный на `JSON`.

При использовании сериализатора `:json` или `:hybrid`, следует иметь в виду, что не все объекты Ruby могут быть сериализованы в JSON. Например, объекты `Date` и `Time` будут сериализованы как строки, и у хэшей ключи будут преобразованы в строки.

```ruby
class CookiesController < ApplicationController
  def set_cookie
    cookies.encrypted[:expiration_date] = Date.tomorrow # => Thu, 20 Mar 2014
    redirect_to action: 'read_cookie'
  end

  def read_cookie
    cookies.encrypted[:expiration_date] # => "2014-03-20"
  end
end
```

Советуем хранить в куки только простые данные (строки и числа). Если необходимо хранить сложные объекты. необходимо производить эти преобразования вручную при чтении значений в последующих запросах.

При использовании хранения сессии в куки, все вышесказанное также применяется к хэшам `session` и `flash`.

### Изменилась структура Flash

Ключи сообщении Flash [нормализуются в строки](https://github.com/rails/rails/commit/a668beffd64106a1e1fedb71cc25eaaa11baf0c1). К ним по прежнему можно получить доступ с помощью символа или строки. Итерация по flash будет всегда возвращать строковые ключи:

```ruby
flash["string"] = "a string"
flash[:symbol] = "a symbol"

# Rails < 4.1
flash.keys # => ["string", :symbol]

# Rails >= 4.1
flash.keys # => ["string", "symbol"]
```

Убедитесь, что вы сравниваете ключи сообщений Flash со строками.

### (changes-in-json-handling) Изменения в обработке JSON

Есть несколько основных изменений в обработке JSON в Rails 4.1.

#### Убран MultiJSON

MultiJSON потерял [смысл своего существования](https://github.com/rails/rails/pull/10576) и был убран из Rails.

Если ваше приложение сейчас непосредственно зависит от MultiJSON, у вас несколько вариантов:

1. Добавьте 'multi_json' в свой `Gemfile`. Отметьте, что это может что-нибудь сломать в будущем

2. Уйти от MultiJSON в пользу использования вместо него `obj.to_json` и `JSON.parse(str)`

WARNING: Нельзя просто заменить `MultiJson.dump` и `MultiJson.load` на `JSON.dump` и `JSON.load`. Эти API гема JSON означают сериализацию и десериализацию произвольных объектов Ruby, и, в основном, [небезопасны](https://www.ruby-doc.org/stdlib-2.2.2/libdoc/json/rdoc/JSON.html#method-i-load).

#### Совместимость с гемом JSON

Исторически у Rails есть несколько проблем совместимости с гемом JSON. Использование `JSON.generate` и `JSON.dump` в приложении Rails могло вызвать неожиданные ошибки.

Rails 4.1 исправил эти проблемы, изолировав свой собственный кодер от гема JSON. API гема JSON будет функционировать, как обычно, но у него не будет доступа к особенностям, специфичным для Rails. Например:

```ruby
class FooBar
  def as_json(options = nil)
    { foo: 'bar' }
  end
end
```

```irb
irb> FooBar.new.to_json
=> "{\"foo\":\"bar\"}"
irb> JSON.generate(FooBar.new, quirks_mode: true)
=> "\"#<FooBar:0x007fa80a481610>\""
```

#### Новый кодер JSON

Кодер JSON в Rails 4.1 был переписан, чтобы воспользоваться преимуществами гема JSON. Для большинства приложений это незаметное изменение. Однако, как часть переписывания, следующие особенности были убраны из кодера:

1. Обнаружение кольцевых структур данных
2. Поддержка хука `encode_json`
3. Опция для кодирования объектов `BigDecimal` как числа, вместо строк

Если ваше приложение зависит от одной из этих особенностей, их можно вернуть, добавив гем [`activesupport-json_encoder`](https://github.com/rails/activesupport-json_encoder) в свой `Gemfile`.

#### Представление в JSON объектов Time

`#as_json` для объектов с компонентом времени (`Time`, `DateTime`, `ActiveSupport::TimeWithZone`) теперь возвращает по умолчанию с точностью до миллисекунд. Если необходимо сохранить старое поведение без миллисекунд, добавьте следующее в инициализатор:

```ruby
ActiveSupport::JSON::Encoding.time_precision = 0
```

### Использование `return` в инлайн блоках колбэков

Раньше Rails разрешал инлайн блокам колбэков использовать `return` таким образом:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { return false } # ПЛОХО
end
```

Это поведение никогда явно не поддерживалось. В связи с изменением внутри `ActiveSupport::Callbacks`, оно более недопустимо в Rails 4.1. Использование выражения `return` в инлайн блоке колбэка вызовет `LocalJumpError` при выполнении колбэка.

Использование `return` в инлайн блоке колбэка может быть отрефакторено на вычисление возвращаемого значения:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { false } # ХОРОШО
end
```

Как вариант, если предпочтителен `return`, рекомендуется явно вызывать метод:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save :before_save_callback # ХОРОШО

  private
    def before_save_callback
      false
    end
end
```

Это изменение применяется к большинству мест в Rails, где используются колбэки, включая колбэки Active Record и Active Model, а также фильтры в Action
 Controller (т.е. `before_action`).

Подробности смотрите в [этом pull request](https://github.com/rails/rails/pull/13271).

### Методы, определенные в фикстурах Active Record

Rails 4.1 вычисляет ERB каждой фикстуры в отдельном контексте, поэтому методы хелпера, определенные в фикстуре, не будут доступны в других фикстурах.

Методы хелпера, используемые в нескольких фикстурах, должны быть определены в модулях, подключаемых в новом `ActiveRecord::FixtureSet.context_class`, в `test_helper.rb`.

```ruby
module FixtureFileHelpers
  def file_sha(path)
    OpenSSL::Digest::SHA256.hexdigest(File.read(Rails.root.join('test/fixtures', path)))
  end
end
ActiveRecord::FixtureSet.context_class.include FixtureFileHelpers
```

### Обеспечение доступных локалей I18n

Сейчас Rails 4.1 устанавливает по умолчанию для опции I18n `enforce_available_locales` `true`. Это означает, что он убедится, что все локали, переданные в него, должны быть объявлены в списке `available_locales`.

Чтобы это отключить (и позволить I18n принимать *любые* опции локали), добавьте следующую конфигурацию в приложение:

```ruby
config.i18n.enforce_available_locales = false
```

Отметьте, что эта опция была добавлена как мера безопасности, чтобы обеспечить, что пользовательская информация не может использоваться как информация о локали, если она не была ранее известна. Следовательно, рекомендуется на отключать эту опцию, если у вас нет весомых причин так делать.

### Мутирующие методы (мутаторы), вызываемые на Relation

У `Relation` больше нет мутирующих методов, таких как `#map!` и `#delete_if`. Преобразовывайте в массив, вызывая `#to_a`, перед использованием этих методов.

Это предназначено для предотвращения странных программных ошибок и непонятностей в коде, вызывающем мутирующие методы непосредственно на `Relation`.

```ruby
# Вместо этого
Author.where(name: 'Hank Moody').compact!

# Теперь нужно делать так
authors = Author.where(name: 'Hank Moody').to_a
authors.compact!
```

### (changes-on-default-scopes) Изменения в скоупах по умолчанию

Скоупы по умолчанию больше не переопределяются присоединенными условиями.

В прежних версиях, при определении в модели `default_scope`, он переопределялся присоединенными условиями на то же поле. Теперь он объединяется, как и любой другой скоуп.

Раньше:

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

После:

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'inactive'
```

Чтобы получить предыдущее поведение, необходимо явно убрать условие `default_scope` с помощью `unscoped`, `unscope`, `rewhere` или `except`.

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { unscope(where: :state).where(state: 'active') }
  scope :inactive, -> { rewhere state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.inactive
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

### (rendering-content-from-string) Рендеринг содержимого из строки

Rails 4.1 предоставляет опции `:plain`, `:html` и `:body` для `render`. Эти опции теперь являются предпочтительным способом рендеринга основанного на строке содержимого, так как позволяет указать, какой тип содержимого вы хотите отослать в качестве отклика.

* `render :plain` установит тип содержимого `text/plain`
* `render :html` установит тип содержимого `text/html`
* `render :body` *не* установит заголовок типа содержимого.

С точки зрения безопасности, если не ожидается какой-либо разметки в теле отклика, следует использовать `render :plain`, так как большинство браузеров будет экранировать небезопасное содержимое вашего отклика.

Использование `render :text` будет объявлено устаревшим в будущих версиях. Пожалуйста, начинайте использовать более точные опции `:plain`, `:html` и `:body`. Использование `render :text` может вызвать риски безопасности, так как содержимое посылается как `text/html`.

### Типы данных JSON и hstore в PostgreSQL

Rails 4.1 связывает столбцы `json` и `hstore` с Ruby `Hash` со строковыми ключами. В прежних версиях использовался `HashWithIndifferentAccess`. Это означает, что доступ по символу больше не поддерживается. Это также касается `store_accessors`, основанного на столбцах `json` или `hstore`. Убедитесь, что правильно используете строковые ключи.

### Явное использование блока для `ActiveSupport::Callbacks`

Rails 4.1 теперь ожидает, что будет передан явный блок при вызове `ActiveSupport::Callbacks.set_callback`. Это изменение пришло из `ActiveSupport::Callbacks`, который был существенно переписан для релиза 4.1.

```ruby
# Раньше в Rails 4.0
set_callback :save, :around, ->(r, &block) { stuff; result = block.call; stuff }

# Теперь в Rails 4.1
set_callback :save, :around, ->(r, block) { stuff; result = block.call; stuff }
```

(upgrading-from-rails-3-2-to-rails-4-0) Апгрейд с Rails 3.2 на Rails 4.0
------------------------------------------------------------------------

Если версия Rails вашего приложения сейчас старше чем 3.2.x, следует сперва произвести апгрейд на Rails 3.2, перед попыткой обновиться до Rails 4.0.

Следующие изменения предназначены для апгрейда приложения на Rails 4.0.

### HTTP PATCH

Rails 4 теперь использует `PATCH` в качестве основного метода HTTP для обновлений, когда в `config/routes.rb` объявлен RESTful-ресурс. Экшн `update` все еще используется, и запросы `PUT` также будут направлены к экшну `update`. Поэтому, если вы используйте только стандартные RESTful-маршруты, не нужно делать никаких изменений:

```ruby
resources :users
```

```erb
<%= form_for @user do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update
    # No change needed; PATCH will be preferred, and PUT will still work.
  end
end
```

Однако, необходимо сделать изменение, если вы используете `form_for` для обновления ресурса в сочетании с произвольным маршрутом с использованием метода `PUT` HTTP:

```ruby
resources :users do
  put :update_name, on: :member
end
```

```erb
<%= form_for [ :update_name, @user ] do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update_name
    # Требуется изменение; form_for попытается использовать несуществующий маршрут PATCH.
  end
end
```

Если экшн не используется в публичном API, и можно без проблем изменить метод HTTP, можно обновить маршрут для использования `patch` вместо `put`:

```ruby
resources :users do
  patch :update_name, on: :member
end
```

Запросы `PUT` к `/users/:id` в Rails 4 направляются к `update`, как и раньше. Поэтому, если ваше API получит настоящие PUT-запросы, они будут работать. Роутер также направит запросы `PATCH` к `/users/:id` в экшн `update`.

Если экшн используется в публичном API, и вы не можете изменить используемый метод HTTP, можно обновить форму для использования метода `PUT`:

```erb
<%= form_for [ :update_name, @user ], method: :put do |f| %>
```

Подробнее о PATCH, и почему это изменение было сделано, смотрите [эту публикацию](https://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method-for-updates/) в блоге Rails.

#### Заметка о типах медиа

Корректировка для метода `PATCH` [определяет, что с `PATCH` должен использоваться тип медиа 'diff' ](http://www.rfc-editor.org/errata_search.php?rfc=5789). Один из таких форматов [JSON Patch](https://tools.ietf.org/html/rfc6902). Хотя Rails не поддерживает JSON Patch, такую поддержку легко добавить:

```ruby
# в вашем контроллере:
def update
  respond_to do |format|
    format.json do
      # выполнить частичное обновление
      @article.update params[:post]
    end

    format.json_patch do
      # выполнить сложное изменение
    end
  end
end
```

```ruby
# config/initializers/json_patch.rb
Mime::Type.register 'application/json-patch+json', :json_patch
```

Так как JSON Patch только недавно был добавлен в RFC, пока еще нет множества замечательных библиотек Ruby. Один из имеющихся гемов [hana](https://github.com/tenderlove/hana) от Aaron Patterson, но в нем еще нет полной поддержки нескольких последних изменений в спецификации.

### Gemfile

Rails 4.0 убрал группу `assets` из `Gemfile`. Вам нужно убрать эту строчку из `Gemfile` перед апгрейдом. Также следует обновить файл приложения (`config/application.rb`):

```ruby
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
```

### vendor/plugins

Rails 4.0 больше не поддерживает загрузку плагинов из `vendor/plugins`. Следует переместить любые плагины, извлекая их в гемы и помещая их в `Gemfile`. Если решаете не делать гемы, можно переместить их, скажем, в `lib/my_plugin/*` и добавить соответствующий инициализатор в `config/initializers/my_plugin.rb`.

### Active Record

* Rails 4.0 убрал identity map из Active Record, из-за [некоторых несоответствий со связями](https://github.com/rails/rails/commit/302c912bf6bcd0fa200d964ec2dc4a44abe328a6). Если вы вручную включали это в своем приложении, нужно убрать соответствующую настройку, так как от нее больше не будет эффекта: `config.active_record.identity_map`.

* Метод `delete` в связях коллекции может получать аргументы `Integer` или `String` в качестве id записей, кроме самих записей, так же, как делает метод `destroy`. Раньше он вызывал `ActiveRecord::AssociationTypeMismatch` для таких аргументов. Начиная с Rails 4.0, `delete` пытается автоматически найти записи, соответствующие переданным id, до их удаления.

* В Rails 4.0, когда переименовывается столбец или таблица, относящиеся к ним индексы также переименовываются. Если у вас есть миграции, переименовывающие индексы – они больше не нужны.

* Rails 4.0 изменил `serialized_attributes` и `attr_readonly` быть только методами класса. Не следует использовать методы экземпляра, так как они устарели. Следует заменить их на методы класса, т.е. `self.serialized_attributes` на `self.class.serialized_attributes`.

* При использовании кодировщика по умолчанию, назначение `nil` сериализованному атрибуту сохранит его в базу данных как `NULL`, вместо пропуска значения `nil` через YAML (`"--- \n...\n"`).

* Rails 4.0 убрал особенность `attr_accessible` и `attr_protected` в пользу. Для более гладкого (smooth) процесса апгрейда можно использовать [гем Protected Attributes](https://github.com/rails/protected_attributes).

* Если вы не используете Protected Attributes, можно удалить опции, относящиеся к этому гему, такие как `whitelist_attributes` или `mass_assignment_sanitizer`.

* Rails 4.0 требует, чтобы скоупы использовали вызываемый объект, такой как Proc или lambda:

    ```ruby
    scope :active, where(active: true)

    # станет
    scope :active, -> { where active: true }
    ```

* В Rails 4.0 устарели `ActiveRecord::Fixtures` в пользу `ActiveRecord::FixtureSet`.

* В Rails 4.0 устарел `ActiveRecord::TestCase` в пользу `ActiveSupport::TestCase`.

* В Rails 4.0 устарел API поиска, основанного на хэше. Это означает, что методы, которые раньше принимали "finder options", больше так не делают. Например, `Book.find(:all, conditions: { name: '1984' })` устарел в пользу `Book.where(name: '1984')`

* Все динамические методы, кроме `find_by_...` and `find_by_...!`, устарели. Вот как можно внести изменения:

      * `find_all_by_...`           становится `where(...)`.
      * `find_last_by_...`          становится `where(...).last`.
      * `scoped_by_...`             становится `where(...)`.
      * `find_or_initialize_by_...` становится `find_or_initialize_by(...)`.
      * `find_or_create_by_...`     становится `find_or_create_by(...)`.

* Отметьте, что `where(...)` возвращает relation, а не массив, как старые методы поиска. Если вы ожидаете массив, используйте `where(...).to_a`.

* Эти эквивалентные методы могут выполнять не идентичный SQL с предыдущей реализацией.

* Чтобы включить старые методы поиска, можно использовать [гем activerecord-deprecated_finders](https://github.com/rails/activerecord-deprecated_finders).

* Rails 4.0 изменил соединительную таблицу по умолчанию для связей `has_and_belongs_to_many`, удаляя общий префикс из имени второй таблицы. Любая существующая связь `has_and_belongs_to_many` между моделями с общим префиксом должна быть указана опция `join_table`. Например:

    ```ruby
    class CatalogCategory < ActiveRecord::Base
      has_and_belongs_to_many :catalog_products, join_table: 'catalog_categories_catalog_products'
    end

    class CatalogProduct < ActiveRecord::Base
      has_and_belongs_to_many :catalog_categories, join_table: 'catalog_categories_catalog_products'
    end
    ```

* Отметьте, что префикс также принимает во внимание пространства имен, поэтому связи между `Catalog::Category` и `Catalog::Product` или `Catalog::Category` и `CatalogProduct` также необходимо обновить.


### Active Resource

Rails 4.0 извлек Active Resource в отдельный гем. Если вам все еще нужна эта особенность, можете добавить [гем Active Resource](https://github.com/rails/activeresource) в своем `Gemfile`.

### Active Model

* Rails 4.0 изменил то, как прикрепляются ошибки с помощью `ActiveModel::Validations::ConfirmationValidator`. Теперь, когда не проходят валидации подтверждения, ошибка будет прикреплена к `:#{attribute}_confirmation` вместо `attribute`.

* Rails 4.0 изменил значение по умолчанию для `ActiveModel::Serializers::JSON.include_root_in_json` на `false`. Теперь сериализаторы Active Model и объекты Active Record имеют одинаковое значение по умолчанию. Это означает, что вы можете закомментировать или убрать следующую опцию в файле `config/initializers/wrap_parameters.rb`:

    ```ruby
    # Disable root element in JSON by default.
    # ActiveSupport.on_load(:active_record) do
    #   self.include_root_in_json = false
    # end
    ```

### Action Pack

* Rails 4.0 представил `ActiveSupport::KeyGenerator`, и использует его, как основу для генерации и проверки подписанных куки (среди прочего). Существующие подписанные куки, сгенерированные с помощью Rails 3.x, будут прозрачно апгрейднуты, если вы оставите существующий `secret_token` и добавите новый `secret_key_base`.

    ```ruby
    # config/initializers/secret_token.rb
    Myapp::Application.config.secret_token = 'existing secret token'
    Myapp::Application.config.secret_key_base = 'new secret key base'
    ```

    Отметьте, что вы должны обождать с установкой `secret_key_base`, пока 100% пользователей на перейдет на Rails 4.x, и вы точно не будете уверены, что не придется откатиться к Rails 3.x. Это так, потому что куки, подписанные на основе нового `secret_key_base` в Rails 4.x, обратно несовместимы с Rails 3.x. Можно спокойно оставить существующий `secret_token`, не устанавливать новый `secret_key_base` и игнорировать предупреждения, пока вы не будете полностью уверены, что апгрейд завершен.

    Если вы полагаетесь на возможность внешних приложений или JavaScript читать подписанные куки сессии вашего приложения Rails (или подписанные куки в целом), вам не следует устанавливать `secret_key_base`, пока вы не избавитесь от этой проблемы.

* Rails 4.0 шифрует содержимое основанной на куки сессии, если был установлен `secret_key_base`. Rails 3.x подписывал, но не шифровал содержимое основанной на куки сессии. Подписанные куки "безопасны", так как проверяется, что они были сгенерированы приложением, и защищены от взлома. Однако, содержимое может быть просмотрено пользователем, и шифрование содержимого устраняет эту заботу без значительного снижения производительности.

    Подробнее читайте в [Pull Request #9978](https://github.com/rails/rails/pull/9978) о переходе на подписанные куки сессии.

* Rails 4.0 убрал опцию `ActionController::Base.asset_path`. Используйте особенность конвейера ресурсов (assets pipeline).

* В Rails 4.0 устарела опция `ActionController::Base.page_cache_extension`. Используйте вместо нее `ActionController::Base.default_static_extension`.

* Rails 4.0 убрал кэширование страниц и экшнов из Action Pack. Необходимо добавить гем `actionpack-action_caching` для использования `caches_action` и `actionpack-page_caching` для использования `caches_page` в контроллерах.

* Rails 4.0 убрал парсер параметров XML. Следует добавить гем `actionpack-xml_parser`, если вам требуется эта особенность.

* Rails 4.0 изменил набор поиска `layout` по умолчанию с помощью символов или проков, возвращающих nil. Чтобы получить поведение "без макета", возвращайте false вместо nil.

* Rails 4.0 изменил клиент memcached по умолчанию с `memcache-client` на `dalli`. Чтобы произвести апгрейд, просто добавьте `gem 'dalli'` в свой `Gemfile`.

* В Rails 4.0 устарели методы `dom_id` и `dom_class` в контроллерах (они нужны только во вью). Вам следует включить модуль `ActionView::RecordIdentifier` в контроллерах, требующих эту особенность.

* В Rails 4.0 устарела опция `:confirm` для хелпера `link_to`. Вместо нее следует полагаться на атрибут data (т.е. `data: { confirm: 'Are you sure?' }`). Это устаревание также затрагивает хелперы, основанные на этом (такие как `link_to_if` или `link_to_unless`).

* Rails 4.0 изменил работу `assert_generates`, `assert_recognizes` и `assert_routing`. Теперь все эти операторы контроля вызывают `Assertion` вместо `ActionController::RoutingError`.

* Rails 4.0 вызывает `ArgumentError`, если определены коллизии в именах маршрутов. Это может быть вызвано как явно определенными именованными маршрутами, либо методом `resources`. Вот два примера, которые вызывают коллизию маршрутов с именем `example_path`:

    ```ruby
    get 'one' => 'test#example', as: :example
    get 'two' => 'test#example', as: :example
    ```

    ```ruby
    resources :examples
    get 'clashing/:id' => 'test#example', as: :example
    ```

    В первом случае можно просто избежать использование одинакового имени для нескольких маршрутов. Во втором следует использовать опции `only` или `except`, представленные методом `resources`, чтобы ограничить создаваемые маршруты, о чем подробно описано в руководстве [Роутинг в Rails](/routing#restricting-the-routes-created).

* Rails 4.0 также изменил способ отрисовки маршрутов с символами unicode. Теперь можно непосредственно отрисовывать символы unicode character. Если вы уже отрисовываете такие маршруты, их нужно изменить, например:

    ```ruby
    get Rack::Utils.escape('こんにちは'), controller: 'welcome', action: 'index'
    ```

    станет

    ```ruby
    get 'こんにちは', controller: 'welcome', action: 'index'
    ```

* Rails 4.0 требует, чтобы маршруты, использующие `match` указывали метод запроса. Например:

    ```ruby
    # Rails 3.x
    match '/' => 'root#index'

    # станет
    match '/' => 'root#index', via: :get

    # или
    get '/' => 'root#index'
  ```

* В Rails 4.0 убрана промежуточная программа `ActionDispatch::BestStandardsSupport`, `<!DOCTYPE html>` уже включает режим стандартов в соответствии с https://msdn.microsoft.com/en-us/library/jj676915(v=vs.85).aspx, а заголовок ChromeFrame был перемещен в `config.action_dispatch.default_headers`.

    Помните, что вы также должны убрать все упоминания промежуточной программы из кода своего приложения, например:

    ```ruby
    # Вызовет исключение
    config.middleware.insert_before(Rack::Lock, ActionDispatch::BestStandardsSupport)
    ```

    Также найдите в своих настройках сред `config.action_dispatch.best_standards_support`, и уберите эту строчку, если она есть.

* Rails 4.0 позволяет настраивать заголовки HTTP, установив `config.action_dispatch.default_headers`. Значения по умолчанию следующие:

    ```ruby
    config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'SAMEORIGIN',
      'X-XSS-Protection' => '1; mode=block'
    }
    ```

    Отметьте, что если ваше приложение зависит от загрузки определенных страниц в `<frame>` или `<iframe>`, тогда необходимо явно установить `X-Frame-Options` в `ALLOW-FROM ...` или `ALLOWALL`.

* В Rails 4.0 при прекомпиляции ассетов не будут больше автоматически копироваться не-JS/CSS ассеты из `vendor/assets` и `lib/assets`. Разработчики приложений на Rails и engine-ов должны поместить эти ассеты в `app/assets` или настроить [`config.assets.precompile`][].

* В Rails 4.0 вызывается `ActionController::UnknownFormat`, когда экшн не обрабатывает формат запроса. По умолчанию исключение обрабатывается, откликаясь с помощью 406 Not Acceptable, но теперь это можно переопределить. В Rails 3 всегда возвращался 406 Not Acceptable. Без возможности переопределения.

* В Rails 4.0 вызывается характерное исключение `ActionDispatch::ParamsParser::ParseError`, когда `ParamsParser` не сможет распарсить параметры запроса. Вам нужно ловить это исключение, вместо низкоуровневого `MultiJson::DecodeError`, например.

* В Rails 4.0 `SCRIPT_NAME` правильно вкладывается, когда engine монтируется в приложении, находящемся на префиксе URL. Больше не нужно устанавливать `default_url_options[:script_name]`, чтобы работать с переписанными префиксами URL.

* В Rails 4.0 устарел `ActionController::Integration` в пользу `ActionDispatch::Integration`.
* В Rails 4.0 устарел `ActionController::IntegrationTest` в пользу `ActionDispatch::IntegrationTest`.
* В Rails 4.0 устарел `ActionController::PerformanceTest` в пользу `ActionDispatch::PerformanceTest`.
* В Rails 4.0 устарел `ActionController::AbstractRequest` в пользу `ActionDispatch::Request`.
* В Rails 4.0 устарел `ActionController::Request` в пользу `ActionDispatch::Request`.
* В Rails 4.0 устарел `ActionController::AbstractResponse` в пользу `ActionDispatch::Response`.
* В Rails 4.0 устарел `ActionController::Response` в пользу `ActionDispatch::Response`.
* В Rails 4.0 устарел `ActionController::Routing` в пользу `ActionDispatch::Routing`.

[`config.assets.precompile`]: /configuring#config-assets-precompile

### Active Support

Rails 4.0 убрал псевдоним `j` для `ERB::Util#json_escape`, так как `j` уже используется для `ActionView::Helpers::JavaScriptHelper#escape_javascript`.

#### Cache

Метод кэширования изменился между Rails 3.x и 4.0. Вы должны [изменить пространство имен](/caching-with-rails#activesupport-cache-store) и развертывать с холодным кэшем.

### Порядок загрузки хелперов

В Rails 4.0 изменился порядок, в котором загружались хелперы из более чем одной директории. Ранее они собирались, а затем сортировались по алфавиту. После апгрейда на Rails 4.0, хелперы будут сохранять порядок загружаемых директорий и будут сортироваться по алфавиту только в пределах каждой директории. Если вы явно не используете параметр `helpers_path`, Это изменение повлияет только на способ загрузки хелперов из engine-ов. Если вы полагаетесь на порядок загрузки, следует проверить, что после апгрейда доступны правильные методы. Если хотите изменить порядок, в котором загружаются engine, Можно использовать метод `config.railties_order=`.

### Active Record Observer и Action Controller Sweeper

`ActiveRecord::Observer` и `ActionController::Caching::Sweeper` были извлечены в гем `rails-observers`. Следует добавить гем `rails-observers`, если вам нужны эти особенности.

### sprockets-rails

*   `assets:precompile:primary` и `assets:precompile:all` были убраны. Используйте вместо них `assets:precompile`.
*   Опция `config.assets.compress` должна быть изменена на [`config.assets.js_compressor`][], например, так:

    ```ruby
    config.assets.js_compressor = :uglifier
    ```

[`config.assets.js_compressor`]: /configuring#config-assets-js-compressor

### sass-rails

*   `asset_url` с двумя аргументами устарел. Например: `asset-url("rails.png", image)` стал `asset-url("rails.png")`

Апгрейд с Rails 3.1 на Rails 3.2
--------------------------------

Если версия Rails вашего приложения сейчас старше чем 3.1.x, следует сперва произвести апгрейд на Rails 3.1, перед попыткой обновиться до Rails 3.2.

Следующие изменения предназначены для апгрейда вашего приложения на последнюю версию 3.2.x Rails.

### Gemfile

Сделайте следующие изменения в своем `Gemfile`.

```ruby
gem "rails", "3.2.21"

group :assets do
  gem "sass-rails",   "~> 3.2.6"
  gem "coffee-rails", "~> 3.2.2"
  gem "uglifier",     ">= 1.0.3"
end
```

### config/environments/development.rb

Имеется ряд новых конфигурационных настроек, которые следует добавить в среде development:

```ruby
# Raise exception on mass assignment protection for Active Record models
config.active_record.mass_assignment_sanitizer = :strict

# Log the query plan for queries taking more than this (works
# with SQLite, MySQL, and PostgreSQL)
config.active_record.auto_explain_threshold_in_seconds = 0.5
```

### config/environments/test.rb

Также должна быть добавлена конфигурационная настройка `mass_assignment_sanitizer` в `config/environments/test.rb`:

```ruby
# Raise exception on mass assignment protection for Active Record models
config.active_record.mass_assignment_sanitizer = :strict
```

### vendor/plugins

В Rails 3.2 устаревает `vendor/plugins`, а в Rails 4.0 будет убрана полностью. Хотя это и не требуется строго при апгрейде на Rails 3.2, можно начать перемещать любые плагины, извлекая их в гемы и помещая их в `Gemfile`. Если решаете не делать гемы, можно переместить их, скажем, в `lib/my_plugin/*` и добавить соответствующий инициализатор в `config/initializers/my_plugin.rb`.

### Active Record

Опция `:dependent => :restrict` была убрана из `belongs_to`. Если хотите предотвратить удаление объекта, если имеются какие-либо связанные объекты, можно установить `:dependent => :destroy` и возвращать `false` после проверки существования связи из любого колбэка на destroy связанного объекта.

Апгрейд с Rails 3.0 на Rails 3.1
--------------------------------

Если версия Rails вашего приложения сейчас старше чем 3.0.x, следует сперва произвести апгрейд на Rails 3.0, перед попыткой обновиться до Rails 3.1.

Следующие изменения предназначены для апгрейда вашего приложения на Rails 3.1.12, последнюю версию 3.1.x Rails.

### Gemfile

Сделайте следующие изменения в своем `Gemfile`.

```ruby
gem "rails", "3.1.12"
gem "mysql2"

# Needed for the new asset pipeline
group :assets do
  gem "sass-rails",   "~> 3.1.7"
  gem "coffee-rails", "~> 3.1.1"
  gem "uglifier",     ">= 1.0.3"
end

# jQuery is the default JavaScript library in Rails 3.1
gem "jquery-rails"
```

### config/application.rb

Конвейер ресурсов (asset pipeline) требует следующих добавлений:

```ruby
config.assets.enabled = true
config.assets.version = "1.0"
```

Если ваше приложение использует маршрут "/assets" для ресурса, можно изменить префикс, используемый для ассетов, чтобы избежать конфликтов:

```ruby
# Defaults to '/assets'
config.assets.prefix = '/asset-files'
```

### config/environments/development.rb

Уберите настройку для RJS `config.action_view.debug_rjs = true`.

Добавьте эти настройки, если вы включили конвейер ресурсов:

```ruby
# Do not compress assets
config.assets.compress = false

# Expands the lines which load the assets
config.assets.debug = true
```

### config/environments/production.rb

Снова, большая часть изменений относится к конвейеру ресурсов. Подробнее о них можно прочитать в руководстве [Asset Pipeline](/asset-pipeline).

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
# config.assets.precompile += %w( admin.js admin.css )

# Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
# config.force_ssl = true
```

### config/environments/test.rb

Можно увеличить производительность тестов, добавив следующее в среде test:

```ruby
# Configure static asset server for tests with Cache-Control for performance
config.public_file_server.enabled = true
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=3600'
}
```

### config/initializers/wrap_parameters.rb

Добавьте эти файлы со следующим содержимым, если хотите оборачивать параметры во вложенный хэш. Для новых приложений это включено по умолчанию.

```ruby
# Be sure to restart your server when you modify this file.
# This file contains settings for ActionController::ParamsWrapper which
# is enabled by default.

# Enable parameter wrapping for JSON. You can disable this by setting :format to an empty array.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# Disable root element in JSON by default.
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
```

### config/initializers/session_store.rb

Необходимо изменить ключ сессии на другой, или удалить все сессии:

```ruby
# in config/initializers/session_store.rb
AppName::Application.config.session_store :cookie_store, key: 'SOMETHINGNEW'
```

или

```bash
$ bin/rake db:sessions:clear
```

### Убрать опции :cache и :concat в хелперах ассетов во вью

* Вместе с конвейером ресурсов опции :cache и :concat больше не используются, удалите эти опции из вью.
