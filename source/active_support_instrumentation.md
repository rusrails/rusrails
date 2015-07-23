Инструментарий Active Support
============================

Active Support — часть ядра Rails, которая предоставляет расширение языка Ruby, утилиты и другие возможности. Она включает инструментарий API, который может использоваться внутри приложения, для отслеживания определенных действий, которые возникают как в коде Ruby, так и внутри приложения Rails и самого фреймворка. Однако, она не ограничена Rails. При необходимости ее можно независимо использовать в других скриптах Ruby если вы желаете.

В этом руководстве вы научитесь использовать инструменты Active Support API для отслеживания событий внутри Rails или другого Ruby кода.

После прочтения данного руководства вы будете знать:

* Какой инструментарий предоставляется.
* Какие есть хуки внутри фреймворка Rails для инструментария.
* О добавлении подписчиков к хукам.
* О построении произвольной реализации инструментария.

--------------------------------------------------------------------------------

Введение в инструментарий
------------------------

Инструментарий API, предоставленный Active Support, позволяет разработчикам создавать хуки, которыми могут пользоваться другие разработчики. Некоторые из них присутствуют в фреймворке Rails, как показано [ниже](#huki-freymvorka-rails). С этим API, разработчики могут быть оповещены при возникновении определенного события в их приложении или другом коде Ruby.

Например, есть хук внутри Active Record который вызывается каждый раз когда Active Record использует запрос SQL к базе данных. На этот хук можно **подписаться** и использовать его для отслеживания количества запросов в течении определенного действия. Есть другой хук, оборачивающий экшны контроллеров. Он может быть использован, например, для отслеживания, как долго выполнялся определенный экшн.

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
| `:format`     | html/js/json/xml и.т.д.                                   |
| `:method`     | Mетод HTTP запроса                                        |
| `:path`       | Путь запроса                                              |

```ruby
{
  controller: "PostsController",
  action: "new",
  params: { "action" => "new", "controller" => "posts" },
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
| `:format`       | html/js/json/xml и.т.д.                                   |
| `:method`       | Mетод HTTP запроса                                        |
| `:path`         | Путь запроса                                              |
| `:status`       | Код статуса HTTP                                          |
| `:view_runtime` | Количество времени, потраченного во вьюхе                 |
| `:db_runtime`   | Время, потраченное на выполнение запросов к БД в мс       |

```ruby
{
  controller: "PostsController",
  action: "index",
  params: {"action" => "index", "controller" => "posts"},
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

`ActionController` не имеет какой-либо конкретной информации при загрузке. Все опции передаются через загрузку.

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
| `:filter` | Фильтр, прервавший экшн |

```ruby
{
  filter: ":halting_filter"
}
```

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

Active Record
-------------

### sql.active_record

| Ключ             | Значение              |
| ---------------- | --------------------- |
| `:sql`           | выражение SQL         |
| `:name`          | Имя операции          |
| `:connection_id` | `self.object_id`      |

INFO. Aдаптеры будут добавлять свои собственные данные.

```ruby
{
  sql: "SELECT \"posts\".* FROM \"posts\" ",
  name: "Post Load",
  connection_id: 70307250813140,
  binds: []
}
```

### identity.active_record

| Ключ             | Значение                                  |
| ---------------- | ----------------------------------------- |
| `:line`          | Главный ключ объекта для идентификации    |
| `:name`          | Класс записи                              |
| `:connection_id` | `self.object_id`                          |

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

### receive.action_mailer

| Ключ          | Значение                                     |
| ------------- | -------------------------------------------- |
| `:mailer`     | Название класса рассыльщика                  |
| `:message_id` | ID сообщения, создается Mail гемом           |
| `:subject`    | Тема сообщения                               |
| `:to`         | Адресат(ы) сообщения                         |
| `:from`       | Отправитель сообщения                        |
| `:bcc`        | BCC адреса сообщения                         |
| `:cc`         | CC адреса сообщения                          |
| `:date`       | Дата сообщения                               |
| `:mail`       | Кодированная форма сообщения                 |

```ruby
{
  mailer: "Notification",
  message_id: "4f5b5491f1774_181b23fc3d4434d38138e5@mba.local.mail",
  subject: "Rails Guides",
  to: ["users@rails.com", "ddh@rails.com"],
  from: ["me@rails.com"],
  date: Sat, 10 Mar 2012 14:18:09 +0100,
  mail: "..." # опущено для краткости
}
```

### deliver.action_mailer

| Ключ          | Значение                                     |
| ------------- | -------------------------------------------- |
| `:mailer`     | Название класса рассыльщика                  |
| `:message_id` | ID сообщения, создается Mail гемом           |
| `:subject`    | Тема сообщения                               |
| `:to`         | Адресат(ы) сообщения                         |
| `:from`       | Отправитель сообщения                        |
| `:bcc`        | BCC адреса сообщения                         |
| `:cc`         | CC адреса сообщения                          |
| `:date`       | Дата сообщения                               |
| `:mail`       | Кодированная форма сообщения                 |

```ruby
{
  mailer: "Notification",
  message_id: "4f5b5491f1774_181b23fc3d4434d38138e5@mba.local.mail",
  subject: "Rails Guides",
  to: ["users@rails.com", "ddh@rails.com"],
  from: ["me@rails.com"],
  date: Sat, 10 Mar 2012 14:18:09 +0100,
  mail: "..." # опущено для краткости
}
```

Active Support
--------------

### cache_read.active_support

| Ключ               | Значение                                                |
| ------------------ | ------------------------------------------------------- |
| `:key`             | Ключ, используемый при хранении                          |
| `:hit`             | Если это чтение успешно                                    |
| `:super_operation` | :fetch добавляется когда чтение используется с `#fetch` |

### cache_generate.active_support

Это событие используется только когда `#fetch` вызывается с блоком.

| Ключ   | Значение                        |
| ------ | ------------------------------- |
| `:key` | Ключ используемый при хранении  |

INFO. Опции, переданные в вызов, будут объединены с информацией при записи в хранилище.

```ruby
{
  key: 'name-of-complicated-computation'
}
```


### cache_fetch_hit.active_support

Это событие используется только когда `#fetch` вызывается с блоком.

| Ключ   | Значение                        |
| ------ | ------------------------------- |
| `:key` | Ключ, используемый при хранении  |

INFO. Опции, переданные в вызов, будут объединены с информацией.

```ruby
{
  key: 'name-of-complicated-computation'
}
```

### cache_write.active_support

| Ключ   | Значение                        |
| ------ | ------------------------------- |
| `:key` | Ключ, используемый при хранении  |

INFO. Кеш хранилище может добавить свой ключ.

```ruby
{
  key: 'name-of-complicated-computation'
}
```

### cache_delete.active_support

| Ключ   | Значение                        |
| ------ | ------------------------------- |
| `:key` | Ключ, используемый при хранении  |

```ruby
{
  key: 'name-of-complicated-computation'
}
```

### cache_exist?.active_support

| Ключ   | Значение                        |
| ------ | ------------------------------- |
| `:key` | Ключ, используемый при хранении  |

```ruby
{
  key: 'name-of-complicated-computation'
}
```

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

* Название события
* Время начала
* Время окончания
* Уникальный ID этого события
* Информация (описывается в предыдущей секции)

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

Добавить свои события очень просто. `ActiveSupport::Notifications` будет делать всю тяжелую работу за вас. Просто вызовите `instrument` с `name`, `payload` и блоком. Уведомление будет отправлено после возвращения блока. `ActiveSupport` сгенерирует время старта и окончания и уникальный ID. Все данные переданные в вызов `instrument` будут выполнены в `payload`.

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
