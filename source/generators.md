Создание и настройка генераторов и шаблонов Rails
=================================================

Генераторы Rails - необходимый инструмент, для улучшения своего рабочего процесса. С помощью этого руководства вы изучите, как создавать генераторы и настраивать существующие.

После прочтения этого руководства, вы узнаете:

* Как посмотреть, какие генераторы доступны в вашем приложении.
* Как создать генератор с использованием шаблонов.
* Как Rails ищет генераторы, чтобы вызвать их.
* Как настроить скаффолд, переопределяя шаблоны генератора.
* Как настроить скаффолд, переопределяя генераторы.
* Как использовать фолбэки, чтобы избежать переопределения большого набора генераторов.
* Как создать шаблон приложения.

Первый контакт
--------------

При создании приложения с помощью команды `rails` фактически вы используете генератор Rails. После этого можно получить список всех доступных генераторов, вызвав `bin/rails generate`:

```bash
$ rails new myapp
$ cd myapp
$ bin/rails generate
```

NOTE: Чтобы создать новое приложение rails, мы используем глобальную команду `rails`, использующую версию Rails, установленную с помощью `gem install rails`. Когда внутри директории вашего приложения, мы используем команду `bin/rails`, которая использует версию Rails этого приложения.

Вы получите список всех генераторов, поставляющихся с Rails. Чтобы увидеть подробное описание определенного генератора, вызовите генератор с опцией `--help`. Например:

```bash
$ bin/rails generate scaffold --help
```

Создание своего генератора
--------------------------

