# Безопасность

Если вы опубликуете свой блог онлайн, любой сможет добавлять, редактировать и удалять публикации или удалять комментарии.

Rails предоставляет очень простую аутентификационную систему HTTP, которая хорошо работает в этой ситуации.

В `PostsController` нам нужен способ блокировать доступ к различным экшнам, если пользователь не аутентифицирован, тут мы можем использовать метод Rails `http_basic_authenticate_with`, разрешающий доступ к требуемым экшнам, если метод позволит это.

Чтобы использовать систему аутентификации, мы определим ее вверху нашего `PostsController`, в нашем случае, мы хотим, чтобы пользователь был аутентифицирован для каждого экшна, кроме `index` и `show`, поэтому напишем так в `app/controllers/posts_controller.rb`:

```ruby
class PostsController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", except: [:index, :show]

  def index
    @posts = Post.all
  end

  # пропущено для краткости
```

Мы также хотим позволить только аутентифицированным пользователям удалять комментарии, поэтому в `CommentsController` (`app/controllers/comments_controller.rb`) мы напишем:

```ruby
class CommentsController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", only: :destroy

  def create
    @post = Post.find(params[:post_id])
  end

  # пропущено для краткости
```

Теперь, если попытаетесь создать новую публикацию, то встретитесь с простым вызовом аутентификации HTTP

![Простой вызов аутентификации HTTP](/assets/guides/challenge.png)
