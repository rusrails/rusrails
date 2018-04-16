Основы Action Mailer
====================

Это руководство представит вам все, что нужно для того, чтобы посылать и получать электронную почту в вашем приложении, и раскроет множество внутренних методов Action Mailer. Оно также раскроет, как тестировать ваши рассыльщики.

После прочтения этого руководства, вы узнаете:

* Как отправлять и получать письма в приложении Rails.
* Как генерировать и редактировать класс Action Mailer и вьюху рассыльщика.
* Как настраивать Action Mailer для своей среды.
* Как тестировать свои классы Action Mailer.

Action Mailer позволяет отправлять электронные письма из приложения, используя классы и вьюхи рассыльщика.

#### Рассыльщики похожи на контроллеры

Они наследуются от `ActionMailer::Base`, и находятся в `app/mailers`. Рассыльщики также работают подобно контроллерами. Некоторые общие черты перечислены ниже. У рассыльщиков есть:

* Экшны, а также связанные вьюхи, которые располагаются в `app/views`.
* Переменные экземпляра, доступные во вьюхах.
* Возможность использовать макеты и партиалы.
* Возможность доступа к хэшу params.

Отправка электронной почты
--------------------------

Этот раздел предоставляет пошаговое руководство по созданию рассыльщика и его вьюх.

### Пошаговое руководство по генерации рассыльщика

#### Создаем рассыльщик

```bash
$ bin/rails generate mailer UserMailer
create  app/mailers/user_mailer.rb
create  app/mailers/application_mailer.rb
invoke  erb
create    app/views/user_mailer
create    app/views/layouts/mailer.text.erb
create    app/views/layouts/mailer.html.erb
invoke  test_unit
create    test/mailers/user_mailer_test.rb
create    test/mailers/previews/user_mailer_preview.rb
```

```ruby
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout 'mailer'
end

# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
end
```

Как видите, можно генерировать рассыльщик одним из генератором Rails.

Если не хотите использовать генератор, можно создать свой файл в `app/mailers`, просто убедитесь, что он унаследован от `ActionMailer::Base`:

```ruby
class MyMailer < ActionMailer::Base
end
```

#### Редактируем рассыльщик

У рассыльщиков есть методы, называемые "экшнами", и они используют вьюхи для структурирования своего контента. В то время, когда контроллер генерирует контент, например HTML, для возврата его на клиент, рассыльщик создает сообщение для доставки по электронной почте.

`app/mailers/user_mailer.rb` содержит пустой рассыльщик:

```ruby
class UserMailer < ApplicationMailer
end
```

Давайте добавим метод, названный `welcome_email`, который будет посылать email на зарегистрированный адрес email пользователя:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

end
```

Вот краткое описание элементов, представленных в этом методе. Для полного списка всех доступных опций, обратитесь к [соответствующему разделу](#complete-list-of-action-mailer-user-settable-attributes).

* Хэш `default` - это хэш значений по умолчанию для любых рассылаемых вами email из этого рассыльщика. В этом случае мы присваиваем заголовку `:from` значение для всех сообщений в этом классе. Это может быть переопределено для отдельного письма.
* `mail` - фактическое сообщение email, куда мы передаем заголовки `:to` и `:subject`.

#### Создаем вьюху рассыльщика

Создадим файл, названный `welcome_email.html.erb` в `app/views/user_mailer/`. Это будет шаблоном, используемым для email, форматированным в HTML:

```html+erb
<!DOCTYPE html>
<html>
  <head>
    <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
  </head>
  <body>
    <h1>Welcome to example.com, <%= @user.name %></h1>
    <p>
      You have successfully signed up to example.com,
      your username is: <%= @user.login %>.<br>
    </p>
    <p>
      To login to the site, just follow this link: <%= @url %>.
    </p>
    <p>Thanks for joining and have a great day!</p>
  </body>
</html>
```

Давайте также создадим текстовую часть для этого email. Не все клиенты предпочитают письма HTML, и рассылка обоих является лучшей практикой. Для этого создайте файл с именем `welcome_email.text.erb` в `app/views/user_mailer/`.

```erb
Welcome to example.com, <%= @user.name %>
===============================================

You have successfully signed up to example.com,
your username is: <%= @user.login %>.

To login to the site, just follow this link: <%= @url %>.

