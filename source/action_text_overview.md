Обзор Action Text
=================

Это руководство предоставляет вам все, что нужно, чтобы начать обрабатывать содержимое обогащенного текста.

После прочтения этого руководства, вы узнаете:

* Как настроить Action Text.
* Как обрабатывать содержимое обогащенного текста.
* Как стилизовать содержимое и вложения обогащенного текста.

--------------------------------------------------------------------------------

Что такое Action Text?
--------------------

Action Text вносит возможность хранения и редактирования обогащенного текста в Rails. Он включает [редактор Trix](https://trix-editor.org), обрабатывающий все, от форматирования до ссылок, до цитат, до списков, до встроенных изображений и галерей. Обогащенный текст, созданный редактором Trix, сохраняется в собственной модели RichText, связанной с любой существующей моделью Active Record приложения. Любые встроенные изображения (или другие вложения) автоматически сохраняются с помощью Active Storage и связываются с включающей моделью RichText.

## Trix в сравнении с другими редакторами обогащенного текста

Большинство редакторов WYSIWYG являются обертками для `contenteditable` и `execCommand` HTML API, разработанным Microsoft для поддержки живого редактирования веб страниц в Internet Explorer 5.5, и [случайно обратно разработанного](https://blog.whatwg.org/the-road-to-html-5-contenteditable#history) и скопированного другими браузерами.

Так как эти API никогда не были полностью определены или документированы, и так как редакторы WYSIWYG HTML охватывают слишком многое, в реализации для каждого браузера есть свой набор ошибок и странностей, и разработчики JavaScript оставлены наедине разбираться с этими неудобствами.

Trix уклоняется от этих неудобств, рассматривая contenteditable как устройство ввода/вывода: когда происходит ввод в редактор, Trix конвертирует этот ввод в операцию редактирования в своей внутренней модели документа, и затем перерисовывает этот документ в редакторе. Это предоставляет Trix полный контроль над тем, что происходит после каждого нажатия клавиш, и помогает избегать необходимости использовать execCommand вообще.

## Установка

Запустите `bin/rails action_text:install` для добавления пакета Yarn и копирования необходимой миграции. Также нужно настроить Active Storage для встроенных изображений и других вложений. Обратитесь к руководству [Обзор Active Storage](/active_storage_overview) guide.

NOTE: Action Text использует полиморфные связи с таблицей `action_text_rich_texts`, поэтому он может быть совместно использован со всеми моделями, у которых есть атрибуты обогащенного текста. Если ваши модели с содержимым Action Text используют значения UUID для идентификаторов, всем моделям, использующим атрибуты Action Text, необходимо использовать значения UUID для их уникальных идентификаторов. Генерируемая миграция для Action Text также должна быть обновлена, с указанием `type: :uuid` для строчки `:record` `references`.

После завершения установки, для приложения Rails следует выполнить следующие изменения:

1. `trix` и `@rails/actiontext` должны быть затребованы в точке входа JavaScript.

    ```js
    // application.js
    import "trix"
    import "@rails/actiontext"
    ```

2. Таблица стилей `trix` будет включена вместе со стилями Action Text в ваш файл `application.css`.

## Создание содержимого обогащенного текста

Добавьте поле обогащенного текста в существующую модель:

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  has_rich_text :content
end
```

или добавьте поле обогащенного текста при создании новой модели с помощью:

```
bin/rails generate model Message content:rich_text
```

**Note:** не нужно добавлять поле `content` в таблице `messages`.

Затем обратитесь к этому полю в форме для модели:

```erb
<%# app/views/messages/_form.html.erb %>
<%= form_with model: message do |form| %>
  <div class="field">
    <%= form.label :content %>
    <%= form.rich_text_area :content %>
  </div>
<% end %>
```

И, наконец, используйте [`rich_text_area`], чтобы отобразить очищенный обогащенный текст на странице:

```erb
<%= @message.content %>
```

Чтобы принимать содержимое обогащенного текста, все, что нужно, это разрешить указанный атрибут:

```ruby
class MessagesController < ApplicationController
  def create
    message = Message.create! params.require(:message).permit(:title, :content)
    redirect_to message
  end
end
```

[`rich_text_area`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-rich_text_area

## Отображение содержимого обогащенного текста

По умолчанию Action Text отобразит содержимое обогащенного текста внутри элемента с классом `.trix-content`:

```html+erb
<%# app/views/layouts/action_text/contents/_content.html.erb %>
<div class="trix-content">
  <%= yield %>
</div>
```

Элементы с этим классом, а также редактор Action Text, стилизуются [таблицей стилей `trix`](https://raw.githubusercontent.com/basecamp/trix/master/dist/trix.css). Чтобы вместо этого предоставить свои стили, уберите строчку `= require trix` из таблицы стилей `app/assets/stylesheets/actiontext.css`, созданной установщиком.

Чтобы изменить HTML, отображаемый вокруг содержимого обогащенного текста, отредактируйте шаблон `app/views/layouts/action_text/contents/_content.html.erb`, созданный установщиком.

Чтобы изменить HTML, отображаемый для встроенных изображений и других вложений (известных как бинарные объекты), отредактируйте шаблон `app/views/active_storage/blobs/_blob.html.erb`, созданный установщиком.

### Отрисовка вложений

В дополнение к вложениям, загруженным с помощью Active Storage, Action Text может встроить все, что может быть найдено по [Signed GlobalID](https://github.com/rails/globalid#signed-global-ids).

Action Text отрисовывает вложенные элементы `<action-text-attachment>`, преобразуя их атрибут `sgid` в экземпляр. Будучи найденным, этот экземпляр передается в [`render`](https://edgeapi.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render). Результирующий HTML вкладывается как потомок в элемент `<action-text-attachment>`.

Например, рассмотрим модель `User`:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_one_attached :avatar
end

user = User.find(1)
user.to_global_id.to_s #=> gid://MyRailsApp/User/1
user.to_signed_global_id.to_s #=> BAh7CEkiCG…
```

Затем, рассмотрим некоторое содержимое обогащенного текста, в которое вложен элемент `<action-text-attachment>`, ссылающийся на подписанный GlobalID экземпляра `User`:

```html
<p>Hello, <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>.</p>
```

Action Text преобразует, используя строку "BAh7CEkiCG…", чтобы найти экземпляр `User`. Далее, рассмотрим партиал приложения `users/user`:

```html+erb
<%# app/views/users/_user.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

Результирующий HTML, отрисованный Action Text, будет выглядеть наподобие:

```html
<p>Hello, <action-text-attachment sgid="BAh7CEkiCG…"><span><img src="..."> Jane Doe</span></action-text-attachment>.</p>
```

Чтобы отобразить другой партиал, определите `User#to_attachable_partial_path`:

```ruby
class User < ApplicationRecord
  def to_attachable_partial_path
    "users/attachable"
  end
end
```

Затем объявите этот партиал. Экземпляр `User` будет доступен как локальная для партиала переменная:

```html+erb
<%# app/views/users/_attachable.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

Для интеграции с отображением Action Text `<action-text-attachment>` класс должен:

* включать модуль `ActionText::Attachable`
* реализовывать `#to_sgid(**options)` (доступно в [`GlobalID::Identification`][global-id])
* (опционально) объявить `#to_attachable_partial_path`

По умолчанию, все потомки `ActiveRecord::Base` включают [`GlobalID::Identification`][global-id], и, следовательно, совместимы с `ActionText::Attachable`.

[global-id]: https://github.com/rails/globalid#usage

## Избегание N+1 запроса

Если хотите предварительно загрузить зависимую модель `ActionText::RichText`, если допустить, что поле обогащенного текста названо `content`, можно использовать именованный скоуп:

```ruby
Message.all.with_rich_text_content # Загружает тело без вложений.
Message.all.with_rich_text_content_and_embeds # Загружает тело и вложения.
```

## Разработка API / Бэкенд

1. В API бэкенда (например, использующий JSON) необходим отдельный адрес для загрузки файлов, создающий `ActiveStorage::Blob` и возвращающий его `attachable_sgid`:

    ```json
    {
      "attachable_sgid": "BAh7CEkiCG…"
    }
    ```

2. Возьмите этот `attachable_sgid` и сообщите своему фронтенду вставить его в содержимое обогащенного текста с помощью тега `<action-text-attachment>`:

    ```html
    <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>
    ```

Это основано на подходе Basecamp, поэтому, если не понимаете, что вам нужно, проверьте [документацию Basecamp](https://github.com/basecamp/bc3-api/blob/master/sections/rich_text.md).
