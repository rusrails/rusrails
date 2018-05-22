Основы создания плагинов Rails
==============================

Плагин Rails - это либо расширение, либо модификация основного фреймворка. Плагины представляют:

* Способ для разработчиков делиться новыми идеями без затрагивания стабильной кодовой базы.
* Сегментную архитектуру, такую, что часть кода может быть исправлена или изменена по своему собственному графику.
* Решение для разработчиков ядра приложения, чтобы не включать каждую новую особенность в свой код.

После прочтения этого руководства, вы узнаете:

* Как создать плагин с нуля.
* Как написать и запустить тесты для плагина.

Это руководство описывает, как создать плагин, движимый тестами (TDD), который будет:

* Расширять классы ядра Ruby, такие как Hash и String.
* Добавлять методы в `ApplicationRecord` в традициях плагинов `acts_as`.
* Представлять информацию о том, где разместить генераторы в вашем плагине.

Для целей этого руководства представьте на момент, что вы заядлый любитель птиц. Вашей любимой птицей является дятел (Yaffle), и вы хотите создать плагин, позволяющий другим разработчикам пользоваться особенностями дятлов.

Настройка
---------

В настоящее время плагины Rails создаются как гемы (_gemified plugins_). Они могут использоваться сразу несколькими приложениями Rails с помощью RubyGems и Bundler.

### Создание гема.

Rails поставляется с командой `rails plugin new`, создающей скелет для разработки любого типа расширения Rails со способностью запуска интеграционных тестов с помощью приложения-заглушки Rails. Создайте свой плагин с помощью команды:

```bash
$ rails plugin new yaffle
```

Как ее использовать и ее опции смотрите:

```bash
$ rails plugin new --help
```

Тестирование своего нового плагина
----------------------------------

Можете перейти в директорию, содержащую плагин, запустить команду `bundle install`, и запустить сгенерированный тест с использованием команды `bin/test`.

Вы должны увидеть:

```bash
  1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

Это сообщает, что все сгенерировалось правильно, и можно начать добавлять функциональность.

Расширение классов ядра
-----------------------

Этот раздел объясняет, как добавить метод в String, который будет доступен везде в вашем приложении Rails.

В следующем примере мы добавим метод в String с именем `to_squawk`. Для начала создайте новый файл теста с несколькими утверждениями:

```ruby
# yaffle/test/core_ext_test.rb

require "test_helper"

class CoreExtTest < ActiveSupport::TestCase
  def test_to_squawk_prepends_the_word_squawk
    assert_equal "squawk! Hello World", "Hello World".to_squawk
  end
end
```

Запустите `bin/test` для запуска теста. Этот тест должен провалиться, так как мы еще не реализовали метод `to_squawk`:

```bash
E

Error:
CoreExtTest#test_to_squawk_prepends_the_word_squawk:
NoMethodError: undefined method `to_squawk' for "Hello World":String


bin/test /path/to/yaffle/test/core_ext_test.rb:4

.

Finished in 0.003358s, 595.6483 runs/s, 297.8242 assertions/s.

2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

Отлично - теперь мы готовы начать разработку.

В `lib/yaffle.rb` добавьте `require "yaffle/core_ext"`:

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/railtie"
require "yaffle/core_ext"

module Yaffle
  # Тут какой-нибудь код...
end
```

Наконец, создайте файл `core_ext.rb` и добавьте метод `to_squawk`:

```ruby
# yaffle/lib/yaffle/core_ext.rb

class String
  def to_squawk
    "squawk! #{self}".strip
  end
end
```

Чтобы проверить, что этот метод делает то, что нужно, запустите юнит-тесты с помощью `bin/test` из директории плагина.

```bash
  2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
```

Чтобы увидеть его в действии, измените директорию на `test/dummy`, запустите консоль и начните squawking:

```bash
$ bin/rails console
>> "Hello World".to_squawk
=> "squawk! Hello World"
```

Добавление метода "acts_as" в Active Record
----------------------------------------

Обычным паттерном для плагинов является добавление в модель метода с именем `acts_as_something`. В нашем случае мы хотим написать метод с именем `acts_as_yaffle`, добавляющий метод `squawk` в модель Active Record.

Для начала настройте свои файлы, вам нужны:

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
end
```

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/railtie"
require "yaffle/core_ext"
require "yaffle/acts_as_yaffle"

module Yaffle
  # Тут какой-нибудь код...
end
```

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
  end
end
```

### Добавление метода класса

Этот плагин ожидает, что мы добавим в модель метод с именем `last_squawk`. Однако, у пользователей плагина уже может быть определен метод в модели `last_squawk`, который они используют для чего-то иного. Этот плагин позволит имени быть измененным, добавив метод класса `yaffle_text_field`.

Для начала напишем падающий тест, показывающий нужное нам поведение:

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end
end
```

При запуске `bin/test` вы увидите следующее:

