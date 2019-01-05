Инструментарий Active Support
=============================

Active Support — часть ядра Rails, которая предоставляет расширение языка Ruby, утилиты и другие возможности. Она включает инструментарий API, который может использоваться внутри приложения, для отслеживания определенных действий, которые возникают как в коде Ruby, так и внутри приложения Rails и самого фреймворка. Однако, она не ограничена Rails. При необходимости ее можно независимо использовать в других скриптах Ruby если вы желаете.

В этом руководстве вы научитесь использовать инструменты Active Support API для отслеживания событий внутри Rails или другого Ruby-кода.

После прочтения данного руководства вы будете знать:

* Какой инструментарий предоставляется.
* Какие есть хуки внутри фреймворка Rails для инструментария.
* О добавлении подписчиков к хукам.
* О построении произвольной реализации инструментария.

--------------------------------------------------------------------------------

Введение в инструментарий
-------------------------

Инструментарий API, предоставленный Active Support, позволяет разработчикам создавать хуки, которыми могут пользоваться другие разработчики. Некоторые из них присутствуют в фреймворке Rails, как показано [ниже](#huki-freymvorka-rails). С этим API, разработчики могут быть оповещены при возникновении определенного события в их приложении или другом коде Ruby.

Например, есть хук внутри Active Record который вызывается каждый раз когда Active Record использует запрос SQL к базе данных. На этот хук можно **подписаться** и использовать его для отслеживания количества запросов в течении определенного экшна. Есть другой хук, оборачивающий экшны контроллеров. Он может быть использован, например, для отслеживания, как долго выполнялся определенный экшн.

Вы даже можете создать свои собственные события внутри приложения, на которые вы потом сможете подписаться.

Хуки фреймворка Rails
---------------------

Внутри фреймворка Ruby on Rails присутствует множество хуков для обычных событий. Они описываются ниже.

Action Controller
-----------------

### write_fragment.action_controller

| Ключ   | Значение         |
| ------ | ---------------- |
| `:key` | Полный ключ      |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

### read_fragment.action_controller

| Ключ   | Значение         |
| ------ | ---------------- |
| `:key` | Полный ключ      |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

### expire_fragment.action_controller

| Ключ   | Значение         |
| ------ | ---------------- |
| `:key` | Полный ключ      |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

### exist_fragment?.action_controller

| Ключ   | Значение         |
| ------ | ---------------- |
| `:key` | Полный ключ      |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

### write_page.action_controller

| Ключ    | Значение          |
| ------- | ----------------- |
| `:path` | Полный путь       |

```ruby
{
  path: '/users/1'
}
```

### expire_page.action_controller

| Ключ    | Значение          |
| ------- | ----------------- |
| `:path` | Полный путь       |

```ruby
{
  path: '/users/1'
}
```

### start_processing.action_controller

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

### process_action.action_controller

| Ключ            | Значение                                                  |
| --------------- | --------------------------------------------------------- |
| `:controller`   | Имя контроллера                                           |
| `:action`       | Экшн                                                      |
| `:params`       | Хэш параметров запроса без фильтрации параметров          |
| `:headers`      | Заголовки запроса                                         |
| `:format`       | html/js/json/xml и.т.д.                                   |
| `:method`       | Метод HTTP-запроса                                        |
| `:path`         | Путь запроса                                              |
| `:status`       | Код статуса HTTP                                          |
| `:view_runtime` | Количество времени, потраченного во вьюхе                 |
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
  status: 200,
  view_runtime: 46.848,
  db_runtime: 0.157
}
```

### send_file.action_controller

| Ключ    | Значение                  |
| ------- | ------------------------- |
| `:path` | Полный путь к файлу       |

INFO. Дополнительные ключи могут быть добавлены при вызове.

### send_data.action_controller

`ActionController` не добавляет какой-либо конкретной информации при загрузке. Все опции передаются через полезную нагрузку (payload).

### redirect_to.action_controller

| Ключ        | Значение              |
| ----------- | --------------------- |
| `:status`   | Код HTTP ответа       |
| `:location` | URL для переадресации |

```ruby
{
  status: 302,
  location: "http://localhost:3000/posts/new"
}
```

### halted_callback.action_controller

| Ключ      | Значение                       |
| --------- | ------------------------------ |
| `:filter` | Фильтр, прервавший экшн        |

```ruby
{
  filter: ":halting_filter"
}
```

### unpermitted_parameters.action_controller

| Ключ    | Значение            |
| ------- | ------------------- |
| `:keys` | Неразрешенные ключи |

Action View
-----------

### render_template.action_view

| Ключ          | Значение               |
| ------------- | ---------------------- |
| `:identifier` | Полный путь до шаблона |
| `:layout`     | Применяемый макет      |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/index.html.erb",
  layout: "layouts/application"
}
```

