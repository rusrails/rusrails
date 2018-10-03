Макеты и рендеринг в Rails
==========================

Это руководство раскрывает основные возможности макетов Action Controller и Action View.

После прочтения этого руководства, вы узнаете:

* Как использовать различные методы рендеринга, встроенные в Rails.
* Как создавать макеты с несколькими разделами содержимого.
* Как использовать частичные шаблоны для соблюдения принципа DRY в ваших вьюхах.
* Как использовать вложенные макеты (подшаблоны).

Обзор: как кусочки складываются вместе
--------------------------------------

Это руководство сосредотачивается на взаимодействии между контроллером и вьюхой (представлением) в треугольнике модель-представление-контроллер (MVC). Как вы знаете, контроллер ответственен за управление целым процессом обслуживания запросов в Rails, хотя обычно любой серьезный код переносится в модель. Но когда приходит время послать отклик обратно пользователю, контроллер передает все вьюхе. Именно этой передаче посвящено данное руководство.

В общих чертах все связано с решением, что же должно быть послано как отклик, и вызовом подходящего метода для создания этого отклика. Если откликом является полноценная вьюха, Rails также проводит дополнительную работу по упаковыванию вьюхи в макет и, возможно, по вставке частичных вьюх. В общем, все эти этапы вы увидите сами в следующих разделах.

Создание откликов
-----------------

С точки зрения контроллера есть три способа создать отклик HTTP:

* Вызвать `render` для создания полного отклика, возвращаемого браузеру
* Вызвать `redirect_to` для передачи браузеру кода переадресации HTTP
* Вызвать `head` для создания отклика, включающего только заголовки HTTP, возвращаемого браузеру

### Рендеринг по умолчанию: соглашения по конфигурации в действии

Вы уже слышали, что Rails содействует принципу "соглашения по конфигурации". Рендеринг по умолчанию - прекрасный пример этого. По умолчанию контроллеры в Rails автоматически рендерят вьюхи с именами, соответствующими валидным маршрутам. Например, если есть такой код в вашем классе `BooksController`:

```ruby
class BooksController < ApplicationController
end
```

И следующее в файле маршрутов:

```ruby
resources :books
```

И у вас имеется файл вьюхи `app/views/books/index.html.erb`:

```ruby
<h1>Books are coming soon!</h1>
```

Rails автоматически отрендерит `app/views/books/index.html.erb` при переходе на адрес `/books`, и вы увидите на экране надпись "Books are coming soon!"

Однако это сообщение минимально полезно, поэтому вскоре вы создадите модель `Book` и добавите экшн index в `BooksController`:

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

Снова отметьте, что у нас соглашения превыше конфигурации в том, что отсутствует избыточный рендер в конце этого экшна index. Правило в том, что не нужно что-то избыточно рендерить в конце экшна контроллера, rails будет искать шаблон `action_name.html.erb` по пути вьюх контроллера и отрендерит его, поэтому в нашем случае Rails отрендерит файл `app/views/books/index.html.erb`.

Итак, в нашей вьюхе мы хотим отобразить свойства всех книг, это делается с помощью шаблона ERB, подобного следующему:

```html+erb
<h1>Listing Books</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Content</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @books.each do |book| %>
      <tr>
        <td><%= book.title %></td>
        <td><%= book.content %></td>
        <td><%= link_to "Show", book %></td>
        <td><%= link_to "Edit", edit_book_path(book) %></td>
        <td><%= link_to "Destroy", book, method: :delete, data: { confirm: "Are you sure?" } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to "New book", new_book_path %>
```

