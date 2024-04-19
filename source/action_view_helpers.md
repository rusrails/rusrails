Хелперы Action View
===================

После прочтения этого руководства вы узнаете:

* Как форматировать даты, строки и числа.
* Как работать с текстом и тегами.
* Как сделать ссылки на изображения, видео, таблицы стилей и так далее.
* Как работать с лентами новостей Atom и JavaScript во вью.
* Как кэшировать, захватывать, отлаживать и очищать контент.

--------------------------------------------------------------------------------

Данный документ содержит описание** некоторых из наиболее часто используемых хелперов,** доступных в Action View. Он служит хорошей отправной точкой, но также рекомендуется ознакомиться с полной [API-документацией](https://api.rubyonrails.org/classes/ActionView/Helpers.html), которая более подробно описывает все хелперы.

Форматирование
--------------

### Даты

Эти хелперы облегчают отображение элементов даты и/или времени в виде понятных для человека, адаптированных к контексту форматов.

#### distance_of_time_in_words

Сообщает о приблизительной разнице во времени между двумя объектами `Time` или `Date` или целыми числами в секундах. Установите `include_seconds` в значение true, если требуются более подробные расчеты.

```ruby
distance_of_time_in_words(Time.current, 15.seconds.from_now)
# => less than a minute
distance_of_time_in_words(Time.current, 15.seconds.from_now, include_seconds: true)
# => less than 20 seconds
```

NOTE: Мы используем `Time.current` вместо `Time.now`, потому что он возвращает текущее время с учетом часового пояса, установленного в Rails, в то время как `Time.now` возвращает объект Time с учетом часового пояса сервера.

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-distance_of_time_in_words).

#### time_ago_in_words

Сообщает о приблизительной разнице во времени между объектом `Time` или `Date` или целым числом в секундах и `Time.current`.

```ruby
time_ago_in_words(3.minutes.from_now) # => 3 minutes
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-time_ago_in_words).

### Числа

Набор методов для преобразования чисел в форматированные строки. Методы предоставляются для телефонных номеров, валюты, процентов, точности, позиционной записи и размера файла.

#### number_to_currency

Форматирует число в строку валюты (например, $13.65).

```ruby
number_to_currency(1234567890.50) # => $1,234,567,890.50
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/NumberHelper.html#method-i-number_to_currency).

#### number_to_human

Оформляет число в удобочитаемый формат (форматирует и округляет); полезно для чисел, которые могут очень большими.

```ruby
number_to_human(1234)    # => 1.23 Thousand
number_to_human(1234567) # => 1.23 Million
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/NumberHelper.html#method-i-number_to_human).

#### number_to_human_size

Форматирует размер в байтах в более понятный вид; полезно для отображения размеров файлов пользователям.

```ruby
number_to_human_size(1234)    # => 1.21 KB
number_to_human_size(1234567) # => 1.18 MB
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/NumberHelper.html#method-i-number_to_human_size).

#### number_to_percentage

Форматирует число как строковое представление процента.

```ruby
number_to_percentage(100, precision: 0) # => 100%
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/NumberHelper.html#method-i-number_to_percentage).

#### number_to_phone

Форматирует номер телефона (по умолчанию в формате США).

```ruby
number_to_phone(1235551234) # => 123-555-1234
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/NumberHelper.html#method-i-number_to_phone).

#### number_with_delimiter

Форматирует число с группировкой тысяч с помощью разделителя.

```ruby
number_with_delimiter(12345678) # => 12,345,678
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/NumberHelper.html#method-i-number_with_delimiter).

#### number_with_precision

Форматирует число с указанной точностью `precision`, которая по умолчанию равна 3.

```ruby
number_with_precision(111.2345)               # => 111.235
number_with_precision(111.2345, precision: 2) # => 111.23
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/NumberHelper.html#method-i-number_with_precision).

### Текст

Набор методов для фильтрации, форматирования и преобразования строк.

#### excerpt

Учитывая `text` и `phrase`, `excerpt` осуществляет поиск и извлечение первого вхождения `phrase`, а также запрошенного окружающего текста, определяемого `radius`. Если начало/конец результата не совпадает с началом/концом текста,
добавляется маркер пропуска.

