Роутинг в Rails
================

Это руководство охватывает открытые для пользователя функции роутинга Rails.

После прочтения этого руководства вы узнаете:

* Как интерпретировать код в `config/routes.rb`
* Как создавать свои собственные маршруты, используя либо предпочтительный ресурсный стиль, либо метод `match`
* Как определять параметры маршрута, которые передаются в экшн контроллера
* Как автоматически создавать пути и URL, используя маршрутные хелперы
* О продвинутых техниках, таких как создание ограничений и монтирование точек назначения Rack

Цель роутера Rails
------------------

Роутер Rails распознает URL и направляет его в экшн контроллера или в приложение Rack. Он также может генерировать пути и URL, избегая необходимость жестко прописывать строки в ваших вьюхах.

### Соединение URL с кодом

Когда ваше приложение на Rails получает входящий запрос для:

```
GET /patients/17
```

оно опрашивает роутер на предмет соответствия экшну контроллера. Если первый соответствующий маршрут это:

```ruby
get '/patients/:id', to: 'patients#show'
```

то запрос будет направлен в контроллер `patients` в экшн `show` с `{ id: '17' }` в `params`.

### Создание URL из кода

Также можно генерировать пути и URL. Если вышеуказанный маршрут модифицировать на:

```ruby
get '/patients/:id', to: 'patients#show', as: 'patient'
```

и ваше приложение содержит код в контроллере:

```ruby
@patient = Patient.find(params[:id])
```

и такой в соответствующей вьюхе:

```erb
<%= link_to 'Patient Record', patient_path(@patient) %>
```

тогда роутер сгенерирует путь `/patients/17`. Это увеличит устойчивость вашей вьюхи и упростит код для понимания. Отметьте, что id не нужно указывать в маршрутном хелпере.

### Настройка маршрутизатора Rails

Маршруты для приложения или engine располагаются в файле `config/routes.rb` и обычно выглядят так:

```ruby
Rails.application.routes.draw do
  resources :brands, only: [:index, :show] do
    resources :products, only: [:index, :show]
  end

  resource :basket, only: [:show, :update, :destroy]

  resolve("Basket") { route_for(:basket) }
end
```

Поскольку это обычный исходный файл Ruby, можно использовать все его особенности, чтобы помочь определять маршруты, но необходимо быть осторожным с именами переменных, так как они могут конфликтовать с методами DSL маршрутизатора.

NOTE: Блок `Rails.application.routes.draw do ... end`, который оборачивает определения маршрутов, требует создания области видимости для DSL маршрутизатора и не должен быть удален.

Ресурсный роутинг
-----------------

Ресурсный роутинг позволяет быстро объявлять все общие маршруты для заданного ресурсного контроллера. Вместо объявления отдельных маршрутов для экшнов `index`, `show`, `new`, `edit`, `create`, `update` и `destroy`, ресурсный маршрут объявляет их одной строчкой кода.

### Ресурсы в вебе

Браузеры запрашивают страницы от Rails, выполняя запрос по URL, используя определенный метод HTTP, такой как `GET`, `POST`, `PATCH`, `PUT` и `DELETE`. Каждый метод - это запрос на выполнение операции с ресурсом. Ресурсный маршрут соединяет несколько родственных запросов с экшнами в одном контроллере.

Когда приложение на Rails получает входящий запрос для:

```
DELETE /photos/17
```

оно просит роутер соединить его с экшном контроллера. Если первый соответствующий маршрут такой:

```ruby
resources :photos
```

Rails будет направлять этот запрос в экшн `destroy` контроллера `photos` с `{ id: '17' }` в `params`.

### CRUD, методы и экшны

В Rails ресурсный маршрут предоставляет сопоставление между методами HTTP и URL к экшнам контроллера. По соглашению, каждый экшн также соединяется с определенной операцией CRUD в базе данных. Одна запись в файле роутинга, такая как:

```ruby
resources :photos
```

создает семь различных маршрутов в приложении, все сопоставления с контроллером `Photos`:

| Метод HTTP | Путь             | Контроллер#Экшн | Использование                                  |
| ---------- | ---------------- | --------------  | ---------------------------------------------- |
| GET        | /photos          | photos#index    | отображает список всех фото                    |
| GET        | /photos/new      | photos#new      | возвращает форму HTML для создания нового фото |
| POST       | /photos          | photos#create   | создает новое фото                             |
| GET        | /photos/:id      | photos#show     | отображает определенное фото                   |
| GET        | /photos/:id/edit | photos#edit     | возвращает форму HTML для редактирования фото  |
| PATCH/PUT  | /photos/:id      | photos#update   | обновляет определенное фото                    |
| DELETE     | /photos/:id      | photos#destroy  | удаляет определенное фото                      |

NOTE: Поскольку роутер использует как метод HTTP, так и URL, для сопоставления с входящими запросами, четыре URL соединяют с семью различными экшнами.

NOTE: Маршруты Rails сравниваются в том порядке, в котором они определены, поэтому, если имеется `resources :photos` до `get 'photos/poll'` маршрут для экшна `show` в строчке `resources` совпадет до строчки `get`. Чтобы это исправить, переместите строчку `get` **выше** строчки `resources`, чтобы она сравнивалась первой.

### Путь и хелперы URL

Создание ресурсного маршрута также сделает доступными множество хелперов в контроллере вашего приложения. В случае с `resources :photos`:

* `photos_path` возвращает `/photos`
* `new_photo_path` возвращает `/photos/new`
* `edit_photo_path(:id)` возвращает `/photos/:id/edit` (например, `edit_photo_path(10)` возвращает `/photos/10/edit`)
* `photo_path(:id)` возвращает `/photos/:id` (например, `photo_path(10)` возвращает `/photos/10`)

Каждый из этих хелперов имеет соответствующий хелпер `_url` (такой как `photos_url`), который возвращает тот же путь с добавленными текущими хостом, портом и префиксом пути.

