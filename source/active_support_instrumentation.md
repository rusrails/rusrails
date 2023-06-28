Инструментарий Active Support
=============================

Active Support — часть ядра Rails, которая предоставляет расширение языка Ruby, утилиты и другие возможности. Она включает инструментарий API, который может использоваться внутри приложения, для отслеживания определенных действий, которые возникают как в коде Ruby, так и внутри приложения Rails и самого фреймворка. Однако, она не ограничена Rails. При необходимости ее можно независимо использовать в других скриптах Ruby если вы желаете.

В этом руководстве вы научитесь использовать API инструментария Active Support для отслеживания событий внутри Rails или другого Ruby-кода.

После прочтения данного руководства вы будете знать:

* Какой инструментарий предоставляется.
* Как добавить подписчика к хуку.
* Как увидеть тайминги от инструментария в браузере.
* Какие есть хуки внутри фреймворка Rails для инструментария.
* Как создать произвольную реализацию инструментария.

--------------------------------------------------------------------------------

Введение в инструментарий
-------------------------

Инструментарий API, предоставленный Active Support, позволяет разработчикам создавать хуки, которыми могут пользоваться другие разработчики. [Некоторые из них](#huki-freymvorka-rails) присутствуют в фреймворке Rails. С этим API, разработчики могут быть оповещены при возникновении определенного события в их приложении или другом коде Ruby.

Например, есть [хук](#sql-active-record) внутри Active Record который вызывается каждый раз когда Active Record использует запрос SQL к базе данных. На этот хук можно **подписаться** и использовать его для отслеживания количества запросов в течении определенного экшна. Есть [другой хук](#process-action-action-controller), оборачивающий экшны контроллеров. Он может быть использован, например, для отслеживания, как долго выполнялся определенный экшн.

Вы даже можете [создать свои собственные события](#creating-custom-events) внутри приложения, на которые вы потом сможете подписаться.

Подписка на события
-------------------

Подписаться на событие просто. Используйте [`ActiveSupport::Notifications.subscribe`][] с блоком, чтобы слушать любое уведомление.

Блок получает следующие аргументы:

* Имя события
* Время начала
* Время окончания
* Уникальный ID для инструментария, запустившего это событие
* Полезная нагрузка для события

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # ваш собственный код
  Rails.logger.info "#{name} Received! (started: #{started}, finished: #{finished})" # process_action.action_controller Received (started: 2019-05-05 13:43:57 -0800, finished: 2019-05-05 13:43:58 -0800)
end
```

Если вы беспокоитесь об аккуратности `started` и `finished` для вычисления точного прошедшего времени, используйте [`ActiveSupport::Notifications.monotonic_subscribe`][]. Преданный блок получает те же аргументы, что и предыдущий, но `started` и `finished` получит значения более аккуратного монотонного времени вместо секундного дискретного времени.

```ruby
ActiveSupport::Notifications.monotonic_subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # ваш собственный код
  Rails.logger.info "#{name} Received! (started: #{started}, finished: #{finished})" # process_action.action_controller Received (started: 1560978.425334, finished: 1560979.429234)
end
```

Определение всех этих аргументов блока каждый раз может быть утомительно. Можно легко создать [`ActiveSupport::Notifications::Event`][] из блока аргументов, например:

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (in milliseconds)
  event.payload   # => {:extra=>information}

  Rails.logger.info "#{event} Received!"
end
```

Вы можете также подписаться на события, соответствующие регулярному выражению. Это позволит вам подписаться на несколько событий за раз. Вот как можно подписаться на все события `ActionController`:

```ruby
ActiveSupport::Notifications.subscribe(/action_controller/) do |*args|
  # Проверка всех событий ActionController
end
```

[`ActiveSupport::Notifications::Event`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications/Event.html
[`ActiveSupport::Notifications.monotonic_subscribe`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-monotonic_subscribe
[`ActiveSupport::Notifications.subscribe`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-subscribe

Просмотр таймингов от инструментария в браузере
-----------------------------------------------

Rails реализует стандарт [Server Timing](https://www.w3.org/TR/server-timing/), чтобы сделать информацию о тайминге доступной в веб-браузере. Чтобы включить, отредактируйте конфигурацию среды (обычно `development.rb`, так как это используется в основном в development), чтобы включить следующее:

```ruby
  config.server_timing = true
```

Как только настроено (включая перезагрузку вашего сервера), можно пойти в панель Developer Tools вашего браузера, затем выбрать Network и перезагрузить вашу страницу. Затем можно выбрать любой запрос к серверу Rails, и увидеть тайминги сервера во вкладке таймингов. Пример этого можно увидеть в [документации Firefox](https://firefox-source-docs.mozilla.org/devtools-user/network_monitor/request_details/index.html#server-timing).

Хуки фреймворка Rails
---------------------

Внутри фреймворка Ruby on Rails присутствует множество хуков для обычных событий. Эти события и их нагрузка описываются ниже.

### Action Controller

#### `start_processing.action_controller`

| Ключ          | Значение                                                  |
| ------------- | --------------------------------------------------------- |
| `:controller` | Имя контроллера                                           |
| `:action`     | Экшн                                                      |
| `:params`     | Хэш параметров запроса без фильтрации параметров          |
| `:headers`    | Заголовки запроса                                         |
| `:format`     | html/js/json/xml и.т.д.                                   |
| `:method`     | Метод HTTP-запроса                                        |
| `:path`       | Путь запроса                                              |

```ruby
{
  controller: "PostsController",
  action: "new",
  params: { "action" => "new", "controller" => "posts" },
  headers: #<ActionDispatch::Http::Headers:0x0055a67a519b88>,
  format: :html,
  method: "GET",
  path: "/posts/new"
}
```

#### `process_action.action_controller`

| Ключ            | Значение                                                  |
| --------------- | --------------------------------------------------------- |
| `:controller`   | Имя контроллера                                           |
| `:action`       | Экшн                                                      |
| `:params`       | Хэш параметров запроса без фильтрации параметров          |
| `:headers`      | Заголовки запроса                                         |
| `:format`       | html/js/json/xml и.т.д.                                   |
| `:method`       | Метод HTTP-запроса                                        |
| `:path`         | Путь запроса                                              |
| `:request`      | Объект [`ActionDispatch::Request`][]                      |
| `:response`     | Объект [`ActionDispatch::Response`][]                     |
| `:status`       | Код статуса HTTP                                          |
| `:view_runtime` | Количество времени, потраченного во вью                   |
| `:db_runtime`   | Время, потраченное на выполнение запросов к БД в мс       |

```ruby
{
  controller: "PostsController",
  action: "index",
  params: {"action" => "index", "controller" => "posts"},
  headers: #<ActionDispatch::Http::Headers:0x0055a67a519b88>,
  format: :html,
  method: "GET",
  path: "/posts",
  request: #<ActionDispatch::Request:0x00007ff1cb9bd7b8>,
  response: #<ActionDispatch::Response:0x00007f8521841ec8>,
  status: 200,
  view_runtime: 46.848,
  db_runtime: 0.157
}
```

#### `send_file.action_controller`

| Ключ    | Значение                  |
| ------- | ------------------------- |
| `:path` | Полный путь к файлу       |

Дополнительные ключи могут быть добавлены при вызове.

#### `send_data.action_controller`

`ActionController` не добавляет какой-либо конкретной информации при загрузке. Все опции передаются через полезную нагрузку (payload).

#### `redirect_to.action_controller`

| Ключ        | Значение                             |
| ----------- | ------------------------------------ |
| `:status`   | Код HTTP ответа                      |
| `:location` | URL для переадресации                |
| `:request`  | Объект [`ActionDispatch::Request`][] |

```ruby
{
  status: 302,
  location: "http://localhost:3000/posts/new",
  request: <ActionDispatch::Request:0x00007ff1cb9bd7b8>
}
```

#### `halted_callback.action_controller`

| Ключ      | Значение                       |
| --------- | ------------------------------ |
| `:filter` | Фильтр, прервавший экшн        |

```ruby
{
  filter: ":halting_filter"
}
```

#### `unpermitted_parameters.action_controller`

| Ключ          | Значение                                                                   |
| ------------- | -------------------------------------------------------------------------- |
| `:keys`       | Неразрешенные ключи                                                        |
| `:context`    | Хэш со следующими ключами: `:controller`, `:action`, `:params`, `:request` |

### Action Controller — кэширование

#### `write_fragment.action_controller`

| Ключ   | Значение         |
| ------ | ---------------- |
| `:key` | Полный ключ      |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `read_fragment.action_controller`

| Ключ   | Значение         |
| ------ | ---------------- |
| `:key` | Полный ключ      |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `expire_fragment.action_controller`

| Ключ   | Значение         |
| ------ | ---------------- |
| `:key` | Полный ключ      |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `exist_fragment?.action_controller`

| Ключ   | Значение         |
| ------ | ---------------- |
| `:key` | Полный ключ      |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

### Action Dispatch

#### `process_middleware.action_dispatch`

| Ключ          | Значение                    |
| ------------- | --------------------------- |
| `:middleware` | Имя промежуточной программы |

#### `redirect.action_dispatch`

| Ключ        | Значение                             |
| ----------- | ------------------------------------ |
| `:status`   | Код отклика HTTP                     |
| `:location` | URL, куда перенаправить              |
| `:request`  | Объект [`ActionDispatch::Request`][] |

#### `request.action_dispatch`

| Ключ        | Значение                             |
| ----------- | ------------------------------------ |
| `:request`  | Объект [`ActionDispatch::Request`][] |

### Action View

#### `render_template.action_view`

| Ключ          | Значение                                  |
| ------------- | ----------------------------------------- |
| `:identifier` | Полный путь до шаблона                    |
| `:layout`     | Применяемый макет                         |
| `:locals`     | Локальные переменные, переданные в шаблон |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/index.html.erb",
  layout: "layouts/application",
  locals: { foo: "bar" }
}
```

#### `render_partial.action_view`

| Ключ          | Значение                                  |
| ------------- | ----------------------------------------- |
| `:identifier` | Полный путь до шаблона                    |
| `:locals`     | Локальные переменные, переданные в шаблон |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_form.html.erb",
  locals: { foo: "bar" }
}
```

#### `render_collection.action_view`

| Ключ          | Значение                                  |
| ------------- | ----------------------------------------- |
| `:identifier` | Полный путь к шаблону                     |
| `:count`      | Размер коллекции                          |
| `:cache_hits` | Количество партиалов, извлеченных из кэша |

Ключ `:cache_hits` включен, только если коллекция рендерится с `cached: true`.

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_post.html.erb",
  count: 3,
  cache_hits: 0
}
```

#### `render_layout.action_view`

| Ключ          | Значение              |
| ------------- | --------------------- |
| `:identifier` | Полный путь к шаблону |


```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/layouts/application.html.erb"
}
```

[`ActionDispatch::Request`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html
[`ActionDispatch::Response`]: https://api.rubyonrails.org/classes/ActionDispatch/Response.html

### Active Record

#### `sql.active_record`

| Ключ                 | Значение                                      |
| -------------------- | --------------------------------------------- |
| `:sql`               | Выражение SQL                                 |
| `:name`              | Имя операции                                  |
| `:connection`        | Объект соединения                             |
| `:binds`             | Связанные параметры                           |
| `:type_casted_binds` | Приведенные связанные параметры               |
| `:statement_name`    | Имя выражения SQL                             |
| `:cached`            | `true` если использованы кэшированные запросы |

Адаптеры могут добавлять свои собственные данные.

```ruby
{
  sql: "SELECT \"posts\".* FROM \"posts\" ",
  name: "Post Load",
  connection: <ActiveRecord::ConnectionAdapters::SQLite3Adapter:0x00007f9f7a838850>,
  binds: [<ActiveModel::Attribute::WithCastValue:0x00007fe19d15dc00>],
  type_casted_binds: [11],
  statement_name: nil
}
```

#### `strict_loading_violation.active_record`

Это событие выпускается, только когда [`config.active_record.action_on_strict_loading_violation`][] установлен `:log`.

| Ключ          | Значение                                      |
| ------------- | --------------------------------------------- |
| `:owner`      | Модель с включенным `strict_loading`          |
| `:reflection` | Отражение связи, которая пытается загрузиться |

[`config.active_record.action_on_strict_loading_violation`]: configuring.html#config-active-record-action-on-strict-loading-violation

#### `instantiation.active_record`

| Ключ             | Значение                                  |
| ---------------- | ----------------------------------------- |
| `:record_count`  | Количество записей                        |
| `:class_name`    | Класс записи                              |

```ruby
{
  record_count: 1,
  class_name: "User"
}
```

### Action Mailer

#### `deliver.action_mailer`

| Ключ                  | Значение                                         |
| --------------------- | ------------------------------------------------ |
| `:mailer`             | Имя класса рассыльщика                           |
| `:message_id`         | ID сообщения, создается Mail гемом               |
| `:subject`            | Тема сообщения                                   |
| `:to`                 | Адресат(ы) сообщения                             |
| `:from`               | Отправитель сообщения                            |
| `:bcc`                | BCC адреса сообщения                             |
| `:cc`                 | CC адреса сообщения                              |
| `:date`               | Дата сообщения                                   |
| `:mail`               | Кодированная форма сообщения                     |
| `:perform_deliveries` | Была ли вызвана доставка этого сообщения или нет |

```ruby
{
  mailer: "Notification",
  message_id: "4f5b5491f1774_181b23fc3d4434d38138e5@mba.local.mail",
  subject: "Rails Guides",
  to: ["users@rails.com", "dhh@rails.com"],
  from: ["me@rails.com"],
  date: Sat, 10 Mar 2012 14:18:09 +0100,
  mail: "...", # опущено для краткости
  perform_deliveries: true
}
```

#### `process.action_mailer`

| Ключ          | Значение                 |
| ------------- | ------------------------ |
| `:mailer`     | Имя класса рассыльщика   |
| `:action`     | Экшн                     |
| `:args`       | Аргументы                |

```ruby
{
  mailer: "Notification",
  action: "welcome_email",
  args: []
}
```

### Active Support - кэширование

#### `cache_read.active_support`

| Ключ               | Значение                                                                          |
| ------------------ | --------------------------------------------------------------------------------- |
| `:key`             | Ключ, используемый при хранении                                                   |
| `:store`           | Имя класса хранилища                                                              |
| `:hit`             | Если это чтение успешно                                                           |
| `:super_operation` | `:fetch`, когда чтение выполняется с [`fetch`][ActiveSupport::Cache::Store#fetch] |

#### `cache_read_multi.active_support`

| Ключ               | Значение                                                                                      |
| ------------------ | --------------------------------------------------------------------------------------------- |
| `:key`             | Ключ, используемый при хранении                                                               |
| `:store`           | Имя класса хранилища                                                                          |
| `:hit`             | Если это чтение успешно                                                                       |
| `:super_operation` | `:fetch_multi`, когда чтение выполняется с [`fetch_multi`][ActiveSupport::Cache::Store#fetch] |

#### `cache_generate.active_support`

Это событие используется, только когда [`fetch`][ActiveSupport::Cache::Store#fetch] вызывается с блоком.

| Ключ     | Значение                        |
| -------- | ------------------------------- |
| `:key`   | Ключ, используемый при хранении |
| `:store` | Имя класса хранилища            |

Опции, переданные в `fetch`, будут объединены с полезной нагрузкой при записи в хранилище.

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_fetch_hit.active_support`

Это событие используется только когда [`fetch`][ActiveSupport::Cache::Store#fetch] вызывается с блоком.

| Ключ     | Значение                        |
| -------- | ------------------------------- |
| `:key`   | Ключ, используемый при хранении |
| `:store` | Имя класса хранилища            |

Опции, переданные в `fetch`, будут объединены с полезной нагрузкой.

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write.active_support`

| Ключ     | Значение                        |
| -------- | ------------------------------- |
| `:key`   | Ключ, используемый при хранении |
| `:store` | Имя класса хранилища            |

Хранилища кэша также могут добавлять свои собственные данные.

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write_multi.active_support`

| Ключ     | Значение                        |
| -------- | ------------------------------- |
| `:key`   | Ключ, используемый при хранении |
| `:store` | Имя класса хранилища            |


#### `cache_increment.active_support`

Это событие вызывается только при использовании [`MemCacheStore`][ActiveSupport::Cache::MemCacheStore] или [`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore].

| Ключ      | Значение                        |
| --------- | ------------------------------- |
| `:key`    | Ключ, используемый при хранении |
| `:store`  | Имя класса хранилища            |
| `:amount` | Сумма увеличения                |

```ruby
{
  key: "bottles-of-beer",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 99
}
```

#### `cache_decrement.active_support`

Это событие вызывается только при использовании хранилищ кэша Memcached или Redis.

| Ключ      | Значение                        |
| --------- | ------------------------------- |
| `:key`    | Ключ, используемый при хранении |
| `:store`  | Имя класса хранилища            |
| `:amount` | Сумма уменьшения                |

```ruby
{
  key: "bottles-of-beer",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 1
}
```

#### `cache_delete.active_support`

| Ключ     | Значение                        |
| -------- | ------------------------------- |
| `:key`   | Ключ, используемый при хранении |
| `:store` | Имя класса хранилища            |

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_delete_multi.active_support`

| Ключ     | Значение                        |
| -------- | ------------------------------- |
| `:key`   | Ключ, используемый при хранении |
| `:store` | Имя класса хранилища            |

#### `cache_delete_matched.active_support`

Это событие вызывается только при использовании [`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore], [`FileStore`][ActiveSupport::Cache::FileStore] или [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| Ключ     | Значение                   |
| -------- | -------------------------- |
| `:key`   | Используемый паттерн ключа |
| `:store` | Имя класса хранилища       |

```ruby
{
  key: "posts/*",
  store: "ActiveSupport::Cache::RedisCacheStore"
}
```

#### `cache_cleanup.active_support`

Это событие вызывается только при использовании [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| Ключ     | Значение                                 |
| -------- | ---------------------------------------- |
| `:store` | Имя класса хранилища                     |
| `:size`  | Количество записей в кэше перед очисткой |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  size: 9001
}
```

#### `cache_prune.active_support`

Это событие вызывается только при использовании [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| Ключ     | Значение                                 |
| -------- | ---------------------------------------- |
| `:store` | Имя класса хранилища                     |
| `:key`   | Целевой размер (в байтах) для кэша       |
| `:from`  | Размер (в байтах) кэша перед сокращением |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  key: 5000,
  from: 9001
}
```

#### `cache_exist?.active_support`

| Ключ     | Значение                        |
| -------- | ------------------------------- |
| `:key`   | Ключ, используемый при хранении |
| `:store` | Имя класса хранилища            |

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

[ActiveSupport::Cache::FileStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html
[ActiveSupport::Cache::MemCacheStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html
[ActiveSupport::Cache::MemoryStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
[ActiveSupport::Cache::RedisCacheStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html
[ActiveSupport::Cache::Store#fetch]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
[ActiveSupport::Cache::Store#fetch_multi]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch_multi

### Active Support — сообщения

#### `message_serializer_fallback.active_support`

| Ключ            | Значение                                |
| --------------- | --------------------------------------- |
| `:serializer`   | Основной (предназначенный) сериализатор |
| `:fallback`     | Запасной (фактический) сериализатор     |
| `:serialized`   | Сериализованная строка                  |
| `:deserialized` | Десериализованное значение              |

```ruby
{
  serializer: :json_allow_marshal,
  fallback: :marshal,
  serialized: "\x04\b{\x06I\"\nHello\x06:\x06ETI\"\nWorld\x06;\x00T",
  deserialized: { "Hello" => "World" },
}
```

### Active Job

#### `enqueue_at.active_job`

| Ключ         | Значение                                    |
| ------------ | ------------------------------------------- |
| `:adapter`   | Объект QueueAdapter, обрабатывающий задание |
| `:job`       | Объект задания                              |

#### `enqueue.active_job`

| Ключ         | Значение                                    |
| ------------ | ------------------------------------------- |
| `:adapter`   | Объект QueueAdapter, обрабатывающий задание |
| `:job`       | Объект задания                              |

#### `enqueue_retry.active_job`

| Ключ         | Значение                                    |
| ------------ | ------------------------------------------- |
| `:job`       | Объект задания                              |
| `:adapter`   | Объект QueueAdapter, обрабатывающий задание |
| `:error`     | Ошибка, вызвавшая повтор                    |
| `:wait`      | Задержка повтора                            |

#### `enqueue_all.active_job`

| Ключ         | Значение                                    |
| ------------ | ------------------------------------------- |
| `:adapter`   | Объект QueueAdapter, обрабатывающий задание |
| `:jobs`      | Массив объектов Job                         |

#### `perform_start.active_job`

| Ключ         | Значение                                    |
| ------------ | ------------------------------------------- |
| `:adapter`   | Объект QueueAdapter, обрабатывающий задание |
| `:job`       | Объект задания                              |

#### `perform.active_job`

| Ключ          | Значение                                                               |
| ------------- | ---------------------------------------------------------------------- |
| `:adapter`    | Объект QueueAdapter, обрабатывающий задание                            |
| `:job`        | Объект задания                                                         |
| `:db_runtime` | Сколько затрачено на выполнение запросов в базу данных в миллисекундах |

#### `retry_stopped.active_job`

| Ключ         | Значение                                    |
| ------------ | ------------------------------------------- |
| `:adapter`   | Объект QueueAdapter, обрабатывающий задание |
| `:job`       | Объект задания                              |
| `:error`     | Ошибка, вызвавшая повтор                    |

#### `discard.active_job`

| Ключ         | Значение                                    |
| ------------ | ------------------------------------------- |
| `:adapter`   | Объект QueueAdapter, обрабатывающий задание |
| `:job`       | Объект задания                              |
| `:error`     | Ошибка, вызвавшая отказ                     |

### Action Cable

#### `perform_action.action_cable`

| Ключ             | Значение                  |
| ---------------- | ------------------------- |
| `:channel_class` | Имя класса канала         |
| `:action`        | Экшн                      |
| `:data`          | Данные хэша               |

#### `transmit.action_cable`

| Ключ             | Значение                  |
| ---------------- | ------------------------- |
| `:channel_class` | Имя класса канала         |
| `:data`          | Данные хэша               |
| `:via`           | С помощью                 |

#### `transmit_subscription_confirmation.action_cable`

| Ключ             | Значение                  |
| ---------------- | ------------------------- |
| `:channel_class` | Имя класса канала         |

#### `transmit_subscription_rejection.action_cable`

| Ключ             | Значение                  |
| ---------------- | ------------------------- |
| `:channel_class` | Имя класса канала         |

#### `broadcast.action_cable`

| Ключ            | Значение             |
| --------------- | -------------------- |
| `:broadcasting` | Имя трансляции       |
| `:message`      | Сообщение хэша       |
| `:coder`        | Кодировщик           |

### Active Storage

#### `preview.active_storage`

| Ключ         | Значение           |
| ------------ | ------------------ |
| `:key`       | Токен безопасности |

#### `transform.active_storage`

#### `analyze.active_storage`

| Ключ         | Значение                          |
| ------------ | --------------------------------- |
| `:analyzer`  | Имя анализатора, например ffprobe |

### Active Storage — сервис хранения

#### `service_upload.active_storage`

| Ключ         | Значение                                      |
| ------------ | --------------------------------------------- |
| `:key`       | Токен безопасности                            |
| `:service`   | Имя сервиса                                   |
| `:checksum`  | Контрольная сумма для обеспечения целостности |

#### `service_streaming_download.active_storage`

| Ключ         | Значение            |
| ------------ | ------------------- |
| `:key`       | Токен безопасности  |
| `:service`   | Имя сервиса         |

#### `service_download.active_storage`

| Ключ         | Значение            |
| ------------ | ------------------- |
| `:key`       | Токен безопасности  |
| `:service`   | Имя сервиса         |

#### `service_download_chunk.active_storage`

| Ключ         | Значение                   |
| ------------ | -------------------------- |
| `:key`       | Токен безопасности         |
| `:service`   | Имя сервиса                |
| `:range`     | Диапазон битов к прочтению |

#### `service_delete.active_storage`

| Ключ         | Значение            |
| ------------ | ------------------- |
| `:key`       | Токен безопасности  |
| `:service`   | Имя сервиса         |

#### `service_delete_prefixed.active_storage`

| Ключ         | Значение            |
| ------------ | ------------------- |
| `:prefix`    | Префикс ключа       |
| `:service`   | Имя сервиса         |

#### `service_exist.active_storage`

| Ключ         | Значение                            |
| ------------ | ----------------------------------- |
| `:key`       | Токен безопасности                  |
| `:service`   | Имя сервиса                         |
| `:exist`     | Существует или же нет файл или blob |

#### `service_url.active_storage`

| Ключ         | Значение            |
| ------------ | ------------------- |
| `:key`       | Токен безопасности  |
| `:service`   | Имя сервиса         |
| `:url`       | Сгенерированный URL |

#### `service_update_metadata.active_storage`

Это событие вызывается только при использовании сервиса Google Cloud Storage.

| Ключ            | Значение                        |
| --------------- | ------------------------------- |
| `:key`          | Токен безопасности              |
| `:service`      | Имя сервиса                     |
| `:content_type` | Поле HTTP `Content-Type`        |
| `:disposition`  | Поле HTTP `Content-Disposition` |

### Action Mailbox

#### `process.action_mailbox`

| Ключ             | Значение                                                              |
| -----------------| --------------------------------------------------------------------- |
| `:mailbox`       | Экземпляр класс Mailbox, унаследованного от [`ActionMailbox::Base`][] |
| `:inbound_email` | Хэш с данными о входящем письме, которое обрабатывается               |

```ruby
{
  mailbox: #<RepliesMailbox:0x00007f9f7a8388>,
  inbound_email: {
    id: 1,
    message_id: "0CB459E0-0336-41DA-BC88-E6E28C697DDB@37signals.com",
    status: "processing"
  }
}
```

[`ActionMailbox::Base`]: https://api.rubyonrails.org/classes/ActionMailbox/Base.html

### Railties

#### `load_config_initializer.railties`

| Ключ           | Значение                                                   |
| -------------- | ---------------------------------------------------------- |
| `:initializer` | Путь к загруженному инициализатору в `config/initializers` |

### Rails

#### `deprecation.rails`

| Ключ                   | Значение                                            |
| ---------------------- | --------------------------------------------------- |
| `:message`             | Предупреждение устаревания                          |
| `:callstack`           | Откуда предупреждение пришло                        |
| `:gem_name`            | Название гема, отчитывающегося об устаревания       |
| `:deprecation_horizon` | Версия, в которой устаревшее поведение будет убрано |

Исключения
----------

Если происходит исключение во время любого инструментария, полезная нагрузка будет включать информацию о нем.

| Ключ                | Значение                                                    |
| ------------------- | ----------------------------------------------------------- |
| `:exception`        | Массив из двух элементов. Имя класса исключение и сообщение |
| `:exception_object` | Объект исключения                                           |

(creating-custom-events) Создание пользовательского события
-----------------------------------------------------------

Добавить свои события очень просто. Active Support будет делать всю тяжелую работу за вас. Просто вызовите [`ActiveSupport::Notifications.instrument`][] с `name`, `payload` и блоком. Уведомление будет отправлено после возвращения блока. Active Support сгенерирует время старта и окончания и добавит уникальный ID инструментария. Все данные переданные в вызов `instrument` будут выполнены в полезной нагрузке.

Пример:

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data do
  # Создание ваших пользовательских настроек тут
end
```

Теперь можно слушать это событие:

```ruby
ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

Также можно вызвать `instrument` без передачи блока. Это позволяет использовать инфраструктуру инструментария для других применений (обмен сообщениями).

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data

ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

Вы должны следовать соглашениям Rails при создании своих событий. Формат: `event.library`. Если ваше приложение отправляет Tweets, вы должны назвать событие `tweet.twitter`.

[`ActiveSupport::Notifications.instrument`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-instrument
