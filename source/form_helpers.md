Хелперы форм в Action View
==========================

Формы - это обычный интерфейс в веб-приложениях. Однако, разметка форм может быть нудной в написании и поддержке из-за необходимости обрабатывать элементы управления формы, имена и атрибуты. Rails упрощает это, предоставляя вспомогательные методы для вью, которые генерируют HTML-разметку форм. Это руководство поможет вам понять различные вспомогательные методы и когда использовать каждый из них.

После прочтения этого руководства, вы узнаете:

* Как создать простые формы, такие как форма поиска.
* Как работать с формами на основе моделей для создания и редактирования конкретных записей базы данных.
* Как сгенерировать списки выбора (select box) с различными типами данных
* Какие хелперы даты и времени предоставляет Rails
* В чем особенность формы загрузки файлов
* Как отправлять формы на внешние ресурсы и указывать настройку `authenticity_token`.
* Как создавать сложные формы

Это руководство не является подробным списком всех доступных хелперов форм. Обратитесь к [документации по Rails API](https://api.rubyonrails.org/classes/ActionView/Helpers.html) за полным списком хелперов форм и их аргументов.

Работа с простыми формами
-------------------------

Главный хелпер форм - это [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with).

```erb
<%= form_with do |form| %>
  Содержимое формы
<% end %>
```

При вызове без аргументов, он создает HTML-тег `<form>` со значением атрибута `method`, установленным на `post`, и значением атрибута `action`, установленным на текущую страницу. Например, предполагая, что текущая страница является домашней страницей по адресу `/home`, сгенерированный HTML будет выглядеть следующим образом:

```html
<form action="/home" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="Lz6ILqUEs2CGdDa-oz38TqcqQORavGnbGkG0CQA8zc8peOps-K7sHgFSTPSkBx89pQxh3p5zPIkjoOTiA_UWbQ" autocomplete="off">
  Содержимое формы
</form>
```

Обратите внимание, что форма содержит элемент `input` с типом `hidden`. Этот скрытый элемент ввода `authenticity_token` требуется для отправки форм, отличных от GET. Этот токен является функцией безопасности в Rails, используемой для предотвращения атак подделки межсайтовых запросов (CSRF), и хелперы форм автоматически генерируют его для каждой формы, отличной от GET (при условии, что функция безопасности включена). Вы можете прочитать об этом подробнее в руководстве [Безопасность приложений на Rails](/security#cross-site-request-forgery-csrf).

### Характерная форма поиска

Одной из наиболее простых форм в вебе является форма поиска. Эта форма содержит:

* элемент формы с методом "GET",
* метку для поля ввода,
* элемент поля ввода текста и
* элемент отправки.

Вот как создать форму поиска с помощью `form_with`:

```erb
<%= form_with url: "/search", method: :get do |form| %>
  <%= form.label :query, "Search for:" %>
  <%= form.text_field :query %>
  <%= form.submit "Search" %>
<% end %>
```

Это сгенерирует следующий HTML:

```html
<form action="/search" accept-charset="UTF-8" method="get">
  <label for="query">Search for:</label>
  <input type="text" name="query" id="query">
  <input type="submit" name="commit" value="Search" data-disable-with="Search">
</form>
```

Обратите внимание, что для поисковой формы мы используем опцию `url` метода `form_with`. Установка `url: "/search"` изменяет значение атрибута action формы со значения по умолчанию (путь текущей страницы) на `action="/search"`.

В общем случае, передача `url: my_path` в `form_with` указывает форме, куда отправлять запрос. Другим вариантом является передача объектов Active Model в форму, как вы узнаете [ниже](#creating-forms-with-model-objects). Вы также можете использовать [хелперы URL](/routing#path-and-url-helpers).

В приведенном выше примере поисковой формы также показан объект [построитель форм](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html). О множестве хелперов, предоставляемых объектом построителя форм (например, `form.label` и `form.text_field`), вы узнаете в следующем разделе.

TIP: Для каждого элемента `input` формы из его названия генерируется атрибут `id` (`"query"` в приведенном выше примере). Эти идентификаторы могут быть очень полезны для стилизации CSS или манипулирования элементами управления формы с помощью JavaScript.

IMPORTANT: Для поисковых форм используйте метод "GET". В целом, соглашения Rails рекомендуют использовать правильный HTTP-метод для экшнов контроллера. Использование "GET" для поиска позволяет пользователям добавлять конкретный поиск в закладки.

### Хелперы для генерации элементов формы

Объект построителя формы, вкладываемый `form_with`, предоставляет множество вспомогательных методов для генерации обычных элементов формы, таких как чекбоксы, текстовые поля и радиокнопки.

Первый аргумент для этих методов всегда является именем ввода. Это полезно помнить, потому что при отправке формы это имя будет передано контроллеру вместе с данными формы в хэше `params`. Имя будет ключом в `params` для значения, введенного пользователем для этого поля.

Например, если форма содержит `<%= form.text_field :query %>`, то вы сможете получить значение этого поля в контроллере с помощью `params[:query]`.

При именовании полей ввода Rails использует определенные соглашения, делающие возможным отправлять параметры с нескалярными величинами, такими как массивы и хэши, которые также будут доступны в `params`. Подробнее об этом можно прочесть в разделе [Соглашения по именованию полей ввода формы и хэш `params`](#form-input-naming-conventions-and-params-hash). Для подробностей по точному использованию этих хелперов, обратитесь к [документации по API](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).

#### Чекбоксы

Чекбокс - это элемент управления формой, который позволяет выбрать или снять один параметр. Группа чекбоксов обычно используется для того, чтобы пользователь мог выбрать один или несколько вариантов из группы.

Вот пример с тремя чекбоксами в форме:

```erb
<%= form.checkbox :biography %>
<%= form.label :biography, "Biography" %>
<%= form.checkbox :romance %>
<%= form.label :romance, "Romance" %>
<%= form.checkbox :mystery %>
<%= form.label :mystery, "Mystery" %>
```

Вышеуказанное сгенерирует следующее:

```html
<input name="biography" type="hidden" value="0" autocomplete="off"><input type="checkbox" value="1" name="biography" id="biography">
<label for="biography">Biography</label>
<input name="romance" type="hidden" value="0" autocomplete="off"><input type="checkbox" value="1" name="romance" id="romance">
<label for="romance">Romance</label>
<input name="mystery" type="hidden" value="0" autocomplete="off"><input type="checkbox" value="1" name="mystery" id="mystery">
<label for="mystery">Mystery</label>
```

Первый параметр [`checkbox`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-checkbox) — это имя элемента ввода, который можно найти в хэше `params`. Если пользователь выбрал только чекбокс "Biography", хэш `params` будет содержать:

```ruby
{
  "biography" => "1",
  "romance" => "0",
  "mystery" => "0"
}
```

Вы можете использовать `params[:biography]`, чтобы проверить, установлен ли этот чекбокс пользователем.

Значения чекбокса (значений, которые появятся в `params`), можно необязательно указать с помощью параметров `checked_value` и `unchecked_value`. Более подробную информацию смотрите в [документации API](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-checkbox).

Существует также `collection_checkboxes`, о котором вы можете узнать в разделе [Вспомогательные методы, связанные с коллекциями](#collection-related-helpers).

#### Радиокнопки

Радиокнопки - это элементы управления формами, которые позволяют пользователю выбрать только один вариант из списка доступных.

Например, радиокнопки для выбора любимого вкуса мороженого:

```erb
<%= form.radio_button :flavor, "chocolate_chip" %>
<%= form.label :flavor_chocolate_chip, "Chocolate Chip" %>
<%= form.radio_button :flavor, "vanilla" %>
<%= form.label :flavor_vanilla, "Vanilla" %>
<%= form.radio_button :flavor, "hazelnut" %>
<%= form.label :flavor_hazelnut, "Hazelnut" %>
```

Вышеуказанное сгенерирует следующий HTML-код:

```html
<input type="radio" value="chocolate_chip" name="flavor" id="flavor_chocolate_chip">
<label for="flavor_chocolate_chip">Chocolate Chip</label>
<input type="radio" value="vanilla" name="flavor" id="flavor_vanilla">
<label for="flavor_vanilla">Vanilla</label>
<input type="radio" value="hazelnut" name="flavor" id="flavor_hazelnut">
<label for="flavor_hazelnut">Hazelnut</label>
```

Второй аргумент для [`radio_button`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-radio_button) - это значение поля ввода. Так как эти радиокнопки имеют одинаковое имя (`flavor`), пользователь может выбрать одну, и `params[:flavor]` будет содержать `"chocolate_chip"`, `"vanilla"` или `hazelnut`.

NOTE: Всегда используйте метки (labels) для чекбоксов и радиокнопок. Они связывают текст с определенной опцией с помощью атрибута `for` и, предоставляя большее пространство для клика, упрощают выбор пользователем нужного пункта радиокнопки.

### (other-helpers-of-interest) Другие интересные хелперы

Существует множество других элементов управления формами, включая текст, электронную почту, пароль, дату и время. Примеры ниже показывают некоторые другие хелперы и их сгенерированный HTML.

Хелперы, связанные с датой и временем:

```erb
<%= form.date_field :born_on %>
<%= form.time_field :started_at %>
<%= form.datetime_local_field :graduation_day %>
<%= form.month_field :birthday_month %>
<%= form.week_field :birthday_week %>
```

Результат:

```html
<input type="date" name="born_on" id="born_on">
<input type="time" name="started_at" id="started_at">
<input type="datetime-local" name="graduation_day" id="graduation_day">
<input type="month" name="birthday_month" id="birthday_month">
<input type="week" name="birthday_week" id="birthday_week">
```

Хелперы со специальным форматированием:

```erb
<%= form.password_field :password %>
<%= form.email_field :address %>
<%= form.telephone_field :phone %>
<%= form.url_field :homepage %>
```

Результат:

```html
<input type="password" name="password" id="password">
<input type="email" name="address" id="address">
<input type="tel" name="phone" id="phone">
<input type="url" name="homepage" id="homepage">
```

Другие обычные хелперы:

```erb
<%= form.textarea :message, size: "70x5" %>
<%= form.hidden_field :parent_id, value: "foo" %>
<%= form.number_field :price, in: 1.0..20.0, step: 0.5 %>
<%= form.range_field :discount, in: 1..100 %>
<%= form.search_field :name %>
<%= form.color_field :favorite_color %>
```

Результат:

```html
<textarea name="message" id="message" cols="70" rows="5"></textarea>
<input value="foo" autocomplete="off" type="hidden" name="parent_id" id="parent_id">
<input step="0.5" min="1.0" max="20.0" type="number" name="price" id="price">
<input min="1" max="100" type="range" name="discount" id="discount">
<input type="search" name="name" id="name">
<input value="#000000" type="color" name="favorite_color" id="favorite_color">
```

Скрытые поля не отображаются пользователю, вместо этого они содержат данные, как и любое текстовое поле. Их значения могут быть изменены с помощью JavaScript.

TIP: Если используются поля для ввода пароля, вы можете настроить свое приложение для предотвращения появления их значений в логах приложения. Это можно изучить в руководстве [Безопасность приложений на Rails](/security).

(creating-forms-with-model-objects) Создание форм с помощью объектов модели
---------------------------------------------------------------------------

### Привязывание формы к объекту

Хелпер `form_with` имеет опцию `:model`, которая позволяет связать объект конструктора формы с объектом модели. Это означает, что форма будет связана с этим объектом модели, а поля формы будут заполнены значениями из этого объекта модели.

К примеру, если у нас есть объект модели `@book`:

```ruby
@book = Book.find(42)
# => #<Book id: 42, title: "Walden", author: "Henry David Thoreau">
```

И следующая форма для создания новой книги:

```erb
<%= form_with model: @book do |form| %>
  <div>
    <%= form.label :title %>
    <%= form.text_field :title %>
  </div>
  <div>
    <%= form.label :author %>
    <%= form.text_field :author %>
  </div>
  <%= form.submit %>
<% end %>
```

Сгенерирует такой HTML:

```html
<form action="/books" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="ChwHeyegcpAFDdBvXvDuvbfW7yCA3e8gvhyieai7DhG28C3akh-dyuv-IBittsjPrIjETlQQvQJ91T77QQ8xWA" autocomplete="off">
  <div>
    <label for="book_title">Title</label>
    <input type="text" name="book[title]" id="book_title">
  </div>
  <div>
    <label for="book_author">Author</label>
    <input type="text" name="book[author]" id="book_author">
  </div>
  <input type="submit" name="commit" value="Create Book" data-disable-with="Create Book">
</form>
```

Некоторые важные моменты при использовании `form_with` с объектом модели:

* `action` формы автоматически заполняется подходящим значением, `action="/books"`. Если бы вы обновляли книгу, это было бы `action="/books/42"`.
* Имена полей формы имеют область видимости `book[...]`. Это означает, что `params[:book]` будет хешем, содержащим значения всех этих полей. Вы можете узнать больше о значении имен ввода в разделе [про именование параметров](#form-input-naming-conventions-and-params-hash) этого руководства.
* Кнопке отправки автоматически присваивается подходящее текстовое значение, в данном случае "Create Book".

СОВЕТ: Обычно ваши поля ввода формы будут отражать атрибуты модели. Однако это не обязательно. Если вам нужна другая информация, вы можете включить поле в свою форму и получить доступ к нему через `params[:book][:my_non_attribute_input]`.

#### Формы c составным первичным ключом

Если у вас есть модель с [TODO: составным первичным ключом](/active_record_composite_primary_keys), синтаксис построения формы такой же, но с небольшими отличиями в выводе.

Например, для обновления объекта модели `@book` с составным ключом `[:author_id, :id]` следующим образом:

```ruby
@book = Book.find([2, 25])
# => #<Book id: 25, title: "Some book", author_id: 2>
```

Следующая форма:

```erb
<%= form_with model: @book do |form| %>
  <%= form.text_field :title %>
  <%= form.submit %>
<% end %>
```

Сгенерирует этот вывод HTML:

```html
<form action="/books/2_25" method="post" accept-charset="UTF-8" >
  <input name="authenticity_token" type="hidden" value="ChwHeyegcpAFDdBvXvDuvbfW7yCA3e8gvhyieai7DhG28C3akh-dyuv-IBittsjPrIjETlQQvQJ91T77QQ8xWA" />
  <input type="text" name="book[title]" id="book_title" value="Some book" />
  <input type="submit" name="commit" value="Update Book" data-disable-with="Update Book">
</form>
```

Обратите внимание, что сгенерированный URL содержит `author_id` и `id`, разделенные подчеркиванием. После отправки контроллер может извлечь каждое значение первичного ключа [извлечь каждое значение первичного ключа](/action-controller-overview#composite-key-parameters) из параметров и обновить запись, как это делается с одиночным первичным ключом.

#### Хелпер `fields_for`

Хелпер `fields_for` используется для отображения полей для связанных объектов модели в одной и той же форме. Связанная "внутренняя" модель обычно связана с "основной" моделью формы через связь Active Record. Например, если имеется модель `Person` со связанной моделью `ContactDetail`, можно создать форму для создания обеих моделей подобным образом:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <%= fields_for :contact_detail, @person.contact_detail do |contact_detail_form| %>
    <%= contact_detail_form.text_field :phone_number %>
  <% end %>
<% end %>
```

Вышеуказанное выдаст такой результат:

```html
<form action="/people" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="..." autocomplete="off" />
  <input type="text" name="person[name]" id="person_name" />
  <input type="text" name="contact_detail[phone_number]" id="contact_detail_phone_number" />
</form>
```

Объект, предоставляемый `fields_for` - это форм-билдер, подобный тому, который предоставляется `form_with`. Хелпер `fields_for` создает похожее связывание, но не отрисовывает тег `<form>`. Вы можете узнать больше о `field_for` в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-fields_for).

### (relying-on-record-identification) Положитесь на идентификацию записи

При работе с RESTful ресурсами вызовы `form_with` можно упростить, используя **идентификацию записей**. Это означает, что вы передаете экземпляр модели и позволяете Rails определить имя модели, метод и другие вещи. В приведенном ниже примере для создания новой записи оба вызова `form_with` генерируют одинаковый HTML:

```ruby
# долгий способ:
form_with(model: @article, url: articles_path)
# сокращение:
form_with(model: @article)
```

Аналогично, для редактирования существующей статьи, как показано ниже, оба вызова `form_with` также будут генерировать одинаковый HTML:

```ruby
# долгий способ:
form_with(model: @article, url: article_path(@article), method: "patch")
# сокращение:
form_with(model: @article)
```

Отметьте, что вызов сокращения `form_with` является идентичным, независимо от того, запись новая или уже существует. Идентификация записи достаточно сообразительная, чтобы выяснить, новая ли запись, запрашивая [`record.persisted?`](https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-persisted-3F). Она также выбирает правильный путь для подтверждения и имя, основанное на классе объекта.

Это предполагает, что модель `Article` объявлена с `resources :articles` в файле маршрутов.

Если у вас [одиночный ресурс](/routing#singular-resources), нужно вызвать `resource` и `resolve` для работы с `form_with`:

```ruby
resource :article
resolve('Article') { [:article] }
```

TIP: Объявление ресурса имеет ряд побочных эффектов. Смотрите руководство [Rails Routing from the Outside In](/routing#resource-routing-the-rails-default) для получения дополнительной информации о настройке и использовании ресурсов.

WARNING: Когда используется [наследование с единой таблицей](/active-record-associations#single-table-inheritance-sti) с вашими моделями, нельзя полагаться на идентификацию записей подкласса, если только их родительский класс определен ресурсом. Необходимо явно указывать `:url` и `:scope` (имя модели).

### Работа с пространствами имен

Если имеется пространство имен для маршрутов, в `form_with` также есть сокращение для этого. Например, сли в приложении есть пространство имен `admin`:

```ruby
form_with model: [:admin, @article]
```

Вышеуказанное создаст форму, которая передается `ArticlesController` в пространстве имен admin, следовательно в `admin_article_path(@article)` в случае с обновлением.

Если у вас несколько уровней пространства имен, тогда синтаксис подобный:

```ruby
form_with model: [:admin, :management, @article]
```

Более подробно о системе маршрутизации Rails и связанным соглашениям смотрите руководство [Роутинг в Rails](/routing).

### Формы с методами PATCH, PUT или DELETE

Фреймворк Rails поддерживает стиль RESTful, что подразумевает, что формы в ваших приложениях будут делать запросы, где `method` `PATCH`, `PUT` или `DELETE`, в дополнение к `GET` и `POST`. Однако, формы HTML _не поддерживают_ методы, отличные от `GET` и `POST`, когда дело доходит до подтверждения форм.

Rails работает с этим ограничением, эмулируя другие методы с помощью POST со скрытым полем, названным `"_method"`. Например:

```ruby
form_with(url: search_path, method: "patch")
```

Вышеуказанная форма сгенерирует результирующий HTML:

```html
<form action="/search" accept-charset="UTF-8" method="post">
  <input type="hidden" name="_method" value="patch" autocomplete="off">
  <input type="hidden" name="authenticity_token" value="R4quRuXQAq75TyWpSf8AwRyLt-R1uMtPP1dHTTWJE5zbukiaY8poSTXxq3Z7uAjXfPHiKQDsWE1i2_-h0HSktQ" autocomplete="off">
<!-- ... -->
</form>
```

При парсинге данных, отправленных с помощью POST, Rails принимает во внимание специальный параметр `_method` и продолжает обработку, как если бы метод HTTP-запроса был тем, что установлен в `_method` (`PATCH` в этом примере).

При рендере формы кнопки отправки могут переопределять атрибут `method` с помощью ключевого слова `formmethod:`:

```erb
<%= form_with url: "/posts/1", method: :patch do |form| %>
  <%= form.button "Delete", formmethod: :delete, data: { confirm: "Are you sure?" } %>
  <%= form.button "Update" %>
<% end %>
```

Как и для элементов `<form>`, многие браузеры _не поддерживают_ переопределение методов формы, объявленные с помощью [formmethod][], отличные от `GET` и `POST`.

Rails обходит эту проблему, эмулируя остальные методы на основе POST с помощью комбинации атрибутов [formmethod][], [value][button-value] и [name][button-name]:

```html
<form accept-charset="UTF-8" action="/posts/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->

  <button type="submit" formmethod="post" name="_method" value="delete" data-confirm="Are you sure?">Delete</button>
  <button type="submit" name="button">Update</button>
</form>
```

В этом случае кнопка "Update" будет обрабатываться как `PATCH`, а кнопка "Delete" - как `DELETE`.

[formmethod]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-formmethod
[button-name]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-name
[button-value]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-value

Легкое создание списков выбора
------------------------------

Список выбора, также известный как раскрывающийся список, позволяют пользователям выбирать из списка вариантов. HTML для полей выбора требует значительного количества разметки - один элемент `<option>` для каждого варианта на выбор. Rails предоставляет вспомогательные методы для создания этой разметки.

Например, скажем у нас есть список городов для выбора пользователем. Можно использовать хелпер [`select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-select):

```erb
<%= form.select :city, ["Berlin", "Lisbon", "Madrid"] %>
```

Вышеуказанное сгенерирует результирующий HTML:

```html
<select name="city" id="city">
  <option value="Berlin">Berlin</option>
  <option value="Chicago">Chicago</option>
  <option value="Madrid">Madrid</option>
</select>
```

И выбранное значение будет доступно в `params[:city]` как обычно.

Можно указать значения `<option>` отличные от их надписи:

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
```

Результат:

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

Таким образом, пользователь увидит полные имена городов, но `params[:city]` будет одним из `"BE"`, `"CHI"` или `"MD"`.

Наконец, можно указать выбор по умолчанию для списка выбора с помощью аргумента `:selected`:

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]], selected: "CHI" %>
```

Результат:

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI" selected="selected">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

### Группы опций для списка выборов

Иногда нужно улучшить пользовательский опыт, сгруппировав вместе схожие опции. Это можно сделать, передав `Hash` (ли совместимый `Array`) в `select`:

```erb
<%= form.select :city,
      {
        "Europe" => [ ["Berlin", "BE"], ["Madrid", "MD"] ],
        "North America" => [ ["Chicago", "CHI"] ],
      },
      selected: "CHI" %>
```

Результат:

```html
<select name="city" id="city">
  <optgroup label="Europe">
    <option value="BE">Berlin</option>
    <option value="MD">Madrid</option>
  </optgroup>
  <optgroup label="North America">
    <option value="CHI" selected="selected">Chicago</option>
  </optgroup>
</select>
```

### Привязка списков выбора к объектам модели

Подобно другим элементам формы, список выбора может быть связан с атрибутом модели. Например, если имеется такой объект модели `@person`:

```ruby
@person = Person.new(city: "MD")
```

Следующая форма:

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
<% end %>
```

Выведет подобный список выбора:

```html
<select name="person[city]" id="person_city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD" selected="selected">Madrid</option>
</select>
<% end %>
```

Единственное отличие заключается в том, что выбранный вариант будет найден в `params[:person][:city]` вместо `params[:city]`.

Отметьте, что подходящая опция была автоматически отмечена `selected="selected"`. Так как этот список выбора был привязан к существующей записи `@person`, не нужно указывать аргумент `:selected`!

Использование хелперов даты и времени
-------------------------------------

Кроме хелперов `date_field` и `time_field`, упомянутых [ранее](#other-helpers-of-interest), Rails предоставляет альтернативные хелперы для форм даты и времени, которые отображают обычные списки выбора. Хелпер `date_select` отображает отдельный список выбора для года, месяца и дня.

Например, если у нас есть такой объект модели `@person`:

```ruby
@person = Person.new(birth_date: Date.new(1995, 12, 21))
```

Следующая форма:

```erb
<%= form_with model: @person do |form| %>
  <%= form.date_select :birth_date %>
<% end %>
```

Выведет списки выбора наподобие:

```html
<select name="person[birth_date(1i)]" id="person_birth_date_1i">
  <option value="1990">1990</option>
  <option value="1991">1991</option>
  <option value="1992">1992</option>
  <option value="1993">1993</option>
  <option value="1994">1994</option>
  <option value="1995" selected="selected">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999">1999</option>
  <option value="2000">2000</option>
</select>
<select name="person[birth_date(2i)]" id="person_birth_date_2i">
  <option value="1">January</option>
  <option value="2">February</option>
  <option value="3">March</option>
  <option value="4">April</option>
  <option value="5">May</option>
  <option value="6">June</option>
  <option value="7">July</option>
  <option value="8">August</option>
  <option value="9">September</option>
  <option value="10">October</option>
  <option value="11">November</option>
  <option value="12" selected="selected">December</option>
</select>
<select name="person[birth_date(3i)]" id="person_birth_date_3i">
  <option value="1">1</option>
  ...
  <option value="21" selected="selected">21</option>
  ...
  <option value="31">31</option>
</select>
```

Отметьте, что при отправке формы не будет одиночного значения в хэше `params`. содержащего полную дату. Вместо этого будет несколько значений со специальными именами наподобие `"birth_date(1i)"`. Однако, Active Record знает, как собрать эти значения в полную дату или время, основываясь на объявленном типе атрибута модели. Таким образом, можно просто передать `params[:person]` в `Person.new` или `Person#update`, как будто бы форма использовала единственное поле, представляющее полную дату.

В дополнение к хелперу [`date_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-date_select), Rails предоставляет [`time_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_select), выводящий списки выбора для часа и минуты. Также имеется [`datetime_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-datetime_select), который объединяет оба списка выбора даты и времени.

### Списки выбора для компонентов времени или даты

Rails также предоставляет хелперы для рендера списков выбора для отдельных компонентов времени или даты: [`select_year`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_year), [`select_month`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_month), [`select_day`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_day), [`select_hour`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_hour), [`select_minute`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_minute) и [`select_second`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_second). Эти хелперы являются "чистыми" методами, что означает, что они не вызываются на экземпляре построителя формы. Например:

```erb
<%= select_year 2024, prefix: "party" %>
```

Вышеуказанное выведет подобный список выбора

```html
<select id="party_year" name="party[year]">
  <option value="2019">2019</option>
  <option value="2020">2020</option>
  <option value="2021">2021</option>
  <option value="2022">2022</option>
  <option value="2023">2023</option>
  <option value="2024" selected="selected">2024</option>
  <option value="2025">2025</option>
  <option value="2026">2026</option>
  <option value="2027">2027</option>
  <option value="2028">2028</option>
  <option value="2029">2029</option>
</select>
```

Для каждого из этих хелперов вы можете указать объект `Date` или `Time` вместо числа в качестве значения по умолчанию (например, `<%= select_year Date.today, prefix: "party" %>` вместо приведенного выше), при этом будут извлечены соответствующие части даты и времени и использованы.

### Выбор часового пояса

Когда вам нужно спросить пользователей, в каком часовом поясе они находятся, есть очень удобный хелпер [`time_zone_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_zone_select), который можно использовать.

Обычно вам пришлось бы предоставлять список вариантов часовых поясов для выбора пользователями. Это может быть утомительно, если бы не список предопределенных объектов [`ActiveSupport::TimeZone`](https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html). Хелпер `time_with_zone` оборачивает это и может быть использован следующим образом:

```erb
<%= form.time_zone_select :time_zone %>
```

Выведет:

```html
<select name="time_zone" id="time_zone">
  <option value="International Date Line West">(GMT-12:00) International Date Line West</option>
  <option value="American Samoa">(GMT-11:00) American Samoa</option>
  <option value="Midway Island">(GMT-11:00) Midway Island</option>
  <option value="Hawaii">(GMT-10:00) Hawaii</option>
  <option value="Alaska">(GMT-09:00) Alaska</option>
  ...
  <option value="Samoa">(GMT+13:00) Samoa</option>
  <option value="Tokelau Is.">(GMT+13:00) Tokelau Is.</option>
```

(collection-related-helpers) Хелперы, относящиеся к коллекции
-------------------------------------------------------------

Выбор из коллекции произвольных объектов
----------------------------------------

Если нужно создать набор вариантов из коллекции произвольных объектов, в Rails есть хелперы `collection_select`, `collection_radio_button` и `collection_checkboxes`.

Для иллюстрации полезности этих хелперов, допустим у нас есть модель `City` и соответствующая связь `belongs_to :city` с `Person`:

```ruby
class City < ApplicationRecord
end

class Person < ApplicationRecord
  belongs_to :city
end
```

Допустим, у нас есть следующие города, сохраненные в базе данных:

```ruby
City.order(:name).map { |city| [city.name, city.id] }
# => [["Berlin", 1], ["Chicago", 3], ["Madrid", 2]]
```

Можно позволить пользователю выбирать город с помощью следующей формы:

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city_id, City.order(:name).map { |city| [city.name, city.id] } %>
<% end %>
```

Вышеуказанное сгенерирует такой HTML:

```html
<select name="person[city_id]" id="person_city_id">
  <option value="1">Berlin</option>
  <option value="3">Chicago</option>
  <option value="2">Madrid</option>
</select>
```

Вышеприведенный пример показывает, как можно сгенерировать варианты вручную. Однако Rails имеет хелперы, которые генерируют варианты из коллекции без необходимости явно перебирать ее. Эти хелперы определяют значение и текстовую метку каждого варианта, вызывая указанные методы для каждого объекта в коллекции.

NOTE: При рендере поля для связи `belongs_to`, необходимо указать имя внешнего ключа (`city_id` в вышеприведенном примере), а не имя самой связи.

### Хелпер `collection_select`

Чтобы создать список выбора, можно использовать [`collection_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_select):

```erb
<%= form.collection_select :city_id, City.order(:name), :id, :name %>
```

Вышеприведенный вывод совпадает с HTML, полученным при ручном переборе:

```html
<select name="person[city_id]" id="person_city_id">
  <option value="1">Berlin</option>
  <option value="3">Chicago</option>
  <option value="2">Madrid</option>
</select>
```

NOTE: Порядок аргументов для `collection_select` отличается от порядка для `select`. С помощью `collection_select` мы определяем сначала метод значения (`:id` в вышеуказанном примере), а затем метод текстовой надписи (`:name` в вышеуказанном примере). Это отличается от порядка, используемого при указании вариантов для хелпера `select`, когда сначала идет текстовая надпись, а потом значение (`["Berlin", 1]` в предыдущем примере).

### Хелпер `collection_radio_buttons`

Чтобы создать набор радиокнопок, можно использовать [`collection_radio_buttons`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_radio_buttons):

```erb
<%= form.collection_radio_buttons :city_id, City.order(:name), :id, :name %>
```

Выведет:

```html
<input type="radio" value="1" name="person[city_id]" id="person_city_id_1">
<label for="person_city_id_1">Berlin</label>

<input type="radio" value="3" name="person[city_id]" id="person_city_id_3">
<label for="person_city_id_3">Chicago</label>

<input type="radio" value="2" name="person[city_id]" id="person_city_id_2">
<label for="person_city_id_2">Madrid</label>
```

### Хелпер `collection_checkboxes`

Чтобы создать набор чекбоксов — к примеру, чтобы поддерживать связь `has_and_belongs_to_many` — можно использовать [`collection_checkboxes`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_checkboxes):

```erb
<%= form.collection_checkboxes :interest_ids, Interest.order(:name), :id, :name %>
```

Выведет:

```html
<input type="checkbox" name="person[interest_id][]" value="3" id="person_interest_id_3">
<label for="person_interest_id_3">Engineering</label>

<input type="checkbox" name="person[interest_id][]" value="4" id="person_interest_id_4">
<label for="person_interest_id_4">Math</label>

<input type="checkbox" name="person[interest_id][]" value="1" id="person_interest_id_1">
<label for="person_interest_id_1">Science</label>

<input type="checkbox" name="person[interest_id][]" value="2" id="person_interest_id_2">
<label for="person_interest_id_2">Technology</label>
```

(uploading-files) Загрузка файлов
---------------------------------

Обычная задача с формами - это позволить пользователям загружать файл. Это может быть изображение аватара или CSV-файл с данными для обработки. Поля загрузки файлов могут быть отрендерены с помощью хелпера [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field).

```erb
<%= form_with model: @person do |form| %>
  <%= form.file_field :csv_file %>
<% end %>
```

Самое важное, это помнить при загрузке файла, что атрибут `enctype` формы *должен* быть установлен как `multipart/form-data`. Это будет выполнено автоматически, если используете `file_field` внутри `form_with`. Также можно установить этот атрибут самому:

```erb
<%= form_with url: "/uploads", multipart: true do |form| %>
  <%= file_field_tag :csv_file %>
<% end %>
```

Оба из которых выводят следующую HTML-форму:

```html
<form enctype="multipart/form-data" action="/people" accept-charset="UTF-8" method="post">
<!-- ... -->
</form>
```

Обратите внимание, что согласно соглашениям `form_with` имена полей в двух формах выше будут отличаться. В первой форме это будет `person[csv_file]`(доступно через `params[:person][:csv_file]`), а во второй форме это будет просто `csv_file` (доступно через `params[:csv_file]`).

### Пример загрузки CSV-файла

При использовании `file_field`, объект в хэше `params` - это экземпляр [`ActionDispatch::Http::UploadedFile`](https://api.rubyonrails.org/classes/ActionDispatch/Http/UploadedFile.html). Вот пример того, как сохранить данные из загруженного CSV-файла в записи в вашем приложении:

```ruby
  require 'csv'

  def upload
    uploaded_file = params[:csv_file]
    if uploaded_file.present?
      csv_data = CSV.parse(uploaded_file.read, headers: true)
      csv_data.each do |row|
        # Обработка каждого ряда CSV-файла
        # SomeInvoiceModel.create(amount: row['Amount'], status: row['Status'])
        Rails.logger.info row.inspect
        #<CSV::Row "id":"po_1KE3FRDSYPMwkcNz9SFKuaYd" "Amount":"96.22" "Created (UTC)":"2022-01-04 02:59" "Arrival Date (UTC)":"2022-01-05 00:00" "Status":"paid">
      end
    end
    # ...
  end
```

Если файл является изображением, которое необходимо хранить с моделью (например, изображение профиля пользователя), необходимо рассмотреть ряд задач, таких как место хранения файла (на диске, Amazon S3 и т.д.), изменение размера файлов изображений и создание миниатюр и т.д. Для помощи с такими задачами разработан [Active Storage](/active_storage_overview).

Настройка Форм-билдеров (Form Builder)
--------------------------------------

Мы называем объекты, предоставляемые `form_with` или  `fields_for`, Форм-билдерами (Form Builders). Форм-билдеры позволяют вам генерировать элементы формы, связанные с объектом модели, и являются экземпляром [`ActionView::Helpers::FormBuilder`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html). Этот класс можно расширять, чтобы добавлять пользовательские вспомогательные методы для вашего приложения.

Например, если вы хотите отобразить поле `text_field` вместе с меткой `label` по всему вашему приложению, вы можете добавить следующий вспомогательный метод в `application_helper.rb`:

```ruby
module ApplicationHelper
  def text_field_with_label(form, attribute)
    form.label(attribute) + form.text_field(attribute)
  end
end
```

И используйте его в форме как обычно:

```erb
<%= form_with model: @person do |form| %>
  <%= text_field_with_label form, :first_name %>
<% end %>
```

Но вы также можете создать подкласс `ActionView::Helpers::FormBuilder` и добавить хелперы туда. После определения этого подкласса `LabellingFormBuilder`:

```ruby
class LabellingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options = {})
    # super вызовет оригинальный метод text_field
    label(attribute) + super
  end
end
```

Вышеуказанная форма может быть заменена на:

```erb
<%= form_with model: @person, builder: LabellingFormBuilder do |form| %>
  <%= form.text_field :first_name %>
<% end %>
```

Если это используется часто, можно определить хелпер `labeled_form_with` который автоматически определяет опцию `builder: LabellingFormBuilder`:

```ruby
module ApplicationHelper
  def labeled_form_with(**options, &block)
    options[:builder] = LabellingFormBuilder
    form_with(**options, &block)
  end
end
```

Вышеуказанное можно использовать вместо `form_with`:

```ruby
```erb
<%= labeled_form_with model: @person do |form| %>
  <%= form.text_field :first_name %>
<% end %>
```

Все три случая выше (хелпер `text_field_with_label`, подкласс `LabellingFormBuilder` и хелпер `labeled_form_with`) будут генерировать одинаковый HTML:

```html
<form action="/people" accept-charset="UTF-8" method="post">
  <!-- ... -->
  <label for="person_first_name">First name</label>
  <input type="text" name="person[first_name]" id="person_first_name">
</form>
```

Форм-билдер также определяет, что произойдет, если вы сделаете:

```erb
<%= render partial: f %>
```

Если `f` - это экземпляр `ActionView::Helpers::FormBuilder`, тогда это отрендерит партиал `form`, установив объект партиала как форм-билдер. Если у форм-билдера есть класс `LabellingFormBuilder`, тогда вместо него будет отрендерен партиал `labelling_form`.

Настройка форм-билдеров, таких как `LabellingFormBuilder`, позволяет скрыть детали реализации (и может показаться избыточным для простого примера выше). Выбирайте между различными вариантами настройки, расширяя класс `FormBuilder` или создавая хелперы, в зависимости от того, насколько часто ваши формы используют пользовательские элементы.

(form-input-naming-conventions-and-params-hash) Соглашения по именованию полей ввода формы и хэш `params`
---------------------------------------------------------------------------------------------------------

Все описанные выше хелперы для форм помогают генерировать HTML для элементов формы, чтобы пользователь мог вводить различные типы данных. Как получить доступ к значениям пользовательского ввода в контроллере? Ответ - хэш `params`. Вы уже видели хэш `params` в приведенном выше примере. В этом разделе мы более подробно рассмотрим соглашения об именовании, связанные со структурой ввода формы в хэше `params`.

Хэш `params` может содержать массивы и массивы хэшей. Значения могут находиться на верхнем уровне хэша `params` или быть вложенными в другой хэш. Например, в стандартном экшне `create` для модели Person, `params[:person]` будет хэшем всех атрибутов объекта `Person`.

Обратите внимание, что HTML-формы не имеют внутренней структуры для пользовательских данных ввода, они только генерируют строковые пары имя-значение. Массивы и хэши, которые вы видите в своем приложении, являются результатом соглашений об именовании параметров, используемых Rails.

NOTE: Поля в хэше `params` должны быть [разрешены в контроллере](#permitting-parameters-in-the-controller).

### Базовая структура

Две основные структуры для данных пользовательских форм — это массивы и хэши.

Хэши отражают синтаксис, используемый для доступа к значению в `params`. Например, если форма содержит:

```html
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

хэш `params` будет содержать

```ruby
{ 'person' => { 'name' => 'Henry' } }
```

и `params[:person][:name]` получит отправленное значение в контроллере.

Хэши могут быть вложены на столько уровней, сколько требуется, например:

```html
<input id="person_address_city" name="person[address][city]" type="text" value="New York"/>
```

Вышеприведенное вернет такой хэш `params`

```ruby
{ 'person' => { 'address' => { 'city' => 'New York' } } }
```

Другая структура это массив. Обычно Rails игнорирует дублирующиеся имена параметра, но если имя параметра заканчивается пустым набором квадратных скобок `[]`, то параметры будут накоплены в массиве.

Например, если нужно, чтобы пользователи могли оставить несколько телефонных номеров, можно поместить это в форму:

```html
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
```

Что приведет к тому, что `params[:person][:phone_number]` будет массивом, содержащим отправленные телефонные номера.

```ruby
{ 'person' => { 'phone_number' => ['555-0123', '555-0124', '555-0125'] } }
```

### Комбинирование массивов и хэшей

Вы можете комбинировать эти два понятия. Один элемент хэша может быть массивом, как в предыдущем примере, хэш `params[:person]` имеет ключ `[:phone_number]`, значение которого является массивом.

Вы также можете иметь массив хэшей. Например, вы можете создать любое количество адресов, повторяя следующий фрагмент формы:

```html
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
```

Это приведет к тому, что `params[:person][:addresses]` будет массивом хэшей. В каждом хэше в массиве будут ключи `line1`, `line2` и `city`, наподобие:

```ruby
{ 'person' =>
  { 'addresses' => [
    { 'line1' => '1000 Fifth Avenue',
      'line2' => '',
      'city' => 'New York'
    },
    { 'line1' => 'Calle de Ruiz de Alarcón',
      'line2' => '',
      'city' => 'Madrid'
    }
    ]
  }
}
```

Важно отметить, что в то время как хэши могут быть вложены произвольно, является допустимым только один уровень "массивности". Массивы обычно могут быть заменены хэшами. Например, вместо массива объектов модели можно иметь хэш объектов модели с ключами, равными их id или подобному.

WARNING: Параметры массива не очень хорошо работают с хелпером `checkbox`. В соответствии со спецификацией HTML, невыбранные чекбоксы не возвращают значения. Однако, было бы удобно, чтобы чекбоксы всегда возвращали значение. Хелпер `checkbox` обходит это, создавая вспомогательное скрытое поле с тем же именем. Если чекбокс не нажат, подтверждается только скрытое поле. Если он нажат, то они оба подтверждаются, но значение от чекбокса получает приоритет. Имеется опция `include_hidden`, которой можно установить `false`, если хотите опустить это скрытое поле. По умолчанию эта опция `true`.

### Хэши с индексом

Скажем, нам нужно рендерить форму с набором полей ввода для каждого адреса человека. Тут может помочь хелпер [`fields_for`][] и его аргумент `:index`:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <% @person.addresses.each do |address| %>
    <%= person_form.fields_for address, index: address.id do |address_form| %>
      <%= address_form.text_field :city %>
    <% end %>
  <% end %>
<% end %>
```

Предположим, у кого-то есть два адреса с ID 23 и 45, вышеприведенная форма отрендерит это:

```html
<form accept-charset="UTF-8" action="/people/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input id="person_name" name="person[name]" type="text" />
  <input id="person_address_23_city" name="person[address][23][city]" type="text" />
  <input id="person_address_45_city" name="person[address][45][city]" type="text" />
</form>
```

Что приведет к тому, что хэш `params` будет выглядеть так

```ruby
{
  "person" => {
    "name" => "Bob",
    "address" => {
      "23" => {
        "city" => "Paris"
      },
      "45" => {
        "city" => "London"
      }
    }
  }
}
```

Все поля ввода формы связаны с хэшем `"person"`, так как мы вызывали `fields_for` на построителе формы `person_form`. Также, указывая `index: address.id`, мы рендерим атрибут `name` каждого поля ввода города как `person[address][#{address.id}][city]` вместо `person[address][city]`. Таким образом можно сообщить, какие записи `Address` должны быть изменены при обработке хэша `params`.

Больше примеров об опции индекса `fields_for` можно обнаружить в [документации API](https://api.rubyonrails.org/v7.1.3.4/classes/ActionView/Helpers/FormHelper.html#method-i-fields_for).

Создание сложных форм
---------------------

По мере роста вашего приложения вам может потребоваться создавать более сложные формы, выходящие за рамки редактирования одного объекта. Например, при создании объекта `Person` вы можете позволить пользователю создавать несколько записей `Address` (домашний, рабочий и т.д.) в рамках одной формы. При последующем редактировании записи `Person` пользователь должен иметь возможность добавлять, удалять или обновлять адреса.

### Настройка вложенных атрибутов модели

Для редактирования связанной записи определенной модели (в данном случае `Person`) Active Record предлагает поддержку на уровне модели с помощью метода [`accepts_nested_attributes_for`](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for).

```ruby
class Person < ApplicationRecord
  has_many :addresses, inverse_of: :person
  accepts_nested_attributes_for :addresses

end

class Address < ApplicationRecord
  belongs_to :person
end
```

Это создаст метод `addresses_attributes=` в `Person`, позволяющий создавать, обновлять и уничтожать адреса.

### Вложенные формы во вью

Следующая форма позволяет пользователю создать `Person` и связанные с ним адреса.

```html+erb
<%= form_with model: @person do |form| %>
  Addresses:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>

        <%= addresses_form.label :street %>
        <%= addresses_form.text_field :street %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

Когда связь принимает вложенные атрибуты, `fields_for` рендерит свой блок для каждого элемента связи. В частности, если у person нет адресов, он ничего не рендерит.

Обычным паттерном для контроллера является построение одного или более пустых дочерних элементов, чтобы как минимум один набор полей был показан пользователю. Следующий пример покажет 2 набора полей адресов в форме нового person.

К примеру, вышеприведенный `form_with` с этим изменением:

```ruby
def new
  @person = Person.new
  2.times { @person.addresses.build }
end
```

Выведет следующий HTML:

```html
<form action="/people" accept-charset="UTF-8" method="post"><input type="hidden" name="authenticity_token" value="lWTbg-4_5i4rNe6ygRFowjDfTj7uf-6UPFQnsL7H9U9Fe2GGUho5PuOxfcohgm2Z-By3veuXwcwDIl-MLdwFRg" autocomplete="off">
  Addresses:
  <ul>
      <li>
        <label for="person_addresses_attributes_0_kind">Kind</label>
        <input type="text" name="person[addresses_attributes][0][kind]" id="person_addresses_attributes_0_kind">

        <label for="person_addresses_attributes_0_street">Street</label>
        <input type="text" name="person[addresses_attributes][0][street]" id="person_addresses_attributes_0_street">
        ...
      </li>

      <li>
        <label for="person_addresses_attributes_1_kind">Kind</label>
        <input type="text" name="person[addresses_attributes][1][kind]" id="person_addresses_attributes_1_kind">

        <label for="person_addresses_attributes_1_street">Street</label>
        <input type="text" name="person[addresses_attributes][1][street]" id="person_addresses_attributes_1_street">
        ...
      </li>
  </ul>
</form>
```

`fields_for` вкладывает форм-билдер. Имя параметра будет таким, какое ожидает `accepts_nested_attributes_for`. К примеру, при создании персоны с 2 адресами, отправленные параметры будут выглядеть так

```ruby
{
  'person' => {
    'name' => 'John Doe',
    'addresses_attributes' => {
      '0' => {
        'kind' => 'Home',
        'street' => '221b Baker Street'
      },
      '1' => {
        'kind' => 'Office',
        'street' => '31 Spooner Street'
      }
    }
  }
}
```

Фактическое значение ключей хэша `:addresses_attributes` не важно. Но они должны быть числовыми строками и различаться для каждого адреса.

Если связанный объект уже сохранен, `fields_for` автоматически генерирует скрытое поле с `id` сохраненной записи. Это можно отключить, передав `include_id: false` в `fields_for`.

```ruby
{
  'person' => {
    'name' => 'John Doe',
    'addresses_attributes' => {
      '0' => {
        'id' => 1,
        'kind' => 'Home',
        'street' => '221b Baker Street'
      },
      '1' => {
        'id' => '2',
        'kind' => 'Office',
        'street' => '31 Spooner Street'
      }
    }
  }
}
```

### (permitting-parameters-in-the-controller) Разрешение параметров в контроллере

Как обычно, в контроллере необходимо
[объявить разрешенные параметры](action_controller_overview.html#strong-parameters), перед их передачей в модель:

```ruby
def create
  @person = Person.new(person_params)
  # ...
end

private
  def person_params
    params.require(:person).permit(:name, addresses_attributes: [:id, :kind, :street])
  end
```

### Удаление связанных объектов

Можно позволить пользователям удалять связанные объекты, передав `allow_destroy: true` в `accepts_nested_attributes_for`

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
end
```

Если хэш атрибутов для объекта содержит ключ `_destroy` со значением, вычисляющимся как `true` (например, `1`, `'1'`, `true` или `'true'`), тогда объект будет уничтожен. Эта форма позволяет пользователям удалять адреса:

```html+erb
<%= form_with model: @person do |form| %>
  Addresses:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.checkbox :_destroy %>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

HTML для поля `_destroy`:

```html
<input type="checkbox" value="1" name="person[addresses_attributes][0][_destroy]" id="person_addresses_attributes_0__destroy">
```

Также необходимо обновить список разрешенных параметров в вашем контроллере, включив туда поле `_destroy`:

```ruby
def person_params
  params.require(:person).
    permit(:name, addresses_attributes: [:id, :kind, :street, :_destroy])
end
```

### Предотвращение пустых записей

Часто полезно игнорировать наборы полей, которые пользователь не заполнял. Этим можно управлять, передав `:reject_if` proc в `accepts_nested_attributes_for`. Этот proc будет вызван для каждого хэша атрибутов, отправляемого формой. Если proc возвращает `true`, тогда Active Record не создаст связанный объект для этого хэша. Следующий пример пытается создать адрес, если установлен атрибут `kind`.

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, reject_if: lambda { |attributes| attributes['kind'].blank? }
end
```

Вместо этого для удобства можно передать символ `:all_blank`, который создаст proc, который отвергнет записи, когда все атрибуты пустые, за исключением любого значения для `_destroy`.

Формы к внешним ресурсам
-------------------------

Хелперы форм Rails можно использовать для создания форм для передачи данных внешнему ресурсу. Если внешний API ожидает `authenticity_token` для ресурса, его можно передать как параметр `authenticity_token: 'your_external_token'` в `form_with`:

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: 'external_token' do %>
  Form contents
<% end %>
```

Иной раз, поля, которые можно использовать в форме, ограничены внешним API, и генерация `authenticity_token` нежелательна. Чтобы _не_ посылать токен, можно передать `false` в опцию `:authenticity_token`:

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: false do %>
  Form contents
<% end %>
```

Использование хелперов тега без построителя форм
------------------------------------------------

Если нужно отрендерить поля формы вне контекста построителя формы, Rails предоставляет хелперы тега для обычных элементов формы. Например, [`checkbox_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-checkbox_tag):

```erb
<%= checkbox_tag "accept" %>
```

Выведет:

```html
<input type="checkbox" name="accept" id="accept" value="1" />
```

Обычно у этих хелперов те же имена, что и у их аналогов в построителе форм плюс суффикс `_tag`. Полный список смотрите в [документации `FormTagHelper` API](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).

Использование `form_tag` и `form_for`
-------------------------------------

До того, как `form_with` был представлен в Rails 5.1, его функционал был разделен между [`form_tag`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag) и [`form_for`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormHelper.html#method-i-form_for). Последние сейчас мягко устаревшие в пользу `form_with`.