Thanks for joining and have a great day!
```

Теперь при вызове метода `mail`, Action Mailer обнаружит два шаблона (text и HTML) и автоматически сгенерирует `multipart/alternative` email.

#### Вызов рассыльщика

Рассыльщики - это всего лишь другой способ отрендерить вьюху. Вместо рендеринга вьюхи и отсылки ее по протоколу HTTP, они всего лишь вместо этого отправляют ее по протоколам email. Благодаря этому имеет смысл, чтобы контроллер сказал рассыльщику отослать письмо тогда, когда пользователь был успешно создан.

Настройка этого до безобразия проста.

Во первых, давайте создадим простой скаффолд `User`:

```bash
$ bin/rails generate scaffold user name email login
$ bin/rails db:migrate
```

Теперь, когда у нас есть модель user, с которой мы играем, надо всего лишь отредактировать `app/controllers/users_controller.rb`, чтобы поручить `UserMailer` доставлять email каждому вновь созданному пользователю, изменив экшн `create` и вставив вызов `UserMailer.with(user: @user).welcome_email` сразу после того, как пользователь был успешно сохранен.

Action Mailer прекрасно интегрирован с Active Job, поэтому можно отправлять электронную почту вне цикла запрос-отклик, таким образом что пользователю не нужно ждать выполнения отправки:

```ruby
class UsersController < ApplicationController
  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        # Сказать UserMailer отослать приветственное письмо после сохранения
        UserMailer.with(user: @user).welcome_email.deliver_later

        format.html { redirect_to(@user, notice: 'User was successfully created.') }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
end
```

NOTE: Поведением Active Job по умолчанию является выполнение заданий с помощью адаптера `:async`. Поэтому можно использовать `deliver_later` для отсылки писем прямо сейчас асинхронно. Адаптер Active Job по умолчанию запускает задания с помощью пула тредов внутри процесса. Это хорошо подходит для сред development/test, так как не требует какой-либо внешней инфраструктуры, но плохо подходит для production, так как он теряет отложенные задания при перезагрузке. Если нужен персистентный бэкенд, необходимо использовать адаптер Active Job, у которого такой бэкенд есть (Sidekiq, Resque и т.п.).

Если хотите отправлять письма прямо сейчас в любом случае (например, из крона) просто вызовите `deliver_now`:

```ruby
class SendWeeklySummary
  def run
    User.find_each do |user|
      UserMailer.with(user: user).weekly_summary.deliver_now
    end
  end
end
```

Любая пара ключ/значение, переданная в `with`, просто становится `params` для экшна рассыльщика. Поэтому `with(user: @user, account: @user.account)` делает `params[:user]` и `params[:account]` доступными в экшне рассыльщика. Это такой же params, который есть в контроллерах.

Метод `welcome_email` возвращает объект `ActionMailer::MessageDelivery`, которому затем можно сказать `deliver_now` или `deliver_later`, чтобы он сам себя отослал. Объект `ActionMailer::MessageDelivery` — это всего лишь обертка для `Mail::Message`. Если хотите исследовать, изменить или еще что-то сделать с объектом `Mail::Message`, к нему можно получить доступ с помощью метода `message` на объекте `ActionMailer::MessageDelivery`.

### Автоматическое кодирование значений заголовка

Action Mailer осуществляет автоматическое кодирование многобайтовых символов в заголовках и телах.

Для более сложных примеров, таких, как определение альтернативных кодировок или самокодировок текста, обратитесь к библиотеке [Mail](https://github.com/mikel/mail).

### (complete-list-of-action-mailer-user-settable-attributes) Полный перечень методов Action Mailer

Имеется всего три метода, необходимых для рассылки почти любых сообщений email:

* `headers` - Определяет любой заголовок email. Можно передать хэш пар имен и значений полей заголовка, или можно вызвать `headers[:field_name] = 'value'`
* `attachments` - Позволяет добавить прикрепленные файлы в email. Например, `attachments['file-name.jpg'] = File.read('file-name.jpg')`
* `mail` - Фактически отсылает сам email. Можете передать в `headers` хэш к методу `mail` как параметр, `mail` затем создаст email, или чистый текст, или multipart, в зависимости от определенных вами шаблонов email.

#### Добавление прикрепленных файлов

В Action Mailer очень просто добавить прикрепленные файлы.

* Передайте имя файла и содержимое, и Action Mailer и [гем Mail](https://github.com/mikel/mail) автоматически определят mime_type, установят кодировку и создадут прикрепленные файлы.

    ```ruby
    attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    ```

  Когда будет вызван метод `mail`, он отправит multipart email с прикрепленным файлом, должным образом вложенным в верхний уровень, являющийся `multipart/mixed`, и первая часть будет `multipart/alternative`, содержащая чистый текст и сообщения HTML.

NOTE: Mail автоматически кодирует прикрепленный файл в Base64. Если хотите что-то иное, закодируйте свое содержимое и передайте в кодированном содержимом, и укажите кодировку в хэше в методе `attachments`.

* Передайте имя файла и определите заголовки и содержимое, и Action Mailer и Mail будут использовать переданные вами настройки.

    ```ruby
    encoded_content = SpecialEncode(File.read('/path/to/filename.jpg'))
    attachments['filename.jpg'] = {
      mime_type: 'application/gzip',
      encoding: 'SpecialEncoding',
      content: encoded_content
    }
    ```

NOTE: Если указать кодировку, Mail будет полагать, что ваше содержимое уже кодировано в ней и не попытается кодировать в Base64.

#### Создание встроенных прикрепленных файлов

Action Mailer 3.0 создает встроенные прикрепленные файлы, которые вовлекали множество хаков в версиях до 3.0, более просто и обычно, так, как и должно было быть.

* Сперва, чтобы сказать Mail превратить прикрепленные файлы во встроенные прикрепленные файлы, надо всего лишь вызвать `#inline` на методе attachments в рассыльщике:

    ```ruby
    def welcome
      attachments.inline['image.jpg'] = File.read('/path/to/image.jpg')
    end
    ```