```ruby
excerpt("This is a very beautiful morning", "very", separator: " ", radius: 1)
# => ...a very beautiful...

excerpt("This is also an example", "an", radius: 8, omission: "<chop> ")
#=> <chop> is also an example
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html#method-i-excerpt).

#### pluralize

Определяет единственное или множественное число слова на основе значения числа.

```ruby
pluralize(1, "person") # => 1 person
pluralize(2, "person") # => 2 people
pluralize(3, "person", plural: "users") # => 3 users
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html#method-i-pluralize).

#### truncate

Обрезает заданный `text` до указанной `length`. Если текст обрезан, к результату будет добавлен маркер усечения, при этом общая длина не превысит `length`.

```ruby
truncate("Once upon a time in a world far far away")
# => "Once upon a time in a world..."

truncate("Once upon a time in a world far far away", length: 17)
# => "Once upon a ti..."

truncate("one-two-three-four-five", length: 20, separator: "-")
# => "one-two-three..."

truncate("And they found that many people were sleeping better.", length: 25, omission: "... (continued)")
# => "And they f... (continued)"

truncate("<p>Once upon a time in a world far far away</p>", escape: false)
# => "<p>Once upon a time in a wo..."
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html#method-i-truncate).

#### word_wrap

Оборачивает текст в строчки с длиной не более `line_width`.

```ruby
word_wrap("Once upon a time", line_width: 8)
# => "Once\nupon a\ntime"
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html#method-i-word_wrap).

Формы
-----

Хелперы форм упрощают работу с моделями по сравнению с использованием только стандартных HTML-элементов. Они предлагают ряд методов, специально разработанных для генерации форм на основе ваших моделей. Некоторые методы соответствуют определенному типу полей ввода, таких как текстовые поля, поля пароля, раскрывающиеся списки и т.д. При отправке формы, значения всех ее полей объединяются в объект params и передаются в контроллер.

Подробнее изучить хелперы форм можно в [руководстве по хелперам форм в Action View](/form-helpers).

Навигация
---------

Набор методов для создания ссылок и URL-адресов на основе подсистемы маршрутизации.

### button_to

Генерирует форму, которая отправляется по указанному URL-адресу. Форма имеет кнопку отправки со значением `name`.

```html+erb
<%= button_to "Sign in", sign_in_path %>
```

что приведет к следующему HTML:

```html
<form method="post" action="/sessions" class="button_to">
  <input type="submit" value="Sign in" />
</form>
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to).

### current_page?

Возвращает true, если текущий URL-адрес запроса совпадает с заданными `options`.

```html+erb
<% if current_page?(controller: 'profiles', action: 'show') %>
  <strong>Currently on the profile page</strong>
<% end %>
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-current_page-3F).

### link_to

Связывает с URL, внутренне используя хелпер `url_for`. Он обычно используется для создания ссылок на ресурсы RESTful, особенно пре передаче моделей в качестве аргументов в `link_to`.

```ruby
link_to "Profile", @profile
# => <a href="/profiles/1">Profile</a>

link_to "Book", @book # допустим составной первичный ключ [:author_id, :id]
# => <a href="/books/2_1">Book</a>

link_to "Profiles", profiles_path
# => <a href="/profiles">Profiles</a>

link_to nil, "https://example.com"
# => <a href="https://www.example.com">https://www.example.com</a>

link_to "Articles", articles_path, id: "articles", class: "article__container"
# => <a href="/articles" class="article__container" id="articles">Articles</a>
```

Вы можете использовать блок, если целевой объект ссылки не помещается в параметр "name".

```html+erb
<%= link_to @profile do %>
  <strong><%= @profile.name %></strong> -- <span>Check it out!</span>
<% end %>
```

что приведет к следующему HTML:

```html
<a href="/profiles/1">
  <strong>David</strong> -- <span>Check it out!</span>
</a>
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to).

### mail_to

Создает тег ссылки `mailto` для указанного адреса электронной почты. Вы также можете указать текст ссылки, дополнительные HTML-параметры и необходимость кодировки адреса электронной почты.

```ruby
mail_to "john_doe@gmail.com"
# => <a href="mailto:john_doe@gmail.com">john_doe@gmail.com</a>

