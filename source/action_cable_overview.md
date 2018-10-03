Обзор Action Cable
==================

В этом руководстве вы изучите, как работает Action Cable, и как использовать WebSockets для внедрения функциональности реального времени в ваше приложение Rails.

После прочтения этого руководства, вы узнаете:

* Что такое Action Cable и об его интеграции на бэкенде и фронтенде
* Как настроить Action Cable
* Как настроить каналы
* О настройке развертывания и архитектуры для запуска Action Cable

--------------------------------------------------------------------------------

Введение
--------

Action Cable с легкостью интегрирует [WebSockets](https://ru.wikipedia.org/wiki/WebSocket) с остальными частями приложения Rails. Он позволяет писать функциональность реального времени на Ruby в стиле и формате остальной части приложения Rails, в то же время являясь производительным и масштабируемым. Он представляет полный стек, включая клиентский фреймворк на JavaScript и серверный фреймворк на Ruby. Вы получаете доступ к моделям предметной области, написанным с помощью Active Record или другой ORM на выбор.

Что такое Pub/Sub
-----------------

[Pub/Sub](https://ru.wikipedia.org/wiki/Издатель-подписчик_(шаблон_проектирования)), или Publish-Subscribe, относится к парадигме очереди сообщений, когда отправители информации (publishers) посылают данные в абстрактный класс получателей (subscribers), без указания отдельных получателей. Action Cable использует этот подход для коммуникации между сервером и множеством клиентов.

## Серверные компоненты

### Соединения

*Соединения* (connection) формируют основу взаимоотношения клиента с сервером. Для каждого WebSocket, принимаемого сервером, на стороне сервера будет инициализирован объект соединения. Этот объект становится родителем для всех *подписок на канал*, которые создаются впоследствии. Само соединение не работает с какой-либо определенной логикой приложения после аутентификации и авторизации. Клиент соединения WebSocket называется *потребителем* соединения (consumer). Отдельный пользователь создаст одну пару потребитель-соединение на каждую вкладку браузера, окно или устройство, которые он использует.

Соединения - это экземпляры класса `ApplicationCable::Connection`. В этом классе вы авторизуете входящее соединение и приступаете к его созданию, если пользователь может быть идентифицирован.

#### (connection-setup) Настройка соединения

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        if verified_user = User.find_by(id: cookies.encrypted[:user_id])
          verified_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
```

Здесь `identified_by` — это идентификатор соединения, который может быть использован, чтобы найти определенное соединение позже. Отметьте, что все, помеченное как идентификатор, автоматически создаст делегирование с тем же именем в каждом экземпляре канала, унаследованного от соединения.

Этот пример полагается на факт, что вы уже провели аутентификацию пользователя где-то в вашем приложении, и что успешная аутентификация устанавливает подписанные куки с ID пользователя.

Тогда куки автоматически посылаются в экземпляр соединения при попытке нового соединения, и используются для установления `current_user`. Идентифицировав соединения тем же текущим пользователем, вы также удостоверяетесь, что в дальнейшем можете получить все открытые соединения данного пользователя (и потенциально рассоединить их все, если пользователь удален или не авторизован).

### Каналы

*Канал* инкапсулирует логическую единицу работы, схожей с той, что делает контроллер в обычном MVC. По умолчанию Rails создает родительский класс `ApplicationCable::Channel` для инкапсуляции логики, общей для ваших каналов.

#### (parent-channel-setup) Настройка родительского канала

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

Далее можно создать собственные классы каналов. Например, можно создать `ChatChannel` и `AppearanceChannel`:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
end

# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
end
```

Затем потребитель может быть подписан на один или оба этих канала.

#### Подписки

Потребитель подписывается на канал, действуя как *подписчик* (subscriber). Это соединение называется *подпиской*. Созданные сообщения затем маршрутизируются на эти подписки на канал, основываясь на идентификаторе, посланным потребителем cable.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  # Вызывается, когда потребитель успешно
  # стал подписчиком этого канала
  def subscribed
  end
end
```

## Клиентские компоненты

### Соединения

Потребителям нужен экземпляр соединения на их стороне. Оно может быть установлено с использованием следующего JavaScript, который генерируется в Rails по умолчанию:

#### (connect-consumer) Присоединение потребителя

```js
// app/assets/javascripts/cable.js
//= require action_cable
//= require_self
//= require_tree ./channels

(function() {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer();
}).call(this);
```

Это подготовит потребителя, который по умолчанию присоединится к `/cable` на вашем сервере. Соединение не будет установлено, пока вы не определите хотя бы одну подписку, в которой вы заинтересованы.

#### (Subscriber) Подписчик

Потребитель становится подписчиком создав подписку на заданный канал:

```coffeescript
# app/assets/javascripts/cable/subscriptions/chat.coffee
App.cable.subscriptions.create { channel: "ChatChannel", room: "Best Room" }

# app/assets/javascripts/cable/subscriptions/appearance.coffee
App.cable.subscriptions.create { channel: "AppearanceChannel" }
```

Хотя это создает подписку, функциональность требует отклика на полученные данные, что будет описано позже.

Потребитель может действовать как подписчик на заданный канал любое количество раз. Например, потребитель может подписаться на несколько комнат чата одновременно:

```coffeescript
App.cable.subscriptions.create { channel: "ChatChannel", room: "1st Room" }
App.cable.subscriptions.create { channel: "ChatChannel", room: "2nd Room" }
```

## Клиент-серверное взаимодействие

### Потоки (Streams)

*Потоки* предоставляют механизм, с помощью которого каналы направляют опубликованный контент (трансляции) их подписчикам.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

Если у вас есть поток, относящийся к модели, тогда используемая трансляция может быть сгенерирована из модели и канала. Следующий пример подпишет на трансляцию вида `comments:Z2lkOi8vVGVzdEFwcC9Qb3N0LzE`

```ruby
class CommentsChannel < ApplicationCable::Channel
  def subscribed
    post = Post.find(params[:id])
    stream_for post
  end
end
```

Затем можно транслировать на этот канал следующим образом:

```ruby
CommentsChannel.broadcast_to(@post, @comment)
```

### (broadcasting) Трансляция

*Трансляция* — это ссылка pub/sub, по которой все, переданное издателем (publisher), направляется непосредственно подписчикам канала, которые читают из потока трансляции с этим именем. Каждый канал может писать в поток ноль или более трансляций. Трансляции — это очередь реального времени. Если потребитель не читает поток (не подписан на данный канал), он не получит трансляцию, когда присоединится позже.

Трансляции вызываются где угодно в приложении Rails:

```ruby
WebNotificationsChannel.broadcast_to(
  current_user,
  title: 'New things!',
  body: 'All the news fit to print'
)
```

Вызов `WebNotificationsChannel.broadcast_to` помещает сообщение в очередь pubsub текущего адаптера подписки (по умолчанию `redis` для production и `async` для development и test сред) под отдельным именем трансляции для каждого пользователя. Для пользователя с ID 1, имя трансляции будет `web_notifications:1`.

Канал проинструктирован писать в поток все, что приходит в `web_notifications:1`, непосредственно на клиент, вызывая колбэк `received`.

### Подписки

Когда потребитель подписывается на канал, он действует как подписчик. Это соединение называется подпиской. Затем, входящие сообщения направляются на эти подписки на канал, основываясь на идентификаторе, посланным потребителем cable.

```coffeescript
# app/assets/javascripts/cable/subscriptions/chat.coffee
# Предполагаем, что вы уже запросили право посылать веб-уведомления
App.cable.subscriptions.create { channel: "ChatChannel", room: "Best Room" },
  received: (data) ->
    @appendLine(data)

  appendLine: (data) ->
    html = @createLine(data)
    $("[data-chat-room='Best Room']").append(html)

  createLine: (data) ->
    """
    <article class="chat-line">
      <span class="speaker">#{data["sent_by"]}</span>
      <span class="body">#{data["body"]}</span>
    </article>
    """
```

### Передача параметров в каналы

Вы можете передавать параметры из клиента на сервер при создании подписки. Например:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

Объект, переданный в качестве первого аргумента в `subscriptions.create`, станет хэшем params в канале cable. Ключевое слово `channel` обязательное:

```coffeescript
# app/assets/javascripts/cable/subscriptions/chat.coffee
App.cable.subscriptions.create { channel: "ChatChannel", room: "Best Room" },
  received: (data) ->
    @appendLine(data)

  appendLine: (data) ->
    html = @createLine(data)
    $("[data-chat-room='Best Room']").append(html)

  createLine: (data) ->
    """
    <article class="chat-line">
      <span class="speaker">#{data["sent_by"]}</span>
      <span class="body">#{data["body"]}</span>
    </article>
    """
```

```ruby
# Это вызывается где-нибудь в приложении,
# возможно из NewCommentJob
ActionCable.server.broadcast(
  "chat_#{room}",
  sent_by: 'Paul',
  body: 'This is a cool chat app.'
)
```

### Перетрансляция сообщения

Обычным сценарием является *перетрансляция* сообщения, посланного одним клиентом, любым другим подсоединенным клиентам.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end

  def receive(data)
    ActionCable.server.broadcast("chat_#{params[:room]}", data)
  end
end
```

```coffeescript
# app/assets/javascripts/cable/subscriptions/chat.coffee
App.chatChannel = App.cable.subscriptions.create { channel: "ChatChannel", room: "Best Room" },
  received: (data) ->
    # data => { sent_by: "Paul", body: "This is a cool chat app." }

App.chatChannel.send({ sent_by: "Paul", body: "This is a cool chat app." })
```

Перетрансляция будет получена всеми подсоединенными клиентами, _включая_ клиента, отправившего сообщение. Отметьте, что params те же самые, что были при подписке на канал.

## Полные примеры

Следующие шаги настройки общие для обоих примеров:

  1. [Настройка вашего соединения](#connection-setup).
  2. [Настройка родительского канала](#parent-channel-setup).
  3. [Присоединение вашего потребителя](#connect-consumer).

### Пример 1: Появление пользователя

Вот простой пример канала, отслеживающего является ли пользователь онлайн или нет, и на какой он странице. (Это полезно для создания особенностей присутствия, наподобие зеленой точки рядом с именем пользователя, если он онлайн).

Создание канала появлений на сервере:

```ruby
# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    current_user.appear
  end

  def unsubscribed
    current_user.disappear
  end

  def appear(data)
    current_user.appear(on: data['appearing_on'])
  end

  def away
    current_user.away
  end
end
```

Когда инициализируется подписка, вызывается колбэк `subscribed`, и мы имеем возможность сказать "определенно, текущий пользователь появился онлайн". Это API появления/исчезновения может быть реализовано в Redis, базе данных или еще как-нибудь.

Создание подписки на канал появлений на клиенте:

```coffeescript
# app/assets/javascripts/cable/subscriptions/appearance.coffee
App.cable.subscriptions.create "AppearanceChannel",
  # Вызывается, когда подписка готова на сервере для использования.
  connected: ->
    @install()
    @appear()

  # Вызывается, когда закрывается соединения WebSocket.
  disconnected: ->
    @uninstall()

  # Вызывается, когда подписка отвергается сервером.
  rejected: ->
    @uninstall()

  appear: ->
    # Вызывает `AppearanceChannel#appear(data)` на сервере.
    @perform("appear", appearing_on: $("main").data("appearing-on"))

  away: ->
    # Вызывает `AppearanceChannel#away` на сервере.
    @perform("away")


  buttonSelector = "[data-behavior~=appear_away]"

  install: ->
    $(document).on "turbolinks:load.appearance", =>
      @appear()

    $(document).on "click.appearance", buttonSelector, =>
      @away()
      false

    $(buttonSelector).show()

  uninstall: ->
    $(document).off(".appearance")
    $(buttonSelector).hide()
```

##### Клиент-серверное взаимодействие

1. **Клиент** соединяется с **Сервером** с помощью `App.cable = ActionCable.createConsumer("ws://cable.example.com")`. (`cable.js`). **Сервер** идентифицирует экземпляр этого соединения по `current_user`.

2. **Клиент** подписывается на канал появлений с помощью `App.cable.subscriptions.create(channel: "AppearanceChannel")`. (`appearance.coffee`)

3. **Сервер** распознает, что была инициализирована новая подписка для канала появлений, и запускает колбэк `subscribed`, вызывающий метод `appear` на `current_user`. (`appearance_channel.rb`)

4. **Клиент** распознав, что подписка была установлена, вызывает `connected` (`appearance.coffee`), который, в свою очередь, вызывает `@install` и `@appear`. `@appear` вызывает `AppearanceChannel#appear(data)` на сервере и предоставляет хэш данных `appearing_on: $("main").data("appearing-on")`. Это возможно, так как экземпляр канала на сервере автоматически открывает публичные методы, объявленные в классе (кроме колбэков), таким образом, они достижимы для вызова в качестве удаленных процедур с помощью метода подписки `perform`.

5. **Сервер** получает запрос для экшна `appear` на канале появлений для соединения, идентифицированного `current_user`. (`appearance_channel.rb`). **Сервер** получает данные с ключом `:appearing_on` из хэша данных и устанавливает его в качестве значения для ключа `:on`, передаваемого в `current_user.appear`.

### Пример 2: Получение новых веб-уведомлений

Пример с появлением пользователей был об открытии серверного функциональности для вызова на стороне клиента через соединение WebSocket. Но отличительная особенность WebSockets в том, что они двусторонние. Давайте покажем пример, когда сервер вызывает экшн на клиенте.

Это канал веб-уведомлений, позволяющий показать веб-уведомления на клиенте при трансляции в правильные потоки:

Создание канала веб-уведомлений на сервере:

```ruby
# app/channels/web_notifications_channel.rb
class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

Создание подписки на канал веб-уведомлений на клиенте:

```coffeescript
# app/assets/javascripts/cable/subscriptions/web_notifications.coffee
# На клиенте полагаем, что уже запросили право
# посылать веб-уведомления
App.cable.subscriptions.create "WebNotificationsChannel",
  received: (data) ->
    new Notification data["title"], body: data["body"]
```

Транслируем содержимое в экземпляр канала веб-уведомлений откуда-нибудь из приложения:

```ruby
# Это вызывается где-то в приложении, возможно из NewCommentJob
WebNotificationsChannel.broadcast_to(
  current_user,
  title: 'New things!',
  body: 'All the news fit to print'
)
```

Вызов `WebNotificationsChannel.broadcast_to` помещает сообщение в очередь pubsub текущего адаптера подписки под отдельным именем трансляции для каждого пользователя. Для пользователя с ID 1, имя трансляции будет `web_notifications:1`.

Канал проинструктирован писать в поток все, что приходит в `web_notifications:1`, непосредственно на клиент, вызывая колбэк `received`. Данные, передаваемые как аргумент, – это хэш, посылаемый в качестве второго параметра в вызов трансляции на сервере, кодируемый для передачи в JSON и распакованный в аргументе data, приходящем как `received`.

### Больше полных примеров

Смотрите репозиторий [rails/actioncable-examples](https://github.com/rails/actioncable-examples), чтобы получить полный пример, как настроить Action Cable в приложении Rails и добавить каналы.

## Настройка

У Action Cable есть две требуемые настройки: адаптер подписки и допустимые домены запроса.

### Адаптер подписки

По умолчанию Action Cable ищет конфигурационный файл в `config/cable.yml`. Этот файл должен указывать адаптер для каждой среды Rails. Подробности об адаптерах смотрите в разделе [Зависимости](#dependencies).

```yaml
development:
  adapter: async

test:
  adapter: async

production:
  adapter: redis
  url: redis://10.10.3.153:6381
  channel_prefix: appname_production
```

#### Конфигурация адаптера

Ниже приведен список адаптеров подписки, доступных для конечных пользователей.

##### Адаптер async

Асинхронный адаптер предназначен для development/testing сред и не должен использоваться в production.

##### Адаптер Redis

Адаптер Redis требует от пользователей предоставления URL, указывающего на сервер Redis. Кроме того, может быть предоставлен `channel_prefix`, чтобы избежать конфликта имен каналов при использовании одного и того же сервера Redis для нескольких приложений. Смотрите [документацию Redis PubSub](https://redis.io/topics/pubsub#database-amp-scoping) для получения дополнительной информации.

##### Адаптер PostgreSQL

Адаптер PostgreSQL использует пул подключений Active Record и, соответственно, конфигурацию базы данных приложения `config/database.yml` для ее подключения. Это может измениться в будущем. [#27214](https://github.com/rails/rails/issues/27214)

### Допустимые домены запроса

Action Cable принимает только запросы с определенных доменов, которые передаются в конфигурацию сервера массивом. Домены могут быть экземплярами строк или регулярных выражений, с которыми выполняется сверка.

```ruby
config.action_cable.allowed_request_origins = ['http://rubyonrails.com', %r{http://ruby.*}]
```

Чтобы отключить и, тем самым, разрешить запросы с любого домена:

```ruby
config.action_cable.disable_request_forgery_protection = true
```

По умолчанию Action Cable позволяет все запросы из localhost:3000 при запуске в среде development.

### Настройка потребителя

Чтобы сконфигурировать URL, добавьте вызов `action_cable_meta_tag` в макете HTML HEAD. Он использует URL или путь, обычно устанавливаемые с помощью `config.action_cable.url` в файлах настройки среды.

### Другие настройки

Другой обычной опцией для настройки являются теги логирования, присоединяемые к логгеру для каждого соединения. Вот пример, использующий при тегировании идентификатор пользовательской записи при наличии, а в противном случае "no-account"

```ruby
config.action_cable.log_tags = [
  -> request { request.env['user_account_id'] || "no-account" },
  :action_cable,
  -> request { request.uuid }
]
```

Полный список всех конфигурационных опций смотрите в классе `ActionCable::Server::Configuration`.

Также отметим, что ваш сервер должен предоставить как минимум то же самое количество соединений с базой данных, сколько у вас есть воркеров. Пул воркеров по умолчанию установлен 4, это означает, что нужно сделать доступными соединения как минимум для них. Это можно изменить в `config/database.yml` с помощью атрибута `pool`.

## Запуск отдельного сервера cable

### В приложении

Action Cable может быть запущен вместе с вашим приложением Rails. Например, чтобы слушать запросы WebSocket на `/websocket`, укажите этот путь в `config.action_cable.mount_path`:

```ruby
# config/application.rb
class Application < Rails::Application
  config.action_cable.mount_path = '/websocket'
end
```

Можно использовать `App.cable = ActionCable.createConsumer()`, чтобы соединить с сервером cable, если `action_cable_meta_tag` вызван в макете. Произвольный путь указывается в качестве первого аргумента `createConsumer` (например, `App.cable = ActionCable.createConsumer("/websocket")`).

Для каждого экземпляра создаваемого сервера и для каждого воркера, порождаемого сервером, у вас также будет новый экземпляр Action Cable, но использование Redis позволяет синхронизировать сообщения между соединениями.

### Отдельное

Серверы cable могут быть отделены от обычного сервера приложений. Это все еще приложение Rack, но это отдельное приложение Rack. Рекомендуемая базовая настройка следующая:

```ruby
# cable/config.ru
require_relative '../config/environment'
Rails.application.eager_load!

run ActionCable.server
```

Затем можно запустить сервер с помощью бинстаба в `bin/cable`, наподобие:

```
#!/bin/bash
bundle exec puma -p 28080 cable/config.ru
```

Вышесказанное запустит сервер cable на порту 28080.

### Заметки

У сервера WebSocket нет доступа к сессии, но есть доступ к куки. Это можно использовать, если нужно обрабатывать аутентификацию. Один из способов с помощью Devise можно посмотреть в этой [статье](http://www.rubytutorial.io/actioncable-devise-authentication).

## (dependencies) Зависимости

Action Cable предоставляет интерфейс адаптера подписки для обработки его pubsub внутренностей. По умолчанию включены адаптеры асинхронный, встроенный, PostgreSQL, и адаптеры Redis. В новых приложениях Rails по умолчанию используется асинхронный (`async`) адаптер.

Часть Ruby этих вещей создана на основе [websocket-driver](https://github.com/faye/websocket-driver-ruby),
[nio4r](https://github.com/celluloid/nio4r) и [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby).

## Развертывание

Action Cable работает на комбинации WebSockets и тредов. Работа обоих фреймворка и определенного для пользователя канала, внутренне обрабатываются с помощью поддержки нативных тредов Ruby. Это означает, что вы можете без проблем использовать все обычные модели Rails, до тех пор, пока они отвечают тредобезопасности.

Сервер Action Cable реализует Rack API угона сокетов (socket hijacking), тем самым позволяет внутренне использовать многотредовый паттерн для управления соединениями, независимо от того, является ли сервер приложения многотредовым.

В соответствии с этим, Action Cable работает со популярными серверами, такими как Unicorn, Puma и Passenger.
