Заметки о релизе Ruby on Rails 3.0
==================================

Rails 3.0 это волшебство! Он приготовит вам ужин и постирает белье. Вы не сможете понять как вы жили без него. Это Лучшая Версия Rails, Какой Еще Не Было!

Но если серьезно, это действительно замечательная вещь. В него вложены все замечательные идеи, внесенные присоединившейся командой Merb, сделан фокус на минимизацию и скорость фреймворка и удобный API. Если вы переходите на Rails 3.0 с Merb 1.x, то вам многое будет знакомым. Если переходите с Rails 2.x, то вы его тоже полюбите.

Даже если вам не интересны подробности об оптимизации "внутренностей", в Rails 3.0 есть что показать. У нас много новых возможностей и улучшений API. Сейчас очень подходящий момент стать разработчиком на Rails. Некоторые из ключевых возможностей:

* Совершенно новый роутинг на основе объявлений RESTful
* Новое Action Mailer API, похожее на Action Controller (теперь без головной боли посылающее multipart сообщения!)
* Новый сцепляемый язык запросов Active Record, построенный на основе relational algebra
* Ненавязчивые хелперы JavaScript с драйверами для Prototype, jQuery и в будущем других фреймворков (конец встроенному JS)
* Удобное управление зависимостями с помощью Bundler

Помимо всего этого, мы попытались как можно лучше указать об устаревании прежнего API с помощью хороших предупреждений. Это означает, что можно перенести ваше существующее приложение на Rails 3 без необходимости немедленного переписывания всего вашего старого кода в соответствии с последними best practices.