* Затем, во вьюхе можно просто сослаться на `attachments` как хэш и определить, какой прикрепленный файл необходимо отобразить, вызвав `url` на нем, и затем передать результат в метод `image_tag`:

    ```html+erb
    <p>Hello there, this is our image</p>

    <%= image_tag attachments['image.jpg'].url %>
    ```

* Так как это стандартный вызов `image_tag`, можно передать хэш опций после URL прикрепленного файла, как это делается для любого другого изображения:

    ```html+erb
    <p>Hello there, this is our image</p>

    <%= image_tag attachments['image.jpg'].url, alt: 'My Photo', class: 'photos' %>
    ```

#### Рассылка Email нескольким получателям

Возможно отослать email одному и более получателям в одном письме (например, информируя всех админов о новой регистрации пользователя), настроив список адресов email в ключе `:to`. Перечень email может быть массивом или отдельной строкой с адресами, разделенными запятыми.

```ruby
class AdminMailer < ApplicationMailer
  default to: -> { Admin.pluck(:email) },
          from: 'notification@example.com'

  def new_registration(user)
    @user = user
    mail(subject: "New User Signup: #{@user.email}")
  end
end
```

Тот же формат может быть использован для назначения получателей копии (Cc:) и скрытой копии (Bcc:), при использовании ключей `:cc` и `:bcc` соответственно.

#### Рассылка Email с именем

Иногда хочется показать имена людей вместо их электронных адресов, при получении ими email. Фокус в том, что формат адреса email следующий `"Full Name" <email>`.

```ruby
def welcome_email
  @user = params[:user]
  email_with_name = %("#{@user.name}" <#{@user.email}>)
  mail(to: email_with_name, subject: 'Welcome to My Awesome Site')
end
```

### Вьюхи рассыльщика

Вьюхи рассыльщика расположены в директории `app/views/name_of_mailer_class`. Определенная вьюха рассыльщика известна классу, поскольку у нее имя такое же, как у метода рассыльщика. Так, в нашем примере, вьюха рассыльщика для метода `welcome_email` будет в `app/views/user_mailer/welcome_email.html.erb` для версии HTML и `welcome_email.text.erb` для обычной текстовой версии.

Чтобы изменить вьюху рассыльщика по умолчанию для вашего экшна, сделайте так:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'Welcome to My Awesome Site',
         template_path: 'notifications',
         template_name: 'another')
  end