### Определение нескольких ресурсов одновременно

Если необходимо создать маршруты для более чем одного ресурса, можете сократить ввод, определив их в одном вызове `resources`:

```ruby
resources :photos, :books, :videos
```

Это приведет к такому же результату, как и:

```ruby
resources :photos
resources :books
resources :videos
```

### Одиночные ресурсы

Иногда имеется ресурс, который клиенты всегда просматривают без ссылки на ID. Обычный пример, `/profile` всегда показывает профиль текущего зарегистрированного пользователя. Для этого можно использовать одиночный ресурс, чтобы связать `/profile` (а не `/profile/:id`) с экшном `show`:

```ruby
get 'profile', to: 'users#show'
```

Передавая `String` в `to:` ожидается следующий формат - `controller#action`. Когда используется `Symbol`, опция `to:` должна быть заменена на `action:`. Когда используется `String` без `#`, опция `to:` должна быть заменена на `controller:`:

```ruby
get 'profile', action: :show, controller: 'users'
```

Этот ресурсный маршрут:

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

создаст шесть различных маршрутов в приложении, все сопоставления с контроллером `Geocoders`:

| Метод HTTP | Путь           | Контроллер#Экшн   | Использование                                       |
| ---------- | -------------- | ----------------- | --------------------------------------------------- |
| GET        | /geocoder/new  | geocoders#new     | возвращает форму HTML для создания нового геокодера |
| POST       | /geocoder      | geocoders#create  | создает новый геокодер                              |
| GET        | /geocoder      | geocoders#show    | отображает один и только один ресурс геокодера      |
| GET        | /geocoder/edit | geocoders#edit    | возвращает форму HTML для редактирования геокодера  |
| PATCH/PUT  | /geocoder      | geocoders#update  | обновляет один и только один ресурс геокодера       |
| DELETE     | /geocoder      | geocoders#destroy | удаляет ресурс геокодера                            |

NOTE: Поскольку вы можете захотеть использовать один и тот же контроллер и для одиночного маршрута (`/account`), и для множественного маршрута (`/accounts/45`), одиночные ресурсы ведут на множественные контроллеры. По этой причине, например, `resource :photo` и `resources :photos` создадут и одиночные, и множественные маршруты, привязанные к одному и тому же контроллеру (`PhotosController`).

Одиночный ресурсный маршрут генерирует эти хелперы:

* `new_geocoder_path` возвращает `/geocoder/new`
* `edit_geocoder_path` возвращает `/geocoder/edit`
* `geocoder_path` возвращает `/geocoder`

Как и в случае с множественными ресурсами, те же хелперы, оканчивающиеся на `_url` также включают хост, порт и префикс пути.

### Пространство имен контроллера и роутинг

Возможно, вы захотите организовать группы контроллеров в пространстве имен. Чаще всего группируют административные контроллеры в пространство имен `Admin::`. Следует поместить эти контроллеры в директорию `app/controllers/admin` и затем можно сгруппировать их вместе в роутере:

```ruby
namespace :admin do
  resources :articles, :comments
end
```

Это создаст ряд маршрутов для каждого контроллера `articles` и `comments`. Для `Admin::ArticlesController`, Rails создаст:

| Метод HTTP | Путь                     | Контроллер#Экшн        | Именованный хелпер           |
| ---------- | ------------------------ | ---------------------- | ---------------------------- |
| GET        | /admin/articles          | admin/articles#index   | admin_articles_path          |
| GET        | /admin/articles/new      | admin/articles#new     | new_admin_article_path       |
| POST       | /admin/articles          | admin/articles#create  | admin_articles_path          |
| GET        | /admin/articles/:id      | admin/articles#show    | admin_article_path(:id)      |
| GET        | /admin/articles/:id/edit | admin/articles#edit    | edit_admin_article_path(:id) |
| PATCH/PUT  | /admin/articles/:id      | admin/articles#update  | admin_article_path(:id)      |
| DELETE     | /admin/articles/:id      | admin/articles#destroy | admin_article_path(:id)      |

Если хотите маршрут `/articles` (без префикса `/admin`) к `Admin::ArticlesController`, можете использовать:

```ruby
scope module: 'admin' do
  resources :articles, :comments
end
```

или для отдельного случая:

```ruby
resources :articles, module: 'admin'
```

Если хотите маршрут `/admin/articles` к `ArticlesController` (без префикса модуля `Admin::`), можно использовать:

```ruby
scope '/admin' do
  resources :articles, :comments
end
```

или для отдельного случая:

```ruby
resources :articles, path: '/admin/articles'
```

В каждом из этих случаев, именованные маршруты остаются теми же, что и без использования `scope`. В последнем случае, следующие пути соединят с `ArticlesController`:

| Метод HTTP | Путь                     | Контроллер#Экшн      | Именованный хелпер     |
| ---------- | ------------------------ | -------------------- | ---------------------- |
| GET        | /admin/articles          | articles#index       | articles_path          |
| GET        | /admin/articles/new      | articles#new         | new_article_path       |
| POST       | /admin/articles          | articles#create      | articles_path          |
| GET        | /admin/articles/:id      | articles#show        | article_path(:id)      |
| GET        | /admin/articles/:id/edit | articles#edit        | edit_article_path(:id) |
| PATCH/PUT  | /admin/articles/:id      | articles#update      | article_path(:id)      |
| DELETE     | /admin/articles/:id      | articles#destroy     | article_path(:id)      |

TIP: _Если хотите использовать другое пространство имен контроллера в блоке `namespace`, можно указать абсолютный путь контроллера, т.е: `get '/foo' => '/foo#index'`._

### Вложенные ресурсы

Нормально иметь ресурсы, которые логически подчинены другим ресурсам. Например, предположим ваше приложение включает эти модели:

```ruby
class Magazine < ApplicationRecord
  has_many :ads
end

class Ad < ApplicationRecord
  belongs_to :magazine
end
```

