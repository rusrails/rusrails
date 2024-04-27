Engine для начинающих
=====================

В этом руководстве вы узнаете об engine, и как они могут быть использованы для предоставления дополнительной функциональности содержащим их приложениям с помощью понятного и простого для понимания интерфейса.

После прочтения этого руководства, вы узнаете:

* Зачем нужен engine.
* Как создать engine.
* Как встраивать особенности в engine.
* Как внедрять engine в приложение.
* Как переопределить функциональность engine из приложения.
* Как избежать загрузки фреймворков Rails с помощью хуков для загрузки и настройки.

Что такое engine?
-----------------

Engine можно рассматривать как миниатюрное приложение, предоставляющее функциональность содержащим его приложениям. Приложение Rails фактически всего лишь "прокачанный" engine с классом `Rails::Application`, унаследовавшим большую часть своего поведения от `Rails::Engine`.

Следовательно, об engine и приложении можно говорить как примерно об одном и том же, с небольшими различиями, как вы увидите в этом руководстве. Engine и приложение также используют одинаковую структуру.

Engine также близок к плагину, они оба имеют одинаковую структуру директории `lib` и оба создаются с помощью генератора `rails plugin new`. Разница в том, что engine рассматривается Rails как "full plugin" (на что указывает опция `--full`, передаваемая в команду генератора). Фактически, тут мы будем использовать опцию `--mountable`, включающую все особенности `--full` и кое-что еще. Впрочем, в этом руководстве эти "full plugins" будут называться просто "engine". Engine **может** быть плагином, а плагин **может** быть engine.

Engine, который будет создан в этом руководстве, называется "blorgh". Этот engine предоставит функциональность блога содержащим его приложениям, позволяя создавать новые статьи и комментарии. В начале этого руководства мы поработаем отдельно с самим engine, но в последующих разделах посмотрим, как внедрить его в приложение.

Engine также может быть отделен от содержащих его приложений. Это означает, что приложение может иметь маршрутный хелпер, такой как `articles_path`, и использовать engine, также предоставляющий путь с именем `articles_path`, и они оба не будут конфликтовать. Наряду с этим, контроллеры, модели и имена таблиц также выделены в пространство имен. Вы узнаете, как это сделать, позже в этом руководстве.

Важно все время помнить, что приложение **всегда** должно иметь приоритет над его engine. Приложение - это объект, имеющий последнее слово в том, что происходит в его среде. Engine должен только улучшать ее, но не изменять радикально.

