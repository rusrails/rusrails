Обзор Action Cable
==================

В этом руководстве вы изучите, как работает Action Cable, и как использовать WebSockets для внедрения функционала реального времени в ваше приложение Rails.

После прочтения этого руководства, вы узнаете:

* Как настроить Action Cable
* Как настроить каналы

Введение
--------

Action Cable с легкостью интегрирует WebSockets с остальными частями приложения Rails. Он позволяет писать функционал реального времени на Ruby в стиле и формате остальной части приложения Rails, в то же время являясь производительным и масштабируемым. Он представляет полный стек, включая клиентский фреймворк на JavaScript и серверный фреймворк на Ruby. Вы получаете доступ к моделям, написанным с помощью Active Record или другой ORM.

Что такое Pub/Sub
-----------------

Pub/Sub, или Publish-Subscribe, относится к парадигме очереди сообщений, когда отправители информации (publishers) посылают данные в абстрактный класс получателей (subscribers), без указания отдельных получателей. Action Cable использует этот подход для коммуникации между сервером и множеством клиентов.

Что такое Action Cable
----------------------

Action Cable — это сервер, который может обрабатывать несколько экземпляров соединений с помощью одного экземпляра клиент-серверного соединения, установленного с помощью соединения WebSocket.

## Серверные компоненты

### Соединения

Соединения формируют основу взаимоотношения клиента с сервером. Для каждого WebSocket, принимаемого сервером cable, на стороне сервера будет инициализирован объект Connection. Этот экземпляр становится родителем для всех подписок на канал, которые создаются впоследствии. Сам Connection не работает с какой-либо определенной логикой приложения после аутентификации и авторизации. Клиент соединения WebSocket называется потребителем (consumer). Отдельный пользователь создаст одну пару consumer-connection на каждую вкладку браузера, окно или устройство, которые он использует.

Соединения инициализируются с помощью класса `ApplicationCable::Connection` на Ruby. В этом классе вы авторизуете входящее соединение и приступаете к его созданию, если пользователь может быть идентифицирован.

#### (connection-setup) Настройка соединения

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected
      def find_verified_user
        if current_user = User.find_by(id: cookies.signed[:user_id])
          current_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
```

Здесь `identified_by` — это идентификатор соединения, который может быть использован, чтобы найти определенное соединение позе. Отметьте, что все, помеченное как идентификатор, автоматически создаст делегирование с тем же именем в каждом экземпляре канала, унаследованного от соединения.

Этот пример полагается на факт, что вы уже провели аутентификацию пользователя где-то в вашем приложении, и что успешная аутентификация устанавливает подписанные куки с `user_id`.

Тогда куки автоматически посылаются в экземпляр соединения при попытке нового соединения, и используются для установления `current_user`. Идентифицировав соединения тем же current_user, вы также удостоверяетесь, что в дальнейшем можете получить все открытые соединения данного пользователя (и потенциально рассоединить их все, если пользователь удаляется или деавторизуется).

### Каналы

Канал инкапсулирует логическую единицу работы, схожей с той, что делает контроллер в обычном MVC. По умолчанию Rails создает родительский класс `ApplicationCable::Channel` для инкапсуляции логики, общей для ваших каналов.

#### (parent-channel-setup) Настройка родительского канала

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

Далее можно создать собственные классы каналов. Например, можно создать **ChatChannel** и **AppearanceChannel**:

```ruby
# app/channels/application_cable/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
end

# app/channels/application_cable/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
end
```

Затем потребитель может быть подписан на один или оба этих канала.

#### Подписки

Когда потребитель подписан на канал, он действует как подписчик (subscriber); Это соединение называется подпиской. Входящие сообщения затем маршрутизируются на эти подписки на канал, основываясь на идентификаторе, посланным потребителем cable.

```ruby
# app/channels/application_cable/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  # Вызывается, когда потребитель успешно стал подписчиком этого канала
  def subscribed
  end
end
```

## Клиентские компоненты

### Соединения

Потребителям нужен экземпляр соединения на их стороне. Оно может быть установлено с использованием следующего Javascript, который генерируется в Rails по умолчанию:

#### (connect-consumer) Присоединение потребителя

```coffeescript
# app/assets/javascripts/cable.coffee
#= require action_cable

