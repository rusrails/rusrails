Обзор Action Cable
==================

В этом руководстве вы изучите, как работает Action Cable, и как использовать WebSockets для внедрения функциональности реального времени в ваше приложение Rails.

После прочтения этого руководства, вы узнаете:

* Что такое Action Cable и об его интеграции на бэкенде и фронтенде
* Как настроить Action Cable
* Как настроить каналы
* О настройке развертывания и архитектуры для запуска Action Cable

--------------------------------------------------------------------------------

Что такое Action Cable?
-----------------------

Action Cable с легкостью интегрирует [WebSockets](https://ru.wikipedia.org/wiki/WebSocket) с остальными частями приложения Rails. Он позволяет писать функциональность реального времени на Ruby в стиле и формате остальной части приложения Rails, в то же время являясь производительным и масштабируемым. Он представляет полный стек, включая клиентский фреймворк на JavaScript и серверный фреймворк на Ruby. Вы получаете полный доступ к моделям предметной области, написанным с помощью Active Record или другой ORM на выбор.


Терминология
------------

Action Cable использует WebSockets вместо протокола запросов-откликов HTTP. И Action Cable, и WebSockets представляют более-менее одинаковую терминологию:

### Соединения

*Соединения* формируют основу взаимоотношения клиента с сервером.

Отдельный сервер Action Cable может обслужить несколько экземпляров соединения. В нем есть один экземпляр соединения на соединение WebSocket. Отдельный пользователь может иметь несколько WebSocket, открытых в вашем приложении, если он использует несколько вкладок браузера или устройств.

### Потребители

Клиент соединения WebSocket называется *потребителем*. В Action Cable потребитель создается клиентским фреймворком JavaScript.

### Каналы

Каждый потребитель, в свою очередь, может подписаться на несколько *каналов*. Каждый канал инкапсулирует логическую единицу работы, подобно тому, что делает контроллер в типичной настройке MVC. Например, могут быть `ChatChannel` и `AppearancesChannel`, а потребитель может подписаться на один или оба этих канала. Потребитель должен минимум быть подписан на один канал.

### Подписчики

Когда потребитель подписан на канал, он действует как *подписчик*. Соединение между подписчиком и каналом называется (сюрприз!) подпиской. Потребитель может действовать как подписчик на данный канал любое количество раз. Например, потребитель может подписаться на несколько комнат чата одновременно. (И помните, что физический пользователь может иметь несколько потребителей,
один на вкладку/устройство, открытых к соединению).

### Pub/Sub

[Pub/Sub](https://ru.wikipedia.org/wiki/Издатель-подписчик_(шаблон_проектирования)), или Publish-Subscribe, относится к парадигме очереди сообщений, когда отправители информации (publishers) посылают данные в абстрактный класс получателей (subscribers), без указания отдельных получателей. Action Cable использует этот подход для коммуникации между сервером и множеством клиентов.

### Трансляции

Трансляция — это ссылка pub/sub, по которой все, передаваемое транслятором, посылается непосредственно подписчикам на канал, которые слушают эту названную трансляцию. Каждый канал может вещать ноль или более трансляций.

## Серверные компоненты

### Соединения

Для каждого WebSocket, принимаемого сервером, на стороне сервера будет инициализирован объект соединения. Этот объект становится родителем для всех *подписок на канал*, которые создаются впоследствии. Само соединение не работает с какой-либо определенной логикой приложения после аутентификации и авторизации. Клиент соединения WebSocket называется *потребителем* соединения (consumer). Отдельный пользователь создаст одну пару потребитель-соединение на каждую вкладку браузера, окно или устройство, которые он использует.

Соединения - это экземпляры класса `ApplicationCable::Connection` который расширяет [`ActionCable::Connection::Base`][]. В `ApplicationCable::Connection` вы авторизуете входящее соединение и приступаете к его созданию, если пользователь может быть идентифицирован.

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

Здесь [`identified_by`][] назначает идентификатор соединения, который может быть использован, чтобы найти определенное соединение позже. Отметьте, что все, помеченное как идентификатор, автоматически создаст делегирование с тем же именем в каждом экземпляре канала, унаследованного от соединения.

Этот пример полагается на факт, что вы уже провели аутентификацию пользователя где-то в вашем приложении, и что успешная аутентификация устанавливает зашифрованные куки с ID пользователя.

Тогда куки автоматически посылаются в экземпляр соединения при попытке нового соединения, и используются для установления `current_user`. Идентифицировав соединения тем же текущим пользователем, вы также удостоверяетесь, что в дальнейшем можете получить все открытые соединения данного пользователя (и потенциально рассоединить их все, если пользователь удален или не авторизован).

Если ваш подход к аутентификации включает использование сессии, вы используете хранилище куки для для сессии, ваши куки сессии названы `_session`, и ключ ID пользователя `user_id`, можно использовать следующий подход:

```ruby
verified_user = User.find_by(id: cookies.encrypted['_session']['user_id'])
```

[`ActionCable::Connection::Base`]: https://api.rubyonrails.org/classes/ActionCable/Connection/Base.html
[`identified_by`]: https://api.rubyonrails.org/classes/ActionCable/Connection/Identification/ClassMethods.html#method-i-identified_by

#### Обработка исключений

По умолчанию необработанные исключения ловятся и логируются логгером Rails'. Если вы хотите глобально перехватывать эти исключения чтобы, например, затем отправить их в какой-нибудь сторонний баг-трекер, то вы можете это сделать используя [`rescue_from`][]:

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    rescue_from StandardError, with: :report_error

    private

    def report_error(e)
      SomeExternalBugtrackingService.notify(e)
    end
  end
end
```

[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from

### Каналы

*Канал* инкапсулирует логическую единицу работы, схожей с той, что делает контроллер в типичном MVC. По умолчанию Rails создает родительский класс `ApplicationCable::Channel` (который расширяет [`ActionCable::Channel::Base`][]) для инкапсуляции логики, общей для ваших каналов.

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
```

```ruby
# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
end
```

[`ActionCable::Channel::Base`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Base.html

Затем потребитель может быть подписан на один или оба этих канала.

#### Подписки

Потребитель подписывается на канал, действуя как *подписчик* (subscriber). Это соединение называется *подпиской*. Созданные сообщения затем маршрутизируются на эти подписки на канал, основываясь на идентификаторе, посланным потребителем канала.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  # Вызывается, когда потребитель успешно
  # стал подписчиком этого канала
  def subscribed
  end
end
```

#### Обработка исключений

Как и в случае с `ApplicationCable::Connection`, можно использовать [`rescue_from`][] на определенном канале для обработки вызванных исключений:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  rescue_from 'MyError', with: :deliver_error_message

  private

  def deliver_error_message(e)
    broadcast_to(...)
  end
end
```

## Клиентские компоненты

### Соединения

Потребителям нужен экземпляр соединения на их стороне. Оно может быть установлено с использованием следующего JavaScript, который генерируется в Rails по умолчанию:

#### (connect-consumer) Присоединение потребителя

```js
// app/javascript/channels/consumer.js
// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `bin/rails generate channel` command.

import { createConsumer } from "@rails/actioncable"

export default createConsumer()
```

Это подготовит потребителя, который по умолчанию присоединится к `/cable` на вашем сервере. Соединение не будет установлено, пока вы не определите хотя бы одну подписку, в которой вы заинтересованы.

Опционально, потребитель может принять аргумент, указывающий URL для соединения. Он может быть строкой или функцией, возвращающей строку, которая будет вызвана, когда откроется WebSocket.

```js
// Указан другой URL для соединения
createConsumer('https://ws.example.com/cable')

// Использована функция для динамической генерации URL
createConsumer(getWebSocketURL)

function getWebSocketURL() {
  const token = localStorage.get('auth-token')
  return `https://ws.example.com/cable?token=${token}`
}
```

#### (Subscriber) Подписчик

Потребитель становится подписчиком создав подписку на заданный канал:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" })

// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "AppearanceChannel" })
```

Хотя это создает подписку, функциональность требует отклика на полученные данные, что будет описано позже.

Потребитель может действовать как подписчик на заданный канал любое количество раз. Например, потребитель может подписаться на несколько комнат чата одновременно:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "1st Room" })
consumer.subscriptions.create({ channel: "ChatChannel", room: "2nd Room" })
```

## Клиент-серверное взаимодействие

### Потоки (Streams)

*Потоки* предоставляют механизм, с помощью которого каналы направляют опубликованный контент (трансляции) их подписчикам. Например, следующий код использует [`stream_from`][] для подписки на трансляцию с именем `chat_Best Room`, где значение параметра `:room` `"Best Room"`:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

Затем, где-нибудь в приложении Rails, можно транслировать в такую комнату, вызвав [`broadcast`][]:

```ruby
ActionCable.server.broadcast("chat_Best Room", { body: "This Room is Best Room." })
```

Если у вас есть поток, относящийся к модели, тогда используемое имя трансляции может быть сгенерировано из модели и канала. Например, следующий код использует [`stream_for`][] для подписки на трансляцию наподобие `comments:Z2lkOi8vVGVzdEFwcC9Qb3N0LzE`, где `Z2lkOi8vVGVzdEFwcC9Qb3N0LzE` это GlobalID модели Post.

```ruby
class CommentsChannel < ApplicationCable::Channel
  def subscribed
    post = Post.find(params[:id])
    stream_for post
  end