Для демонстрации других engine, смотрите [Devise](https://github.com/plataformatec/devise), engine, предоставляющий аутентификацию для содержащих его приложений, или [Thredded](https://github.com/thredded/thredded), engine, предоставляющий функциональность форума. Также имеется [Spree](https://github.com/spree/spree), предоставляющий платформу электронной коммерции, и [Refinery CMS](https://github.com/refinery/refinerycms), CMS engine.

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

Опция `--mountable` сообщает генератору, что вы хотите создать "монтируемый" и изолированный engine. Этот генератор предоставляет ту же структуру скелета, как и с опцией `--full`. Опция `--full` сообщает генератору, что вы хотите создать engine, включая скелет следующей структуры:

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

Опция `--mountable` добавит к опции `--full`:

  * Файлы манифестов ресурсов (`blorgh_manifest.js` и `application.css`)
  * Пустой `ApplicationController` в пространстве имен
  * Пустой `ApplicationHelper` в пространстве имен
  * Шаблон макета вью для engine
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
mount Blorgh::Engine => "/blorgh"
```

### Внутри Engine

#### Критичные файлы

В корне директории нового engine есть файл `blorgh.gemspec`. Позже, когда вы будете включать engine в приложение, это нужно будет сделать с помощью следующей строчки в `Gemfile` приложения:

```ruby
gem "blorgh", path: "engines/blorgh"
```

Не забудьте запустить `bundle install`, как обычно. Если указать его как гем в `Gemfile`, Bundler так его и загрузит, спарсив файл `blorgh.gemspec`, и затребовав файл в директории `lib` по имени `lib/blorgh.rb`. Этот файл требует файл `blorgh/engine.rb` (расположенный в `lib/blorgh/engine.rb`) и определяет базовый модуль по имени `Blorgh`.

```ruby
require "blorgh/engine"

module Blorgh
end
```

TIP: В некоторых engine этот файл используется для размещения глобальных конфигурационных опций для engine. Это относительно хорошая идея, так что, если хотите предложить конфигурационные опции, файл, в котором определен `module` вашего engine, подходит для этого. Поместите методы в модуль и можно продолжать.

`lib/blorgh/engine.rb` это основной класс для engine:

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

Унаследованный от класса `Rails::Engine`, этот гем информирует Rails, что по определенному пути есть engine, и должным образом монтирует engine в приложение, выполняя задачи, такие как добавление директории `app` из engine к путям загрузки для моделей, рассыльщиков, контроллеров и вью.

Метод `isolate_namespace` заслуживает особого внимания. Этот вызов ответственен за изолирование контроллеров, моделей, маршрутов и прочего в их собственное пространство имен, подальше от подобных компонентов приложения. Без этого есть вероятность, что компоненты engine могут "просочиться" в приложение, вызвав нежелательные разрушения, или что важные компоненты engine могут быть переопределены таким же образом названными вещами в приложении. Один из примеров таких конфликтов - хелперы. Без вызова `isolate_namespace`, хелперы engine будут включены в контроллеры приложения.

NOTE: **Настойчиво** рекомендуется оставить строчку `isolate_namespace` в определении класса `Engine`. Без этого созданные в engine классы **могут** конфликтовать с приложением.

Эта изоляция в пространство имен означает, что модель, созданная с помощью `bin/rails g model`, например `bin/rails g model article`, не будет называться `Article`, а будет помещена в пространство имен и названа `Blorgh::Article`. Кроме того, таблица для модели будет помещена в пространство имен, и станет `blorgh_articles`, а не просто `articles`. Подобно пространству имен моделей, контроллер с именем `ArticlesController` будет `Blorgh::ArticlesController`, и вью для этого контроллера будут не в `app/views/articles`, а в `app/views/blorgh/articles`. Рассыльщики, задания и хелперы также помещены в пространство имен.

Наконец, маршруты также будут изолированы в engine. Это одна из наиболее важных частей относительно пространства имен, и будет обсуждена позже в разделе [Маршруты](#routes) этого руководства.

#### Директория `app`

В директории `app` имеются стандартные директории `assets`, `controllers`, `helpers`, `jobs`, `mailers`, `models` и `views`, с которыми вы уже знакомы по приложению. Мы рассмотрим модели в следующем разделе, когда будем писать engine.

В директории `app/assets` имеются директории `images` и `stylesheets`, которые, опять же, должны быть знакомы по приложению. Имеется одно отличие - каждая директория содержит поддиректорию с именем engine. Поскольку этот engine будет помещен в пространство имен, его ресурсы также будут помещены.

В директории `app/controllers` имеется директория `blorgh`, содержащая файл с именем `application_controller.rb`. Этот файл предоставит любую общую функциональность для контроллеров engine. Директория `blorgh` - то место, в котором будут другие контроллеры engine. Помещая их в этой директории, вы предотвращаете их от возможного конфликта с идентично названными контроллерами других engine или даже приложения.

NOTE: Класс `ApplicationController` в engine называется так же, как и в приложении Rails, чтобы было проще преобразовать ваше приложение в engine.

Так же, как и для `app/controllers`, вы обнаружите поддиректорию `blorgh` в директориях `app/helpers`, `app/jobs`, `app/mailers` и `app/models`, содержащую связанный файл `application_*.rb` для размещения общего функционала. Помещая свои файлы в эту директорию и пространство имен, вы предотвращаете их от возможного пересечения с идентично названными элементами других engine или даже приложения.

Наконец, директория `app/views` содержит папку `layouts`, содержащую файл `blorgh/application.html.erb`. Этот файл позволяет определить макет для engine. Если этот engine будет использоваться как автономный, следует поместить любые настройки макета в этот файл, а не в файл `app/views/layouts/application.html.erb` приложения.

Если не хотите навязывать макет пользователям engine, удалите этот файл и ссылайтесь на другой макет в контроллерах вашего engine.

#### Директория `bin`

Эта директория содержит один файл, `bin/rails`, позволяющий использовать подкоманды и генераторы `rails`, как вы это делаете для приложения. Это означает, что можно создать новые контроллеры и модели для этого engine, просто запуская подобные команды:

```bash
$ bin/rails generate model
```

Помните, что все созданное с помощью этих команд в engine, имеющим `isolate_namespace` в классе `Engine`, будет помещено в пространство имен.

#### (test-directory) Директория `test`

В директории `test` будут тесты для engine. Для тестирования engine, там будет урезанная версия приложения Rails, вложенная в `test/dummy`. Это приложение смонтирует в файле `test/dummy/config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount Blorgh::Engine => "/blorgh"
end
```

Эта строчка монтирует engine по пути `/blorgh`, что делает его доступным в приложении только по этому пути.

В директории test имеется директория `test/integration`, в которой должны быть расположены интеграционные тесты для engine. Также могут быть созданы иные директории в `test`. Для примера, можно создать директорию `test/models` для тестов ваших моделей.

Предоставляем функциональность engine
-------------------------------------

Engine, раскрываемый в этом руководстве, предоставляет функциональность отправки статей и комментирования, и излагается подобно в руководстве [Rails для начинающих](/getting-started), с некоторыми новыми особенностями.

NOTE: Для этого раздела убедитесь, что запускаете команды в корне директории engine `blorgh`.

### Создаем ресурс Article

Первыми вещами для создания блога являются модель `Article` и соответствующий контроллер. Чтобы их создать быстро, воспользуемся генератором скаффолдов Rails.

```bash
$ bin/rails generate scaffold article title:string text:text
```

Эта команда выведет такую информацию:

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_articles.rb
create    app/models/blorgh/article.rb
invoke    test_unit
create      test/models/blorgh/article_test.rb
create      test/fixtures/blorgh/articles.yml
invoke  resource_route
 route    resources :articles
invoke  scaffold_controller
create    app/controllers/blorgh/articles_controller.rb
invoke    erb
create      app/views/blorgh/articles
create      app/views/blorgh/articles/index.html.erb
create      app/views/blorgh/articles/edit.html.erb
create      app/views/blorgh/articles/show.html.erb
create      app/views/blorgh/articles/new.html.erb
create      app/views/blorgh/articles/_form.html.erb
create      app/views/blorgh/articles/_article.html.erb
invoke    resource_route
invoke    test_unit
create      test/controllers/blorgh/articles_controller_test.rb
create      test/system/blorgh/articles_test.rb
invoke    helper
create      app/helpers/blorgh/articles_helper.rb
invoke      test_unit
```

Первое, что сделает генератор скаффолда, - это вызовет генератор `active_record`, который создаст миграцию и модель для ресурса. Отметьте, однако, что миграция называется `create_blorgh_articles` вместо обычной `create_articles`. Это происходит благодаря методу `isolate_namespace`, вызванному в определении класса `Blorgh::Engine`. Модель также помещена в пространство имен, размещена в `app/models/blorgh/article.rb`, а не в `app/models/article.rb`, благодаря вызову `isolate_namespace` в классе `Engine`.

Далее для этой модели вызывается генератор `test_unit`, создающий тест модели в `test/models/blorgh/article_test.rb` (а не в `test/models/article_test.rb`) и фикстуру в `test/fixtures/blorgh/articles.yml` (а не в `test/fixtures/articles.yml`).

После этого для ресурса вставляется строчка в файл `config/routes.rb` engine. Эта строчка - просто `resources :articles`, файл `config/routes.rb` engine стал таким:

```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

Отметьте, что маршруты отрисовываются в объекте `Blorgh::Engine`, а не в классе `YourApp::Application`. Это так, поскольку маршруты engine ограничены самим engine и могут быть смонтированы в определенной точке, как показано в разделе [Директория `test`](#test-directory). Также по этой причине маршруты engine изолированы от маршрутов приложения. Раздел [Маршруты](#routes) руководства описывает это подробнее.

Затем вызывается генератор `scaffold_controller`, создавая контроллер с именем `Blorgh::ArticlesController` (в `app/controllers/blorgh/articles_controller.rb`) и соответствующие вью в `app/views/blorgh/articles`. Этот генератор также создает тесты для контроллера (`test/controllers/blorgh/articles_controller_test.rb` и `test/system/blorgh/articles_test.rb`) и хелпер (`app/helpers/blorgh/articles_helper.rb`).

Все, что этот генератор создает, аккуратно помещается в пространство имен. Класс контроллера определяется в модуле `Blorgh`:

```ruby
module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

NOTE: Класс `ArticlesController` наследуется от `Blorgh::ApplicationController`, а не от `ApplicationController` приложения.

Хелпер в `app/helpers/blorgh/articles_helper.rb` также имеет пространство имен:

```ruby
module Blorgh
  module ArticlesHelper
    # ...
  end
end
```

Это помогает предотвратить конфликты с любым другим engine или приложением, которые также могут иметь ресурс article.

Можно понаблюдать, что имеет engine на текущий момент, запустив `bin/rails db:migrate` в корне нашего engine, чтобы запустить миграцию, созданную генератором скаффолда, а затем запустив `bin/rails server` в `test/dummy`. Если открыть `http://localhost:3000/blorgh/articles`, можно увидеть созданный скаффолд по умолчанию. Проверьте! Вы только что создали первые функции вашего первого engine.

Также можно поиграть с консолью, `bin/rails console` будет работать так же, как и для приложения Rails. Помните: модель `Article` лежит в пространстве имен, поэтому, чтобы к ней обратиться, следует вызвать ее как `Blorgh::Article`.

```irb
irb> Blorgh::Article.find(1)
=> #<Blorgh::Article id: 1 ...>
```

Наконец нужно сделать так, чтобы ресурс `articles` этого engine был в корне engine. Когда кто-либо перейдет в корень пути, в котором смонтирован engine, ему должен быть показан перечень статей. Чтобы это произошло, следующая строчка должна быть вставлена в файл `config/routes.rb` в engine:

```ruby
root to: "articles#index"
```

Теперь пользователям нужно всего лишь перейти в корень engine, чтобы увидеть все статьи, без посещения `/articles`. Это означает, что вместо `http://localhost:3000/blorgh/articles`, теперь можно перейти на `http://localhost:3000/blorgh`.

### Создание ресурса комментариев

Теперь, когда engine может создавать новые статьи, необходимо добавить функциональность комментирования. Для этого необходимо создать модель комментария, контроллер комментария и модифицировать скаффолд статей для отображения комментариев и позволения пользователям создавать новые.

Из корня engine запустите генератор моделей. Скажите ему создать модель `Comment` с соответствующей таблицей, имеющей два столбца: числовой `article_id` и текстовый `text`.

```bash
$ bin/rails generate model Comment article_id:integer text:text
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

Вызов этого генератора создаст только необходимые для модели файлы, поместит их в пространство имен в директории `blorgh` и создаст класс модели по имени `Blorgh::Comment`. Теперь запустите миграцию, чтобы создать таблицу blorgh_comments:

```bash
$ bin/rails db:migrate
```

Чтобы отображать комментарии на статью, отредактируйте `app/views/blorgh/articles/show.html.erb` и добавьте эту строчку до ссылки "Edit":

```html+erb
<h3>Comments</h3>
<%= render @article.comments %>
```

Эта строчка требует, чтобы была связь `has_many` для комментариев, определенная в модели `Blorgh::Article`, которой сейчас нет. Чтобы ее определить, откройте `app/models/blorgh/article.rb` и добавьте эту строчку в модель:

```ruby
has_many :comments
```

Превратив модель в следующее:

```ruby
module Blorgh
  class Article < ApplicationRecord
    has_many :comments
  end
end
```

NOTE: Поскольку `has_many` определена в классе внутри модуля `Blorgh`, Rails знает, что вы хотите использовать модель `Blorgh::Comment` для этих объектов, поэтому тут нет необходимости указывать это с использованием опции `:class_name`.

Затем необходима форма для создания комментариев к статье. Чтобы ее добавить, поместите эту строчку после вызова `render @article.comments` в `app/views/blorgh/articles/show.html.erb`:

```erb
<%= render "blorgh/comments/form" %>
```

Затем необходимо, чтобы существовал партиал, который рендерит эта строчка. Создайте новую директорию `app/views/blorgh/comments` и в ней новый файл по имени `_form.html.erb`, содержащий следующий код для создания необходимого партиала:

```html+erb
<h3>New comment</h3>
<%= form_with model: [@article, @article.comments.build] do |form| %>
  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>
  <%= form.submit %>
<% end %>
```

При подтверждении этой формы, она попытается выполнить запрос `POST` по маршруту `/articles/:article_id/comments` в engine. Сейчас этот маршрут не существует, но может быть создан с помощью изменения строчки `resources :articles` в `config/routes.rb` на эти строчки:

```ruby
resources :articles do
  resources :comments
end
```

Это создаст вложенный маршрут для комментариев, что и требует форма.

Теперь маршрут существует, но контроллер, на который ведет маршрут, нет. Для его создания запустите команду из корня engine:

```bash
$ bin/rails g controller comments
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
```

Форма сделает запрос `POST` к `/articles/:article_id/comments`, который связан с экшном `create` в `Blorgh::CommentsController`. Этот экшн нужно создать и поместить следующие строчки в определение класса в `app/controllers/blorgh/comments_controller.rb`:

```ruby
def create
  @article = Article.find(params[:article_id])
  @comment = @article.comments.create(comment_params)
  flash[:notice] = "Comment has been created!"
  redirect_to articles_path
end

private

def comment_params
  params.require(:comment).permit(:text)
end
```

Это последняя часть, требуемая для работы формы нового комментария. Однако, отображение комментариев еще не закончено. Если создадите новый комментарий сейчас, то увидите эту ошибку:

```
Missing partial blorgh/comments/_comment with {:handlers=>[:erb, :builder], :formats=>[:html], :locale=>[:en, :en]}. Searched in:
  * "/Users/ryan/Sites/side_projects/blorgh/test/dummy/app/views"
  * "/Users/ryan/Sites/side_projects/blorgh/app/views"
```

Engine не может найти партиал, требуемый для рендеринга комментариев. Rails сперва ищет его в директории приложения (`test/dummy`) `app/views`, а затем в директории engine `app/views`. Когда он не нашел его, выдал эту ошибку. Engine знает, что нужно искать в `blorgh/comments/_comment`, поскольку объект модели, которую он получает, класса `Blorgh::Comment`.

Сейчас этот партиал будет ответственен за рендеринг только текста комментария. Создайте новый файл `app/views/blorgh/comments/_comment.html.erb` и поместите в него эту строчку:

```erb
<%= comment_counter + 1 %>. <%= comment.text %>
```

Локальная переменная `comment_counter` дается нам вызовом `<%= render @article.comments %>`, она определяется автоматически, и счетчик увеличивается с итерацией для каждого комментария. Он используется в этом примере для отображения числа рядом с каждым созданным комментарием.

Мы завершили функцию комментирования engine блога. Теперь настало время использовать его в приложении.

Внедрение в приложение
----------------------

Использовать engine в приложении очень просто. Этот раздел раскрывает, как монтировать engine в приложение требуемые начальные настройки, а также как присоединить engine к классу `User`, представленному приложением, для обеспечения принадлежности статей и комментариев в engine.

### Монтирование Engine

Сначала необходимо определить engine в `Gemfile` приложения. Если у вас нет под рукой готового приложения для тестирования, создайте новое с использованием команды `rails new` вне директории engine:

```bash
$ rails new unicorn
```

Обычно определение engine в `Gemfile` выполняется как определение обычного повседневного гема.

```ruby
gem "devise"
```

Однако, поскольку вы разрабатываете engine `blorgh` на своей локальной машине, необходимо указать опцию `:path` в `Gemfile`:

```ruby
gem "blorgh", path: "engines/blorgh"
```

Затем запустите `bundle` для установки гема.

Как было сказано ранее, при помещении гема в `Gemfile`, он будет загружен вместе с Rails, Он сначала затребует `lib/blorgh.rb` в engine, затем `lib/blorgh/engine.rb`, который является файлом, определяющим основную функциональность для engine.

Чтобы функциональность engine была доступна в приложении, необходимо его смонтировать в файле `config/routes.rb` приложения:

```ruby
mount Blorgh::Engine, at: "/blog"
```

Эта строчка смонтирует engine в `/blog` приложения. Сделав его доступным в `http://localhost:3000/blog`, когда приложение запущено с помощью `bin/rails server`.

NOTE: Другие engine, такие как Devise, управляют этим немного по-другому, позволяя указывать в маршрутах свои хелперы (такие как `devise_for`). Эти хелперы делают примерно то же самое, монтируя части настраиваемой функциональности engine на предопределенные пути.

### Настройка engine

Engine содержит миграции для таблиц `blorgh_articles` и `blorgh_comments`, которые необходимо создать в базе данных приложения, чтобы модели engine могли делать правильные запросы к ним. Чтобы скопировать эти миграции в приложение, запустите следующую команду из корня приложения:

```bash
$ bin/rails blorgh:install:migrations
```

Если имеется несколько engine, из которых необходимо скопировать миграции, используйте `railties:install:migrations`:

```bash
$ bin/rails railties:install:migrations
```

Вы можете указать произвольный путь в исходном engine для миграций, определив переменную среды MIGRATIONS_PATH.

```bash
$ bin/rails railties:install:migrations MIGRATIONS_PATH=db_blourgh
```

Если у вас настроено несколько баз данных, вы также можете указать целевую базу данных с помощью DATABASE.


```bash
$ bin/rails railties:install:migrations DATABASE=animals
```

Эта команда при первом запуске скопирует все миграции из engine. При следующем запуске она скопирует лишь те миграции, которые еще не были скопированы. Первый запуск этой команды выдаст что-то подобное:

```
Copied migration [timestamp_1]_create_blorgh_articles.blorgh.rb from blorgh
Copied migration [timestamp_2]_create_blorgh_comments.blorgh.rb from blorgh
```

Первая временная метка (`[timestamp_1]`) будет текущим временем, а вторая временная метка (`[timestamp_2]`) будет текущим временем плюс секунда. Причиной для этого является то, что миграции для engine выполняются после всех существующих миграций приложения.

Для запуска этих миграций в контексте приложения просто выполните `bin/rails db:migrate`. При входе в engine по адресу `http://localhost:3000/blog`, статей не будет, поскольку таблица, созданная в приложении, отличается от той, что была создана в engine. Сходите, поиграйте с только что смонтированным engine. Он точно такой же, как когда он был только engine.

Если хотите выполнить миграции только от одного engine, можно определить `SCOPE`:

```bash
bin/rails db:migrate SCOPE=blorgh
```

Это полезно, если хотите откатить миграции перед их удалением. Чтобы откатить все миграции от engine blorgh, следует запустить такой код:

```bash
bin/rails db:migrate SCOPE=blorgh VERSION=0
```

### Использование класса, предоставленного приложением

#### Использование модели, предоставленной приложением

При создании engine, может возникнуть желание использовать определенные классы приложения для обеспечения связей между частями engine и частями приложения. В случае engine `blorgh` есть смысл в том, чтобы статьи и комментарии имели авторов.

Типичное приложении имеет класс `User`, предоставляющий авторов статей и комментариев. Но возможен случай, когда приложение называет этот класс по-другому, скажем `Person`. По этой причине engine не должен быть жестко связанным с классом `User`.

В нашем случае, для упрощения, в приложении будет класс с именем `User`, представляющий пользователей приложения (мы сделаем его настраиваемым в дальнейшем). Он может быть создан с помощью этой команды в приложении:

```bash
bin/rails generate model user name:string
```

Далее должна быть запущена команда `bin/rails db:migrate`, чтобы для дальнейшего использовании в приложении создалась таблица `users`.

Также для упрощения, в форме статьи будет новое текстовое поле с именем `author_name`, в которое пользователи смогут вписать свое имя. Затем engine примет это имя и либо создаст новый объект `User` для него, либо найдет того, кто уже имеет такое имя. Engine затем свяжет статью с найденным или созданным объектом `User`.

Сначала нужно добавить текстовое поле `author_name` в партиал `app/views/blorgh/articles/_form.html.erb` внутри engine. Добавьте этот код перед полем `title`:

```html+erb
<div class="field">
  <%= form.label :author_name %><br>
  <%= form.text_field :author_name %>
</div>
```

Затем необходимо обновить метод `Blorgh::ArticlesController#article_params` для разрешения параметров новой формы:

```ruby
def article_params
  params.require(:article).permit(:title, :text, :author_name)
end
```

В модели `Blorgh::Article` должен быть некоторый код, преобразующий поле `author_name` в фактический объект `User` и привязывающий его как `author` статьи до того, как статья будет сохранена. Это потребует настройки `attr_accessor` для этого поля, таким образом, для него будут определены методы сеттера и геттера.

Для этого необходимо добавить `attr_accessor` для `author_name`, связь для author и вызов `before_validation` в `app/models/blorgh/article.rb`. Связь `author` будет пока что жестко завязана на класс `User`.

```ruby
attr_accessor :author_name
belongs_to :author, class_name: "User"

before_validation :set_author

private
  def set_author
    self.author = User.find_or_create_by(name: author_name)
  end
```

Представив объект связи `author` классом `User`, установлена связь между engine и приложением. Должен быть способ связывания записей в таблице `blorgh_articles` с записями в таблице `users`. Поскольку связь называется `author`, столбец `author_id` должен быть добавлен в таблицу `blorgh_articles`.

Для создания этого нового столбца запустите команду внутри engine:

```bash
$ bin/rails generate migration add_author_id_to_blorgh_articles author_id:integer
```

NOTE: Благодаря имени миграции и определению столбца после него, Rails автоматически узнает, что вы хотите добавить столбец в определенную таблицу и запишет это в миграцию. Вам не нужно больше ничего делать.

Нужно запустить эту миграцию в приложении. Для этого, сперва ее нужно скопировать с помощью команды:

```bash
$ bin/rails blorgh:install:migrations
```

Отметьте, что сейчас будет скопирована только _одна_ миграция. Это так, потому что первые две миграции уже были скопированы при первом вызове этой команды.

```
NOTE Migration [timestamp]_create_blorgh_articles.blorgh.rb from blorgh has been skipped. Migration with the same name already exists.
NOTE Migration [timestamp]_create_blorgh_comments.blorgh.rb from blorgh has been skipped. Migration with the same name already exists.
Copied migration [timestamp]_add_author_id_to_blorgh_articles.blorgh.rb from blorgh
```

Запустите эту миграцию с помощью:

```bash
$ bin/rails db:migrate
```

Теперь, когда все на месте, в дальнейшем будет происходить связывание автора - представленного записью в таблице `users` - со статьей, представленной таблицей `blorgh_articles` из engine.

Наконец, на странице статьи должно отображаться имя автора. Добавьте нижеследующий код над выводом "Title" в `app/views/blorgh/articles/_article.html.erb`:

```html+erb
<p>
  <strong>Author:</strong>
  <%= article.author.name %>
</p>
```

#### Использование контроллера, предоставленного приложением

Поскольку обычно контроллеры Rails имеют общий код для таких вещей, как переменные сессии для аутентификации и доступа, по умолчанию они наследуются от `ApplicationController`. Однако engine Rails помещен в пространство имен для запуска, независимого от основного приложения, поэтому каждый engine получает `ApplicationController` в своем пространстве имен. Это пространство имен предотвращает коллизии кода, но часто контроллерам engine необходимо получить доступ к методам `ApplicationController` основного приложения. Легче всего получить этот доступ, изменив `ApplicationController` в пространстве имен engine, унаследовав его от `ApplicationController` основного приложения. Для нашего Blorgh engine это может быть выполнено, изменив `app/controllers/blorgh/application_controller.rb` подобным образом:

```ruby
module Blorgh
  class ApplicationController < ::ApplicationController
  end
end
```

По умолчанию контроллеры engine наследуются от `Blorgh::ApplicationController`. Поэтому после такого изменения они получат доступ к `ApplicationController` основного приложения, как будто они являются частью основного приложения.

Это изменение требует, чтобы engine запускался из приложения Rails, в котором имеется `ApplicationController`.

### Конфигурирование Engine

Этот раздел раскрывает как сделать класс `User` конфигурируемым, а затем даны общие советы по конфигурированию engine.

#### Установка конфигурационных настроек в приложении

Следующим шагом нужно сделать настраиваемым для engine класс, представленный как `User` в приложении. Это потому, как объяснялось ранее, что этот класс не всегда будет `User`. Для этого у engine будет конфигурационная настройка по имени `author_class`, используемая для определения, какой класс представляет пользователей в приложении.

Для определения этой конфигурационной настройки следует использовать `mattr_accessor` в модуле `Blorgh`. Добавьте эту строчку в `lib/blorgh.rb` внутри engine:

```ruby
mattr_accessor :author_class
```

Этот метод работает подобно его братьям `attr_accessor` и `cattr_accessor`, но предоставляет методы сеттера и геттера для модуля с определенным именем. Для его использования к нему следует обратиться с использованием `Blorgh.author_class`.

Следующим шагом является переключение модели `Blorgh::Article` на эту новую настройку. Измените `belongs_to` в этой модели (`app/models/blorgh/article.rb`), на это:

```ruby
belongs_to :author, class_name: Blorgh.author_class
```

Метод `set_author` в модели `Blorgh::Article` должен тоже использовать тот класс:

```ruby
self.author = Blorgh.author_class.constantize.find_or_create_by(name: author_name)
```

Для предотвращения вызова `constantize` на `author_class` каждый раз, можно вместо этого переопределить метод геттера `author_class` внутри модуля `Blorgh` в файле `lib/blorgh.rb`, чтобы он всегда вызывал `constantize` на сохраненном значении до возврата значения:

```ruby
def self.author_class
  @@author_class.constantize
end
```

Это позволит изменить написанный выше код для `set_author` так:

```ruby
self.author = Blorgh.author_class.find_or_create_by(name: author_name)
```

Результат стал более коротким и более очевидным в своем поведении. Метод `author_class` должен всегда возвращать объект `Class`.

Поскольку мы изменили метод `author_class`, чтобы он возвращал `Class` вместо `String`, мы также должны модифицировать определение `belongs_to` в модели `Blorgh::Article`:

```ruby
belongs_to :author, class_name: Blorgh.author_class.to_s
```

Чтобы установить эту конфигурационную настройку в приложении, следует использовать инициализатор. При использовании инициализатора, конфигурация установится до того, как запустится приложение и вызовутся модели engine, которые могут зависеть от существования этих конфигурационных настроек.

Создайте инициализатор `config/initializers/blorgh.rb` в приложении, в котором установлен engine `blorgh`, и поместите в него такое содержимое:

```ruby
Blorgh.author_class = "User"
```

WARNING: Тут важно использовать строковую версию класса, а не сам класс. Если использовать класс, Rails попытается загрузить этот класс и затем обратиться к соответствующей таблице, что приведет к проблемам, если таблица еще не существует. Следовательно, должна быть использована строка, а затем преобразована в класс с помощью `constantize` позже в engine.

Попытайтесь создать новую статью. Вы увидите, что все работает так же, как и прежде, за исключением того, что engine использует конфигурационную настройку в `config/initializers/blorgh.rb`, чтобы узнать, какой класс использовать.

Нет каких-либо строгих ограничений, каким должен быть класс, есть только каким должно быть API для класса. Engine просто требует, чтобы этот класс определял метод `find_or_create_by`, возвращающий объект этого класса для связи со статьей при ее создании. Этот объект, разумеется, должен иметь некоторый идентификатор, по которому на него можно сослаться.

#### Конфигурация Engine общего характера

Может случиться так, что вы захотите использовать для engine инициализаторы, интернационализацию или другие конфигурационные опции. Эти вещи вполне возможны, поскольку Rails engine имеет почти такую же функциональность, как и приложение Rails. Фактически, функциональность приложения Rails - это супер надстройка над тем, что предоставляет engine!

Если хотите использовать инициализатор - код, который должен выполниться до загрузки engine - поместите его в папку `config/initializers`. функциональность этой директории объясняется в разделе [Инициализаторы](/configuring#initializers) руководства по конфигурированию, и работает абсолютно так же, как и директория `config/initializers` в приложении. То же самое касается стандартных инициализаторов.

Что касается локалей, просто поместите файлы локалей в директории `config/locales`, так же, как это делается в приложении.

Тестирование engine
-------------------

В созданном engine есть небольшое пустое приложение в `test/dummy`. Это приложение используется как точка монтирования для engine, чтобы максимально упростить тестирование engine. Это приложение можно расширить, сгенерировав контроллеры, модели или вью из этой директории, и использовать их для тестирования своего engine.

Директорию `test` следует рассматривать как обычную среду тестирования Rails, допускающую юнит, функциональные и интеграционные тесты.

### Функциональные тесты

Следует принять во внимание при написании функциональных тестов, что тесты будут запущены для приложения - приложения `test/dummy` - а не для вашего engine. Это так благодаря настройке тестового окружения; engine нуждается в приложении, как хосту для тестирования его основной функциональности, особенно контроллеров. Это означает, что если сделать обычный `GET` к контроллеру в функциональном тесте для контроллера:

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    def test_index
      get foos_url
      # ...
    end
  end
end
```

Он не будет работать правильно. Это так, поскольку приложение не знает, как направить эти запросы в engine, пока вы явно не скажете **как**. Для этого необходимо установить значение переменной экземпляра `@routes` набором маршрутов engine в коде setup:

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
    end

    def test_index
      get foos_url
      # ...
    end
  end
end
```

Это сообщит приложению, что вы все еще хотите выполнить запрос `GET` к экшну `index` этого контроллера, но вы хотите использовать тут маршрут engine, а не приложения.

Это также позволит убедиться в тестах, что хелперы URL engine работают так, как ожидается.

Улучшение функциональности engine
---------------------------------

Этот раздел объяснит, как добавить или переопределить MVC-функциональность engine из основного приложения Rails.

### Переопределение моделей и контроллеров

Модели и контроллеры engine могут быть переоткрыты в родительском приложении, чтобы их расширить или декорировать.

Переопределения могут быть организованы в выделенной директории `app/overrides`, игнорируемой автозагрузчиком, которая предварительно загружается в колбэке `to_prepare`:

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # ...

    overrides = "#{Rails.root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)

    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
        load override
      end
    end
  end
end
```

#### Переоткрытие существующих классов с использованием `class_eval`

Например, чтобы переопределить модель engine

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    # ...
  end
end
```

нужно всего лишь создать файл, _переоткрывающий_ этот класс:

```ruby
# MyApp/app/overrides/models/blorgh/article_override.rb
Blorgh::Article.class_eval do
  # ...
end
```

Очень важно, что переопределение переоткрывает этот класс или модуль. Использование ключевых слов `class` или `module` определили бы их, если они еще не существуют в памяти, что было бы неправильным, так как определение находится в engine. Использование `class_eval`, как показано выше, гарантирует, что вы переоткрываете.

#### Изменение существующих классов с использованием ActiveSupport::Concern

Использование `Class#class_eval` хорошо подходит для простых корректировок, но для более сложных модификаций следует рассмотреть использование [`ActiveSupport::Concern`](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html). `ActiveSupport::Concern` управляет порядком загрузки взаимосвязанных зависимостей во время выполнения, что позволяет существенно модулировать ваш код.

**Добавление** `Article#time_since_created` и **Переопределение** `Article#summary`:

```ruby
# MyApp/app/models/blorgh/article.rb

class Blorgh::Article < ApplicationRecord
  include Blorgh::Concerns::Models::Article

  def time_since_created
    Time.current - created_at
  end

  def summary
    "#{title} - #{truncate(text)}"
  end
end
```

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    include Blorgh::Concerns::Models::Article
  end
end
```

```ruby
# Blorgh/lib/concerns/models/article.rb

module Blorgh::Concerns::Models::Article
  extend ActiveSupport::Concern

  # 'included do' приводит к тому, что блок будет вычислен в контексте,
  # в котором модуль подключен (т.е. Blorgh::Article),
  # а не в самом модуле.
  included do
    attr_accessor :author_name
    belongs_to :author, class_name: "User"

    before_validation :set_author

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

### Автозагрузка и Engine

Обратитесь к руководству [Автозагрузка и перезагрузка констант](/autoloading-and-reloading-constants#autoloading-and-engines)
guide for more information about autoloading and engines.

### Переопределение вью

Когда Rails ищет вью для рендеринга, он сперва смотрит в директорию `app/views` приложения. Если он не может найти там вью, он проверит директории `app/views` всех engine, имеющих эту директорию.

Когда приложение хочет отрендерить вью для экшна `index` в `Blorgh::ArticlesController`, он сперва пытается найти путь `app/views/blorgh/articles/index.html.erb` внутри приложения. Если не сможет найти, то будет искать внутри engine.

Можно переопределить эту вью в приложении, просто создав файл `app/views/blorgh/articles/index.html.erb`. Можно полностью изменить то, что эта вью должна обычно выводить.

Попробуйте так сделать, создав новый файл `app/views/blorgh/articles/index.html.erb` и поместив в него:

```html+erb
<h1>Articles</h1>
<%= link_to "New Article", new_article_path %>
<% @articles.each do |article| %>
  <h2><%= article.title %></h2>
  <small>By <%= article.author %></small>
  <%= simple_format(article.text) %>
  <hr>
<% end %>
```

### (routes) Маршруты

По умолчанию маршруты в engine изолированы от приложения. Это выполняется с помощью вызова `isolate_namespace` в классе `Engine`. По сути это означает, что приложение и его engine могут иметь одинаково названные маршруты, и не будет никакого конфликта.

Маршруты в engine отрисовываются в классе `Engine` в `config/routes.rb`, подобно:

```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

Имея подобные изолированные маршруты, если захотите сослаться на часть engine из приложения, необходимо воспользоваться прокси методом маршрутов engine. Вызов обычных маршрутных методов, таких как `articles_path`, может привести в нежелательное место расположения, если и приложение, и engine определяют такой хелпер.

Ссылка в следующем примере приведет на `articles_path` приложения, если шаблон был отрендерен из приложения, или на `articles_path` engine, если был отрендерен в engine:

```erb
<%= link_to "Blog articles", articles_path %>
```

Чтобы этот маршрут всегда использовал маршрутный метод хелпера `articles_path` engine, необходимо вызвать метод на маршрутном прокси методе, имеющем то же имя, что и engine.

```erb
<%= link_to "Blog articles", blorgh.articles_path %>
```

Можно обратиться к приложению из engine подобным образом, используя хелпер `main_app`:

```erb
<%= link_to "Home", main_app.root_path %>
```

Если это использовать в engine, он **всегда** будет вести на корень приложения. Если опустить вызов метода "маршрутного прокси" `main_app`, он потенциально может вести на корень engine или приложения, в зависимости от того, где был вызван.

Если шаблон, рендерящийся из engine, попытается использовать один из методов маршрутного хелпера приложения, это может привести к вызову неопределенного метода. Если вы с этим столкнулись, убедитесь, что не пытаетесь вызвать из engine маршрутный метод приложения без префикса `main_app`.

### Ресурсы (assets)

Ресурсы в engine работают так же, как и в полноценном приложении. Поскольку класс engine наследуется от `Rails::Engine`, приложение будет знать, что следует искать ресурсы в директориях engine `app/assets` и `lib/assets`.

Подобно остальным компонентам engine, ресурсы также будут помещены в пространство имен. Это означает, что если имеется ресурс по имени `style.css`, он должен быть помещен в `app/assets/stylesheets/[engine name]/style.css`, а не в `app/assets/stylesheets/style.css`. Если этот ресурс не будет помещен в пространство имен, то есть вероятность, что в приложении есть идентично названный ресурс, в этом случае ресурс приложения будет иметь преимущество, а ресурс в engine будет проигнорирован.

Представим, что у вас есть ресурс `app/assets/stylesheets/blorgh/style.css`. Чтобы включить его в приложение, используйте `stylesheet_link_tag` и сошлитесь на ресурс так, как он находится в engine:

```erb
<%= stylesheet_link_tag "blorgh/style.css" %>
```

Также можно определить эти ресурсы как зависимости для других ресурсов, используя выражения Asset Pipeline в обрабатываемых файлах:

```css
/*
 *= require blorgh/style
 */
```

INFO. Помните, что для использования языков, таких как Sass или CoffeeScript, следует подключить соответствующую библиотеку в `.gemspec` вашего engine.

### Отдельные ресурсы и прекомпиляция

Бывают ситуации, когда ресурсы engine не требуются приложению. Например, скажем, вы создали административную функциональность, существующую только для engine. В этом случае приложению не нужно требовать `admin.css` или `admin.js`. Только административному макету гема необходимы эти ресурсы. Нет смысла, чтобы приложение включало `"blorg/admin.css"` в свои таблицы стилей. В такой ситуации следует явно определить эти ресурсы для прекомпиляции.
Это сообщит Sprockets добавить ресурсы engine при вызове `bin/rails assets:precompile`.

Ресурсы для прекомпиляции можно определить в `engine.rb`

```ruby
initializer "blorgh.assets.precompile" do |app|
  app.config.assets.precompile += %w( admin.js admin.css )
end
```

Более подробно читайте в руководстве [Asset Pipeline](/asset-pipeline).

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

Оба типа зависимостей будут установлены при запуске `bundle install`  внутри приложения. Зависимости development для гема будут использованы только когда будут запущена разработка и тесты для engine.

Отметьте, что если вы захотите немедленно затребовать зависимости при затребовании engine, следует их затребовать до инициализации engine. Например:

```ruby
require "other_engine/engine"
require "yet_another_engine/engine"

module MyEngine
  class Engine < ::Rails::Engine
  end
end
```
