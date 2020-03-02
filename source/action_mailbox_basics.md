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

Action Mailbox маршрутизирует входящие письма в подобные контроллеру ящики для обработки в Rails. Он поставляется с ингрессом для Mailgun, Mandrill, Postmark и SendGrid. Также можно обрабатывать входящие письма напрямую, с помощью встроенных ингрессов Exim, Postfix и Qmail.

Входящие письма преобразуются в записи `InboundEmail` с помощью Active Record и отслеживания жизненного цикла, оригинальные письма хранятся в облачном хранилище с помощью Active Storage, и данные обрабатываются с последующим их уничтожением по умолчанию.

Эти входящие письма асинхронно маршрутизируются с помощью Active Job на один или несколько выделенных ящиков, которые способны непосредственно взаимодействовать с остальной частью вашей доменной модели.

## Настройка

Установите миграции, необходимые для `InboundEmail`, и убедитесь, что Active Storage настроен:

```bash
$ bin/rails action_mailbox:install
$ bin/rails db:migrate
```

## Конфигурация

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

```shell
bin/rails action_mailbox:ingress:exim URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Mailgun

Передайте Action Mailbox ваш [ключ Mailgun API](https://help.mailgun.com/hc/en-us/articles/203380100-Where-can-I-find-my-API-key-and-SMTP-credentials), таким образом он сможет аутентифицировать запросы к ингрессу Mailgun.

Используйте `bin/rails credentials:edit`, чтобы добавить ключ API в зашифрованные учетные данные вашего приложения под именем `action_mailbox.mailgun_api_key`, по которому Action Mailbox автоматически найдет его:

```yaml
action_mailbox:
  mailgun_api_key: ...
```

Альтернативно можно предоставить ключ API в переменной среды `MAILGUN_INGRESS_API_KEY`.

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

```shell
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

```shell
bin/rails action_mailbox:ingress:qmail URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
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

## Примеры

Настройте простой роутинг:

```ruby
# app/mailboxes/application_mailbox.rb
class ApplicationMailbox < ActionMailbox::Base
  routing /^save@/i     => :forwards
  routing /@replies\./i => :replies
end
```

Затем настройте почтовый ящик:

```ruby
# Создайте новый почтовый ящик
$ bin/rails generate mailbox forwards
```

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
        # Мспользуйте Action Mailers для возврата входящих писем отправителю – это прервет обработку
        bounce_with Forwards::BounceMailer.no_projects(inbound_email, forwarder: forwarder)
      end
    end

    def record_forward
      forwarder.forwards.create subject: mail.subject, content: mail.content
    end

    def request_forwarding_project
      Forwards::RoutingMailer.choose_project(inbound_email, forwarder: forwarder).deliver_now
    end

    def forwarder
      @forwarder ||= User.find_by(email_address: mail.from)
    end
end
```

## Уничтожение InboundEmails

По умолчанию InboundEmail, которое было успешно обработано, будет уничтожено через 30 дней. Это удостоверяет, что вы не храните данные людей вынужденно, после того, как они могли закрыть свой аккаунт или удалить свое содержимое. Цель в том, что после обработки письма, вы должны извлечь все нужные данные и преобразовать их в модели домена и содержимое на вашей стороне в приложении. InboundEmail просто остается в системе на некоторое время для предоставления возможности отладки и криминалистики.

Фактическое уничтожение выполняется с помощью `IncinerationJob`, которая запланирована на запуск через `config.action_mailbox.incinerate_after`. Это значение по умолчанию установлено `30.days`, но его можно изменить в настройках production.rb. (Отметьте, что это планируемое будущее уничтожение полагается на возможность вашей очереди задач хранить задачи на такой промежуток времени.)

## Работа с Action Mailbox при разработке

Полезно иметь возможность тестирования входящих писем при разработке без фактического отправления и получения реальных писем. Для этого есть вспомогательный контроллер, смонтированный на `/rails/conductor/action_mailbox/inbound_emails`, дающий перечень всех InboundEmail в системе, состояние их обработки, а также форму для создания нового InboundEmail.

## Тестирование почтовых ящиков

Пример:

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