NOTE: Фактически рендеринг осуществляется вложенными классами модуля [`ActionView::Template::Handlers`](http://api.rubyonrails.org/classes/ActionView/Template/Handlers.html). Мы не будем углубляться в этот процесс, но важно знать, что расширение файла вьюхи контролирует выбор обработчика шаблона.

### Использование `render`

Во многих случаях метод `ActionController::Base#render` выполняет большую работу по рендерингу содержимого Вашего приложения для использования в браузере. Имеются различные способы настройки возможностей `render`. Вы можете рендерить вьюху по умолчанию для шаблона Rails, или определенный шаблон, или файл, или встроенный код, или совсем ничего. Можно рендерить текст, JSON или XML. Также можно определить тип содержимого или статус HTTP отрендеренного отклика.

TIP: Если хотите увидеть точные результаты вызова `render` без необходимости проверять это в браузере, можете вызвать `render_to_string`. Этот метод принимает те же самые опции, что и `render`, но возвращает строку вместо отправки отклика обратно браузеру.

#### Рендеринг вьюхи экшна

Если хотите отрендерить вьюху, соответствующую другому шаблону этого же контроллера, можно использовать `render` с именем вьюхи:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render "edit"
  end
end
```

Если вызов `update` проваливается, вызов экшна `update` в этом контроллере отрендерит шаблон `edit.html.erb`, принадлежащий тому же контроллеру.

Если хотите, можете использовать символ вместо строки для определения экшна для рендеринга:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render :edit
  end
end
```

#### Рендеринг шаблона экшна из другого контроллера

Что, если вы хотите отрендерить шаблон из абсолютно другого контроллера? Это можно также сделать с `render`, который принимает полный путь шаблона для рендеринга (относительно `app/views`). Например, если запускаем код в `AdminProductsController` который находится в `app/controllers/admin`, можете отрендерить результат экшна в шаблон в `app/views/products` следующим образом:

```ruby
render "products/show"
```

Rails знает, что эта вьюха принадлежит другому контроллеру, поскольку содержит символ слэша в строке. Если хотите быть точными, можете использовать опцию `:template` (которая требовалась в Rails 2.2 и более ранних):

```ruby
render template: "products/show"
```

#### Рендеринг произвольного файла

Метод `render` также может использовать вьюху, которая находится вне вашего приложения:

```ruby
render file: "/u/apps/warehouse_app/current/app/views/products/show"
```

Опция `:file` принимает абсолютный путь в файловой системе. Разумеется, вам необходимы права на просмотр того, что вы используете для рендеринга.

NOTE: Использование опции `:file` в комбинации с данными, введенными пользователем, может привести к проблемам безопасности, так как злоумышленник может использовать этот экшн для доступа к чувствительным, с точки зрения безопасности, файлам вашей файловой системы.

NOTE: По умолчанию файл рендериться с использованием текущего макета.

TIP: Если вы используете Rails под Microsoft Windows, то должны использовать опцию `:file` для рендеринга файла, потому что имена файлов Windows не имеют тот же формат, как имена файлов Unix.

#### Оборачивание

Вышеописанные три метода рендеринга (рендеринг другого шаблона в контроллере, рендеринг шаблона в другом контроллере и рендеринг произвольного файла в файловой системе) на самом деле являются вариантами одного и того же экшна.

Фактически в классе BooksController, в экшне update, в котором мы хотим отрендерить шаблон edit, если книга не была успешно обновлена, все нижеследующие вызовы отрендерят шаблон `edit.html.erb` в директории `views/books`:

```ruby
render :edit
render action: :edit
render "edit"
render "edit.html.erb"
render action: "edit"
render action: "edit.html.erb"
render "books/edit"
render "books/edit.html.erb"
render template: "books/edit"
render template: "books/edit.html.erb"
render "/path/to/rails/app/views/books/edit"
render "/path/to/rails/app/views/books/edit.html.erb"
render file: "/path/to/rails/app/views/books/edit"
render file: "/path/to/rails/app/views/books/edit.html.erb"
```

Какой из них вы будете использовать - это вопрос стиля и соглашений, но практическое правило заключается в использовании простейшего, который больше подходит по стилю написания вашего кода.

#### Использование `render` с `:inline`

Метод `render` вполне может обойтись без вьюхи, если вы используете опцию `:inline` для поддержки ERB, как части вызова метода. Это вполне валидно:

```ruby
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

WARNING: Должно быть серьезное основание для использования этой опции. Вкрапление ERB в контроллер нарушает MVC ориентированность Rails и создает трудности для других разработчиков в следовании логике вашего проекта. Вместо этого используйте отдельную erb-вьюху.

По умолчанию встроенный рендеринг использует ERB. Можете принудить использовать вместо этого Builder с помощью опции `:type`:

```ruby
render inline: "xml.p {'Horrid coding practice!'}", type: :builder
```

#### Рендеринг текста

Вы можете послать простой текст - совсем без разметки - обратно браузеру с использованием опции `:plain` в `render`:

```ruby
render plain: "OK"
```

TIP: Рендеринг чистого текста наиболее полезен, когда вы делаете Ajax-отклик или отвечаете на запросы веб-сервиса, ожидающего что-то иное, чем HTML.

NOTE: По умолчанию при использовании опции `:plain` текст рендерится без использования текущего макета. Если хотите, чтобы Rails вложил текст в текущий макет, необходимо добавить опцию `layout: true` и использовать расширение `.text.erb` для файла макета.

#### Рендеринг HTML

Вы можете вернуть HTML, используя опцию `:html` метода `render`:

```ruby
render html: helpers.tag.strong('Not Found')
```

TIP: Это полезно когда вы хотите отрендерить небольшой кусочек HTML-кода. Однако, если у вас достаточно сложная разметка, стоит рассмотреть выделение её в файл шаблона.

NOTE: Когда используется опция `html:`, HTML объекты будут экранироваться, если строка не состоит из API, поддерживающих `html_safe`.

#### Рендеринг JSON

JSON - это формат данных JavaScript, используемый многими библиотеками Ajax. Rails имеет встроенную поддержку для преобразования объектов в JSON и рендеринга этого JSON обратно браузеру:

```ruby
render json: @product
```

TIP: Не нужно вызывать `to_json` в объекте, который хотите рендерить. Если используется опция `:json`, `render` автоматически вызовет `to_json` за вас.

#### Рендеринг XML

Rails также имеет встроенную поддержку для преобразования объектов в XML и рендеринга этого XML обратно вызывающему:

```ruby
render xml: @product
```

TIP: Не нужно вызывать `to_xml` в объекте, который хотите рендерить. Если используется опция `:xml`, `render` автоматически вызовет `to_xml` за вас.

#### Рендеринг внешнего JavaScript

Rails может рендерить чистый JavaScript:

```ruby
render js: "alert('Hello Rails');"
```

Это пошлет указанную строку в браузер с типом MIME `text/javascript`.

#### Рендеринг необработанного содержимого

Вы можете вернуть необработанный текст, без установки типа содержимого,
используя опцию `:body`, метода `render`:

```ruby
render body: "raw"
```

TIP: Эта опция должна использоваться, только если не важен тип содержимого отклика.
Использование `:plain` или `:html` уместнее в большинстве случаев.

NOTE: Возвращенным откликом от этой опции будет `text/plain` (если не будет переопределен),
так как это тип содержимого по умолчанию у отклика Action Dispatch.

#### Опции для `render`

Вызов метода `render` как правило принимает пять опций:

* `:content_type`
* `:layout`
* `:location`
* `:status`
* `:formats`

##### Опция `:content_type`

По умолчанию Rails будет обрабатывать результаты операции рендеринга с типом содержимого MIME `text/html` (или `application/json`, если используется опция `:json`, или `application/xml` для опции `:xml`). Иногда бывает так, что нужно изменить это, и тогда необходимо настроить опцию `:content_type`:

```ruby
render file: filename, content_type: "application/rss"
```

##### Опция `:layout`

С большинством опций для `render`, отрендеренное содержимое отображается как часть текущего макета. Вы узнаете более подробно о макетах, и как их использовать, позже в этом руководстве.

Опция `:layout` нужна, чтобы сообщить Rails о необходимости использовать определенный файл как макет для текущего экшна:

```ruby
render layout: "special_layout"
```

Также можно сообщить Rails, что требуется рендерить вообще без макета:

```ruby
render layout: false
```

##### Опция `:location`

Опцию `:location` можно использовать, чтобы установить заголовок HTTP `Location`:

```ruby
render xml: photo, location: photo_url(photo)
```

##### (the-status-option) Опция `:status`

Rails автоматически сгенерирует отклик с правильным кодом статуса HTML (в большинстве случаев равный `200 OK`). Опцию `:status` можно использовать, чтобы изменить это:

```ruby
render status: 500
render status: :forbidden
```

Rails понимает как числовые коды статуса, так и соответствующие символы, показанные ниже.

| Класс отклика       | Код статуса HTTP | Символ                           |
| ------------------- | ---------------- | -------------------------------- |
| **Informational**   | 100              | :continue                        |
|                     | 101              | :switching_protocols             |
|                     | 102              | :processing                      |
| **Success**         | 200              | :ok                              |
|                     | 201              | :created                         |
|                     | 202              | :accepted                        |
|                     | 203              | :non_authoritative_information   |
|                     | 204              | :no_content                      |
|                     | 205              | :reset_content                   |
|                     | 206              | :partial_content                 |
|                     | 207              | :multi_status                    |
|                     | 208              | :already_reported                |
|                     | 226              | :im_used                         |
| **Redirection**     | 300              | :multiple_choices                |
|                     | 301              | :moved_permanently               |
|                     | 302              | :found                           |
|                     | 303              | :see_other                       |
|                     | 304              | :not_modified                    |
|                     | 305              | :use_proxy                       |
|                     | 307              | :temporary_redirect              |
|                     | 308              | :permanent_redirect              |
| **Client Error**    | 400              | :bad_request                     |
|                     | 401              | :unauthorized                    |
|                     | 402              | :payment_required                |
|                     | 403              | :forbidden                       |
|                     | 404              | :not_found                       |
|                     | 405              | :method_not_allowed              |
|                     | 406              | :not_acceptable                  |
|                     | 407              | :proxy_authentication_required   |
|                     | 408              | :request_timeout                 |
|                     | 409              | :conflict                        |
|                     | 410              | :gone                            |
|                     | 411              | :length_required                 |
|                     | 412              | :precondition_failed             |
|                     | 413              | :payload_too_large               |
|                     | 414              | :uri_too_long                    |
|                     | 415              | :unsupported_media_type          |
|                     | 416              | :range_not_satisfiable           |
|                     | 417              | :expectation_failed              |
|                     | 421              | :misdirected_request             |
|                     | 422              | :unprocessable_entity            |
|                     | 423              | :locked                          |
|                     | 424              | :failed_dependency               |
|                     | 426              | :upgrade_required                |
|                     | 428              | :precondition_required           |
|                     | 429              | :too_many_requests               |
|                     | 431              | :request_header_fields_too_large |
|                     | 451              | :unavailable_for_legal_reasons   |
| **Server Error**    | 500              | :internal_server_error           |
|                     | 501              | :not_implemented                 |
|                     | 502              | :bad_gateway                     |
|                     | 503              | :service_unavailable             |
|                     | 504              | :gateway_timeout                 |
|                     | 505              | :http_version_not_supported      |
|                     | 506              | :variant_also_negotiates         |
|                     | 507              | :insufficient_storage            |
|                     | 508              | :loop_detected                   |
|                     | 510              | :not_extended                    |
|                     | 511              | :network_authentication_required |

NOTE: Если попытаться отрендерить содержимое наряду с кодом статуса без содержимого (100-199, 204, 205 или 304), он будет исключён из отклика.

##### Опция `:formats`

Rails использует формат, определённый в запросе (или `:html` по умолчанию). Вы можете изменить его, передав в опцию `:formats` символ или массив:

```ruby
render formats: :xml
render formats: [:json, :xml]
```

Если шаблон с указанным форматом не существует, вызывается ошибка `ActionView::MissingTemplate`.

##### Поиск макетов

Чтобы найти текущий макет, Rails сначала смотрит файл в `app/views/layouts` с именем, таким же, как имя контроллера. Например, рендеринг экшнов из класса `PhotosController` будет использовать `/app/views/layouts/photos.html.erb` (или `app/views/layouts/photos.builder`). Если такого макета нет, Rails будет использовать `/app/views/layouts/application.html.erb` или `/app/views/layouts/application.builder`. Если макет `.erb` отсутствует, Rails будет использовать макет `.builder`, если таковой имеется. Rails также предоставляет несколько способов для более точного назначения определенных макетов отдельным контроллерам и экшнам.

##### Определение макетов для контроллеров

Вы можете переопределить дефолтные соглашения по макетам в контроллере, используя объявление `layout`. Например:

```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

С этим объявлением все вьюхи, отрендеренные `ProductsController`, будут использовать `app/views/layouts/inventory.html.erb` как макет.

Чтобы привязать определенный макет к приложению в целом, используйте объявление `layout` в классе `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```

С этим объявлением каждая из вьюх во всем приложении будет использовать `app/views/layouts/main.html.erb` как макет.

##### Выбор макетов во время выполнения

Можно использовать символ для отсрочки выбора макета до тех пор, пока не будет обработан запрос:

```ruby
class ProductsController < ApplicationController
  layout :products_layout

  def show
    @product = Product.find(params[:id])
  end

  private
    def products_layout
      @current_user.special? ? "special" : "products"
    end

end
```

Теперь, если текущий пользователь является специальным, он получит специальный макет при просмотре продукта.

Можно даже использовать встроенный метод, такой как Proc, для определения макета. Например, если передать объект Proc, то блоку, которому вы передаете Proc, будет предоставлен экземпляр `controller`, поэтому макет может быть определен, основываясь на текущем запросе:

```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

##### Условные макеты

Макеты, определенные на уровне контроллера, поддерживают опции `:only` и `:except`. Эти опции принимают либо имя метода, либо массив имен методов, соответствующих именам методов в контроллере:

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

С таким объявлением макет `product` будет использован везде, кроме методов `rss` и `index`.

##### Наследование макета

Объявление макета ниже по иерархии и более специфическое объявление макета всегда переопределяет более общие. Например:

* `application_controller.rb`

    ```ruby
    class ApplicationController < ActionController::Base
      layout "main"
    end
    ```

* `articles_controller.rb`

    ```ruby
    class ArticlesController < ApplicationController
    end
    ```

* `special_articles_controller.rb`

    ```ruby
    class SpecialArticlesController < PostsController
      layout "special"
    end
    ```

* `old_articles_controller.rb`

    ```ruby
    class OldArticlesController < SpecialPostsController
      layout false

      def show
        @article = Article.find(params[:id])
      end

      def index
        @old_articles = Article.older
        render layout: "old"
      end
      # ...
    end
    ```

В этом приложении:

* В целом, вьюхи будут рендериться в макет `main`
* `ArticlesController#index` будет использовать макет `main`
* `SpecialArticlesController#index` будет использовать макет `special`
* `OldArticlesController#show` не будет использовать макет совсем
* `OldArticlesController#index` будет использовать макет `old`

##### Наследование шаблона

Следуя логике наследования макета, если шаблон или партиал не найдены по обычному пути, контроллер будет искать шаблон или партиал для рендеринга по цепочке наследования. Например:

```ruby
# in app/controllers/application_controller
class ApplicationController < ActionController::Base
end

# in app/controllers/admin_controller
class AdminController < ApplicationController
end

# in app/controllers/admin/products_controller
class Admin::ProductsController < AdminController
  def index
  end
end
```

Порядок поиска экшна `admin/products#index` будет такой:

* `app/views/admin/products/`
* `app/views/admin/`
* `app/views/application/`

Это делает `app/views/application/` хорошим местом для общих партиалов, которые затем могут быть отрендерены в ERB следующим образом:

```erb
<%# app/views/admin/products/index.html.erb %>
<%= render @products || "empty_list" %>

<%# app/views/application/_empty_list.html.erb %>
There are no items in this list <em>yet</em>.
```

#### Избегание ошибок двойного рендеринга

Рано или поздно, большинство разработчиков на Rails увидят сообщение об ошибке "Can only render or redirect once per action". Хоть такое и раздражает, это относительно просто правится. Обычно такое происходит в связи с фундаментальным непониманием метода работы `render`.

Например, вот некоторый код, который вызовет эту ошибку:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

Если `@book.special?` вычисляется как `true`, Rails начинает процесс рендеринга, выгружая переменную `@book` во вьюху `special_show`. Но это _не_ остановит от выполнения остальной код в экшне `show`, и когда Rails достигнет конца экшна, он начнет рендерить вьюху `show` - и выдаст ошибку. Решение простое: убедитесь, что у вас есть только один вызов `render` или `redirect` за один проход. Еще может помочь такая вещь, как `and return`. Вот исправленная версия метода:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show" and return
  end
  render action: "regular_show"
end
```

Убедитесь, что используете `and return` вместо `&& return`, поскольку `&& return` не будет работать в связи с приоритетом операторов в языке Ruby.

Отметьте, что неявный рендер, выполняемый ActionController, определяет, был ли вызван `render` поэтому следующий код будет работать без проблем:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```

Это отрендерит книгу (book) с `special?`, заданным с помощью шаблона `special_show`, в то время как остальные книги будут рендериться с дефолтным шаблоном `show`.

### Использование `redirect_to`

Другой способ управлять возвратом отклика на HTTP-запрос - с помощью `redirect_to`. Как вы видели, `render` сообщает Rails, какую вьюху (или иной ассет) использовать при построении отклика. Метод `redirect_to` делает нечто совершенно отличное: он говорит браузеру послать новый запрос по другому URL. Например, можно перенаправить из любого места, где сейчас выполняется код, к экшну index фотографий вашего приложения с помощью этого вызова:

```ruby
redirect_to photos_url
```

Можно использовать `redirect_back`, чтобы вернуть пользователя на страницу с которой он только что пришел. Это место расположения вытаскивается из заголовка `HTTP_REFERER`, который не обязательно будет установлен браузером, поэтому нужно предоставить `fallback_location` для использования в таком случае.

```ruby
redirect_back(fallback_location: root_path)
```

NOTE: `redirect_to` и `redirect_back` не прерывают и не возвращают из выполняемого метода немедленно, а просто устанавливают отклики HTTP. Выражения, следующие после них в методе, будут выполнены. При необходимости можно прервать явным `return` или любым другим механизмом прерывания.

#### Получение различного кода статуса перенаправления

Rails использует код статуса HTTP 302, временное перенаправление, при вызове `redirect_to`. Если хотите использовать иной код статуса, возможно 301, постоянное перенаправление, можете использовать опцию `:status`:

```ruby
redirect_to photos_path, status: 301
```

Подобно опции `:status` для `render`, `:status` для `redirect_to` принимает и числовые, и символьные обозначения заголовка.

#### Различие между `render` и `redirect_to`

Иногда неопытные разработчики думают о `redirect_to` как о разновидности команды `goto`, перемещающую выполнение из одного места в другое в вашем коде Rails. Это _не_ верно. Ваш код останавливается и ждет нового запроса от браузера. Просто получается так, что вы говорите браузеру, какой запрос он должен сделать следующим, возвращая код статуса HTTP 302.

Рассмотрим эти экшны, чтобы увидеть разницу:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    render action: "index"
  end
end
```

С кодом в такой форме, вероятно, будет проблема, если переменная `@book` равна `nil`. Помните, `render :action` не запускает какой-либо код в указанном экшне, и таким образом ничего не будет присвоено переменной `@books`, которую, возможно, потребует вьюха `index`. Один из способов исправить это - использовать перенаправление вместо рендеринга:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    redirect_to action: :index
  end
end
```

С помощью этого кода браузер сделает новый запрос для индексной страницы, код в методе `index` запустится, и все будет хорошо.

Единственный недостаток этого кода в том, что он требует круговорот через браузер: браузер запрашивает экшн show с помощью `/books/1`, и контроллер обнаруживает, что книг нет, поэтому отсылает отклик-перенаправление 301 браузеру, сообщающий перейти на `/books/`, браузер выполняет и посылает новый запрос контроллеру, теперь запрашивая экшн `index`, затем контроллер получает все книги в базе данных и рендерит шаблон index, отсылает его обратно браузеру, который затем показывает его на экране.

Пока это небольшое приложение, такая добавленная задержка не может быть проблемой, но иногда стоит подумать о том, является ли время отклика проблемой. Можем продемонстрировать один из способов управления этим с помощью хитрого примера:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    @books = Book.all
    flash.now[:alert] = "Your book was not found"
    render "index"
  end
end
```

Это обнаружит, что нет книг с определенным ID, заполнит переменную экземпляра `@books` всеми книгами в модели, и затем напрямую отрендерит шаблон `index.html.erb`, возвратив его браузеру с предупреждающим сообщением в flash, сообщающим пользователю, что произошло.

### Использование `head` для создания отклика, содержащего только заголовок

Метод `head` может использоваться для отправки браузеру откликов, содержащих только заголовки. Метод `head` принимает число или символ (смотрите [таблицу соответствия](#the-status-option)), представляющие код статуса HTTP. Аргумент опций интерпретируется как хэш заголовков имен и значений. Например, можно возвратить только заголовок ошибки:

```ruby
head :bad_request
```

Это создаст следующий заголовок:

```bash
HTTP/1.1 400 Bad Request
Connection: close
Date: Sun, 24 Jan 2010 12:15:53 GMT
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
X-Runtime: 0.013483
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

Или можете использовать другие заголовки HTTP для передачи другой информации:

```ruby
head :created, location: photo_path(@photo)
```

Что создаст:

```bash
HTTP/1.1 201 Created
Connection: close
Date: Sun, 24 Jan 2010 12:16:44 GMT
Transfer-Encoding: chunked
Location: /photos/1
Content-Type: text/html; charset=utf-8
X-Runtime: 0.083496
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

Структурирование макетов
------------------------

Когда Rails рендерит вьюху как отклик, он делает это путем объединения вьюхи с текущим макетом, используя правила для нахождения текущего макета, которые были рассмотрены ранее. В макетах у вас есть доступ к трем инструментам для объединения различных кусочков результата для формирования общего отклика:

* Теги ассетов
* `yield` и `content_for`
* Партиалы

### Хелперы ассетных тегов

Хелперы ассетных тегов предоставляют методы для генерации HTML, связывающие вьюхи с лентами новостей, JavaScript, таблицами стилей, изображениями, видео и аудио. В Rails доступно шесть хелперов ассетных тегов:

* `auto_discovery_link_tag`
* `javascript_include_tag`
* `stylesheet_link_tag`
* `image_tag`
* `video_tag`
* `audio_tag`

Эти теги можно использовать в макетах или других вьюхах, хотя `auto_discovery_link_tag`, `javascript_include_tag` и `stylesheet_link_tag` как правило используются в разделе `<head>` макета.

WARNING: Хелперы ассетных тегов _не_ проверяют существование ассетов по заданному месту расположения; они просто предполагают, что вы знаете, что делаете, и генерируют ссылку.

#### Присоединение каналов с помощью `auto_discovery_link_tag`

Хелпер `auto_discovery_link_tag` создает HTML-код, который большинство браузеров и агрегаторов новостей могут использовать для определения наличия каналов RSS, Atom или JSON лент. Он принимает тип ссылки (`:rss`, `:atom` или `:json`), хэш опций, которые передаются через url_for, и хэш опций для тега:

```erb
<%= auto_discovery_link_tag(:rss, {action: "feed"},
  {title: "RSS Feed"}) %>
```

Вот три опции тега, доступные для `auto_discovery_link_tag`:

* `:rel` определяет значение `rel` в ссылке. Значение по умолчанию "alternate"
* `:type` определяет явный тип MIME. Rails генерирует подходящий тип MIME автоматически
* `:title` определяет заголовок ссылки. Значение по умолчанию это значение `:type` в верхнем регистре, например, "ATOM" или "RSS".

#### Присоединение файлов JavaScript с помощью `javascript_include_tag`

Хелпер `javascript_include_tag` возвращает HTML-тег `script` для каждого предоставленного источника.

При использовании Rails с включенным [Asset Pipeline](/asset-pipeline), этот хелпер сгенерирует ссылку на `/assets/javascripts/`, а не на `public/javascripts`, которая использовалась в более ранних версиях Rails. Затем эта ссылка обслуживается файлопроводом (asset pipeline).

Файл JavaScript в приложении Rails или Rails Engine размещается в одном из трех мест расположения: `app/assets`, `lib/assets` или `vendor/assets`. Эти места расположения детально описаны в разделе про [организацию ресурсов](/asset-pipeline#how-to-use-the-asset-pipeline) в руководстве по Asset Pipeline.

Можно определить полный путь относительно корня документа или URL, по желанию. Например, сослаться на файл JavaScript, находящийся в директории с именем `javascripts` в одной из `app/assets`, `lib/assets` или `vendor/assets`, можно так:

```erb
<%= javascript_include_tag "main" %>
```

Rails тогда выдаст такой тег `script`:

```html
<script src='/assets/main.js'></script>
```

Затем запрос к этому ассету будет обслужен гемом Sprockets.

Чтобы включить несколько файлов, таких как `app/assets/javascripts/main.js` и `app/assets/javascripts/columns.js` за один раз:

```erb
<%= javascript_include_tag "main", "columns" %>
```

Чтобы включить `app/assets/javascripts/main.js` и `app/assets/javascripts/photos/columns.js`:

```erb
<%= javascript_include_tag "main", "/photos/columns" %>
```

Чтобы включить `http://example.com/main.js`:

```erb
<%= javascript_include_tag "http://example.com/main.js" %>
```

#### Присоединение файлов CSS с помощью `stylesheet_link_tag`

Хелпер `stylesheet_link_tag` возвращает HTML-тег `<link>` для каждого предоставленного источника.

При использовании Rails с включенным "Asset Pipeline", этот хелпер сгенерирует ссылку на `/assets/stylesheets/`. Эта ссылка будет затем обработана гемом Sprockets. Файл таблицы стилей может быть размещен в одном из трех мест расположения: `app/assets`, `lib/assets` или `vendor/assets`.

Можно определить полный путь относительно корня документа или URL. Например, на файл таблицы стилей в директории `stylesheets`, размещенной в одной из `app/assets`, `lib/assets` или `vendor/assets`, можно сослаться так:

```erb
<%= stylesheet_link_tag "main" %>
```

Чтобы включить `app/assets/stylesheets/main.css` и `app/assets/stylesheets/columns.css`:

```erb
<%= stylesheet_link_tag "main", "columns" %>
```

Чтобы включить `app/assets/stylesheets/main.css` и `app/assets/stylesheets/photos/columns.css`:

```erb
<%= stylesheet_link_tag "main", "/photos/columns" %>
```

Чтобы включить `http://example.com/main.css`:

```erb
<%= stylesheet_link_tag "http://example.com/main.css" %>
```

По умолчанию `stylesheet_link_tag` создает ссылки с `media="screen" rel="stylesheet"`. Можно переопределить любое из этих дефолтных значений, указав соответствующую опцию (:media, :rel):

```erb
<%= stylesheet_link_tag "main_print", media: "print" %>
```

#### Присоединение изображений с помощью `image_tag`

Хелпер `image_tag` создает HTML-тег `<img />` для определенного файла. По умолчанию файлы загружаются из `public/images`.

WARNING: Обратите внимание, что нужно указывать расширение изображения.

```erb
<%= image_tag "header.png" %>
```

Вы можете предоставить путь к изображению, если желаете:

```erb
<%= image_tag "icons/delete.gif" %>
```

Вы можете предоставить хэш дополнительных опций HTML:

```erb
<%= image_tag "icons/delete.gif", {height: 45} %>
```

Или альтернативный текст, если пользователь отключил показ изображений в браузере. Если вы не определили явно тег alt, по умолчанию будет указано имя файла с большой буквы и без расширения. Например, эти два тега изображения возвратят одинаковый код:

```erb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", alt: "Home" %>
```

Можете указать специальный тег size в формате "{width}x{height}":

```erb
<%= image_tag "home.gif", size: "50x20" %>
```

В дополнение к вышеописанным специальным тегам, можно предоставить итоговый хэш стандартных опций HTML, таких как `:class` или `:id`, или `:name`:

```erb
<%= image_tag "home.gif", alt: "Go Home",
                          id: "HomeImage",
                          class: "nav_bar" %>
```

#### Присоединение видео с помощью `video_tag`

Хелпер `video_tag` создает тег HTML 5 `<video>` для определенного файла. По умолчанию файлы загружаются из `public/videos`.

```erb
<%= video_tag "movie.ogg" %>
```

Создаст

```erb
<video src="/videos/movie.ogg" />
```

Подобно `image_tag`, можно предоставить путь или абсолютный, или относительный к директории `public/videos`. Дополнительно можно определить опцию `size: "#{width}x#{height}"`, как и в `image_tag`. Теги видео также могут иметь любые опции HTML, определенные в конце (`id`, `class` и др.).

Тег видео также поддерживает все HTML-опции `<video>` через хэш HTML-опций, включая:

* `poster: "image_name.png"`, предоставляет изображение, которое будет отображаться вместо видео прежде, чем оно начнет проигрываться.
* `autoplay: true`, запускает проигрывание видео при загрузке страницы.
* `loop: true`, запускает видео сначала, как только оно достигает конца.
* `controls: true`, предоставляет пользователю поддерживаемую браузером панель управления для взаимодействия с видео.
* `autobuffer: true`, файл видео предварительно загружается для пользователя при загрузке страницы.

Также можно определить несколько видео для проигрывания, передав массив видео в `video_tag`:

```erb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

Это создаст:

```erb
<video>
  <source src="/videos/trailer.ogg" />
  <source src="/videos/movie.ogg" />
</video>
```

#### Присоединение аудиофайлов с помощью `audio_tag`

Хелпер `audio_tag` создает тег HTML 5 `<audio>` для определенного файла. По умолчанию файлы загружаются из `public/audios`.

```erb
<%= audio_tag "music.mp3" %>
```

Если хотите, можете предоставить путь к аудио файлу:

```erb
<%= audio_tag "music/first_song.mp3" %>
```

Также можно предоставить хэш дополнительных опций, таких как `:id`, `:class` и т.д.

Подобно `video_tag`, `audio_tag` имеет специальные опции:

* `autoplay: true`, начинает воспроизведение аудио при загрузке страницы
* `controls: true`, предоставляет пользователю поддерживаемую браузером панель управления для взаимодействия с аудио.
* `autobuffer: true`, файл аудио предварительно загружается для пользователя при загрузке страницы.

### Понимание `yield`

В контексте макета, `yield` определяет раздел, где должно быть вставлено содержимое из вьюхи. Самый простой способ его использования - это иметь один `yield` там, куда вставится все содержимое вьюхи, которая в настоящий момент рендерится:

```html+erb
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

Также можете создать макет с несколькими разделами yield:

```html+erb
<html>
  <head>
  <%= yield :head %>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

Основное тело вьюхи всегда рендериться в неименованный `yield`. Чтобы рендерить содержимое в именованный `yield`, используйте метод `content_for`.

### Использование метода `content_for`

Метод `content_for` позволяет вставлять содержимое в именованный блок `yield` в макете. Например, эта вьюха будет работать с макетом, который вы только что видели:

```html+erb
<% content_for :head do %>
  <title>A simple page</title>
<% end %>

<p>Hello, Rails!</p>
```

Результат рендеринга этой страницы в макет будет таким HTML:

```html+erb
<html>
  <head>
  <title>A simple page</title>
  </head>
  <body>
  <p>Hello, Rails!</p>
  </body>
</html>
```

Метод `content_for` может помочь, когда макет содержит отдельные разделы, такие как боковые панели или футеры, в которые нужно вставить свои блоки содержимого. Это также полезно при вставке тегов, загружающих специфичные для страницы файлы JavaScript или css в хедер макета в целом.

### Использование партиалов

Частичные шаблоны - также называемые "партиалы" - являются еще одним подходом к разделению процесса рендеринга на более управляемые кусочки. С партиалами можно перемещать код для рендеринга определенных частей отклика в свои отдельные файлы.

#### Именование партиалов

Чтобы отрендерить партиал как часть вьюхи, используем метод `render` внутри вьюхи:

```ruby
<%= render "menu" %>
```

Это отрендерит файл, названный `_menu.html.erb` в этом месте в пределах рендерящейся вьюхи. Обратите внимание на начальный символ подчеркивания: файлы партиалов начинаются со знака подчеркивания, чтобы отличать их от обычных вьюх, несмотря на то, что в вызове они указаны без подчеркивания. Это справедливо даже тогда, когда партиалы вызываются из другой папки:

```ruby
<%= render "shared/menu" %>
```

Этот код вытянет партиал из `app/views/shared/_menu.html.erb`.

#### Использование партиалов для упрощения вьюх

Один из способов применения партиалов это использоваться их как эквивалент подпрограмм: способ переместить часть разметки из вьюхи так, чтобы можно было легче понять, что там происходит. Например, у вас может быть такая вьюха:

```erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
...

<%= render "shared/footer" %>
```

Здесь партиалы `_ad_banner.html.erb` и `_footer.html.erb` могут содержать контент, общий для многих страниц приложения. Нет необходимости видеть код этих разделов, чтобы сконцентрироваться на определенной странице.

Как видно из предыдущих разделов данного руководства, `yield` является очень мощным инструментом для очистки ваших макетов. Имейте в виду, что это чистый Ruby, так что можно использовать его практически везде. Например, его можно использовать для соблюдения принципа DRY при определении макета формы для нескольких похожих ресурсов:

* `users/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |f| %>
      <p>
        Name contains: <%= f.text_field :name_contains %>
      </p>
    <% end %>
    ```

* `roles/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |f| %>
      <p>
        Title contains: <%= f.text_field :title_contains %>
      </p>
    <% end %>
    ```

* `shared/_search_filters.html.erb`

    ```html+erb
    <%= form_for(search) do |f| %>
      <h1>Search form:</h1>
      <fieldset>
        <%= yield f %>
      </fieldset>
      <p>
        <%= f.submit "Search" %>
      </p>
    <% end %>
    ```

TIP: Для содержимого, общего для всех страниц приложения, можно использовать партиалы прямо в макетах.

#### Макеты партиала

Партиал может использовать свой собственный файл макета, подобно тому, как вьюха может использовать макет. Например, можете вызвать подобный партиал:

```erb
<%= render partial: "link_area", layout: "graybar" %>
```

Это найдет партиал с именем `_link_area.html.erb` и отрендерит его, используя макет `_graybar.html.erb`. Отметьте, что макеты для партиалов также начинаются с подчеркивания, как и обычные партиалы, и размещаются в той же папке с партиалами, которым они принадлежат (не в основной папке `layouts`).

Также отметьте, что явное указание `partial` необходимо, когда передаются дополнительные опции, такие как `layout`

#### Передача локальных переменных

В партиалы также можно передавать локальные переменные, что делает их более мощными и гибкими. Например, можете использовать такую технику для уменьшения дублирования между страницами new и edit, сохранив немного различающееся содержимое:

* `new.html.erb`

    ```erb
    <h1>New zone</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `edit.html.erb`

    ```erb
    <h1>Editing zone</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `_form.html.erb`

    ```erb
    <%= form_for(zone) do |f| %>
      <p>
        <b>Zone name</b><br>
        <%= f.text_field :name %>
      </p>
      <p>
        <%= f.submit %>
      </p>
    <% end %>
    ```

Хотя тот же самый партиал будет отрендерен в обоих вьюхах, Action View отправит хелпер, который возвратит "Create Zone" для экшна new и "Update Zone" для экшна edit.

Для передачи локальной переменной в партиал только в особых случаях, используйте `local_assigns`.

* `index.html.erb`

  ```erb
  <%= render user.articles %>
  ```

* `show.html.erb`

  ```erb
  <%= render article, full: true %>
  ```

* `_article.html.erb`

  ```erb
  <h2><%= article.title %></h2>

  <% if local_assigns[:full] %>
    <%= simple_format article.body %>
  <% else %>
    <%= truncate article.body %>
  <% end %>
  ```

Таким образом, можно использовать партиал без необходимости объявления всех локальных переменных.

Каждый партиал также имеет локальную переменную с именем, как у партиала (без начального символа подчеркивания). Можете передать объект в эту локальную переменную через опцию `:object`:

```erb
<%= render partial: "customer", object: @new_customer %>
```

В партиале `customer` переменная `customer` будет указывать на `@new_customer` из родительской вьюхи.

Если есть экземпляр модели для рендеринга в партиале, можно использовать сокращенный синтаксис:

```erb
<%= render @customer %>
```

Предположим, что переменная экземпляра `@customer` содержит экземпляр модели `Customer`. Эта переменная будет использовать `_customer.html.erb` для рендеринга модели и передаст локальную переменную `customer` в партиал, на который будет ссылаться на переменная экземпляра `@customer` в родительской вьюхе.

#### Рендеринг коллекций

Партиалы часто используют для рендеринга коллекций. Когда коллекция передается в партиал с помощью опции `:collection`, партиал будет вставлен один раз для каждого члена коллекции:

* `index.html.erb`

    ```erb
    <h1>Products</h1>
    <%= render partial: "product", collection: @products %>
    ```

* `_product.html.erb`

    ```erb
    <p>Product Name: <%= product.name %></p>
    ```

Когда партиал вызывается с коллекцией во множественном числе, то каждый отдельный экземпляр партиала имеет доступ к члену коллекции, подлежащей рендерингу, через переменную с именем партиала. В нашем случает партиал `_product`, и в партиале `_product` можете обращаться к `product` для получения экземпляра, который рендерится.

Имеется также сокращенная запись для этого. Предположив, что `@products` является коллекцией экземпляров `product`, можно просто написать так в `index.html.erb` и получить аналогичный результат:

```html+erb
<h1>Products</h1>
<%= render @products %>
```

Rails определяет имя партиала, изучая имя модели в коллекции. Фактически, можно даже создать гетерогенную коллекцию и рендерить ее таким образом, и Rails подберет подходящий партиал для каждого члена коллекции:

* `index.html.erb`

    ```erb
    <h1>Contacts</h1>
    <%= render [customer1, employee1, customer2, employee2] %>
    ```

* `customers/_customer.html.erb`

    ```erb
    <p>Customer: <%= customer.name %></p>
    ```

* `employees/_employee.html.erb`

    ```erb
    <p>Employee: <%= employee.name %></p>
    ```

В этом случае Rails использует партиалы customer или employee по мере необходимости для каждого члена коллекции.

В случае, если коллекция пустая, `render` возвратит nil, поэтому очень просто предоставить альтернативное содержимое.

```erb
<h1>Products</h1>
<%= render(@products) || "There are no products available." %>
```

#### Локальные переменные

Чтобы использовать пользовательские имена локальных переменных в партиале, определите опцию `:as` в вызове партиала:

```erb
<%= render partial: "product", collection: @products, as: :item %>
```

С этим изменением можете получить доступ к экземпляру коллекции `@products` через локальную переменную `item` в партиале.

Также можно передавать произвольные локальные переменные в любой партиал, который рендерится с помощью опции `locals: {}`:

```erb
<%= render partial: "product", collection: @products,
           as: :item, locals: {title: "Products Page"} %>
```

В этом случае, партиал имеет доступ к локальной переменной `title` со значением "Products Page".

TIP: Rails также создает переменную счетчика, доступную в партиале, вызываемом коллекцией, названную именем заголовка партиала с добавленным `_counter`. Например, при рендеринге коллекции `@products` партиал `_product.html.erb` может получить доступ к переменной `product_counter`, которая индексирует количество раз, сколько оно было отрендерено во внешнюю вьюху.

Также можно определить второй партиал, который будет отрендерен между экземплярами главного партиала, используя опцию `:spacer_template`:

#### Разделяющие шаблоны

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails отрендерит партиал `_product_ruler` (без переданных в него данных) между каждой парой партиалов `_product`.

#### Макеты коллекции партиала

При рендеринге коллекций также возможно использовать опцию `:layout`:

```erb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

Макет будет отрендерен вместе с партиалом для каждого элемента коллекции. Переменные текущего объекта и object_counter также будут доступны в макете, как это происходит в партиале.

### Использование вложенных макетов

Возможно, ваше приложение потребует макет, немного отличающийся от обычного макета приложения, для поддержки одного определенного контроллера. Вместо повторения главного макета и редактирования его, можете выполнить это с помощью вложенных макетов (иногда называемых подшаблонами). Вот пример:

Предположим, имеется макет `ApplicationController`:

* `app/views/layouts/application.html.erb`

    ```erb
    <html>
    <head>
      <title><%= @page_title or "Page Title" %></title>
      <%= stylesheet_link_tag "layout" %>
      <style><%= yield :stylesheets %></style>
    </head>
    <body>
      <div id="top_menu">Top menu items here</div>
      <div id="menu">Menu items here</div>
      <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
    </body>
    </html>
    ```

На страницах, сгенерированных `NewsController`, допустим, нужно спрятать верхнее меню и добавить правое меню:

* `app/views/layouts/news.html.erb`

    ```erb
    <% content_for :stylesheets do %>
      #top_menu {display: none}
      #right_menu {float: right; background-color: yellow; color: black}
    <% end %>
    <% content_for :content do %>
      <div id="right_menu">Right menu items here</div>
      <%= content_for?(:news_content) ? yield(:news_content) : yield %>
    <% end %>
    <%= render template: "layouts/application" %>
    ```

Вот и все. Вьюхи News будут использовать новый макет, прячущий верхнее меню и добавляющий новое правое меню в "content" div.

Существует несколько способов получения похожих результатов с различными подшаблонными схемами, используя эту технику. Отметьте, что нет ограничений на уровень вложенности. Можно использовать метод `ActionView::render` через `render template: 'layouts/news'`, чтобы создать новый макет на основе макета News. Если есть уверенность, что не понадобятся подшаблоны для макета `News`, можно заменить строку `content_for?(:news_content) ? yield(:news_content) : yield` простым `yield`.
