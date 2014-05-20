Active Support инструметарий
============================

Active Support часть ядра Rails, которое предоставляет расширение языка Ruby, утилиты и другие возможности. Одна из них включает инструментарий API, который может использоваться внутри приложения, для отслеживания определенных действий, которые возникают в Ruby коде, как внутри Rails приложения так и самого фреймфорка. Это не ограниченно Rails, однако. Это можно использовать независимо в других Ruby скриптах, если будет необходимость.

В этом гайде, вы научитесь использовать инструменты API внутри Active Support для отслеживания событий внутрий Rails или другого Ruby кода.

После прочтения данного гайда вы будете знать:

* Какой предоставлется инструментарий.
* Какие есть хуки внутри Rails фрейимворка для инструментария.
* Добавление подписчиков к хукам.
* Построение пользовательской реализации инструментария.

--------------------------------------------------------------------------------

Введение в инструметарий
------------------------

Инструметарий API, предоставленный Active Support, позволяет разработчикам предоставлять хуки, которе могут использоваться другими разработчикам. Несколько из них присутствуют в Rails фреймворке, как показано ниже (TODO: ссылка на секцию, объясняющую каждый хук). С этим API, разработчики могут выбрать когда получать уведомления, при возникновении определенного события в приложении или другом Ruby кодe.

Например, есть хук внутри Active Record который вызывается каждый раз когда Active Record использует SQL запрос к базе данных. На этот хук можно подписаться, и использовать для отслеживания количества запросов втечение определенного действия. Есть другой хук обрабатывающий действия контроллеров. Он может быть использован, например, для отслеживания, как долго определенное действие было использовано.

Вы даже можете создать свои собственные события внутри приложения на которые вы потом можете подписатся.

Хуки Rails фреймворка
---------------------

Внутри Ruby on Rails фреймворка присутствует большое количество хуков для общих событий. Они описываются ниже.

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
| `:action`     | Действие                                                  |
| `:params`     | "Хеш" параметров запроса без какой-либо фильтрации       |
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
| `:action`       | Действие                                                  |
| `:params`       | "Хеш" параметров запроса без какой-либо фильтрации       |
| `:format`       | html/js/json/xml и.т.д.                                   |
| `:method`       | Mетод HTTP запроса                                        |
| `:path`         | Путь запроса                                              |
| `:view_runtime` | Количество времени потраченного на отображение            |

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

ИНФОРМАЦИЯ. Дополнительные ключи могут быть добавлены при вызове.

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
| `:filter` | Фильтр останаливающий действие |

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
| `:layout`     | Применяемая схема      |

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

| Ключ         | Значение              |
| ------------ | --------------------- |
| `:sql`       | SQL выражение         |
| `:name`      | Название выражения    |
| `:object_id` | `self.object_id`      |

ИНФОРМАЦИЯ. Aдаптеры будут добавлять свои собственные данные.

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
  mail: "..." # omitted for brevity
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
  mail: "..." # omitted for brevity
}
```

ActiveResource
--------------

### request.active_resource

| Ключ           | Значение             |
| -------------- | -------------------- |
| `:method`      | Метод HTTP запроса   |
| `:request_uri` | Полный URI           |
| `:result`      | Объект HTTP ответа   |

Active Support
--------------

### cache_read.active_support

| Ключ               | Значение                                                |
| ------------------ | ------------------------------------------------------- |
| `:key`             | Ключ, используемый при хранении                          |
| `:hit`             | Если читается, успех                                    |
| `:super_operation` | :fetch добавляется когда чтение используется с `#fetch` |

### cache_generate.active_support

Это событие используется только когда `#fetch` вызывается с блоком.

| Ключ   | Значение                        |
| ------ | ------------------------------- |
| `:key` | Ключ используемый при хранении  |

ИНФОРМАЦИЯ. Опции переданные в вызов будут соеденены с информацией при записи в хранилище.

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

ИНФОРМАЦИЯ. Опции переданные в вызов будут информацией.

```ruby
{
  key: 'name-of-complicated-computation'
}
```

### cache_write.active_support

| Ключ   | Значение                        |
| ------ | ------------------------------- |
| `:key` | Ключ, используемый при хранении  |

ИНФОРМАЦИЯ. Кеш хранилище может добавить свой ключ.

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

Подписаться на событие просто. Используйте `ActiveSupport::Notifications.subscribe` с блоком, чтоб слушать любое уведомление.

Блок получает следующие аргументы:

* Название события
* Время начала
* Время окончания
* Уникальный ID этого события
* Нагрузка (Объяснение в предыдущей секции)

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # Ваши собственные настройки
  Rails.logger.info "#{name} Received!"
end
```
Определение всех этих аргументов блока каждый раз может быть утомительно. Вы можете легко создать `ActiveSupport::Notifications::Event` из блока аргументов, например:

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  event = ActiveSupport::Notifications::Event.new *args

  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (in milliseconds)
  event.payload   # => {:extra=>information}

  Rails.logger.info "#{event} Received!"
end
```

Большую часть времени вы будете заботиться o самой информации. Ниже приведен короткий вариант, как получить информацию.

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  data = args.extract_options!
  data # { extra: :information }
end
```

Вы можете также подписаться на события, соотвутствующие регулярному выражению. Это позволит Вам подписаться на несколько событий за раз. Тут вы можете подписаться на все события `ActionController`.

```ruby
ActiveSupport::Notifications.subscribe /action_controller/ do |*args|
  # Проверка всех событий ActionController
end
```

Создание пользовательского события
----------------------------------

Добавить свои события очень просто. `ActiveSupport::Notifications` будет делать всю тяжелую работу за Вас. Просто вызовите `instrument` с `name`, `payload` и блоком. Уведомление будет отправлено после возвращения блока. `ActiveSupport` сгенерирует время старта и окончания и уникальный ID. Все данные переданные в вызов `instrument` будут выполнены в `payload`.

Пример:

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data do
  # Создание ваших пользовательских настроек тут
end
```

Теперь Вы можете слушать это событие:

```ruby
ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

Вы должны соблюдать Rails соглашения при создании своих событий. Формат: `event.library`. Если ваше приложение отправляет Tweets, вы должны назвать событие `tweet.twitter`.
