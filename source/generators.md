Создание и настройка генераторов и шаблонов Rails
=================================================

Генераторы Rails - необходимый инструмент, если вы планируете улучшить свой рабочий процесс. С помощью этого руководства вы изучите, как создавать генераторы и настраивать существующие.

После прочтения этого руководства, вы узнаете:

* Как посмотреть, какие генераторы доступны в вашем приложении.
* Как создать генератор с использованием шаблонов.
* Как Rails ищет генераторы, чтобы вызвать их.
* Как Rails генерирует код Rails из шаблонов.
* Как настроить скаффолд, создавая новые генераторы.
* Как настроить скаффолд, изменяя шаблоны генератора.
* Как использовать фолбэки, чтобы избежать переопределения большого набора генераторов.
* Как создать шаблон приложения.

Первый контакт
--------------

При создании приложения с помощью команды `rails` фактически вы используете генератор Rails. После этого можно получить список всех доступных генераторов, просто вызвав `rails generate`:

```bash
$ rails new myapp
$ cd myapp
$ bin/rails generate
```

Вы получите список всех генераторов, поставляющихся с Rails. Если необходимо подробное описание, к примеру, генератора helper, можно просто сделать так:

```bash
$ bin/rails generate helper --help
```

Создание своего генератора
--------------------------