end
```

Затем можно транслировать на этот канал с помощью [`broadcast_to`][]:

```ruby
CommentsChannel.broadcast_to(@post, @comment)
```

[`broadcast`]: https://api.rubyonrails.org/classes/ActionCable/Server/Broadcasting.html#method-i-broadcast
[`broadcast_to`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Broadcasting/ClassMethods.html#method-i-broadcast_to
[`stream_for`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Streams.html#method-i-stream_for
[`stream_from`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Streams.html#method-i-stream_from

### (broadcasting) Трансляции

*Трансляция* — это ссылка pub/sub, по которой все, переданное издателем (publisher), направляется непосредственно подписчикам канала, которые читают из потока трансляции с этим именем. Каждый канал может писать в поток ноль или более трансляций. Трансляции — это очередь реального времени. Если потребитель не читает поток (не подписан на данный канал), он не получит трансляцию, когда присоединится позже.

### Подписки

Когда потребитель подписывается на канал, он действует как подписчик. Это соединение называется подпиской. Затем, входящие сообщения направляются на эти подписки на канал, основываясь на идентификаторе, посланным потребителем cable.

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("[data-chat-room='Best Room']")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article class="chat-line">
        <span class="speaker">${data["sent_by"]}</span>
        <span class="body">${data["body"]}</span>
      </article>
    `
  }
})
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

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("[data-chat-room='Best Room']")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article class="chat-line">
        <span class="speaker">${data["sent_by"]}</span>
        <span class="body">${data["body"]}</span>
      </article>
    `
  }
})
```