mail_to "me@john_doe.com", cc: "me@jane_doe.com",
        subject: "This is an example email"
# => <a href="mailto:"me@john_doe.com?cc=me@jane_doe.com&subject=This%20is%20an%20example%20email">"me@john_doe.com</a>
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-mail_to).

### url_for

Возвращает URL-адрес на основе предоставленного набора `options`.

```ruby
url_for @profile
# => /profiles/1

url_for [ @hotel, @booking, page: 2, line: 3 ]
# => /hotels/1/bookings/1?line=3&page=2

url_for @post # given a composite primary key [:blog_id, :id]
# => /posts/1_2
```

Очистка
-------

Набор методов предназначен для очистки текста от нежелательных HTML-элементов. Эти вспомогательные методы особенно полезны для того, чтобы гарантировать отображение только безопасного и валидного HTML/CSS. Они также могут быть полезны для предотвращения XSS атак путем экранирования или удаления потенциально вредоносного контента из пользовательского ввода перед его отображением в ваших вью.

Эта функциональность внутренне обеспечивается гемом [rails-html-sanitizer](https://github.com/rails/rails-html-sanitizer).

### sanitize

Метод `sanitize` закодирует все HTML-теги и удалит все атрибуты, которые явно не разрешены.

```ruby
sanitize @article.body
```

Если указать любую из опций `:attributes` или `:tags`, то будут разрешены только указанные атрибуты и теги, и ничего более.

```ruby
sanitize @article.body, tags: %w(table tr td), attributes: %w(id class style)
```

Чтобы изменить настройки по умолчанию для многократного использования, например, добавив теги таблиц к разрешенным по умолчанию:

```ruby
# config/application.rb
class Application < Rails::Application
  config.action_view.sanitized_allowed_tags = %w(table tr td)
end
```

Эта функциональность внутренне обеспечивается гемом [rails-html-sanitizer](https://api.rubyonrails.org/classes/ActionView/Helpers/SanitizeHelper.html#method-i-sanitize).

### sanitize_css

Очищает блок кода CSS, особенно когда он задан через атрибут style в HTML-контенте. `sanitize_css` особенно актуальна при работе с пользовательским контентом или динамическим контентом, который может включать атрибуты стилей.

Метод `sanitize_css`, описанный ниже, удалит все неразрешенные стили.

```ruby
sanitize_css("background-color: red; color: white; font-size: 16px;")
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/SanitizeHelper.html#method-i-sanitize_css).

### strip_links

Удаляет все теги ссылок из текста, оставляя только сам текст ссылки.

Strips all link tags from text leaving just the link text.

```ruby
strip_links("<a href='https://rubyonrails.org'>Ruby on Rails</a>")
# => Ruby on Rails

strip_links("emails to <a href='mailto:me@email.com'>me@email.com</a>.")
# => emails to me@email.com.

strip_links("Blog: <a href='http://myblog.com/'>Visit</a>.")
# => Blog: Visit.
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/SanitizeHelper.html#method-i-strip_links).

### strip_tags

Удаляет все HTML-теги из HTML, включая комментарии и специальные символы.

```ruby
strip_tags("Strip <i>these</i> tags!")
# => Strip these tags!

strip_tags("<b>Bold</b> no more! <a href='more.html'>See more</a>")
# => Bold no more! See more

strip_links('<<a href="https://example.org">malformed & link</a>')
# => &lt;malformed &amp; link
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/SanitizeHelper.html#method-i-strip_tags).

Ресурсы
-------

Набор методов для генерации HTML, который связывает вью с различными ресурсами, такими как изображения, JavaScript-файлы, таблицы стилей и ленты новостей.

По умолчанию, Rails создает ссылки на эти ресурсы с текущего хоста в папке public. Однако, вы можете настроить Rails на использование отдельного сервера для хранения этих ресурсов, установив параметр [`config.asset_host`][] в конфигурации приложения, обычно в `config/environments/production.rb`.

Например, допустим, ваш хост для ресурсов  - `assets.example.com`:

```ruby
config.asset_host = "assets.example.com"
```

в таком случае, соответствующий URL для `image_tag` будет:

```ruby
image_tag("rails.png")
# => <img src="//assets.example.com/images/rails.png" />
```

[`config.asset_host`]: configuring.html#config-asset-host

### audio_tag

Генерирует HTML-тег audio или как одиночный тэг для строкового источника. либо вложенные теги источника для массива нескольких источников. `sources` могут быть полными путями, файлами в вашей публичной директории аудио или [вложениями Active Storage](/active_storage_overview).

```ruby
audio_tag("sound")
# => <audio src="/audios/sound"></audio>

audio_tag("sound.wav", "sound.mid")
# => <audio><source src="/audios/sound.wav" /><source src="/audios/sound.mid" /></audio>

audio_tag("sound", controls: true)
# => <audio controls="controls" src="/audios/sound"></audio>
```

INFO: Внутренняя реализация `audio_tag` использует [`audio_path` из AssetUrlHelpers](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetUrlHelper.html#method-i-audio_path) для построения пути к аудиофайлу.

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-audio_tag).

### auto_discovery_link_tag

Возвращает тег ссылки, который браузеры и программы чтения лент новостей могут использовать для автоматического обнаружения лент новостей RSS, Atom или JSON.

```ruby
auto_discovery_link_tag(:rss, "http://www.example.com/feed.rss", { title: "RSS Feed" })
# => <link rel="alternate" type="application/rss+xml" title="RSS Feed" href="http://www.example.com/feed.rss" />
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-auto_discovery_link_tag).

### favicon_link_tag

Возвращает тег ссылки для иконки, управляемый конвейером ресурсов. `source` может быть полным путем к файлу или файлом, находящимся в вашей директории ресурсов.

```ruby
favicon_link_tag
# => <link href="/assets/favicon.ico" rel="icon" type="image/x-icon" />
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-favicon_link_tag).

### image_tag

Возвращает HTML-тег изображения для указанного источника. `source` может быть полным путем к изображению или файлом, находящимся в директории `app/assets/images`.

```ruby
image_tag("icon.png")
# => <img src="/assets/icon.png" />

image_tag("icon.png", size: "16x10", alt: "Edit Article")
# => <img src="/assets/icon.png" width="16" height="10" alt="Edit Article" />
```

INFO: Внутренне, `image_tag` использует [`image_path` из AssetUrlHelpers](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetUrlHelper.html#method-i-image_path) для построения пути к изображению.

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-image_tag).

### javascript_include_tag

Возвращает HTML-тег скрипта для каждого из указанных источников. Вы можете передать имя (расширение `.js` не обязательно) JavaScript-файлов из директории `app/assets/javascripts` для включения на текущую страницу, или можете передать полный путь к файлу относительно корня вашего документа.

```ruby
javascript_include_tag("common")
# => <script src="/assets/common.js"></script>

javascript_include_tag("common", async: true)
# => <script src="/assets/common.js" async="async"></script>
```

Некоторые из наиболее распространенных атрибутов - `async` и `defer`, где `async` - позволит загружать скрипт параллельно, чтобы разобрать и выполнить его как можно скорее, а `defer` - укажет, что скрипт должен быть выполнен после того, как документ был полностью разобран.

INFO: Внутренне, `javascript_include_tag` использует [`javascript_path` из AssetUrlHelpers](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetUrlHelper.html#method-i-javascript_path) для построения пути к скрипту.

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-javascript_include_tag).

### picture_tag

Возвращает HTML-тег picture для указанного источника. Она поддерживает передачу String, Array или Block.

```ruby
picture_tag("icon.webp", "icon.png")
```

Это сгенерирует следующий HTML:

```html
<picture>
  <source srcset="/assets/icon.webp" type="image/webp" />
  <source srcset="/assets/icon.png" type="image/png" />
  <img src="/assets/icon.png" />
</picture>
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-picture_tag).

