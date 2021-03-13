Работа с JavaScript в Rails
===========================

Это руководство раскрывает встроенную в Rails функциональность Ajax/JavaScript (и даже чуть больше), который позволит вам с легкостью создать насыщенные и динамические приложения Ajax!

После прочтения этого руководства вы узнаете:

* Об основах Ajax.
* О ненавязчивом JavaScript.
* Как помогут встроенные хелперы Rails.
* Как обрабатывать Ajax на стороне сервера.
* О геме Turbolinks.
* Как включать токен Cross-Site Request Forgery в заголовки запроса.

Введение в Ajax
---------------

Чтобы понять Ajax, нужно сперва понять, что обычно делает браузер.

Когда вы переходите на `http://localhost:3000` в своем браузере, браузер (ваш 'клиент') осуществляет запрос к серверу. Он парсит отклик, затем получает все связанные ассеты, такие как файлы JavaScript, таблицы стилей и изображения. Затем он собирает страницу. Если вы нажмете на ссылку, он сделает то же самое: получит страницу, получит ассеты, сложит их вместе, отобразит результаты. Это называется 'цикл запроса'.

JavaScript также может осуществлять запросы к серверу и парсить отклики. У него также есть возможность обновить информацию на странице. Объединив эти две силы, программист JavaScript может изготовить веб-страницу, обновляющую лишь части себя, без необходимости получения полных данных с сервера. Эту мощную технологию мы называем Ajax.

К примеру, вот некоторый код JavaScript, осуществляющий запрос Ajax:

```js
fetch("/test")
  .then((data) => data.text())
  .then((html) => {
    const results = document.querySelector("#results");
    results.insertAdjacentHTML("beforeend", html);
  });
```

Этот код получает данные из "/test", а затем присоединяет результат к элементу с id `results`.

Rails предоставляет небольшую встроенную поддержку для создания веб-страниц с помощью такой техники. Вам редко придется писать такой код самим. Оставшаяся часть руководства покажет, как Rails может помочь создавать сайты схожим образом, но в основе лежит эта довольно простая техника.

Ненавязчивый JavaScript
-----------------------

Rails использует технику "ненавязчивый JavaScript" для управления присоединением JavaScript к DOM. Обычно он рассматривается как лучшая практика во фронтенд-сообществе, но иногда встречаются статьи, демонстрирующие иные способы.

Вот простейший способ написания JavaScript. Его называют 'встроенный JavaScript':

```html
<a href="#" onclick="this.style.backgroundColor='#990000';event.preventDefault();">Paint it red</a>
```

При нажатии, задний фон ссылки станет красным. Проблема в следующем: что будет, если у нас много JavaScript, который мы хотим выполнить по клику?

```html
<a href="#" onclick="this.style.backgroundColor='#009900';this.style.color='#FFFFFF';event.preventDefault();">Paint it green</a>
```

Некрасиво, правда? Можно вытащить определение функции из обработчика клика, и перевести его в функцию:

```js
window.paintIt = function(event, backgroundColor, textColor) {
  event.preventDefault();
  event.target.style.backgroundColor = backgroundColor;
  if (textColor) {
    event.target.style.color = textColor;
  }
}
```

А затем на нашей странице:

```html
<a href="#" onclick="paintIt(event, '#990000')">Paint it red</a>
```

Немного лучше, но как насчет нескольких ссылок, для которых нужен тот же эффект?

```html
<a href="#" onclick="paintIt(event, '#990000')">Paint it red</a>
<a href="#" onclick="paintIt(event, '#009900', '#FFFFFF')">Paint it green</a>
<a href="#" onclick="paintIt(event, '#000099', '#FFFFFF')">Paint it blue</a>
```

Совсем не DRY, да? Это можно исправить, используя события. Мы добавим атрибут `data-*` нашим ссылкам, а затем привяжем обработчик на событие клика для каждой ссылки, имеющей этот атрибут:

```js
function paintIt(element, backgroundColor, textColor) {
  element.style.backgroundColor = backgroundColor;
  if (textColor) {
    element.style.color = textColor;
  }
}

window.addEventListener("load", () => {
  const links = document.querySelectorAll(
    "a[data-background-color]"
  );
  links.forEach((element) => {
    element.addEventListener("click", (event) => {
      event.preventDefault();

      const {backgroundColor, textColor} = element.dataset;
      paintIt(element, backgroundColor, textColor);
    });
  });
});
```

```html
<a href="#" data-background-color="#990000">Paint it red</a>
<a href="#" data-background-color="#009900" data-text-color="#FFFFFF">Paint it green</a>
<a href="#" data-background-color="#000099" data-text-color="#FFFFFF">Paint it blue</a>
```

