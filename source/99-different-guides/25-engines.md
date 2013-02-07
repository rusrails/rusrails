# Engine для начинающих

В этом руководстве вы узнаете об engine-ах, и как они могут быть использованы для предоставления дополнительного функционала содержащим их приложениям с помощью понятного и простого для понимания интерфейса.

После прочтения этого руководства, вы узнаете:

* Зачем нужен engine.
* Как создать engine,
* Встроенные особенности engine.
* Внедрение engine в приложение.
* Переопределение функционала engine из приложения.

Что такое engine?
-----------------

Engine можно рассматривать как миниатюрное приложение, предоставляющее функционал содержащим их приложениям. Приложение Rails фактически всего лишь "прокачанный" engine с классом `Rails::Application`, унаследовавшим большую часть своего поведения от `Rails::Engine`.

Следовательно, об engine и приложении можно говорить как примерно об одном и том же, с небольшими различиями, как вы увидите в этом руководстве. Engine и приложение также используют одинаковую структуру.

Engine также близок к плагину, они оба имеют одинаковую структуру директории `lib` и оба создаются с помощью генератора `rails plugin new`. Разница в том, что engine рассматривается Rails как "full plugin", что указывается опцией `--full`, передаваемой в команду генератора, но во всем этом руководстве он называется просто "engine". Engine **может** быть плагином, а плагин **может** быть engine-ом.

Engine, который будет создан в этом руководстве, называется "blorgh". Engine предоставит функционал блога содержащим его приложениям, позволяя создавать новые публикации и комментарии. Сначала мы поработаем отдельно с самим engine, а потом посмотрим, как внедрить его в приложение.

Engine также может быть отделен от содержащих его приложений. Это означает, что приложение может иметь маршрутный хелпер, такой как `posts_path`, и использовать engine, также предоставляющий путь с именем `posts_path`, и они оба не будут конфликтовать. Наряду с этим, контроллеры, модели и имена таблиц также выделены в пространство имен. Вы узнаете, как это сделать, позже в этом руководстве.

Важно все время помнить, что приложение **всегда** должно иметь приоритет над его engine-ами. Приложение - это объект, имеющий последнее слово в том, что происходит во вселенной (под вселенной понимаем окружение приложения), в то время как engine должен только улучшать ее, но не изменять радикально.

