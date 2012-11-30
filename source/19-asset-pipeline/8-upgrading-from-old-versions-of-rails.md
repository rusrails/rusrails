# Обновление со старых версий Rails

Имеются несколько проблем при обновлении. Первая это перемещение файлов из `public/` в новые места размещения. Смотрите [Организация ресурсов](/asset-pipeline/how-to-use-the-asset-pipeline) ранее в руководстве для правильного размешения файлов разных типов.

Следующей является избегание дублирования файлов JavaScript. Так как jQuery является библиотекой JavaScript по умолчанию, начиная с Rails 3.1 и далее, не нужно купировать `jquery.js` в `app/assets`, он будет включен автоматически.

Третья это обновление файлов различных сред с правильными значениями по умолчанию. Следующие изменения отражают значения по умолчанию в версии 3.1.0.

В `application.rb`:

```ruby
# Включить файлопровод
config.assets.enabled = true

# Версия ваших ресурсов, измените ее, если хотие, чтобы срок существующих ресурсов истек
config.assets.version = '1.0'

# Измените путь, откуда отдаются ресурсы
# config.assets.prefix = "/assets"
```

В `development.rb`:

```ruby
# Не сжимать ресурсы
config.assets.compress = false

# Разворачивать строки, загружающие ресурсы the lines which load the assets
config.assets.debug = true
```

И в `production.rb`:

```ruby
# Сжимать JavaScripts и CSS
config.assets.compress = true

# Выбрать используемый компрессор
# config.assets.js_compressor  = :uglifier
# config.assets.css_compressor = :yui

# Не обращаться к файлопроводу, если отсутствует прекомпилированный ресурс
config.assets.compile = false

# Создавать дайджесты для URL ресурсов.
config.assets.digest = true

# По умолчанию nil и сохраняется в расположении, определенном с помощью config.assets.prefix
# config.assets.manifest = YOUR_PATH

# Прекомпилировать дополнительные ресурсы (application.js, application.css и все не-JS/CSS уже добавлены)
# config.assets.precompile `= %w( search.js )
```

Не нужно изменять `test.rb`. По умолчанию в среде test: `config.assets.compile` равно true и `config.assets.compress`, `config.assets.debug` и `config.assets.digest` равны false.

Следующее также должно быть добавлено в `Gemfile`:

```ruby
# Гемы, используемые только для ресурсов и не требуемые
# в среде production по умолчанию.
group :assets do
  gem 'sass-rails',   "~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier'
end
```

Если используете группу `assets` с Bundler, убедитесь, что в вашем `config/application.rb` имеется следующее выражение Bundler require.

```ruby
if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end
```

Вместо старого из Rails версии 3.0

```ruby
# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)
```