### preload_link_tag

Возвращает тег ссылки, который браузеры могут использовать для предварительной загрузки источника. Источник может быть путем к ресурсу, управляемому конвейером ресурсов, полным путем или URI.

```ruby
preload_link_tag("application.css")
# => <link rel="preload" href="/assets/application.css" as="style" type="text/css" />
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-preload_link_tag).

### stylesheet_link_tag

Возвращает тег ссылки на таблицу стилей для указанных источников. Если вы не укажете расширение файла, `.css` будет автоматически добавлено.

```ruby
stylesheet_link_tag("application")
# => <link href="/assets/application.css" rel="stylesheet" />

stylesheet_link_tag("application", media: "all")
# => <link href="/assets/application.css" media="all" rel="stylesheet" />
```

`media` используется для определения типа носителя для ссылки. Наиболее распространенные типы носителей: `all`, `screen`, `print` и `speech`.

INFO: Внутренне, `stylesheet_link_tag` использует [`stylesheet_path` из AssetUrlHelpers](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetUrlHelper.html#method-i-stylesheet_path) для построения пути к таблице стилей.

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-stylesheet_link_tag).

### video_tag

Генерирует HTML-тег video с источником(ами), или как отдельный тег для строкового источника или вложенные теги источника для массива нескольких источников. Источники могут быть полными путями, файлами из публичной директории videos или вложениями Active Storage.

```ruby
video_tag("trailer")
# => <video src="/videos/trailer"></video>

