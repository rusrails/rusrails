Шаблоны приложения Rails
========================

Шаблоны приложений - это простые Ruby файлы, содержащие DSL для добавления гемов/инициализаторов и т.п. в ваш только что созданный или существующий Rails проект.

После прочтения данного руководства, вы узнаете:

* Как использовать шаблоны для создания/настройки Rails приложений.
* Как написать свои собственные шаблоны, которые можно будет использовать повторно, используя Rails API для шаблонов.

--------------------------------------------------------------------------------

Использование
-------------

Чтобы применить шаблон, вам необходимо запустить генератор Rails с расположением шаблона, который вы хотите применить, используя опцию `-m`. Это может быть путь к файлу или URL.

```bash
$ rails new blog -m ~/template.rb
$ rails new blog -m http://example.com/template.rb
```

Вы можете использовать команду rails `app:template` чтобы применить шаблоны к существующему Rails приложению. Место расположения шаблона должно быть передано с помощью переменной среды LOCATION. Опять же, это может быть путь к файлу или URL.

```bash
$ rails app:template LOCATION=~/template.rb
$ rails app:template LOCATION=http://example.com/template.rb
```

API для шаблонов
----------------

Rails API для шаблонов легок для понимания. Ниже пример типичного шаблона Rails:

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rails_command("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

В следующих разделах рассматриваются основные методы, предоставленные API:

### `gem(*args)`

Добавляет запись `gem` для предоставляемого гема в генерируемый для приложения `Gemfile`.

Например, если ваше приложение зависит от гемов `bj` и `nokogiri`:

```ruby
gem "bj"
gem "nokogiri"
```

Пожалуйста, отметьте, что это не установит гемы и вы должны будете запустить `bundle install` для этого.

```bash
bundle install
```

### `gem_group(*names, &block)`

Оборачивает записи гемов внутрь группы.

Например, если вы хотите загружать `rspec-rails` только в группах `development` и `test`:

```ruby
gem_group :development, :test do
  gem "rspec-rails"
end
```

### `add_source(source, options={}, &block)`

Добавляет переданный источник в генерируемый для приложения `Gemfile`.

Например, если вам необходим источник гема `"http://code.whytheluckystiff.net"`:

```ruby
add_source "http://code.whytheluckystiff.net"
```

Если передан блок, то записи гемов в блоке будут обернуты в группу с источником.

```ruby
add_source "http://gems.github.com/" do
  gem "rspec-rails"
end
```

### `environment/application(data=nil, options={}, &block)`

Добавляет строчку внутрь класса `Application` в `config/application.rb`.

Если указана `options[:env]`, строчка добавляется в соответствующий файл в `config/environments`.

```ruby
environment 'config.action_mailer.default_url_options = {host: "http://yourwebsite.example.com"}', env: 'production'
```

Блок может использоваться вместо аргумента `data`.

### `vendor/lib/file/initializer(filename, data = nil, &block)`

Добавляет инициализатор в папку `config/initializers` генерируемого приложения.

Допустим, вам нравится использовать `Object#not_nil?` и `Object#not_blank?`:

```ruby
initializer 'bloatlol.rb', <<-CODE
  class Object
    def not_nil?
      !nil?
    end

    def not_blank?
      !blank?
    end
  end
CODE
```

Аналогично, `lib()` создает файл в папке `lib/`, и `vendor()` создает файл в папке `vendor/`.

Есть даже `file()`, который принимает относительный путь от `Rails.root` и создает все необходимые папки/файлы:

```ruby
file 'app/components/foo.rb', <<-CODE
  class Foo
  end
CODE
```

Это создаст папку `app/components` и поместит в нее `foo.rb`.

### `rakefile(filename, data = nil, &block)`

Создает новый rake файл в `lib/tasks` с предоставленной задачей:

```ruby
rakefile("bootstrap.rake") do
  <<-TASK
    namespace :boot do
      task :strap do
        puts "i like boots!"
      end
    end
  TASK
end
```

Код выше создаст `lib/tasks/bootstrap.rake` с rake задачей `boot:strap`.

### `generate(what, *args)`

Запускает предоставленный генератор rails с переданными аргументами.

```ruby
generate(:scaffold, "person", "name:string", "address:text", "age:number")
```

### `run(command)`

Выполняет произвольную команду, как открывающая кавычка. Допустим, вы хотите удалить файл `README.rdoc`:

```ruby
run "rm README.rdoc"
```

### `rails_command(command, options = {})`

Запускает предоставленную команду в Rails приложении. Допустим, вы хотите запустить миграции базы данных:

```ruby
rails_command "db:migrate"
```

Вы также можете запустить команды с разными Rails окружениями:

```ruby
rails_command "db:migrate", env: 'production'
```

Вы также можете запустить команды как супер-пользователь:

```ruby
rails_command "log:clear", sudo: true
```

### `route(routing_code)`

Добавляет запись маршрутизации в файл `config/routes.rb`. В шагах выше мы сгенерировали скаффолд для person и также удалили `README.rdoc`. Сейчас, сделаем для приложения `PeopleController#index` страницей по умолчанию:

```ruby
route "root to: 'person#index'"
```

### `inside(dir)`

Позволяет вам запускать команды из данного каталога. Например, если у вас есть копия крайних rails, и вы хотите сделать ссылку из вашего нового приложения, вы можете сделать:

```ruby
inside('vendor') do
  run "ln -s ~/commit-rails/rails rails"
end
```

### `ask(question)`

`ask()` дает вам шанс получить некоторую обратную связь от пользователя и использовать ее в ваших шаблонах. Допустим, вы хотите, чтобы ваши пользователи дали название новой блестящей библиотеке, вы добавляете:

```ruby
lib_name = ask("What do you want to call the shiny library ?")
lib_name << ".rb" unless lib_name.index(".rb")

lib lib_name, <<-CODE
  class Shiny
  end
CODE
```

### `yes?(question) or no?(question)`

Эти методы позволяют вам задать вопросы из ваших шаблонов и принять решение в процессе в зависимости от ответа пользователя. Допустим, вы хотите заморозить Rails, только если пользователь хочет:

```ruby
rails_command("rails:freeze:gems") if yes?("Freeze rails gems?")
# no?(question) acts just the opposite.
```

### `git(:command)`

Шаблоны Rails позволяют вам запускать любую команду git:

```ruby
git :init
git add: "."
git commit: "-a -m 'Initial commit'"
```

### `after_bundle(&block)`

Регистрирует колбэк, который будет выполняться после того, как гемы были упакованы и бинстабы сгенерированы. Полезно для всех генерируемых файлов в системе контроля версий:

```ruby
after_bundle do
  git :init
  git add: '.'
  git commit: "-a -m 'Initial commit'"
end
```

Колбэки выполняется, даже если `--skip-bundle` и/или `--skip-spring` были переданы.

Продвинутое использование
-------------------------

Шаблон приложения вычисляется в контексте экземпляра `Rails::Generators::AppGenerator`. Используется экшн `apply`, предоставленное [Thor](https://github.com/erikhuda/thor/blob/master/lib/thor/actions.rb#L207).
Это означает, что вы можете расширить и изменить экземпляр в соответствии с вашими потребностями.

Например, переписать метод `source_paths`, чтобы он содержал место расположения шаблона. Сейчас методы, такие как `copy_file`, будут принимать относительные пути по отношению к месту расположения шаблону.

```ruby
def source_paths
  [__dir__]
end
```
