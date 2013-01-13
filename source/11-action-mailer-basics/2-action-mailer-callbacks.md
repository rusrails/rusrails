# Колбэки Action Mailer

Action Mailer позволяет определить `before_action`, `after_action` и 'around_action'.

* Фильтры могут быть определены в блоке или сиволом с именем метода рассыльщика, подобно контроллерам.

* `before_action` можно использовать для предварительного заполнения объекта mail значениями по умолчанию, delivery_method_options или вставки заголовков по умолчанию и вложений.

* `after_action` можно использовать для подобной настройки, как и в `before_action`, но используя переменные экземпляра, установленные в экшне рассыльщика.

```ruby
class UserMailer < ActionMailer::Base
  after_action :set_delivery_options, :prevent_delivery_to_guests, :set_business_headers

  def feedback_message(business, user)
    @business = business
    @user = user
    mail
  end

  def campaign_message(business, user)
    @business = business
    @user = user
  end

  private

  def set_delivery_options
    # Тут у вас есть доступ к экземпляру mail и переменным экземпляра @business и @user
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