Вложенные маршруты позволяют захватить эти отношения в вашем роутинге. В этом случае можете включить такое объявление маршрута:

```ruby
resources :magazines do
  resources :ads
end
```

В дополнение к маршрутам для magazines, это объявление также создаст маршруты для ads в `AdsController`. URL с ad требует magazine:

| Метод HTTP | Путь                                 | Контроллер#Экшн | Использование                                                                     |
| ---------- | ------------------------------------ | --------------- | ----------------------------------------------------------------------------------|
| GET        | /magazines/:magazine_id/ads          | ads#index       | отображает список всех ads для определенного magazine                             |
| GET        | /magazines/:magazine_id/ads/new      | ads#new         | возвращает форму HTML для создания новой ad, принадлежащей определенному magazine |
| POST       | /magazines/:magazine_id/ads          | ads#create      | создает новую ad, принадлежащую указанному magazine                               |
| GET        | /magazines/:magazine_id/ads/:id      | ads#show        | отражает определенную ad, принадлежащую определенному magazine                    |
| GET        | /magazines/:magazine_id/ads/:id/edit | ads#edit        | возвращает форму HTML для редактирования ad, принадлежащей определенному magazine |
| PATCH/PUT  | /magazines/:magazine_id/ads/:id      | ads#update      | обновляет определенную ad, принадлежащую определенному magazine                   |
| DELETE     | /magazines/:magazine_id/ads/:id      | ads#destroy     | удаляет определенную ad, принадлежащую определенному magazine                     |

Также будут созданы маршрутные хелперы, такие как `magazine_ads_url` и `edit_magazine_ad_path`. Эти хелперы принимают экземпляр Magazine как первый параметр (`magazine_ads_url(@magazine)`).

#### Ограничения для вложения

Вы можете вкладывать ресурсы в другие вложенные ресурсы, если хотите. Например:

```ruby
resources :publishers do
  resources :magazines do
    resources :photos
  end
end
```

Глубоко вложенные ресурсы быстро становятся громоздкими. В этом случае, например, приложение будет распознавать пути, такие как:

```
/publishers/1/magazines/2/photos/3
```