Это называется 'ненавязчивым' JavaScript, так как мы больше не смешиваем JavaScript с HTML. Мы должным образом разделили ответственность, сделав будущие изменения простыми. Можно с легкостью добавить поведение для любой ссылки, добавив атрибут data. Можно пропустить весь наш JavaScript через минимизатор. Этот JavaScript можно подключить на каждой странице, что означает, что он будет загружен только при загрузке первой страницы, затем будет кэширован для остальных страниц. Множество небольших преимуществ.

Встроенные хелперы
------------------

### (remote-elements) Remote элементы

Rails предоставляет ряд вспомогательных методов для вью, написанных на Ruby, помогающих вам генерировать HTML. Иногда хочется добавить немного Ajax к этим элементам, и Rails подсобит в таких случаях.

Так как JavaScript ненавязчив, "Ajax-хелперы" Rails фактически состоят из двух частей: часть JavaScript и часть Ruby.

Если не отключить Asset Pipeline, [rails-ujs](https://github.com/rails/rails/tree/main/actionview/app/assets/javascripts) предоставляет часть для JavaScript, а хелперы вью на обычном Ruby добавляют подходящие теги в DOM.

Ниже вы можете прочитать о различных событиях, которые вызываются при работе с remote элементами внутри вашего приложения.

#### form_with

[`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with) - это хелпер, помогающий писать формы. Чтобы использовать Ajax для формы, можно передать опцию `:local` в `form_with`.

```erb
<%= form_with(model: @article, id: "new-article", local: false) do |form| %>
  ...
<% end %>
```

Это сгенерирует следующий HTML:

```html
<form id="new-article" action="/articles" accept-charset="UTF-8" method="post" data-remote="true">
  ...
</form>
```

Обратите внимание на `data-remote="true"`. Теперь форма будет подтверждена с помощью Ajax вместо обычного браузерного механизма подтверждения.

Впрочем, вы не хотите просто сидеть с заполненной формой. Возможно, вы хотите что-то сделать при успешном подтверждении. Для этого привяжите что-нибудь к событию `ajax:success`. При неудаче используйте `ajax:error`. Посмотрите:

```js
window.addEventListener("load", () => {
  const element = document.querySelector("#new-article");
  element.addEventListener("ajax:success", (event) => {
    const [_data, _status, xhr] = event.detail;
    element.insertAdjacentHTML("beforeend", xhr.responseText);
  });
  element.addEventListener("ajax:error", () => {
    element.insertAdjacentHTML("beforeend", "<p>ERROR</p>");
  });
});
```

Очевидно, что хочется чего-то большего, но ведь это только начало.

#### link_to

[`link_to`](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to) - это хелпер, помогающий генерировать ссылки. У него есть опция `:remote`, которую используют следующим образом:

```erb
<%= link_to "an article", @article, remote: true %>
```

что сгенерирует

```html
<a href="/articles/1" data-remote="true">an article</a>
```

Можно привязаться к тем же событиям Ajax, что и в `form_with`. Вот пример. Предположим, имеется список публикаций, которые можно удалить одним кликом. Нужно генерировать некоторый HTML, например так:

```erb
<%= link_to "Delete article", @article, remote: true, method: :delete %>
```

и написать некоторый JavaScript:

```js
window.addEventListener("load", () => {
  const links = document.querySelectorAll("a[data-remote]");
  links.forEach((element) => {
    element.addEventListener("ajax:success", () => {
      alert("The article was deleted.");
    });
  });
});
```

#### button_to

[`button_to`](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to) - это хелпер, помогающий создавать кнопки. У него есть опция `:remote`, которая вызывается так:

```erb
<%= button_to "An article", @article, remote: true %>
```

это сгенерирует

```html
<form action="/articles/1" class="button_to" data-remote="true" method="post">
  <input type="submit" value="An article" />
</form>
```

Поскольку это всего лишь `<form>`, применима вся информация, что и для `form_with`.

### Настройка remote элементов

Можно настроить поведение элементов с атрибутом `data-remote` без написания строчек на JavaScript. Вы можете указать дополнительные `data-`атрибуты для достижения этой цели.

#### `data-method`

Нажатие на гиперссылки всегда приводит к запросу HTTP GET. Однако, если ваше приложение - [RESTful](https://ru.wikipedia.org/wiki/REST), то некоторые ссылки фактически являются экшнами, которые изменяют данные на сервере и должны выполняться с не-GET-запросами. Этот атрибут позволяет пометить такие ссылки с помощью явного метода, такого как "post", "put" или "delete".

Суть его работы заключается в том, что после нажатия на ссылку, она создает скрытую форму в документе с атрибутом "action", который соответствует значению "href" ссылки, и методу, соответствующему значению `data-method`, и отправляет эту форму.

NOTE: Поскольку отправка форм с помощью методов HTTP, отличных от GET и POST, поддерживается не всеми браузерами, то все остальные HTTP методы фактически отправляются через POST с использованием метода, указанного в параметре `_method`. Rails автоматически обнаруживает и компенсирует это.

#### `data-url` и `data-params`

Некоторые элементы вашей страницы на самом деле не ссылаются на какой-либо URL, но вам может понадобиться, чтобы они вызывали Ajax. Указание атрибута `data-url` вместе с `data-remote` вызовет Ajax для заданного URL. Вы также можете указать дополнительные параметры через атрибут `data-params`.

Это может быть полезно для того, чтобы вызвать экшн над чекбоксами, например:

```html
<input type="checkbox" data-remote="true"
    data-url="/update" data-params="id=10" data-method="put">
```

#### `data-type`

Также можно явно определить Ajax `dataType` при выполнении запросов для элементов `data-remote`, посредством атрибута `data-type`.

### Подтверждения

Вы можете запросить дополнительное подтверждение пользователя, добавив атрибут `data-confirm` в ссылки и формы. Пользователю будет показано с помощью JavaScript диалоговое окно `confirm()`, содержащее текст атрибута. Если пользователь решит нажать на "отменить", экшн не будет выполнен.

Добавление этого атрибута в теги ссылки вызовет диалоговое окно при нажатии на нее, и добавление атрибута в теги формы вызовет его при отправке. Например:

```erb
<%= link_to "Dangerous zone", dangerous_zone_path,
  data: { confirm: 'Are you sure?' } %>
```

Это сгенерирует:

```html
<a href="..." data-confirm="Are you sure?">Dangerous zone</a>
```

Атрибут также разрешено использовать для кнопок отправки формы. Это позволяет настроить предупреждающее сообщение в зависимости от кнопки, которая была нажата. В этом случае у вас **не** должно быть `data-confirm` в самой форме.

### Автоматическое отключение

Также возможно автоматически отключить возможность ввода, пока форма отправляется с помощью атрибута `data-disable-with`. Это делается для предотвращения случайного двойного клика пользователя, что может привести к дублированию HTTP-запросов, которые бэкенд может не обнаружить как таковой. Значение атрибута - это текст, который станет новым значением кнопки в отключенном состоянии.

Это также работает для ссылок с атрибутом `data-method`.

Например:

```erb
<%= form_with(model: Article.new) do |form| %>
  <%= form.submit data: { disable_with: "Saving..." } %>
<% end %>
```

Это сгенерирует форму с:

```html
<input data-disable-with="Saving..." type="submit">
```

### Обработчики событий Rails-ujs

Rails 5.1 представил rails-ujs и убрал поддержку jQuery как зависимости. Как результат, ненавязчивый драйвер JavaScript (UJS) был переписан для работы без jQuery. Эти нововведения приводят к небольшим изменениям в `пользовательских событиях`, срабатывающих во время запроса:

NOTE: Сигнатура вызовов обработчиков событий UJS изменилась. В отличие от версии с jQuery, все пользовательские события возвращают только один параметр: `event`. В этом параметре есть дополнительный атрибут `detail`, который содержит массив дополнительных параметров. Информацию о ранее используемом `jquery-ujs` в Rails 5 и ранее читайте в [вики `jquery-ujs`](https://github.com/rails/jquery-ujs/wiki/ajax).

| Имя события         | Доп. параметры (event.detail)   | Срабатывают                                                 |
|---------------------|---------------------------------|-------------------------------------------------------------|
| `ajax:before`       |                                 | Перед всем ajax-бизнесом.                                   |
| `ajax:beforeSend`   | [xhr, options]                  | Перед отправкой запроса.                                    |
| `ajax:send`         | [xhr]                           | Когда запрос отправлен.                                     |
| `ajax:stopped`      |                                 | Когда запрос остановлен.                                    |
| `ajax:success`      | [response, status, xhr]         | После завершения, если отклик был success.                  |
| `ajax:error`        | [response, status, xhr]         | После завершения, если отклик был error.                    |
| `ajax:complete`     | [xhr, status]                   | После завершения запроса, независимо от результата.         |

Пример использования:

```js
document.body.addEventListener("ajax:success", (event) => {
  const [data, status, xhr] = event.detail;
});
```

### Останавливаемые события

Можно остановить выполнение запроса Ajax, выполнив `event.preventDefault()` из обработчиков методов `ajax:before` или `ajax:beforeSend`. Событие `ajax:before` может манипулировать данными формы перед сериализацией и событие `ajax:beforeSend` полезно для добавления пользовательских заголовков запроса.

Если остановить событие `ajax:aborted:file`, поведение по умолчанию, позволяющее браузеру отправлять форму обычным способом (то есть не-Ajax представление), будет отменено и форма вообще не будет отправлена. Это полезно для реализации вашего собственного Ajax способа загрузки файлов.

Обратите внимание, необходимо использовать `return false`, чтобы предотвратить событие для `jquery-ujs` и `e.preventDefault()` для `rails-ujs`.

Со стороны сервера
------------------

Ajax - это не только сторона клиента, необходимо также поработать на стороне сервера, чтобы добавить его поддержку. Часто людям нравится, когда на их запросы Ajax возвращается JSON, а не HTML. Давайте обсудим, что необходимо для этого сделать.

### Простой пример

Представьте, что у вас есть ряд пользователей, которых нужно отобразить, и предоставить форму на той же странице для создания нового пользователя. Экшн index вашего контроллера выглядит так:

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    @user = User.new
  end
  # ...
```

Вью для index (`app/views/users/index.html.erb`) содержит:

```erb
<b>Users</b>

<ul id="users">
<%= render @users %>
</ul>

<br>

<%= form_with model: @user do |form| %>
  <%= form.label :name %><br>
  <%= form.text_field :name %>
  <%= form.submit %>
<% end %>
```

Партиал `app/views/users/_user.html.erb` содержит следующее:

```erb
<li><%= user.name %></li>
```

Верхняя часть индексной страницы отображает пользователей. Нижняя часть представляет форму для создания нового пользователя.

Нижняя форма вызовет экшн `create` в `UsersController`. Так как у формы опция remote установлена true, запрос будет передан через post к `UsersController` как запрос Ajax, ожидая JavaScript. Чтобы обслужить этот запрос, экшн `create` вашего контроллера должен выглядеть так:

```ruby
  # app/controllers/users_controller.rb
  # ......
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.js
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
```

Обратите внимание на `format.js` в блоке `respond_to`, который позволяет контроллеру откликаться на ваши запросы Ajax. Далее необходим соответствующий файл вью `app/views/users/create.js.erb`, генерирующий фактический код JavaScript, который будет отослан и выполнен на стороне клиента.

```js
var users = document.querySelector("#users");
users.insertAdjacentHTML("beforeend", "<%= j render(@user) %>");
```

NOTE: Рендеринг вью JavaScript не выполняет какого-либо препроцессинга, поэтому тут не следует использовать синтаксис ES6.

Turbolinks
----------

Rails поставляется с [библиотекой Turbolinks](https://github.com/turbolinks/turbolinks), использующей Ajax для ускорения рендеринга страницы в большинстве приложений.

### Как работает Turbolinks

Turbolinks добавляет обработчик кликов на всех тегах `<a>` на странице. Если ваш браузер поддерживает [PushState](https://developer.mozilla.org/ru/docs/Web/API/History_API#Метод_pushState()),
Turbolinks сделает запрос Ajax для страницы, распарсит отклик и заменит полностью `<body>` страницы на `<body>` отклика. Затем он использует PushState для изменения URL на правильный, сохраняя семантику для обновления и предоставляя красивые URL.

Если хотите отключить Turbolinks для определенных ссылок, добавьте атрибут `data-turbolinks="false"` к тегу:

```html
<a href="..." data-turbolinks="false">No turbolinks here</a>.
```

### События изменения страницы

Часто необходимо что-то сделать при загрузке страницы. С помощью DOM вы писали что-то вроде этого:

```js
window.addEventListener("load", () => {
  alert("page has loaded!");
});
```

Однако, поскольку Turbolinks переопределяет обычный процесс загрузки страницы, событие, на которое полагается вышеуказанный код, не произойдет. Если у вас есть подобный код, следует его изменить на следующий:

```js
document.addEventListener("turbolinks:load", () => {
  alert("page has loaded!");
});
```

Подробности, включая другие возможные события, можно посмотреть [в Turbolinks README](https://github.com/turbolinks/turbolinks/blob/master/README.md).

Токен Cross-Site Request Forgery (CSRF) в Ajax
----

При использовании другой библиотеки для совершения вызовов Ajax, необходимо добавить токен безопасности в качестве заголовка по умолчанию для вызовов Ajax вашей библиотеки. Чтобы получить токен:

```js
const token = document.getElementsByName(
  "csrf-token"
)[0].content;
```

Затем нужно вставить этот токен в качестве заголовка `X-CSRF-Token` вашего запроса Ajax. Не нужно добавлять токен CSRF для запросов GET, нужно только для не-GET.

Подробнее о Cross-Site Request Forgery можно прочитать в [руководстве по безопасности](/ruby-on-rails-security-guide#cross-site-request-forgery-csrf).

Другие ресурсы
--------------

Вот несколько полезных ссылок, которые позволят вам узнать больше:

* [rails-ujs wiki](https://github.com/rails/rails/tree/main/actionview/app/assets/javascripts)
* [Railscasts: Unobtrusive JavaScript](http://railscasts.com/episodes/205-unobtrusive-javascript)
* [Railscasts: Turbolinks](http://railscasts.com/episodes/390-turbolinks)