Начиная с Rails 3.0, генераторы создаются на основе [Thor](https://github.com/erikhuda/thor). Thor представляет мощные опции для парсинга и великолепный API для взаимодействия с файлами. Например, давайте создадим генератор, создающий файл инициализатора с именем `initializer.rb` внутри `config/initializers`.

Первым шагом является создание файла `lib/generators/initializer_generator.rb` со следующим содержимым:

```ruby
class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/initializer.rb", "# Add initialization content here"
  end
end
```

NOTE: `create_file` - это метод, представленный `Thor::Actions`. Документация по `create_file` и другие методы Thor находятся в [документации по Thor](http://rdoc.info/github/erikhuda/thor/master/Thor/Actions.html)

Наш новый генератор очень прост: он наследуется от `Rails::Generators::Base` и содержит одно определение метода. Когда генератор вызывается, каждый публичный метод в генераторе выполняется в порядке, в котором он определен. Наконец, мы вызываем метод `create_file`, который создаст файл в указанном месте с заданным содержимым. Если вы знакомы с Rails Application Templates API, API генераторов покажется вам очень знакомым.

Чтобы вызвать наш новый генератор, нужно всего лишь выполнить:

```bash
$ bin/rails generate initializer
```

Перед тем, как продолжить, давайте посмотрим на описание нашего нового генератора:

```bash
$ bin/rails generate initializer --help
```

Rails обычно способен генерировать хорошие описания, если генератор расположен в пространствах имен, таких как `ActiveRecord::Generators::ModelGenerator`, но не в этом частном случае. Эту проблему можно решить двумя способами. Первым является вызов `desc` внутри нашего генератора:

```ruby
class InitializerGenerator < Rails::Generators::Base
  desc "This generator creates an initializer file at config/initializers"
  def create_initializer_file
    create_file "config/initializers/initializer.rb", "# Add initialization content here"
  end
end
```

Теперь можно просмотреть новое описание, вызвав `--help` на новом генераторе. Вторым способом является добавление описания в файле `USAGE` в той же директории, что и наш генератор. Мы это сделаем на следующем этапе.

Создание генераторов с помощью генераторов
------------------------------------------

У самих генераторов есть генератор:

```bash
$ bin/rails generate generator initializer
      create  lib/generators/initializer
      create  lib/generators/initializer/initializer_generator.rb
      create  lib/generators/initializer/USAGE
      create  lib/generators/initializer/templates
      invoke  test_unit
      create    test/lib/generators/initializer_generator_test.rb
```

Вот только что созданный генератор:

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)
end
```

Сперва обратите внимание, что он унаследован от `Rails::Generators::NamedBase` вместо `Rails::Generators::Base`. Это означает, что наш генератор ожидает как минимум один аргумент, который будет именем инициализатора и будет доступным в нашем коде в переменной `name`.

Это можно увидеть, если вызвать описание для генератора (не забудьте удалить файл старого генератора):

```bash
$ bin/rails generate initializer --help
Usage:
  rails generate initializer NAME [options]
```

Также можно увидеть, что в нашем новом генераторе есть метод класса `source_root`. Этот метод указывает на место расположения шаблонов нашего генератора, если таковые имеются, и по умолчанию он указывает на созданную директорию `lib/generators/initializer/templates`.

Чтобы понять, что такое шаблон генератора, давайте создадим файл `lib/generators/initializer/templates/initializer.rb` со следующим содержимым:

```ruby
# Add initialization content here
```

А теперь изменим генератор, чтобы он копировал этот файл при вызове:

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/#{file_name}.rb"
  end
end
```

И выполним наш генератор:

```bash
$ bin/rails generate initializer core_extensions
```

Теперь мы видим, что инициализатор с именем core_extensions был создан в `config/initializers/core_extensions.rb` с содержимым нашего шаблона. Это означает, что `copy_file` копирует файл из корневой директории исходников в заданный путь назначения. Метод `file_name` автоматически создается, когда мы наследуем от `Rails::Generators::NamedBase`.

Доступные для генераторов методы раскрываются в [последнем разделе](#generator-methods) этого руководства.

Поиск генераторов
-----------------

При запуске `rails generate initializer core_extensions` Rails затребует эти файлы в следующем порядке, пока один из них не будет найден:

```bash
rails/generators/initializer/initializer_generator.rb
generators/initializer/initializer_generator.rb
rails/generators/initializer_generator.rb
generators/initializer_generator.rb
```

Если ни один не найден, вы получите сообщение об ошибке.

INFO: Вышеуказанный пример положит файлы в папку `lib` приложения, поскольку сказано, что эта директория принадлежит `$LOAD_PATH`.

Настройка рабочего процесса
---------------------------

Собственные генераторы Rails достаточно гибки, чтобы позволить вам настроить скаффолдинг. Они могут быть настроены в `config/application.rb`, вот несколько настроек по умолчанию:

```ruby
config.generators do |g|
  g.orm             :active_record
  g.template_engine :erb
  g.test_framework  :test_unit, fixture: true
end
```

Так как мы настраиваем наш рабочий процесс, давайте сперва посмотрим, как выглядит наш скаффолд:

```bash
$ bin/rails generate scaffold User name:string
      invoke  active_record
      create    db/migrate/20130924151154_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
      create      test/models/user_test.rb
      create      test/fixtures/users.yml
      invoke  resource_route
       route    resources :users
      invoke  scaffold_controller
      create    app/controllers/users_controller.rb
      invoke    erb
      create      app/views/users
      create      app/views/users/index.html.erb
      create      app/views/users/edit.html.erb
      create      app/views/users/show.html.erb
      create      app/views/users/new.html.erb
      create      app/views/users/_form.html.erb
      invoke    test_unit
      create      test/controllers/users_controller_test.rb
      invoke    helper
      create      app/helpers/users_helper.rb
      invoke    jbuilder
      create      app/views/users/index.json.jbuilder
      create      app/views/users/show.json.jbuilder
      invoke  test_unit
      create    test/application_system_test_case.rb
      create    test/system/users_test.rb
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/users.coffee
      invoke    scss
      create      app/assets/stylesheets/users.scss
      invoke  scss
      create    app/assets/stylesheets/scaffolds.scss
```

Глядя на этот вывод, легко понять, как работают генераторы в Rails 3.0 и выше. Генератор скаффолда фактически не генерирует ничего, он просто вызывает другие. Это позволяет нам добавить/заменить/убрать любые из этих вызовов. Например, генератор скаффолда вызывает генератор scaffold_controller, который вызывает генераторы erb, test_unit и helper. Поскольку у каждого генератора одна функция, их просто использовать повторно, избегая дублирования кода.

Если хотите избежать генерации файла по умолчанию `app/assets/stylesheets/scaffolds.scss` при скаффолдинге нового ресурса, можно отключить `scaffold_stylesheet`:

```ruby
  config.generators do |g|
    g.scaffold_stylesheet false
  end
```

Следующей настройкой рабочего процесса будет полное прекращение генерации таблиц стилей, JavaScript и фикстур для тестов скаффолда. Этого можно достичь, изменив конфигурацию следующим образом:

```ruby
config.generators do |g|
  g.orm             :active_record
  g.template_engine :erb
  g.test_framework  :test_unit, fixture: false
  g.stylesheets     false
  g.javascripts     false
end
```

Если мы сгенерируем другой ресурс с помощью генератора скаффолда, мы увидим, что ни таблица стилей, ни JavaScript, ни фикстуры более не будут созданы. Если мы захотим настраивать его дальше, например использовать DataMapper и RSpec вместо Active Record и TestUnit, это достигается всего лишь добавлением соответствующих гемов в приложение и настройкой ваших генераторов.

Для демонстрации мы собираемся создать новый генератор хелперов, который просто добавляет несколько методов-ридеров для переменных экземпляра. Сначала мы создадим генератор в пространстве имен rails, так как тут rails ищет генераторы, используемые как хуки:

```bash
$ bin/rails generate generator rails/my_helper
      create  lib/generators/rails/my_helper
      create  lib/generators/rails/my_helper/my_helper_generator.rb
      create  lib/generators/rails/my_helper/USAGE
      create  lib/generators/rails/my_helper/templates
      invoke  test_unit
      create    test/lib/generators/rails/my_helper_generator_test.rb
```

Можно опробовать наш новый генератор, создав хелпер для продуктов:

```bash
$ bin/rails generate my_helper products
      create  app/helpers/products_helper.rb
```

И следующий хелпер будет сгенерирован в `app/helpers`:

```ruby
module ProductsHelper
  attr_reader :products, :product
end
```

Что, собственно, и ожидалось. Можно сообщить скаффолду использовать наш новый генератор хелпера, снова отредактировав `config/application.rb`:

```ruby
config.generators do |g|
  g.orm             :active_record
  g.template_engine :erb
  g.test_framework  :test_unit, fixture: false
  g.stylesheets     false
  g.javascripts     false
  g.helper          :my_helper
end
```

и увидев его в действии при вызове генератора:

```bash
$ bin/rails generate scaffold Article body:text
      [...]
      invoke    my_helper
      create      app/helpers/articles_helper.rb
```

Можно отметить в выводе, что был вызван наш новый генератор хелпера вместо генератора Rails по умолчанию. Однако мы кое-что упустили, это тесты для нашего нового генератора, и чтобы их сделать, мы воспользуемся старыми генераторами теста для хелперов.

Начиная с Rails 3.0, это просто, благодаря концепции хуков. Наш новый хелпер не должен быть сфокусирован на какой-то определенный тестовый фреймворк, он просто представляет хук, и тестовому фреймворку нужно всего-лишь реализовать этот хук, чтобы быть совместимым.

Для этого мы изменим генератор следующим образом:

```ruby
# lib/generators/rails/my_helper/my_helper_generator.rb
class Rails::MyHelperGenerator < Rails::Generators::NamedBase
  def create_helper_file
    create_file "app/helpers/#{file_name}_helper.rb", <<-FILE
module #{class_name}Helper
  attr_reader :#{plural_name}, :#{plural_name.singularize}
end
    FILE
  end

  hook_for :test_framework
end
```

Теперь, когда вызывается генератор хелпера, и как тестовый фреймворк настроен TestUnit, он попытается вызвать `Rails::TestUnitGenerator` и `TestUnit::MyHelperGenerator`. Поскольку ни один из них не определен, можно сообщить нашему генератору вместо них вызывать `TestUnit::Generators::HelperGenerator`, который определен, так как это генератор Rails. Для этого нужно всего лишь добавить:

```ruby
# Search for :helper instead of :my_helper
hook_for :test_framework, as: :helper
```

Теперь можно снова запустить скаффолд для другого ресурса и увидеть, что он также генерирует тесты!

Настройка рабочего процесса, изменяя шаблоны генераторов
--------------------------------------------------------

На предыдущем шаге мы просто хотели добавить строчку в сгенерированный хелпер без добавления какой-либо дополнительной функциональности. Имеется более простой способ, чтобы сделать такое - замена шаблонов для уже существующих генераторов, в нашем случае `Rails::Generators::HelperGenerator`.

В Rails 3.0 и выше генераторы не просто ищут шаблоны в корневом пути, они также ищут по другим путям. И одно из них — `lib/templates`. Поскольку мы хотим изменить `Rails::Generators::HelperGenerator`, можно это осуществить, просто сделав копию шаблона в `lib/templates/rails/helper` с именем `helper.rb`. Так давайте же создадим этот файл со следующим содержимым:

```erb
module <%= class_name %>Helper
  attr_reader :<%= plural_name %>, :<%= plural_name.singularize %>
end
```

и отменим последнее изменение в `config/application.rb`:

```ruby
config.generators do |g|
  g.orm             :active_record
  g.template_engine :erb
  g.test_framework  :test_unit, fixture: false
  g.stylesheets     false
  g.javascripts     false
end
```

Если сгенерировать другой ресурс, то увидите абсолютно тот же результат! Это полезно, если хотите изменить шаблоны вашего скаффолда и/или макет, просто создав `edit.html.erb`, `index.html.erb` и так далее в `lib/templates/erb/scaffold`.

Шаблоны скаффолда в Rails часто используют теги ERB; эти теги необходимо экранировать, чтобы сгенерированный результат являлся валидным кодом ERB.

Например, в шаблоне необходим следующий экранированный тег ERB (обратите внимание на дополнительный `%`)...

```ruby
<%%= stylesheet_include_tag :application %>
```

...чтобы сгенерировать следующий результат:

```ruby
<%= stylesheet_include_tag :application %>
```


Добавление фолбэков генераторов
-------------------------------

Еще одна особенность генераторов, которая очень полезна, это фолбэки. Например, представим, что вы хотите добавить особенность над TestUnit, такую как [shoulda](https://github.com/thoughtbot/shoulda). Так как TestUnit уже реализует все генераторы, требуемые Rails, а shoulda всего лишь хочет переопределить часть из них, нет необходимости для shoulda переопределять некоторые генераторы, она может просто сообщить Rails использовать генератор `TestUnit`, если такой не найден в пространстве имен `Shoulda`.

Можно с легкостью смоделировать это поведение, снова изменив наш `config/application.rb`:

```ruby
config.generators do |g|
  g.orm             :active_record
  g.template_engine :erb
  g.test_framework  :shoulda, fixture: false
  g.stylesheets     false
  g.javascripts     false

  # Добавим фолбэк!
  g.fallbacks[:shoulda] = :test_unit
end
```

Теперь, если создать скаффолд Comment, вы увидите, что были вызваны генераторы shoulda, но в итоге они всего лишь переуступили генераторам TestUnit:

```bash
$ bin/rails generate scaffold Comment body:text
      invoke  active_record
      create    db/migrate/20130924143118_create_comments.rb
      create    app/models/comment.rb
      invoke    shoulda
      create      test/models/comment_test.rb
      create      test/fixtures/comments.yml
      invoke  resource_route
       route    resources :comments
      invoke  scaffold_controller
      create    app/controllers/comments_controller.rb
      invoke    erb
      create      app/views/comments
      create      app/views/comments/index.html.erb
      create      app/views/comments/edit.html.erb
      create      app/views/comments/show.html.erb
      create      app/views/comments/new.html.erb
      create      app/views/comments/_form.html.erb
      invoke    my_helper
      create      app/helpers/comments_helper.rb
      invoke      shoulda
      create        test/helpers/comments_helper_test.rb
      invoke    jbuilder
      create      app/views/comments/index.json.jbuilder
      create      app/views/comments/show.json.jbuilder
      invoke  test_unit
      create    test/application_system_test_case.rb
      create    test/system/comments_test.rb
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/comments.coffee
      invoke    scss
```

Фолбэки позволяют вашим генераторам иметь единственную ответственность, увеличить повторное использование кода и уменьшить дублирование.

Шаблоны приложения
------------------

Теперь, когда вы узнали, как генераторы используются _внутри_ приложения, знаете ли вы, что они используются и для _генерации_ приложения тоже? Этот тип генератора называют "template". Далее идет краткий обзор Templates API. Подробную информацию смотрите в руководстве [Шаблоны приложения на Rails](/rails-application-templates).

```ruby
gem "rspec-rails", group: "test"
gem "cucumber-rails", group: "test"

if yes?("Would you like to install Devise?")
  gem "devise"
  generate "devise:install"
  model_name = ask("What would you like the user model to be called? [user]")
  model_name = "user" if model_name.blank?
  generate "devise", model_name
end
```

В вышеприведенном шаблоне мы определили, что приложение полагается на гемы `rspec-rails` и `cucumber-rails`, поэтому они будут добавлены в группу `test` в `Gemfile`. Затем мы зададим вопрос пользователю относительно того, хочет ли он установить Devise. Если пользователь ответит "y" или "yes" на этот вопрос, тогда шаблон добавит Devise в `Gemfile` вне какой-либо группы, а затем запустит генератор `devise:install`. Затем этот шаблон возьмет пользовательский ввод и запустит генератор `devise` с переданным ответом пользователя из последнего вопроса.

Представим, что этот шаблон был в файле `template.rb`. Можно его использовать, чтобы модифицировать результат команды `rails new` с помощью опции `-m` и передачей имени файла:

```bash
$ rails new thud -m template.rb
```

Эта команда сгенерирует приложение `Thud`, а затем применит шаблон к сгенерированному результату.

Шаблоны не обязательно должны храниться в локальной системе, опция `-m` также поддерживает онлайн шаблоны:

```bash
$ rails new thud -m https://gist.github.com/radar/722911/raw/
```

В то время как последний раздел этого руководства не раскрывает, как генерировать замечательные шаблоны, он познакомит вас с доступными методами, с помощью которых вы сможете создать их самостоятельно. Абсолютно те же методы доступны и для генераторов.

Добавление аргументов командной строки
--------------------------------------

Генераторы Rails легко модифицировать, чтобы они принимали произвольные аргументы командной строки. Эта функциональность исходит из [Thor](http://www.rubydoc.info/github/erikhuda/thor/master/Thor/Base/ClassMethods#class_option-instance_method):

```
class_option :scope, type: :string, default: 'read_products'
```

Теперь наш генератор может быть вызван следующим образом:

```bash
rails generate initializer --scope write_products
```

К аргументам командной строки можно обратиться с помощью метода `options` в классе генератора. То есть:

```ruby
@scope = options['scope']
```

(Generator methods) Методы генератора
-------------------------------------

Следующие методы доступны как для генераторов, так и для шаблонов Rails.

NOTE: Методы, представленные Thor не раскрываются в этом руководстве, а находятся в [документации по Thor](http://rdoc.info/github/erikhuda/thor/master/Thor/Actions.html)

### `gem`

Указывает зависимость приложения от гема.

```ruby
gem "rspec", group: "test", version: "2.1.0"
gem "devise", "1.1.5"
```

Доступны следующие опции:

* `:group` - Группа в `Gemfile`, где должен быть гем.
* `:version` - Строка версии гема, которую нужно использовать. Также может быть указана в качестве второго аргумента метода.
* `:git` - URL репозитория git для этого гема.

Любые дополнительные опции, переданные в этот метод помещаются в конце строчки:

```ruby
gem "devise", git: "https://github.com/plataformatec/devise.git", branch: "master"
```

Вышеприведенный код поместит следующую строчку в `Gemfile`:

```ruby
gem "devise", git: "https://github.com/plataformatec/devise.git", branch: "master"
```

### `gem_group`

Оборачивает вхождения гемов в группу:

```ruby
gem_group :development, :test do
  gem "rspec-rails"
end
```

### `add_source`

Добавляет определенный источник в `Gemfile`:

```ruby
add_source "http://gems.github.com"
```

Этот метод также принимает блок:

```ruby
add_source "http://gems.github.com" do
  gem "rspec-rails"
end
```

### `inject_into_file`

Встраивает блок кода в определенную позицию вашего файла.

```ruby
inject_into_file 'name_of_file.rb', after: "#The code goes below this line. Don't forget the Line break at the end\n" do <<-'RUBY'
  puts "Hello World"
RUBY
end
```

### `gsub_file`

Заменяет текст в файле.

```ruby
gsub_file 'name_of_file.rb', 'method.to_be_replaced', 'method.the_replacing_code'
```

Этот метод можно сделать более точным с помощью регулярных выражений. Таким же образом можно использовать `append_file` и `prepend_file`, чтобы поместить код в начало или конец файла соответственно.

### `application`

Добавляет строчку в `config/application.rb` непосредственно после определения класса приложения.

```ruby
application "config.asset_host = 'http://example.com'"
```

Также этот метод может принимать блок:

```ruby
application do
  "config.asset_host = 'http://example.com'"
end
```

Доступные опции:

* `:env` - Определяет среду для этой конфигурационной опции. Если хотите использовать эту опцию с блочным синтаксисом, рекомендуемый синтаксис следующий:

```ruby
application(nil, env: "development") do
  "config.asset_host = 'http://localhost:3000'"
end
```

### `git`

Запускает определенную команду git:

```ruby
git :init
git add: "."
git commit: "-m First commit!"
git add: "onefile.rb", rm: "badfile.cxx"
```

Значения хэша будут аргументами или опциями, переданными в определенную команду git. Как показано в последнем примере, одновременно могут быть определены несколько команд git, но не гарантируется соответствие порядка их запуска порядку, в котором они определены.

### `vendor`

Помещает файл, содержащий указанный код, в `vendor`.

```ruby
vendor "sekrit.rb", '#top secret stuff'
```

Этот метод также принимает блок:

```ruby
vendor "seeds.rb" do
  "puts 'in your app, seeding your database'"
end
```

### `lib`

Помещает файл, содержащий указанный код, в `lib`.

```ruby
lib "special.rb", "p Rails.root"
```

Этот метод также принимает блок:

```ruby
lib "super_special.rb" do
  "puts 'Super special!'"
end
```

### `rakefile`

Создает файл Rake в директории `lib/tasks` приложения.

```ruby
rakefile "test.rake", 'task(:hello) { puts "Hello, there" }'
```

Этот метод также принимает блок:

```ruby
rakefile "test.rake" do
  %Q{
    task rock: :environment do
      puts "Rockin'"
    end
  }
end
```

### `initializer`

Создает инициализатор в директории `config/initializers` приложения:

```ruby
initializer "begin.rb", "puts 'this is the beginning'"
```

Этот метод также принимает блок и ожидает возврата строки:

```ruby
initializer "begin.rb" do
  "puts 'this is the beginning'"
end
```

### `generate`

Запускает указанный генератор, где первый аргумент это имя генератора, а оставшиеся аргументы передаются непосредственно в генератор.

```ruby
generate "scaffold", "forums title:string description:text"
```

### `rake`

Запускает указанную задачу Rake.

```ruby
rake "db:migrate"
```

Доступные опции:

* `:env` - Указывает среду, в которой запускается эта задача rake.
* `:sudo` - Запускать ли эту задачу с помощью `sudo`. По умолчанию `false`.

### `route`

Добавляет текст в файл `config/routes.rb`:

```ruby
route "resources :people"
```

### `readme`

Выводит содержимое файла из `source_path` шаблона, обычно README.

```ruby
readme "README"
```