video_tag(["trailer.ogg", "trailer.flv"])
# => <video><source src="/videos/trailer.ogg" /><source src="/videos/trailer.flv" /></video>

video_tag("trailer", controls: true)
# => <video controls="controls" src="/videos/trailer"></video>
```

INFO: Внутренне, `video_tag` использует [`video_path` из AssetUrlHelpers](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetUrlHelper.html#method-i-video_path) для построения пути к видео.

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-video_tag).

JavaScript
----------

Набор методов для работы с JavaScript в ваших вью.

### escape_javascript

Экранирует символы переноса строки, а также одинарные и двойные кавычки для сегментов JavaScript. Нужно использовать этот метод, чтобы взять строку текста и убедиться, что она не будет содержать неправильных символов, которые могут привести к ошибкам при ее обработке браузером.

Например, предположим, у вас есть партиал с приветствием, которое содержит двойные кавычки. Вы можете экранировать приветствие перед его использованием в JavaScript-окне предупреждения.

```html+erb
<%# app/views/users/greeting.html.rb %>
My name is <%= current_user.name %>, and I'm here to say "Welcome to our website!"
```

```html+erb
<script>
  var greeting = "<%= escape_javascript render('users/greeting') %>";
  alert(`Hello, ${greeting}`);
</script>
```

Этот метод правильно экранирует кавычки, и приветствие отобразится в окне предупреждения.

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/JavaScriptHelper.html#method-i-escape_javascript).

### javascript_tag

Возвращает JavaScript-тег, содержащий предоставленный код. Вы можете передать хэш опций для управления поведением тега `<script>`.

```ruby
javascript_tag("alert('All is good')", type: "application/javascript")
```

```html
<script type="application/javascript">
//<![CDATA[
alert('All is good')
//]]>
</script>
```

Вместо передачи содержимого в качестве аргумента, вы также можете использовать блок.

```html+erb
<%= javascript_tag type: "application/javascript" do %>
  alert("Welcome to my app!")
<% end %>
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/JavaScriptHelper.html#method-i-javascript_tag).

Альтернативные теги
-------------------

Набор методов для программной генерации HTML-тегов.

### tag

Генерирует одиночный HTML-тег с указанным `name` и `options`.

Каждый тег может быть построен с помощью:

```ruby
tag.some_tag_name(optional content, options)
```

Где имя тега может быть, например, `br`, `div`, `section`, `article` или вообще любой тег.

Например, вот несколько распространенных вариантов использования:

```ruby
tag.h1 "All titles fit to print"
# => <h1>All titles fit to print</h1>

tag.div "Hello, world!"
# => <div>Hello, world!</div>
```

