# Настройка файлопровода

### Сжатие CSS

Имеется всего один вариант для сжатия CSS, YUI. [YUI CSS compressor](http://developer.yahoo.com/yui/compressor/css.html) представляет минификацию.

Следующая строка включает сжатие YUI и требует гем `yui-compressor`.

```ruby
config.assets.css_compressor = :yui
```

`config.assets.compress` должна быть установлена в `true`, чтобы включить сжатие CSS.

### Сжатие JavaScript

Возможные варианты для сжатия JavaScript это `:closure`, `:uglifier` and `:yui`. Они требуют использование гемов `closure-compiler`, `uglifier` или `yui-compressor` соответственно.

Gemfile по умолчанию включает [uglifier](https://github.com/lautis/uglifier). Этот гем оборачивает [UglifierJS](https://github.com/mishoo/UglifyJS) (написанный для) в Ruby. Он сжимает ваш код, убирая пробелы. Он также включает иные операции, наподобие замены ваших выражений `if` и `else` на тренарные операторы там, где возможно.

Следующая строка вызывает `uglifier` для сжатия JavaScript.

```ruby
config.assets.js_compressor = :uglifier
```

Отметьте, что `config.assets.compress` должна быть установлена `true`. чтобы включить сжатие JavaScript

NOTE: Необходим runtime, поддерживаемый [ExecJS](https://github.com/sstephenson/execjs#readme), чтобы использовать `uglifier`. Если используете Mac OS X или Windows, у вас уже имеется JavaScript runtime, установленный в операционной системе. Обратитесь к документации по [ExecJS](https://github.com/sstephenson/execjs#readme), чтобы узнать обо всех поддерживаемых JavaScript runtime-ах.

### Использование собственного компрессора

Настройки конфигурации компрессора для CSS и JavaScript также могут принимать любой объект. Этот объект должен иметь метод `compress`, принимающий строку как единственный аргумент, и он должен возвращать строку.

```ruby
class Transformer
  def compress(string)
    do_something_returning_a_string(string)
  end
end
```

Чтобы его включить, передайте `new` объект в настройку конфигурации в `application.rb`:

```ruby
config.assets.css_compressor = Transformer.new
```

### Изменение пути _assets_

Публичный путь, используемый Sprockets по умолчанию, это `/assets`.

Он может быть заменен на что-то другое:

```ruby
config.assets.prefix = "/some_other_path"
```

Это удобная опция, если вы обновляете существующий проект (до Rails 3.1), уже использующий этот путь, или вы хотите использовать этот путь для нового ресурса.

### Заголовки X-Sendfile

Заголовок X-Sendfile это указание веб-серверу игнорировать отклик от приложения, и вместо этого отдать определенный файл с диска. Эта опция отключена по умолчанию, но может быть включена, если ее поддерживает сервер. Когда опция включена, обязанность по отдаче файла передается веб-серверу, который быстрее.

Apache и nginx поддерживают эту опцию, которая включается в `config/environments/production.rb`.

```ruby
# config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
# config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx
```

WARNING: Если вы обновляете свое существующее приложение и намереваетесь использовать эту опцию, убедитесь, что скопировали эту опцию только в `production.rb` и в любую другую среду, которую вы определили, как имеющую поведение production (не в `application.rb`).