```ruby
# Это вызывается где-нибудь в приложении,
# возможно из NewCommentJob
ActionCable.server.broadcast(
  "chat_#{room}",
  {
    sent_by: 'Paul',
    body: 'This is a cool chat app.'
  }
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

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

const chatChannel = consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    // data => { sent_by: "Paul", body: "This is a cool chat app." }
  }
})

chatChannel.send({ sent_by: "Paul", body: "This is a cool chat app." })
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

```js
// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create("AppearanceChannel", {
  // Вызывается единожды при создании подписки.
  initialized() {
    this.update = this.update.bind(this)
  },

  // Вызывается, когда подписка готова на сервере для использования.
  connected() {
    this.install()
    this.update()
  },

  // Вызывается, когда закрывается соединения WebSocket.
  disconnected() {
    this.uninstall()
  },

  // Вызывается, когда подписка отвергается сервером.
  rejected() {
    this.uninstall()
  },

  update() {
    this.documentIsActive ? this.appear() : this.away()
  },

  appear() {
    // Вызывает `AppearanceChannel#appear(data)` на сервере.
    this.perform("appear", { appearing_on: this.appearingOn })
  },

  away() {
    // Вызывает `AppearanceChannel#away` на сервере.
    this.perform("away")
  },

  install() {
    window.addEventListener("focus", this.update)
    window.addEventListener("blur", this.update)
    document.addEventListener("turbolinks:load", this.update)
    document.addEventListener("visibilitychange", this.update)
  },

  uninstall() {
    window.removeEventListener("focus", this.update)
    window.removeEventListener("blur", this.update)
    document.removeEventListener("turbolinks:load", this.update)
    document.removeEventListener("visibilitychange", this.update)
  },

  get documentIsActive() {
    return document.visibilityState === "visible" && document.hasFocus()
  },

  get appearingOn() {
    const element = document.querySelector("[data-appearing-on]")
    return element ? element.getAttribute("data-appearing-on") : null
  }
})
```

#### Клиент-серверное взаимодействие

1. **Клиент** соединяется с **Сервером** с помощью `App.cable = ActionCable.createConsumer("ws://cable.example.com")`. (`cable.js`). **Сервер** идентифицирует экземпляр этого соединения по `current_user`.

2. **Клиент** подписывается на канал появлений с помощью `consumer.subscriptions.create({ channel: "AppearanceChannel" })`. (`appearance_channel.js`)

3. **Сервер** распознает, что была инициализирована новая подписка для канала появлений, и запускает колбэк `subscribed`, вызывающий метод `appear` на `current_user`. (`appearance_channel.rb`)

4. **Клиент** распознав, что подписка была установлена, вызывает `connected` (`appearance_channel.js`), который, в свою очередь, вызывает `install` и `appear`. `appear` вызывает `AppearanceChannel#appear(data)` на сервере и предоставляет хэш данных `{ appearing_on: this.appearingOn }`. Это возможно, так как экземпляр канала на сервере автоматически открывает публичные методы, объявленные в классе (кроме колбэков), таким образом, они достижимы для вызова в качестве удаленных процедур с помощью метода подписки `perform`.