Кроме того, вы можете передать опции для добавления атрибутов к создаваемому тегу.

```ruby
tag.section class: %w( kitties puppies )
# => <section class="kitties puppies"></section>
```

Дополнительно, HTML-атрибуты `data-*` могут быть переданы хелперу `tag` с помощью опции `data`. Эта опция принимает хэш, содержащий пары ключ-значение для дополнительных атрибутов. Эти пары затем преобразуются в атрибуты `data-*` с разделителями-дефисами для обеспечения совместимости с JavaScript.

```ruby
tag.div data: { user_id: 123 }
# => <div data-user-id="123"></div>
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html#method-i-tag).

### token_list

Возвращает строку токенов, сформированную на основе предоставленных аргументов. Он также имеет псевдоним `class_names`.

```ruby
token_list("cats", "dogs")
# => "cats dogs"

token_list(nil, false, 123, "", "foo", { bar: true })
# => "123 foo bar"

mobile, alignment = true, "center"
token_list("flex items-#{alignment}", "flex-col": mobile)
# => "flex items-center flex-col"
class_names("flex items-#{alignment}", "flex-col": mobile) # using the alias
# => "flex items-center flex-col"
```

Блоки захвата
-------------

Набор методов для извлечения сгенерированной разметки, которую можно использовать в других частях файла шаблона или макета.

Этот набор методов предоставляет метод `capture` для захвата блоков в переменную и способ захвата блок для использования в макете с помощью `content_for`.

### capture

Метод `capture` позволяет извлечь часть шаблона в переменную.

```html+erb
<% @greeting = capture do %>
  <p>Welcome! The date and time is <%= Time.current %></p>
<% end %>
```

Затем вы можете использовать эту переменную в любом месте ваших шаблонов, макетов или хелперов.

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

Возвращаемое значение `capture` - это строка, сгенерированная переданным блоком.

``` ruby
@greeting
# => "Welcome to my shiny new web page! The date and time is 2018-09-06 11:09:16 -0500"
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/CaptureHelper.html#method-i-capture).

### content_for

Вызов `content_for` сохраняет блок разметки под определенным идентификатором для дальнейшего использования. Вы можете обращаться к этому сохраненному содержимому позже в других шаблонах, вспомогательных модулях или макете, передавая идентификатор в качестве аргумента методу `yield`.

Один из распространенных вариантов использования `content_for` - это установка заголовка страницы.

Вы определяете блок `content_for` с заголовком в специальном шаблоне страницы, и затем используете `yield` в макете. На других страницах, где блок `content_for` не используется, он останется пустым, и `yield` ничего не вставит.

```html+erb
<%# app/views/users/special_page.html.erb %>
<% content_for(:html_title) { "Special Page Title" } %>
```

```html+erb
<%# app/views/layouts/application.html.erb %>
<html>
  <head>
    <title><%= content_for?(:html_title) ? yield(:html_title) : "Default Title" %></title>
  </head>
</html>
```

Обратите внимание, что в приведенном выше примере мы используем метод-предикат `content_for?` для условного вывода заголовка. Этот метод проверяет, был ли какой-либо контент ранее захвачен с помощью `content_for`, что позволяет вам адаптировать части вашего макета в зависимости от контента в ваших вью.

Дополнительно, вы можете использовать `content_for` внутри вспомогательного модуля.

```ruby
# app/helpers/title_helper.rb
module TitleHelper
  def html_title
    content_for(:html_title) || "Default Title"
  end
end
```

Теперь вы можете вызвать `html_title` в вашем макете, чтобы получить содержимое, сохраненное в блоке `content_for`. Если на странице, которая отрисовывается (например, на `special_page`), установлен блок `content_for`, он отобразит заголовок. В противном случае будет отображен текст по умолчанию "Default Title".

WARNING: `content_for` игнорируется в кэше. Поэтому не следует использовать его для элементов, которые будут кэшироваться фрагментами.