Соответствующий маршрутный хелпер будет `publisher_magazine_photo_url`, требующий определения объектов на всех трех уровнях. Действительно, эта ситуация достаточно запутана, так что в [статье](http://weblog.jamisbuck.org/2007/2/5/nesting-resources) Jamis Buck предлагает правило хорошей разработки на Rails:

TIP: _Ресурсы никогда не должны быть вложены глубже, чем на 1 уровень._

#### Мелкое вложение

Один из способов избежать глубокой вложенности (как рекомендовано выше) состоит в том, чтобы генерировать экшны коллекции в области видимости родителя, получая представление об иерархии, но не вкладывать экшны элементов. Другими словами, создавать маршруты с минимальным количеством информации для однозначной идентификации ресурса, например так:

```ruby
resources :articles do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

Эта идея балансирует на грани между наглядностью маршрутов и глубоким вложением. Существует сокращенный синтаксис для получения подобного с помощью опции `:shallow`:

```ruby
resources :articles do
  resources :comments, shallow: true
end
```

Это сгенерирует те же самые маршруты из первого примера. Также можно определить опцию `:shallow` в родительском ресурсе, в этом случае все вложенные ресурсы будут мелкие:

```ruby
resources :articles, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```

Метод `shallow` в DSL создает область видимости, в котором каждое вложение мелкое. Это генерирует те же самые маршруты из предыдущего примера:

```ruby
shallow do
  resources :articles do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```

Также существуют две опции для `scope` для настройки мелких маршрутов. `:shallow_path` добавляет к путям элемента префикс с указанным параметром:

```ruby
scope shallow_path: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

Для ресурса комментариев будут сгенерированы следующие маршруты:

| Метод HTTP | Путь                                         | Контроллер#Экшн   | Именованный хелпер       |
| ---------- | -------------------------------------------- | ----------------- | ------------------------ |
| GET        | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST       | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET        | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET        | /sekret/comments/:id/edit(.:format)          | comments#edit     | edit_comment_path        |
| GET        | /sekret/comments/:id(.:format)               | comments#show     | comment_path             |
| PATCH/PUT  | /sekret/comments/:id(.:format)               | comments#update   | comment_path             |
| DELETE     | /sekret/comments/:id(.:format)               | comments#destroy  | comment_path             |

Опция `:shallow_prefix` добавляет указанный параметр к именованным хелперам:

```ruby
scope shallow_prefix: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

Для ресурса комментариев будут сгенерированы следующие маршруты:

| Метод HTTP | Путь                                         | Контроллер#Экшн   | Именованный хелпер          |
| ---------- | -------------------------------------------- | ----------------- | --------------------------- |
| GET        | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path       |
| POST       | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path       |
| GET        | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path    |
| GET        | /comments/:id/edit(.:format)                 | comments#edit     | edit_sekret_comment_path    |
| GET        | /comments/:id(.:format)                      | comments#show     | sekret_comment_path         |
| PATCH/PUT  | /comments/:id(.:format)                      | comments#update   | sekret_comment_path         |
| DELETE     | /comments/:id(.:format)                      | comments#destroy  | sekret_comment_path         |

### Концерны маршрутов

Концерны маршрутов позволяют объявлять общие маршруты, которые затем могут быть повторно использованы внутри других ресурсов и маршрутов. Чтобы определить концерн:

```ruby
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

Эти концерны могут быть использованы в ресурсах, чтобы избежать дублирования кода и разделить поведение между несколькими маршрутами:

```ruby
resources :messages, concerns: :commentable

resources :articles, concerns: [:commentable, :image_attachable]
```

Вышеуказанное эквивалентно:

```ruby
resources :messages do
  resources :comments
end

resources :articles do
  resources :comments
  resources :images, only: :index
end
```

Также их можно использовать в любом месте внутри маршрутов, например, в вызове `scope` или `namespace`:

```ruby
namespace :articles do
  concerns :commentable
end
```

### Создание путей и URL из объектов

В дополнение к использованию маршрутных хелперов, Rails может также создавать пути и URL из массива параметров. Например, предположим, у вас есть этот набор маршрутов:

```ruby
resources :magazines do
  resources :ads
end
```

При использовании `magazine_ad_path`, можно передать экземпляры `Magazine` и `Ad` вместо числовых ID:

```erb
<%= link_to 'Ad details', magazine_ad_path(@magazine, @ad) %>
```

Можно также использовать `url_for` с набором объектов, и Rails автоматически определит, какой маршрут вам нужен:

```erb
<%= link_to 'Ad details', url_for([@magazine, @ad]) %>
```

В этом случае Rails увидит, что `@magazine` это `Magazine` и `@ad` это `Ad`, и поэтому использует хелпер `magazine_ad_path`. В хелперах, таких как `link_to`, можно определить лишь объект вместо полного вызова `url_for`:

```erb
<%= link_to 'Ad details', [@magazine, @ad] %>
```

Если хотите ссылку только на magazine:

```erb
<%= link_to 'Magazine details', @magazine %>
```

Для других экшнов следует всего лишь вставить имя экшна как первый элемент массива:

```erb
<%= link_to 'Edit Ad', [:edit, @magazine, @ad] %>
```

Это позволит рассматривать экземпляры модели как URL, что является ключевым преимуществом ресурсного стиля.

### Определение дополнительных экшнов RESTful

Вы не ограничены семью маршрутами, которые создает роутинг RESTful по умолчанию. Если хотите, можете добавить дополнительные маршруты, применяющиеся к коллекции или отдельным элементам коллекции.

#### Добавление маршрутов к элементам

Для добавления маршрута к элементу, добавьте блок `member` в блок ресурса:

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```

Это распознает `/photos/1/preview` с GET и направит в экшн `preview` контроллера `PhotosController` со значением id ресурса, переданного в `params[:id]`. Это также создаст хелперы `photo_preview_url` и `photo_preview_path`.

В блоке маршрутов элемента каждое имя маршрута определяет метод HTTP,
с которым он будет связан. Тут можно использовать `get`, `patch`, `put`, `post` или `delete`.
Если у вас нет нескольких маршрутов к `member`, также можно передать `:on` к маршруту, избавившись от блока:

```ruby
resources :photos do
  get 'preview', on: :member
end
```

Можно опустить опцию `:on`, это создаст такой же маршрут для элемента, за исключением того, что значение id ресурса будет доступно в `params[:photo_id]` вместо `params[:id]`.

#### Добавление маршрутов к коллекции

Чтобы добавить маршрут к коллекции:

```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```

Это позволит Rails распознавать пути, такие как `/photos/search` с GET и направить в экшн `search` контроллера `PhotosController`. Это также создаст маршрутные хелперы `search_photos_url` и `search_photos_path`.

Как и с маршрутами к элементу, можно передать `:on` к маршруту:

```ruby
resources :photos do
  get 'search', on: :collection
end
```

#### Добавление маршрутов для дополнительных экшнов new

Чтобы добавить альтернативный экшн new, используйте сокращенный вариант `:on`:

```ruby
resources :comments do
  get 'preview', on: :new
end
```

Это позволит Rails распознавать пути, такие как `/comments/new/preview` с GET, и направлять их в экшн `preview` в `CommentsController`. Он также создаст маршрутные хелперы `preview_new_comment_url` и `preview_new_comment_path`.

TIP: Если вдруг вы захотели добавить много дополнительных экшнов в ресурсный маршрут, нужно остановиться и спросить себя, может быть, от вас утаилось присутствие другого ресурса.

Нересурсные маршруты
--------------------

В дополнению к ресурсному роутингу, Rails поддерживает роутинг произвольных URL к экшнам. Тут не будет групп маршрутов, генерируемых автоматически ресурсным роутингом. Вместо этого вы должны настроить каждый маршрут отдельно в вашем приложении.

Хотя обычно следует пользоваться ресурсным роутингом, все еще есть много мест, где более подходит простой роутинг. Нет необходимости пытаться заворачивать каждый кусочек своего приложения в ресурсные рамки, если это менее удобно.

В частности, простой роутинг облегчает привязку унаследованных URL к новым экшнам Rails.

### Необязательные параметры

При настройке обычного маршрута вы предоставляете ряд символов, которые Rails связывает с частями входящего запроса HTTP. Например, рассмотрим следующий маршрут:

```ruby
get 'photos(/:id)', to: 'photos#display'
```

Если входящий запрос `/photos/1` обрабатывается этим маршрутом (так как он не соответствует любому предыдущему маршруту до этого), то результатом будет вызов экшна `display` в `PhotosController`, и результирующий параметр `"1"` будет доступен как `params[:id]`. Этот маршрут также свяжет входящий запрос `/photos` с `PhotosController#display`, поскольку `:id` — опциональный параметр, обозначенный скобками.

### (dynamic-segments) Динамические сегменты

Можете настроить сколько угодно динамических сегментов в обычном маршруте. Любой сегмент будет доступен для соответствующего экшна как часть хэша params. Таким образом, если настроите такой маршрут:

```ruby
get 'photos/:id/:user_id', to: 'photos#show'
```

Входящий путь `/photos/1/2` будет направлен на экшн `show` в `PhotosController`. `params[:id]` будет установлен как "1", и `params[:user_id]` будет установлен как "2".

TIP: По умолчанию динамические сегменты не принимают точки - потому что точка используется как разделитель для формата маршрутов. Если в динамическом сегменте необходимо использовать точку, добавьте ограничение, переопределяющее это – к примеру, `id: /[^\/]+/` позволяет все, кроме слэша.

### Статичные сегменты

Можете определить статичные сегменты при создании маршрута, не начинающиеся с двоеточия в фрагменте:

```ruby
get 'photos/:id/with_user/:user_id', to: 'photos#show'
```

Этот маршрут соответствует путям, таким как `/photos/1/with_user/2`. В этом случае `params` будет `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### Параметры строки запроса

`params` также включает любые параметры из строки запроса. Например, с таким маршрутом:

```ruby
get 'photos/:id', to: 'photos#show'
```

Входящий путь `/photos/1?user_id=2` будет направлен на экшн `show` контроллера `Photos`. `params` будет `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### Определение значений по умолчанию

Можно определить значения по умолчанию в маршруте, предоставив хэш для опции `:defaults`. Это также относится к параметрам, которые не определены как динамические сегменты. Например:

```ruby
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

Rails направит `photos/12` в экшн `show` `PhotosController`, и установит `params[:format]` как `"jpg"`.

Вы также можете использовать `defaults` в формате блока, чтобы определить значения по умолчанию для нескольких элементов:

```ruby
defaults format: :json do
  resources :photos
end
```

NOTE: Невозможно переопределить значения по умолчанию с помощью параметров строки запроса - по причине безопасности. Единственные значения по умолчанию, которые могут быть переопределены - это динамические сегменты, с помощью подстановки в путь URL.

### Именование маршрутов

Можно определить имя для любого маршрута, используя опцию `:as`:

```ruby
get 'exit', to: 'sessions#destroy', as: :logout
```

Это создаст `logout_path` и `logout_url` как именованные хелперы в вашем приложении. Вызов `logout_path` вернет `/exit`

Также это можно использовать для переопределения маршрутных методов, определенных ресурсами, следующим образом:

```ruby
get ':username', to: 'users#show', as: :user
```

Что определит метод `user_path`, который будет доступен в контроллерах, хелперах и вьюхах, и будет вести на маршрут, такой как `/bob`. В экшне `show` из `UsersController`, `params[:username]` будет содержать имя пользователя. Измените `:username` в определении маршрута, если не хотите, чтобы имя параметра было `:username`.

### Ограничения метода HTTP

В основном следует использовать методы `get`, `post`, `put`, `patch` и `delete` для ограничения маршрута определенным методом. Можно использовать метод `match` с опцией `:via` для соответствия нескольким методам сразу:

```ruby
match 'photos', to: 'photos#show', via: [:get, :post]
```

Также можно установить соответствие всем методам для определенного маршрута, используя `:via: :all`:

```ruby
match 'photos', to: 'photos#show', via: :all
```

NOTE: Роутинг запросов `GET` и `POST` одновременно в один экшн небезопасен. В основном, следует избегать роутинг всех методов в экшн, если нет веской причины делать так.

NOTE: `GET` в Rails не проверяет токен CSRF. Никогда не пишите в базу данных из `GET` запросов, подробнее о контрмерах CSRF смотрите в руководстве [Безопасность приложений на Rails](/ruby-on-rails-security-guide#csrf-countermeasures).

### Ограничения сегмента

Можно использовать опцию `:constraints` для соблюдения формата динамического сегмента:

```ruby
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

Этот маршрут соответствует путям, таким как `/photos/A12345`, но не `/photos/893`. Можно выразить тот же маршрут более кратко:

```ruby
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`:constraints` принимает регулярное выражение c тем ограничением, что якоря regexp не могут использоваться. Например, следующий маршрут не работает:

```ruby
get '/:id', to: 'articles#show', constraints: {id: /^\d/}
```

Однако отметьте, что нет необходимости использовать якоря, поскольку все маршруты заякорены изначально.

Например, следующие маршруты приведут к `articles` со значениями `to_param` наподобие `1-hello-world`, которые всегда начинаются с цифры, и к `users` со значениями `to_param` наподобие `david`, которые никогда не начинаются с цифры, чтобы можно было использовать общее корневое пространство имен:

```ruby
get '/:id', to: 'articles#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```

### Ограничения, основанные на запросе

Также можно ограничить маршрут, основываясь на любом методе в [объекте Request](/action-controller-overview#the-request-and-response-objects), который возвращает `String`.

Ограничение, основанное на запросе, определяется так же, как и сегментное ограничение:

```ruby
get 'photos', to: 'photos#index', constraints: { subdomain: 'admin' }
```

Также можно определить ограничения в форме блока:

```ruby
namespace :admin do
  constraints subdomain: 'admin' do
    resources :photos
  end
end
```

NOTE: Ограничения запроса работают, вызывая метод на [объекте Request](/action-controller-overview#the-request-and-response-objects) с тем же именем, что и ключ хэша, а затем сравнивают возвращенное значение со значением хэша. Следовательно, значения ограничений должны соответствовать возвращаемому типу соответствующего метода объекта Request. Например: `constraints: { subdomain: 'api' }` будет соответствовать поддомену `api`, как и ожидалось, однако, использование символа `constraints: { subdomain: :api }` не будет, так как `request.subdomain` возвращает `'api'` как строку.

NOTE: Имеется исключения для ограничения `format`: так как это метод на объекте Request, это также неявный опциональный параметр для каждого пути. Ограничения сегмента имеют приоритет, и ограничение `format` применяется как есть, даже когда передано в хэше. Например, `get 'foo', constraints: { format: 'json' }` будет соответствовать `GET  /foo`, так как формат опциональный по умолчанию. Однако, [используя lambda](#advanced-constraints), как в `get 'foo', constraints: lambda { |req| req.format == :json }`, маршрут будет соответствовать только явным запросам JSON.

### (advanced-constraints) Продвинутые ограничения

Если имеется более продвинутое ограничение, можете предоставить объект, отвечающий на `matches?`, который будет использовать Rails. Скажем, вы хотите направить всех пользователей через черный список в `BlacklistController`. Можно сделать так:

```ruby
class BlacklistConstraint
  def initialize
    @ips = Blacklist.retrieve_ips
  end

  def matches?(request)
    @ips.include?(request.remote_ip)
  end
end

Rails.application.routes.draw do
  get '*path', to: 'blacklist#index',
    constraints: BlacklistConstraint.new
end
```

Ограничения также можно определить как лямбду:

```ruby
Rails.application.routes.draw do
  get '*path', to: 'blacklist#index',
    constraints: lambda { |request| Blacklist.retrieve_ips.include?(request.remote_ip) }
end
```

И метод `matches?`, и лямбда получают объект `request` в качестве аргумента.

### Подстановка маршрутов и подстановочные сегменты

Подстановка маршрутов - это способ указать, что определенные параметры должны соответствовать остальным частям маршрута. Например:

```ruby
get 'photos/*other', to: 'photos#unknown'
```

Этот маршрут будет соответствовать `photos/12` или `/photos/long/path/to/12`, установив `params[:other]` как `"12"`, или `"long/path/to/12"`. Фрагменты, начинающиеся со звездочки, называются "подстановочные сегменты" ("wildcard segments").

Подстановочные сегменты могут быть где угодно в маршруте. Например:

```ruby
get 'books/*section/:title', to: 'books#show'
```

будет соответствовать `books/some/section/last-words-a-memoir` с `params[:section]` равным `'some/section'`, и `params[:title]` равным `'last-words-a-memoir'`.

На самом деле технически маршрут может иметь более одного динамического сегмента, matcher назначает параметры интуитивным образом. Для примера:

```ruby
get '*a/foo/*b', to: 'test#index'
```

будет соответствовать `zoo/woo/foo/bar/baz` с `params[:a]` равным `'zoo/woo'`, и `params[:b]` равным `'bar/baz'`.

NOTE: Запросив `'/foo/bar.json'`, ваш `params[:pages]` будет равен `'foo/bar'` с форматом запроса JSON. Если вам нужно вернуть старое поведение 3.0.x, можете предоставить `format: false` вот так:

```ruby
get '*pages', to: 'pages#show', format: false
```

NOTE: Если хотите сделать сегмент формата обязательным, чтобы его нельзя было опустить, укажите `format: true` подобным образом:

```ruby
get '*pages', to: 'pages#show', format: true
```

### Перенаправление

Можно перенаправить любой путь на другой путь, используя хелпер `redirect` в вашем роутере:

```ruby
get '/stories', to: redirect('/articles')
```

Также можно повторно использовать динамические сегменты для соответствия пути, на который перенаправляем:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}')
```

Также можно предоставить блок для перенаправления, который получает символизированные параметры пути и объект request:

```ruby
get '/stories/:name', to: redirect { |path_params, req| "/articles/#{path_params[:name].pluralize}" }
get '/stories', to: redirect { |path_params, req| "/articles/#{req.subdomain}" }
```

Пожалуйста, отметьте, что перенаправлением по умолчанию является 301 "Moved Permanently". Учтите, что некоторые браузеры или прокси серверы закэшируют этот тип перенаправления, сделав старые страницы недоступными. Чтобы изменить статус отклика, можно использовать опцию `:status`:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}', status: 302)
```

Во всех этих случаях, если не предоставить предшествующий хост (`http://www.example.com`), Rails возьмет эти детали из текущего запроса.

### Роутинг к приложениям Rack

Вместо строки, подобной `'articles#index'`, соответствующей экшну `index` в `ArticlesController`, можно определить любое [приложение Rack](/rails-on-rack) как конечную точку совпадения.

```ruby
match '/application.js', to: MyRackApp, via: :all
```

Пока `MyRackApp` отвечает на `call` и возвращает `[status, headers, body]`, роутер не будет различать приложение Rack и экшн. Здесь подходит использование `via: :all`, если вы хотите позволить своему приложению Rack обрабатывать все методы так, как оно посчитает нужным.

NOTE: Для любопытства, `'articles#index'` фактически расширяется до `ArticlesController.action(:index)`, который возвращает валидное приложение Rack.

Если вы указываете приложение Rack как конечную точку совпадения, помните что маршрут будет неизменным в принимающем приложении. Со следующим маршрутом ваше приложение Rack будет ожидать маршрут `/admin`:

```ruby
match '/admin', to: AdminApp, via: :all
```

Если вы предпочитаете, чтобы ваше приложение Rack получало запросы на корневой путь, используйте вместо этого `mount`:

```ruby
mount AdminApp, at: '/admin'
```

### Использование `root`

Можно определить, с чем Rails должен связать `'/'` с помощью метода `root`:

```ruby
root to: 'pages#main'
root 'pages#main' # то же самое в краткой форме
```

Следует поместить маршрут `root` в начало файла, поскольку это наиболее популярный маршрут и должен быть проверен первым.

NOTE: Маршрут `root` связывает с экшном только запросы `GET`.

`root` также можно использовать внутри пространств имен и областей видимости. Например:

```ruby
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```

### Маршруты с символами Unicode

Маршруты с символами unicode можно определять явно. Например:

```ruby
get 'こんにちは', to: 'welcome#index'
```

### Прямые маршруты

Можно создавать собственные хелперы URL напрямую. Например:

```ruby
direct :homepage do
  "http://www.rubyonrails.org"
end

# >> homepage_url
# => "http://www.rubyonrails.org"
```

Возвращаемое значение блока должно быть валидным аргументом для метода `url_for`. Таким образом, можно передать валидный строковый URL, хэш, массив, экземпляр Active Model или класс Active Model.

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```

### Использование `resolve`

Метод `resolve` позволяет настраивать полиморфное сопоставление моделей. Например:

``` ruby
resource :basket

resolve("Basket") { [:basket] }
```

``` erb
<%= form_for @basket do |form| %>
  <!-- basket form -->
<% end %>
```

Это сгенерирует URL в единственном числе `/basket` вместо обычного `/baskets/:id`.

Настройка ресурсных маршрутов
-----------------------------

Хотя дефолтные маршруты и хелперы, сгенерированные `resources :articles`, как правило, нормально работают, возможно, может понадобиться некоторым образом их настроить. Rails позволяет настроить практически любую часть ресурсных хелперов.

### Определение используемого контроллера

Опция `:controller` позволяет явно определить контроллер, используемый ресурсом. Например:

```ruby
resources :photos, controller: 'images'
```

распознает входящие пути, начинающиеся с `/photos`, но смаршрутизирует к контроллеру `Images`:

| Метод HTTP | Путь             | Контроллер#Экшн   | Именованный хелпер   |
| ---------  | ---------------- | ----------------- | -------------------- |
| GET        | /photos          | images#index      | photos_path          |
| GET        | /photos/new      | images#new        | new_photo_path       |
| POST       | /photos          | images#create     | photos_path          |
| GET        | /photos/:id      | images#show       | photo_path(:id)      |
| GET        | /photos/:id/edit | images#edit       | edit_photo_path(:id) |
| PATCH/PUT  | /photos/:id      | images#update     | photo_path(:id)      |
| DELETE     | /photos/:id      | images#destroy    | photo_path(:id)      |

NOTE: Используйте `photos_path`, `new_photo_path` и т.д. для генерации путей для этого ресурса.

Для контроллеров в пространстве имен можно использовать нотацию директории. Например:

```ruby
resources :user_permissions, controller: 'admin/user_permissions'
```

Это будет смаршрутизировано на контроллер `Admin::UserPermissions`.

NOTE: Поддерживается только нотация директории. Определение контроллера с помощью нотации константы Ruby (т.е. `controller: 'Admin::UserPermissions'`) может привести к маршрутным проблемам, и в итоге к предупреждению.

### Определение ограничений

Можно использовать опцию `:constraints` для определения требуемого формата на неявном `id`. Например:

```ruby
resources :photos, constraints: { id: /[A-Z][A-Z][0-9]+/ }
```

Это объявление ограничивает параметр `:id` соответствием предоставленному регулярному выражению. Итак, в этом случае роутер больше не будет сопоставлять `/photos/1` этому маршруту. Вместо этого он будет соответствовать `/photos/RR27`.

Можно определить одиночное ограничение, применив его к ряду маршрутов, используя блочную форму:

```ruby
constraints(id: /[A-Z][A-Z][0-9]+/) do
  resources :photos
  resources :accounts
end
```

NOTE: Конечно, можно использовать более продвинутые ограничения, доступные в нересурсных маршрутах, в этом контексте.

TIP: По умолчанию параметр `:id` не принимает точки - так как точка используется как разделитель для отформатированного маршрута. Если необходимо использовать точку в `:id`, добавьте ограничение, которое переопределит это - к примеру, `id: /[^\/]+/` позволяет все, кроме слэша.

### Переопределение именованных хелперов

Опция `:as` позволяет переопределить нормальное именование для именованных маршрутных хелперов. Например:

```ruby
resources :photos, as: 'images'
```

распознает входящие пути, начинающиеся с `/photos` и смаршрутизирует запросы к `PhotosController`, но использует значение опции `:as` для наименования хелпера:

| Метод HTTP | Путь             | Контроллер#Экшн   | Именованный хелпер   |
| ---------  | ---------------- | ----------------- | -------------------- |
| GET        | /photos          | photos#index      | images_path          |
| GET        | /photos/new      | photos#new        | new_image_path       |
| POST       | /photos          | photos#create     | images_path          |
| GET        | /photos/:id      | photos#show       | image_path(:id)      |
| GET        | /photos/:id/edit | photos#edit       | edit_image_path(:id) |
| PATCH/PUT  | /photos/:id      | photos#update     | image_path(:id)      |
| DELETE     | /photos/:id      | photos#destroy    | image_path(:id)      |

### Переопределение сегментов `new` и `edit`

Опция `:path_names` позволяет переопределить автоматически генерируемые сегменты `new` и `edit` в путях:

```ruby
resources :photos, path_names: { new: 'make', edit: 'change' }
```

Это приведет к тому, что роутинг распознает пути, такие как:

```
/photos/make
/photos/1/change
```

NOTE: Фактические имена экшнов не меняются этой опцией. Два показанных пути все еще ведут к экшнам `new` и `edit`.

TIP: Если вдруг захотите изменить эту опцию одинаково для всех маршрутов, можно использовать scope:

```ruby
scope path_names: { new: 'make' } do
  # остальные ваши маршруты
end
```

### Префикс именованных маршрутных хелперов

Можно использовать опцию `:as` для задания префикса именованных маршрутных хелперов, генерируемых Rails для маршрута. Используйте эту опцию для предотвращения коллизий имен между маршрутами, использующими область видимости пути. Например:

```ruby
scope 'admin' do
  resources :photos, as: 'admin_photos'
end

resources :photos
```

Это предоставит маршрутные хелперы, такие как `admin_photos_path`, `new_admin_photo_path` и т.д.

Для задания префикса группы маршрутов, используйте `:as` со `scope`:

```ruby
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
```

Это сгенерирует маршруты такие как `admin_photos_path` и `admin_accounts_path`, ведущие соответственно к `/admin/photos` и `/admin/accounts`.

NOTE: Область видимости `namespace` автоматически добавляет `:as`, так же как и префиксы `:module` и `:path`.

Можно задать префикс маршрута именованным параметром также и так:

```ruby
scope ':username' do
  resources :articles
end
```

Это предоставит URL, такие как `/bob/articles/1` и позволит обратиться к части пути `username` в контроллерах, хелперах и вьюхах как `params[:username]`.

### (restricting-the-routes-created) Ограничение создаваемых маршрутов

По умолчанию Rails создает маршруты для всех семи дефолтных экшнов (`index`, `show`, `new`, `create`, `edit`, `update` и `destroy`) для каждого маршрута RESTful вашего приложения. Можно использовать опции `:only` и `:except` для точной настройки этого поведения. Опция `:only` говорит Rails создать только определенные маршруты:

```ruby
resources :photos, only: [:index, :show]
```

Теперь запрос `GET` к `/photos` будет успешным, а запрос `POST` к `/photos` (который обычно соединяется с экшном `create`) провалится.

Опция `:except` определяет маршрут или перечень маршрутов, который Rails _не_ должен создавать:

```ruby
resources :photos, except: :destroy
```

В этом случае Rails создаст все нормальные маршруты за исключением маршрута для `destroy` (запрос `DELETE` к `/photos/:id`).

TIP: Если в вашем приложении много маршрутов RESTful, использование `:only` и `:except` для генерации только тех маршрутов, которые Вам фактически нужны, позволит снизить использование памяти и ускорить процесс роутинга.

### Переведенные пути

Используя `scope`, можно изменить имена путей, генерируемых с помощью `resources`:

```ruby
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```

Rails теперь создаст маршруты к `CategoriesController`.

| Метод HTTP | Путь                       | Контроллер#Экшн    | Именованный хелпер      |
| ---------- | -------------------------- | ------------------ | ----------------------- |
| GET        | /kategorien                | categories#index   | categories_path         |
| GET        | /kategorien/neu            | categories#new     | new_category_path       |
| POST       | /kategorien                | categories#create  | categories_path         |
| GET        | /kategorien/:id            | categories#show    | category_path(:id)      |
| GET        | /kategorien/:id/bearbeiten | categories#edit    | edit_category_path(:id) |
| PATCH/PUT  | /kategorien/:id            | categories#update  | category_path(:id)      |
| DELETE     | /kategorien/:id            | categories#destroy | category_path(:id)      |

### Переопределение единственного числа

Если хотите определить единственное число ресурса, следует добавить дополнительные правила в `Inflector`:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```

### Использование `:as` во вложенных ресурсах

Опция `:as` переопределяет автоматически генерируемое имя для ресурса в хелперах вложенного маршрута. Например:

```ruby
resources :magazines do
  resources :ads, as: 'periodical_ads'
end
```

Это создаст маршрутные хелперы, такие как `magazine_periodical_ads_url` и `edit_magazine_periodical_ad_path`.

### Переопределение параметров именованных маршрутов

Опция `:param` переопределяет дефолтный идентификатор ресурса `:id` (имя [динамического сегмента](#dynamic-segments), используемого для генерации маршрутов). К этому сегменту можно обратиться из контроллера с помощью `params[<:param>]`.

```ruby
resources :videos, param: :identifier
```

```
     videos GET  /videos(.:format)                  videos#index
            POST /videos(.:format)                  videos#create
 new_videos GET  /videos/new(.:format)              videos#new
edit_videos GET  /videos/:identifier/edit(.:format) videos#edit
```

```ruby
Video.find_by(identifier: params[:identifier])
```

Можно переопределить `ActiveRecord::Base#to_param` соответствующей модели, чтобы создать URL:

```ruby
class Video < ApplicationRecord
  def to_param
    identifier
  end
end

video = Video.find_by(identifier: "Roman-Holiday")
edit_videos_path(video) # => "/videos/Roman-Holiday"
```

Осмотр и тестирование маршрутов
-------------------------------

Rails предлагает инструменты для осмотра и тестирования маршрутов.

### Список существующих маршрутов

Чтобы получить полный список всех доступных маршрутов вашего приложения, посетите `http://localhost:3000/rails/info/routes` в браузере, в то время как ваш сервер запущен в режиме **development**. Команда `rails routes`, выполненная в терминале, выдаст тот же результат.

Оба метода напечатают все ваши маршруты, в том же порядке, что они появляются в `config/routes.rb`. Для каждого маршрута вы увидите:

* Имя маршрута (если имеется)
* Используемый метод HTTP (если маршрут реагирует не на все методы)
* Шаблон URL
* Параметры роутинга для этого маршрута

Например, вот небольшая часть результата команды `rails routes` для маршрута RESTful:

```
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
 new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
```

Можно искать маршруты с помощью опции grep: -g. Это выведет любые маршруты, которые частично соответствуют по имени метода хелпера URL, метода HTTP или пути URL.

```
$ bin/rails routes -g new_comment
$ bin/rails routes -g POST
$ bin/rails routes -g admin
```

Если хотите просмотреть маршруты, ведущие на определенный контроллер, имеется опция -c.

```
$ bin/rails routes -c users
$ bin/rails routes -c admin/users
$ bin/rails routes -c Comments
$ bin/rails routes -c Articles::CommentsController
```

TIP: Результат команды `rails routes` более читаемый, если у вас в окне терминала прокрутка, а не перенос строчек. Также можно использовать опцию --expanded, чтобы включить режим форматирования расширенных таблиц.

### Тестирование маршрутов

Маршруты должны быть включены в вашу стратегию тестирования (так же, как и остальное в вашем приложении). Rails предлагает три [встроенных оператора контроля](http://api.rubyonrails.org/classes/ActionController/Assertions/RoutingAssertions.html), разработанных для того, чтобы сделать тестирование маршрутов проще:

* `assert_generates`
* `assert_recognizes`
* `assert_routing`

#### Оператор контроля `assert_generates`

Используйте `assert_generates`, чтобы убедиться в том, что определенный набор опций генерирует конкретный путь и может использоваться с дефолтными маршрутами или своими маршрутами. Например:

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### Оператор контроля `assert_recognizes`

Оператор контроля `assert_recognizes` - это противоположность `assert_generates`. Он убеждается, что Rails распознает предложенный путь и маршрутизирует его в конкретную точку в вашем приложении. Например:

```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

Можете задать аргумент `:method`, чтобы определить метод HTTP:

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### Оператор контроля `assert_routing`

Оператор контроля `assert_routing` проверяет маршрут с двух сторон: он тестирует, что путь создает опции, и что опции создают путь. Таким образом, он комбинирует функции `assert_generates` и `assert_recognizes`:

```ruby
assert_routing({ path: 'photos', method: :post }, { controller: 'photos', action: 'create' })
```