end
```

В этом случае он будет искать шаблон в `app/views/notifications` с именем `another`. Также можно определить массив путей для `template_path`, и они будут искаться в указанном порядке.

Если желаете большей гибкости, также возможно передать блок и рендерить определенный шаблон или даже рендерить вложенный код или текст без использования файла шаблона:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'Welcome to My Awesome Site') do |format|
      format.html { render 'another_template' }
      format.text { render plain: 'Render text' }
    end
  end

end
```

Это отрендерит шаблон 'another_template.html.erb' для HTML части и использует 'Render text' для текстовой части. Команда `render` та же самая, что используется в Action Controller, поэтому можете использовать те же опции, такие как `:text`, `:inline` и т.д.

#### Кэширование вьюх рассыльщика

Во вьюхах рассыльщика можно выполнять кэширование фрагментов так же, как и во вьюхах приложения, с помощью метода `cache`.

```
<% cache do %>
  <%= @company.name %>
<% end %>
```

И чтобы использовать эту особенность, необходимо настроить приложение следующим образом:

```
  config.action_mailer.perform_caching = true
```

Кэширование фрагментов также поддерживается в multipart письмах.
Подробнее читайте в руководстве [Кэширование с Rails: Обзор](/caching-with-rails-an-overview).

### Макеты Action Mailer

Как и во вьюхах контроллера, можно также иметь макеты рассыльщика. Имя макета должно быть таким же, как у вашего рассыльщика, таким как `user_mailer.html.erb` и `user_mailer.text.erb`, чтобы автоматически распознаваться вашим рассыльщиком как макет.

Чтобы задействовать другой файл, вызовите `layout` в своем рассыльщике:

```ruby
class UserMailer < ApplicationMailer
  layout 'awesome' # использовать awesome.(html|text).erb как макет
end
```

Подобно вьюхам контроллера, используйте `yield` для рендеринга вьюхи внутри макета.

Также можно передать опцию `layout: 'layout_name'` в вызов render в формате блока, чтобы определить различные макеты для различных форматов:

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email) do |format|
      format.html { render layout: 'my_layout' }
      format.text
    end
  end
end
```

Отрендерит часть в HTML, используя файл `my_layout.html.erb`, и текстовую часть с обычным файлом `user_mailer.text.erb`, если он существует.

### Предпросмотр писем

Предпросмотр Action Mailer предоставляет способ увидеть, как выглядят письма, посетив специальный URL, который отображает их. В приведенном выше примере, класс предпросмотра для `UserMailer` должен называться `UserMailerPreview` и находится в `test/mailers/previews/user_mailer_preview`. Чтобы увидеть предпросмотр `welcome_email`, реализуйте метод с таким же именем и вызовом `UserMailer.welcome_email`:

```ruby
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end
end
```

Тогда предпросмотр будет доступно по адресу <http://localhost:3000/rails/mailers/user_mailer/welcome_email>.

Если вы поменяете что-то в `app/views/user_mailer/welcome_email.html.erb` или в самом рассыльщике, это автоматически перезагрузится и отрендерится, таким образом, вы можете увидеть новые стили мгновенно. Список для предпросмотра также доступен по адресу <http://localhost:3000/rails/mailers>.

По умолчанию, классы предпросмотра находятся в `test/mailers/previews`.
Это может быть изменено, используя опцию `preview_path`. Например, если вы хотите изменить это на `lib/mailer_previews`, вы можете указать в `config/application.rb`:

```ruby
config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"
```

### Генерируем URL во вьюхах Action Mailer

В отличие от контроллеров, экземпляр рассыльщика не может использовать какой-либо контекст относительно входящего запроса, поэтому необходимо предоставить параметр `:host` самостоятельно.

Так как `:host` обычно одинаковый для всего приложения, его можно настроить глобально в `config/application.rb`:

```ruby
config.action_mailer.default_url_options = { host: 'example.com' }
```

В связи с таким поведением в письме нельзя использовать любые хелперы `*_path`. Вместо них можно использовать связанные хелперы `*_url`. Например, вместо использования

```
<%= link_to 'welcome', welcome_path %>
```

Нужно использовать:

```
<%= link_to 'welcome', welcome_url %>
```

При использовании полного URL ваши ссылки в письмах будут работать.


#### Генерация URL с помощью `url_for`

`url_for` генерирует полный URL по умолчанию в шаблонах.

Если вы не настроили опцию `:host` глобально, убедитесь, что передали ее в `url_for`.

```erb
<%= url_for(host: 'example.com',
            controller: 'welcome',
            action: 'greeting') %>
