# Рефакторинг

Теперь, когда у нас есть работающие публикации и комментарии, взглянем на шаблон `app/views/posts/show.html.erb`. Он стал длинным и неудобным. Давайте воспользуемся партиалами, чтобы разгрузить его.

### Рендеринг коллекций партиалов

Сначала сделаем партиал для комментариев, показывающий все комментарии для публикации. Создайте файл `app/views/comments/_comment.html.erb` и поместите в него следующее:

```html+erb
<p>
  <strong>Commenter:</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>Comment:</strong>
  <%= comment.body %>
</p>
```

Затем можно изменить `app/views/posts/show.html.erb` вот так:

```html+erb
<p>
  <strong>Title:</strong>
  <%= @post.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @post.text %>
</p>

<h2>Comments</h2>
<%= render @post.comments %>

<h2>Add a comment:</h2>
<%= form_for([@post, @post.comments.build]) do |f| %>
  <p>
    <%= f.label :commenter %><br />
    <%= f.text_field :commenter %>
  </p>
  <p>
    <%= f.label :body %><br />
    <%= f.text_area :body %>
  </p>
  <p>
    <%= f.submit %>
  </p>
<% end %>

<%= link_to 'Edit Post', edit_post_path(@post) %> |
<%= link_to 'Back to Posts', posts_path %>
```

Теперь это отрендерит партиал `app/views/comments/_comment.html.erb` по разу для каждого комментария в коллекции `@post.comments`. Так как метод `render` перебирает коллекцию `@post.comments`, он назначает каждый комментарий локальной переменной с именем, как у партиала, в нашем случае `comment`, которая нам доступна в партиале для отображения.

### Рендеринг партиальной формы

Давайте также переместим раздел нового коментария в свой партиал. Опять же, создайте файл `app/views/comments/_form.html.erb`, содержащий:

```html+erb
<%= form_for([@post, @post.comments.build]) do |f| %>
  <p>
    <%= f.label :commenter %><br />
    <%= f.text_field :commenter %>
  </p>
  <p>
    <%= f.label :body %><br />
    <%= f.text_area :body %>
  </p>
  <p>
    <%= f.submit %>
  </p>
<% end %>
```

Затем измените `app/views/posts/show.html.erb` следующим образом:

```html+erb
<p>
  <strong>Title:</strong>
  <%= @post.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @post.text %>
</p>

<h2>Add a comment:</h2>
<%= render "comments/form" %>

<%= link_to 'Edit Post', edit_post_path(@post) %> |
<%= link_to 'Back to Posts', posts_path %>
```

Второй render всего лишь определяет шаблон партиала, который мы хотим рендерить, `comments/form`. Rails достаточно сообразительный, чтобы подставить подчеркивание в эту строку и понять, что Вы хотели рендерить файл `_form.html.erb` в директории `app/views/comments`.

Объект `@post` доступен в любых партиалах, рендерируемых во вьюхе, так как мы определили его как переменную экземпляра.
