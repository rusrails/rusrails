# Соединительные таблицы

Active Record предоставляет метод поиска с именем `joins` для определения условия `JOIN` в результирующем SQL. Есть разные способы определить метод `joins`:

### Использование строчного фрагмента SQL

Можете просто дать чистый SQL, определяющий условие `JOIN` в `joins`.

```ruby
Client.joins('LEFT OUTER JOIN addresses ON addresses.client_id = clients.id')
```

Это приведет к следующему SQL:

```sql
SELECT clients.* FROM clients LEFT OUTER JOIN addresses ON addresses.client_id = clients.id
```

### Использование массива/хэша именнованных связей

WARNING: Этот метод работает только с `INNER JOIN`.

Active Record позволяет использовать имена "связей":/active-record-associations, определенных в модели, как ярлыки для определения условия `JOIN` этих связей при использовании метода `joins`.

Например, рассмотрим следующие модели `Category`, `Post`, `Comments` и `Guest`:

```ruby
class Category < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :category
  has_many :comments
  has_many :tags
end

class Comment < ActiveRecord::Base
  belongs_to :post
  has_one :guest
end

class Guest < ActiveRecord::Base
  belongs_to :comment
end

class Tag < ActiveRecord::Base
  belongs_to :post
end
```

Сейчас все нижеследующее создаст ожидаемые соединительные запросы с использованием `INNER JOIN`:

#### Соединение одиночной связи

```ruby
Category.joins(:posts)
```

Это создаст:

```sql
SELECT categories.* FROM categories
  INNER JOIN posts ON posts.category_id = categories.id
```

Или, по-русски, "возвратить объект Category для всех категорий с публикациями". Отметьте, что будут дублирующиеся категории, если имеется более одной публикации в одной категории. Если нужны уникальные категории, можно использовать `Category.joins(:posts).select("distinct(categories.id)")`.

#### Соединение нескольких связей

```ruby
Post.joins(:category, :comments)
```

Это создаст:

```sql
SELECT posts.* FROM posts
  INNER JOIN categories ON posts.category_id = categories.id
  INNER JOIN comments ON comments.post_id = posts.id
```

Или, по-русски, "возвратить все публикации, у которых есть категория и как минимум один комментарий". Отметьте, что публикации с несколькими комментариями будут показаны несколько раз.

#### Соединение вложенных связей (одного уровня)

```ruby
Post.joins(:comments => :guest)
```

Это создаст:

```sql
SELECT posts.* FROM posts
  INNER JOIN comments ON comments.post_id = posts.id
  INNER JOIN guests ON guests.comment_id = comments.id
```

Или, по-русски, "возвратить все публикации, имеющие комментарий, сделанный гостем".

#### Соединение вложенных связей (разных уровней)

```ruby
Category.joins(:posts => [{:comments => :guest}, :tags])
```

Это создаст:

```sql
SELECT categories.* FROM categories
  INNER JOIN posts ON posts.category_id = categories.id
  INNER JOIN comments ON comments.post_id = posts.id
  INNER JOIN guests ON guests.comment_id = comments.id
  INNER JOIN tags ON tags.post_id = posts.id
```

### Определение условий в соединительных таблицах

В соединительных таблицах можно определить условия, используя надлежащие [массивные](/active-record-query-interface/conditions#array-conditions) и [строчные](/active-record-query-interface/conditions#pure-string-conditions) условия. [Условия с использованием хэша](/active-record-query-interface/conditions#hash-conditions) предоставляют специальный синтаксис для определения условий в соединительных таблицах:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Client.joins(:orders).where('orders.created_at' => time_range)
```

Альтернативный и более чистый синтаксис для этого - вложенные хэш-условия:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Client.joins(:orders).where(:orders => {:created_at => time_range})
```

Будут найдены все клиенты, имеющие созданные вчера заказы, снова используя выражение SQL `BETWEEN`.