@App = {}
App.cable = ActionCable.createConsumer()
```

Это подготовит потребителя, который по умолчанию присоединится к /cable на вашем сервере. Соединение не будет установлено, пока вы не определите хотя бы одну подписку, в которой вы заинтересованы.

#### (Subscriber) Подписчик

Когда потребитель подписан на канал, он действует как подписчик. Потребитель может выступать в качестве подписчика на заданный канал любое количество раз. Например, подписчик может подписаться на несколько комнат чата одновременно.
(Помните, что физический пользователь может иметь несколько потребителей, один на закладку/устройство, открытых на ваше соединение).

Потребитель становится подписчиком создав подписку на заданный канал:

```coffeescript
# app/assets/javascripts/cable/subscriptions/chat.coffee
App.cable.subscriptions.create { channel: "ChatChannel", room: "Best Room" }

# app/assets/javascripts/cable/subscriptions/appearance.coffee
App.cable.subscriptions.create { channel: "AppearanceChannel" }
```

Хотя это создает подписку, функционал требует отклика на полученные данные, что будет описано позже.

## Клиент-серверное взаимодействие

### Потоки

Потоки предоставляют механизм, с помощью которого каналы направляют опубликованный контент (трансляции) своим подписчикам.

```ruby
# app/channels/application_cable/chat_channel.rb
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

Затем можно транслировать на этот канал с помощью: `CommentsChannel.broadcast_to(@post, @comment)`

### Трансляции

Трансляция — это ссылка pub/sub, по которой все, переданное издателем (publisher), направляется непосредственно подписчикам канала, которые читают из потока трансляции с этим именем. Каждый канал может писать в поток ноль или более трансляций. Трансляции — это очередь реального времени; Если потребитель не читает поток (не подписан на данный канал), он не получит трансляцию, когда присоединится позже.

Трансляции вызываются где угодно в приложении Rails:

```ruby
  WebNotificationsChannel.broadcast_to current_user, title: 'New things!', body: 'All the news fit to print'
```

Вызов `WebNotificationsChannel.broadcast_to` помещает сообщение в очередь pubsub текущего адаптера подписки (по умолчанию Redis) под отдельным именем трансляции для каждого пользователя. Для пользователя с ID 1, имя трансляции будет `web_notifications_1`.

Канал проинструктирован писать в поток все, что приходит в `web_notifications_1`, непосредственно на клиент, вызывая колбэк `#received(data)`.

### Подписки

Когда потребитель подписывается на канал, он действует как подписчик; Это соединение называется подпиской. Затем, входящие сообщения направляются на эти подписки на канал, основываясь на идентификаторе, посланным потребителем cable.

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

### Передача параметров в канал

Вы можете передавать параметры из клиента на сервер при создании подписки. Например:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

Передайте объект в качестве первого аргумента в `subscriptions.create`, и этот объект станет хэшем params в канале cable. Ключевое слово `channel` обязательное.

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
# Это вызывается где-нибудь в приложении, возможно из NewCommentJob
ChatChannel.broadcast_to "chat_#{room}", sent_by: 'Paul', body: 'This is a cool chat app.'
```

### Перетрансляция сообщения

Обычным сценарием является перетрансляция сообщения, посланного одним клиентом, любым другим подсоединенным клиентам.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end

  def receive(data)
    ChatChannel.broadcast_to "chat_#{params[:room]}", data
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

  1. [Настройка вашего соединения](#connection-setup)
  2. [Настройка родительского канала](#parent-channel-setup)
  3. [Присоединение вашего потребителя](#connect-consumer)

### Пример 1: Появление пользователя

Вот простой пример канала, отслеживающего является ли пользователь онлайн или нет, и на какой он странице. (Это полезно для создания особенностей присутствия, наподобие зеленой точки рядом с именем пользователя, если он онлайн).

#### Создание канала Appearance на сервере:

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
    current_user.appear on: data['appearing_on']
  end

  def away
    current_user.away
  end
end
```

Когда потребителем вызывается колбэк `#subscribed`, инициализируется клиентская подписка. В этом случае мы имеем возможность сказать "определенно, текущий пользователь появился онлайн". Это API появления/исчезновения может быть реализовано в Redis, базе данных или еще как-нибудь.

#### Создание подписки на канал Appearance на клиенте:

```coffeescript
# app/assets/javascripts/cable/subscriptions/appearance.coffee
App.cable.subscriptions.create "AppearanceChannel",
  # Вызывается, когда подписка готова на сервере для использования
  connected: ->
    @install()
    @appear()

  # Вызывается, когда закрывается соединения WebSocket
  disconnected: ->
    @uninstall()

  # Вызывается, когда подписка отвергается сервером
  rejected: ->
    @uninstall()

  appear: ->
    # Вызывает `AppearanceChannel#appear(data)` на сервере
    @perform("appear", appearing_on: $("main").data("appearing-on"))

  away: ->
    # Вызывает `AppearanceChannel#away` на сервере
    @perform("away")


  buttonSelector = "[data-behavior~=appear_away]"

  install: ->
    $(document).on "page:change.appearance", =>
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

