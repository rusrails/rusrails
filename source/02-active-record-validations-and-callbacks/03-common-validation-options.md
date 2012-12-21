# Общие опции валидаций

Есть несколько общих опций валидаций:

### `:allow_nil`

Опция `:allow_nil` пропускает валидацию, когда проверяемое значение равно `nil`.

```ruby
class Coffee < ActiveRecord::Base
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }, allow_nil: true
end
```

TIP: `:allow_nil` игнорируется валидатором presence.

### `:allow_blank`

Опция `:allow_blank` подобна опции `:allow_nil`. Эта опция пропускает валидацию, если значение аттрибута `blank?`, например `nil` или пустая строка.

```ruby
class Topic < ActiveRecord::Base
  validates :title, length: { is: 5 }, allow_blank: true
end

Topic.create("title" => "").valid?  # => true
Topic.create("title" => nil).valid? # => true
```

TIP: `:allow_blank` игнорируется валидатором presence.

### `:message`

Как мы уже видели, опция `:message` позволяет определить сообщение, которое будет добавлено в коллекцию `errors`, когда валидация проваливается. Если эта опция не используется, Active Record будет использовать соответственные сообщение об ошибках по умолчанию для каждого валидационного хелпера.

### `:on`

Опция `:on` позволяет определить, когда должна произойти валидация. Стандартное поведение для всех встроенных валидационных хелперов это запускаться при сохранении (и когда создается новая запись, и когда она обновляется). Если хотите изменить это, используйте `on: :create`, для запуска валидации только когда создается новая запись, или `on: :update`, для запуска валидации когда запись обновляется.

```ruby
class Person < ActiveRecord::Base
  # будет возможно обновить email с дублирующим значением
  validates :email, uniqueness: true, on: :create

  # будет возможно создать запись с нечисловым возрастом
  validates :age, numericality: true, on: :update

  # по умолчанию (проверяет и при создании, и при обновлении)
  validates :name, presence: true, on: :save
end
```
