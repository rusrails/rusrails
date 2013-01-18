# Варианты тестирования производительности

Тесты производительности Rails являются специальным типом интеграционных тестов, разработанным для бенчмаркинга и профилирования тестируемого кода. С тестами производительности можно определить, откуда идут проблемы вашего приложения с памятью или скоростью, и получить более глубокую картину об этих проблемах.

В только что созданном приложении на Rails, `test/performance/browsing_test.rb` содержит пример теста производительности:

```ruby
require 'test_helper'
require 'rails/performance_test_help'

class BrowsingTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { runs: 5, metrics: [:wall_time, :memory],
  #                          output: 'tmp/performance', formats: [:flat] }

  test "homepage" do
    get '/'
  end
end
```

Этот пример является простым случаем теста производительности для профилирования запроса GET к домашней странице приложения.

### Создание тестов производительности

Rails предоставляет генератор, названный `performance_test`, для создания новых тестов производительности:

```bash
$ rails generate performance_test homepage
```

Это создаст `homepage_test.rb` в директории `test/performance`:

```ruby
require 'test_helper'
require 'rails/performance_test_help'

class HomepageTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { runs: 5, metrics: [:wall_time, :memory],
  #                          output: 'tmp/performance', formats: [:flat] }

  test "homepage" do
    get '/'
  end
end
```

### Примеры

Давайте предположим, что ваше приложение имеет следующие контроллер и модель:

```ruby
# routes.rb
root to: 'home#dashboard'
resources :posts

# home_controller.rb
class HomeController < ApplicationController
  def dashboard
    @users = User.last_ten.includes(:avatars)
    @posts = Post.all_today
  end
end

# posts_controller.rb
class PostsController < ApplicationController
  def create
    @post = Post.create(params[:post])
    redirect_to(@post)
  end
end

# post.rb
class Post < ActiveRecord::Base
  before_save :recalculate_costly_stats

  def slow_method
    # I fire gallzilion queries sleeping all around
  end

  private

  def recalculate_costly_stats
    # CPU heavy calculations
  end
end
```

#### Пример с контроллером

Поскольку тесты производительности являются специальным видом интеграционного теста, можете использовать в них методы `get` и `post`.

Вот тест производительности для `HomeController#dashboard` и `PostsController#create`:

```ruby
require 'test_helper'
require 'rails/performance_test_help'

class PostPerformanceTest < ActionDispatch::PerformanceTest
  def setup
    # Приложение требует залогиненого пользователя
    login_as(:lifo)
  end

  test "homepage" do
    get '/dashboard'
  end

  test "creating new post" do
    post '/posts', post: { body: 'lifo is fooling you' }
  end
end
```

Более детально о методах `get` и `post` написано в руководстве по [тестированию приложений на Rails](/a-guide-to-testing-rails-applications).

#### Пример с моделью

Несмотря на то, что тесты производительности являются интеграционными тестами и поэтому ближе к циклу запрос/ответ по своей природе, вы также можете тестировать производительность кода модели:

```ruby
require 'test_helper'
require 'rails/performance_test_help'

class PostModelTest < ActionDispatch::PerformanceTest
  test "creation" do
    Post.create body: 'still fooling you', cost: '100'
  end

  test "slow method" do
    # Используем фикстуру posts(:awesome)
    posts(:awesome).slow_method
  end
end
```

### Режимы

Тесты производительности могут быть запущены в двух режимах: Бенчмаркинг и Профилирование.

#### Бенчмаркинг

Бенчмаркинг помогает найти как быстро выполняется каждый тест производительности. В режиме бенчмаркинга каждый случай тестирования выполняется **4 раза**.

Чтобы запустить тесты производительности в режиме бенчмаркинга:

```bash
$ rake test:benchmark
```

#### Профилирование

Профилирование помогает увидеть подробности теста производительности и предоставить углубленную картину медленных и памятепотребляемых частей. В режиме профилирования каждый случай тестирования запускается **1 раз**.

Чтобы запустить тесты производительности в режиме профилирования:

```bash
$ rake test:profile
```

### Метрики