1. **Клиент** устанавливает соединение с **Сервером** с помощью `App.cable = ActionCable.createConsumer("ws://cable.example.com")`. [*` cable.coffee`*] **Сервер** идентифицирует экземпляр этого соединения по `current_user`.
2. **Клиент** инициализирует подписку на `Appearance Channel` для своих соединений с помощью `App.cable.subscriptions.create "AppearanceChannel"`. [*`appearance.coffee`*]
3. **Сервер** распознав, что была инициализирована новая подписка для `AppearanceChannel`, выполняет колбэк `subscribed`, который вызывает метод `appear` на `current_user`. [*`appearance_channel.rb`*]
4. **Клиент** распознав, что подписка была установлена, вызывает `connected` [*`appearance.coffee`*], который, в свою очередь, вызывает `@install` и `@appear`. `@appear` вызывает `AppearanceChannel#appear(data)` на сервере и предоставляет хэш данных `appearing_on: $("main").data("appearing-on")`. Это возможно, так как экземпляр канала на сервере автоматически открывает публичные методы, объявленные в классе (за исключением колбэков), таким образом, они достижимы для вызова в качестве удаленных процедур с помощью метода подписки `perform`.
5. **Сервер** получает запрос для действия `appear` на канале `AppearanceChannel` для соединения, идентифицированного `current_user`. [*`appearance_channel.rb`*] Сервер получает данные с ключом `appearing_on` из хэша данных и устанавливает его в качестве значения для ключа `on:`, передаваемого в `current_user.appear`.

### Пример 2: Получение новых веб-уведомлений

Пример с появлением пользователей был об открытии серверного функционала для вызова на стороне клиента через соединение WebSocket. Но отличительная особенность WebSockets в том, что они двусторонние. Давайте покажем пример, когда сервер вызывает действие на клиенте.

Это канал веб-уведомлений, позволяющий показать веб-уведомления на клиенте при трансляции в правильные потоки:

#### Создание Web Notifications Channel на сервере:

```ruby
# app/channels/web_notifications_channel.rb
class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

#### Создание подписки Web Notifications Channel на клиенте:
```coffeescript
# app/assets/javascripts/cable/subscriptions/web_notifications.coffee
# На клиенте полагаем, что уже запросили право посылать веб-уведомления
App.cable.subscriptions.create "WebNotificationsChannel",
  received: (data) ->
    new Notification data["title"], body: data["body"]
```

#### Транслируем содержимое в экземпляр Web Notification Channel откуда-нибудь из приложения

```ruby
# Это вызывается где-то в приложении, возможно из NewCommentJob
  WebNotificationsChannel.broadcast_to current_user, title: 'New things!', body: 'All the news fit to print'
```

Вызов `WebNotificationsChannel.broadcast_to` помещает сообщение в очередь pubsub текущего адаптера подписки (по умолчанию Redis) помещает сообщение в очередь pubsub текущего адаптера подписки (по умолчанию Redis) под отдельным именем трансляции для каждого пользователя. Для пользователя с ID 1, имя трансляции будет `web_notifications_1`.

Канал проинструктирован писать в поток все, что приходит в `web_notifications_1`, непосредственно на клиент, вызывая колбэк `#received(data)`. Данные – это хэш, посылаемый в качестве второго параметра в вызов трансляции на сервере, кодируемый для передачи в JSON, и распакованный в аргументе data, приходящем в `#received`.

### Больше полных примеров complete examples

