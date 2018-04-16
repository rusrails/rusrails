Тестирование приложений на Rails
================================

Это руководство раскрывает встроенные в Rails механизмы для тестирования вашего приложения.

После его прочтения, вы узнаете:

* О терминологии тестирования Rails.
* Как писать юнит-, функциональные, интеграционные и системные тесты для вашего приложения.
* О других популярных подходах к тестированию и плагинах.

Зачем писать тесты для приложения на Rails?
-------------------------------------------

Rails предлагает писать тесты очень просто. Когда вы создаете свои модели и контроллеры, он начинает создавать скелет тестового кода.

Запуск тестов Rails позволяет убедиться, что ваш код придерживается нужной функциональности даже после большой переделки кода.

Тесты Rails также могут симулировать запросы браузера, таким образом, можно тестировать отклик своего приложения без необходимости тестирования с использованием браузера.

Введение в тестирование
-----------------------

Поддержка тестирования встроена в Rails с самого начала. И это не было так: "О! Давайте внесем поддержку запуска тестов, это ново и круто!"

### Настройка Rails для тестирования с нуля

Rails создает директорию `test` как только вы создаете проект Rails, используя `rails new _application_name_`. Если посмотрите список содержимого этой папки, то увидите:

```bash
$ ls -F test

controllers/           helpers/               mailers/               system/                test_helper.rb
fixtures/              integration/           models/                application_system_test_case.rb
```

Директории `helpers`, `mailers` и `models` предназначены содержать тесты для хелперов вьюх, рассыльщиков и моделей соответственно. Директория `controllers` предназначена содержать тесты для ваших контроллеров, маршрутов и вьюх. Директория `integration` предназначена содержать тесты для взаимодействия между контроллерами.

Директория `system` содержит системные тесты, используемые для полного браузерного тестирования вашего приложения. Системные тесты позволяют тестировать приложение так, как ваши пользователи взаимодействуют с ним, а также тестировать ваш JavaScript. Системные тесты наследуются от Capybara и выполняются в браузере.

Фикстуры это способ организации тестовых данных; они находятся в директории `fixtures`.

Также будет создана директория `jobs`, как только первый связанные тест будет сгенерирован.

Файл `test_helper.rb` содержит конфигурацию по умолчанию для ваших тестов.

`application_system_test_case.rb` содержит настройки по умолчанию для ваших системных тестов.

### Тестовая среда разработки

По умолчанию каждое приложение на Rails имеет три среды разработки: development, test и production. База данных для каждой из них настраивается в `config/database.yml`.

Схожим образом можно модифицировать конфигурацию среды. В этом случае можно модифицировать тестовую среду, изменяя опции в `config/environments/test.rb`.

NOTE: Ваши тесты запускаются с `RAILS_ENV=test`.

### Rails встретился с Minitest

Если помните, мы использовали команду `rails generate model` в руководстве [Rails для начинающих](/getting-started-with-rails). Мы создали нашу первую модель, где, среди прочего, создались незаконченные тесты в папке `test`:

```bash
$ bin/rails generate model article title:string body:text
...
create  app/models/article.rb
create  test/models/article_test.rb
create  test/fixtures/articles.yml
...
```

Незаконченный тест по умолчанию в `test/models/article_test.rb` выглядит так:

```ruby
require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
```

Построчное изучение этого файла поможет ориентироваться в коде тестирования и терминологии Rails.

```ruby
require 'test_helper'
```

Требуя этот файл, загружается конфигурация по умолчанию `test_helper.rb` для запуска наших тестов. Мы будем включать эту строку во все написанные тесты, таким образом, все методы, добавленные в этот файл, будут доступны во всех наших тестах.

```ruby
class ArticleTest < ActiveSupport::TestCase
```

Класс `ArticleTest` определяет _тестовый случай_, поскольку он унаследован от `ActiveSupport::TestCase`. Поэтому `ArticleTest` имеет все методы, доступные в `ActiveSupport::TestCase`. Позже в этом руководстве мы увидим некоторые из методов, которые он нам дает.

Любой метод, определенный в классе, унаследованном от `Minitest::Test` (который является суперклассом для `ActiveSupport::TestCase`), начинающийся с `test_` (чувствительно к регистру), просто вызывает тест. Таким образом, методы, определенные как `test_password` и `test_valid_password`, это правильные имена тестов, и запустятся автоматически при запуске тестового случая.

Rails также добавляет метод `test`, который принимает имя теста и блок. Он генерирует обычный тест `MiniTest::Unit` с именем метода, начинающегося с `test_`, поэтому можно не беспокоиться об именовании методов, а просто писать так:

```ruby
test "the truth" do
  assert true
end
```

Это является приблизительно тем же, как если бы написали:

```ruby
def test_the_truth
  assert true
end
```

Хотя вы все еще можете использовать обычные определения методов, использование макроса `test` позволяет получить более читаемое имя теста.

NOTE: Имя метода генерируется, заменяя пробелы на подчеркивания. Хотя результат не должен быть валидным идентификатором Ruby, имя может содержать знаки пунктуации и т.д. Это связано с тем, что в Ruby технически любая строка может быть именем метода. Это может потребовать, чтобы вызовы `define_method` и `send` функционировали правильно, но формально есть только небольшое ограничение на имя.

Далее посмотрим на наше первое утверждение:

```ruby
assert true
```

Утверждение (assertion) - это строчка кода, которая вычисляет объект (или выражение) для ожидаемых результатов. Например, утверждение может проверить:

* является ли это значение равным тому значению?
* является ли этот объект `nil`?
* вызывает ли эта строчка кода исключение?
* является ли пароль пользователя больше, чем 5 символов?

Каждый тест должен содержать одно или более утверждений, без ограничений на их максимальное количество. Только когда все утверждения успешны, тест проходит.

#### Ваш первый падающий тест

Чтобы увидеть, как сообщается провал теста, вы можете добавить проваливающийся тест в тестовый случай `article_test.rb`.

```ruby
test "should not save article without title" do
  article = Article.new
  assert_not article.save
end
```

Давайте запустим только что добавленный тест (где `6` - это номер строчки, где определен тест).

```bash
$ bin/rails test test/models/article_test.rb:6
Run options: --seed 44656

# Running:

F

Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
Expected true to be nil or false


bin/rails test test/models/article_test.rb:6


Finished in 0.023918s, 41.8090 runs/s, 41.8090 assertions/s.

1 runs, 1 assertions, 1 failures, 0 errors, 0 skips

```

В результате `F` обозначает провал. Можете увидеть соответствующую трассировку под `Failure` вместе с именем провалившегося теста. Следующие несколько строчек содержат трассировку стека, затем сообщение, где упомянуто фактическое значение и ожидаемое в утверждении значение. По умолчанию сообщение для утверждения предоставляет достаточно информации, чтобы помочь выявить ошибку. Чтобы сделать сообщение о провале для утверждения более читаемым, каждое утверждение предоставляет опциональный параметр для сообщения, как показано тут:

```ruby
test "should not save article without title" do
  article = Article.new
  assert_not article.save, "Saved the article without a title"
end
```

Запуск этого теста покажет более дружелюбное сообщение для утверждения:

```bash
Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
Saved the article without a title
```

Теперь, чтобы этот тест прошел, можно добавить валидацию на уровне модели для поля _title_.

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
end
```

Теперь тест пройдет. Давайте убедимся в этом, запустив его снова:

```bash
$ bin/rails test test/models/article_test.rb:6
Run options: --seed 31252

# Running:

.
Finished in 0.027476s, 36.3952 runs/s, 36.3952 assertions/s.

1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