5. **Сервер** получает запрос для экшна `appear` на канале появлений для соединения, идентифицированного `current_user`. (`appearance_channel.rb`). **Сервер** получает данные с ключом `:appearing_on` из хэша данных и устанавливает его в качестве значения для ключа `:on`, передаваемого в `current_user.appear`.

### Пример 2: Получение новых веб-уведомлений

Пример с появлением пользователей был об открытии серверного функциональности для вызова на стороне клиента через соединение WebSocket. Но отличительная особенность WebSockets в том, что они двусторонние. Давайте покажем пример, когда сервер вызывает экшн на клиенте.

Это канал веб-уведомлений, позволяющий показать веб-уведомления на клиенте при трансляции в релевантные потоки:

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

```js
// app/javascript/channels/web_notifications_channel.js
// На клиенте полагаем, что уже запросили право
// посылать веб-уведомления
import consumer from "./consumer"

consumer.subscriptions.create("WebNotificationsChannel", {
  received(data) {
    new Notification(data["title"], { body: data["body"] })
  }
})
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

## (configuration) Настройка

У Action Cable есть две требуемые настройки: адаптер подписки и допустимые домены запроса.

### Адаптер подписки

По умолчанию Action Cable ищет конфигурационный файл в `config/cable.yml`. Этот файл должен указывать адаптер для каждой среды Rails. Подробности об адаптерах смотрите в разделе [Зависимости](#dependencies).

```yaml
development:
  adapter: async

test:
  adapter: test

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