Посмотрите репозиторий [rails/actioncable-examples](http://github.com/rails/actioncable-examples), чтобы получить полный пример, как настроить Action Cable в приложении Rails и добавить каналы.

## Настройка

У Action Cable есть две требуемые настройки: адаптер подписки и допустимые домены запроса.

### Адаптер подписки

По умолчанию `ActionCable::Server::Base` ищет конфигурационный файл в `Rails.root.join('config/cable.yml')`. Этот файл должен указывать адаптер и URL для каждой среды Rails. Подробности об адаптерах смотрите в разделе "Зависимости".

```yaml
production: &production
  adapter: redis
  url: redis://10.10.3.153:6381
development: &development
  adapter: async
test: *development
```

Этот формат позволяет вам указать одну конфигурацию на среду Rails. Также возможно изменить расположение конфигурационного файла Action Cable в инициализаторе Rails с помощью чего-то вроде:

```ruby
Rails.application.paths.add "config/redis/cable", with: "somewhere/else/cable.yml"
```

### Допустимые домены запроса

Action Cable принимает только запросы с определенных доменов, которые передаются в конфигурацию сервера массивом. Домены могут быть экземплярами строк или регулярных выражений, с которыми выполняется сверка.

```ruby
Rails.application.config.action_cable.allowed_request_origins = ['http://rubyonrails.com', /http:\/\/ruby.*/]
```

Чтобы отключить и, тем самым, разрешить запросы с любого домена:

```ruby
Rails.application.config.action_cable.disable_request_forgery_protection = true
```

По умолчанию Action Cable позволяет все запросы из localhost:3000 при запуске в среде development.

### Настройка потребителя

Чтобы сконфигурировать URL, добавьте вызов `action_cable_meta_tag` в макете HTML HEAD. Он использует url или путь, обычно устанавливаемые с помощью `config.action_cable.url` в файлах настройки среды.

### Другие настройки

Другой обычной опцией для настройки являются теги логирования, присоединяемые к логгеру для каждого соединения. Вот как это используется в Basecamp:

```ruby
Rails.application.config.action_cable.log_tags = [
  -> request { request.env['bc.account_id'] || "no-account" },
  :action_cable,
  -> request { request.uuid }
]
```

Полный список всех конфигурационных опций смотрите в классе `ActionCable::Server::Configuration`.

Также отметим, что ваш сервер должен предоставить как минимум то же самое количество соединений с базой данных, сколько у вас есть воркеров. Пул воркеров по умолчанию установлен 100, это означает, что нужно сделать доступными соединения как минимум для них. Это можно изменить в `config/database.yml` с помощью атрибута `pool`.

## Запуск отдельного сервера cable

### В приложении

Action Cable может быть запущен вместе с вашим приложением Rails. Например, чтобы слушать запросы WebSocket на `/websocket`, смонтируйте сервер на этот путь:

```ruby
# config/routes.rb
Example::Application.routes.draw do
  mount ActionCable.server => '/cable'
end
```

Можно использовать `App.cable = ActionCable.createConsumer()`, чтобы соединить с сервером cable, если `action_cable_meta_tag` включен в макет. Произвольный путь указывается в качестве первого аргумента `createConsumer` (например, `App.cable = ActionCable.createConsumer("/websocket")`).

Для каждого экземпляра создаваемого сервера и для каждого воркера, порождаемого сервером, у вас также будет новый экземпляр ActionCable, но использование Redis позволяет синхронизировать сообщения между соединениями.

### Отдельное

Серверы cable могут быть отделены от обычного сервера приложений. Это все еще приложение Rack, но это отдельное приложение Rack. Рекомендуемая базовая настройка следующая:

```ruby
# cable/config.ru
require ::File.expand_path('../../config/environment', __FILE__)
Rails.application.eager_load!

run ActionCable.server
```

Затем можно запустить сервер с помощью binstub в bin/cable, наподобие:

```
#!/bin/bash
bundle exec puma -p 28080 cable/config.ru
```

Вышесказанное запустит сервер cable на порту 28080.

### Заметки

У сервера WebSocket нет доступа к сессии, но есть доступ к куки. Это можно использовать, если нужно обрабатывать аутентификацию. Один из способов с помощью Devise можно посмотреть в этой [статье](http://www.rubytutorial.io/actioncable-devise-authentication).

## Зависимости

Action Cable предоставляет интерфейс адаптера подписки для обработки его pubsub внутренностей. По умолчанию включены адаптеры асинхронный, встроенный, PostgreSQL, событийный Redis и не событийный Redis. В новых приложениях Rails по умолчанию асинхронный (`async`) адаптер.

Часть Ruby этих вещей создана на основе [websocket-driver](https://github.com/faye/websocket-driver-ruby),
[nio4r](https://github.com/celluloid/nio4r) и [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby).

## Развертывание

Action Cable работает на комбинации WebSockets и тредов. Работа обоих фреймворка и определенного для пользователя канала, внутренне обрабатываются с помощью поддержки нативных тредов Ruby. Это означает, что вы можете без проблем использовать все обычные модели Rails, до тех пор, пока они отвечают тредобезопасности.

Сервер Action Cable реализует API сокетов Rack, тем самым позволяет внутренне использовать мультитредовый паттерн для управления соединениями, независимо от того, является ли сервер приложения многопоточным.

В соответствии с этим, Action Cable работает со всеми популярными серверами приложений — Unicorn, Puma и Passenger.
