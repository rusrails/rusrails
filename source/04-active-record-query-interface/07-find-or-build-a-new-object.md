# Поиск или создание нового объекта

Нормально, если вам нужно найти запись или создать ее, если она не существует. Это осуществимо с помощью методов `find_or_create_by` и `find_or_create_by!`.

### `find_or_create_by`

Метод `find_or_create_by` проверяет, существует ли запись с атрибутами. Если нет, то вызывается `create`. Давайте рассмотрим пример.

Предположим, вы хотите найти клиента по имени 'Andy', и, если такого нет, создать его. Это можно сделать, выполнив:

```ruby
Client.find_or_create_by(first_name: 'Andy')
+# => #<Client id: 1, first_name: "Andy", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">
```

SQL, генерируемый этим методом, выглядит так:

```sql
SELECT * FROM clients WHERE (clients.first_name = 'Andy') LIMIT 1
BEGIN
INSERT INTO clients (created_at, first_name, locked, orders_count, updated_at) VALUES ('2011-08-30 05:22:57', 'Andy', 1, NULL, '2011-08-30 05:22:57')
COMMIT
```

`find_or_create_by` возвращает либо уже существующую запись, либо новую запись. В нашем случае, у нас еще нет клиента с именем Andy, поэтому запись будет создана и возвращена.

Новая запись может быть не сохранена в базу данных; это зависит от того, прошли валидации или нет (подобно `create`).

Предположим, мы хотим установить атрибут 'locked' как true, если создаем новую запись, но не хотим включать его в запрос. Таким образом, мы хотим найти клиента по имени "Andy" или, если этот клиент не существует, создать клиента по имени "Andy", который не заблокирован.

Этого можно достичь двумя способами. Первый - это использование `create_with`:

```ruby
Client.create_with(locked: false).find_or_create_by(first_name: 'Andy')
```

Второй способ - это использование блока:

```ruby
Client.find_or_create_by(first_name: 'Andy') do |c|
  c.locked = false
end
```

Блок будет запущен только если клиент был создан. Во второй раз при запуске этого кода блок будет проигнорирован.

### `find_or_create_by!`

Можно также использовать `find_or_create_by!`, чтобы вызвать исключение, если новая запись невалидна. Валидации не раскрываются в этом руководстве, но давайте на момент предположим, что вы временно добавили

```ruby
validates :orders_count, presence: true
```

в модель `Client`. Если попытаетесь создать нового `Client` без передачи `orders_count`, запись будет невалидной и будет вызвано исключение:

```ruby
Client.find_or_create_by!(first_name: 'Andy')
# => ActiveRecord::RecordInvalid: Validation failed: Orders count can't be blank
```

### `find_or_initialize_by`

Метод `find_or_initialize_by` работает похоже на `find_or_create_by`, но он вызывает не `create`, а `new`. Это означает, что новый экземпляр модели будет создан в памяти, но не будет сохранен в базу данных. Продолжая пример с `find_or_create_by`, теперь мы хотим клиента по имени 'Nick':

```ruby
nick = Client.find_or_initialize_by(first_name: 'Nick')
# => <Client id: nil, first_name: "Nick", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">

nick.persisted?
# => false

nick.new_record?
# => true
```

Поскольку объект еще не сохранен в базу данных, создаваемый SQL выглядит так:

```sql
SELECT * FROM clients WHERE (clients.first_name = 'Nick') LIMIT 1
```

Когда захотите сохранить его в базу данных, просто вызовите `save`:

```ruby
nick.save
# => true
```