```

#### Генерация URL с помощью именованных маршрутов

У клиентов email отсутствует веб-контекст, таким образом у путей нет базового URL для формирования полного веб-адреса. Поэтому следует всегда использовать только вариант "_url" именованных маршрутных хелперов.

Если вы не настроили опцию `:host` глобально, убедитесь, что передали ее в маршрутный хелпер.

```erb
<%= user_url(@user, host: 'example.com') %>
```

NOTE: не `GET` ссылки требуют [rails-ujs](https://github.com/rails/rails/blob/master/actionview/app/assets/javascripts) или [jQuery UJS](https://github.com/rails/jquery-ujs)
и не будут работать в шаблонах рассыльщика. Они будут заменятся на простые `GET` запросы.

### Добавление картинок во вьюхах Action Mailer

В отличие от контроллеров, экземпляр рассыльщика не может использовать какой-либо контекст относительно входящего запроса, поэтому необходимо предоставить параметр `:asset_host` самостоятельно.

Так как `:asset_host` обычно одинаковый для всего приложения, его можно настроить глобально в `config/application.rb`:

```ruby
config.action_mailer.asset_host = 'http://example.com'
```

Теперь вы можете отображать картинки внутри вашего письма.

```ruby
<%= image_tag 'image.jpg' %>
```

### Рассылка multipart email

Action Mailer автоматически посылает multipart email, если имеются разные шаблоны для одного и того же экшна. Таким образом, для нашего примера `UserMailer`, если есть `welcome_email.text.erb` и `welcome_email.html.erb` в `app/views/user_mailer`, то Action Mailer автоматически пошлет multipart email с версиями HTML и текстовой, настроенными как разные части.

Порядок, в котором части будут вставлены, определяется `:parts_order` в методе `ActionMailer::Base.default`.

### Рассылка писем с динамическими опциями доставки

Если хотите переопределить опции доставки по умолчанию (т.е. учетные данные SMTP) во время доставки писем, можно использовать `delivery_method_options` в экшне рассыльщика.

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    @url  = user_url(@user)
    delivery_options = { user_name: params[:company].smtp_user,
                         password: params[:company].smtp_password,
                         address: params[:company].smtp_host }
    mail(to: @user.email,
         subject: "Please see the Terms and Conditions attached",
         delivery_method_options: delivery_options)
  end
end
```

### Рассылка писем без рендеринга шаблона

Бывают ситуации, когда вы хотите пропустить шаг рендеринга шаблона и предоставить тело письма, как строку. Это достигается с использованием опции `:body`. В таком случае, не забудьте добавить опцию `:content_type`. Иначе Rails использует по умолчанию `text/plain`.

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email,
         body: params[:email_body],
         content_type: "text/html",
         subject: "Already rendered!")
  end
end
```

Получение электронной почты
---------------------------

Получение и парсинг электронной почты с помощью Action Mailer может быть довольно сложным делом. До того, как электронная почта достигнет ваше приложение на Rails, нужно настроить вашу систему, чтобы каким-то образом направлять почту в приложение, которому нужно быть следящим за ней. Таким образом, чтобы получать электронную почту в приложении на Rails, нужно:

* Реализовать метод `receive` в вашем рассыльщике.

* Настроить ваш почтовый сервер для направления почты от адресов, желаемых к получению вашим приложением, в `/path/to/app/bin/rails runner 'UserMailer.receive(STDIN.read)'`.

Как только метод, названный `receive`, определяется в каком-либо рассыльщике, Action Mailer будет парсить сырую входящую почту в объект email, декодировать его, создавать экземпляр нового рассыльщика и передавать объект email в метод экземпляра рассыльщика `receive`. Вот пример:

```ruby
class UserMailer < ApplicationMailer
  def receive(email)
    page = Page.find_by(address: email.to.first)
    page.emails.create(
      subject: email.subject,
      body: email.body
    )

    if email.has_attachments?
      email.attachments.each do |attachment|
        page.attachments.create({
          file: attachment,
          description: email.subject
        })
      end
    end
  end