Для демонстрации других engine-ов, посмотрите [Devise](https://github.com/plataformatec/devise), engine, предоставляющий аутентификацию для содержащих его приложиний, или [Forem](https://github.com/radar/forem), engine, представляюий функционал форума. Также имеется [Spree](https://github.com/spree/spree), предоставляющий платформу электронной коммерции, и [RefineryCMS](https://github.com/resolve/refinerycms), CMS engine.

Наконец, engine не был бы возможен без работы James Adam, Piotr Sarnacki, Rails Core Team, и ряда других людей. Если вы с ними встретитесь, не забудьте поблагодарить!

Создание engine
---------------

Чтобы создать engine, необходимо запустить генератор плагинов и передать ему подходящие для нужд опции. Для примера с "blorgh", нужно создать "монтируемый" engine, запустив в терминале эту команду:

```bash
$ rails plugin new blorgh --mountable
```

Можно просмотреть полный список опций для генератора плагина, написав:

```bash
$ rails plugin --help
```

Опция `--full` сообщает генератору, что вы хотите создать engine, включая скелет следующей структуры:

  * Дерево директории `app`
  * Файл `config/routes.rb`:

    ```ruby
    Rails.application.routes.draw do
    end
    ```

  * Файл `lib/blorgh/engine.rb`, идентичный по функции стандартному файлу приложения Rails `config/application.rb`:

    ```ruby
    module Blorgh
      class Engine < ::Rails::Engine
      end
    end
    ```

Опция `--mountable` сообщает генератору, что вы хотите создать "монтируемый" и изолированный в пространстве имен engine. Этот генератор предоставит тот же самый скелет структуры, как и опция `--full`, и добавит:

  * Файлы манифестов ресурсов (`application.js` и `application.css`)
  * Пустой `ApplicationController` в пространстве имен
  * Пустой `ApplicationHelper` в пространстве имен
  * Шаблон макета вьюхи для engine
  * Изоляцию в пространстве имен для `config/routes.rb`:

    ```ruby
    Blorgh::Engine.routes.draw do
    end
    ```

  * Изоляцию в пространстве имен для `lib/blorgh/engine.rb`:

    ```ruby
    module Blorgh
      class Engine < ::Rails::Engine
        isolate_namespace Blorgh
      end
    end
    ```

Кроме того, опция `--mountable` сообщает генератору смонтировать engine в пустом тестовом приложении, расположенном в `test/dummy`, поместив следующую строку в маршрутный файл пустого приложения `test/dummy/config/routes.rb`:

```ruby
mount Blorgh::Engine, at: "blorgh"
```

### Внутри engine

#### Критичные файлы

В корне директории нового engine есть файл `blorgh.gemspec`. Позже, когда вы будете включать engine в приложение, это нужно будет сделать с помощью следующей строчки в `Gemfile` приложения:

```ruby
gem 'blorgh', path: "vendor/engines/blorgh"
```

Если указать его как гем в `Gemfile`, Bundler так его и загрузит, спарсив файл `blorgh.gemspec`, и затребовав файл в директории `lib` по имени `lib/blorgh.rb`. Этот файл требует файл `blorgh/engine.rb` (расположенный в `lib/blorgh/engine.rb`) и определяет базовый модуль по имени `Blorgh`.

```ruby
require "blorgh/engine"

module Blorgh
end
```

TIP: В некоторых engine этот файл используется для размещения глобальных конфигурационных опций для engine. Это относительно хорошая идея, так что, если хотите предложить конфигурационные опции, файл, в котором определен `module` вашего engine, подходит для этого. Поместите методы в модуль и можно продолжать.

`lib/blorgh/engine.rb` это основной класс для engine:

```ruby
module Blorgh
  class Engine < Rails::Engine
    isolate_namespace Blorgh
  end
end
```

Унаследованный от класса `Rails::Engine`, этот гем информирует Rails, что по определенному пути есть engine, и должным образом монтирует engine  в приложение, выполняя задачи, такие как добавление директории `app` из engine к путям загрузки для моделей, рассыльщиков, контроллеров и вьюх.

Метод `isolate_namespace` заслуживает особого внимания. Этот вызов ответственен за изолирование контроллеров, моделей, маршрутов и прочего в их собственное пространство имен, подальше от подобных компонентов приложения. Без этого есть вероятность, что компоненты engine могут "просочиться" в приложение, вызвав нежелательные разрушения, или что важные компоненты engine могут быть переопределены таким же образом названными вещами в приложении. Один из примеров таких конфликтов - хелперы. Без вызова `isolate_namespace`, хелперы engine будут включены в контроллеры приложения.

NOTE: **Настойчиво** рекомендуется оставить строку `isolate_namespace` в определении класса `Engine`. Без этого созданные в engine классы **могут** конфликтовать с приложением.

Эта изоляция в пространство имен означает, что модель, созданная с помощью `rails g model`, например `rails g model post`, не будет называться `Post`, а будет помещена в пространство имен и названа `Blorgh::Post`. Кроме того, таблица для модели будет помещена в пространство имен, и станет `blorgh_posts`, а не просто `posts`. Подобно пространству имен моделей, контроллер с именем `PostsController` будет `Blorgh::Postscontroller`, и вьюхи для этого контроллера будут не в `app/views/posts`, а в `app/views/blorgh/posts`. Рассыльщики также помещены в пространство имен.

Наконец, маршруты также будут изолированы в engine. Это одна из наиболее важных частей относительно пространства имен, и будет обсуждена позже в разделе [Маршруты](#routes) этого руководства.

#### Директория `app`

В директории `app` имеются стандартные директории `assets`, `controllers`, `helpers`, `mailers`, `models` и `views`, с которыми вы уже знакомы по приложению. Директории `helpers`, `mailers` и `models` пустые, поэтому не описываются в этом разделе. Мы рассмотрим модели позже, когда будем писать engine.

В директории `app/assets` имеются директории `images`, `javascripts` и `stylesheets`, которые, опять же, должны быть знакомы по приложению. Имеется одно отличие - каждая директория содержит поддиректорию с именем engine-а. Поскольку этот engine будет помещен в пространство имен, его ресурсы также будут помещены.

В директории `app/controllers` имеется директория `blorgh`, и в ней есть файл с именем `application_controller.rb`. Этот файл предоставит любой общий функционал для контроллеров engine-а. Директория `blorgh` - то место, в котором будут другие контроллеры engine-а. Помещая их в этой директории, вы предотвращаете их от возможного конфликта с идентично названными контроллерами других engine-ов или даже приложения.

NOTE: Класс `ApplicationController` в engine называется так же, как и в приложении Rails, чтобы было проще преобразовать ваше приложение в engine.

Наконец, директория `app/views` содержит папку `layouts`, содержащую файл `blorgh/application.html.erb`, позволяющий определить макет для engine. Если этот engine будет использоваться как автономный, следует поместить любые настройки макета в этот файл, а не в файл `app/views/layouts/application.html.erb` приложения.

Если не хотите навязывать макет пользователям engine, удалите этот файл и ссылайтесь на другой макет в контроллерах вашего engine.

#### Директория `bin`

Эта директория содержит один файл, `bin/rails`, позволяющий использовать подкоманды и генераторы `rails`, как вы это делаете для приложения. Это означает, что очень просто создать новые контроллеры и модели для этого engine, запуская подобные команды:

```bash
rails g model
```

Помните, что все созданное с помощью этих команд в engine, имеющим `isolate_namespace` в классе `Engine`, будет помещено в пространство имен.

#### Директория `test`

В директории `test` будут тесты для engine. Для тестирования engine, там будет урезанная версия приложения Rails, вложенная в `test/dummy`. Это приложение смонтирует в файле `test/dummy/config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount Blorgh::Engine => "/blorgh"
end
```

Эта строка монтирует engine по пути `/blorgh`, что делает его доступным в приложении только по этому пути.

В директории test имеется директория `test/integration`, в которой должны быть расположены интеграционные тесты для engine. Также могут быть созданы иные директории в `test`. Для примера, можно создать директорию `test/models` для тестов ваших моделей.

Предоставляем функционал engine
-------------------------------

Engine, раскрываемый в этом руководстве, предоставляет функционал публикаций и комментирования и излагается подобно [Руководству по Rails для начинающих](/getting-started-with-rails), с некоторыми новыми особенностями.

### Создаем ресурс публикации

Первыми вещами для создания блога являются модель `Post` и соответствующий контроллер. Чтобы их создать быстро, воспользуемся генератором скаффолдов Rails.

```bash
$ rails generate scaffold post title:string text:text
```

Эта команда выведет такую информацию:

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_posts.rb
create    app/models/blorgh/post.rb
invoke    test_unit
create      test/models/blorgh/post_test.rb
create      test/fixtures/blorgh/posts.yml
 route  resources :posts
invoke  scaffold_controller
create    app/controllers/blorgh/posts_controller.rb
invoke    erb
create      app/views/blorgh/posts
create      app/views/blorgh/posts/index.html.erb
create      app/views/blorgh/posts/edit.html.erb
create      app/views/blorgh/posts/show.html.erb
create      app/views/blorgh/posts/new.html.erb
create      app/views/blorgh/posts/_form.html.erb
invoke    test_unit
create      test/controllers/blorgh/posts_controller_test.rb
invoke    helper
create      app/helpers/blorgh/posts_helper.rb
invoke      test_unit
create        test/helpers/blorgh/posts_helper_test.rb
invoke  assets
invoke    js
create      app/assets/javascripts/blorgh/posts.js
invoke    css
create      app/assets/stylesheets/blorgh/posts.css
invoke  css
create    app/assets/stylesheets/scaffold.css
```

Первое, что сделает генератор скаффолда, - это вызовет генератор `active_record`, который создаст миграцию и модель для ресурса. Отметьте, однако, что миграция называется `create_blorgh_posts` вместо обычной `create_posts`. Это благодаря методу `isolate_namespace`, вызванному в определении класса `Blorgh::Engine`. Модель также помещена в пространство имен, размещена в `app/models/blorgh/post.rb`, а не в `app/models/post.rb`, благодаря вызову `isolate_namespace` в классе `Engine`.

Далее для этой модели вызывается генератор `test_unit`, создающий тест модели в `test/models/blorgh/post_test.rb` (а не в `test/models/post_test.rb`) и фикстуру в `test/fixtures/blorgh/posts.yml` (а не в `test/fixtures/posts.yml`).

После этого для ресурса вставляется строка в в файл `config/routes.rb` engine-а. Эта строка - просто `resources :posts`, файл `config/routes.rb` engine-а стал таким:

```ruby
Blorgh::Engine.routes.draw do
  resources :posts
end
```

Отметьте, что маршруты отрисовываются в объекте `Blorgh::Engine`, а не в классе `YourApp::Application`. Это так, поскольку маршруты engine ограничены самим engine и могут быть смонтированы в определенной точке, как показано в разделе [Директория `test`](#test-directory). Это также вызывает то, что маршруты engine изолированы от маршрутов приложения. Разделе "Маршруты":#routes руководства описывает это подробнее.

Затем вызывается генератор `scaffold_controller`, создавая контроллер с именем `Blorgh::PostsController` (в `app/controllers/blorgh/posts_controller.rb`) и соответствующие вьюхи в `app/views/blorgh/posts`. Этот генератор также создает тест для контроллера (`test/controllers/blorgh/posts_controller_test.rb`) и хелпер (`app/helpers/blorgh/posts_controller.rb`).

Все, что этот генератор создает, аккуратно помещается в пространство имен. Класс контроллера определяется в модуле `Blorgh`:

```ruby
module Blorgh
  class PostsController < ApplicationController
    ...
  end
end
```

NOTE: Класс `ApplicationController`, от которого тут происходит наследование, является `Blorgh::ApplicationController`, а не `ApplicationController` приложения.

Хелпер в `app/helpers/blorgh/posts_helper.rb` также имеет пространство имен:

```ruby
module Blorgh
  class PostsHelper
    ...
  end
end
```

Это помогает предотвратить конфликты с любым другим engine или приложением, которые также могут иметь ресурс post.

Наконец, создаются два ресурсных файла, `app/assets/javascripts/blorgh/posts.js` и `app/assets/stylesheets/blorgh/posts.css`. Вы увидите, как их использовать немного позже.

По умолчанию стили скаффоллда не применяется в engine, поскольку файл макета engine, `app/views/layouts/blorgh/application.html.erb` не загружает его. Чтобы применить их, вставьте эту строку в тэг `<head>` этого макета:

```erb
<%= stylesheet_link_tag "scaffold" %>
```

Можно понаблюдать, что имеет engine на текущий момент, запустив `rake db:migrate` в корне нашего engine, чтобы запустить миграцию, созданную генератором скаффолда, а затем запустив `rails server` в `test/dummy`. Если открыть `http://localhost:3000/blorgh/posts`, можно увидеть созданный скаффолд по умолчанию. Покликайте! Вы только что создали первые функции вашего первого engine.

Также можно поиграть с консолью, `rails console` также будет работать, так же как и для приложения Rails. Помните: модель `Post` лежит в пространстве имен, поэтому, чтобы к ней обратиться, следует вызвать ее как `Blorgh::Post`.

```ruby
>> Blorgh::Post.find(1)
=> #<Blorgh::Post id: 1 ...>
```

Наконец нужно сделать так, чтобы ресурс `posts` этого engine был в корне engine. Когда кто-либо перейдет в корень пути, в котором смонтирован engine, ему должен быть показан перечень публикаций. Чтобы это произошло, следующая строчка должна быть вставлена в файл `config/routes.rb` в engine:

```ruby
root to: "posts#index"
```

Теперь пользователям нужно всего лишь перейти в корень engine, чтобы увидеть все публикации, без посещения `/posts`. Это означает, что вместо `http://localhost:3000/blorgh/posts`, теперь можно перейти на `http://localhost:3000/blorgh`.

### Создание ресурса комментариев

Теперь, когда engine может создавать новые публикации, необходимо добавить функционал комментирования. Для этого необходимо создать модель комментария, контроллер комментария и модифицировать скаффолд публикаций для отображения комментариев и позволения пользователям создавать новые.

Запустите генератор моделей и скажите ему создать модель `Comment` с соответствующей таблицей, имеющей два столбца: числовой `post_id` и текстовый `text`.

```bash
$ rails generate model Comment post_id:integer text:text
```

Это выдаст следующее:

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_comments.rb
create    app/models/blorgh/comment.rb
invoke    test_unit
create      test/models/blorgh/comment_test.rb
create      test/fixtures/blorgh/comments.yml
```

Вызов этого генератора создаст только необходимые для модели файлы, поместит их в пространство имен в директории `blorgh` и создаст класс модели по имени `Blorgh::Comment`.

Чтобы отображать комментарии на публикацию, отредактируйте `app/views/blorgh/posts/show.html.erb` и добавьте эту строку до ссылки "Edit":

```html+erb
<h3>Comments</h3>
<%= render @post.comments %>
```

Эта строчка требует, чтобы была связь `has_many` для  комментариев, определенная в модели `Blorgh::Post`, которой сейчас нет. Чтобы ее определить, откройте `app/models/blorgh/post.rb` и добавьте эту строку в модель:

```ruby
has_many :comments
```

Превратив модель в следующее:

```ruby
module Blorgh
  class Post < ActiveRecord::Base
    has_many :comments
  end
end
```

NOTE: Поскольку `has_many` определена в классе внутри модуля `Blorgh`, Rails знает, что вы хотите использовать модель `Blorgh::Comment` для этих объектов, поэтому тут нет необходимости указывать это с использованием опции `:class_name`.

Затем необходима форма для создания комментариев к публикации. Чтобы ее добавить, поместите эту строчку после вызова `render @post.comments` в `app/views/blorgh/posts/show.html.erb`:

```erb
<%= render "blorgh/comments/form" %>
```

Затем необходимо, чтобы существовал партиал, который рендерит эта строка. Создайте новую директорию `app/views/blorgh/comments` и в ней новый файл по имени `_form.html.erb`, содержащий следующий код для создания необходимого партиала:

```html+erb
<h3>New comment</h3>
<%= form_for [@post, @post.comments.build] do |f| %>
  <p>
    <%= f.label :text %><br />
    <%= f.text_area :text %>
  </p>
  <%= f.submit %>
<% end %>
```

При подтверждении этой формы, она попытается выполнить запрос `POST` по маршруту `/posts/:post_id/comments` в engine. Сейчас этот маршрут не существует, но может быть создан с помощью изменения строки `resources :posts` в `config/routes.rb` на эти строки:

```ruby
resources :posts do
  resources :comments
end
```

Это создаст вложенный маршрут для комментариев, что и требует форма.

Теперь маршрут существует, но контроллера, на который ведет маршрут, нет. Для его создания запустите команду:

```bash
$ rails g controller comments
```

Это создаст следующие вещи:

```
create  app/controllers/blorgh/comments_controller.rb
invoke  erb
 exist    app/views/blorgh/comments
invoke  test_unit
create    test/controllers/blorgh/comments_controller_test.rb
invoke  helper
create    app/helpers/blorgh/comments_helper.rb
invoke    test_unit
create      test/helpers/blorgh/comments_helper_test.rb
invoke  assets
invoke    js
create      app/assets/javascripts/blorgh/comments.js
invoke    css
create      app/assets/stylesheets/blorgh/comments.css
```

Форма сделает запрос `POST` к `/posts/:post_id/comments`, который связан с экшном `create` в `Blorgh::CommentsController`. Этот экшн нужно создать, поместив следующие строки в определение класса в `app/controllers/blorgh/comments_controller.rb`:

```ruby
def create
  @post = Post.find(params[:post_id])
  @comment = @post.comments.create(params[:comment])
  flash[:notice] = "Comment has been created!"
  redirect_to post_path
end
```

Это последняя часть, требуемая для работы формы нового комментария. Однако, отображение комментариев еще не закончено. Если создадите новый комментарий сейчас, то увидите эту ошибку:

```
Missing partial blorgh/comments/comment with {:handlers=>[:erb, :builder], :formats=>[:html], :locale=>[:en, :en]}. Searched in:
  * "/Users/ryan/Sites/side_projects/blorgh/test/dummy/app/views"
  * "/Users/ryan/Sites/side_projects/blorgh/app/views"
```

Engine не может найти партиал, требуемый для рендеринга комментариев. Rails сперва ищет его в директории приложения (`test/dummy`) `app/views`, а затем в директории engine `app/views`. Когда он не нашел его, выдал эту ошибку. Engine знает, что нужно искать в `blorgh/comments/comment`, поскольку объект модели, которую он получает, класса `Blorgh::Comment`.

Сейчас этот партиал будет ответственен за рендеринг только текста комментария. Создайте новый файл `app/views/blorgh/comments/_comment.html.erb` и поместите в него эту строку:

```erb
<%= comment_counter + 1 %>. <%= comment.text %>
```

Локальная переменная `comment_counter` дается нам вызовом `&lt;%= render @post.comments %&gt;`, она определяется автоматически, и счетчик увеличивается с итерацией для каждого комментария. Он используется в этом примере для отображения числа рядом с каждым созданным комментарием.

Мы завершили функцию комментирования у блогового engine. Теперь настало время использовать его в приложении.

Внедрение в приложение
----------------------

Использовать engine в приложении очень просто. Этот раздел раскрывает, как монтировать engine в приложение, требуемые начальные настройки, а также как присоединить engine к классу `User`, представленному приложением, для обеспечения принадлежности публикаций и комментариев в engine.

### Монтирование engine

Сначала необходимо определить engine в `Gemfile` приложения. Если у вас нет под рукой готового приложения для тестирования, создайте новое с использованием команды `rails new` вне директории engine:

```bash
$ rails new unicorn
```

Обычно определение engine в Gemfile выполняется как определение обычного повседневного гема.

```ruby
gem 'devise'
```

Однако, поскольку вы разрабатываете engine `blorgh` на своей локальной машине, необходимо указать опцию `:path` в `Gemfile`:

```ruby
gem 'blorgh', path: "/path/to/blorgh"
```

Как было сказано ранее, при помещении гема в `Gemfile`, он будет загружен вместе с Rails, сначала затребовав `lib/blorgh.rb` в engine, а затем `lib/blorgh/engine.rb`, который является файлом, определяющим основной функционал для engine.

Чтобы функционал engine был доступен в приложении, необходимо его смонтировать в файле `config/routes.rb` приложения:

```ruby
mount Blorgh::Engine, at: "/blog"
```

Эта строка смонтирует engine в `/blog` приложения. Сделав его доступным в `http://localhost:3000/blog`, когда приложение запущено с помощью `rails server`.

NOTE: Другие engine-ы, такие как Devise, управляют этим немного по другому, позволяя указывать в маршрутах свои хелперы, такие как `devise_for`. Эти хелперы делают примерно то же самое, монтируя части настраиваемого функционала engine на предопределенные пути.

### Настройка engine

Engine содержит миграции для таблиц `blorgh_posts` и `blorgh_comments`, которые необходимо создать в базе данных приложения, чтобы модели engine могли делать корректные запросы к ним. Чтобы скопировать эти миграции в приложение, используйте эту команду:

```bash
$ rake blorgh:install:migrations
```

Если имеется несколько engine-ов, из которых необходимо скопировать миграции, используйте `railties:install:migrations`:

```bash
$ rake railties:install:migrations
```

Эта команда при первом запуске скопирует все миграции из engine. При следующем запуске она скопирует лишь те миграции, которые еще не были скопированы. Первый запуск этой команды выдаст что-то подобное:

```bash
Copied migration [timestamp_1]_create_blorgh_posts.rb from blorgh
Copied migration [timestamp_2]_create_blorgh_comments.rb from blorgh
```

Первая временная метка (`[timestamp_1]`) будет текущим временем, а вторая временная метка (`[timestamp_2]`) будет текущим временем плюс секунда. Причиной для этого является то, что миграции для engine выполняются после всех существующих миграций приложения.

Для запуска этих миграций в контексте приложения просто выполните `rake db:migrate`. При входе в engine по адресу `http://localhost:3000/blog`, публикаций не будет, поскольку таблица, созданная в приложении, отличается от той, что была создана в engine. Сходите, поиграйте с только что смонтированным engine. Он точно такой же, как когда он был только engine-ом.

Если хотите выполнить миграции только от одного engine, можно определить `SCOPE`:

```bash
rake db:migrate SCOPE=blorgh
```

Это полезно, если хотите откатить миграции перед их удалением. Чтобы откатить все миграции от engine blorgh, следует запустить такой код:

```bash
rake db:migrate SCOPE=blorgh VERSION=0
```

### Использование класса, предоставленного приложением

#### Использование модели, предоставленной приложением

При создании engine, может возникнуть желание использовать определенные классы приложения для обеспечения связей между частями engine и частями приложения. В случае engine `blorgh` есть смысл в том, чтобы публикации и комментарии имели авторов.

Типичное приложении имеет класс `User`, предоставляющий авторов публикаций и комментариев. Но возможен случай, когда приложение называет этот класс по-другому, скажем `Person`. По этой причине engine не должен быть жестко связанным с классом `User`.

В нашем случае, для упрощения, в приложении будет класс с именем `User`, представляющий пользователей приложения. Он может быть создан с помощью этой команды в приложении:

```bash
rails g model user name:string
```

Далее должна быть запущена команда `rake db:migrate`, чтобы для дальнейшего использовании в приложении создалась таблица `users`.

Также для упрощения, в форме публикации будет новое текстовое поле с именем `author_name`, в которое пользователи смогут вписать свое имя. Затем engine примет это имя и создаст новый объект `User` для него, или найдет того, кто уже имеет такое имя, и свяжет с ним публикацию.

Сначала нужно добавить текстовое поле `author_name` в партиал `app/views/blorgh/posts/_form.html.erb` внутри engine. Добавьте этот код перед полем `title`:

```html+erb
<div class="field">
  <%= f.label :author_name %><br />
  <%= f.text_field :author_name %>
</div>
```

В модели `Blorgh::Post` должен быть некоторый код, преобразующий поле `author_name` в фактический объект `User` и привязывающий его как `author` публикации до того, как публикация будет сохранена. Это потребует настройки `attr_accessor` для этого поля, таким образом, для него будут определены методы сеттера и геттера.

Для этого необходимо добавить `attr_accessor` для `author_name`, связь для author и вызов `before_save` в `app/models/blorgh/post.rb`. Связь `author` будет пока что жестко завязана на класс `User`.

```ruby
attr_accessor :author_name
belongs_to :author, class_name: "User"

before_save :set_author

private
  def set_author
    self.author = User.find_or_create_by(name: author_name)
  end
```

Определение, что объект связи `author` представлен классом `User`, устанавливает связь между engine и приложением. Должен быть способ связывания записей в таблице `blorgh_posts` с записями в таблице `users`. Поскольку связь называется `author`, столбец `author_id` должен быть добавлен в таблицу `blorgh_posts`.

Для создания этого нового столбца запустите команду внутри engine:

```bash
$ rails g migration add_author_id_to_blorgh_posts author_id:integer
```

NOTE: Благодаря имени миграции и определению столбца после него, Rails автоматически узнает, что вы хотите добавить столбец в определенную таблицу и запишет это в миграцию. Вам не нужно больше ничего делать.

Нужно запустить эту миграцию в приложении. Для этого, сперва ее нужно скопировать с помощью команды:

```bash
$ rake blorgh:install:migrations
```

Отметьте, что сейчас будет скопирована только _одна_ миграция. Это так, потому что первые две миграции уже были скопированы при первом вызове этой команды.

```
NOTE Migration [timestamp]_create_blorgh_posts.rb from blorgh has been skipped. Migration with the same name already exists.
NOTE Migration [timestamp]_create_blorgh_comments.rb from blorgh has been skipped. Migration with the same name already exists.
Copied migration [timestamp]_add_author_id_to_blorgh_posts.rb from blorgh
```

Запустите эту миграцию с помощью команды:

```bash
$ rake db:migrate
```

Теперь, когда все на месте, в дальнейшем будет происходить связывание автора - представленного записью в таблице `users` - с публикацией, представленной таблицей `blorgh_posts` из engine.

Наконец, на странице публикации должно отображаться имя автора. Добавьте нижеследующий код над выводом "Title" в `app/views/blorgh/posts/show.html.erb`:

```html+erb
<p>
  <b>Author:</b>
  <%= @post.author %>
</p>
```

При выводе `@post.author` с использованием тега `&lt;%=` на объекте будет вызван метод `to_s`. По умолчанию он выдает нечто уродливое:

```
#<User:0x00000100ccb3b0>
```

Это не подходит, будет гораздо лучше, если бы тут было имя пользователя. Для этого добавьте метод `to_s` в класс `User` в приложении:

```ruby
def to_s
  name
end
```

Теперь вместо уродливого объекта Ruby будет отображено имя автора.

#### Использование контроллера, предоставленного приложением

Поскольку обычно контроллеры Rails имеют общий код для таких вещей, как переменные сессии для аутентификации и доступа, по умолчанию они наследуются от `ApplicationController`. Однако engine Rails помещен в пространство имен для запуска, независимого от основного приложения, поэтому каждый engine получает `ApplicationController` в своем пространстве имен. Это пространство имен предотвращает коллизии кода, но часто контроллеры engine должны получать доступ к методам `ApplicationController` основного приложения. Легче всего получить этот доступ, изменив `ApplicationController` в пространстве имен engine, унаследовав его от `ApplicationController` основного приложения. Для нашего Blorgh engine это может быть выполнено, изменив `app/controllers/blorgh/application_controller.rb` подобным образом:

```ruby
class Blorgh::ApplicationController < ApplicationController
end
```

По умолчанию контроллеры engine наследуются от `Blorgh::ApplicationController`. Поэтому после такого изменения они получат доступ к `ApplicationController` основного приложения, как будто они являются частью основного приложения.

Это изменение требует, чтобы engine запускался из приложения Rails, в котором имеется `ApplicationController`.

### Конфигурирование engine

Этот раздел раскрывает как сделать класс `User` конфигурируемым, а затем даны общие советы по конфигурированию engine.

#### Установка конфигурационных настроек в приложении

Следующим шагом нужно сделать настраиваемым для engine класс, представленный как `User` в приложении. Это потому, как объяснялось ранее, что этот класс не всегда будет `User`. Для этого у engine будет конфигурационная настройка по имени `user_class`, используемая для определения, какой класс представляет пользователей в приложении.

Для определения этой конфигурационной настройки следует использовать `mattr_accessor` в модуле `Blorgh`, расположенном в `lib/blorgh.rb` в engine. Внутри этого модуля поместите строку:

```ruby
mattr_accessor :user_class
```

Этот метод работает подобно его братьям `attr_accessor` и `cattr_accessor`, но предоставляет методы сеттера и геттера для модуля с определенным именем. Для его использования к нему следует обратиться с использованием `Blorgh.user_class`.

Следующим шагом является переключение модели `Blorgh::Post` на эту новую настройку. Связь `belongs_to` в этой модели (`app/models/blorgh/post.rb`), станет такой:

```ruby
belongs_to :author, class_name: Blorgh.user_class
```

Метод `set_author`, также расположенный в этом классе, должен тоже использовать тот класс:

```ruby
self.author = Blorgh.user_class.constantize.find_or_create_by(name: author_name)
```

Для предотвращения вызова `constantize` на `user_class` каждый раз, можно вместо этого переопределить метод геттера `user_class` внутри модуля `Blorgh` в файле `lib/blorgh.rb`, чтобы он всегда вызывал `constantize` на сохраненном значении до возврата значения:

```ruby
def self.user_class
  @@user_class.constantize
end
```

Это позволит изменить вышенаписанный код для `set_author` так:

```ruby
self.author = Blorgh.user_class.find_or_create_by(name: author_name)
```

Результат стал более коротким и более очевидным в своем поведении. Метод `user_class` должен всегда возвращать объект `Class`.

Чтобы установить эту конфигурационную настройку в приложении, следует использовать инициализатор. При использовании инициализатора, конфигурация установится до того, как запустится приложение и вызовутся модели engine-а, которые могут зависеть от существования этих конфигурационных настроек.

Создайте инициализатор `config/initializers/blorgh.rb` в приложении, в котором установлен engine `blorgh`, и поместите в него такое содержимое:

```ruby
Blorgh.user_class = "User"
```

WARNING: Тут важно использовать строковую версию класса, а не сам класс. Если использовать класс, Rails попытается загрузить этот класс и затем обратиться к соответствующей таблице, что приведет к проблемам, если таблица еще не существует. Следовательно, должна быть использована строка, а затем преобразована в класс с помощью `constantize` позже в engine.

Попытайтесь создать новую публикацию. Вы увидите, что все работает так же, как и прежде, за исключением того, что engine использует конфигурационную настройку в `config/initializers/blorgh.rb`, чтобы узнать, какой класс использовать.

Нет каких-либо строгих ограничений, каким должен быть класс, есть только каким должно быть API для класса. Engine просто требует, чтобы этот класс определял метод `find_or_create_by`, возвращающий объект этого класса для связи с публикацие при ее создании. Этот объект, разумеется, должен иметь некоторый идентификатор, по которому на него можно сослаться.

#### Конфигурация engine общего характера

Может случиться так, что вы захотите использовать для engine инициализаторы, интернационализацию или другие конфигурационные опции. Эти вещи вполне возможны, поскольку Rails engine имеет почти такой же функционал, как и приложение Rails. Фактически, функционал приложения Rails это супернадстройка над тем, что предоставляет engine!

Если хотите использовать инициализатор - код, который должен выполниться до загрузки engine - поместите его в папку `config/initializers`. Функционал этой директории объясняется в [разделе Инициализация](/configuring-rails-applications/initialization) руководства по конфигурированию, и работает обсолютно так же, как и директория `config/initializers` в приложении. То же самое касается стандартных инициализаторов.

Что касается локалей, просто поместите файлы локалей в директории `config/locales`, так же, как это делается в приложении.

Тестирование engine
-------------------

В созданном engine есть небольшое пустое приложение в `test/dummy`. Это приложение используется как точка монтирования для engine, чтобы максимально упростить тестирование engine. Это приложение можно расширить, сгенерировав контроллеры, модели или вьюхи из этой директории, и использовать их для тестирования своего engine.

Директорию `test` следует рассматривать как обычную среду тестирования Rails, допускающую юнит, функциональные и интеграционные тесты.

### Функциональные тесты

Следует принять во внимание при написании функциональных тестов, что тесты будут запущены для приложения - приложения `test/dummy` - а не для вашего engine. Это так благодаря настройке тестового окружения; engine нуждается в приложении, как хосту для тестирования его основного функционала, особенно контроллеров. Это означает, что если сделать обычный `GET` к контроллеру в функциональном тесте для контроллера:

```ruby
get :index
```

Он не будет работать правильно. Это так, поскольку приложение не знает, как направить эти запросы в engine, пока вы явно не скажете **как**. Для этого следует передать опцию `:use_route` (как параметр) этим запросам:

```ruby
get :index, use_route: :blorgh
```

Это сообщит приложению, что вы все еще хотите выполнить запрос `GET` к экшну `index` этого контроллера, но вы хотите использовать тут маршрут engine-а, а не приложения.

Улучшение функционала engine
----------------------------

Этот раздел объяснит, как добавить или переопределить MVC-функционал engine из основного приложения Rails.

### Переопределение моделей и контроллеров

Классы модели и контроллера engine могут быть расширены открытым изменением в основном приложении Rails (так как классы модели и контроллера являются всего лишь классами Ruby, наследующими специфичный функционал Rails). Открытое изменение класса Engine переопределяет его для использования в основном приложении. Это обычно реализуется с помощью паттерна декоратора.

Для простых изменений класса используйте `Class#class_eval`, а для сложных - рассмотрите использование `ActiveSupport::Concern`.

#### Реализация паттерна "Декоратор" с использованием Class#class_eval

**Добавление** `Post#time_since_created`,

```ruby
# MyApp/app/decorators/models/blorgh/post_decorator.rb

Blorgh::Post.class_eval do
  def time_since_created
    Time.current - created_at
  end
end
```

```ruby
# Blorgh/app/models/post.rb

class Post < ActiveRecord::Base
  has_many :comments
end
```

**Переопределение** `Post#summary`

```ruby
# MyApp/app/decorators/models/blorgh/post_decorator.rb

Blorgh::Post.class_eval do
  def summary
    "#{title} - #{truncate(text)}"
  end
end
```

```ruby
# Blorgh/app/models/post.rb

class Post < ActiveRecord::Base
  has_many :comments
  def summary
    "#{title}"
  end
end
```

#### Реализация паттерна "Декоратор" с использованием ActiveSupport::Concern

Использование `Class#class_eval` хорошо подходит для простых корректировок, но для более сложных изменений следует рассмотреть использование [`ActiveSupport::Concern`](http://edgeapi.rubyonrails.org/classes/ActiveSupport/Concern.html). `ActiveSupport::Concern` управляет порядком загрузки взаимосвязанных зависимостей во время выполнения, что позволяет существенно модулировать ваш код.

**Добавление** `Post#time_since_created` и **Переопределение** `Post#summary`

```ruby
# MyApp/app/models/blorgh/post.rb

class Blorgh::Post < ActiveRecord::Base
  include Blorgh::Concerns::Models::Post

  def time_since_created
    Time.current - created_at
  end

  def summary
    "#{title} - #{truncate(text)}"
  end
end
```

```ruby
# Blorgh/app/models/post.rb

class Post < ActiveRecord::Base
  include Blorgh::Concerns::Models::Post
end
```

```ruby
# Blorgh/lib/concerns/models/post

module Blorgh::Concerns::Models::Post
  extend ActiveSupport::Concern

  # 'included do' приводит к тому, что включенный код будет выполнен в
  # контексте того, где он подключен (post.rb), вместо того, чтобы быть
  # выполненным в контексте модуля (blorgh/concerns/models/post).
  included do
    attr_accessor :author_name
    belongs_to :author, class_name: "User"

    before_save :set_author

    private

      def set_author
        self.author = User.find_or_create_by(name: author_name)
      end
  end

  def summary
    "#{title}"
  end

  module ClassMethods
    def some_class_method
      'some class method string'
    end
  end
end
```

### Переопределение вьюх

Когда Rails ищет вьюху для рендеринга, он сперва смотрит в директорию `app/views` приложения. Если он не может найти там вьюху, он затем проверяет директории `app/views` всех engine-ов, имеющих эту директорию.

В engine `blorgh` сейчас имеется файл `app/views/blorgh/posts/index.html.erb`. Когда engine хочет отрендерить вьюху для экшна `index` в `Blorgh::PostsController`, он сперва пытается ее найти в `app/views/blorgh/posts/index.html.erb` приложения, и если не сможет, то ищет внутри engine.

Можно переопределить эту вьюху в приложении, просто создав файл `app/views/blorgh/posts/index.html.erb`. Можно полностью изменить то, что эта вьюха должна обычно выводить.

Попробуйте так сделать, создав новый файл `app/views/blorgh/posts/index.html.erb` и поместив в него:

```html+erb
<h1>Posts</h1>
<%= link_to "New Post", new_post_path %>
<% @posts.each do |post| %>
  <h2><%= post.title %></h2>
  <small>By <%= post.author %></small>
  <%= simple_format(post.text) %>
  <hr>
<% end %>
```

### Маршруты

По умолчанию маршруты в engine изолированы от приложения. Это выполняется с помощью вызова `isolate_namespace` в классе `Engine`. По сути это означает, что приложение и его engine-ы могут иметь одинаково названные маршруты, и не будет никакого конфликта.

Маршруты в engine отрисовываются в классе `Engine` в `config/routes.rb`, подобно:

```ruby
Blorgh::Engine.routes.draw do
  resources :posts
end
```

Имея подобные изолированные маршруты, если захотите сослаться на часть engine из приложения, необходимо воспользоваться прокси методом маршрутов engine. Вызов обычных маршрутных методов, таких как `posts_path`, может привести в нежелательное место, если и приложение, и engine определяют такой хелпер.

Ссылка в следующем примере приведет на `posts_path` приложения, если шаблон был отрендерен из приложения, или на `posts_path` engine-а, если был отрендерен в engine:

```erb
<%= link_to "Blog posts", posts_path %>
```

Чтобы этот маршрут всегда использовал маршрутный метод хелпера `posts_path` engine-а, необходимо вызвать метод на маршрутном прокси методе, имеющем то же имя, что и engine.

```erb
<%= link_to "Blog posts", blorgh.posts_path %>
```

Можно обратиться к приложению из engine подобным образом, используя хелпер `main_app`:

```erb
<%= link_to "Home", main_app.root_path %>
```

Если это использовать в  engine, он **всегда** будет вести на корень приложения. Если опустить вызов метода "маршрутного прокси" `main_app`, он потенциально может вести на корень engine или приложения, в зависимости от того, где был вызван.

Если шаблон рендерится из engine и пытается использовать один из методов маршрутного хелпера приложения, это может привести к вызову неопределенного метода. Если вы с этим столкнулись, убедитесь, что не пытаетесь вызвать из engine маршрутный метод приложения без префикса `main_app`.

### Ресурсы (assets)

Ресурсы в engine работают так же, как и в полноценном приложении. Поскольку класс engine наследуется от `Rails::Engine`, приложение будет знать, что следует смотреть в директории engine `app/assets` и `lib/assets` в поиске потенциальных ресурсов.

Подобно остальным компонентам engine, ресурсы также будут помещены в пространство имен. Это означает, что если имеется ресурс по имени `style.css`, он должен быть помещен в `app/assets/stylesheets/[engine name]/style.css`, а не в `app/assets/stylesheets/style.css`. Если этот ресурс не будет помещен в пространство имен, то есть вероятность, что в приложении есть идентично названный ресурс, в этом случае ресурс приложения будет иметь преимущество, а ресурс в engine будет проигнорирован.

Представим, что у вас есть ресурс `app/assets/stylesheets/blorgh/style.css` Чтобы включить его в приложение, используйте `stylesheet_link_tag` и сошлитесь на ресурс так, как он находится в engine:

```erb
<%= stylesheet_link_tag "blorgh/style.css" %>
```

Также можно определить эти ресурсы как зависимости для других ресурсов, используя выражения Asset Pipeline в обрабатываемых файлах:

```
/*
 *= require blorgh/style
*/
```

INFO. Помните, что для использования языков, таких как Sass или CoffeeScript, следует подключить соответствующую библиотеку в `.gemspec` вашего engine.

### Отдельные ресурсы и прекомпиляция

Бывают ситуации, когда ресурсы engine не требуются приложению. Например, скажем, вы создали административный функционал, существующий только для engine. В этом случае приложению не нужно требовать `admin.css` или `admin.js`. Только административному макету гема необходимы эти ресурсы. Нет смысла, чтобы приложение включало `"blorg/admin.css"` в свои таблицы стилей. В такой ситуации следут явно определить эти ресурсы для прекомпиляции.
Это сообщит sprockets добавить ресурсы engine при запуске `rake assets:precompile`.

Ресурсы для прекомпиляции можно определить в `engine.rb`

```ruby
initializer "blorgh.assets.precompile" do |app|
  app.config.assets.precompile `= %w(admin.css admin.js)
end
```

Более подробно читайте в [руководстве по Asset Pipeline](/asset-pipeline)

### Зависимости от других гемов

Зависимости от гемов в engine должны быть определены в файле `.gemspec` в корне engine. Причиной для этого является то, что engine может быть установлен как гем. Если определить зависимости в `Gemfile`, они могут быть не распознаны при традиционной установке гема, и быть не установленными, вызвав неработоспособность engine.

Для определения зависимости, которая должна быть установлена вместе с engine во время традиционного `gem install`, определите ее в блоке `Gem::Specification` в файле `.gemspec` в engine:

```ruby
s.add_dependency "moo"
```

Для определения зависимости, которая должна быть установлена только при разработке приложения, определите это так:

```ruby
s.add_development_dependency "moo"
```

Оба типа зависимостей будут установлены при запуске `bundle install`  внутри приложения. Зависимости development для гема будут использованы только когда будут запущены тесты для engine.

Отметьте, что если вы захотите немедленно затребовать зависимости при затребовании engine, следует их затрбовать до инициализации engine. Например:

```ruby
require 'other_engine/engine'
require 'yet_another_engine/engine'

module MyEngine
  class Engine < ::Rails::Engine
  end
end
```