NOTE: Возможно, вы задумываетесь, в чем разница между `capture` и `content_for`? <br><br>
`capture` используется для захвата блока разметки в переменную, а `content_for` используется для хранения блока разметки под идентификатором для дальнейшего использования. Внутренне `content_for` фактически вызывает `capture`. Однако ключевое отличие заключается в их поведении при многократном вызове.<br><br>
`content_for` можно вызывать несколько раз, объединяя блоки, которые он получает для определенного идентификатора, в том порядке, в котором они предоставляются. Каждый последующий вызов просто добавляется к тому, что уже сохранено. Напротив, `capture` возвращает только содержимое блока, не отслеживая предыдущих вызовов.

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/CaptureHelper.html#method-i-content_for).

Производительность
------------------

### benchmark

Оборачивайте дорогостоящие операции или потенциальные узкие места блоком `benchmark`, чтобы получить время выполнения операции.

```html+erb
<% benchmark "Process data files" do %>
  <%= expensive_files_operation %>
<% end %>
```

Это добавит в лог информацию вроде `Process data files (0.34523)`, которую затем можно использовать для сравнения временных затрат при оптимизации вашего кода.

NOTE: Этот хелпер является частью Active Support и также доступен в контроллерах, хелперах, моделях и т.д.

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActiveSupport/Benchmarkable.html#method-i-benchmark).

### cache

Вы можете кэшировать фрагменты вью, а не целые действия или страницы. Эта техника полезна для кэширования таких элементов, как меню, списки новостей, статические фрагменты HTML и т.д. Он позволяет обернуть фрагмент логики вью в блок кэша и извлекать его из хранилища кэша при следующем запросе.

Метод `cache` принимает блок, содержащий контент, который вы хотите кэшировать.

Например, вы можете кэшировать footer вашего макета приложения, обернув его блоком `cache`.

```erb
<% cache do %>
  <%= render "application/footer" %>
<% end %>
```

Вы также можете кэшировать данные на основе экземпляров модели. Например, можно кэшировать каждую статью на странице, передав объект `article` в метод `cache`. Это позволит кэшировать каждую статью отдельно.

```erb
<% @articles.each do |article| %>
  <% cache article do %>
    <%= render article %>
  <% end %>
<% end %>
```

Когда ваше приложение получает первый запрос к этой странице, Rails запишет новую запись кэша с уникальным ключом. Ключ выглядит примерно так:

```irb
views/articles/index:bea67108094918eeba32cd4a6f786301/articles/1
```

Подробности смотрите в [`Кэширование фрагмента`](caching_with_rails.html#fragment-caching) и [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/CacheHelper.html#method-i-cache).

Разное
------

### atom_feed

Каналы Atom - это файловые форматы на основе XML, используемые для рассылки контента. Пользователи могут просматривать контент с помощью программ чтения RSS-каналов, а поисковые системы могут использовать их для обнаружения дополнительной информации о вашем сайте.

Этот хелпер упрощает создание каналов Atom и чаще всего используется в шаблонах Builder для создания XML. Вот полный пример использования:

```ruby
# config/routes.rb
resources :articles
```

```ruby
# app/controllers/articles_controller.rb
def index
  @articles = Article.all

  respond_to do |format|
    format.html
    format.atom
  end
end
```

```ruby
# app/views/articles/index.atom.builder
atom_feed do |feed|
  feed.title("Articles Index")
  feed.updated(@articles.first.created_at)

  @articles.each do |article|
    feed.entry(article) do |entry|
      entry.title(article.title)
      entry.content(article.body, type: "html")

      entry.author do |author|
        author.name(article.author_name)
      end
    end
  end
end
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/AtomFeedHelper.html#method-i-atom_feed).

### debug


Возвращает представление объекта в формате YAML, обернутое тегом `pre`. Это удобный способ читабельного просмотра объекта.

```ruby
my_hash = { "first" => 1, "second" => "two", "third" => [1, 2, 3] }
debug(my_hash)
```

```html
<pre class="debug_dump">---
first: 1
second: two
third:
- 1
- 2
- 3
</pre>
```

Подробности смотрите в [API-документации](https://api.rubyonrails.org/classes/ActionView/Helpers/DebugHelper.html#method-i-debug).
