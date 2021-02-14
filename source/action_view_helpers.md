Хелперы Action View
===================

После прочтения этого руководства вы узнаете:

* Как форматировать даты, строки и числа
* Как сделать ссылки на изображения, видео, таблицы стилей и так далее...
* Как очистить небезопасное содержимое
* Как локализовать содержимое to localize content

--------------------------------------------------------------------------------

Обзор хелперов, предоставленных Action View
-------------------------------------------

WIP: Тут перечислены не все хелперы. За полным списком можно обратиться к [документации API](https://api.rubyonrails.org/classes/ActionView/Helpers.html)

Нижеследующее является лишь кратким обзором хелперов, доступных в Action View. Рекомендуется обратиться к [документации API](https://api.rubyonrails.org/classes/ActionView/Helpers.html), покрывающей все хелперы более подробно, но это должно послужить хорошей отправной точкой.

### AssetTagHelper

Этот модуль предоставляет методы для генерации HTML, связывающего вьюхи с файлами, такими как картинки, файлы JavaScript, таблицы стилей и новостные ленты.

По умолчанию Rails ссылается на эти файлы на текущем хосте в папке public, но можно направить Rails ссылаться на файлы на выделенном сервере файлов, установив `config.asset_host` в конфигурации приложения, обычно в `config/environments/production.rb`. Например, допустим хост ваших файлов `assets.example.com`:

```ruby
config.asset_host = "assets.example.com"
image_tag("rails.png") # => <img src="http://assets.example.com/images/rails.png" />
```

#### auto_discovery_link_tag

Возвращает тег ссылки, которую могут использовать браузеры и агрегаторы новостей для автоматического определения RSS, Atom или ленты JSON.

```ruby
auto_discovery_link_tag(:rss, "http://www.example.com/feed.rss", { title: "RSS Feed" }) # =>
  <link rel="alternate" type="application/rss+xml" title="RSS Feed" href="http://www.example.com/feed" />
```

#### image_path

Вычисляет путь до ресурса картинки в директории `app/assets/images`. Будут переданы полные пути от корня документа. Используется внутри `image_tag` для создания пути к картинке.

```ruby
image_path("edit.png") # => /assets/edit.png
```

К имени файла будет добавлена метка, если config.assets.digest установлен в true.

```ruby
image_path("edit.png") # => /assets/edit-2d1a2db63fc738690021fedb5a65b68e.png
```

#### image_url

Вычисляет URL ресурса картинки в директории `app/assets/images`. Он вызовет `image_path` и соединит с вашим текущим хостом или вашим хостом ресурсов.

```ruby
image_url("edit.png") # => http://www.example.com/assets/edit.png
```

#### image_tag

Возвращает тег картинки HTML для источника. Источником может быть полный путь или файл, существующий в директории `app/assets/images`.

```ruby
image_tag("icon.png") # => <img src="/assets/icon.png" />
```

#### javascript_include_tag

Возвращает HTML-тег script для каждого предоставленного источника. Можно передать имя файла (расширение `.js` опционально) или файлы JavaScript, существующие в директории `app/assets/javascripts` для включения в текущую страницу, или передать полный путь относительно корня документа.

```ruby
javascript_include_tag "common"
# => <script src="/assets/common.js"></script>
```

#### javascript_path

Вычисляет путь до ресурса JavaScript в директории `app/assets/javascripts`. Если у имени файла источника нет расширения, будет добавлено `.js`. Будут переданы полные пути от корня документа. Используется внутри `javascript_include_tag` для создания пути к скрипту.

```ruby
javascript_path "common" # => /assets/common.js
```

#### javascript_url

Вычисляет URL ресурса JavaScript в директории `app/assets/javascripts`. Он вызовет `javascript_path` и соединит с вашим текущим хостом или вашим хостом ресурсов.

```ruby
javascript_url "common"
# => http://www.example.com/assets/common.js
```

#### stylesheet_link_tag

Возвращает тег ссылки на таблицу стилей для источников, указанных в качестве аргументов. Если не указать расширение, автоматически будет добавлено `.css`.

```ruby
stylesheet_link_tag "application"
# => <link href="/assets/application.css" rel="stylesheet" />
```

#### stylesheet_path

Вычисляет путь до ресурса таблицы стилей в директории `app/assets/stylesheets`. Если у имени файла источника нет расширения, будет добавлено `.css`. Будут переданы полные пути от корня документа. Используется внутри `stylesheet_link_tag` для создания пути к таблице стилей.

```ruby
stylesheet_path "application" # => /assets/application.css
```

#### stylesheet_url

Вычисляет URL ресурса таблицы стилей в директории `app/assets/stylesheets`. Он вызовет `stylesheet_path` и соединит с вашим текущим хостом или вашим хостом ресурсов.

```ruby
stylesheet_url "application"
# => http://www.example.com/assets/application.css
```

### AtomFeedHelper

#### atom_feed

Этот хелпер позволяет с легкостью создать новостную ленту Atom. Вот пример полного использования:

**config/routes.rb**

```ruby
resources :articles
```

**app/controllers/articles_controller.rb**

```ruby
def index
  @articles = Article.all

  respond_to do |format|
    format.html
    format.atom
  end
end
```

**app/views/articles/index.atom.builder**

```ruby
atom_feed do |feed|
  feed.title("Articles Index")
  feed.updated(@articles.first.created_at)

  @articles.each do |article|
    feed.entry(article) do |entry|
      entry.title(article.title)
      entry.content(article.body, type: 'html')

      entry.author do |author|
        author.name(article.author_name)
      end
    end
  end
end
```

### BenchmarkHelper

#### benchmark

Позволяет измерить время выполнения блока в шаблоне и записать результат в лог. Оберните этот блок вокруг затратных операций или потенциальных узких мест, чтобы получить время чтения для операций.

```html+erb
<% benchmark "Process data files" do %>
  <%= expensive_files_operation %>
<% end %>
```

Это добавит в лог что-то вроде "Process data files (0.34523)", затем это можно использовать для сравнения времени при оптимизации кода.

### CacheHelper

#### cache

Метод для кэширования фрагмента вьюхи, а не всего экшна или страницы. Эта техника полезна для кэширования таких кусочков, как меню, списки заголовков новостей, статичные фрагменты HTML и так далее. Этот метод принимает блок, содержащий код, который вы хотите закэшировать. Подробности смотрите в `AbstractController::Caching::Fragments`.

```erb
<% cache do %>
  <%= render "shared/footer" %>
<% end %>
```

### CaptureHelper

#### capture

Метод `capture` позволяет извлечь часть шаблона в переменную. Эту переменную потом можно использовать в любом месте шаблона или макета.

```html+erb
<% @greeting = capture do %>
  <p>Welcome! The date and time is <%= Time.now %></p>
<% end %>
```

Захваченная переменная может быть потом где-то использована.

```html+erb
<html>
  <head>
    <title>Welcome!</title>
  </head>
  <body>
    <%= @greeting %>
  </body>
</html>
```

#### content_for

Вызов `content_for` хранит блок разметки как идентификатор для дальнейшего использования. Можно совершать последующие вызовы сохраненного содержимого в других шаблонах или макете, передав идентификатор в качестве аргумента в `yield`.

Например, допустим у нас есть стандартный макет приложения, но также есть специальная страница, требующая определенный JavaScript, который не требуется в остальных частях сайта. Можно использовать `content_for`, чтобы включить этот JavaScript на нашу специальную страницу без влияния на оставшуюся часть сайта.

**app/views/layouts/application.html.erb**

```html+erb
<html>
  <head>
    <title>Welcome!</title>
    <%= yield :special_script %>
  </head>
  <body>
    <p>Welcome! The date and time is <%= Time.now %></p>
  </body>
</html>
```

**app/views/articles/special.html.erb**

```html+erb
<p>This is a special page.</p>

<% content_for :special_script do %>
  <script>alert('Hello!')</script>
<% end %>
```

### DateHelper

#### distance_of_time_in_words

Возвращает приблизительный промежуток времени между двумя объектами Time или Date, или целыми числами в секундах. Установите `include_seconds` в true, если хотите более детальное приближение.

```ruby
distance_of_time_in_words(Time.now, Time.now + 15.seconds)        
# => less than a minute
distance_of_time_in_words(Time.now, Time.now + 15.seconds, include_seconds: true)  
# => less than 20 seconds
```

#### time_ago_in_words

Подобен `distance_of_time_in_words`, где `to_time` устанавливается `Time.now`.

```ruby
time_ago_in_words(3.minutes.from_now)  # => 3 minutes
```

### DebugHelper

Возвращает тег `pre` с объектом, выгруженным в YAML. Это создает удобочитаемый способ проверки объекта.

```ruby
my_hash = { 'first' => 1, 'second' => 'two', 'third' => [1,2,3] }
debug(my_hash)
```

```html
<pre class='debug_dump'>---
first: 1
second: two
third:
- 1
- 2
- 3
</pre>
```

### FormHelper

Хелперы форм предназначены для упрощения работы с моделями по сравнению с использованием только стандартных элементов HTML, предоставляя набор методов для создания форм на основе ваших моделей. Этот хелпер создает HTML для форм, предоставляя метод для каждого типа полей ввода (например text, password, select и так далее). Когда форма подтверждается (т.е. когда пользователь нажимает кнопку подтверждения или form.submit вызывается с помощью JavaScript), поля ввода формы будут объединены в объект params и переданы в контроллер.

Подробнее изучить хелперы форм можно в [руководстве по хелперам форм в Action View](/rails-form-helpers).

### JavaScriptHelper

Предоставляет функциональность для работы с JavaScript в ваших вьюхах.

#### escape_javascript

Экранирует переводы строк и одиночные и двойные кавычки во фрагментах JavaScript.

#### javascript_tag

Возвращает тег JavaScript, оборачивающий предоставленный код.

```ruby
javascript_tag "alert('All is good')"
```

```html
<script>
//<![CDATA[
alert('All is good')
//]]>
</script>
```

### NumberHelper

Предоставляет методы для конвертации чисел в форматированные строки. Методы предоставлены для телефонных номеров, валют, процентов, позиционных систем счисления и размеров файла.

#### number_to_currency

Форматирует число в строку с символом валюты (например, $13.65).

```ruby
number_to_currency(1234567890.50) # => $1,234,567,890.50
```

#### number_to_human

Красиво выводит (форматирует и округляет) число, таким образом, оно лучше читаемое пользователями; полезно для чисел, которые могут быть очень большими.

```ruby
number_to_human(1234)    # => 1.23 Thousand
number_to_human(1234567) # => 1.23 Million
```

#### number_to_human_size

Форматирует размер в байтах в более понятное представление; полезно для показа размеров файла пользователям.

```ruby
number_to_human_size(1234)    # => 1.2 KB
number_to_human_size(1234567) # => 1.2 MB
```

#### number_to_percentage

Форматирует число в строку с символом процента.

```ruby
number_to_percentage(100, precision: 0) # => 100%
```

#### number_to_phone

Форматирует число в телефонный номер (по умолчанию США).

```ruby
number_to_phone(1235551234) # => 123-555-1234
```

#### number_with_delimiter

Форматирует число со сгруппированными тысячами, используя разделитель.

```ruby
number_with_delimiter(12345678) # => 12,345,678
```

#### number_with_precision

Форматирует число с помощью определенного уровня точности, по умолчанию 3.

```ruby
number_with_precision(111.2345)               # => 111.235
number_with_precision(111.2345, precision: 2) # => 111.23
```

### SanitizeHelper

Модуль SanitizeHelper предоставляет набор методов для очистки текста от нежелательных элементов HTML.

#### sanitize

Хелпер sanitize экранирует все теги HTML и удаляет все атрибуты, которые не разрешены явно.

```ruby
sanitize @article.body
```

Если переданы опции или `:attributes`, или `:tags`, разрешены только упомянутые теги и атрибуты, и ничего более.

```ruby
sanitize @article.body, tags: %w(table tr td), attributes: %w(id class style)
```

Чтобы изменить значения по умолчанию для многократного использования, например, добавить теги таблиц к значениям по умолчанию:

```ruby
class Application < Rails::Application
  config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td'
end
```

#### sanitize_css(style)

Экранирует блок кода CSS.

#### strip_links(html)

Обрезает все теги ссылок в тексте, оставляя только текст ссылки.

```ruby
strip_links('<a href="https://rubyonrails.org">Ruby on Rails</a>')
# => Ruby on Rails
```

```ruby
strip_links('emails to <a href="mailto:me@email.com">me@email.com</a>.')
# => emails to me@email.com.
```

```ruby
strip_links('Blog: <a href="http://myblog.com/">Visit</a>.')
# => Blog: Visit.
```

#### strip_tags(html)

Обрезает все теги HTML из html, включая комментарии. Эта функция доступна, если подключен гем rails-html-sanitizer.

```ruby
strip_tags("Strip <i>these</i> tags!")
# => Strip these tags!
```

```ruby
strip_tags("<b>Bold</b> no more!  <a href='more.html'>See more</a>")
# => Bold no more!  See more
```

NB: Результат все еще может содержать неэкранированные символы '<', '>', '&' и путать браузеры.

### UrlHelper

Предоставляет методы для создания ссылок и получения URL, зависящих от подсистемы роутинга.

#### url_for

Возвращает URL для набора предоставленных `options`.

##### Примеры

```ruby
url_for @profile
# => /profiles/1

url_for [ @hotel, @booking, page: 2, line: 3 ]
# => /hotels/1/bookings/1?line=3&page=2
```

#### link_to

Связывает с URL на основе `url_for`. В основном используется для создания ресурсных RESTful ссылок, которые, в этом примере, сводятся к передаче моделей в `link_to`.

**Примеры**

```ruby
link_to "Profile", @profile
# => <a href="/profiles/1">Profile</a>
```

Также можно использовать блок, если target ссылки не подходит для параметра имени. Пример ERB:

```html+erb
<%= link_to @profile do %>
  <strong><%= @profile.name %></strong> -- <span>Check it out!</span>
<% end %>
```

выведет:

```html
<a href="/profiles/1">
  <strong>David</strong> -- <span>Check it out!</span>
</a>
```

Смотрите [подробности в документации API](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)

#### button_to

Создает форму, отправляющуюся на переданный URL. У формы будет кнопка отправки со значением `name`.

##### Примеры

```html+erb
<%= button_to "Sign in", sign_in_path %>
```

выведет примерно такое:

```html
<form method="post" action="/sessions" class="button_to">
  <input type="submit" value="Sign in" />
</form>
```

Смотрите [подробности в документации API](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)

### CsrfHelper

Возвращает метатеги "csrf-param" и "csrf-token" с, соответственно, именами параметра и токена против межсайтовой подделки запроса.

```html
<%= csrf_meta_tags %>
```

NOTE: Обычные формы создают скрытые поля, поэтому они не используют эти теги. Подробнее в руководстве [Безопасность приложений на Rails](/ruby-on-rails-security-guide#cross-site-request-forgery-csrf).