```
# Running:

..E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NameError: uninitialized constant ActsAsYaffleTest::Wickwall

bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NameError: uninitialized constant ActsAsYaffleTest::Hickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4



Finished in 0.004812s, 831.2949 runs/s, 415.6475 assertions/s.

4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

Это сообщает нам об отсутствии необходимых моделей (Hickwall и Wickwall), которые мы пытаемся протестировать. Эти модели можно с легкостью создать в нашем "dummy" приложении Rails, запустив следующие команды в директории `test/dummy`:

```bash
$ cd test/dummy
$ bin/rails generate model Hickwall last_squawk:string
$ bin/rails generate model Wickwall last_squawk:string last_tweet:string
```

Теперь можно создать необходимые таблицы в вашей тестовой базе данных, перейдя в приложение-заглушку и мигрировав базу данных. Сначала запустите:

```bash
$ cd test/dummy
$ bin/rails db:migrate
```

Пока вы тут, измените модели Hickwall и Wickwall так, чтобы они знали, что они должны действовать как дятлы.

```ruby
# test/dummy/app/models/hickwall.rb

class Hickwall < ApplicationRecord
  acts_as_yaffle
end

# test/dummy/app/models/wickwall.rb

class Wickwall < ApplicationRecord
  acts_as_yaffle yaffle_text_field: :last_tweet
end
```

Также добавим код, определяющий метод `acts_as_yaffle`.

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
      end
    end
  end
end

# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

Затем можно вернуться в корневую директорию плагина (`cd ../..`) и перезапустить тесты с помощью `bin/test`.

```
# Running:

.E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974ebbe9d8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4

E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974eb8cfc8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

.

Finished in 0.008263s, 484.0999 runs/s, 242.0500 assertions/s.

4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

Подбираемся ближе... Теперь мы реализуем код метода `acts_as_yaffle`, чтобы тесты проходили.

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end

# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

Когда запустите `bin/test`, все тесты должны пройти:

```bash
  4 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### Добавление метода экземпляра

Этот плагин добавит метод 'squawk' в любой объект Active Record, который вызовет `acts_as_yaffle`. Метод 'squawk' просто установит значение одному из полей в базе данных.

Для начала напишем падающий тест, показывающий желаемое поведение:

```ruby
# yaffle/test/acts_as_yaffle_test.rb
require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end

  def test_hickwalls_squawk_should_populate_last_squawk
    hickwall = Hickwall.new
    hickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", hickwall.last_squawk
  end

  def test_wickwalls_squawk_should_populate_last_tweet
    wickwall = Wickwall.new
    wickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", wickwall.last_tweet
  end
end
```

Запустите тест, чтобы убедиться, что последние два теста упадут с ошибкой, содержащей "NoMethodError: undefined method `squawk'", затем обновите `acts_as_yaffle.rb`, чтобы он выглядел так:

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    included do
      def squawk(string)
        write_attribute(self.class.yaffle_text_field, string.to_squawk)
      end
    end

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s

      end
    end
  end
end

# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

Запустите `bin/test` в последний раз, вы должны увидеть:

```
  6 runs, 6 assertions, 0 failures, 0 errors, 0 skips
```

NOTE: Использование `write_attribute` для записи в поле модели - это всего лишь пример того, как плагин может взаимодействовать с моделью, но не всегда правильный метод для использования. Например, также можно использовать:

```ruby
send("#{self.class.yaffle_text_field}=", string.to_squawk)
```

Генераторы
----------

Генераторы могут быть включены в гем простым добавлением в директорию `lib/generators` плагина. Подробнее о создании генераторов смотрите в руководстве [Создание и настройка генераторов и шаблонов Rails](/generators).

Публикация вашего гема
----------------------

Плагины в виде гемов, которые в текущий момент в разработке, могут с легкостью быть доступны из любого репозитория Git. Чтобы поделиться гемом Yaffle с другими, просто передайте код в репозиторий Git (такой как GitHub) и добавьте строчку в `Gemfile` требуемого приложения:

```ruby
gem "yaffle", git: "https://github.com/rails/yaffle.git"
```

После запуска `bundle install` функциональность гема будет доступна в приложении.

Когда гем готов к официальному релизу, он может быть опубликован на [RubyGems](https://rubygems.org). Подробнее о публикации гемов на RubyGems смотрите: [Publishing your gem](http://guides.rubygems.org/publishing)

Документация RDoc
-----------------

Как только ваш плагин станет стабильным, и вы будете готовы его разместить, сделайте хорошее дело, документировав его! К счастью, написание документации для вашего плагина - это очень просто.

Первым шагом является обновление файла README детальной информацией о том, как использовать ваш плагин. Ключевые вещи, которые следует включить, следующие:

* Ваше имя
* Как установить
* Как добавить функциональность в приложение (несколько примеров обычных ситуаций использования)
* Предупреждения, хитрости или подсказки, которые могут помочь пользователям и сохранить их время

Как только README готов, пройдитесь и добавьте комментарии rdoc ко всем методам, которые будут использовать разработчики. Также принято добавить комментарии `#:nodoc:` к тем частям кода, которые не включены в публичный API.

Как только ваши комментарии закончены, перейдите в директорию плагины и запустите:

```bash
$ bundle exec rake rdoc
```

### Ссылки

* [Developing a RubyGem using Bundler](https://github.com/radar/guides/blob/master/gem-development.md)
* [Using .gemspecs as Intended](http://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/)
* [Gemspec Reference](http://guides.rubygems.org/specification-reference/)
