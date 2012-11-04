# Структурирование макетов (часть первая)

Когда Rails рендерит вьюху как отклик, он делает это путем объединения вьюхи с текущим макетом, используя правила для нахождения текущего макета, которые мы рассмотрели ранее. В макетах у вас есть доступ к трем инструментам объединения различных кусочков результата для формирования общего отклика:

* Тэги ресурсов
* `yield` и `content_for`
* Партиалы

В этой части мы рассмотрим теги ресурсов. Во [второй части](/layouts-and-rendering-in-rails/structuring-layouts-2) `yield` и `content_for`. И в [третьей части](/layouts-and-rendering-in-rails/structuring-layouts-3), соответственно, партиалы и вложенные макеты.

### Хелперы ресурсных тегов

Хелперы ресурсных тегов представляют методы для создания HTML, связывающие вьюхи с ресурсами, такими как каналы, Javascript, таблицы стилей, изображения, видео и аудио. Есть шесть типов хелперов ресурсных тегов:

* `auto_discovery_link_tag`
* `javascript_include_tag`
* `stylesheet_link_tag`
* `image_tag`
* `video_tag`
* `audio_tag`

Эти теги можно использовать в макетах или других вьюхах, хотя `auto_discovery_link_tag`, `javascript_include_tag`, and `stylesheet_link_tag` как правило используются в разделе `<head>` макета.

WARNING: Хелперы ресурсных тегов _не_ проверяют существование ресурсов по заданому месту расположения; они просто предполагают, что вы знаете, что делаете, и создают ссылку.

#### Присоединение каналов с помощью `auto_discovery_link_tag`

Хелпер `auto_discovery_link_tag` создает HTML, который многие браузеры и ньюзгруппы могут использовать для определения наличия каналов RSS или ATOM. Он принимает тип ссылки (`:rss` или `:atom`), хэш опций, которые передаются через url_for, и хэш опций для тега:

```erb
<%= auto_discovery_link_tag(:rss, {:action => "feed"},
  {:title => "RSS Feed"}) %>
```

Вот три опции тега, доступные для `auto_discovery_link_tag`:

* `:rel` определяет значение `rel` в ссылке. Значение по умолчанию "alternate"
* `:type` определяет явный тип MIME. Rails генерирует подходящий тип MIME автоматически
* `:title` определяет заголовок ссылки. Значение по умолчанию это значение `:type` в верхнем регистре, например, "ATOM" или "RSS".

h5. Присоединение файлов Javascript с помощью `javascript_include_tag`

Хелпер `javascript_include_tag` возвращает HTML тег `script` для каждого предоставленного источника.

При использовании Rails с включенным "Asset Pipeline":/asset-pipeline enabled, этот хелпер создаст ссылку на `/assets/javascripts/`, а не на `public/javascripts`, что использовалось в прежних версиях Rails. Эта ссылка обслуживается гемом Sprockets, представленным в Rails 3.1.

