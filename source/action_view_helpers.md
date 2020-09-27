Хелперы Action View
===================

После прочтения этого руководства вы узнаете:

* Какие хелперы предоставлены Action View.

--------------------------------------------------------------------------------

Обзор хелперов, предоставленных Action View
-------------------------------------------

WIP: Тут перечислены не все хелперы. За полным списком можно обратиться к [документации API](https://api.rubyonrails.org/classes/ActionView/Helpers.html)

Нижеследующее является лишь кратким обзором хелперов, доступных в Action View. Рекомендуется обратиться к [документации API](https://api.rubyonrails.org/classes/ActionView/Helpers.html), покрывающей все хелперы более подробно, но это должно послужить хорошей отправной точкой.

### AssetTagHelper

Этот модуль предоставляет методы для генерации HTML, связывающего вьюхи с файлами, такими как картинки, файлы JavaScript, таблицы стилей и новостные ленты.

По умолчанию Rails ссылается на эти файлы на текущем хосте в папке public, но можно направить Rails ссылаться на файлы на выделенном сервере файлов, установив `config.action_controller.asset_host` в конфигурации приложения, обычно в `config/environments/production.rb`. Например, допустим хост ваших файлов `assets.example.com`:

```ruby
config.action_controller.asset_host = "assets.example.com"
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
# => <link href="/assets/application.css" media="screen" rel="stylesheet" />
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

#### date_select

Возвращает набор тегов select (по одному для года, месяца и дня), предзаполненных для доступа к определенному атрибуту даты.

```ruby
date_select("article", "published_on")
```

#### datetime_select

Возвращает набор тегов select (по одному для года, месяца, дня, часа и минуты), предзаполненных для доступа к определенному атрибуту даты-времени.

```ruby
datetime_select("article", "published_on")
```

#### distance_of_time_in_words

Возвращает приблизительный промежуток времени между двумя объектами Time или Date, или целыми числами в секундах. Установите `include_seconds` в true, если хотите более детальное приближение.

```ruby
distance_of_time_in_words(Time.now, Time.now + 15.seconds)        
# => less than a minute
distance_of_time_in_words(Time.now, Time.now + 15.seconds, include_seconds: true)  
# => less than 20 seconds
```

#### select_date

Возвращает набор HTML-тегов select (по одному для года, месяца и дня), предзаполненных предоставленной `date`.

```ruby
# Создает select для date, который по умолчанию соответствует предоставленной дате (шесть дней, начиная с сегодняшнего)
select_date(Time.today + 6.days)

# Создает select для date, который по умолчанию соответствует сегодняшней дате (без аргумента)
select_date()
```

#### select_datetime

Возвращает набор HTML-тегов select (по одному для года, месяца, дня, часа и минуты), предзаполненных предоставленным `datetime`.

```ruby
# Создает select для datetime, который по умолчанию соответствует предоставленной дате (четыре дня, начиная с сегодняшнего)
select_datetime(Time.now + 4.days)

# Создает select для datetime, который по умолчанию соответствует сегодняшней дате (без аргумента)
select_datetime()
```

#### select_day

Возвращает тег select с опциями для каждого дня с 1 по 31 и выбранным текущим днем.

```ruby
# Создает поле select для дней с предоставленной датой как значение по умолчанию
select_day(Time.today + 2.days)

# Создает поле select для дней с данным числом как значение по умолчанию
select_day(5)
```

#### select_hour

Возвращает тег select с опциями для каждого часа с 0 по 23 и выбранным текущим часом.

```ruby
# Создает поле select для часов с предоставленным временем как значение по умолчанию
select_hour(Time.now + 6.hours)
```

#### select_minute

Возвращает тег select с опциями для каждой минуты с 0 по 59 и выбранной текущей минутой.

```ruby
# Создает поле select для минут с предоставленным временем как значение по умолчанию
select_minute(Time.now + 10.minutes)
```

#### select_month

Возвращает тег select с опциями для каждого месяца с January по December и выбранным текущим месяцем.

```ruby
# Создает поле select для месяцев с текущим месяцем как значение по умолчанию
select_month(Date.today)
```

#### select_second

Возвращает тег select с опциями для каждой секунды с 0 по 59 и выбранной текущей секундой.

```ruby
# Создает поле select для секунд с предоставленным временем как значение по умолчанию
select_second(Time.now + 16.seconds)
```

#### select_time

Возвращает набор тегов HTML select (по одному для часа и минуты).

```ruby
# Создает поля select с предоставленным временем как значение по умолчанию
select_time(Time.now)
```

#### select_year

Возвращает тег select с опциями для каждого года из пяти от и до выбранного текущего. Пятилетний радиус может быть изменен с помощью опциональных ключей `:start_year` и `:end_year` в `options`.

```ruby
# Создает поле select для пяти лет в обе стороны от Date.today, являющаяся значением по умолчанию для текущего года
select_year(Date.today)

# Создает поле select от 1900 до 2009 с текущим годом как значение по умолчанию
select_year(Date.today, start_year: 1900, end_year: 2009)
```

#### time_ago_in_words

Подобен `distance_of_time_in_words`, где `to_time` устанавливается `Time.now`.

```ruby
time_ago_in_words(3.minutes.from_now)  # => 3 minutes
```

#### time_select

Возвращает набор тегов select (по одному для часа, минуты и, опционально, секунды), предзаполненных для доступа к определенному атрибуту времени. Этот набор подготовлен для назначения нескольких параметров в объекте Active Record.

```ruby
# Создает тег select для времени, который при POST будет сохранен в переменную order атрибута submitted
time_select("order", "submitted")
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

Существует два типа хелперов форм: те, которые работают с атрибутами модели, и те, которые нет. Этот хелпер относится к тем, которые работают с атрибутами модели; чтобы посмотреть примеры хелперов форм, которые не работают с атрибутами модели, обратитесь к документации `ActionView::Helpers::FormTagHelper`.

Основной метод этого хелпера, `form_with`, дает возможность создавать форму для экземпляра модели; например, допустим, что имеется модель Person, и мы хотим создать ее новый экземпляр:

```html+erb
<!-- Note: переменная @person была создана в контроллере (т.е. @person = Person.new) -->
<%= form_with model: @person do |form| %>
  <%= form.text_field :first_name %>
  <%= form.text_field :last_name %>
  <%= submit_tag 'Create' %>
<% end %>
```

Созданным HTML будет:

```html
<form class="new_person" id="new_person" action="/people" accept-charset="UTF-8" method="post">
  <input name="utf8" type="hidden" value="&#x2713;" />
  <input type="hidden" name="authenticity_token" value="lTuvBzs7ANygT0NFinXj98tfw3Emfm65wwYLbUvoWsK2pngccIQSUorM2C035M9dZswXgWTvKwFS8W5TVblpYw==" />
  <input type="text" name="person[first_name]" id="person_first_name" />
  <input type="text" name="person[last_name]" id="person_last_name" />
  <input type="submit" name="commit" value="Create" data-disable-with="Create" />
</form>
```

Объект params, созданный при отправке этой формы, будет выглядеть так:

```ruby
{"utf8" => "✓", "authenticity_token" => "lTuvBzs7ANygT0NFinXj98tfw3Emfm65wwYLbUvoWsK2pngccIQSUorM2C035M9dZswXgWTvKwFS8W5TVblpYw==", "person" => {"first_name" => "William", "last_name" => "Smith"}, "commit" => "Create", "controller" => "people", "action" => "create"}
```

В хэше params будет вложенное значение person, к которому можно получить доступ в контроллере с помощью `params[:person]`.

#### check_box

Возвращает тег чекбокса с учетом доступа к определенному атрибуту.

```ruby
# Допустим, что @article.validated? равен 1:
check_box("article", "validated")
# => <input type="checkbox" id="article_validated" name="article[validated]" value="1" />
#    <input name="article[validated]" type="hidden" value="0" />
```

#### fields_for

Создает пространство имен вокруг определенного объекта модели. Это делает `fields_for` подходящим для указания дополнительных объектов модели в той же форме:

```html+erb
<%= form_with model: @person do |person_form| %>
  First name: <%= person_form.text_field :first_name %>
  Last name : <%= person_form.text_field :last_name %>

  <%= fields_for @person.permission do |permission_fields| %>
    Admin?  : <%= permission_fields.check_box :admin %>
  <% end %>
<% end %>
```

#### file_field

Возвращает поле для загрузки файла с учетом доступа к определенному атрибуту.

```ruby
file_field(:user, :avatar)
# => <input type="file" id="user_avatar" name="user[avatar]" />
```

#### form_with

Создает форму и пространство имен вокруг определенного объекта модели, используемого как основа для опроса значений полей.

Создает построитель формы, с которым будет работать блок. Если указан аргумент `model`, поля формы будут ограничены этой моделью, и значения полей формы будут предзаполнены соответствующими атрибутами модели.

```html+erb
<%= form_with model: @article do |form| %>
  <%= form.label :title, 'Title' %>:
  <%= form.text_field :title %><br>
  <%= form.label :body, 'Body' %>:
  <%= form.text_area :body %><br>
<% end %>
```

#### hidden_field

Возвращает тег скрытого поля с учетом доступа к определенному атрибуту.

```ruby
hidden_field(:user, :token)
# => <input type="hidden" id="user_token" name="user[token]" value="#{@user.token}" />
```

#### label

Возвращает тег label с учетом поля ввода для определенного атрибута.

```ruby
label(:article, :title)
# => <label for="article_title">Title</label>
```

#### password_field

Возвращает тег input типа "password" с учетом доступа к определенному атрибуту.

```ruby
password_field(:login, :pass)
# => <input type="text" id="login_pass" name="login[pass]" value="#{@login.pass}" />
```

#### radio_button

Возвращает тег радио кнопки с учетом доступа к определенному атрибуту.

```ruby
# Допустим, что @article.category возвращает "rails":
radio_button("article", "category", "rails")
radio_button("article", "category", "java")
# => <input type="radio" id="article_category_rails" name="article[category]" value="rails" checked="checked" />
#    <input type="radio" id="article_category_java" name="article[category]" value="java" />
```

#### text_area

Возвращает набор открывающего и закрывающего тега textarea с учетом доступа к определенному атрибуту.

```ruby
text_area(:comment, :text, size: "20x30")
# => <textarea cols="20" rows="30" id="comment_text" name="comment[text]">
#      #{@comment.text}
#    </textarea>
```

#### text_field

Возвращает тег input типа "text" с учетом доступа к определенному атрибуту.

```ruby
text_field(:article, :title)
# => <input type="text" id="article_title" name="article[title]" value="#{@article.title}" />
```

#### email_field

Возвращает тег input типа "email" с учетом доступа к определенному атрибуту.

```ruby
email_field(:user, :email)
# => <input type="email" id="user_email" name="user[email]" value="#{@user.email}" />
```

#### url_field

Возвращает тег input типа "url" с учетом доступа к определенному атрибуту.

```ruby
url_field(:user, :url)
# => <input type="url" id="user_url" name="user[url]" value="#{@user.url}" />
```

### FormOptionsHelper

Предоставляет ряд методов для превращения различного рода контейнеров в набор тегов option.

#### collection_select

Возвращает теги `select` и `option` для коллекции значений, возвращаемых `method` для класса `object`.

Пример структуры объекта для использования с этим методом:

```ruby
class Article < ApplicationRecord
  belongs_to :author
end

class Author < ApplicationRecord
  has_many :articles
  def name_with_initial
    "#{first_name.first}. #{last_name}"
  end
end
```

Пример использования (выбор связанного Author для экземпляра Article, `@article`):

```ruby
collection_select(:article, :author_id, Author.all, :id, :name_with_initial, { prompt: true })
```

Если `@article.author_id` — 1, это вернет:

```html
<select name="article[author_id]">
  <option value="">Please select</option>
  <option value="1" selected="selected">D. Heinemeier Hansson</option>
  <option value="2">D. Thomas</option>
  <option value="3">M. Clark</option>
</select>
```

#### collection_radio_buttons

Возвращает теги `radio_button` для коллекции значений, возвращаемых `method` для класса `object`.

Пример структуры объекта для использования с этим методом:

```ruby
class Article < ApplicationRecord
  belongs_to :author
end

class Author < ApplicationRecord
  has_many :articles
  def name_with_initial
    "#{first_name.first}. #{last_name}"
  end
end
```

Пример использования (выбор связанного Author для экземпляра Article, `@article`):

```ruby
collection_radio_buttons(:article, :author_id, Author.all, :id, :name_with_initial)
```

Если `@article.author_id` — 1, это вернет:

```html
<input id="article_author_id_1" name="article[author_id]" type="radio" value="1" checked="checked" />
<label for="article_author_id_1">D. Heinemeier Hansson</label>
<input id="article_author_id_2" name="article[author_id]" type="radio" value="2" />
<label for="article_author_id_2">D. Thomas</label>
<input id="article_author_id_3" name="article[author_id]" type="radio" value="3" />
<label for="article_author_id_3">M. Clark</label>
```

Раскрыть, что некоторый вариант выбран (т.е. программно отметить объект из коллекции):

```ruby
collection_radio_buttons(:article, :author_id, Author.all, :id, :name_with_initial, {checked: Author.last})
```

В этом случае, последний объект из коллекции будет отмечен:

```html
<input id="article_author_id_1" name="article[author_id]" type="radio" value="1" />
<label for="article_author_id_1">D. Heinemeier Hansson</label>
<input id="article_author_id_2" name="article[author_id]" type="radio" value="2" />
<label for="article_author_id_2">D. Thomas</label>
<input id="article_author_id_3" name="article[author_id]" type="radio" value="3" checked="checked" />
<label for="article_author_id_3">M. Clark</label>
```

Чтобы программно получить доступ к переданным опциям (например, добавить пользовательский класс, если отмечен):

**Образец html.erb**

```html+erb
<%= collection_radio_buttons(:article, :author_id, Author.all, :id, :name_with_initial, {checked: Author.last, required: true} do |rb| %>
      <%= rb.label(class: "#{'my-custom-class' if rb.value == Author.last.id}") { rb.radio_button + rb.text } %>
<% end %>
```

#### collection_check_boxes

Возвращает теги `check_box` для коллекции значений, возвращаемых `method` для класса `object`.

Пример структуры объекта для использования с этим методом:

```ruby
class Article < ApplicationRecord
  has_and_belongs_to_many :authors
end

class Author < ApplicationRecord
  has_and_belongs_to_many :articles
  def name_with_initial
    "#{first_name.first}. #{last_name}"
  end
end
```

Пример использования (выбор связанного Author для экземпляра Article, `@article`):

```ruby
collection_check_boxes(:article, :author_ids, Author.all, :id, :name_with_initial)
```

Если `@article.author_id` — [1], это вернет:

```html
<input id="article_author_ids_1" name="article[author_ids][]" type="checkbox" value="1" checked="checked" />
<label for="article_author_ids_1">D. Heinemeier Hansson</label>
<input id="article_author_ids_2" name="article[author_ids][]" type="checkbox" value="2" />
<label for="article_author_ids_2">D. Thomas</label>
<input id="article_author_ids_3" name="article[author_ids][]" type="checkbox" value="3" />
<label for="article_author_ids_3">M. Clark</label>
<input name="article[author_ids][]" type="hidden" value="" />
```

#### option_groups_from_collection_for_select

Возвращает строку с тегами `option`, подобно `options_from_collection_for_select`, но группирует их тегами `optgroup` на основе объектных отношений аргументов.

Пример структуры объекта для использования с этим методом:

```ruby
class Continent < ApplicationRecord
  has_many :countries
  # attribs: id, name
end

class Country < ApplicationRecord
  belongs_to :continent
  # attribs: id, name, continent_id
end
```

Пример использования:

```ruby
option_groups_from_collection_for_select(@continents, :countries, :name, :id, :name, 3)
```

Возможный результат:

```html
<optgroup label="Africa">
  <option value="1">Egypt</option>
  <option value="4">Rwanda</option>
  ...
</optgroup>
<optgroup label="Asia">
  <option value="3" selected="selected">China</option>
  <option value="12">India</option>
  <option value="5">Japan</option>
  ...
</optgroup>
```

NOTE: Возвращаются только теги `optgroup` и `option`, вам все еще нужно обернуть результат в подходящий тег `select`.

#### options_for_select

Принимает контейнер (хэш, массив, перечисление, ваш тип) и возвращает строку тегов option.

```ruby
options_for_select([ "VISA", "MasterCard" ])
# => <option>VISA</option> <option>MasterCard</option>
```

NOTE: Возвращаются только теги `option`, вам все еще нужно обернуть результат в обычный HTML-тег `select`.

#### options_from_collection_for_select

Возвращает строку тегов option, собранную с помощью итерации по `collection` и назначая результат вызова `value_method` как значение option и `text_method` как текст option.

```ruby
options_from_collection_for_select(collection, value_method, text_method, selected = nil)
```

Например, представьте цикл, проходящий по каждому человеку в `@project.people` для создания тега ввода:

```ruby
options_from_collection_for_select(@project.people, "id", "name")
# => <option value="#{person.id}">#{person.name}</option>
```

NOTE: Возвращаются только теги `option`, вам все еще нужно обернуть результат в обычный HTML-тег `select`.

#### select

Создает тег select и ряд связанных тегов option для предоставленного объекта и метода.

Пример:

```ruby
select("article", "person_id", Person.all.collect { |p| [ p.name, p.id ] }, { include_blank: true })
```

Если `@article.person_id` — 1, это выдаст:

```html
<select name="article[person_id]">
  <option value="" label=" "></option>
  <option value="1" selected="selected">David</option>
  <option value="2">Eileen</option>
  <option value="3">Rafael</option>
</select>
```

#### time_zone_options_for_select

Возвращает строку тегов option для практически любой временной зоны в мире.

#### time_zone_select

Возвращает теги select и option для заданного объекта и метода, используя `time_zone_options_for_select` для создания списка тегов option.

```ruby
time_zone_select("user", "time_zone")
```

#### date_field

Возвращает тег input типа "date" с учетом доступа к определенному атрибуту.

```ruby
date_field("user", "dob")
```

### FormTagHelper

Предоставляет ряд методов для создания тегов форм, которые не зависят от объекта Active Record. Вместо этого вы предоставляете вручную имена и значения.

#### check_box_tag

Создает тег поля ввода формы в виде чекбокса.

```ruby
check_box_tag 'accept'
# => <input id="accept" name="accept" type="checkbox" value="1" />
```

#### field_set_tag

Создает fieldset для группировки элементов формы HTML.

```html+erb
<%= field_set_tag do %>
  <p><%= text_field_tag 'name' %></p>
<% end %>
# => <fieldset><p><input id="name" name="name" type="text" /></p></fieldset>
```

#### file_field_tag

Создает поле для загрузки файла.

```html+erb
<%= form_with url: new_account_avatar_path(@account), multipart: true do %>
  <label for="file">Avatar:</label> <%= file_field_tag 'avatar' %>
  <%= submit_tag %>
<% end %>
```

Примерный результат:

```ruby
file_field_tag 'attachment'
# => <input id="attachment" name="attachment" type="file" />
```

#### hidden_field_tag

Создает скрытое поле input, используемое для передачи данных, которые были бы потеряны из-за протокола без сохранения состояния HTTP, или данные, которые должны быть скрыты от пользователя.

```ruby
hidden_field_tag 'token', 'VUBJKB23UIVI1UU1VOBVI@'
# => <input id="token" name="token" type="hidden" value="VUBJKB23UIVI1UU1VOBVI@" />
```

#### image_submit_tag

Отображает изображение, при нажатии на которое будет отправлена форма.

```ruby
image_submit_tag("login.png")
# => <input src="/images/login.png" type="image" />
```

#### label_tag

Создает тег label.

```ruby
label_tag 'name'
# => <label for="name">Name</label>
```

#### password_field_tag

Создает поле для ввода пароля, скрытое текстовое поле, которое спрячет то, что вводит пользователь символами маски.

```ruby
password_field_tag 'pass'
# => <input id="pass" name="pass" type="password" />
```

#### radio_button_tag

Создает радиокнопку; используйте группу радиокнопок с одинаковым именем, чтобы пользователи могли выбирать из группы опций.

```ruby
radio_button_tag 'favorite_color', 'maroon'
# => <input id="favorite_color_maroon" name="favorite_color" type="radio" value="maroon" />
```

#### select_tag

Создает выпадающий список.

```ruby
select_tag "people", "<option>David</option>"
# => <select id="people" name="people"><option>David</option></select>
```

#### submit_tag

Создает кнопку для отправки формы с текстом-заголовком.

```ruby
submit_tag "Publish this article"
# => <input name="commit" type="submit" value="Publish this article" />
```

#### text_area_tag

Создает область ввода текста; используйте textarea для длинного ввода текста, такого как статьи в блоге или описания.

```ruby
text_area_tag 'article'
# => <textarea id="article" name="article"></textarea>
```

#### text_field_tag

Создает стандартное поле ввода текста; используйте их для ввода небольших кусочков текста, таких как имя пользователя или поисковый запрос.

```ruby
text_field_tag 'name'
# => <input id="name" name="name" type="text" />
```

#### email_field_tag

Создает стандартное поле ввода с типом email.

```ruby
email_field_tag 'email'
# => <input id="email" name="email" type="email" />
```

#### url_field_tag

Создает стандартное поле ввода с типом url.

```ruby
url_field_tag 'url'
# => <input id="url" name="url" type="url" />
```

#### date_field_tag

Создает стандартное поле ввода с типом date.

```ruby
date_field_tag "dob"
# => <input id="dob" name="dob" type="date" />
```

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