### render_partial.action_view

| Ключ          | Значение               |
| ------------- | ---------------------- |
| `:identifier` | Полный путь до шаблона |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_form.html.erb",
}
```

### render_collection.action_view

| Ключ          | Значение                                  |
| ------------- | ----------------------------------------- |
| `:identifier` | Полный путь к шаблону                     |
| `:count`      | Размер коллекции                          |
| `:cache_hits` | Количество партиалов, извлеченных из кэша |

`:cache_hits` включается, только если коллекция рендерится с `cached: true`.

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_post.html.erb",
  count: 3,
  cache_hits: 0
}
```

Active Record
-------------

### sql.active_record

| Ключ                 | Значение                                      |
| -------------------- | --------------------------------------------- |
| `:sql`               | Выражение SQL                                 |
| `:name`              | Имя операции                                  |
| `:connection_id`     | Object ID объекта соединения                  |
| `:connection`        | Объект соединения                             |
| `:binds`             | Связанные параметры                           |
| `:type_casted_binds` | Приведенные связанные параметры               |
| `:statement_name`    | Имя выражения SQL                             |
| `:cached`            | `true` если использованы кэшированные запросы |

INFO. Адаптеры будут добавлять свои собственные данные.

```ruby
{
  sql: "SELECT \"posts\".* FROM \"posts\" ",
  name: "Post Load",
  connection_id: 70307250813140,
  connection: #<ActiveRecord::ConnectionAdapters::SQLite3Adapter:0x00007f9f7a838850>,
  binds: [#<ActiveModel::Attribute::WithCastValue:0x00007fe19d15dc00>],
  type_casted_binds: [11],
  statement_name: nil
}
```

### instantiation.active_record

| Key              | Value                                     |
| ---------------- | ----------------------------------------- |
| `:record_count`  | Количество записей                        |
| `:class_name`    | Класс записи                              |

```ruby
{
  record_count: 1,
  class_name: "User"
}
```

Action Mailer
-------------

### deliver.action_mailer

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

### process.action_mailer

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

Active Support
--------------

### cache_read.active_support

| Ключ               | Значение                                                |
| ------------------ | ------------------------------------------------------- |
| `:key`             | Ключ, используемый при хранении                         |
| `:hit`             | Если это чтение успешно                                 |
| `:super_operation` | :fetch добавляется когда чтение используется с `#fetch` |

### cache_generate.active_support

Это событие используется только когда `#fetch` вызывается с блоком.

| Ключ   | Значение                         |
| ------ | -------------------------------- |
| `:key` | Ключ, используемый при хранении  |

INFO. Опции, переданные в вызов, будут объединены с полезной нагрузкой при записи в хранилище.

```ruby
{
  key: 'name-of-complicated-computation'
}
```


### cache_fetch_hit.active_support

Это событие используется только когда `#fetch` вызывается с блоком.

| Ключ   | Значение                         |
| ------ | -------------------------------- |
| `:key` | Ключ, используемый при хранении  |

INFO. Опции, переданные в вызов, будут объединены с полезной нагрузкой.