Адаптер Redis требует от пользователей предоставления URL, указывающего на сервер Redis. Кроме того, может быть предоставлен `channel_prefix`, чтобы избежать конфликта имен каналов при использовании одного и того же сервера Redis для нескольких приложений. Смотрите [документацию Redis Pub/Sub](https://redis.io/docs/manual/pubsub/#database--scoping) для получения дополнительной информации.

Адаптер Redis также поддерживает соединения SSL/TLS. Требуемые параметры SSL/TLS могут быть переданы в ключ `ssl_params` в конфигурационном файле YAML.

```
production:
  adapter: redis
  url: rediss://10.10.3.153:tls_port
  channel_prefix: appname_production
  ssl_params: {
    ca_file: "/path/to/ca.crt"
  }
```

Опции, переданные в `ssl_params`, передаются непосредственно в метод `OpenSSL::SSL::SSLContext#set_params`, и они могут быть любыми валидными атрибутами контекста SSL. Обратитесь к [документации OpenSSL::SSL::SSLContext](https://docs.ruby-lang.org/en/master/OpenSSL/SSL/SSLContext.html) за другими доступными атрибутами.

Если вы используете самоподписанные сертификаты для адаптера redis за файрволом и пропускаете проверку сертификата, тогда в ssl `verify_mode` должен быть установлен как `OpenSSL::SSL::VERIFY_NONE`.

WARNING: Не рекомендуется использовать `VERIFY_NONE` в production, если вы только не абсолютно понимаете влияние на безопасность. Чтобы установить эту опцию для адаптера Redis, настройка должна быть `ssl_params: { verify_mode: <%= OpenSSL::SSL::VERIFY_NONE %> }`.

##### Адаптер PostgreSQL

Адаптер PostgreSQL использует пул подключений Active Record и, соответственно, конфигурацию базы данных приложения `config/database.yml` для ее подключения. Это может измениться в будущем. [#27214](https://github.com/rails/rails/issues/27214)

### Допустимые домены запроса

Action Cable принимает только запросы с определенных доменов, которые передаются в конфигурацию сервера массивом. Домены могут быть экземплярами строк или регулярных выражений, с которыми выполняется сверка.

```ruby
config.action_cable.allowed_request_origins = ['https://rubyonrails.com', %r{http://ruby.*}]
```

Чтобы отключить и, тем самым, разрешить запросы с любого домена:

```ruby
config.action_cable.disable_request_forgery_protection = true
```

По умолчанию Action Cable позволяет все запросы из localhost:3000 при запуске в среде development.

### Настройка потребителя

Чтобы сконфигурировать URL, добавьте вызов [`action_cable_meta_tag`][] в макете HTML HEAD. Он использует URL или путь, обычно устанавливаемые с помощью [`config.action_cable.url`][] в файлах настройки среды.

[`config.action_cable.url`]: /configuring#config-action-cable-url
[`action_cable_meta_tag`]: https://api.rubyonrails.org/classes/ActionCable/Helpers/ActionCableHelper.html#method-i-action_cable_meta_tag

### Настройка пула воркеров

Пул воркеров используется для запуска колбэков соединения и экшнов канала в изоляции от основного треда сервера. Action Cable позволяет приложению настроить количество одновременно обрабатываемых тредов в пуле воркеров.

```ruby
config.action_cable.worker_pool_size = 4
```

Также отметим, что ваш сервер должен предоставить как минимум то же самое количество соединений с базой данных, сколько у вас есть воркеров. Пул воркеров по умолчанию установлен 4, это означает, что нужно сделать как минимум 4 доступных соединения к базе данных. Это можно изменить в `config/database.yml` с помощью атрибута `pool`.

### Логирование на клиенте

Логирование на клиенте отключено по умолчанию. Его можно включить, установив `ActionCable.logger.enabled` true.

```ruby
import * as ActionCable from '@rails/actioncable'

ActionCable.logger.enabled = true
```

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

## Запуск отдельного сервера cable

### В приложении

Action Cable может быть запущен вместе с вашим приложением Rails. Например, чтобы слушать запросы WebSocket на `/websocket`, укажите этот путь в [`config.action_cable.mount_path`][]:

```ruby
# config/application.rb
class Application < Rails::Application
  config.action_cable.mount_path = '/websocket'
end
```

Можно использовать `ActionCable.createConsumer()`, чтобы соединить с сервером cable, если `action_cable_meta_tag` вызван в макете. В противном случае, путь указывается в качестве первого аргумента `createConsumer` (например, `ActionCable.createConsumer("/websocket")`).

Для каждого экземпляра создаваемого сервера и для каждого воркера, порождаемого сервером, у вас также будет новый экземпляр Action Cable, но использование адаптеров Redis или PostgreSQL позволяет синхронизировать сообщения между соединениями.

[`config.action_cable.mount_path`]: /configuring#config-action-cable-mount-path

### Отдельное

Серверы cable могут быть отделены от обычного сервера приложений. Это все еще приложение Rack, но это отдельное приложение Rack. Рекомендуемая базовая настройка следующая:

```ruby
# cable/config.ru
require_relative "../config/environment"
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

У сервера WebSocket нет доступа к сессии, но есть доступ к куки. Это можно использовать, если нужно обрабатывать аутентификацию. Один из способов с помощью Devise можно посмотреть в этой [статье](https://greg.molnar.io/blog/actioncable-devise-authentication/).

## (dependencies) Зависимости

Action Cable предоставляет интерфейс адаптера подписки для обработки его pubsub внутренностей. По умолчанию включены адаптеры асинхронный, встроенный, PostgreSQL, и адаптеры Redis. В новых приложениях Rails по умолчанию используется асинхронный (`async`) адаптер.

Часть Ruby этих вещей создана на основе [websocket-driver](https://github.com/faye/websocket-driver-ruby),
[nio4r](https://github.com/celluloid/nio4r) и [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby).

## Развертывание

Action Cable работает на комбинации WebSockets и тредов. Работа обоих фреймворка и определенного для пользователя канала, внутренне обрабатываются с помощью поддержки нативных тредов Ruby. Это означает, что вы можете без проблем использовать все существующие модели Rails, до тех пор, пока они отвечают тредобезопасности.

Сервер Action Cable реализует Rack API угона сокетов (socket hijacking), тем самым позволяет внутренне использовать многотредовый паттерн для управления соединениями, независимо от того, является ли сервер приложения многотредовым.

В соответствии с этим, Action Cable работает с популярными серверами, такими как Unicorn, Puma и Passenger.

## Тестирование

Детальные инструкции по тестированию функционала Action Cable можно найти в [руководстве по тестированию](/testing#testing-action-cable).