Бенчмаркинг и профилирование запускают тесты производительности и выдают разные метрики. Доступность каждой метрики определена используемым интерпретатором - не все из них поддерживают все метрики - и используемым режимом. Краткое описание каждой метрики и их доступность для интерпретатора/режима описаны ниже.

#### Время разделения (Wall Time)

Время разделения измеряет реальное время, прошедшее в течение запуска теста. Оно зависит от любых других процессов, параллельно работающих в системе.

#### Время процесса (Process Time)

Время процесса измеряет время, затраченное процессом. Оно не зависит от любых других процессов, параллельно работающих в системе. Поэтому время процесса скорее всего будет постоянным для любого конкретного теста производительности, независимо от загрузки машины.

#### Память (Memory)

Память измеряет количество памяти, использованной в случае теста производительности.

#### Объекты (Objects)

Объекты измеряют число объектов, выделенных в случае теста производительности.

#### Запуски GC (GC Runs)

Запуски GC измеряют, сколько раз GC был вызван в случае теста производительности.

#### Время GC (GC Time)

Время GC измеряет количество времени, потраченного в GC для случая теста производительности.

#### Доступность метрик

##### Бенчмаркинг

| Интерпретатор | Wall Time | Process Time | CPU Time | User Time | Memory | Objects | GC Runs | GC Time |
| ------------- | --------- | ------------ | -------- | --------- | ------ | ------- | ------- | ------- |
| **MRI**       | да        | да           | да       | нет       | да     | да      | да      | да      |
| **REE**       | да        | да           | да       | нет       | да     | да      | да      | да      |
| **Rubinius**  | да        | нет          | нет      | нет       | да     | да      | да      | да      |
| **JRuby**     | да        | нет          | нет      | да        | да     | да      | да      | да      |

##### Профилирование

| Интерпретатор | Wall Time | Process Time | CPU Time | User Time | Memory | Objects | GC Runs | GC Time |
| ------------- | --------- | ------------ | -------- | --------- | ------ | ------- | ------- | ------- |
| **MRI**       | да        | да           | нет      | нет       | да     | да      | да      | да      |
| **REE**       | да        | да           | нет      | нет       | да     | да      | да      | да      |
| **Rubinius**  | да        | нет          | нет      | нет       | нет    | нет     | нет     | нет     |
| **JRuby**     | да        | нет          | нет      | нет       | нет    | нет     | нет     | нет     |

NOTE: Для профилирования под JRuby следует запустить `export JRUBY_OPTS="-Xlaunch.inproc=false --profile.api"` **перед** тестами производительности.

### Интерпретация результата

Тесты производительности выводят различные результаты в директорию `tmp/performance`, в зависимости от их режима и метрики.

#### Бенчмаркинг

В режиме бенчмаркинга тесты производительности выводят два типа результата:

##### Командная строка

Это основная форма результата в режиме бенчмаркинга. пример:

```bash
BrowsingTest#test_homepage (31 ms warmup)
           wall_time: 6 ms
              memory: 437.27 KB
             objects: 5,514
             gc_runs: 0
             gc_time: 19 ms
```

##### Файлы CSV

Результаты теста производительности также добавляются к файлам `.csv` в tmp/performance`. Напрмер, запуск дефолтного `BrowsingTest#test_homepage` создаст следующие пять файлов:

* BrowsingTest#test_homepage_gc_runs.csv
* BrowsingTest#test_homepage_gc_time.csv
* BrowsingTest#test_homepage_memory.csv
* BrowsingTest#test_homepage_objects.csv
* BrowsingTest#test_homepage_wall_time.csv

Так как результаты добавляются к этим файлам каждый раз, как тесты производительности запускаются, вы можете собирать данные за период времени. Это может быть полезным при анализе эффекта от изменения кода.

Образец вывода в `BrowsingTest#test_homepage_wall_time.csv`:

```bash
measurement,created_at,app,rails,ruby,platform
0.00738224999999992,2009-01-08T03:40:29Z,,3.0.0,ruby-1.8.7.249,x86_64-linux
0.00755874999999984,2009-01-08T03:46:18Z,,3.0.0,ruby-1.8.7.249,x86_64-linux
0.00762099999999993,2009-01-08T03:49:25Z,,3.0.0,ruby-1.8.7.249,x86_64-linux
0.00603075000000008,2009-01-08T04:03:29Z,,3.0.0,ruby-1.8.7.249,x86_64-linux
0.00619899999999995,2009-01-08T04:03:53Z,,3.0.0,ruby-1.8.7.249,x86_64-linux
0.00755449999999991,2009-01-08T04:04:55Z,,3.0.0,ruby-1.8.7.249,x86_64-linux
0.00595999999999997,2009-01-08T04:05:06Z,,3.0.0,ruby-1.8.7.249,x86_64-linux
0.00740450000000004,2009-01-09T03:54:47Z,,3.0.0,ruby-1.8.7.249,x86_64-linux
0.00603150000000008,2009-01-09T03:54:57Z,,3.0.0,ruby-1.8.7.249,x86_64-linux
0.00771250000000012,2009-01-09T15:46:03Z,,3.0.0,ruby-1.8.7.249,x86_64-linux
```

#### Профилирование

В режиме профилирования тесты производительности могут создавать разные типы результатов. Результат в командной строке всегда присутствует, но поддержка остальных зависит от используемого интерпретатора. Краткое описание каждого типа и их доступность для интерпретаторов представлены ниже.

##### Командная строка

Это очень простая форма вывода результата в режиме профилирования:

```bash
BrowsingTest#test_homepage (58 ms warmup)
        process_time: 63 ms
              memory: 832.13 KB
             objects: 7,882
```

##### Флэт (Flat)

