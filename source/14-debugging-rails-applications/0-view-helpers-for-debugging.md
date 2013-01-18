# Хелперы вьюхи для отладки

Одной из обычных задач является проверить содержимое переменной. В Rails это можно сделать тремя методами:

* `debug`
* `to_yaml`
* `inspect`

### `debug`

Хелпер `debug` возвратит тег \<pre>, который рендерит объект, с использованием формата YAML. Это создаст читаемые данные из объекта. Например, если у вас такой код во вьюхе:

```html+erb
<%= debug @post %>
<p>
  <b>Title:</b>
  <%= @post.title %>
</p>
```

Вы получите что-то наподобие этого:

```yaml
--- !ruby/object:Post
attributes:
  updated_at: 2008-09-05 22:55:47
  body: It's a very helpful guide for debugging your Rails app.
  title: Rails debugging guide
  published: t
  id: "1"
  created_at: 2008-09-05 22:55:47
attributes_cache: {}


Title: Rails debugging guide
```

### `to_yaml`

Отображение переменной экземпляра или любого другого объекта или метода в формате yaml может быть достигнуто следующим образом:

```html+erb
<%= simple_format @post.to_yaml %>
<p>
  <b>Title:</b>
  <%= @post.title %>
</p>
```

Метод `to_yaml` преобразует метод в формат YAML, оставив его более читаемым, а затем используется хелпер `simple_format` для рендера каждой строки как в консоли. Именно так и работает метод `debug`.

В результате получится что-то вроде этого во вашей вьюхе:

```yaml
--- !ruby/object:Post
attributes:
updated_at: 2008-09-05 22:55:47
body: It's a very helpful guide for debugging your Rails app.
title: Rails debugging guide
published: t
id: "1"
created_at: 2008-09-05 22:55:47
attributes_cache: {}

Title: Rails debugging guide
```

### `inspect`

Другим полезным методом для отображения значений объекта является `inspect`, особенно при работе с массивами и хэшами. Он напечатает значение объекта как строку. Например:

```html+erb
<%= [1, 2, 3, 4, 5].inspect %>
<p>
  <b>Title:</b>
  <%= @post.title %>
</p>
```

Отрендерит следующее:

```
[1, 2, 3, 4, 5]

Title: Rails debugging guide
```
