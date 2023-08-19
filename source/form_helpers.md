Хелперы форм в Action View
==========================

Формы в веб-приложениях - это основной интерфейс для пользовательского ввода. Однако, разметка форм может быстро стать нудной в написании и поддержке из-за необходимости обрабатывать имена элементов управления формы и их бесчисленные атрибуты. Rails устраняет эту сложность, предоставляя хелперы вью для генерации разметки форм. Однако, поскольку эти хелперы имеют разные принципы использования, разработчикам нужно знать различия между похожими методами хелперов, прежде чем начать их использовать.

После прочтения этого руководства, вы узнаете:

* Как создавать формы поиска и подобного рода формы, не представляющие определенную модель вашего приложения
* Как сделать модельно-ориентированные формы для создания и редактирования определенных записей базы данных
* Как сгенерировать списки выбора (select box) с различными типами данных
* Какие хелперы даты и времени предоставляет Rails
* В чем особенность формы загрузки файлов
* Как отправлять формы на внешние ресурсы и указывать настройку `authenticity_token`.
* Как создавать сложные формы

NOTE: Это руководство не является подробной документацией по доступным хелперам форм и их аргументам. Для получения полной информации, обратитесь к [документации по Rails API](http://api.rubyonrails.org/).

Разбираемся с простыми формами
------------------------------

Главный хелпер форм - это [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with).

```erb
<%= form_with do |form| %>
  Содержимое формы
<% end %>
```

При подобном вызове без аргументов, он создает тег формы, который при отправке сформирует POST-запрос на текущую страницу. Например, предположим текущая страница является домашней, тогда сгенерированный HTML будет выглядеть следующим образом (некоторые разрывы строчек добавлены для читаемости):

```html
<form accept-charset="UTF-8" action="/" method="post">
  <input name="authenticity_token" type="hidden" value="J7CBxfHalt49OSHp27hblqK20c9PgwJ108nDHX/8Cts=" />
  Содержимое формы
</form>
```

Можно увидеть, что HTML содержит элемент `input` с типом `hidden`. Этот `input` важен, поскольку без него формы, у которых action не "GET", не могут быть успешно отправлены. Скрытый элемент input с именем `authenticity_token` является особенностью безопасности Rails, называемой **защитой от межсайтовой подделки запроса**, и хелперы форм генерируют его для каждой формы, у которых action не "GET" (при условии, что эта особенность безопасности включена). Подробнее об этом можно прочитать в руководстве [Безопасность приложений на Rails](/security#cross-site-request-forgery-csrf).

### Характерная форма поиска

Одной из наиболее простых форм, встречающихся в вебе, является форма поиска. Эта форма содержит:

* элемент формы с методом "GET",
* метку для поля ввода,
* элемент поля ввода текста и
* элемент отправки.

Чтобы создать эту форму, используем `form_with` и объект построителя формы, который он вкладывает. Как тут:

```erb
<%= form_with url: "/search", method: :get do |form| %>
  <%= form.label :query, "Search for:" %>
  <%= form.text_field :query %>
  <%= form.submit "Search" %>
<% end %>
```

Это сгенерирует следующий HTML:

```html
<form action="/search" method="get" accept-charset="UTF-8" >
  <label for="query">Search for:</label>
  <input id="query" name="query" type="text" />
  <input name="commit" type="submit" value="Search" data-disable-with="Search" />
</form>
```

TIP: Передача `url: my_specified_path` в `form_with` сообщает форме, куда осуществлять запрос. Однако, как объясняется ниже, в форму также можно передавать объекты Active Record.

TIP: Для каждого поля ввода формы генерируется атрибут ID из его имени (`"query"` в примере). Эти ID могут быть очень полезны для стилизации CSS или управления элементами форм с помощью JavaScript.

IMPORTANT: Используйте "GET" как метод для форм поиска. Это позволяет пользователям добавлять в закладки определенный поиск и потом возвращаться к нему. В более общем смысле Rails призывает вас использовать правильный метод HTTP для экшна.

### Хелперы для генерации элементов формы

Объект построителя формы, вкладываемый `form_with`, предоставляет ряд вспомогательных методов для генерации элементов формы, таких как чекбоксы, текстовые поля, радиокнопки и так далее. Первый параметр у них это всегда имя поля ввода. Когда форма будет отправлена, имя будет передано вместе с данными формы, и, в свою очередь, помещено в `params` в контроллере со значением, введенным пользователем для этого поля. Например, если форма содержит `<%= form.text_field :query %>`, то значение этого поля можно получить в контроллере с помощью `params[:query]`.

При именовании полей ввода Rails использует определенные соглашения, делающие возможным отправлять параметры с нескалярными величинами, такими как массивы и хэши, которые также будут доступны в `params`. Подробнее об этом можно прочесть в [разделе про именование параметров](#understanding-parameter-naming-conventions). Для подробностей по точному использованию этих хелперов, обратитесь к [документации по API](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).

#### Чекбоксы

Чекбоксы - это элементы управления формой, которые дают пользователю ряд опций, которые он может включить или выключить:

```erb
<%= form.check_box :pet_dog %>
<%= form.label :pet_dog, "I own a dog" %>
<%= form.check_box :pet_cat %>
<%= form.label :pet_cat, "I own a cat" %>
```

Это сгенерирует следующее:

```html
<input type="checkbox" id="pet_dog" name="pet_dog" value="1" />
<label for="pet_dog">I own a dog</label>
<input type="checkbox" id="pet_cat" name="pet_cat" value="1" />
<label for="pet_cat">I own a cat</label>
```

Первый параметр у [`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box) - это имя поля ввода. Значения чекбокса (значения, которые появятся `params`) могут быть опционально указаны с помощью третьего и четвертого параметра. Подробности смотрите в документации API.

#### Радиокнопки

Радиокнопки, чем-то похожие на чекбоксы, являются элементами управления, которые определяют набор взаимоисключающих опций (т.е. пользователь может выбрать только одну):

```erb
<%= form.radio_button :age, "child" %>
<%= form.label :age_child, "I am younger than 21" %>
<%= form.radio_button :age, "adult" %>
<%= form.label :age_adult, "I am over 21" %>
```

Результат:

```html
<input type="radio" id="age_child" name="age" value="child" />
<label for="age_child">I am younger than 21</label>
<input type="radio" id="age_adult" name="age" value="adult" />
<label for="age_adult">I am over 21</label>
```

Второй параметр для [`radio_button`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-radio_button) - это значение поля ввода. Так как эти две радиокнопки имеют одинаковое имя (`age`), пользователь может выбрать одну, и `params[:age]` будет содержать или `"child"`, или `"adult"`.

NOTE: Всегда используйте метки (labels) для чекбоксов и радиокнопок. Они связывают текст с определенной опцией и, предоставляя большее пространство для клика, упрощают выбор пользователем нужного пункта радиокнопки.

### Другие интересные хелперы

Среди других элементов управления формой стоит упомянуть текстовые области и следующие поля: паролей, числовые, даты и времени, и так далее:

```erb
<%= form.text_area :message, size: "70x5" %>
<%= form.hidden_field :parent_id, value: "foo" %>
<%= form.password_field :password %>
<%= form.number_field :price, in: 1.0..20.0, step: 0.5 %>
<%= form.range_field :discount, in: 1..100 %>
<%= form.date_field :born_on %>
<%= form.time_field :started_at %>
<%= form.datetime_local_field :graduation_day %>
<%= form.month_field :birthday_month %>
<%= form.week_field :birthday_week %>
<%= form.search_field :name %>
<%= form.email_field :address %>
<%= form.telephone_field :phone %>
<%= form.url_field :homepage %>
<%= form.color_field :favorite_color %>
```

Результат:

```html
<textarea name="message" id="message" cols="70" rows="5"></textarea>
<input type="hidden" name="parent_id" id="parent_id" value="foo" />
<input type="password" name="password" id="password" />
<input type="number" name="price" id="price" step="0.5" min="1.0" max="20.0" />
<input type="range" name="discount" id="discount" min="1" max="100" />
<input type="date" name="born_on" id="born_on" />
<input type="time" name="started_at" id="started_at" />
<input type="datetime-local" name="graduation_day" id="graduation_day" />
<input type="month" name="birthday_month" id="birthday_month" />
<input type="week" name="birthday_week" id="birthday_week" />
<input type="search" name="name" id="name" />
<input type="email" name="address" id="address" />
<input type="tel" name="phone" id="phone" />
<input type="url" name="homepage" id="homepage" />
<input type="color" name="favorite_color" id="favorite_color" value="#000000" />
```

Скрытые поля не отображаются пользователю, вместо этого они содержат данные, как и любое текстовое поле. Их значения могут быть изменены с помощью JavaScript.

IMPORTANT: Поля поиска, ввода телефона, даты, времени, цвета, даты-времени, локальных даты-времени, месяца, недели, url, email, числовые и интервалов - это элементы управления HTML5. Если необходимо, чтобы у вашего приложения была совместимость со старыми браузерами, вам необходим HTML5 polyfill (предоставляемый с помощью CSS и/или JavaScript). Хотя в таких решениях [нет недостатка](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills), популярным инструментом на сегодняшний момент является [Modernizr](http://www.modernizr.com/), предоставляющий простой способ добавить функциональность, основанной на обнаружении установленных особенностей HTML5.

TIP: Если используются поля для ввода пароля (для любых целей), вы можете настроить свое приложение для предотвращения появления их значений в логах приложения. Это можно изучить в руководстве [Безопасность приложений на Rails](/security).

Работаем с объектами модели
---------------------------

### Привязывание формы к объекту

Аргумент `:model` в `form_with` позволяет связать объект построителя формы с объектом модели. Это означает, что эта форма будет будет ограничена этим объектом модели, и поля формы будут предзаполнены значениями из этого объекта модели.

К примеру, если у нас есть такой объект модели `@article`:

```ruby
@article = Article.find(42)
# => #<Article id: 42, title: "My Title", body: "My Body">
```

Следующая форма:

```erb
<%= form_with model: @article do |form| %>
  <%= form.text_field :title %>
  <%= form.text_area :body, size: "60x10" %>
  <%= form.submit %>
<% end %>
```

Выведет:

```html
<form action="/articles/42" method="post" accept-charset="UTF-8" >
  <input name="authenticity_token" type="hidden" value="..." />
  <input type="text" name="article[title]" id="article_title" value="My Title" />
  <textarea name="article[body]" id="article_body" cols="60" rows="10">
    My Body
  </textarea>
  <input type="submit" name="commit" value="Update Article" data-disable-with="Update Article">
</form>
```

Тут нужно отметить несколько вещей:

* `action` формы автоматически заполняется подходящим значением для `@article`.
* Поля формы автоматически заполняются соответствующими значениями из `@article`.
* Имена полей формы ограничиваются с помощью `article[...]`. Это означает, что `params[:article]` будет хэшем, содержащим все значения этих полей. Подробнее о значении имен полей ввода можно прочитать в разделе [про именование параметров](#understanding-parameter-naming-conventions) этого руководства.
* Кнопке отправки автоматически присвоено подходящее текстовое значение.

TIP: По соглашению, поля ввода будут отражать атрибуты модели. Однако, это необязательно! Если имеется иная необходимая информация, ее можно включить в форму, также как атрибут, и она будет доступна как `params[:article][:my_nifty_non_attribute_input]`.

#### Хелпер `fields_for`

Хелпер [`fields_for`][] создает подобное привязывание без фактического создания тега `<form>`. Он может быть использован для рендера полей ввода для дополнительных объектов модели в той же форме. Например, если имеется модель `Person` со связанной моделью `ContactDetail`, можно создать форму для создания обеих моделей подобным образом:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <%= fields_for :contact_detail, @person.contact_detail do |contact_detail_form| %>
    <%= contact_detail_form.text_field :phone_number %>
  <% end %>
<% end %>
```

Которая выдаст такой результат:

```html
<form action="/people" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="bL13x72pldyDD8bgtkjKQakJCpd4A8JdXGbfksxBDHdf1uC0kCMqe2tvVdUYfidJt0fj3ihC4NxiVHv8GVYxJA==" />
  <input type="text" name="person[name]" id="person_name" />
  <input type="text" name="contact_detail[phone_number]" id="contact_detail_phone_number" />
</form>
```

Объект, предоставляемый `fields_for` - это form builder, подобный тому, который предоставляется `form_with`.

[`fields_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-fields_for

### (relying-on-record-identification) Положитесь на идентификацию записи

Модель Article непосредственно доступна пользователям приложения, и таким образом, следуя лучшим рекомендациям разработки на Rails, вы должны объявить ее как **ресурс**.

```ruby
resources :articles
```

TIP: Объявление ресурса имеет несколько побочных эффектов. Смотрите руководство [Роутинг в Rails](/routing) для получения более подробной информации по настройке и использованию ресурсов.

Когда работаем с ресурсами RESTful, вызовы `form_with` становятся значительно проще, если они основываются на **идентификации записи**. Вкратце, вы должны всего лишь передать экземпляр модели и позволить Rails выяснить имя модели и остальное. В обоих примерах, длинный и короткий стили приведет к тому же результату:

```ruby
## Создание новой статьи
# длинный стиль:
form_with(model: @article, url: articles_path)
# короткий стиль:
form_with(model: @article)

## Редактирование существующей статьи
# длинный стиль:
form_with(model: @article, url: article_path(@article), method: "patch")
# короткий стиль:
form_with(model: @article)
```

Отметьте, что вызов короткого стиля `form_with` является идентичным, независимо от того, запись новая или уже существует. Идентификация записи достаточно сообразительная, чтобы выяснить, новая ли запись, запрашивая `record.persisted?`. Она также выбирает правильный путь для подтверждения и имя, основанное на классе объекта.

Если у вас [одиночный ресурс](/routing#singular-resources), нужно вызвать `resource` и `resolve` для работы с `form_with`:

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

WARNING: Когда используется STI (наследование с единой таблицей) с вашими моделями, нельзя полагаться на идентификацию записей подкласса, если только их родительский класс определен ресурсом. Необходимо явно указывать `:url` и `:scope` (имя модели).

#### Работаем с пространствами имен

Если создать пространство имен для маршрутов, `form_with` также можно изящно сократить. Если в приложении есть пространство имен admin, то

```ruby
form_with model: [:admin, @article]
```

создаст форму, которая передается `ArticlesController` в пространстве имен admin (передача в `admin_article_path(@article)` в случае с обновлением). Если у вас несколько уровней пространства имен, тогда синтаксис подобный:

```ruby
form_with model: [:admin, :management, @article]
```

Более подробно о системе маршрутизации Rails и связанным соглашениям смотрите руководство [Роутинг в Rails](/routing).

### Как формы работают с методами PATCH, PUT или DELETE?

Фреймворк Rails поддерживает стиль RESTful в ваших приложениях, что подразумевает частое использование запросов "PATCH", "PUT" и "DELETE" (помимо "GET" и "POST"). Однако, большинство браузеров _не поддерживают_ методы, отличные от "GET" и "POST", когда дело доходит до подтверждения форм.

Rails работает с этой проблемой, эмулируя другие методы с помощью POST со скрытым полем, названным `"_method"`, который установлен для отображения желаемого метода:

```ruby
form_with(url: search_path, method: "patch")
```

Результат:

```html
<form accept-charset="UTF-8" action="/search" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->
</form>
```

При парсинге данных, отправленных с помощью POST, Rails принимает во внимание специальный параметр `_method` и ведет себя так, как будто бы в нем был определен этот метод HTTP ("PATCH" в этом примере).

При рендере формы кнопки отправки могут переопределять атрибут `method` с помощью ключевого слова `formmethod:`:

```erb
<%= form_with url: "/posts/1", method: :patch do |form| %>
  <%= form.button "Delete", formmethod: :delete, data: { confirm: "Are you sure?" } %>
  <%= form.button "Update" %>
<% end %>
```

Как и для элементов `<form>`, многие браузеры _не поддерживают_ переопределение методов формы, объявленные с помощью [formmethod][], отличные от "GET" и "POST".

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

IMPORTANT: В Rails 6.0 and 5.2 все формы с использованием `form_with` по умолчанию реализуют `remote: true`. Эти формы будут отправлять данные с помощью запроса XHR (Ajax). Чтобы это отключить, добавьте `local: true`. Подробности смотрите в руководстве [Работа с JavaScript в Rails](/working-with-javascript-in-rails#remote-elements).

[formmethod]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-formmethod
[button-name]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-name
[button-value]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-value

Легкое создание списков выбора
------------------------------

Списки выбора в HTML требуют значительного количества разметки - один элемент `OPTION` для каждого пункта списка. Поэтому Rails предоставляет вспомогательные методы для облегчения этого бремени.

Например, скажем у нас есть список городов для выбора пользователем. Можно использовать хелпер [`select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-select) таким образом:

```erb
<%= form.select :city, ["Berlin", "Lisbon", "Madrid"] %>
```

Результат:

```html
<select name="city" id="city">
  <option value="Berlin">Berlin</option>
  <option value="Chicago">Chicago</option>
  <option value="Madrid">Madrid</option>
</select>
```

Можно назначить значения `<option>` отличные от их надписи:

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

### Группы опций

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

### Списки выбора и объекты модели

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

Отметьте, что подходящая опция была автоматически отмечена `selected="selected"`. Так как этот список выбора был привязан к модели, не нужно указывать аргумент `:selected`!

### Выбор часового пояса и страны

Для управления поддержкой часовых поясов в Rails, можно спрашивать своих пользователей, в какой зоне они находятся. Это потребует сгенерировать пункты списка из списка предопределенных объектов [`ActiveSupport::TimeZone`](https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html), но можно просто использовать хелпер [`time_zone_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_zone_select), который уже все это содержит:

```erb
<%= form.time_zone_select :time_zone %>
```

В Rails _раньше_ был хелпер `country_select` для выбора стран, но сейчас он вынесен во внешний [плагин country_select](https://github.com/stefanpenner/country_select).

Использование хелперов даты и времени
-------------------------------------

Если не хотите использовать поля ввода даты и времени HTML5, Rails предоставляет альтернативные хелперы формы для даты и времени, выводящие обычные списки выбора. Эти хелперы рендерят список выбора на каждый компонент (год, месяц, день и т.д.). Например, если у нас есть такой объект модели `@person`:

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

Отметьте, что при отправке формы не будет одиночного значения в хэше `params`. содержащего полную дату. Вместо этого будет несколько значений со специальными именами наподобие `"birth_date(1i)"`. Active Record знает, как собрать эти особенно названные значения в полную дату или время, основываясь на объявленном типе атрибута модели. Таким образом, можно просто передать `params[:person]` в `Person.new` или `Person#update`, как будто бы форма использовала единственное поле, представляющее полную дату.

В дополнение к хелперу [`date_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-date_select), Rails предоставляет [`time_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_select) и [`datetime_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-datetime_select).

### Списки выбора с отдельными элементами времени

Rails также предоставляет хелперы для рендера списков выбора для отдельных компонентов времени: [`select_year`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_year), [`select_month`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_month), [`select_day`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_day), [`select_hour`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_hour), [`select_minute`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_minute) и [`select_second`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_second). Эти хелперы являются "чистыми" методами, что означает, что они не вызываются на экземпляре построителя формы. Например:

```erb
<%= select_year 1999, prefix: "party" %>
```

Выведет подобный список выбора

```html
<select name="party[year]" id="party_year">
  <option value="1994">1994</option>
  <option value="1995">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999" selected="selected">1999</option>
  <option value="2000">2000</option>
  <option value="2001">2001</option>
  <option value="2002">2002</option>
  <option value="2003">2003</option>
  <option value="2004">2004</option>
</select>
```

Для каждого из этих хелперов можно указать объект даты или времени вместо числа в качестве значения по умолчанию, тогда будет извлечен и использован подходящий компонент времени.

Выбор из коллекции произвольных объектов
----------------------------------------

Иногда нам нужно создать набор вариантов из коллекции произвольных объектов. Например, если у нас есть модель `City` и соответствующая связь `belongs_to :city`:

```ruby
class City < ApplicationRecord
end

class Person < ApplicationRecord
  belongs_to :city
end
```

```ruby
City.order(:name).map { |city| [city.name, city.id] }
# => [["Berlin", 3], ["Chicago", 1], ["Madrid", 2]]
```

Затем можно позволить пользователю выбирать город из базы данных с помощью следующей формы:

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city_id, City.order(:name).map { |city| [city.name, city.id] } %>
<% end %>
```

NOTE: При рендере поля для связи `belongs_to`, необходимо указать имя внешнего ключа (`city_id` в вышеприведенном примере), а не имя самой связи.

Однако, Rails предоставляет хелперы для генерации выборов из коллекции без необходимости явного перебора по ней. Эти хелперы определяют метки значения и текста каждого выбора, вызывая указанные методы на каждом объекте в коллекции.

### Хелпер `collection_select`

Чтобы создать список выбора, можно использовать [`collection_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_select):

```erb
<%= form.collection_select :city_id, City.order(:name), :id, :name %>
```

Выведет:

```html
<select name="person[city_id]" id="person_city_id">
  <option value="3">Berlin</option>
  <option value="1">Chicago</option>
  <option value="2">Madrid</option>
</select>
```

NOTE: С помощью `collection_select` мы определяем сначала метод значения (`:id` в вышеуказанном примере), а затем метод текстовой надписи (`:name` в вышеуказанном примере). Это отличается от порядка, используемого при указании вариантов для хелпера `select`, когда сначала идет текстовая надпись, а потом значение.

### Хелпер `collection_radio_buttons`

Чтобы создать набор радиокнопок, можно использовать [`collection_radio_buttons`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_radio_buttons):

```erb
<%= form.collection_radio_buttons :city_id, City.order(:name), :id, :name %>
```

Выведет:

```html
<input type="radio" name="person[city_id]" value="3" id="person_city_id_3">
<label for="person_city_id_3">Berlin</label>

<input type="radio" name="person[city_id]" value="1" id="person_city_id_1">
<label for="person_city_id_1">Chicago</label>

<input type="radio" name="person[city_id]" value="2" id="person_city_id_2">
<label for="person_city_id_2">Madrid</label>
```

### Хелпер `collection_check_boxes`

Чтобы создать набор чекбоксов — к примеру, чтобы поддерживать связь `has_and_belongs_to_many` — можно использовать [`collection_check_boxes`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_check_boxes):

```erb
<%= form.collection_check_boxes :interest_ids, Interest.order(:name), :id, :name %>
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

Частой задачей является загрузка некоторого файла, аватарки или файла CSV, содержащего информацию для обработки. Поля загрузки файлов могут быть отрендерены с помощью хелпера [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field).

```erb
<%= form_with model: @person do |form| %>
  <%= form.file_field :picture %>
<% end %>
```

Самое важное, это помнить при загрузке файла, что атрибут `enctype` формы *должен* быть установлен как "multipart/form-data". Это будет выполнено автоматически, если используете `file_field` внутри `form_with`. Также можно установить этот атрибут самому:

```erb
<%= form_with url: "/uploads", multipart: true do |form| %>
  <%= file_field_tag :picture %>
<% end %>
```

Отметьте, что в соответствии с соглашениями `form_with`, имена поля в вышеуказанных формах также будут отличаться. То есть, именем поля в первой форме будет `person[picture]` (доступное как `params[:person][:picture]`), а именем поля во второй форме будет просто `picture` (доступное как `params[:picture]`).

### Что имеем загруженным

Объект в хэше `params` - это экземпляр [`ActionDispatch::Http::UploadedFile`](https://api.rubyonrails.org/classes/ActionDispatch/Http/UploadedFile.html). Следующий образец кода сохраняет загруженное содержимое в `#{Rails.root}/public/uploads` под тем же именем, что и исходный файл.

```ruby
def upload
  uploaded_file = params[:picture]
  File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
    file.write(uploaded_file.read)
  end
end
```

Как только файл был загружен, появляется множество потенциальных задач, начиная от того, где хранить файлы (на диске, Amazon S3 и т.д.), как связать их с моделями, изменить размер файлов изображений и сгенерировать миниатюры. Для помощи с такими задачами разработан [Active Storage](/active_storage_overview).

Настройка Form Builder
----------------------

Объект, который передается от `form_with` и `fields_for`, - это экземпляр [`ActionView::Helpers::FormBuilder`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html). Form builder инкапсулирует представление элементов формы для отдельного объекта. Хотя, конечно, можно писать хелперы для своих форм обычным способом, так же как можно объявить подкласс `ActionView::Helpers::FormBuilder` и добавить хелперы туда. Например:

```erb
<%= form_with model: @person do |form| %>
  <%= text_field_with_label form, :first_name %>
<% end %>
```

может быть заменено этим

```erb
<%= form_with model: @person, builder: LabellingFormBuilder do |form| %>
  <%= form.text_field :first_name %>
<% end %>
```

через определение класса `LabellingFormBuilder` подобным образом:

```ruby
class LabellingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options={})
    label(attribute) + super
  end
end
```

Если это используется часто, можно определить хелпер `labeled_form_with` который автоматически определяет опцию `builder: LabellingFormBuilder`:

```ruby
def labeled_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
  options.merge! builder: LabellingFormBuilder
  form_with model: model, scope: scope, url: url, format: format, **options, &block
end
```

Form builder также определяет, что произойдет, если вы сделаете:

```erb
<%= render partial: f %>
```

Если `f` - это экземпляр `ActionView::Helpers::FormBuilder`, тогда это отрендерит партиал `form`, установив объект партиала как form builder. Если у form builder есть класс `LabellingFormBuilder`, тогда вместо него будет отрендерен партиал `labelling_form`.

(understanding-parameter-naming-conventions) Понимание соглашений по именованию параметров
------------------------------------------------------------------------------------------

Значения из форм могут быть на верхнем уровне хэша `params` или вложены в другой хэш. Например, в стандартном экшне `create` для модели Person, `params[:person]` будет обычно хэшем всех атрибутов для создания персоны. Хэш `params` может также содержать массивы, массивы хэшей и тому подобное.

В основном формы HTML не знают о каких-либо структурировании данных, все, что они генерируют - это пары имя-значение, где пары являются обычными строками. Массивы и хэши, которые можно увидеть в своем приложении, - это результат некоторых соглашений по именованию параметров, которые использует Rails.

### Базовые структуры

Две базовые структуры - это массивы и хэши. Хэши отражают синтаксис, используемый для доступа к значению в `params`. Например, если форма содержит

```html
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

хэш `params` будет содержать

```ruby
{'person' => {'name' => 'Henry'}}
```

и `params[:person][:name]` получит отправленное значение в контроллере.

Хэши могут быть вложены на столько уровней, сколько требуется, например:

```html
<input id="person_address_city" name="person[address][city]" type="text" value="New York"/>
```

вернет такой хэш `params`

```ruby
{'person' => {'address' => {'city' => 'New York'}}}
```

Обычно Rails игнорирует дублирующиеся имена параметра. Если имя параметра заканчивается пустым набором квадратных скобок `[]`, то они будут накоплены в массиве. Если нужно, чтобы пользователи могли оставить несколько телефонных номеров, можно поместить это в форму:

```html
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
```

Что приведет к тому, что `params[:person][:phone_number]` будет массивом, содержащим введенные телефонные номера.

### Комбинируем их

Можно смешивать и сочетать эти две концепции. Один из элементов хэша может быть массивом, как в предыдущем примере, или вы можете иметь массив хэшей. Например, форма может позволить вам создать любое количество адресов, повторяя следующий фрагмент кода

```html
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
```

Это приведет к тому, что `params[:person][:addresses]` будет массивом хэшей с ключами `line1`, `line2` и `city`.

Однако, имеется ограничение, в то время как хэши могут быть вложены произвольно, является допустимым только один уровень "массивности". Массивы обычно могут быть заменены хэшами; например, вместо массива объектов модели можно иметь хэш объектов модели с ключами, равными их id, индексу массива или любому другому параметру.

WARNING: Параметры массива не очень хорошо работают с хелпером `check_box`. В соответствии со спецификацией HTML, невыбранные чекбоксы не возвращают значения. Хелпер `check_box` обходит это, создавая вспомогательное скрытое поле с тем же именем. Если чекбокс не нажат, подтверждается только скрытое поле, а если он нажат, то они оба подтверждаются, но значение от чекбокса получает приоритет.

### Опция `:index` хелпера `fields_for`

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

Предположим, у кого-то есть два адреса с ID 23 и 45, вышеприведенная форма отрендерит что-то подобное:

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

Все поля ввода формы связаны с хэшем `"person"`, так как мы вызывали `fields_for` на построителе формы `person_form`. Также, указывая `index: address.id`, мы рендерим атрибут `name` каждого поля ввода города как `person[address][#{address.id}][city]` вместо `person[address][city]`. Таким образом можно определить, какие записи Address должны быть изменены при обработке хэша `params`.

Можно передать другие числа или строки с помощью опции `:index`. Можно даже передать `nil`, что создаст параметр массив.

Чтобы создать более замысловатые вложения, можно явно указать первую часть имени поля ввода (`person[address]` в предыдущем примере):

```erb
<%= fields_for 'person[address][primary]', address, index: address.id do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

создаст такие поля ввода:

```html
<input id="person_address_primary_23_city" name="person[address][primary][23][city]" type="text" value="Paris" />
```

Можно также передать опцию `:index` прямо в хелперы, такие как `text_field`, но обычно будет меньше повторов, если определить это на уровне form builder, а не для отдельных элементах управления input.

Говоря более широко, конечным именем поля ввода будет сцепление имени, переданного в `fields_for`/`form_with`, значения опции `:index` и имени атрибута.

Наконец, как ярлык, вместо указания ID для `:index` (например, `index: address.id`), можно добавить `"[]"` к заданному имени. Например:

```erb
<%= fields_for 'person[address][primary][]', address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

создаст абсолютно тот же результат, что и наш оригинальный пример.

Формы к внешним ресурсам
-------------------------

Хелперы форм Rails можно использовать и для создания форм для передачи данных внешнему ресурсу. Однако, иногда необходимо установить `authenticity_token` для ресурса; это можно осуществить, передав параметр `authenticity_token: 'your_external_token'` в опциях `form_with`:

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: 'external_token' do %>
  Form contents
<% end %>
```

Иногда при отправке данных внешнему ресурсу, такому как платежный шлюз, поля, которые можно использовать в форме, ограничены внешним API, и генерация `authenticity_token` нежелательна. Чтобы не посылать токен, просто передайте `false` в опцию `:authenticity_token`:

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: false do %>
  Form contents
<% end %>
```

Создание сложных форм
---------------------

Многие приложения выходят за рамки простых форм, редактирующих одиночные объекты. Например, при создании `Person` можно позволить пользователю (в той же самой форме) создать несколько записей адресов (домашний, рабочий и т.д.). При последующем редактировании этого person, пользователю должно быть доступно добавление, удаление или правка адреса, если это необходимо.

### Настройка модели

Active Record предоставляет поддержку на уровне модели с помощью метода [`accepts_nested_attributes_for`](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for):

```ruby
class Person < ApplicationRecord
  has_many :addresses, inverse_of: :person
  accepts_nested_attributes_for :addresses

end

class Address < ApplicationRecord
  belongs_to :person
end
```

Это создаст метод `addresses_attributes=` в `Person`, позволяющий создавать, обновлять и (опционально) уничтожать адреса.

### Вложенные формы

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

Когда связь принимает вложенные атрибуты, `fields_for` рендерит свой блок для каждого элемента связи. В частности, если у person нет адресов, он ничего не рендерит. Обычным паттерном для контроллера является построение одного или более пустых дочерних элементов, чтобы как минимум один набор полей был показан пользователю. Следующий пример покажет 2 набора полей адресов в форме нового person.

```ruby
def new
  @person = Person.new
  2.times { @person.addresses.build }
end
```

`fields_for` вкладывает form builder. Имя параметра будет таким, какое ожидает `accepts_nested_attributes_for`. К примеру, при создании пользователя с 2 адресами, отправленные параметры будут выглядеть так

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

Фактические значения ключей хэша `:addresses_attributes` не важны; однако, они должны быть числовыми строками и различаться для каждого адреса.

Если связанный объект уже сохранен, `fields_for` автоматически генерирует скрытое поле с `id` сохраненной записи. Это можно отключить, передав `include_id: false` в `fields_for`.

### Контроллер

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

### Удаление объектов

Можно позволить пользователям удалять связанные объекты, передав `allow_destroy: true` в `accepts_nested_attributes_for`

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
end
```

Если хэш атрибутов для объекта содержит ключ `_destroy` со значением, вычисляющимся как 'true' (например, 1, '1', true или 'true'), тогда объект будет уничтожен. Эта форма позволяет пользователям удалять адреса:

```html+erb
<%= form_with model: @person do |form| %>
  Addresses:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.check_box :_destroy %>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

Не забудьте обновить список разрешенных параметров в вашем контроллере, а также включить туда поле `_destroy`:

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
  accepts_nested_attributes_for :addresses, reject_if: lambda {|attributes| attributes['kind'].blank?}
end
```

Вместо этого для удобства можно передать символ `:all_blank`, который создаст proc, который отвергнет записи, когда все атрибуты пустые, за исключением любого значения для `_destroy`.

### Добавление полей на лету

Вместо того, чтобы рендерить несколько наборов полей раньше времени, можно добавить их только тогда, когда пользователь нажимает на кнопку 'Добавить новый адрес'. Rails не предоставляет какой-либо встроенной поддержки для этого. При генерации новых наборов полей следует убедиться, что ключ связанного массива уникальный - наиболее распространенным выбором является текущий JavaScript date (миллисекунды после [epoch](https://ru.wikipedia.org/wiki/Unix-время)).

Использование хелперов тега без построителя форм
------------------------------------------------

Если нужно отрендерить поля формы вне контекста построителя формы, Rails предоставляет хелперы тега для обычных элементов формы. Например, [`check_box_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-check_box_tag):

```erb
<%= check_box_tag "accept" %>
```

Выведет:

```html
<input type="checkbox" name="accept" id="accept" value="1" />
```

Обычно у этих хелперов те же имена, что и у их аналогов в построителе форм плюс суффикс `_tag`. Полный список смотрите в [документации `FormTagHelper` API](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).

Использование `form_tag` и `form_for`
-------------------------------------

До того, как `form_with` был представлен в Rails 5.1, его функционал был разделен между [`form_tag`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag) и [`form_for`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormHelper.html#method-i-form_for). Последние сейчас мягко устаревшие. Документация по их использованию находится в [старых версиях этого руководства](https://github.com/rusrails/rusrails/blob/5.1/source/form_helpers.md).