```ruby
{
  key: 'name-of-complicated-computation'
}
```

### cache_write.active_support

| Ключ   | Значение                         |
| ------ | -------------------------------- |
| `:key` | Ключ, используемый при хранении  |

INFO. Кэш хранилище может добавить свой собственный ключ.

```ruby
{
  key: 'name-of-complicated-computation'
}
```

### cache_delete.active_support

| Ключ   | Значение                         |
| ------ | -------------------------------- |
| `:key` | Ключ, используемый при хранении  |

```ruby
{
  key: 'name-of-complicated-computation'
}
```

### cache_exist?.active_support

| Ключ   | Значение                         |
| ------ | -------------------------------- |
| `:key` | Ключ, используемый при хранении  |

```ruby
{
  key: 'name-of-complicated-computation'
}
```

Active Job
--------

### enqueue_at.active_job

| Ключ         | Значение                                    |
| ------------ | ------------------------------------------- |
| `:adapter`   | Объект QueueAdapter, обрабатывающий задание |
| `:job`       | Объект задания                              |

### enqueue.active_job

| Ключ         | Значение                                    |
| ------------ | ------------------------------------------- |
| `:adapter`   | Объект QueueAdapter, обрабатывающий задание |
| `:job`       | Объект задания                              |

### enqueue_retry.active_job

| Ключ         | Значение                                    |
| ------------ | ------------------------------------------- |
| `:job`       | Объект задания                              |
| `:adapter`   | Объект QueueAdapter, обрабатывающий задание |
| `:error`     | Ошибка, вызвавшая повтор                    |
| `:wait`      | Задержка повтора                            |

### perform_start.active_job

| Ключ         | Значение                                    |
| ------------ | ------------------------------------------- |
| `:adapter`   | Объект QueueAdapter, обрабатывающий задание |
| `:job`       | Объект задания                              |

### perform.active_job

| Ключ         | Значение                                    |
| ------------ | ------------------------------------------- |
| `:adapter`   | Объект QueueAdapter, обрабатывающий задание |
| `:job`       | Объект задания                              |

### retry_stopped.active_job

| Ключ         | Значение                                    |
| ------------ | ------------------------------------------- |
| `:adapter`   | Объект QueueAdapter, обрабатывающий задание |
| `:job`       | Объект задания                              |
| `:error`     | Ошибка, вызвавшая повтор                    |

### discard.active_job

| Ключ         | Значение                                    |
| ------------ | ------------------------------------------- |
| `:adapter`   | Объект QueueAdapter, обрабатывающий задание |
| `:job`       | Объект задания                              |
| `:error`     | Ошибка, вызвавшая отказ                     |

Action Cable
------------

### perform_action.action_cable

| Ключ             | Значение                  |
| ---------------- | ------------------------- |
| `:channel_class` | Имя класса канала         |
| `:action`        | Экшн                      |
| `:data`          | Данные хэша               |

### transmit.action_cable

| Ключ             | Значение                  |
| ---------------- | ------------------------- |
| `:channel_class` | Имя класса канала         |
| `:data`          | Данные хэша               |
| `:via`           | С помощью                 |

### transmit_subscription_confirmation.action_cable

| Ключ             | Значение                  |
| ---------------- | ------------------------- |
| `:channel_class` | Имя класса канала         |

### transmit_subscription_rejection.action_cable

| Ключ             | Значение                  |
| ---------------- | ------------------------- |
| `:channel_class` | Имя класса канала         |

### broadcast.action_cable

| Ключ            | Значение             |
| --------------- | -------------------- |
| `:broadcasting` | Имя трансляции       |
| `:message`      | Сообщение хэша       |
| `:coder`        | Кодировщик           |

Active Storage (Rails 5.2)
--------------------------

### service_upload.active_storage

