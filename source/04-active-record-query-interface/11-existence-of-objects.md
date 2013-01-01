# Существование объектов

Если вы просто хотите проверить существование объекта, есть метод, называемый `exists?`. Этот метод запрашивает базу данных, используя тот же запрос, что и `find`, но вместо возврата объекта или коллекции объектов, он возвращает или `true`, или `false`.

```ruby
Client.exists?(1)
```

Метод `exists?` также принимает несколько id, при этом возвращает true, если хотя бы хотя бы одна запись из них существует.

```ruby
Client.exists?(1,2,3)
#или
Client.exists?([1,2,3])
```

Более того, `exists` принимает опцию `conditions` подобно этому:

```ruby
Client.where(first_name: 'Ryan').exists?
```

Даже возможно использовать `exists?` без аргументов:

```ruby
Client.exists?
```

Это возвратит `false`, если таблица `clients` пустая, и `true` в противном случае.

Для проверки на существование также можно использовать `any?` и `many?` на модели или relation.

```ruby
# на модели
Post.any?
Post.many?

# на именнованном скоупе
Post.recent.any?
Post.recent.many?

# на relation
Post.where(published: true).any?
Post.where(published: true).many?

# на связи
Post.first.categories.any?
Post.first.categories.many?
```