Флэт показывает метрики - время. память и т.д. - потраченные на каждый метод. [Обратитесь к профессиональной документации по ruby для лучшего объяснения](http://ruby-prof.rubyforge.org/files/examples/flat_txt.html).

##### Граф (Graph)

Граф показывает, как долго каждый метод запускался, какие методы его вызывали, и какие методы вызывал он. [Обратитесь к профессиональной документации по ruby для лучшего объяснения](http://ruby-prof.rubyforge.org/files/examples/graph_txt.html).

##### Дерево (Tree)

Дерево это профилированная информация в формате calltree, используемом в [kcachegrind](http://kcachegrind.sourceforge.net/html/Home.html) и подобных инструментах.

##### Доступность вывода результатов

|              | Flat | Graph | Tree |
| ------------ | ---- | ----- | ---- |
| **MRI**      | да   | да    | да   |
| **REE**      | да   | да    | да   |
| **Rubinius** | да   | да    | нет  |
| **JRuby**    | да   | да    | нет  |

### Настройка тестовых прогонов

Запуски тестов могут быть настроены с помощью установки переменной класса `profile_options` в вашем классе теста.

```ruby
require 'test_helper'
require 'rails/performance_test_help'

class BrowsingTest < ActionDispatch::PerformanceTest
  self.profile_options = { runs: 5, metrics: [:wall_time, :memory] }

  test "homepage"
    get '/'
  end
end
```

В этом примере тест будет запущен 5 раз и измерит время разделения и память. Есть несколько конфигурационных опций:

| Опция      | Описание                                         | По умолчанию                      | Режим          |
| ---------- | ------------------------------------------------ | --------------------------------- | -------------- |
| `:runs`    | Количество запусков.                             | Бенчмаркинг: 4, Профилирование: 1 | Оба            |
| `:output`  | Директория, используемая для записи результатов. | `tmp/performance`                 | Оба            |
| `:metrics` | Используемые метрики.                            | Смотрите ниже.                    | Оба            |
| `:formats` | Форматы вывода результатов.                      | Смотрите ниже.                    | Профилирование |

У метрик и форматов разные значения по умолчанию, зависящие от используемого интерпретатора.

| Интерпретатор | Режим          | Метрики по умолчанию                                    | Форматы по умолчанию                           |
| ------------- | -------------- | ------------------------------------------------------- | ----------------------------------------------- |
| **MRI/REE**   | Бенчмаркинг    | `[:wall_time, :memory, :objects, :gc_runs, :gc_time]`   | N/A                                             |
|               | Профилирование | `[:process_time, :memory, :objects]`                    | `[:flat, :graph_html, :call_tree, :call_stack]` |
| **Rubinius**  | Бенчмаркинг    | `[:wall_time, :memory, :objects, :gc_runs, :gc_time]`   | N/A                                             |
|               | Профилирование | `[:wall_time]`                                          | `[:flat, :graph]`                               |
| **JRuby**     | Бенчмаркинг    | `[:wall_time, :user_time, :memory, :gc_runs, :gc_time]` | N/A                                             |
|               | Профилирование | `[:wall_time]`                                          | `[:flat, :graph]`                               |

Как вы уже, наверное, заметили, метрики и форматы определены с использованием массива символов, с [подчеркиванием](http://api.rubyonrails.org/classes/String.html#method-i-underscore) в каждом имени.

### Среда тестов производительности

Тесты производительности запускаются в среде `development`. Но запускаемые тесты производительности могут настраиваться следующими конфигурационными параметрами:

```bash
ActionController::Base.perform_caching = true
ActiveSupport::Dependencies.mechanism = :require
Rails.logger.level = ActiveSupport::Logger::INFO
```

Когда `ActionController::Base.perform_caching` устанавливается в `true`, тесты производительности будут вести себя так, как будто они в среде `production`.

### Установка Ruby, пропатченного GC

Чтобы взять лучшее от тестов производительности Rails под MRI, нужно создать специальный мощный двоичный файл Ruby.

Рекомендованные патчи для MRI находятся в директории [_patches_ RVM](https://github.com/wayneeseguin/rvm/tree/master/patches/ruby) для каждой определенной версии интерпретатора.

Что касается самой установки, можно либо сделать это просто, используя [RVM](http://rvm.io/), либо создать все из исходников, что несколько сложнее.

#### Установка с использованием RVM

Процесс установки пропатченного интерпретатора Ruby очень прост, если позволить всю работу выполнить RVM. Все нижеследующие команды RVM предоставят пропатченный интерпретатор Ruby:

```bash
$ rvm install 1.9.2-p180 --patch gcdata
$ rvm install 1.9.2-p180 --patch ~/Downloads/downloaded_gcdata_patch.patch
```

можно даже сохранить обычный интерпретатор, назначив имя пропатченному:

```bash
$ rvm install 1.9.2-p180 --patch gcdata --name gcdata
$ rvm use 1.9.2-p180 # your regular ruby
$ rvm use 1.9.2-p180-gcdata # your patched ruby
```

И все! Вы установили пропатченный интерпретатор Ruby.

#### Установка из исходников

Этот процесс более сложный, но не чересчур. Если ранее вы ни разу не компилировали двоичные файлы Ruby, нижеследующее приведет к созданию двоичных файлов Ruby в вашей домашней директории.

##### Скачать и извлечь

```bash
$ mkdir rubygc
$ wget <the version you want from ftp://ftp.ruby-lang.org/pub/ruby>
$ tar -xzvf <ruby-version.tar.gz>
$ cd <ruby-version>
```

##### Применить патч

```bash
$ curl https://raw.github.com/wayneeseguin/rvm/master/patches/ruby/1.9.2/p180/gcdata.patch | patch -p0 # если у вас 1.9.2!
```

##### Настроить и установить

Следующее установит Ruby в директорию `/rubygc` вашей домашней директории. Убедитесь, что заменили `<homedir>` полным путем к вашей фактической домашней директории.

```bash
$ ./configure --prefix=/<homedir>/rubygc
$ make && make install
```

##### Подготовить псевдонимы

Для удобства добавьте следующие строки в ваш `~/.profile`:

```bash
alias gcruby='~/rubygc/bin/ruby'
alias gcrake='~/rubygc/bin/rake'
alias gcgem='~/rubygc/bin/gem'
alias gcirb='~/rubygc/bin/irb'
alias gcrails='~/rubygc/bin/rails'
```

Не забудьте использовать псевдонимы с этого момента.

### Использование Ruby-Prof на MRI и REE

Добавьте Ruby-Prof в Gemfile вашего приложения, если хотите использовать бенчмаркинг/профилирование под MRI или REE:

```ruby
gem 'ruby-prof'
```

теперь запустите `bundle install` и все готово.
