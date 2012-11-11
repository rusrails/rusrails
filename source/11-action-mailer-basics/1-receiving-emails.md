# Получение электронной почты

Получение и парсинг электронной почты с помощью Action Mailer может быть довольно сложным делом. До того, как электронная почта достигнет ваше приложение на Rails, нужно настроить вашу систему, чтобы каким-то образом направлять почту в приложение, которому нужно быть следящим за ней. Таким образом, чтобы получать электронную почту в приложении на Rails, нужно:

* Реализовать метод `receive` в вашем рассыльщике.

* Настроить ваш почтовый сервер для направления почты от адресов, желаемых к получению вашим приложением, в `/path/to/app/script/rails runner 'UserMailer.receive(STDIN.read)'`.

Как только метод, названный `receive`, определяется в каком-либо рассыльщике, Action Mailer будет парсить сырую входящую почту в объект email, декодировать его, создавать экземпляр нового рассыльщика и передавать объект email в метод экземпляра рассыльщика `receive`. Вот пример:

```ruby
class UserMailer < ActionMailer::Base
  def receive(email)
    page = Page.find_by_address(email.to.first)
    page.emails.create(
      :subject => email.subject,
      :body => email.body
    )

    if email.has_attachments?
      email.attachments.each do |attachment|
        page.attachments.create({
          :file => attachment,
          :description => email.subject
        })
      end
    end
  end
end
```