Файл JavaScript в приложении Rails или engine Rails размещается в одном из трех мест: `app/assets`, `lib/assets` или `vendor/assets`. Эти места детально описаны в [разделе про организацию ресурсов в руководстве по Asset Pipeline](http://rusrails.ru/asset-pipeline/how-to-use-the-asset-pipeline).

Можно определить полный путь относительно корня документа или URL, по желанию. Например, сослаться на файл JavaScript, находящийся в директории с именем `javascripts` в одной из `app/assets`, `lib/assets` или `vendor/assets`, можно так:

```erb
<%= javascript_include_tag "main" %>
```

Rails тогда выдаст такой тег `script`:

```html
<script src='/assets/main.js'></script>
```

Затем запрос к этому ресурсу будет обслужен гемом Sprockets.

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

Если приложение не использует файлопровод (asset pipeline), опция `:defaults` загрузит загружает библиотеки jQuery по умолчанию:

```erb
<%= javascript_include_tag :defaults %>
```

Выдаст такие теги `script`:

```html
<script src="/javascripts/jquery.js"></script>
<script src="/javascripts/jquery_ujs.js"></script>
```

Эти два файла для jQuery, `jquery.js` и `jquery_ujs.js`, должны быть помещены в `public/javascripts`, если приложение не использует файлопровод. Эти файлы могут быть скачаны из [репозитория jquery-rails на GitHub](https://github.com/indirect/jquery-rails/tree/master/vendor/assets/javascripts).

WARNING: При использовании файлопровода этот тег отрендерит тег `script` для ресурса по имени `defaults.js`, не существующего в вашем приложении, если вы явно не создали его.

Разумеется, можно переопределить список `:defaults` в `config/application.rb`:

```ruby
config.action_view.javascript_expansions[:defaults] = %w(foo.js bar.js)
```

Также можно определить новые значения по умолчанию.

```ruby
config.action_view.javascript_expansions[:projects] = %w(projects.js tickets.js)
```

А затем использовать их, ссылаясь так же, как на `:defaults`:

```erb
<%= javascript_include_tag :projects %>
```

При использовании `:defaults`, если файл `application.js` существует в `public/javascripts`, он также будет включен в конец.

Также, если отключен файлопровод, опция `all` загружает каждый файл javascript из каталога `public/javascripts`:

```erb
<%= javascript_include_tag :all %>
```

Отметьте, что сначала будут включены выбранные по умолчанию скрипты, поскольку они могут требоваться во всех последующих файлах.

Также можете применить опцию `:recursive` для загрузки файлов в подпапках `public/javascripts`:

```erb
<%= javascript_include_tag :all, :recursive => true %>
```

Если вы загружаете несколько файлов javascript, то можете объединить несколько файлов в единую загрузку. Чтобы сделать это, определите `:cache => true` в вашем `javascript_include_tag`:

```erb
<%= javascript_include_tag "main", "columns", :cache => true %>
```

По умолчанию, объединенный файл будет доставлен как `javascripts/all.js`. Вместо этого вы можете определить собственное расположение для кэшированного ресурсного файла:

```erb
<%= javascript_include_tag "main", "columns",
  :cache => "cache/main/display" %>
```

Можно даже использовать динамические пути, такие как `cache/#{current_site}/main/display`.

#### Присоединение файлов CSS с помощью `stylesheet_link_tag`

Хелпер `stylesheet_link_tag` возвращает HTML тег `<link>` для каждого предоставленного источника.

При использовании Rails с включенным "Asset Pipeline" (файлопроводом), этот хелпер создаст ссылку на `/assets/stylesheets/`. Эта ссылка будет затем обработана гемом Sprockets. Файл таблицы стилей может быть размещен в одном из трех мест: `app/assets`, `lib/assets` или `vendor/assets`.

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
<%= stylesheet_link_tag "main_print", :media => "print" %>
```

Если файлопровод отключен, опция `all` создает ссылки на каждый файл CSS в `public/stylesheets`:

```erb
<%= stylesheet_link_tag :all %>
```

Также можете применить опцию `:recursive` для загрузки файлов в подпапках каталога `public/stylesheets`:

```erb
<%= stylesheet_link_tag :all, :recursive => true %>
```

Если вы загружаете несколько файлов CSS, то можете объединить несколько файлов в единую загрузку. Чтобы сделать это, определите `:cache => true` в вашем `stylesheet_link_tag`:

```erb
<%= stylesheet_link_tag "main", "columns", :cache => true %>
```

По умолчанию, объединенный файл будет доставлен как `stylesheets/all.css`. Вместо этого вы можете определить собственное расположение для кэшированного ресурсного файла:

```erb
<%= stylesheet_link_tag "main", "columns",
  :cache => "cache/main/display" %>
```

Можно даже использовать динамические пути, такие как `cache/#{current_site}/main/display`.

#### Присоединение изображений с помощью `image_tag`

Хелпер `image_tag` создает HTML тег `<img />` для определенного файла. По умолчанию файлы загружаются из `public/images`.

WARNING: Отметьте, что вы должны определить расширение у файла с изображением. Прежние версии Rails позволяли вызвать всего лишь имя изображения и добавляли `.png`, если расширение не было задано, но Rails 3.0 так не делает.

```erb
<%= image_tag "header.png" %>
```

Вы можете предоставить путь к изображению, если желаете:

```erb
<%= image_tag "icons/delete.gif" %>
```

Вы можете предоставить хэш дополнительных опций HTML:

```erb
<%= image_tag "icons/delete.gif", {:height => 45} %>
```

Или альтернативный текст, если пользователь отключил показ изображений в браузере. Если вы не определили явно тег alt, по умолчанию будет указано имя файла с большой буквы и без расширения, например, эти два тега изображения возвратят одинаковый код:

```erb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", :alt => "Home" %>
```

Можете указать специальный тег size в формате "{width}x{height}":

```erb
<%= image_tag "home.gif", :size => "50x20" %>
```

В дополнение к вышеописанным специальным тегам, можно предоставить итоговый хэш стандартных опций HTML, таких как `:class`, или `:id`, или `:name`:

```erb
<%= image_tag "home.gif", :alt => "Go Home",
                          :id => "HomeImage",
                          :class => "nav_bar" %>
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

Подобно `image_tag`, можно предоставить путь или абсолютный, или относительный к директории `public/videos`. Дополнительно можно определить опцию `:size => "#{width}x#{height}"`, как и в `image_tag`. Теги видео также могут иметь любые опции HTML, определенные в конце (`id`, `class` и др.).

Тег видео также поддерживает все HTML опции `&lt;video&gt;` с помощью хэша HTML опций, включая:

* `:poster => "image_name.png"`, предоставляет изображение для размещения вместо видео до того, как оно начнет проигрываться.
* `:autoplay => true`, запускает проигрывание по загрузке страницы.
* `:loop => true`, запускает видео сначала, как только оно достигает конца.
* `:controls => true`, предоставляет пользователю поддерживаемые браузером средства управления для взаимодействия с видео.
* `:autobuffer => true`, файл видео предварительно загружается для пользователя по загрузке страницы.

Также можно определить несколько видео для проигрывания, передав массив видео в `video_tag`:

```erb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

Это создаст:

```erb
<video><source src="trailer.ogg" /><source src="movie.ogg" /></video>
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

* `:autoplay => true`, начинает воспроизведение аудио по загрузке страницы
* `:controls => true`, предоставляет пользователю поддерживаемые браузером средства управления для взаимодействия с аудио.
* `:autobuffer => true`, файл аудио предварительно загружается для пользователя по загрузке страницы.