Теперь, если вы заметили, мы сначала написали провальный тест для желаемой функциональности, затем мы написали некоторый код, добавляющий функциональность, и, наконец, мы убедились, что наш тест прошел. Этот подход к разработке программного обеспечения называют [_Разработка через тестирование, Test-Driven Development_ (TDD)](http://c2.com/cgi/wiki?TestDrivenDevelopment).

#### Как выглядит ошибка

Чтобы увидеть, как сообщается об ошибке, вот тест, содержащий ошибку:

```ruby
test "should report error" do
  # переменная some_undefined_variable не определена в другом месте тестового случая
  some_undefined_variable
  assert true
end
```

Теперь вы увидите чуть больше результата в консоли от запуска тестов:

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1808

# Running:

.E

Error:
ArticleTest#test_should_report_error:
NameError: undefined local variable or method 'some_undefined_variable' for #<ArticleTest:0x007fee3aa71798>
    test/models/article_test.rb:11:in 'block in <class:ArticleTest>'


bin/rails test test/models/article_test.rb:9



Finished in 0.040609s, 49.2500 runs/s, 24.6250 assertions/s.

2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

Отметьте 'E' в результате. Она отмечает тест с ошибкой.

NOTE: Выполнение каждого тестового метода останавливается, как только возникают какие-либо ошибки или провал утверждения, и тестовый набор продолжается со следующего метода. Все тестовые методы выполняются в случайном порядке. Для настройки порядка тестирования может быть использована [опция `config.active_support.test_order`](/configuring-rails-applications#configuring-active-support).

Когда тест проваливается, вам показывается соответствующий бэктрейс. По умолчанию Rails фильтрует этот бэктрейс и печатает только строчки, относящиеся к вашему приложению. Это устраняет шум от фреймворка и помогает сфокусироваться на вашем коде. Однако, бывают ситуации, когда вам захочется увидеть полный бэктрейс. Установите аргумент `-b` (или `--backtrace`) для включения этого поведения:

```bash
$ bin/rails test -b test/models/article_test.rb
```

Если хотите, чтобы этот тест прошел, можно его модифицировать, используя `assert_raises` следующим образом:

```ruby
test "should report error" do
  # переменная some_undefined_variable не определена в тесте
  assert_raises(NameError) do
    some_undefined_variable
  end
end
```

Теперь этот тест должен пройти.

### Доступные утверждения

К этому моменту вы уже увидели некоторые из имеющихся утверждений. Утверждения - это рабочие лошадки тестирования. Они единственные, кто фактически выполняет проверки, чтобы убедиться, что все работает как задумано.

Ниже представлена выдержка утверждений, которые вы можете использовать с [`Minitest`](https://github.com/seattlerb/minitest), библиотекой тестирования, используемой Rails по умолчанию. Параметр `[msg]` - это опциональное строковое сообщение, которое вы можете указать для того, чтобы сделать сообщение о провале более ясным.

| Утверждение                                                    | Назначение |
| -------------------------------------------------------------- | ---------- |
| `assert( test, [msg] )`                                        | Утверждает, что `test` истинно.|
| `assert_not( test, [msg] )`                                    | Утверждает, что `test` ложно.|
| `assert_equal( expected, actual, [msg] )`                      | Утверждает, что `expected == actual` истинно.|
| `assert_not_equal( expected, actual, [msg] )`                  | Утверждает, что `expected != actual` истинно.|
| `assert_same( expected, actual, [msg] )`                       | Утверждает, что `expected.equal?(actual)` истинно.|
| `assert_not_same( expected, actual, [msg] )`                   | Утверждает, что `expected.equal?(actual)` ложно.|
| `assert_nil( obj, [msg] )`                                     | Утверждает, что `obj.nil?` истинно.|
| `assert_not_nil( obj, [msg] )`                                 | Утверждает, что `obj.nil?` ложно.|
| `assert_empty( obj, [msg] )`                                   | Утверждает, что `obj` является `empty?`.|
| `assert_not_empty( obj, [msg] )`                               | Утверждает, что `obj` не является `empty?`.|
| `assert_match( regexp, string, [msg] )`                        | Утверждает, что строка соответствует регулярному выражению.|
| `assert_no_match( regexp, string, [msg] )`                     | Утверждает, что строка не соответствует регулярному выражению.|
| `assert_includes( collection, obj, [msg] )`                    | Утверждает, что `obj` находится в `collection`.|
| `assert_not_includes( collection, obj, [msg] )`                | Утверждает, что `obj` не находится в `collection`.|
| `assert_in_delta( expected, actual, [delta], [msg] )`          | Утверждает, что между числами `expected` и `actual` разницу `delta`.|
| `assert_not_in_delta( expected, actual, [delta], [msg] )`      | Утверждает, что между числами `expected` и `actual` разница, отличная от `delta`.|
| `assert_in_epsilon ( expected, actual, [epsilon], [msg] )`     | Утверждает, что между числами `expected` и `actual` относительная погрешность меньше, чем `epsilon`.|
| `assert_not_in_epsilon ( expected, actual, [epsilon], [msg] )` | Утверждает, что между числами `expected` и `actual` относительная погрешность не меньше, чем `epsilon`.|
| `assert_throws( symbol, [msg] ) { block }`                     | Утверждает, что переданный блок бросает symbol.|
| `assert_raises( exception1, exception2, ... ) { block }`       | Утверждает, что переданный блок генерирует одно из переданных исключений.|
| `assert_instance_of( class, obj, [msg] )`                      | Утверждает, что `obj` является экземпляром `class`.|
| `assert_not_instance_of( class, obj, [msg] )`                  | Утверждает, что `obj` не является экземпляром `class`.|
| `assert_kind_of( class, obj, [msg] )`                          | Утверждает, что `obj` является экземпляром `class` или класса, наследуемого от него.|
| `assert_not_kind_of( class, obj, [msg] )`                      | Утверждает, что `obj` не является экземпляром `class` или класса, наследуемого от него.|
| `assert_respond_to( obj, symbol, [msg] )`                      | Утверждает, что `obj` отвечает на `symbol`.|
| `assert_not_respond_to( obj, symbol, [msg] )`                  | Утверждает, что `obj` не отвечает на `symbol`.|
| `assert_operator( obj1, operator, [obj2], [msg] )`             | Утверждает, что `obj1.operator(obj2)` истинно.|
| `assert_not_operator( obj1, operator, [obj2], [msg] )`         | Утверждает, что `obj1.operator(obj2)` ложно.|
| `assert_predicate ( obj, predicate, [msg] )`                   | Утверждает, что `obj.predicate` истинно, т.е. `assert_predicate str, :empty?`|
| `assert_not_predicate ( obj, predicate, [msg] )`               | Утверждает, что `obj.predicate` ложно, т.е. `assert_not_predicate str, :empty?`|
| `flunk( [msg] )`                                               | Утверждает провал. Это полезно для явного указания теста, который еще не закончен.|

Представленный выше список утверждений поддерживается minitest. Более полный и более актуальный список всех доступных утверждений смотрите в [документации Minitest API](http://docs.seattlerb.org/minitest/), в частности [`Minitest::Assertions`](http://docs.seattlerb.org/minitest/Minitest/Assertions.html)

В силу модульной природы фреймворка тестирования, возможно создать свои собственные утверждения. Фактически Rails так и делает. Он включает некоторые специализированные утверждения, чтобы сделать жизнь разработчика проще.

NOTE: Создание собственных утверждений это особый разговор, которого мы касаться не будем.

### Специфичные утверждения Rails

Rails добавляет некоторые свои утверждения в фреймворк `minitest`:

| Утверждение                                                                       | Назначение |
| --------------------------------------------------------------------------------- | ---------- |
| [`assert_difference(expressions, difference = 1, message = nil) {...}`](http://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_difference) | Тестирует числовую разницу между возвращаемым значением expression и результатом вычисления в данном блоке. |
| [`assert_no_difference(expressions, message = nil, &block)`](http://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_difference) | Утверждает, что числовой результат вычисления expression не изменяется до и после применения переданного в блоке. |
| [`assert_changes(expressions, message = nil, from:, to:, &block)`](http://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_changes) | Тестирует, что результат вычисления expression изменится после применения переданного в блоке.|
| [`assert_no_changes(expressions, message = nil, &block)`](http://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_changes) | Тестирует, что результат вычисления expression не изменится после применения переданного в блоке.|
| [`assert_nothing_raised { block }`](http://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_nothing_raised) | Обеспечивает, что данный блок не вызывает какие-либо исключения.|
| [`assert_recognizes(expected_options, path, extras={}, message=nil)`](http://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes) | Обеспечивает, что роутинг данного path был правильно обработан, и что проанализированные опции (заданные в хэше expected_options) соответствуют path. По существу он утверждает, что Rails распознает маршрут, заданный в expected_options. |
| [`assert_generates(expected_path, options, defaults={}, extras = {}, message=nil)`](http://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates) | Утверждает, что предоставленные options могут быть использованы для генерации предоставленного пути. Это противоположность assert_recognizes. Параметр extras используется, чтобы сообщить запросу имена и значения дополнительных параметров запроса, которые могут быть в строке запроса. Параметр message позволяет определить свое сообщение об ошибке при провале утверждения. |
| [`assert_response(type, message = nil)`](http://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_response) | Утверждает, что отклик идет с определенным кодом статуса. Можете определить `:success` для обозначения 200-299, `:redirect` для обозначения 300-399, `:missing` для обозначения 404, или `:error` для соответствия интервалу 500-599. Можно передать явный номер статуса или его символьный эквивалент. Более подробно смотрите в [полном списке кодов статуса](http://rubydoc.info/github/rack/rack/master/Rack/Utils#HTTP_STATUS_CODES-constant) и как работает их [привязка](http://rubydoc.info/github/rack/rack/master/Rack/Utils#SYMBOL_TO_STATUS_CODE-constant). |
| [`assert_redirected_to(options = {}, message=nil)`](http://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_redirected_to) | Утверждает, что опции перенаправления передаются в соответствии с вызовами перенаправления в последнем экшне. Это соответствие может быть частичным, так `assert_redirected_to(controller: "weblog")` будет также соответствовать перенаправлению `redirect_to(controller: "weblog", action: "show")` и тому подобное. Также можно передать именованные маршруты, как в `assert_redirected_to root_path`, и объекты Active Record, как в `assert_redirected_to @article`. |

Вы увидите использование некоторых из этих утверждений в следующей части.

### Краткая заметка о тестовых случаях

Все основные утверждения, такие как `assert_equal`, определенные в `Minitest::Assertions`, также доступны в классах, используемых в наших тестовых случаях. Фактически, Rails представляет вам следующие классы для наследования:

* [`ActiveSupport::TestCase`](http://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)
* [`ActionMailer::TestCase`](http://api.rubyonrails.org/classes/ActionMailer/TestCase.html)
* [`ActionView::TestCase`](http://api.rubyonrails.org/classes/ActionView/TestCase.html)
* [`ActiveJob::TestCase`](http://api.rubyonrails.org/classes/ActiveJob/TestCase.html)
* [`ActionDispatch::IntegrationTest`](http://api.rubyonrails.org/classes/ActionDispatch/IntegrationTest.html)
* [`ActionDispatch::SystemTestCase`](http://api.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html)
* [`Rails::Generators::TestCase`](http://api.rubyonrails.org/classes/Rails/Generators/TestCase.html)

Каждый из этих классов включает `Minitest::Assertions`, позволяя использовать все основные утверждения в наших тестах.

NOTE: За подробностями о `Minitest` обратитесь к [его документации](http://docs.seattlerb.org/minitest)

### Запуск тестов Rails

Можно запустить все тесты за раз с помощью команды `bin/rails test`.

Или можно запустить отдельный тест, передав команде `bin/rails test` имя файла, содержащего тестовые случаи.

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1559

# Running:

..

Finished in 0.027034s, 73.9810 runs/s, 110.9715 assertions/s.

2 runs, 3 assertions, 0 failures, 0 errors, 0 skips
```

Это запустит все тестовые методы из тестового случая.

Также можете запустить определенный тестовый метод из тестового случая, предоставив флажок `-n` или `--name` и имя метода теста.

```bash
$ bin/rails test test/models/article_test.rb -n test_the_truth
Run options: -n test_the_truth --seed 43583

# Running:

.

Finished tests in 0.009064s, 110.3266 tests/s, 110.3266 assertions/s.

1 tests, 1 assertions, 0 failures, 0 errors, 0 skips
```

Также можно запустить тест в определенной строчке, предоставив номер строчки.

```bash
$ bin/rails test test/models/article_test.rb:6 # запускает определенный тест и строчку
```

Также можно запустить целую директорию тестов, предоставив путь к этой директории.

```bash
$ bin/rails test test/controllers # запускает все тесты из определенной директории
```

Для запуска тестов также имеется множество других особенностей, таких как падение при первой ошибке (failing fast), вывод результатов тестов после запуска тестов и так далее. Документацию по запуску тестов можно просмотреть так:

```bash
$ bin/rails test -h
minitest options:
    -h, --help                       Display this help.
    -s, --seed SEED                  Sets random seed. Also via env. Eg: SEED=n rake
    -v, --verbose                    Verbose. Show progress processing files.
    -n, --name PATTERN               Filter run on /regexp/ or string.
        --exclude PATTERN            Exclude /regexp/ or string from run.

Known extensions: rails, pride

Usage: bin/rails test [options] [files or directories]
You can run a single test by appending a line number to a filename:

    bin/rails test test/models/user_test.rb:27

You can run multiple files and directories at the same time:

    bin/rails test test/controllers test/integration/login_test.rb

By default test failures and errors are reported inline during a run.

Rails options:
    -w, --warnings                   Run with Ruby warnings enabled
    -e, --environment                Run tests in the ENV environment
    -b, --backtrace                  Show the complete backtrace
    -d, --defer-output               Output test failures and errors after the test run
    -f, --fail-fast                  Abort test run on first failure or error
    -c, --[no-]color                 Enable color in the output
```

Параллельное тестирование
-------------------------

Параллельное тестирование позволяет распараллелить тестовый набор. Хотя форк процессов является методом по умолчанию, треды также поддерживаются. Запуск тестов параллельно сокращает время, затрачиваемое на запуск всего тестового набора.

### Параллельное тестирование с помощью процессов

Дефолтный метод распараллеливания - это форк процессов с помощью системы DRb. Процессы форкаются, основываясь на количестве предоставленных воркеров. Значение по умолчанию равно 2, но может быть изменено на число, переданное методу распараллеливания. Active Record автоматически обрабатывает создание и миграцию новой базы данных для каждого используемого воркера.

Чтобы включить распараллеливание, добавьте следующее в `test_helper.rb`:

```
class ActiveSupport::TestCase
  parallelize(workers: 2)
end
```

Количество переданных воркеров равно количеству раз, когда процесс будет форкнут. Возможно, может понадобиться распараллелить локальный тестовый набор отлично от CI, поэтому предоставляется переменная среды, позволяющая легко изменять количество воркеров, которые должны использоваться для запуска теста:

```
PARALLEL_WORKERS=15 bin/rails test
```

При распараллеливании тестов Active Record автоматически обрабатывает создание и миграцию базы данных для каждого процесса. Базы данных будут иметь суффикс с цифрой, соответствующей воркеру. Например, если есть 2 воркера, тесты создадут `test-database-0` и` test-database-1` соответственно.

Если количество переданных воркеров равно 1 или менее, процессы не будут форкнуты, и тесты не будут распараллелены, и тесты будут использовать исходную базу данных `test-database`.

Предоставляются два хука, один запускается, когда процесс был форкнут, и еще один запускается до закрытия процессов. Они могут быть полезны, если приложение использует несколько баз данных или выполняет другие задачи, зависящие от количества воркеров.

Метод `parallelize_setup` вызывается сразу после того, как процессы форкнуты. Метод `parallelize_teardown` вызывается непосредственно до закрытия процессов.

```
class ActiveSupport::TestCase
  parallelize_setup do |worker|
    # настройки баз данных
  end

  parallelize_teardown do |worker|
    # настройки баз данных
  end

  parallelize(workers: 2)
end
```

Эти методы не нужны или не доступны при параллельном тестировании с помощью тредов.

### Параллельное тестирование с помощью тредов

Если предпочитаете использовать треды или используете JRuby, предоставляется тредовая опция распараллеливания. Тредовый распараллеливатель поддерживается `Parallel::Executor` в Minitest.

Чтобы изменить метод распараллеливания для использования тредов над форками, необходимо добавить в `test_helper.rb`

```
class ActiveSupport::TestCase
  parallelize(workers: 2, with: :threads)
end
```

Приложения Rails, сгенерированные от JRuby автоматически включают опцию `with: :threads`.

Число переданных воркеров в `parallelize` определяет количество тредов, которые будут использоваться в тестах. Возможно, может понадобиться распараллелить локальный тестовый набор отлично от CI, поэтому предоставляется переменная среды, позволяющая легко изменять количество воркеров, которые должны использоваться для запуска теста:

```
PARALLEL_WORKERS=15 bin/rails test
```

Тестовая база данных
--------------------

Почти каждое приложение на Rails сильно взаимодействует с базой данных, и, как результат, тестам также требуется база данных для работы. Чтобы писать эффективные тесты, следует понять, как настроить эту базу данных и наполнить ее образцом данных.

По умолчанию каждое приложение на Rails имеет три среды разработки: development, test и production. База данных для каждой из них настраивается в `config/database.yml`.

Отдельная тестовая база данных позволяет настраивать и работать с данными в изоляции. Таким образом, тесты могут искажать тестовые данные с уверенностью, не беспокоясь о данных в базах данных development или production.

### Поддержка схемы тестовой базы данных

Чтобы запустить тесты, ваша тестовая база данных должна иметь текущую структуры. Тестовый хелпер проверяет, не имеет ли ваша тестовая база данных отложенных миграций. Он пытается загрузить ваши `db/schema.rb` или `db/structure.sql` в тестовую базу данных. Если есть отложенные миграции - будет вызвана ошибка. Обычно это указывает на то, что ваша схема не полностью мигрирована. Запуск миграций для базы данных development (`bin/rails db:migrate`) приведет схему в актуальное состояние.

NOTE: Если были модификации в существующих миграциях, нужно перестроить тестовую базу данных. Это делается с помощью выполнения `bin/rails db:test:prepare`.

### Полная информация по фикстурам

Для хороших тестов необходимо подумать о настройке тестовых данных. В Rails этим можно управлять, определяя и настраивая фикстуры. Подробности можно узнать в [документации API фикстур](http://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html).

#### Что такое фикстуры?

_Fixtures_ это выдуманное слово для образцов данных. Фикстуры позволяют заполнить вашу тестовую базу данных предопределенными данными до запуска тестов. Фикстуры независимы от типа базы данных и написаны на YAML. На каждую модель имеется отдельный файл.

NOTE: Фикстуры не разработаны для создания каждого объекта, требуемого в ваших тестах, и они лучше всего подходят только при использовании для данных по умолчанию, которые применимы в общем случае.

Фикстуры расположены в директории `test/fixtures`. Когда запускаете `rails generate model` для создания новой модели, Rails автоматически создаст незаконченные фикстуры в этой директории.

#### YAML

Фикстуры в формате YAML являются дружелюбным способом описать ваш образец данных. Этот тип фикстур имеет расширение файла *.yml* (как в `users.yml`).

Вот образец файла фикстуры YAML:

```yaml
# lo & behold! I am a YAML comment!
david:
  name: David Heinemeier Hansson
  birthday: 1979-10-15
  profession: Systems development

steve:
  name: Steve Ross Kellock
  birthday: 1974-09-27
  profession: guy with keyboard
```

Каждой фикстуре дается имя со следующим за ним списком с отступом пар ключ/значение, разделенных двоеточием. Записи обычно разделяются пустой строчкой. Можете помещать комментарии в файл фикстуры, используя символ # в первом столбце.

Если работаете со [связями](/active-record-associations), можно определить ссылку между двумя различными фикстурами. Вот пример для связи `belongs_to`/`has_many`:

```yaml
# In fixtures/categories.yml
about:
  name: About

# In fixtures/articles.yml
first:
  title: Welcome to Rails!
  body: Hello world!
  category: about
```

Отметьте, что у ключа `category` в статье `first` из `fixtures/articles.yml` значение `about`. Это говорит Rails загрузить категорию `about` из `fixtures/categories.yml`.

NOTE: При связи двух записей по имени в связанных фикстурах можно использовать имя фикстуры вместо атрибута `id:` связанной фикстуры. Rails автоматически назначит первичный ключ, согласующийся между запусками. Подробнее об этом поведении связей можно прочитать в [документации API фикстур](http://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html).

#### ERb

ERb позволяет встраивать код Ruby в шаблоны. Формат фикстур YAML предварительно обрабатывается с помощью ERb при загрузке фикстур. Это позволяет использовать Ruby для помощи в генерации некоторых образцов данных. Например, следующий код сгенерирует тысячу пользователей:

```erb
<% 1000.times do |n| %>
user_<%= n %>:
  username: <%= "user#{n}" %>
  email: <%= "user#{n}@example.com" %>
<% end %>
```

#### Фикстуры в действии

Rails по умолчанию автоматически загружает все фикстуры из директории `test/fixtures` для ваших тестов моделей и контроллеров. Загрузка состоит из трех этапов:

1. Убираются любые существующие данные из таблицы, соответствующей фикстуре
2. Загружаются данные фикстуры в таблицу
3. Выгружаются данные фикстуры в переменную, в случае, если вы хотите обращаться к ним напрямую

TIP: Чтобы убрать существующие данные из базы, Rails пытается отключить триггеры ссылочной целостности (такие как внешние ключи и проверки ограничений). Если вы получаете надоедливые ошибки прав доступа при запуске тестов, убедитесь, что у пользователя базы данных есть права на отключение этих триггеров в тестовой среде. (В PostgreSQL только суперпользователи могут отключать все триггеры. Подробнее о правах доступа в PostgreSQL читайте [здесь](http://blog.endpoint.com/2012/10/postgres-system-triggers-error.html))

#### Фикстуры это объекты Active Record

Фикстуры являются экземплярами Active Record. Как упоминалось в этапе №3 выше, Вы можете обращаться к объекту напрямую, поскольку он автоматически доступен как метод, область видимости которого локальна для тестового случая. Например:

```ruby
# это возвратит объект User для фикстуры с именем david
users(:david)

# это возвратит свойство для david, названное id
users(:david).id

# он имеет доступ к методам, доступным для класса User
david = users(:david)
david.call(david.partner)
```

Чтобы получить несколько фикстур за раз, вы можете передать список имен фикстур. Например:

```ruby
# это возвратит массив, содержаший фикстуры david и steve
users(:david, :steve)
```

Тестирование моделей
--------------------

Тесты моделей используются для тестирования различных моделей вашего приложения.

Тесты моделей Rails хранятся в директории `test/models` directory. Rails предоставляет генератор для создания скелета теста модели.

```bash
$ bin/rails generate test_unit:model article title:string body:text
create  test/models/article_test.rb
create  test/fixtures/articles.yml
```

У тестов модели нет своего собственного суперкласса, такого как `ActionMailer::TestCase`, вместо этого они наследуются от [`ActiveSupport::TestCase`](http://api.rubyonrails.org/classes/ActiveSupport/TestCase.html).

Системное тестирование
----------------------

Системные тесты позволяют тестировать взаимодействие пользователя с вашим приложением, запускать тесты либо в реальном, либо в headless браузере. Системные тесты используют Capybara под капотом.

Для создания системных тестов Rails используют директорию приложения `test/system`. Rails предоставляет генератор для создания скелета системного теста.

```bash
$ bin/rails generate system_test users
      invoke test_unit
      create test/system/users_test.rb
```

Вот как выглядит свежесгенерированный системный тест:

```ruby
require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit users_url
  #
  #   assert_selector "h1", text: "Users"
  # end
end
```

По умолчанию системные тесты запускаются с помощью драйвера Selenium с использованием браузера Chrome и разрешения экрана 1400x1400. Следующий раздел объясняет, как изменить настройки по умолчанию.

### Изменение настроек по умолчанию

В Rails изменить настройки по умолчанию для системных тестов очень просто. Все настройки абстрагированы, поэтому вы можете сфокусироваться на написании своих тестов.

При генерации нового приложения или скаффолда, в тестовой директории будет создан файл `application_system_test_case.rb`. Это то самое место, где должны находиться все настройки для ваших системных тестов.

Если хотите изменить настройки по умолчанию, надо изменить то, с помощью чего "запускаются" ваши системные тесты. Скажем, вы хотите изменить драйвер с Selenium на Poltergeist. Сначала добавьте гем `poltergeist` в свой `Gemfile`. Затем сделайте в своем файле `application_system_test_case.rb` следующее:

```ruby
require "test_helper"
require "capybara/poltergeist"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :poltergeist
end
```

Имя драйвера — обязательный аргумент для `driven_by`. Опциональные аргументы, который можно передать в `driven_by` это `:using` для браузера (используется только в Selenium), :screen_size, чтобы изменить размер экрана для скриншотов, и `:options`, которые могут использоваться для установки опций, поддерживаемых драйвером.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :firefox
end
```

Если необходимо использовать headless-браузер, можно использовать Headless Chrome или Headless Firefox, добавив `headless_chrome` или `headless_firefox` в аргумент `:using`.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
```

Если вашей конфигурации для Capybara требуется больше настроек, чем предоставлено Rails, то эту дополнительную конфигурацию можно поместить в файл `application_system_test_case.rb`.

За дополнительными настройками обратитесь к [документации Capybara](https://github.com/teamcapybara/capybara#setup).

### Хелпер для скриншотов

`ScreenshotHelper` - это хелпер, разработанный для захвата скриншотов ваших тестов.
Это полезно для просмотра браузера в момент, когда упал тест, или для просмотра скриншотов для отладки.

Предоставляются два метода: `take_screenshot` и `take_failed_screenshot`. `take_failed_screenshot` автоматически включается в `after_teardown` внутри Rails.

Вспомогательный метод `take_screenshot` может быть включен где угодно в ваших тестах, чтобы снять скриншот браузера.

### Реализация системного теста

Теперь мы собираемся добавить системный тест в наше приложение блога. Мы продемонстрируем написание системного теста для посещения индексной страницы и для создания статьи в блоге.

При использовании генератора скаффолда, автоматически создавался скелет системного теста. Если не использовать генератор скаффолда, нужно начать с создания скелета системного теста.

```bash
$ bin/rails generate system_test articles
```

Это создаст файл теста. В результате выполнения предыдущей команды вы увидите:

```bash
      invoke  test_unit
      create    test/system/articles_test.rb
```

Теперь откройте этот файл и напишите первой утверждение:

```ruby
require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  test "viewing the index" do
    visit articles_path
    assert_selector "h1", text: "Articles"
  end
end
```

Тест должен увидеть, что на индексной странице статей есть `h1` и пройти.

Запустите системные тесты.

```bash
bin/rails test:system
```

NOTE: По умолчанию, выполнение `bin/rails test` не будет запускать ваши системные тесты. Убедитесь, что вы выполняете `bin/rails test:system`, чтобы на самом деле запустить их.

#### Системный тест для создания статей

Теперь давайте протестируем процесс создания новой статьи в нашем блоге.

```ruby
test "creating an article" do
  visit articles_path

  click_on "New Article"

  fill_in "Title", with: "Creating an Article"
  fill_in "Body", with: "Created this article successfully!"

  click_on "Create Article"

  assert_text "Creating an Article"
end
```

Первый шаг — это вызов `visit articles_path`. Это приведет тест на индексную страницу статей.

Затем `click_on "New Article"` найдет кнопку "New Article" на индексной странице. Это перенаправит браузер на `/articles/new`.

Затем браузер заполнит title и body статьи представленным текстом. Как только поля будут заполнены, будет нажата "Create Article", что отправит запрос POST для создания новой статьи в базе данных.

Мы будем перенаправлены обратно на индексную страницу статей, где мы убедимся, что текст заголовка новой статьи присутствует на индексной странице статей.

#### Тестирование для нескольких размеров экрана

Если необходимо протестировать размеры мобильных устройств поверх тестирования для десктопных, можно создать другой класс, который наследуется от SystemTestCase и использовать в тестовом наборе. В этом примере файл, называемый `mobile_system_test_case.rb`, создается в директории `/test` со следующей конфигурацией.

```ruby
require "test_helper"

class MobileSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [375, 667]
end
```

Чтобы использовать эту конфигурацию, нужно создать тест внутри `test/system`, который наследуется от `MobileSystemTestCase`. Теперь можно протестировать приложение, используя несколько разных конфигураций.

```ruby
require "mobile_system_test_case"

class PostsTest < MobileSystemTestCase
  test "visiting the index" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end
end
```

#### Что дальше?

Красота системного тестирования в том, что оно похоже на интеграционное тестирование в том, что оно тестирует взаимодействие пользователя с вашими контроллерами, моделями и вьюхами, но системное тестирование более адекватное и фактически тестирует ваше приложение так, как его будет использовать реальный пользователь. Двигаясь дальше, можно протестировать все, что пользователь сможет делать в вашем приложении - комментирование, удаление статей, публикацию черновиков и так далее.

Интеграционное тестирование
---------------------------

Интеграционные тесты используются для тестирования взаимодействия различных частей вашего приложения. Они в основном используются для тестирования важных рабочих процессов в нашем приложении.

Для создания интеграционных тестов Rails используется директория 'test/integration' нашего приложения. Rails предоставляет нам генератор для создания скелета интеграционного теста.

```bash
$ bin/rails generate integration_test user_flows
      exists  test/integration/
      create  test/integration/user_flows_test.rb
```

Вот как выглядит свежесгенерированный интеграционный тест:

```ruby
require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
end
```

Здесь тест наследуется от `ActionController::IntegrationTest`. Это делает доступным несколько дополнительных хелперов для использования в наших интеграционных тестах.

### Хелперы, доступные для интеграционных тестов

В дополнение к стандартным хелперам тестирования, наследование от `ActionDispatch::IntegrationTest` дает несколько дополнительных хелперов для написания интеграционных тестов. Давайте для краткости представим три категории хелперов.

Для работы с runner-ом интеграционных тестов, смотрите [`ActionDispatch::Integration::Runner`](http://api.rubyonrails.org/classes/ActionDispatch/Integration/Runner.html).

Для выполнения запросов у нас есть [`ActionDispatch::Integration::RequestHelpers`](http://api.rubyonrails.org/classes/ActionDispatch/Integration/RequestHelpers.html).

Если хотим модифицировать сессию или состояние вашего интеграционного теста, нам поможет [`ActionDispatch::Integration::Session`](http://api.rubyonrails.org/classes/ActionDispatch/Integration/Session.html).

### Реализация интеграционного теста

Давайте добавим интеграционный тест в наше приложение блога. Начнем с основного процесса создания новой статьи блога, чтобы убедиться, что все работает правильно.

Начнем с генерации скелета нашего интеграционного теста:

```bash
$ bin/rails generate integration_test blog_flow
```

Он должен создать файл для размещения теста, и в результате предыдущей команды мы должны увидеть:

```bash
      invoke  test_unit
      create    test/integration/blog_flow_test.rb
```

Теперь откроем этот файл и напишем наше первое утверждение:

```ruby
require 'test_helper'

class BlogFlowTest < ActionDispatch::IntegrationTest
  test "can see the welcome page" do
    get "/"
    assert_select "h1", "Welcome#index"
  end
end
```

Мы рассмотрим `assert_select` для запрашивания результирующего HTML запроса в разделе "Тестирование вьюх" ниже. Он используется для тестирования отклика на наш запрос, убеждаясь в наличии ключевых элементов HTML и их содержимого.

При посещении корневого пути мы должны увидеть `welcome/index.html.erb`, отрендеренную для представления. Таким образом, это утверждение должно пройти.

#### Создание интеграции статей

Как насчет тестирования возможности создавать новую статью в нашем блоге и просматривать полученную статью.

```ruby
test "can create an article" do
  get "/articles/new"
  assert_response :success

  post "/articles",
    params: { article: { title: "can create", body: "article successfully." } }
  assert_response :redirect
  follow_redirect!
  assert_response :success
  assert_select "p", "Title:\n  can create"
end
```

Давайте разобьем этот тест на кусочки, чтобы понять его.

Мы начинаем с вызова экшна `:new` контроллера Articles. Этот запрос должен быть успешным.

После этого мы делаем запрос post к экшну `:create` нашего контроллера Articles:

```ruby
post "/articles",
  params: { article: { title: "can create", body: "article successfully." } }
assert_response :redirect
follow_redirect!
```

Следующие две строчки — это обработка редиректа, который мы настроили при создании новой статьи.

NOTE: Не забывайте вызвать `follow_redirect!` Если планируете сделать последовательные запросы после выполнения редиректа.

Наконец, мы убеждаемся, что наш отклик был успешным, и нашу статью можно прочесть на странице.

#### Идем дальше

У нас получилось протестировать маленький процесс посещения нашего блога и создания новой статьи. Если мы хотим идти дальше, мы можем добавить тесты для комментирования, удаления статей и редактирования комментариев. Интеграционные тесты — это отличное место для экспериментов с различными сценариями использования приложения.

Функциональные тесты для ваших контроллеров
-------------------------------------------

В Rails тестирование различных экшнов контроллера — это форма написания функциональных тестов. Помните, что контроллеры обрабатывают входящие веб-запросы к вашему приложению и в конечном итоге откликаются отрендеренной вьюхой. При написании функциональных тестов, вы тестируете, как ваши экшны обрабатывают запросы, ожидаемый результат или, в некоторых случаях, отклики вьюх HTML.

### Что включать в функциональные тесты

Следует протестировать такие вещи, как:

* был ли веб-запрос успешным?
* был ли пользователь перенаправлен на правильную страницу?
* был ли пользователь успешно аутентифицирован?
* был ли правильный объект сохранен в шаблон отклика?
* было ли подходящее сообщение отражено для пользователя во вьюхе

Самым простым способом увидеть функциональные тесты в действии является генерация контроллера с помощью генератора скаффолда:

```bash
$ bin/rails generate scaffold_controller article title:string body:text
...
create  app/controllers/articles_controller.rb
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

Это сгенерирует код контроллера и тестов для ресурса `Article`. Можете взглянуть на файл `articles_controller_test.rb` в директории `test/controllers`.

Если у вас уже есть контроллер и вы просто хотите сгенерировать код теста скаффолда для каждого из семи экшнов по умолчанию, можете использовать следующую команду:

```bash
$ bin/rails generate test_unit:scaffold article
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

Давайте взглянем на один такой тест, `test_should_get_index` из файла `articles_controller_test.rb`.

```ruby
# articles_controller_test.rb
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url
    assert_response :success
  end
end
```

В тесте `test_should_get_index`, Rails имитирует запрос к экшну index, убеждается, что запрос был успешным, а также обеспечивает, что генерируется правильное тело отклика.

Метод `get` стартует веб-запрос и заполняет результаты в `@response`. Он может принимать до 6 аргументов:

* URI экшна контроллера, к которому обращаетесь. Он может быть в форме строки или хелпера маршрута (например, `articles_url`).
* `params`: опция с хэшем параметров запроса для передачи в экшн (например, параметры строки запроса или переменные для модели article).
* `headers`: для установки заголовков, которые будут переданы с запросом.
* `env`: для настройки среды запроса по необходимости.
* `xhr`: был ли запрос Ajax или нет. Можно установить true для пометки, что запрос является Ajax.
* `as`: для кодировки запроса другим типом запроса. По умолчанию поддерживает `:json`.

Все эти аргументы с ключевым словом опциональны.

Пример: Вызов экшна `:show`, передача `id`, равного 12, как `params`, и установка заголовка `HTTP_REFERER`:

```ruby
get article_url, params: { id: 12 }, headers: { "HTTP_REFERER" => "http://example.com/home" }
```

Другой пример: Вызов экшна `:update`, передача `id`, равного 12, как `params`, как запрос Ajax.

```ruby
patch article_url, params: { id: 12 }, xhr: true
```

NOTE: Если попытаетесь запустить тест `test_should_create_article` из `articles_controller_test.rb`, он провалится из-за недавно добавленной валидации на уровне модели, и это правильно.

Давайте модифицируем тест `test_should_create_article` в `articles_controller_test.rb` так, чтобы все наши тесты проходили:

```ruby
test "should create article" do
  assert_difference('Article.count') do
    post articles_url, params: { article: { body: 'Rails is awesome!', title: 'Hello Rails' } }
  end

  assert_redirected_to article_path(Article.last)
end
```

Теперь можете попробовать запустить все тесты, и они должны пройти.

NOTE: Если выполняли шаги в разделе про базовую аутентификацию, то необходимо добавить следующее в блок `setup`, чтобы все тесты проходили:

```ruby
request.headers['Authorization'] = ActionController::HttpAuthentication::Basic.
  encode_credentials('dhh', 'secret')
```

### Доступные типы запросов для функциональных тестов

Если вы знакомы с протоколом HTTP, то знаете, что `get` это тип запроса. Имеется 6 типов запросов, поддерживаемых в функциональных тестах Rails:

* `get`
* `post`
* `patch`
* `put`
* `head`
* `delete`

У всех типов запросов есть эквивалентные методы, которые можно использовать. В обычном приложении C.R.U.D. вы чаще будете использовать `get`, `post`, `put` и `delete`.

NOTE: Функциональные тесты не проверяют, поддерживается ли определенный тип запроса экшном, мы больше беспокоимся о результате. Для этого случая существуют тесты запросов, чтобы сделать ваши тесты более целенаправленными.

### Тестирование запросов XHR (AJAX)

Чтобы протестировать запросы AJAX, можно указать опцию `xhr: true` в методах `get`, `post`, `patch`, `put` и `delete`. Например:

```ruby
test "ajax request" do
  article = articles(:one)
  get article_url(article), xhr: true

  assert_equal 'hello world', @response.body
  assert_equal "text/javascript", @response.content_type
end
```

### Три Хэша Апокалипсиса (The Three Hashes of the Apocalypse)

После того, как запрос был сделан и обработан, у вас будет 3 объекта Hash, готовых для использования:

* `cookies` - Любые установленные куки
* `flash` - Любые объекты, находящиеся во flash
* `session` - Любый объекты, находящиеся в переменных сессии

Как и в случае с обычными объектами Hash, можете получать доступ к значениям, указав ключ в строке. Также можете указать его именем символа. Например:

```ruby
flash["gordon"]               flash[:gordon]
session["shmession"]          session[:shmession]
cookies["are_good_for_u"]     cookies[:are_good_for_u]
```

### Доступные переменные экземпляра

В ваших функциональных тестах также доступны три переменные экземпляра, после того как запрос был выполнен:

* `@controller` - Контроллер, обрабатывающий запрос
* `@request` - Объект запроса
* `@response` - Объект отклика

```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url

    assert_equal "index", @controller.action_name
    assert_equal "application/x-www-form-urlencoded", @request.media_type
    assert_match "Articles", @response.body
  end
end
```

### Установка заголовков и переменных CGI

[Заголовки HTTP](https://tools.ietf.org/search/rfc2616#section-5.3) и [переменные CGI](https://tools.ietf.org/search/rfc3875#section-4.1) могут быть переданы как заголовки:

```ruby
# устанавливаем заголовок HTTP
get articles_url, headers: { "Content-Type": "text/plain" } # имитировать запрос с пользовательским заголовком

# устанавливаем переменную CGI
get articles_url, headers: { "HTTP_REFERER": "http://example.com/home" } # имитировать запрос с пользовательской env переменной
```

### Тестирование сообщений `flash`

Как помните, одним из трех хэшей был `flash`.

Мы хотим добавить сообщение `flash` в наше приложение блога, всякий раз, когда кто-то успешно создает новый объект Article.

Давайте начнем с добавления этого утверждения в наш тест `test_should_create_article`:

```ruby
test_should_create_article do
  assert_difference('Article.count') do
    post article_url, params: { article: { title: 'Some title' } }
  end

  assert_redirected_to article_path(Article.last)
  assert_equal 'Article was successfully created.', flash[:notice]
end
```

Если запустить наш тест сейчас, мы увидим ошибку:

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 32266

# Running:

F

Finished in 0.114870s, 8.7055 runs/s, 34.8220 assertions/s.

  1) Failure:
ArticlesControllerTest#test_should_create_article [/test/controllers/articles_controller_test.rb:16]:
--- expected
+++ actual
@@ -1 +1 @@
-"Article was successfully created."
+nil

1 runs, 4 assertions, 1 failures, 0 errors, 0 skips
```

Теперь давайте реализуем сообщение flash в нашем контроллере. Наш экшн `:create` теперь должен выглядеть так:

```ruby
def create
  @article = Article.new(article_params)

  if @article.save
    flash[:notice] = 'Article was successfully created.'
    redirect_to @article
  else
    render 'new'
  end
end
```

Если теперь запустить наши тесты, мы увидим, что он проходит:

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 18981

# Running:

.

Finished in 0.081972s, 12.1993 runs/s, 48.7972 assertions/s.

1 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### Обобщение изложенного

С этого момента в нашем контроллере Articles тестируются экшны `:index`, `:new` и `:create`. Но как насчет работы с существующими данными?

Давайте напишем тест для экшна `:show`:

```ruby
test "should show article" do
  article = articles(:one)
  get article_url(article)
  assert_response :success
end
```

Как помните из нашего обсуждения фикстур, что метод `articles()` дает нам доступ к нашим фикстурам Articles.

Как насчет удаления существующего объекта Article?

```ruby
test "should destroy article" do
  article = articles(:one)
  assert_difference('Article.count', -1) do
    delete article_url(article)
  end

  assert_redirected_to articles_path
end
```

Также можно добавить тест для обновления существующего объекта Article.

```ruby
test "should update article" do
  article = articles(:one)

  patch article_url(article), params: { article: { title: "updated" } }

  assert_redirected_to article_path(article)
  # Перезагрузим связь, чтобы извлечь обновленные данные и убедиться, что заголовок обновлен.
  article.reload
  assert_equal "updated", article.title
end
```

Отметьте, что у нас имеется некоторое дублирование в этих трех тестах, они все получают доступ к одним и тем же данным фикстуры Article. Можно убрать повторения с помощью методов `setup` и `teardown`, предоставленных `ActiveSupport::Callbacks`.

Наш тест должен быть похож на следующее. Не обращайте внимания, что остальные тесты были убраны для краткости.

```ruby
require 'test_helper'

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  # вызывается перед каждым отдельным тестом
  setup do
    @article = articles(:one)
  end

  # вызывается после каждого отдельного теста
  teardown do
    # когда контроллер использует кэш, это может быть хорошей идеей сбросить его затем
    Rails.cache.clear
  end

  test "should show article" do
    # переиспользуем переменную экземпляра @article из setup
    get article_url(@article)}
    assert_response :success
  end

  test "should destroy article" do
    assert_difference('Article.count', -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_path
  end

  test "should update article" do
    patch article_url(@article), params: { article: { title: "updated" } }

    assert_redirected_to article_path(@article)
    # Перезагрузим связь, чтобы извлечь обновленные данные и убедиться, что заголовок обновлен.
    article.reload
    assert_equal "updated", article.title
  end
end
```

Подобно другим колбэкам Rails, методы `setup` и `teardown` можно использовать, передав блок, lambda или имя метода символом для вызова.

### Тестовые хелперы

Чтобы избежать дублирования кода, можно добавлять собственные тестовые хелперы. Хорошим примером может быть хелпер входа в систему:

```ruby
# test/test_helper.rb

module SignInHelper
  def sign_in_as(user)
    post sign_in_url(email: user.email, password: user.password)
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

```ruby
require 'test_helper'

class ProfileControllerTest < ActionDispatch::IntegrationTest

  test "should show profile" do
    # теперь хелпер можно повторно использовать в любом тестовом случае контроллера
    sign_in_as users(:david)

    get profile_url
    assert_response :success
  end
end
```

Тестирование маршрутов
----------------------

Как и все другое в вашем приложении Rails, ваши маршруты можно тестировать. Тесты маршрутов находятся в `test/controllers/` или являются частью тестов контроллера.

NOTE: Если в вашем приложении сложные маршруты, Rails предоставляет ряд полезных хелперов для их тестирования.

Подробности о тестировании маршрутов доступны в Rails, обратитесь к документации API для [`ActionDispatch::Assertions::RoutingAssertions`](http://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html).

Тестирование вьюх
-----------------

Тестирование отклика на ваш запрос с помощью подтверждения наличия ключевых элементов HTML и их содержимого, это хороший способ протестировать вьюхи вашего приложения. Как и тесты маршрутов, тесты вьюх находятся в `test/controllers/` или являются частью тестов контроллера. Метод `assert_select` позволяет осуществить выборку элементов HTML отклика с помощью простого, но мощного синтаксиса.

Имеется две формы `assert_select`:

`assert_select(selector, [equality], [message])` обеспечивает, что условие equality выполняется для выбранных через selector элементов, selector может быть выражением селектора CSS (String) или выражением с заменяемыми значениями.

`assert_select(element, selector, [equality], [message])` обеспечивает, что условие equality выполняется для всех элементов, выбранных через selector начиная с _element_ (экземпляра `Nokogiri::XML::Node` или `Nokogiri::XML::NodeSet`) и его потомков.

Например, можно проверить содержимое в элементе `title` отклика с помощью:

```ruby
assert_select 'title', "Welcome to Rails Testing Guide"
```

Также можно использовать вложенные блоки `assert_select` для углубленного исследования.

В следующем примере, внутренний `assert_select` для `li.menu_item` запускается для полной коллекции элементов, выбранных во внешнем блоке:

```ruby
assert_select 'ul.navigation' do
  assert_select 'li.menu_item'
end
```

Коллекция выбранных элементов может быть перебрана, таким образом `assert_select` может быть вызван отдельно для каждого элемента.

Например, если отклик содержит два упорядоченных списка, каждый из четырех элементов, тогда оба следующих теста пройдут.

```ruby
assert_select "ol" do |elements|
  elements.each do |element|
    assert_select element, "li", 4
  end
end

assert_select "ol" do
  assert_select "li", 8
end
```

Это утверждение достаточно мощное. Для более продвинутого использования обратитесь к его [документации](https://github.com/rails/rails-dom-testing/blob/master/lib/rails/dom/testing/assertions/selector_assertions.rb).

#### Дополнительные утверждения, основанные на вьюхе

В тестировании вьюх в основном используется такие утверждения:

| Утверждение                                                | Назначение                                              |
| ---------------------------------------------------------- | ------------------------------------------------------- |
| `assert_select_email`                                      | Позволяет сделать утверждение относительно тела e-mail. |
| `assert_select_encoded`                                    | Позволяет сделать утверждение относительно закодированного HTML. Он делает это декодируя содержимое каждого элемента и затем вызывая блок со всеми декодированными элементами. |
| `css_select(selector)` или `css_select(element, selector)` | Возвращают массив всех элементов, выбранных через _selector_. Во втором варианте сначала проверяется соответствие базовому _element_, а затем пытается применить соответствие выражению _selector_ на каждом из его детей. Если нет соответствий, оба варианта возвращают пустой массив. |

Вот пример использования `assert_select_email`:

```ruby
assert_select_email do
  assert_select 'small', 'Please click the "Unsubscribe" link if you want to opt-out.'
end
```

Тестирование хелперов
---------------------

Хелпер — это всего лишь простой модуль, в котором можно определять методы, которые будут доступны во вьюхах.

Чтобы протестировать хелперы, нужно проверить, что результат метода хелпера соответствует тому, что вы ожидаете. Тесты, относящиеся к хелперам, расположены в директории `test/helpers`.

Допустим, у нас имеется следующий хелпер:

```ruby
module UserHelper
  def link_to_user(user)
    link_to "#{user.first_name} #{user.last_name}", user
  end
end
```

Мы можем протестировать результат этого метода хелпера следующим образом:

```ruby
class UserHelperTest < ActionView::TestCase
  test "should return the user's full name" do
    user = users(:david)

    assert_dom_equal %{<a href="/user/#{user.id}">David Heinemeier Hansson</a>}, link_to_user(user)
  end
end
```

Более того, так как этот класс теста расширяет `ActionView::TestCase`, у вас есть доступ к методам хелпера Rails, таким как `link_to` или `pluralize`.

(testing-your-mailers) Тестирование почтовых рассыльщиков
---------------------------------------------------------

Тестирование классов рассыльщика требует несколько специфичных инструментов для тщательного выполнения задания.

### Держим отправку почты под контролем

Ваши классы рассыльщика - как и любая другая часть вашего приложения на Rails - должны быть протестированы, что они работают так, как ожидается.

Тестировать классы рассыльщика нужно, чтобы быть уверенным в том, что:

* электронные письма обрабатываются (создаются и отсылаются)
* содержимое письма правильное (тема, получатель, тело и т.д.)
* правильные письма отправляются в нужный момент

#### Со всех сторон

Есть два момента в тестировании рассыльщика, юнит-тесты и функциональные тесты. В юнит-тестах обособленно запускается рассыльщик с жестко заданными входящими значениями, и сравнивается результат с известным значением (фикстуры). В функциональных тестах не нужно тестировать мелкие детали, вместо этого мы тестируем, что наши контроллеры и модели правильно используют рассыльщик. Мы тестируем, чтобы подтвердить, что правильный email был послан в правильный момент.

### Юнит-тестирование

Для того, чтобы протестировать, что ваш рассыльщик работает как надо, можете использовать юнит-тесты для сравнения фактических результатов рассыльщика с предварительно написанными примерами того, что должно быть получено.

#### Реванш фикстур

Для целей юнит-тестирования рассыльщика фикстуры используются для предоставления примера, как результат _должен_ выглядеть. Так как это примеры электронных писем, а не данные Active Record, как в других фикстурах, они должны храниться в своей поддиректории отдельно от других фикстур. Имя директории в `test/fixtures` полностью соответствует имени рассыльщика. Таким образом, для рассыльщика с именем `UserMailer` фикстуры должны располагаться в директории `test/fixtures/user_mailer`.

Если вы генерируете свой рассыльщик, то генератор не создает незавершенные фикстуры для экшнов рассыльщиков. Вам следует создать эти файлы самостоятельно, как описано выше.

#### Базовый тестовый случай

Вот юнит-тест для тестирования рассыльщика с именем `UserMailer`, экшн `invite` которого используется для рассылки приглашений друзьям. Это адаптированная версия исходного теста, созданного генератором для экшна `invite`.

```ruby
require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Создайте email и сохраните его для будущих утверждений
    email = UserMailer.create_invite('me@example.com',
                                     'friend@example.com', Time.now)

    # Отправить письмо, затем проверить, что оно попало в очередь
    assert_emails 1 do
      email.deliver_now
    end

    # Проверить тело отправленного письма, что оно содержит то, что мы ожидаем
    assert_equal ['me@example.com'], email.from
    assert_equal ['friend@example.com'], email.to
    assert_equal 'You have been invited by me@example.com', email.subject
    assert_equal read_fixture('invite').join, email.body.to_s
  end
end
```

В тесте мы посылаем письмо и сохраняем возвращенный объект в переменной `email`. Затем мы убеждаемся, что оно было послано (первое утверждение), затем, вот второй порции утверждений, мы убеждаемся, что `email` содержит в точности то, что мы ожидаем. Хелпер `read_fixture` используется для считывания содержимого из этого файла.

NOTE: `email.body.to_s` существует только когда присутствует одна часть (HTML или text). Если рассыльщик представляет обе, можно протестировать фикстуру для определенной части с помощью `email.text_part.body.to_s` или `email.html_part.body.to_s`.

Вот содержимое фикстуры `invite`:

```
Hi friend@example.com,

You have been invited.

Cheers!
```

Сейчас самое время понять немного больше о написании тестов для ваших рассыльщиков. Строчка `ActionMailer::Base.delivery_method = :test` в `config/environments/test.rb` устанавливает метод доставки в тестовом режиме, таким образом, письмо не будет фактически доставлено (полезно во избежание спама для ваших пользователей во время тестирования), но вместо этого оно будет присоединено к массиву (`ActionMailer::Base.deliveries`).

NOTE: Массив `ActionMailer::Base.deliveries` перезагружается автоматически только в тестах `ActionMailer::TestCase` и `ActionDispatch::IntegrationTest`. Если необходим чистый массив вне этих тестовых случаев, его можно перезагрузить вручную с помощью `ActionMailer::Base.deliveries.clear`

### Функциональное тестирование

Функциональное тестирование рассыльщиков предполагает не только проверку того, что тело письма, получатели и так далее правильны. В функциональных тестах писем мы вызываем методы доставки почты и проверяем, что надлежащие электронные письма присоединяются в перечень доставки. Это позволяет с большой долей уверенности предположить, что методы доставки выполняют свое задание. Возможно, более интересно, отправляет ли бизнес-логика электронную почту тогда, когда это от нее ожидается. Например, можно проверить, что операция по приглашению друзей надлежаще рассылает письма:

```ruby
require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  test "invite friend" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post invite_friend_url, params: { email: 'friend@example.com' }
    end
    invite_email = ActionMailer::Base.deliveries.last

    assert_equal "You have been invited by me@example.com", invite_email.subject
    assert_equal 'friend@example.com', invite_email.to[0]
    assert_match(/Hi friend@example\.com/, invite_email.body.to_s)
  end
end
```

(jobs-testing) Тестирование заданий
-----------------------------------

Так как ваши задания могут быть поставлены в очередь на различных уровнях приложения, вам нужно протестировать как сами задания (их поведение при получении из очереди), так и то, и что другие элементы правильно кладут их в очередь.

### Базовый тестовый случай

По умолчанию при генерации задания, также будет сгенерирован связанный тест в директории `test/jobs`. Вот пример теста с заданием по выставлению счета:

```ruby
require 'test_helper'

class BillingJobTest < ActiveJob::TestCase
  test 'that account is charged' do
    BillingJob.perform_now(account, product)
    assert account.reload.charged_for?(product)
  end
end
```

Это очень простой пример, он только проверяет, что задание делает работу так, как ожидается.

По умолчанию `ActiveJob::TestCase` устанавливает адаптер очереди `:test`, чтобы ваши задания выполнялись сразу. Это также позволяет убедиться, что все ранее выполненные и поставленные в очередь задания будут очищены до запуска любого теста, таким образом гарантируется, что в рамках каждого теста нет ранее выполненных заданий.

### Пользовательские утверждения и тестирование заданий внутри других компонент

Active Job поставляется с набором пользовательских утверждений, которые могут быть использованы для уменьшения уровня детализации тестов. Полный список утверждений смотрите в документации API для [`ActiveJob::TestHelper`](http://api.rubyonrails.org/classes/ActiveJob/TestHelper.html).

Хорошей практикой бывает убедиться, что ваши задания были поставлены в очередь или выполнены, там, где вы их вызываете (например, внутри контроллера). Именно тут пользовательские утверждения, предоставленные Active Job, особенно полезны. Например, в модели:

```ruby
require 'test_helper'

class ProductTest < ActiveJob::TestCase
  test 'billing job scheduling' do
    assert_enqueued_with(job: BillingJob) do
      product.charge(account)
    end
  end
end
```

Дополнительные ресурсы по тестированию
--------------------------------------

### Тестирование кода, зависимого от времени

Rails предоставляет встроенные вспомогательные методы, позволяющие убеждаться, что ваш зависимый от времени код работает, как ожидается.

Вот пример использования хелпера [`travel_to`](http://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel_to):

```ruby
# Допустим, что пользователю можно сделать подарок через месяц после регистрации.
user = User.create(name: 'Gaurish', activation_date: Date.new(2004, 10, 24))
assert_not user.applicable_for_gifting?
travel_to Date.new(2004, 11, 24) do
  assert_equal Date.new(2004, 10, 24), user.activation_date # внутри блока `travel_to` `Date.current` имитируется
  assert user.applicable_for_gifting?
end
assert_equal Date.new(2004, 10, 24), user.activation_date # Изменение было видно только внутри блока `travel_to`.
```

Обратитесь к [документации `ActiveSupport::Testing::TimeHelpers` API](http://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html) за более подробной информацией о доступных хелперах времени.
