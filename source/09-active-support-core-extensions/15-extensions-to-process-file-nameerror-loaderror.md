# Расширения для File, Marshal, Logger, NameError, LoadError

Расширения для `File`
---------------------

### `atomic_write`

С помощью метода класса `File.atomic_write` можно записать в файл способом, предотвращающим от просмотра недописанного содержимого.

Имя файла передается как аргумент, и в метод вкладываются обработчики файла, открытого для записи. Как только блок выполняется, `atomic_write` закрывает файл и завершает свою работу.

Например, Action Pack использует этот метод для записи активных файлов кэша, таких как `all.css`:

```ruby
File.atomic_write(joined_asset_path) do |cache|
  cache.write(join_asset_file_contents(asset_paths))
end
```

Для выполнения этого `atomic_write` создает временный файл. Фактически код в блоке пишет в этот файл. При выполнении временный файл переименовывается, что является атомарной операцией в системах POSIX. Если целевой файл существует, `atomic_write` перезаписывает его и сохраняет владельцев и права. Однако в некоторых случаях `atomic_write` не может изменить владельца или права на файл, эта ошибка отлавливается и пропускается, позволяя файловой системе убедиться, что файл доступен для необходимых действий.

NOTE. Благодаря операции chmod, выполняемой `atomic_write`, если у целевого файла установлен ACL, то этот ACL будет пересчитан/изменен.

WARNING. Отметьте, что с помощью `atomic_write` нельзя дописывать.

Вспомогательный файл записывается в стандартной директории для временных файлов, но можно передать эту директорию как второй аргумент.

NOTE: Определено в `active_support/core_ext/file/atomic.rb`.

Расширения для `Marshal`
-----------------------

### `load`

Active Support добавляет поддержку постоянной автозагрузки для `load`.

Например, хранилище кэша в файле десериализует следующим образом:

```ruby
File.open(file_name) { |f| Marshal.load(f) }
```

Если закэшированные данные обращаются к константе6 которая неизвестна в данный момент, включается механизм автозагрузки и, если он успешен, перевыполняется десериализация.

WARNING. Если аргумент `IO`, необходимо, чтобы он отвечал на `rewind`, чтобы быть способным на повтор. Обычные файлы отвечают на `rewind`.

NOTE: Определено в `active_support/core_ext/marshal.rb`.

Расширения для `Logger`
-----------------------

### `around_[level]`

Принимает два аргумента, `before_message` и `after_message`, и вызывает метод текущего уровня в экземпляре `Logger`, передавая `before_message`, затем определенное сообщение, затем `after_message`:

```ruby
logger = Logger.new("log/development.log")
logger.around_info("before", "after") { |logger| logger.info("during") }
```

### `silence`

Заглушает каждый уровень лога, меньший чем определенный, на протяжении заданного блока. Порядок уровня логов следующий: debug, info, error и fatal.

```ruby
logger = Logger.new("log/development.log")
logger.silence(Logger::INFO) do
  logger.debug("In space, no one can hear you scream.")
  logger.info("Scream all you want, small mailman!")
end
```

### `datetime_format=`

Изменяет формат вывода datetime с помощью класса форматирования, связанного с этим логером. Если у класса форматирования нет метода `datetime_format`, то он будет проигнорирован.

```ruby
class Logger::FormatWithTime < Logger::Formatter
  cattr_accessor(:datetime_format) { "%Y%m%d%H%m%S" }

  def self.call(severity, timestamp, progname, msg)
    "#{timestamp.strftime(datetime_format)} - #{String === msg ? msg : msg.inspect}\n"
  end
end

logger = Logger.new("log/development.log")
logger.formatter = Logger::FormatWithTime
logger.info("<- is the current time")
```

NOTE: Определено в `active_support/core_ext/logger.rb`.

Расширения для `NameError`
--------------------------

Active Support добавляет `missing_name?` к `NameError`, который тестирует было ли исключение вызвано в связи с тем, что имя было передано как аргумент.

Имя может быть задано как символ или строка. Символ тестируется как простое имя константы, строка - как полное имя константы.

TIP: Символ может представлять полное имя константы как `:"ActiveRecord::Base"`, такое поведение для символов определено для удобства, а не потому, что такое возможно технически.

К примеру, когда вызывается экшн `PostsController`, Rails пытается оптимистично использовать `PostsHelper`. Это нормально, когда не существует модуля хелпера, поэтому если вызывается исключение для этого имени константы, оно должно молчать. Но в случае, если `posts_helper.rb` вызывает `NameError` благодаря неизвестной константе, оно должно быть перевызвано. Метод `missing_name?` предоставляет способ проведения различия в этих двух случаях:

```ruby
def default_helper_module!
  module_name = name.sub(/Controller$/, '')
  module_path = module_name.underscore
  helper module_path
rescue MissingSourceFile => e
  raise e unless e.is_missing? "#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

NOTE: Определено в `active_support/core_ext/name_error.rb`.

Расширения для `LoadError`
--------------------------

Active Support добавляет `is_missing?` к `LoadError`, а также назначает этот класс константе `MissingSourceFile` для обеспечения обратной совместимости.

Для заданного имени пути `is_missing?` тестирует, будет ли вызвано исключение из-за определенного файла (за исключением файлов с расширением ".rb").

Например, когда вызывается экшн `PostsController`, Rails пытается загрузить `posts_helper.rb`, но этот файл может не существовать. Это нормально, модуль хелпера не обязателен, поэтому Rails умалчивает ошибку загрузки. Но может быть случай, что модуль хелпера существует, и в свою очередь требует другую библиотеку, которая отсутствует. В этом случае Rails должен перевызвать исключение. Метод `is_missing?` предоставляет способ проведения различия в этих двух случаях:

```ruby
def default_helper_module!
  module_name = name.sub(/Controller$/, '')
  module_path = module_name.underscore
  helper module_path
rescue MissingSourceFile => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

NOTE: Определено в `active_support/core_ext/load_error.rb`.
