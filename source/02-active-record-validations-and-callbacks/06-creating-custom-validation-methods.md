# Выполнение собственных валидаций

Когда встроенных валидационных хелперов недостаточно для ваших нужд, можете написать свои собственные валидаторы или методы валидации.

### Собственные валидаторы

Собственные валидаторы это классы, расширяющие `ActiveModel::Validator`. Эти классы должны реализовать метод `validate`, принимающий запись как аргумент и выполняющий валидацию на ней. Собственный валидатор вызывается с использованием метода `validates_with`.

```ruby
class MyValidator < ActiveModel::Validator
  def validate(record)
    if record.name.starts_with? ‘X’
      record.errors[:name] << ‘Need a name starting with X please!’
    end
  end
end
 
class Person
  include ActiveModel::Validations
  validates_with MyValidator
end
```

Простейшим способом добавить собственные валидаторы для валидации отдельных атрибутов является наследуемость от `ActiveModel::EachValidator`. В этом случае класс собственного валидатора должен реализовать метод `validate_each`, принимающий три аргумента: запись, атрибут и значение, соответствующее экземпляру, соответственно атрибут тот, который будет проверяться и значение в переданном экземпляре:

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)`[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end

class Person < ActiveRecord::Base
  validates :email, presence: true, email: true
end
```

Как показано в примере, можно объединять стандартные валидации со своими произвольными валидаторами.

### Собственные методы

Также возможно создать методы, проверяющие состояние ваших моделей и добавляющие сообщения в коллекцию `errors`, когда они невалидны. Затем эти методы следует зарегистрировать, используя метод класса `validate`, передав символьные имена валидационных методов.

Можно передать более одного символа для каждого метода класса, и соответствующие валидации будут запущены в том порядке, в котором они зарегистрированы.

```ruby
class Invoice < ActiveRecord::Base
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "can't be in the past")
    end
  end

  def discount_cannot_be_greater_than_total_value
    errors.add(:discount, "can't be greater than total value") if
      discount > total_value
  end
end
```

По умолчанию такие валидации будут выполнены каждый раз при вызове `valid?`. Также возможно контролировать, когда выполнять собственные валидации, передав опцию `:on` в метод `validate`, с ключами: `:create` или `:update`.

```ruby
class Invoice < ActiveRecord::Base
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "is not active") unless customer.active?
  end
end
```