| Ключ         | Значение                                      |
| ------------ | --------------------------------------------- |
| `:key`       | Защищенный токен                              |
| `:service`   | Имя сервиса                                   |
| `:checksum`  | Контрольная сумма для обеспечения целостности |

### service_streaming_download.active_storage

| Ключ         | Значение            |
| ------------ | ------------------- |
| `:key`       | Защищенный токен    |
| `:service`   | Имя сервиса         |

### service_download.active_storage

| Ключ         | Значение            |
| ------------ | ------------------- |
| `:key`       | Защищенный токен    |
| `:service`   | Имя сервиса         |

### service_delete.active_storage

| Ключ         | Значение            |
| ------------ | ------------------- |
| `:key`       | Защищенный токен    |
| `:service`   | Имя сервиса         |

### service_delete_prefixed.active_storage

| Ключ         | Значение            |
| ------------ | ------------------- |
| `:prefix`    | Префикс ключа       |
| `:service`   | Имя сервиса         |

### service_exist.active_storage

| Ключ         | Значение                            |
| ------------ | ----------------------------------- |
| `:key`       | Защищенный токен                    |
| `:service`   | Имя сервиса                         |
| `:exist`     | Существует или же нет файл или blob |

### service_url.active_storage

| Ключ         | Значение            |
| ------------ | ------------------- |
| `:key`       | Защищенный токен    |
| `:service`   | Имя сервиса         |
| `:url`       | Сгенерированный url |

Railties
--------

### load_config_initializer.railties

| Ключ           | Значение                                                    |
| -------------- | ----------------------------------------------------------- |
| `:initializer` | Путь к загруженному инициализатору из `config/initializers` |

Rails
-----

### deprecation.rails

| Ключ         | Значение                        |
| ------------ | ------------------------------- |
| `:message`   | Предупреждение устаревания      |
| `:callstack` | Откуда предупреждение пришло    |


Подписка на события
-------------------

Подписаться на событие просто. Используйте `ActiveSupport::Notifications.subscribe` с блоком, чтобы слушать любое уведомление.

Блок получает следующие аргументы:

* Имя события
* Время начала
* Время окончания
* Уникальный ID для инструментария, запустившего это событие
* Полезная нагрузка (описывается в предыдущем разделе)

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # Ваши собственные настройки
  Rails.logger.info "#{name} Received!"
end
```
Определение всех этих аргументов блока каждый раз может быть утомительно. Можно легко создать `ActiveSupport::Notifications::Event` из блока аргументов, например:

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  event = ActiveSupport::Notifications::Event.new *args

  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (in milliseconds)
  event.payload   # => {:extra=>information}

  Rails.logger.info "#{event} Received!"
end
```

Также можно передать блок лишь с одним аргументом, в блоке в него будет вложен объект события:

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |event|
  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (in milliseconds)
  event.payload   # => {:extra=>information}

  Rails.logger.info "#{event} Received!"
end
```

В основном вас будет интересовать сама информация. Ниже приведен краткий вариант, как можно получить информацию.

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  data = args.extract_options!
  data # { extra: :information }
end
```

Вы можете также подписаться на события, соответствующие регулярному выражению. Это позволит вам подписаться на несколько событий за раз. Вот как можно подписаться на все события `ActionController`.

```ruby
ActiveSupport::Notifications.subscribe /action_controller/ do |*args|
  # Проверка всех событий ActionController
end
```

Создание пользовательского события
----------------------------------

Добавить свои события очень просто. `ActiveSupport::Notifications` будет делать всю тяжелую работу за вас. Просто вызовите `instrument` с `name`, `payload` и блоком. Уведомление будет отправлено после возвращения блока. `ActiveSupport` сгенерирует время старта и окончания и добавит уникальный ID инструментария. Все данные переданные в вызов `instrument` будут выполнены в полезной нагрузке.

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

Вы должны следовать соглашениям Rails при создании своих событий. Формат: `event.library`. Если ваше приложение отправляет Tweets, вы должны назвать событие `tweet.twitter`.
