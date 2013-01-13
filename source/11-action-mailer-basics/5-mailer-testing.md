# Тестирование рассыльщика

По умолчанию Action Mailer не посылает электронные письма в среде разработки test. Они всего лишь добавляются к массиву `ActionMailer::Base.deliveries`.

Тестирование рассыльщиков обычно включает две вещи: Первая это то, что письмо помещается в очередь, а вторая это то, что письмо правильное. Имея это в виду, можем протестировать наш пример рассыльщика из предыдущих статей таким образом:

```ruby
class UserMailerTest < ActionMailer::TestCase
  def test_welcome_email
    user = users(:some_user_in_your_fixtures)

    # Посылаем email, затем тестируем, если оно не попало в очередь
    email = UserMailer.welcome_email(user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Тестируем, содержит ли тело посланного email то, что мы ожидаем
    assert_equal [user.email], email.to
    assert_equal 'Welcome to My Awesome Site', email.subject
    assert_match "<h1>Welcome to example.com, #{user.name}</h1>", email.body.to_s
    assert_match 'you have joined to example.com community', email.body.to_s
  end
end
```

В тесте мы посылаем email и храним возвращенный объект в переменной `email`. Затем мы убеждаемся, что он был послан (первый assert), затем, во второй группе операторов контроля, мы убеждаемся, что email действительно содержит то, что мы ожидаем.