Генераторы создаются на основе [Thor](https://github.com/erikhuda/thor), представляющего мощные опции для парсинга и великолепный API для взаимодействия с файлами.

Давайте создадим генератор, создающий файл инициализатора с именем `initializer.rb` внутри `config/initializers`. Первым шагом является создание файла `lib/generators/initializer_generator.rb` со следующим содержимым:

```ruby
class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # Тут добавьте содержимое инициализации
    RUBY
  end
end
```

Наш новый генератор очень прост: он наследуется от [`Rails::Generators::Base`][] и содержит одно определение метода. Когда генератор вызывается, каждый публичный метод в генераторе выполняется в порядке, в котором он определен. Наш метод вызывает [`create_file`][], который создаст файл в указанном месте с заданным содержимым.

Чтобы вызвать наш новый генератор, запустим:

```bash
$ bin/rails generate initializer
```

Перед тем, как продолжить, давайте посмотрим на описание нашего нового генератора:

```bash
$ bin/rails generate initializer --help
```

Rails обычно способен производить хорошие описания, если генератор расположен в пространствах имен, таких как `ActiveRecord::Generators::ModelGenerator`, но не в этом случае. Эту проблему можно решить двумя способами. Первым является добавление описания, вызывая [`desc`][] внутри нашего генератора:

```ruby
class InitializerGenerator < Rails::Generators::Base
  desc "This generator creates an initializer file at config/initializers"
  create_file "config/initializers/initializer.rb", <<~RUBY
    # Тут добавьте содержимое инициализации
  RUBY
end
```

Теперь можно просмотреть новое описание, вызвав `--help` на новом генераторе.

Вторым способом является добавление описания в файле `USAGE` в той же директории, что и наш генератор. Мы это сделаем на следующем этапе.

[`Rails::Generators::Base`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html
[`Thor::Actions`]: https://www.rubydoc.info/gems/thor/Thor/Actions
[`create_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#create_file-instance_method
[`desc`]: https://www.rubydoc.info/gems/thor/Thor#desc-class_method

Создание генераторов с помощью генераторов
------------------------------------------

У самих генераторов есть генератор. Давайте уберем наш `InitializerGenerator` и используем `bin/rails generate generator` чтобы сгенерировать его заново:

```bash
$ rm lib/generators/initializer_generator.rb

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
  source_root File.expand_path("templates", __dir__)
end
```

Сперва обратите внимание, что генератор унаследован от [`Rails::Generators::NamedBase`][] вместо `Rails::Generators::Base`. Это означает, что наш генератор ожидает как минимум один аргумент, который будет именем инициализатора и будет доступным в нашем коде как `name`.

Это можно увидеть, если вызвать описание для генератора:

```bash
$ bin/rails generate initializer --help
Usage:
  bin/rails generate initializer NAME [options]
```

Также отметьте, что в генераторе есть метод класса [`source_root`][]. Этот метод указывает на расположение наших шаблонов, если таковые имеются, и по умолчанию он указывает на директорию `lib/generators/initializer/templates`, которая только что была создана.

Чтобы понять, как работает шаблон генератора, давайте создадим файл `lib/generators/initializer/templates/initializer.rb` со следующим содержимым:

```ruby
# Тут добавьте содержимое инициализации
```

И изменим генератор, чтобы он копировал этот файл при вызове:

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/#{file_name}.rb"
  end
end
```

Теперь запустим наш генератор:

```bash
$ bin/rails generate initializer core_extensions
      create  config/initializers/core_extensions.rb

$ cat config/initializers/core_extensions.rb
# Тут добавьте содержимое инициализации
```

Мы видим, что [`copy_file`][] создал `config/initializers/core_extensions.rb` с содержимым нашего шаблона. (Метод `file_name`, используемый в пути назначения, унаследован от `Rails::Generators::NamedBase`.)

[`Rails::Generators::NamedBase`]: https://api.rubyonrails.org/classes/Rails/Generators/NamedBase.html
[`copy_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#copy_file-instance_method
[`source_root`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html#method-c-source_root

Опции командной строки генераторов
----------------------------------

Генераторы могут поддерживать опции командной строки с помощью [`class_option`][]. Например:

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  class_option :scope, type: :string, default: "app"
end
```

Теперь наш генератор может быть вызван с опцией `--scope`:

```bash
$ bin/rails generate initializer theme --scope dashboard
```

Значения опций доступны в методах генератора как [`options`][]:

```ruby
def copy_initializer_file
  @scope = options["scope"]
end
```

[`class_option`]: https://www.rubydoc.info/gems/thor/Thor/Base/ClassMethods#class_option-instance_method
[`options`]: https://www.rubydoc.info/gems/thor/Thor/Base#options-instance_method

Разрешение генератора
---------------------

При разрешении имени генератора, Rails ищет генератор с помощью нескольких имен файлов. Например, при запуске `bin/rails generate initializer core_extensions`, Rails пытается загрузить каждый из следующих файлов по порядку, пока один из них не будет найден:

* `rails/generators/initializer/initializer_generator.rb`
* `generators/initializer/initializer_generator.rb`
* `rails/generators/initializer_generator.rb`
* `generators/initializer_generator.rb`

Если ни один из них не будет найден, будет вызвана ошибка.

Мы поместили наш генератор в директорию `lib/` приложения, потому что эта директория в `$LOAD_PATH`, что позволяет Rails найти и загрузить файл.

Переопределение шаблонов генератора Rails
-----------------------------------------

Rails также будет искать в нескольких местах при разрешении файлов шаблона генератора. Одним из этих мест является директория `lib/templates/` приложения. Это поведение позволяет нам переопределить шаблоны, используемые встроенными в Rails генераторами. Например, мы можем переопределить [шаблон скаффолда контроллера][] или [шаблоны скаффолда вью][].

Чтобы увидеть это в действии, давайте создадим файл `lib/templates/erb/scaffold/index.html.erb.tt` со следующим содержимым:

```erb
<%% @<%= plural_table_name %>.count %> <%= human_name.pluralize %>
```

Отметьте, что это шаблон ERB, который рендерит _другой_ шаблон ERB. Поэтому любой `<%`, который должен появиться в _получившемся_ шаблоне, должен быть экранирован как `<%%` в шаблоне _генератора_.

Теперь давайте запустим генератор скаффолда, встроенного в Rails:

```bash
$ bin/rails generate scaffold Post title:string
      ...
      create      app/views/posts/index.html.erb
      ...
```

Содержимое `app/views/posts/index.html.erb`:

```erb
<% @posts.count %> Posts
```

[scaffold controller template]: https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/scaffold_controller/templates/controller.rb.tt
[scaffold view templates]: https://github.com/rails/rails/tree/main/railties/lib/rails/generators/erb/scaffold/templates

Переопределение генераторов Rails
---------------------------------

Встроенные генераторы Rails могут быть настроены с помощью [`config.generators`][], включая полное переопределение некоторых генераторов.

Сначала давайте пристально взглянем на то, как работает генератор скаффолда.

```bash
$ bin/rails generate scaffold User name:string
      invoke  active_record
      create    db/migrate/20230518000000_create_users.rb
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
      create      app/views/users/_user.html.erb
      invoke    resource_route
      invoke    test_unit
      create      test/controllers/users_controller_test.rb
      create      test/system/users_test.rb
      invoke    helper
      create      app/helpers/users_helper.rb
      invoke      test_unit
      invoke    jbuilder
      create      app/views/users/index.json.jbuilder
      create      app/views/users/show.json.jbuilder
```

Из вывода мы видим, что генератор скаффолда вызывает другие генераторы, такие как генератор `scaffold_controller`. И некоторые из этих генераторов также вызывают другие генераторы. В частности, генератор `scaffold_controller` вызывает несколько других генераторов, включая генератор `helper`.

Давайте переопределим встроенный генератор `helper` новым генератором. Мы назовем генератор `my_helper`:

```bash
$ bin/rails generate generator rails/my_helper
      create  lib/generators/rails/my_helper
      create  lib/generators/rails/my_helper/my_helper_generator.rb
      create  lib/generators/rails/my_helper/USAGE
      create  lib/generators/rails/my_helper/templates
      invoke  test_unit
      create    test/lib/generators/rails/my_helper_generator_test.rb
```

И в `lib/generators/rails/my_helper/my_helper_generator.rb` мы определим генератор как:

```ruby
class Rails::MyHelperGenerator < Rails::Generators::NamedBase
  def create_helper_file
    create_file "app/helpers/#{file_name}_helper.rb", <<~RUBY
      module #{class_name}Helper
        # I'm helping!
      end
    RUBY
  end
end
```

Наконец, необходимо сообщить Rails использовать генератор `my_helper` вместо встроенного генератора `helper`. Для этого мы используем `config.generators`. В `config/application.rb` добавим:

```ruby
config.generators do |g|
  g.helper :my_helper
end
```

Теперь, если мы снова запустим генератор скаффолда, мы увидим генератор `my_helper` в действии:

```bash
$ bin/rails generate scaffold Article body:text
      ...
      invoke  scaffold_controller
      ...
      invoke    my_helper
      create      app/helpers/articles_helper.rb
      ...
```

NOTE: Можно отметить, что вывод для встроенного генератора `helper` включает "invoke test_unit", а вывод для `my_helper` нет. Хотя генератор `helper` не генерирует тесты по умолчанию, он предоставляет хук для этого с помощью [`hook_for`][]. Мы можем сделать то же самое, включив `hook_for :test_framework, as: :helper` в класс `MyHelperGenerator`. Подробнее смотрите в документации по `hook_for`.

[`config.generators`]: configuring.html#configuring-generators
[`hook_for`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html#method-c-hook_for

### Фолбэки генераторов

Другим способом переопределить определенные генераторы является использование _фолбэков_. Фолбэк позволяет пространству имен генератора делегировать пространству имен другого генератора.

Скажем, к примеру, что мы хотим переопределить генератор `test_unit:model` нашим собственным генератором `my_test_unit:model`, но мы не хотим заменять все другие генераторы `test_unit:*`, такие как `test_unit:controller`.

Сначала мы создадим генератор `my_test_unit:model` в `lib/generators/my_test_unit/model/model_generator.rb`:

```ruby
module MyTestUnit
  class ModelGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    def do_different_stuff
      say "Doing different stuff..."
    end
  end
end
```

Затем используем `config.generators` для конфигурации генератора `test_framework` как `my_test_unit`, но мы также сконфигурируем фолбэк, что любые отсутствующие генераторы `my_test_unit:*` будут разрешаться как `test_unit:*`:

```ruby
config.generators do |g|
  g.test_framework :my_test_unit, fixture: false
  g.fallbacks[:my_test_unit] = :test_unit
end
```

Теперь, когда мы запустим генератор скаффолда, мы увидим, что `my_test_unit` заменил `test_unit`, но были затронуты только тесты модели:

```bash
$ bin/rails generate scaffold Comment body:text
      invoke  active_record
      create    db/migrate/20230518000000_create_comments.rb
      create    app/models/comment.rb
      invoke    my_test_unit
    Doing different stuff...
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
      create      app/views/comments/_comment.html.erb
      invoke    resource_route
      invoke    my_test_unit
      create      test/controllers/comments_controller_test.rb
      create      test/system/comments_test.rb
      invoke    helper
      create      app/helpers/comments_helper.rb
      invoke      my_test_unit
      invoke    jbuilder
      create      app/views/comments/index.json.jbuilder
      create      app/views/comments/show.json.jbuilder
```

Шаблоны приложения
------------------

Шаблоны приложения это специальный тип генератора. Они могут использовать все [вспомогательные методы генератора](#generator-helper-methods), но написаны как скрипт Ruby вместо класса Ruby. Вот пример:

```ruby
# template.rb

if yes?("Would you like to install Devise?")
  gem "devise"
  devise_model = ask("What would you like the user model to be called?", default: "User")
end

after_bundle do
  if devise_model
    generate "devise:install"
    generate "devise", devise_model
    rails_command "db:migrate"
  end
  git add: ".", commit: %(-m 'Initial commit')
end
```

Сначала шаблон спрашивает пользователя, желает ли он установить Devise. Если пользователь отвечает "yes" (или "y"), шаблон добавит Devise в `Gemfile`, спрашивая пользователя об имени модели пользователя Devise (по умолчанию `User`). Затем, после запуска `bundle install`, шаблон запустит генераторы Devise и `rails db:migrate`, если была указана модель Devise. Наконец, шаблон выполнит `git add` и `git commit` для всей директории приложения.

Наш шаблон можно запустить при генерации нового приложения Rails, передав опцию `-m` к команде `rails new`:

```bash
$ rails new my_cool_app -m path/to/template.rb
```

Альтернативно можно запустить наш шаблон внутри существующего приложения с помощью `bin/rails app:template`:

```bash
$ bin/rails app:template LOCATION=path/to/template.rb
```

Также шаблоны не обязательно хранить локально — можно указать URL вместо пути:

```bash
$ rails new my_cool_app -m http://example.com/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

Вспомогательные методы генератора
---------------------------------

Thor предоставляет множество вспомогательным методам генератора посредством [`Thor::Actions`][], таких как:

* [`copy_file`][]
* [`create_file`][]
* [`gsub_file`][]
* [`insert_into_file`][]
* [`inside`][]

В дополнение к этому, Rails также предоставляет множество вспомогательных методов посредством [`Rails::Generators::Actions`][], таких как:

* [`environment`][]
* [`gem`][]
* [`generate`][]
* [`git`][]
* [`initializer`][]
* [`lib`][]
* [`rails_command`][]
* [`rake`][]
* [`route`][]

[`Rails::Generators::Actions`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html
[`environment`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-environment
[`gem`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-gem
[`generate`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-generate
[`git`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-git
[`gsub_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#gsub_file-instance_method
[`initializer`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-initializer
[`insert_into_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#insert_into_file-instance_method
[`inside`]: https://www.rubydoc.info/gems/thor/Thor/Actions#inside-instance_method
[`lib`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-lib
[`rails_command`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-rails_command
[`rake`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-rake
[`route`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-route