Эти заметки о релизе покрывают только основные изменения, но не включают все мелкие исправления программных ошибок и изменения. Rails 3.0 содержит почти 4,000 коммитов от более чем 250 авторов! Чтобы увидеть все, обратитесь к [списку коммитов](https://github.com/rails/rails/commits/3-0-stable) в главном репозитории Rails на GitHub.

--------------------------------------------------------------------------------

Чтобы установить Rails 3:

```bash
# Используйте sudo, если этого требует установка
$ gem install rails
```

Апгрейд до Rails 3
------------------

Прежде чем апгрейдить существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 3, необходимо сначала произвести апгрейд до Rails 2.3.5 и убедиться, что приложение все еще выполняется так, как нужно. Затем обратите внимание на следующие изменения:

### Rails 3 требует как минимум Ruby 1.8.7

Rails 3.0 требует Ruby 1.8.7 или выше. Поддержка всех прежних версий Ruby была официально прекращена, и следует произвести апгрейд как можно раньше. Rails 3.0 также совместим с Ruby 1.9.2.

TIP: Отметьте, что в Ruby 1.8.7 p248 и p249 имеются программные ошибки маршалинга, ломающие Rails 3.0. Хотя в Ruby Enterprise Edition это было исправлено, начиная с релиза 1.8.7-2010.02. В ветке 1.9, Ruby 1.9.1 не пригоден к использованию, поскольку он иногда вылетает в Rails 3.0, поэтому, если хотите использовать Rails 3.0 с 1.9.x перепрыгивайте на 1.9.2 для гладкой работы.

### Объект Rails Application

Как часть внутренней работы по поддержке запуска нескольких приложений на Rails в одном процессе, Rails 3 представляет концепцию объекта Application. Этот объект содержит все настройки, специфичные для приложения, и очень похож по сути на `config/environment.rb` из прежних версий Rails.

Теперь каждое приложение Rails должно иметь соответствующий объект application. Этот объект определяется в `config/application.rb`. При апгрейде существующего приложения до Rails 3, необходимо добавить этот файл и переместить подходящие конфигурации из `config/environment.rb` в `config/application.rb`.

### script/* заменен на script/rails

Новый `script/rails` заменяет все ранее использовавшиеся скрипты из директории `script`. Впрочем, сейчас не нужно запускать даже `script/rails`, команда `rails` обнаруживает его при вызове из корня приложения Rails и запускает этот скрипт. Пример изменившегося использования:

```bash
$ rails console                      # вместо script/console
$ rails g scaffold post title:string # вместо script/generate scaffold post title:string
```

Запустите `rails --help`, чтобы увидеть список всех опций.

### Зависимости и config.gem

Метода `config.gem` больше нет, он был заменен использованием `bundler` и `Gemfile`, смотрите [Внешние Гемы](#vendoring-gems) ниже.

### Процесс апгрейда

Для упрощения и автоматизации процесса апгрейда был создан плагин [Rails Upgrade](https://github.com/rails/rails_upgrade).

Просто установите плагин, затем запустите `rake rails:upgrade:check` для проверки, какие части вашего приложения следует обновить (с ссылками на информацию, как это сделать). Он также предлагает задачу по генерации `Gemfile`, основанного на текущих вызовах `config.gem`, и задачу по генерации нового маршрутного файла из старого. Чтобы получить плагин, просто запустите:

```bash
$ ruby script/plugin install git://github.com/rails/rails_upgrade.git
```

Пример того, как это все работает, можно увидеть в [Rails Upgrade is now an Official Plugin](http://omgbloglol.com/post/364624593/rails-upgrade-is-now-an-official-plugin)

Помимо Rails Upgrade tool, если нужна помощь, есть люди в IRC и [rubyonrails-talk](http://groups.google.com/group/rubyonrails-talk), которые, возможно, сталкивались с подобными проблемами. Напишите в свой блог о своем опыте апгрейда, чтобы другие смогли воспользоваться вашими знаниями!

Создание приложения Rails 3.0
-----------------------------

```bash
# Уже должен быть установлен руби-гем 'rails'
$ rails new myapp
$ cd myapp
```

### Сторонние гемы

Сейчас Rails использует `Gemfile` в корне приложения, чтобы определить гемы, требуемые для запуска вашего приложения. Этот `Gemfile` обрабатывается [Bundler](https://github.com/bundler/bundler), который затем устанавливает все зависимости. Он может даже установить все зависимости локально в ваше приложение, и оно не будет зависеть от системных гемов.

Подробнее: - [домашняя страница Bundler](https://bundler.io/)

### Живите на грани

`Bundler` и `Gemfile` замораживает ваше приложение Rails с помощью отдельной команды `bundle`, поэтому `rake freeze` более не актуальна и была отброшена.

Если хотите установить напрямую из репозитория Git, передайте флажок `--edge`:

```bash
$ rails new myapp --edge
```

Если имеется локальная копия репозитория Rails, и необходимо сгенерировать приложение используя ее, передайте флажок `--dev`:

```bash
$ ruby /path/to/rails/bin/rails new myapp --dev
```

Архитектурные изменения Rails
-----------------------------

Имеется шесть больших изменений в архитектуре Rails.

### Railties Restrung

Railties был обновлен, чтобы предоставить совместимое с плагинами API для всего фреймворка Rails, а также полностью переписаны генераторы и зависимости Rails, в результате разработчики смогут в значительной степени внедрять свой код в генераторы и фреймворк приложения совместимым и определенным образом.

### Все компоненты ядра Rails были разделены

В связи с объединением Merb и Rails, одним из заданий было устранение тесно связанных вместе компонентов ядра Rails. Это было достигнуто, и теперь все компоненты ядра Rails используют то же API, что вы можете использовать для своих плагинов. Это означает, что каждый сделанный вами плагин или замена любого компонента ядра (например, DataMapper или Sequel) имеют доступ ко всей функциональности, к которой имеют доступ компоненты ядра Rails, и могут расширять и улучшать ее как угодно.

Подробнее: - [The Great Decoupling](http://yehudakatz.com/2009/07/19/rails-3-the-great-decoupling/)

### Абстракция Active Model

Частью разделения компонентов ядра было выделение всех связей из Action Pack в Active Record. Теперь это выполнено. Всем новым плагинам ORM теперь всего лишь нужно внедрить интерфейсы Active Model, чтобы работать с Action Pack.

Подробнее: - [Make Any Ruby Object Feel Like ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)

### Абстракция контроллера

Другой крупной частью разделения компонентов ядра было создание основного суперкласса, отделенного от терминов HTTP, для управления рендерингом вьюх и т.д. Создание `AbstractController` позволило существенно упростить `ActionController` и `ActionMailer`, убрав общий код из этих библиотек, и поместив его в Abstract Controller.

Подробнее: - [Rails Edge Architecture](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)

### Интеграция Arel

[Arel](https://github.com/brynary/arel) (или Active Relation) был принят в качестве основы Active Record, и теперь требуется в Rails. Arel предоставляет абстракцию SQL, упрощающую Active Record и предоставляющую основы для функциональности relation в Active Record.

Подробнее: - [Why I wrote Arel](https://web.archive.org/web/20120718093140/http://magicscalingsprinkles.wordpress.com/2010/01/28/why-i-wrote-arel/).

### Извлечение Mail

В Action Mailer с самого начала были monkey патчи, пре-парсеры и даже агенты для отправки и получения, все вдобавок к встроенному в исходник TMail. Версия 3 изменила все это, так что вся функциональность, связанная с сообщениями email была выделена в гем [Mail](https://github.com/mikel/mail). Это, опять же, уменьшило повторение кода и помогло определить границы между Action Mailer и парсером email.

Подробнее: - [New Action Mailer API in Rails 3](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)

Интернационализация
-------------------

В Rails 3 было проделано много работы над поддержкой I18n, включая гем [I18n](https://github.com/svenfuchs/i18n), поддерживающий разные улучшения производительности.

* I18n для любого объекта - поведение I18n может быть добавлено к любому объекту, включая `ActiveModel::Translation` и `ActiveModel::Validations`. Для переводов также имеется `errors.messages` fallback.
* У атрибутов имеются переводы по умолчанию.
* Form Submit Tag автоматически ставит правильный статус (Create или Update), в зависимости от статуса объекта, и, таким образом, ставит правильный перевод.
* Label теперь также работает с I18n, просто передайте в него имя атрибута.

Подробнее: - [Rails 3 I18n changes](http://blog.plataformatec.com.br/2010/02/rails-3-i18n-changes/)

Railties
--------

В связи с разделением главных фреймворков Rails, в Railties проведена огромная переделка, чтобы он связывал фреймворки, engine-ы или плагины настолько просто и безболезненно, насколько это возможно:

* У каждого приложения теперь есть собственное пространство имен, к примеру, приложение стартует с помощью `YourAppName.boot`, что позволяет взаимодействовать с другими приложениями намного проще.
* Теперь все в `Rails.root/app` добавляется в путь загрузки, поэтому можно сделать `app/observers/user_observer.rb` и Rails загрузит его безо всяких модификаций.
* Теперь Rails 3.0 предоставляет объект `Rails.config`, представляющий централизованное хранилище всех типов гибких конфигурационных опций Rails.

Генератор приложения получает дополнительные флажки, позволяющие опустить установку test-unit, Active Record, Prototype и Git. Также добавлен новый флажок `--dev`, настраивающий приложение с `Gemfile`, указывающим на вашу версию Rails (определенную путем к исходникам `rails`). Подробнее смотрите `rails --help`.

Генераторы Railties требуют большого внимания, основываясь на том, что:

* Генераторы были полностью переписаны и обратно не совместимы.
* API шаблонов Rails и API генераторов были объединены (сейчас они фактически те же самые).
* Генераторы больше не загружаются по специальным путям, они должны быть в путях загрузки Ruby, поэтому вызов `rails generate foo` будет искать `generators/foo_generator`.
* Новые генераторы предоставляют хуки, таким образом в них могут быть легко внедрен любой шаблон engine, ORM, тестовый фреймворк.
* Новые генераторы позволяют переопределить шаблоны, поместив копию в `Rails.root/lib/templates`.
* Также представлен `Rails::Generators::TestCase`, поэтому вы можете создать собственные генераторы и протестировать их.

Также несколько переделаны вьюхи, генерируемые с помощью генераторов Railties:

* Сейчас вьюхи используют теги `div` вместо тегов `p`.
* Сейчас сгенерированные скаффолды используют партиалы `_form`, вместо повторения кода во вьюхах edit и new.
* Сейчас формы скаффолда используют `f.submit`, возвращающий "Create ModelName" или "Update ModelName", в зависимости от состояния переданного объекта.

Наконец, ряд улучшений был добавлен в задачи rake:

* Был добавлен `rake db:forward`, позволяющий откатить ваши миграции с возвратом отдельно или в группах.
* Был добавлен `rake routes CONTROLLER=x`, позволяющий просмотреть маршруты только к одному контроллеру.

Теперь Railties объявил устаревшим:

* `RAILS_ROOT` в пользу `Rails.root`,
* `RAILS_ENV` в пользу `Rails.env`, и
* `RAILS_DEFAULT_LOGGER` в пользу `Rails.logger`.

`PLUGIN/rails/tasks` и `PLUGIN/tasks` больше не загружаются, все задачи теперь должны быть в `PLUGIN/lib/tasks`.

Подробнее:

* [Discovering Rails 3 generators](http://blog.plataformatec.com.br/2010/01/discovering-rails-3-generators)
* [The Rails Module (in Rails 3)](http://quaran.to/blog/2010/02/03/the-rails-module/)

Action Pack
-----------

В Action Pack произошло множество внутренних и внешних изменений.

### Abstract Controller

В Abstract Controller были извлечены части общего назначения из Action Controller в виде модуля, годного в использовании любой библиотекой, используемой для рендеринга шаблонов или партиалов, хелперов, переводов, логирования и любой части цикла отклика на запрос. Теперь эта абстракция позволяет `ActionMailer::Base` быть унаследованным от `AbstractController` и всего лишь оборачивать Rails DSL в гем Mail.

Это также предоставило возможность вычистить Action Controller, упростив его код.

Однако отметьте, что Abstract Controller не имеет публичного API, и его не стоит запускать в повседневном использовании Rails.

Подробнее: - [Rails Edge Architecture](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)

### Action Controller

* В `application_controller.rb` теперь по умолчанию есть `protect_from_forgery`.
* `cookie_verifier_secret` устарел, вместо этого теперь назначается `Rails.application.config.cookie_secret`, и был перемещен в отдельный файл: `config/initializers/cookie_verification_secret.rb`.
* `session_store` настраивалось в `ActionController::Base.session`, а теперь перемещено в `Rails.application.config.session_store`. Значения по умолчанию устанавливаются в `config/initializers/session_store.rb`.
* `cookies.secure` позволяет устанавливать зашифрованные значения куки с помощью `cookie.secure[:key] => value`.
* `cookies.permanent` позволяет устанавливать постоянные значения хэш куки `cookie.permanent[:key] => value`, вызывая исключение на шифрованных значениях, если не проходит верификация.
* Теперь можно передать `:notice => 'This is a flash message'` или `:alert => 'Something went wrong'` в вызове `format` внутри блока `respond_to`. Хэш `flash[]` все еще работает по-прежнему.
* Теперь в контроллеры добавился метод `respond_with`, упрощающий старые блоки `format`.
* Добавленный `ActionController::Responder` дает гибкость в том, как будут получены сгенерированные вами отклики.

Устарело:

* `filter_parameter_logging` устарел в пользу `config.filter_parameters << :password`.

Подробнее:
* [Render Options in Rails 3](https://www.engineyard.com/blog/render-options-in-rails-3)
* [Three reasons to love ActionController::Responder](http://weblog.rubyonrails.org/2009/8/31/three-reasons-love-responder)

### Action Dispatch

Action Dispatch это новшество в Rails 3.0, он представляет новую, более чистую реализацию роутинга.

* Большая чистка и переписывание роутера, теперь роутер Rails является `rack_mount` с лежащим в основе Rails DSL, это отдельная самодостаточная часть программы.
* Маршруты, определяемые для каждого приложения, теперь помещаются в пространство имен модуля вашего приложения, что означает:

```ruby
# Вместо:

ActionController::Routing::Routes.draw do |map|
  map.resources :posts
end

# Будет:

AppName::Application.routes do
  resources :posts
end
```

* В роутер добавлен метод `match`, также можно к соответствующему маршруту передать любое приложение Rack.
* В роутер добавлен метод `constraints`, позволяющий защитить маршруты определенными ограничениями.
* В роутер добавлен метод `scope`, позволяющий вложить маршруты в пространство имен для разных языков или различных экшнов, например:

```ruby
scope 'es' do
  resources :projects, :path_names => { :edit => 'cambiar' }, :path => 'proyecto'
end

# Даст вам экшн edit по адресу /es/proyecto/1/cambiar
```

* В роутер добавлен метод `root` как ярлык к `match '/', :to => path`.
* В match можно передать несколько опциональных сегментов, например `match "/:controller(/:action(/:id))(.:format)"`, каждый сегмент в скобках является опциональным.
* Маршруты могут быть выражены с помощью блоков, к примеру можно вызвать `controller :home { match '/:action' }`.

NOTE. Старый стиль команд `map` все еще работает, как и прежде, для обратной совместимости, однако будет убран в релизе 3.1.

Устарело

* Обработка всех маршрутов в нересурсных приложениях (`/:controller/:action/:id`) теперь закомментирована.
* :path_prefix в маршрутах больше не существует, а :name_prefix теперь автоматически добавляет "_" в конец заданного значения.

Подробнее:

* [The Rails 3 Router: Rack it Up](http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/)
* [Revamped Routes in Rails 3](https://medium.com/fusion-of-thoughts/revamped-routes-in-rails-3-b6d00654e5b0)
* [Generic Actions in Rails 3](http://yehudakatz.com/2009/12/20/generic-actions-in-rails-3/)

### Action View

#### Ненавязчивый JavaScript

Произошло масштабное переписывание хелперов Action View, реализованы хуки Unobtrusive JavaScript (UJS) и убраны старые команды встроенного AJAX. Это позволило Rails использовать любой совместимый драйвер UJS для внедрения хуков UJS в хелперах.

Это означает, что все прежние хелперы `remote_<method>` были убраны из ядра Rails и перемещены в [Prototype Legacy Helper](https://github.com/rails/prototype_legacy_helper). Для получения хуков UJS в HTML, теперь нужно передать `:remote => true`. Для примера:

```ruby
form_for @post, :remote => true
```

Создаст:

```html
<form action="http://host.com" id="create-post" method="post" data-remote="true">
```

### Хелперы с блоками

Хелперы наподобие `form_for` или `div_for`, вставляющие содержимое из блока, теперь используют `<%=`:

```html+erb
<%= form_for @post do |f| %>
  ...
<% end %>
```

От ваших собственных подобных хелперов ожидается, что они возвращают строку, а не добавляют к результирующему буферу вручную.

Хелперы с другим поведением, наподобие `cache` или `content_for`, не затронуты этим изменением, им нужен `<%` как и прежде.

#### Другие изменения

* Больше не нужно вызывать `h(string)` для экранирования HTML, это осуществляется по умолчанию во всех шаблонах вьюх. Если хотите неэкранированную строку, вызывайте `raw(string)`.
* Теперь по умолчанию хелперы выводят HTML 5.
* Хелпер формы label теперь берет значения из I18n с отдельным значением, таким образом `f.label :name` возьмет перевод `:name`.
* Метка I18n для select теперь :en.helpers.select вместо :en.support.select.
* Теперь не нужно помещать знак минуса в конце интерполяции руби в шаблоне ERB для того, чтобы убрать перевод строки в результирующем HTML.
* В Action View добавлен хелпер `grouped_collection_select`.
* Добавлен `content_for?`, позволяющий проверить существование содержимого во вьюхе до рендеринга.
* Передача в хелперы форм `:value => nil` установит атрибут поля `value` как nil вместо значения по умолчанию
* Передача в хелперы форм `:id => nil` приведет к тому, что эти поля будут отрендерены без атрибута `id`
* Передача `:alt => nil` в `image_tag` приведет к тому, что тег `img` отрендерится без атрибута `alt`

Active Model
------------

Active Model это новшество в Rails 3.0. Он представляет уровень абстракции для любой библиотеки ORM для использования во взаимодействии с Rails с применением интерфейса Active Model.

### Абстракция ORM и интерфейс Action Pack

Частью разделения компонентов ядра было выделение всех связей из Action Pack в Active Record. Теперь это выполнено. Всем новым плагинам ORM теперь всего лишь нужно внедрить интерфейсы Active Model, чтобы работать с Action Pack.

Подробнее: - [Make Any Ruby Object Feel Like ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)

### Валидации

Валидации были перемещены из Active Record в Active Model, предоставляя интерфейс для валидаций, работающий во всех библиотеках ORM в Rails 3.

* Теперь имеется краткий метод `validates :attribute, options_hash` позволяющий передать опции для всех валидационных методов класса, в метод валидации можно передать более одной опции.
* У метода `validates` имеются следующие опции:
    * `:acceptance => Boolean`.
    * `:confirmation => Boolean`.
    * `:exclusion => { :in => Enumerable }`.
    * `:inclusion => { :in => Enumerable }`.
    * `:format => { :with => Regexp, :on => :create }`.
    * `:length => { :maximum => Fixnum }`.
    * `:numericality => Boolean`.
    * `:presence => Boolean`.
    * `:uniqueness => Boolean`.

NOTE: Все валидационные методы стиля Rails 2.3 все еще поддерживаются в Rails 3.0, новый метод валидации разработан как дополнительная помощь при валидации модели, а не как замена существующего API.

Также можно передать объект валидатора, который можно повторно использовать в разных моделях, использующих Active Model:

```ruby
class TitleValidator < ActiveModel::EachValidator
  Titles = ['Mr.', 'Mrs.', 'Dr.']
  def validate_each(record, attribute, value)
    unless Titles.include?(value)
      record.errors[attribute] << 'must be a valid title'
    end
  end
end
```

```ruby
class Person
  include ActiveModel::Validations
  attr_accessor :title
  validates :title, :presence => true, :title => true
end

# Или для Active Record

class Person < ActiveRecord::Base
  validates :title, :presence => true, :title => true
end
```

Также есть поддержка самоанализа:

```ruby
User.validators
User.validators_on(:login)
```

Подробнее:

* [Sexy Validation in Rails 3](http://thelucid.com/2010/01/08/sexy-validation-in-edge-rails-rails-3/)
* [Rails 3 Validations Explained](http://lindsaar.net/2010/1/31/validates_rails_3_awesome_is_true)

Active Record
-------------

Active Record было уделено много внимания в Rails 3.0, включая абстрагирование в Active Model, полное обновление интерфейса запросов с применением Arel, обновления валидаций и многие улучшения и исправления. Rails 2.x API будет полностью поддерживаемым с целью совместимости, до версии 3.1.

### Интерфейс запросов

Теперь Active Record, благодаря использованию Arel, возвращает relations на свои основные методы. Существующее API Rails 2.3.x все еще поддерживается и не будет объявлено устаревшим до Rails 3.1, и не будет убрано до Rails 3.2, однако новое API представляет следующие новые методы, все возвращающие relations, позволяющие сцеплять их вместе:

* `where` - Представляет условия для relation, которое будет возвращено.
* `select` - Выбирает, какие атрибуты моделей будут возращены из БД.
* `group` - Группирует relation по представленному атрибуту.
* `having` - Представляет выражение для ограничения сгруппированных relations (ограничение GROUP BY).
* `joins` - Соединяет relation с другой таблицей.
* `clause` - Представляет выражение, ограничивающее соединенные relations (ограничение JOIN).
* `includes` - Включает предварительную загрузку других relations.
* `order` - Сортирует relation, основываясь на представленном выражении.
* `limit` - Ограничивает relation представленным количеством записей.
* `lock` - Блокирует записи, возвращенные из таблицы.
* `readonly` - Возвращает копию данных только для чтения.
* `from` - Предоставляет способ для выбора relation из более чем одной таблицы.
* `scope` - (ранее `named_scope`) возвращает relations и может быть сцеплен с другим методом для relation.
* `with_scope` - и `with_exclusive_scope` теперь также возвращают relations и могут быть сцеплены.
* `default_scope` - также работает с relations.

Подробнее:

* [Active Record Query Interface](http://m.onkey.org/2010/1/22/active-record-query-interface)
* [Let your SQL Growl in Rails 3](http://hasmanyquestions.wordpress.com/2010/01/17/let-your-sql-growl-in-rails-3/)

### Улучшения

* Добавлен `:destroyed?` к объектам Active Record.
* Добавлена `:inverse_of` к связям Active Record, позволяющая получить экземпляр уже загруженной связи без запроса к базе данных.

### Патчи и устаревания

Кроме того, в ветке Active Record сделано много исправлений:

* Поддержка SQLite 2 была отброшена в пользу SQLite 3.
* Поддержка порядка следования столбцов в MySQL.
* В адаптере PostgreSQL теперь исправлена поддержка `TIME ZONE`, теперь не будут вставляться неправильные значения.
* Поддержка нескольких схем в именах таблицы для PostgreSQL.
* PostgreSQL поддерживает тип данных столбца XML.
* `table_name` теперь кэшируется.
* Много работы выполнено по адаптеру Oracle, также с множеством исправлений программных ошибок.

А также следующее объявлено устаревшим:

* `named_scope` в классе Active Record устарел и был переименован в просто `scope`.
* В методах `scope` следует перейти к использованию методов relation, вместо метода поиска `:conditions => {}`, например `scope :since, lambda {|time| where("created_at > ?", time) }`.
* `save(false)` устарел в пользу `save(:validate => false)`.
* I18n сообщений об ошибках для Active Record должна быть изменена с :en.activerecord.errors.template на `:en.errors.template`.
* `model.errors.on` устарел в пользу `model.errors[]`
* validates_presence_of => validates... :presence => true
* `ActiveRecord::Base.colorize_logging` и `config.active_record.colorize_logging` устарели в пользу `Rails::LogSubscriber.colorize_logging` и `config.colorize_logging`

NOTE: Хотя реализация State Machine была в ветке Active Record несколько месяцев, она была убрана из релиза Rails 3.0.

Active Resource
---------------

Часть Active Resource также была извлечена в Active Model, позволив легко использовать объекты Active Resource с Action Pack.

* Добавлены валидации с помощью Active Model.
* Добавлены хуки обсерверов.
* Поддержка прокси HTTP.
* Добавлена поддержка дайджест-аутентификации.
* Именование модели перемещено в Active Model.
* Изменены атрибуты Active Resource на Hash with indifferent access.
* Добавлены псевдонимы `first`, `last` и `all` для эквивалентных скоупов поиска.
* Теперь `find_every` не возвращает ошибку `ResourceNotFound`, если ничего не возвращено.
* Добавлен `save!`, вызывающий `ResourceInvalid` если объект не `valid?`.
* К моделям Active Resource добавлены `update_attribute` и `update_attributes`.
* Добавлен `exists?`.
* Переименован `SchemaDefinition` в `Schema` и `define_schema` в `schema`.
* Использован `format` из Active Resources, а не `content-type` на удаленных ошибках для загрузки ошибок.
* Использован `instance_eval` для блока схемы.
* Исправлен `ActiveResource::ConnectionError#to_s`, когда `@response` не отвечал на #code или #message, для совместимости с Ruby 1.9.
* Добавлена поддержка для ошибок в формате JSON.
* Гарантировано, что `load` работает с числовыми массивами.
* Распознается отклик 410 от удаленного (remote) ресурса, как то, что ресурс был удален (deleted).
* Добавлена возможность установить опции SSL на соединениях Active Resource.
* Настройки тайм-аута соединения также влияют на `Net::HTTP` `open_timeout`.

Устарело:

* `save(false)` устарел в пользу `save(:validate => false)`.
* Ruby 1.9.2: `URI.parse` и `.decode` устарели и больше не используются в библиотеке.

Active Support
--------------

В Active Support были направлены большие усилия на то, чтобы сделать его раздробленным, это означает, что вам больше не нужно требовать всю библиотеку Active Support, чтобы пользоваться ее частью. Это позволило различным частям компонентов ядра Rails выполняться быстрее.

Вот основные изменения в Active Support:

* Большая чистка всей библиотеки от неиспользуемых методов.
* Active Support более не предоставляет внешние библиотеки TZInfo, Memcache Client и Builder, все они включены как зависимости и устанавливаются с помощью команды `bundle install`.
* Безопасные буферы реализованы в `ActiveSupport::SafeBuffer`.
* Добавлены `Array.uniq_by` и `Array.uniq_by!`.
* Убран `Array#rand` и бэкпортирован `Array#sample` из Ruby 1.9.
* Исправлена программная ошибка в методе `TimeZone.seconds_to_utc_offset`, возвращающий неправильное значение.
* Добавлена промежуточная программа `ActiveSupport::Notifications`.
* `ActiveSupport.use_standard_json_time_format` теперь по умолчанию true.
* `ActiveSupport.escape_html_entities_in_json` теперь по умолчанию false.
* `Integer#multiple_of?` принимает ноль как аргумент, возвращает false если получатель не ноль.
* `string.chars` переименован в `string.mb_chars`.
* `ActiveSupport::OrderedHash` теперь может быть десериализован с помощью YAML.
* Добавлен парсер на основе SAX для XmlMini, с использованием LibXML и Nokogiri.
* Добавлен `Object#presence`, возвращающий объект, если он `#present?`, в ином случае возвращающий `nil`.
* Добавлено расширение для `String#exclude?`, возвращающее противоположность `#include?`.
* Добавлен `to_i` к `DateTime` в `ActiveSupport`, таким образом `to_yaml` правильно работает в моделях с атрибутами `DateTime`.
* Добавлен `Enumerable#exclude?` в пару к `Enumerable#include?`, чтобы избежать условия `!x.include?`.
* Включена по умолчанию экранизация XSS для rails.
* Поддержка многоуровневого объединения в `ActiveSupport::HashWithIndifferentAccess`.
* `Enumerable#sum` теперь работает для всех перечисляемых типов, даже если они не отвечают на `:size`.
* `inspect` на нулевой продолжительности возвращает '0 seconds' вместо пустой строки.
* Добавлены `element` и `collection` в `ModelName`.
* `String#to_time` и `String#to_datetime` обрабатывают дробные секунды.
* Добавлена поддержка для новых колбэков для объекта охватывающего фильтра, отвечающего на `:before` и `:after`, используемых в предварительных и последующих колбэках.
* Метод `ActiveSupport::OrderedHash#to_a` возвращает упорядоченный набор массивов. Соответствует `Hash#to_a` из Ruby 1.9.
* `MissingSourceFile` существует как константа, но сейчас всего лишь равна `LoadError`.
* Добавлен `Class#class_attribute` для возможности объявить атрибуты на уровне класса, значения которых наследуются и перезаписываются подклассами.
* Окончательно убран `DeprecatedCallbacks` в `ActiveRecord::Associations`.
* `Object#metaclass` теперь `Kernel#singleton_class`, для соответствия Ruby.

Следующие методы были убраны, поскольку они теперь доступны в Ruby 1.8.7 и 1.9.

* `Integer#even?` и `Integer#odd?`
* `String#each_char`
* `String#start_with?` и `String#end_with?` (псевдонимы в третьем лице все еще остались)
* `String#bytesize`
* `Object#tap`
* `Symbol#to_proc`
* `Object#instance_variable_defined?`
* `Enumerable#none?`

Патч безопасности для REXML остался в Active Support, поскольку ранним версиям Ruby 1.8.7 он все еще нужен. Active Support знает, нужно его применять или нет.

Следующие методы были убраны, поскольку они больше не используются во фреймворке:

* `Kernel#daemonize`
* `Object#remove_subclasses_of` `Object#extend_with_included_modules_from`, `Object#extended_by`
* `Class#remove_class`
* `Regexp#number_of_captures`, `Regexp.unoptionalize`, `Regexp.optionalize`, `Regexp#number_of_captures`

Action Mailer
-------------

Action Mailer получил новый API в связи с заменой TMail на новый [Mail](https://github.com/mikel/mail) в качестве библиотеки для электронных писем. В самом Action Mailer была переписана практически каждая строчка кода. В результате теперь Action Mailer просто наследуется от Abstract Controller и оборачивает гем Mail в Rails DSL. Это значительно уменьшило количество кода и дублирование других библиотек в Action Mailer.

* По умолчанию все рассыльщики теперь находятся в `app/mailers`.
* Теперь можно отослать email с использованием нового API тремя методами: `attachments`, `headers` and `mail`.
* Теперь в Action Mailer имеется нативная поддержка для встроенных прикрепленных файлов с помощью метода `attachments.inline`.
* Методы рассылки Action Mailer теперь возвращают объекты `Mail::Message`, которые затем могут быть отосланы с помощью метода `deliver` на них.
* Все методы доставки теперь абстрагированы в геме Mail.
* Метод отправки письма может принимать хэш всех валидных полей заголовка письма в паре с их значением.
* Метод доставки `mail` работает подобно `respond_to` из Action Controller, и можно явно или неявно рендерить шаблоны. Action Mailer превратит email в multipart email по необходимости.
* В вызов `format.mime_type` в блоке mail можно передать proc и явно отрендерить определенные типы текста, или добавить макет или различные шаблоны. Вызов `render` внутри proc происходит из Abstract Controller и поддерживает те же опции.
* Юнит-тесты рассыльщика перенесены в функциональные тесты.
* Теперь Action Mailer делегирует все автоматическое кодирование полей заголовка и тела письма в гем Mail
* Action Mailer автоматически закодирует поля заголовка и тело письма

Устарело:

* `:charset`, `:content_type`, `:mime_version`, `:implicit_parts_order` устарели в пользу стиля объявления `ActionMailer.default :key => value`.
* Динамические методы рассыльщика `create_method_name` и `deliver_method_name` устарели, просто вызывайте `method_name`, который возвратит объект `Mail::Message`.
* `ActionMailer.deliver(message)` устарел, просто вызывайте `message.deliver`.
* `template_root` устарел, передавайте опции в вызов render в proc из метода `format.mime_type` внутри блока генерации письма `mail`
* Метод `body` для определения переменных экземпляра устарел (`body {:ivar => value}`), всего лишь определите переменные экземпляра непосредственно в методе, и они будут доступны во вьюхе.
* Нахождение рассыльщиков в `app/models` устарело, вместо этого используйте `app/mailers`.

Подробнее:

* [New Action Mailer API in Rails 3](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)
* [New Mail Gem for Ruby](http://lindsaar.net/2010/1/23/mail-gem-version-2-released)