end
```

Колбэки Action Mailer
---------------------

Action Mailer позволяет определить `before_action`, `after_action` и `around_action`.

* Фильтры могут быть определены в блоке или символом с именем метода рассыльщика, подобно контроллерам.

* `before_action` можно использовать для заполнения объекта mail значениями по умолчанию, `delivery_method_options` или вставки дефолтных заголовков и прикрепленных файлов.

```ruby
class InvitationsMailer < ApplicationMailer
  before_action { @inviter, @invitee = params[:inviter], params[:invitee] }
  before_action { @account = params[:inviter].account }

  default to:       -> { @invitee.email_address },
          from:     -> { common_address(@inviter) },
          reply_to: -> { @inviter.email_address_with_name }

  def account_invitation
    mail subject: "#{@inviter.name} invited you to their Basecamp (#{@account.name})"
  end

  def project_invitation
    @project    = params[:project]
    @summarizer = ProjectInvitationSummarizer.new(@project.bucket)

    mail subject: "#{@inviter.name.familiar} added you to a project in Basecamp (#{@account.name})"
  end
end
```

* `after_action` можно использовать для подобной настройки, как и в `before_action`, но используя переменные экземпляра, установленные в экшне рассыльщика.

```ruby
class UserMailer < ApplicationMailer
  before_action { @business, @user = params[:business], params[:user] }

  after_action :set_delivery_options,
               :prevent_delivery_to_guests,
               :set_business_headers

  def feedback_message
  end

  def campaign_message
  end

  private

    def set_delivery_options
      # Тут у вас есть доступ к экземпляру mail и переменным экземпляра
      # @business и @user
      if @business && @business.has_smtp_settings?
        mail.delivery_method.settings.merge!(@business.smtp_settings)
      end
    end

    def prevent_delivery_to_guests
      if @user && @user.guest?
        mail.perform_deliveries = false
      end
    end

    def set_business_headers
      if @business
        headers["X-SMTPAPI-CATEGORY"] = @business.code
      end
    end
end
```

* Фильтры рассыльщика прерывают дальнейшую обработку, если body установлено в не-nil значение.

Использование хелперов Action Mailer
------------------------------------

Action Mailer теперь всего лишь наследуется от `AbstractController`, поэтому у вас есть доступ к тем же общим хелперам, как и в Action Controller.

(action-mailer-configuration) Настройка Action Mailer
-----------------------------------------------------

Следующие конфигурационные опции лучше всего делать в одном из файлов среды разработки (environment.rb, production.rb, и т.д...)

| Конфигурация            | Описание |
| ----------------------- | -------- |
| `logger`                | logger используется для генерации информации на ходу, если возможно. Можно установить как `nil` для отсутствия логирования. Совместим как с `Logger` в Ruby, так и с логгером `Log4r`.|
| `smtp_settings`         | Позволяет подробную настройку для метода доставки `:smtp`:<ul><li>`:address` - Позволяет использовать удаленный почтовый сервер. Просто измените его изначальное значение "localhost".</li><li>`:port` - В случае, если почтовый сервер не работает с 25 портом, можете изменить его.</li><li>`:domain` - Если необходимо определить домен HELO, это можно сделать здесь.</li><li>`:user_name` - Если почтовый сервер требует аутентификацию, установите имя пользователя этой настройкой.</li><li>`:password` - Если почтовый сервер требует аутентификацию, установите пароль этой настройкой. </li><li>`:authentication` - Если почтовый сервер требует аутентификацию, здесь нужно определить тип аутентификации. Это один из символов `:plain` (будет отправлять пароль в открытом виде), `:login` (будет отправлять пароль закодированным Base64) или `:cram_md5` (сочетает в себе механизм Challenge/Response для обмена информацией и криптографический алгоритм MD5 (Message Digest 5) хэширования важной информации)</li><li>`:enable_starttls_auto` - Определяет, включен ли STARTTLS в вашем SMTP сервере и будет использовать это. По умолчанию, `true`.</li><li>`:openssl_verify_mode` - При использовании TLS, вы можете установить, как OpenSSL проверяет сертификат. Это действительно полезно, если вам нужно производить проверку самостоятельно созданного и/или группового сертификата. Вы можете использовать название проверяющей константы OpenSSL ('none' или 'peer') или непосредственно константу (`OpenSSL::SSL::VERIFY_NONE` или `OpenSSL::SSL::VERIFY_PEER`).</li></ul>|
| `sendmail_settings`     | Позволяет переопределить опции для метода доставки `:sendmail`.<ul><li>`:location` - Место расположения исполняемого sendmail. По умолчанию `/usr/sbin/sendmail`.</li><li>`:arguments` - Аргументы командной строки. По умолчанию `-i`.</li></ul>|
| `raise_delivery_errors` | Должны ли быть вызваны ошибки, если email не может быть доставлен. Это работает, если внешний сервер email настроен на немедленную доставку.|
| `delivery_method`       | Определяет метод доставки. Возможные значения: <ul><li>`:smtp` (по умолчанию), может быть настроен с помощью `config.action_mailer.smtp_settings`.</li><li>`:sendmail`, может быть настроен с помощью  `config.action_mailer.sendmail_settings`.</li><li>`:file`: сохраняет письма в файлы; может быть настроен с помощью `config.action_mailer.file_settings`.</li><li>`:test`: сохраняет письма в массив `ActionMailer::Base.deliveries`.</li></ul>Подробнее смотрите в [API docs](http://api.rubyonrails.org/classes/ActionMailer/Base.html).|
| `perform_deliveries`    | Определяет, должны ли методы deliver_* фактически выполняться. По умолчанию должны, но это можно отключить для функционального тестирования.|
| `deliveries`            | Содержит массив всех электронных писем, отправленных через Action Mailer с помощью delivery_method :test. Очень полезно для юнит- и функционального тестирования.|
| `default_options`       | Позволит вам установить значения по умолчанию для опций метода `mail` (`:from`, `:reply_to` и т.д.).|

Подробное описание возможных конфигураций смотрите в [разделе про настройку Action Mailer](/configuring-rails-applications#configuring-action-mailer) нашего руководства по конфигурированию приложений на Rails.

### Пример настройки Action Mailer

Примером может быть добавление следующего в подходящий файл `config/environments/$RAILS_ENV.rb`:

```ruby
config.action_mailer.delivery_method = :sendmail
# Defaults to:
# config.action_mailer.sendmail_settings = {
#   location: '/usr/sbin/sendmail',
#   arguments: '-i'
# }
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_options = {from: 'no-reply@example.com'}
```

### Настройка Action Mailer для Gmail

Action Mailer теперь использует [гем Mail](https://github.com/mikel/mail), теперь это сделать просто, нужно добавить в файл `config/environments/$RAILS_ENV.rb`:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'example.com',
  user_name:            '<username>',
  password:             '<password>',
  authentication:       'plain',
  enable_starttls_auto: true }
```

