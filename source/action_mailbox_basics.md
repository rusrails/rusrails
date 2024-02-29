Основы Action Mailbox
=====================

Это руководство предоставляет вам все, что нужно для того, чтобы начать получать письма в вашем приложении.

После его прочтения, вы узнаете:

* Как получать письма в приложении Rails.
* Как настраивать Action Mailbox.
* Как генерировать и маршрутизировать письма в ящик.
* Как тестировать входящие письма.

--------------------------------------------------------------------------------

Что такое Action Mailbox?
-----------------------

Action Mailbox маршрутизирует входящие письма в подобные контроллеру ящики для обработки в приложении Rails. Action Mailbox предназначен для получения электронных писем, в то время как [Action Mailer](/action-mailer-basics) используется для их *отправки*.

Входящие электронные письма асинхронно направляются с помощью [Active Job](/active_job_basics) в один или несколько специализированных почтовых ящиков. Затем эти письма преобразуются в записи [`InboundEmail`](https://api.rubyonrails.org/classes/ActionMailbox/InboundEmail.html) с помощью [Active Record](/active-record-basics), которые могут взаимодействовать напрямую с остальными моделями вашей предметной области.

Записи `InboundEmail` также обеспечивают отслеживание жизненного цикла, хранение исходного письма с помощью [Active Storage](/active_storage_overview) и ответственное управление данными с автоматическим [уничтожением](#incineration-of-inboundemails) по умолчанию.

Action Mailbox поставляется с ингрессами, которые позволяют вашему приложению получать электронные письма от внешних почтовых провайдеров, таких как Mailgun, Mandrill, Postmark и SendGrid. Также можно обрабатывать входящие письма напрямую, с помощью встроенных ингрессов Exim, Postfix и Qmail.

## Настройка

В Action Mailbox есть несколько ключевых этапов настройки. Сначала запускаете установщик. Затем выбираете и конфигурируете ингресс для обработки входящих писем. И затем вы уже можете добавлять маршрутизацию Action Mailbox, создание почтовых ящиков и начать обрабатывать входящие письма.

Для начала давайте установим Action Mailbox:

```bash
$ bin/rails action_mailbox:install
```

Это создаст файл `application_mailbox.rb` и скопирует миграции.

```bash
$ bin/rails db:migrate
```

Эта команда выполнит миграции для Action Mailbox и Active Storage.

Таблица `action_mailbox_inbound_emails` в Action Mailbox хранит входящие сообщения и их статус обработки.

Теперь вы можете запустить сервер Rails и перейти по ссылке `http://localhost:3000/rails/conductor/action_mailbox/inbound_emails`. Подробности смотрите в  [Локальная разработка и тестирование](#local-development-and-testing)

Следующим шагом будет настройка ингресса в вашем приложении Rails для определения способа получения входящих электронных писем.

## Настройка ингресса

Настройка ингресса включает в себя определение учетных данных и информации о конечной точке для выбранной службы электронной почты. Вот инструкции для каждого из поддерживаемого ингресса.

### Exim

Сообщите Action Mailbox принимать письма от релея SMTP:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Сгенерируйте сложный пароль, который Action Mailbox может использовать для аутентификации запросов к ингрессу релея.

Используйте `bin/rails credentials:edit` чтобы добавить пароль в зашифрованные учетные данные вашего приложения под именем `action_mailbox.ingress_password`, по которому Action Mailbox автоматически найдет его:

```yaml
action_mailbox:
  ingress_password: ...
```

Альтернативно можно предоставить пароль в переменной среды `RAILS_INBOUND_EMAIL_PASSWORD`.

Настройте Exim передавать входящие письма в `bin/rails action_mailbox:ingress:exim`, предоставив `URL` ингресса релея и `INGRESS_PASSWORD`, созданный ранее. Если ваше приложение находится по адресу `https://example.com`, полная команда будет выглядеть так:

```bash
$ bin/rails action_mailbox:ingress:exim URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Mailgun

Передайте Action Mailbox ваш ключ Mailgun Signing (который можно найти в Settings -> Security & Users -> API security в Mailgun), таким образом он сможет аутентифицировать запросы к ингрессу Mailgun.

Используйте `bin/rails credentials:edit`, чтобы добавить ключ Signing в зашифрованные учетные данные вашего приложения под именем `action_mailbox.mailgun_signing_key`, по которому Action Mailbox автоматически найдет его:

```yaml
action_mailbox:
  mailgun_signing_key: ...
```

Альтернативно можно предоставить ключ Signing в переменной среды `MAILGUN_INGRESS_SIGNING_KEY`.

Сообщите Action Mailbox принимать письма от Mailgun:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mailgun
```

[Настройте Mailgun](https://documentation.mailgun.com/en/latest/user_manual.html#receiving-forwarding-and-storing-messages)
перенаправлять входящие письма в `/rails/action_mailbox/mailgun/inbound_emails/mime`. Если ваше приложение находится по адресу `https://example.com`, нужно указать полный URL `https://example.com/rails/action_mailbox/mailgun/inbound_emails/mime`.

### Mandrill

Передайте Action Mailbox ваш ключ Mandrill API, таким образом он сможет аутентифицировать запросы к ингрессу Mandrill.

Используйте `bin/rails credentials:edit` чтобы добавить ключ API в зашифрованные учетные данные вашего приложения под именем `action_mailbox.mandrill_api_key`, по которому Action Mailbox автоматически найдет его:

```yaml
action_mailbox:
  mandrill_api_key: ...
```

Альтернативно можно предоставить ключ API в переменной среды `MANDRILL_INGRESS_API_KEY`.

Сообщите Action Mailbox принимать письма от Mandrill:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mandrill
```

[Настройте Mandrill](https://mandrill.zendesk.com/hc/en-us/articles/205583197-Inbound-Email-Processing-Overview) перенаправлять входящие письма в `/rails/action_mailbox/mandrill/inbound_emails`. Если ваше приложение находится по адресу `https://example.com`, нужно указать полный URL `https://example.com/rails/action_mailbox/mandrill/inbound_emails`.

### Postfix

Сообщите Action Mailbox принимать письма от релея SMTP:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Сгенерируйте сложный пароль, который Action Mailbox может использовать для аутентификации запросов к ингрессу релея.

Используйте `bin/rails credentials:edit` чтобы добавить пароль в зашифрованные учетные данные вашего приложения под именем `action_mailbox.ingress_password`, по которому Action Mailbox автоматически найдет его:

```yaml
action_mailbox:
  ingress_password: ...
```

Альтернативно можно предоставить пароль в переменной среды `RAILS_INBOUND_EMAIL_PASSWORD`.

[Настройте Postfix](https://serverfault.com/questions/258469/how-to-configure-postfix-to-pipe-all-incoming-email-to-a-script) передавать входящие письма в `bin/rails action_mailbox:ingress:postfix`, предоставив `URL` ингресса релея и `INGRESS_PASSWORD`, созданный ранее. Если ваше приложение находится по адресу `https://example.com`, полная команда будет выглядеть так:

```bash
$ bin/rails action_mailbox:ingress:postfix URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Postmark

Сообщите Action Mailbox принимать письма от Postmark:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :postmark
```

Сгенерируйте сложный пароль, который Action Mailbox может использовать для аутентификации запросов к ингрессу Postmark.

Используйте `bin/rails credentials:edit` чтобы добавить пароль в зашифрованные учетные данные вашего приложения под именем `action_mailbox.ingress_password`, по которому Action Mailbox автоматически найдет его:

```yaml
action_mailbox:
  ingress_password: ...
```

Альтернативно можно предоставить пароль в переменной среды `RAILS_INBOUND_EMAIL_PASSWORD`.

[Настройте веб-хук входящих Postmark](https://postmarkapp.com/manual#configure-your-inbound-webhook-url), чтобы перенаправлять входящие письма в `/rails/action_mailbox/postmark/inbound_emails` с именем пользователя `actionmailbox` и созданным ранее паролем. Если ваше приложение находится по адресу `https://example.com`, нужно указать в настройках Postmark следующий полный URL:

```
https://actionmailbox:PASSWORD@example.com/rails/action_mailbox/postmark/inbound_emails
```

NOTE: При настройке веб-хука входящих Postmark, убедитесь, что вы включили **"Include raw email content in JSON payload"**.
Action Mailbox нужно исходное содержимое email для работы.

### Qmail

Сообщите Action Mailbox принимать письма от релея SMTP:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Сгенерируйте сложный пароль, который Action Mailbox может использовать для аутентификации запросов к ингрессу релея.

Используйте `bin/rails credentials:edit` чтобы добавить пароль в зашифрованные учетные данные вашего приложения под именем `action_mailbox.ingress_password`, по которому Action Mailbox автоматически найдет его:

```yaml
action_mailbox:
  ingress_password: ...
```

Альтернативно можно предоставить пароль в переменной среды `RAILS_INBOUND_EMAIL_PASSWORD`.

Настройте Qmail передавать входящие письма в `bin/rails action_mailbox:ingress:qmail`, предоставив `URL` ингресса релея и `INGRESS_PASSWORD`, созданный ранее. Если ваше приложение находится по адресу `https://example.com`, полная команда будет выглядеть так:

```bash
$ bin/rails action_mailbox:ingress:qmail URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### SendGrid

Сообщите Action Mailbox принимать письма от SendGrid:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :sendgrid
```

Сгенерируйте сложный пароль, который Action Mailbox может использовать для аутентификации запросов к ингрессу SendGrid.

Используйте `bin/rails credentials:edit` чтобы добавить пароль в зашифрованные учетные данные вашего приложения под именем `action_mailbox.ingress_password`, по которому Action Mailbox автоматически найдет его:

```yaml
action_mailbox:
  ingress_password: ...
```

Альтернативно можно предоставить пароль в переменной среды `RAILS_INBOUND_EMAIL_PASSWORD`.

[Настройте SendGrid Inbound Parse](https://sendgrid.com/docs/for-developers/parsing-email/setting-up-the-inbound-parse-webhook/) передавать входящие письма в `/rails/action_mailbox/sendgrid/inbound_emails` с именем пользователя `actionmailbox` и ранее созданным паролем. Если ваше приложение находится по адресу `https://example.com`, нужно настроить SendGrid следующим URL:

```
https://actionmailbox:PASSWORD@example.com/rails/action_mailbox/sendgrid/inbound_emails
```

NOTE: При настройке веб хука SendGrid Inbound Parse, убедитесь, что включили флажок с надписью **“Post the raw, full MIME message.”** Action Mailbox для работы требует исходное сообщение MIME.

## Обработка входящих электронных писем

Обработка входящих электронных писем в вашем Rails-приложении обычно включает в себя использование содержимого письма для создания моделей, обновления вью, постановки фоновых задач в очередь.

Прежде чем приступить к обработке входящих писем, необходимо настроить маршрутизацию Action Mailbox и создать почтовые ящики.

### Настройка маршрутизации

После того, как входящее письмо получено через настроенный ингресс, оно должно быть направлено в почтовый ящик для дальнейшей обработки вашим приложением Подобно тому, как [маршрутизатор Rails](/routing) направляет URL-адреса к контроллерам, маршрутизация в Action Mailbox определяет, какие письма отправляются в какие почтовые ящики для обработки. Маршруты добавляются в файл `application_mailbox.rb` с использованием регулярных выражений:

```ruby
# app/mailboxes/application_mailbox.rb
class ApplicationMailbox < ActionMailbox::Base
  routing(/^save@/i     => :forwards)
  routing(/@replies\./i => :replies)
end
```

Регулярное выражение совпадает с полями `to` (кому), `cc` (копия) или `bcc` (скрытая копия) входящего письма. Например, приведенный выше код будет направлять любое письмо, отправленное на адрес `save@`, в почтовый ящик "forwards". Существуют и другие способы маршрутизации писем, подробности смотрите в
[`ActionMailbox::Base`](https://api.rubyonrails.org/classes/ActionMailbox/Base.html).

Далее нам нужно создать этот почтовый ящик "forwards".

### Создание почтового ящика

```bash
# Создайте новый почтовый ящик
$ bin/rails generate mailbox forwards
```

Это создаст файл `app/mailboxes/forwards_mailbox.rb`, содержащий класс `ForwardsMailbox` и метод `process`.

### Обработка Email

При обработке `InboundEmail` вы можете получить структурированную версию письма в виде объекта [`Mail`](https://github.com/mikel/mail) с помощью метода `InboundEmail#mail`. Вы также можете получить исходный код письма напрямую с помощью метода `#source`. Объект `Mail` предоставляет доступ к различным полям письма, таким как `mail.to`, `mail.body.decoded` и т.д.

```irb
irb> mail
=> #<Mail::Message:33780, Multipart: false, Headers: <Date: Wed, 31 Jan 2024 22:18:40 -0600>, <From: someone@hey.com>, <To: save@example.com>, <Message-ID: <65bb1ba066830_50303a70397e@Bhumis-MacBook-Pro.local.mail>>, <In-Reply-To: >, <Subject: Hello Action Mailbox>, <Mime-Version: 1.0>, <Content-Type: text/plain; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <x-original-to: >>
irb> mail.to
=> ["save@example.com"]
irb> mail.from
=> ["someone@hey.com"]
irb> mail.date
=> Wed, 31 Jan 2024 22:18:40 -0600
irb> mail.subject
=> "Hello Action Mailbox"
irb> mail.body.decoded
=> "This is the body of the email message."
# mail.decoded, a shorthand for mail.body.decoded, also works
irb> mail.decoded
=> "This is the body of the email message."
irb> mail.body
=> <Mail::Body:0x00007fc74cbf46c0 @boundary=nil, @preamble=nil, @epilogue=nil, @charset="US-ASCII", @part_sort_order=["text/plain", "text/enriched", "text/html", "multipart/alternative"], @parts=[], @raw_source="This is the body of the email message.", @ascii_only=true, @encoding="7bit">
```

### Статус входящего письма

Во время маршрутизации к соответствующему почтовому ящику и обработки Action Mailbox обновляет статус письма, хранящийся в таблице `action_mailbox_inbound_emails`, одним из следующих значений:

- `pending`: письмо получено одним из контроллеров ингресса и запланировано к маршрутизации.
- `processing`: письмо активно обрабатывается определенным почтовым ящиком, выполняющим его метод `process`.
- `delivered`: письмо успешно обработано конкретным почтовым ящиком.
- `failed`: во время выполнения метода `process` конкретного почтового ящика возникла ошибка.
- `bounced`: письмо отклонено конкретным почтовым ящиком и возвращено отправителю.

Если письмо помечено как `delivered`, `failed` или `bounced`, оно считается "обработанным" и помечается на [уничтожение](#incineration-of-inboundemails).

## Пример

Ниже приведен пример Action Mailbox, который обрабатывает электронные письма для создания "переадресаций" для проектов пользователя.

Колбэк `before_processing` используется для обеспечения выполнения определенных условий перед вызовом метода `process`. В данном случае `before_processing` проверяет наличие у пользователя хотя бы одного проекта. Другие поддерживаемые [колбэки Action Mailbox](https://api.rubyonrails.org/classes/ActionMailbox/Callbacks.html) - `after_processing` и `around_processing`.

Письмо может быть возвращено отправителю с помощью `bounced_with`, если у "переадресанта" нет проектов. "Переадресант" - это `User` с тем же адресом электронной почты, что и `mail.from`.

Если у "переадресанта" есть хотя бы один проект, метод `record_forward` создает модель Active Record в приложении, используя данные письма `mail.subject` и `mail.decoded`. В противном случае он отправляет электронное письмо с помощью Action Mailer, с просьбой к "переадресанту" выбрать проект.

```ruby
# app/mailboxes/forwards_mailbox.rb
class ForwardsMailbox < ApplicationMailbox
  # Колбэки, указывающие предусловия обработки
  before_processing :require_projects

  def process
    # Запишите перенаправление на единственный проект, или…
    if forwarder.projects.one?
      record_forward
    else
      # …вовлеките второй Action Mailer, чтобы спросить, в какой проект это нужно направить.
      request_forwarding_project
    end
  end

  private
    def require_projects
      if forwarder.projects.none?
        # Используйте Action Mailers для возврата входящих писем отправителю – это прервет обработку
        bounce_with Forwards::BounceMailer.no_projects(inbound_email, forwarder: forwarder)
      end
    end

    def record_forward
      forwarder.forwards.create subject: mail.subject, content: mail.decoded
    end

    def request_forwarding_project
      Forwards::RoutingMailer.choose_project(inbound_email, forwarder: forwarder).deliver_now
    end

    def forwarder
      @forwarder ||= User.find_by(email_address: mail.from)
    end
end
```

## (local-development-and-testing) Локальная разработка и тестирование

Полезно иметь возможность тестирования входящих писем при разработке без фактического отправления и получения реальных писем. Для этого есть вспомогательный контроллер, смонтированный на `/rails/conductor/action_mailbox/inbound_emails`, дающий перечень всех InboundEmail в системе, состояние их обработки, а также форму для создания нового InboundEmail.

Вот пример тестирования входящего письма с помощью Action Mailbox TestHelpers.

```ruby
class ForwardsMailboxTest < ActionMailbox::TestCase
  test "directly recording a client forward for a forwarder and forwardee corresponding to one project" do
    assert_difference -> { people(:david).buckets.first.recordings.count } do
      receive_inbound_email_from_mail \
        to: 'save@example.com',
        from: people(:david).email_address,
        subject: "Fwd: Status update?",
        body: <<~BODY
          --- Begin forwarded message ---
          From: Frank Holland <frank@microsoft.com>

          What's the status?
        BODY
    end

    recording = people(:david).buckets.first.recordings.last
    assert_equal people(:david), recording.creator
    assert_equal "Status update?", recording.forward.subject
    assert_match "What's the status?", recording.forward.content.to_s
  end
end
```

За остальными тестовыми вспомогательными методами обратитесь к [ActionMailbox::TestHelper API](https://api.rubyonrails.org/classes/ActionMailbox/TestHelper.html).


## (incineration-of-inboundemails) Уничтожение InboundEmails

По умолчанию `InboundEmail`, которое было обработано, будет уничтожено через 30 дней. `InboundEmail` рассматривается обработанным, когда его статус изменяется на `delivered`, `failed` или `bounced`.

Фактическое уничтожение выполняется с помощью [`IncinerationJob`](https://api.rubyonrails.org/classes/ActionMailbox/IncinerationJob.html), которая запланирована на запуск через [`config.action_mailbox.incinerate_after`](/configuring#config-action-mailbox-incinerate-after). Это значение по умолчанию установлено `30.days`, но его можно изменить в настройках production.rb. (Отметьте, что это планируемое будущее уничтожение полагается на возможность вашей очереди задач хранить задачи на такой промежуток времени.)

Уничтожение данных по умолчанию гарантирует, что вы не будете хранить данные пользователей без необходимости, после того, как они отменили свои учетные записи или удалили свой контент.

Предполагается, что при обработке входящего письма с помощью Action Mailbox вы извлекаете из него все необходимые данные и сохраняете их в моделях предметной области вашего приложения. Запись `InboundEmail` остается в системе в течение настроенного времени для целей отладки и криминалистики, а затем удаляется.