NOTE: 15 июля 2014 Google усилили [меры безопасности](https://support.google.com/accounts/answer/6010255) и теперь блокируют попытки от приложений, которые они сочтут небезопасными. Вы можете изменить ваши настройки gmail [здесь](https://www.google.com/settings/security/lesssecureapps), чтобы позволить попытки. Если ваша учетная запись Gmail активирована с использованием двухфакторной аутентификации, вам нужно будет установить [пароль приложения](https://myaccount.google.com/apppasswords) и использовать ее вместо обычного пароля. Кроме того, вы можете использовать другой почтовый провайдер (ESP, email service provider) для отправки почты, заменив выше 'smtp.gmail.com' на адрес вашего провайдера.

Тестирование рассыльщика
------------------------

Подробные инструкции, как тестировать ваши рассыльщики, можно найти в руководстве [Тестирование приложений на Rails](a-guide-to-testing-rails-applications#testing-your-mailers)

Перехват писем
--------------

Бывают ситуации, когда необходимо отредактировать письмо до его отправки. К счастью, Action Mailer предоставляет хуки для перехвата каждого письма. Можно зарегистрировать перехватчик для модификации сообщений писем перед тем, как они будут переданы агентам доставки.

```ruby
class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['sandbox@example.com']
  end
end
```

Прежде чем перехватчик сможет выполнить свое задание, необходимо зарегистрировать его с помощью фреймворка Action Mailer. Это можно сделать в файле инициализатора `config/initializers/sandbox_email_interceptor.rb`

```ruby
if Rails.env.staging?
  ActionMailer::Base.register_interceptor(SandboxEmailInterceptor)
end
```

NOTE: Вышеприведенный пример использует пользовательское окружение по имени "staging" для сервера, похожего на production, но для целей тестирования. Подробнее о пользовательских окружениях в Rails можно прочитать в [Создание сред Rails](/configuring-rails-applications#creating-rails-environments).
