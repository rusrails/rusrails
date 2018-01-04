Установка зависимостей для разработки
=====================================

Это руководство раскрывает, как настроить среду для разработки ядра Ruby on Rails.

После прочтения этого руководства, вы узнаете:

* Как настроить свою машину для разработки Rails
* Как запустить определенную группу юнит-тестов из тестового набора Rails
* Как работает часть тестового набора Rails, относящаяся к Active Record

--------------------------------------------------------------------------------

Простой способ
--------------

Простейшим и рекомендованным способом получить среду разработки, готовую для программирования, является использование [Rails development box](https://github.com/rails/rails-dev-box).

Сложный способ
--------------

В случае, если нет возможности использовать Rails development box, вот шаги для создания среды разработки для ядра Ruby on Rails.

### Установите Git

Ruby on Rails использует Git для контроля кода. На [домашней странице Git](https://git-scm.com/) есть инструкции по установке. Также в сети есть ряд ресурсов, которые помогут познакомиться с Git:

* [Курс Try Git](https://try.github.io/) — это интерактивный курс, который научит основам.
* [Официальная документация](https://git-scm.com/documentation) довольно объемная, а также содержит несколько видео с основами Git.
* [Everyday Git](https://schacon.github.io/git/everyday.html) научит достаточному, чтобы работать с Git.
* [GitHub](https://help.github.com) предлагает ссылки на ряд ресурсов по Git.
* [Pro Git](https://git-scm.com/book) — это целая книга о Git с лицензией Creative Commons.

### Клонируйте репозиторий Ruby on Rails

Перейдите в папку, в которой вы хотите разместить исходный код Ruby on Rails (он создаст свою собственную поддиректорию `rails`), и запустите:

```bash
$ git clone https://github.com/rails/rails.git
$ cd rails
```

### Настройте и запустите тесты

Тестовый набор должен проходить для любого отправляемого кода. Вне зависимости, пишете ли вы новый код, или вычисляете чей-то, вам нужно иметь возможность запускать тесты.

Сначала установите SQLite3 и его файлы для разработки для гема `sqlite3`. Пользователи macOS это могут сделать так:

```bash
$ brew install sqlite3
```

На Ubuntu это делается так:

```bash
$ sudo apt-get install sqlite3 libsqlite3-dev
```

Если у вас Fedora или CentOS, то так

```bash
$ sudo yum install libsqlite3x libsqlite3x-devel
```

Если у вас Arch Linux, нужно запустить:

```bash
$ sudo pacman -S sqlite
```

Для пользователей FreeBSD, это делается так:

```bash
# pkg install sqlite3
```

Или скомпилируйте порт `databases/sqlite3`.

Получите последнюю версию [Bundler](https://bundler.io/)

```bash
$ gem install bundler
$ gem update bundler
```

и запустите:

```bash
$ bundle install --without db
```

Эта команда установит все зависимости, кроме Ruby-драйверов MySQL и PostgreSQL. К ним мы скоро вернемся.

NOTE: Если вы хотите запустить тесты, использующие memcached, необходимо убедиться, что он у вас установлен и запущен.

Можно использовать [Homebrew](https://brew.sh/) для установки memcached на macOS:

```bash
$ brew install memcached
```

На Ubuntu можно установить его с помощью apt-get:

```bash
$ sudo apt-get install memcached
```

Или использовать yum на Fedora или CentOS:

```bash
$ sudo yum install memcached
```

Если вы запускаете на Arch Linux:

```bash
$ sudo pacman -S memcached
```

Для пользователей FreeBSD, это делается так:

```bash
# pkg install memcached
```

Альтернативно можно скомпилировать порт `databases/memcached`.

Теперь, когда установлены зависимости, можно запустить тестовый набор с помощью:

```bash
$ bundle exec rake test
```

Также можно запустить тесты для отдельного компонента, например Action Pack, перейдя в его директорию и выполнив ту же самую команду:

```bash
$ cd actionpack
$ bundle exec rake test
```

Если хотите запустить тесты, расположенные в определенной директории, используйте переменную среды `TEST_DIR`. Например, это запустит тесты только в директории `railties/test/generators`:

```bash
$ cd railties
$ TEST_DIR=generators bundle exec rake test
```

Можно запустить тесты для определенного файла, используя:

```bash
$ cd actionpack
$ bundle exec ruby -Itest test/template/form_helper_test.rb
```

Или можно запустить отдельный тест в определенном файле:

```bash
$ cd actionpack
$ bundle exec ruby -Itest path/to/test.rb -n test_name
```

### Настройка Railties

Некоторые тесты Railties зависят от окружения JavaScript runtime, такого как [Node.js](https://nodejs.org/).

### Настройка Active Record

Тестовый набор Active Record запускается три раза: один для SQLite3, один для MySQL, и один для PostgreSQL. Мы собираемся показать, как настроить среду для них.

WARNING: Если вы работаете с кодом, вы _обязаны_ убедиться, что тесты проходят как минимум для MySQL, PostgreSQL и SQLite3. Тонкости в различии между различными адаптерами лежали в основе отклонения многих изменений, которые выглядели хорошо, когда их тестировали только на MySQL.

#### Конфигурация базы данных

Тестовый набор Active Record требует пользовательский файл настроек: `activerecord/test/config.yml`. Пример представлен в `activerecord/test/config.example.yml`, который можно скопировать и использовать в своей среде.

#### MySQL и PostgreSQL

Чтобы запускать набор для MySQL и PostgreSQL, нам нужны их гемы. Сначала установите серверы, их клиентские библиотеки и их файлы для разработки.

На macOS можно выполнить:

```bash
$ brew install mysql
$ brew install postgresql
```

Чтобы их запустить, следуйте инструкциям Homebrew.

На Ubuntu просто запустите:

```bash
$ sudo apt-get install mysql-server libmysqlclient-dev
$ sudo apt-get install postgresql postgresql-client postgresql-contrib libpq-dev
```

На Fedora или CentOS просто запустите:

```bash
$ sudo yum install mysql-server mysql-devel
$ sudo yum install postgresql-server postgresql-devel
```

Если вы запускаете на Arch Linux, MySQL больше не поддерживается, поэтому вам нужно вместо него использовать MariaDB (смотрите [этот анонс](https://www.archlinux.org/news/mariadb-replaces-mysql-in-repositories/)):

```bash
$ sudo pacman -S mariadb libmariadbclient mariadb-clients
$ sudo pacman -S postgresql postgresql-libs
```

Пользователи FreeBSD должны запустить следующее:

```bash
# pkg install mysql56-client mysql56-server
# pkg install postgresql94-client postgresql94-server
```

Или установить их с помощью портов (они расположены в папке `databases`). Если у вас затруднения при установке MySQL, обратитесь к
[документации MySQL](http://dev.mysql.com/doc/refman/5.1/en/freebsd-installation.html).

После этого запустите:

```bash
$ rm .bundle/config
$ bundle install
```

Сперва нам нужно удалить `.bundle/config`, так как Bundler запоминает, что мы не хотели устанавливать группу "db" (альтернативно вы можете отредактировать этот файл).

Чтобы иметь возможность запускать тестовый набор на MySQL, необходимо создать пользователя с именем `rails` с привилегиями на тестовые базы данных:

```bash
$ mysql -uroot -p

mysql> CREATE USER 'rails'@'localhost';
mysql> GRANT ALL PRIVILEGES ON activerecord_unittest.*
       to 'rails'@'localhost';
mysql> GRANT ALL PRIVILEGES ON activerecord_unittest2.*
       to 'rails'@'localhost';
mysql> GRANT ALL PRIVILEGES ON inexistent_activerecord_unittest.*
       to 'rails'@'localhost';
```

и создать тестовые базы данных:

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
```

Аутентификация PostgreSQL работает по-другому. Чтобы настроить среду разработки для своего аккаунта на Linux или BSD, просто запустите:

```bash
$ sudo -u postgres createuser --superuser $USER
```

и для macOS:

```bash
$ createuser --superuser $USER
```

Затем нужно создать тестовые базы данных с помощью:

```bash
$ cd activerecord
$ bundle exec rake db:postgresql:build
```

Можно создать базы данных для обоих PostgreSQL и MySQL с помощью:

```bash
$ cd activerecord
$ bundle exec rake db:create
```

Можно очистить базы данных с помощью:

```bash
$ cd activerecord
$ bundle exec rake db:drop
```

NOTE: Использование задачи Rake для создания тестовых баз данных позволяет убедиться, что они имеют правильные кодировки и сортировки.

NOTE: Вы увидите следующее предупреждение (или локализованное предупреждение) при активации расширения HStore в PostgreSQL 9.1.x или ранее: "WARNING: => is deprecated as an operator".

Если вы используете другую базу данных, ищите в файле `activerecord/test/config.yml` или `activerecord/test/config.example.yml` информацию по соединению по умолчанию. Можно отредактировать `activerecord/test/config.yml`, чтобы представить другие учетные данные для вашей машины, если необходимо, но, очевидно, вы не должны отправлять такие изменения обратно в Rails.

### Настройка Action Cable

Action Cable использует Redis в качестве адаптера подписки по умолчанию ([подробнее](/action-cable-overview#broadcasting)). Таким образом, чтобы тесты Action Cable проходили, необходимо установить и запустить Redis.

#### Установка Redis из исходников

Документация Redis отговаривает от установки с помощью пакетных менеджеров, так как они обычно устаревшие. Установка из исходников и запуск сервера просто и хорошо документированы в [документации Redis](https://redis.io/download#installation).

#### Установка Redis из пакетного менеджера

В macOS можно запустить:

```bash
$ brew install redis
```

Следуйте инструкциям Homebrew чтобы его запустить.

На Ubuntu просто запустите:

```bash
$ sudo apt-get install redis-server
```

В Fedora или CentOS (требует включенный EPEL) просто запустите:

```bash
$ sudo yum install redis
```

Если используете Arch Linux, просто запустите:

```bash
$ sudo pacman -S redis
$ sudo systemctl start redis
```

Пользователям FreeBSD нужно запустить следующее:

```bash
# portmaster databases/redis
```

### Настройка Active Storage (Rails 5.2)

При работе с Active Storage важно отметить, что следует устанавливать зависимости JavaScript во время работы над этим разделом кодовой базы. Чтобы установить эти зависимости, в системе должен быть доступен Yarn, пакетный менеджер Node.js. Предпосылкой для установки этого пакетного менеджера является установка [Node.js](https://nodejs.org).

На macOS просто запустите:

```bash
brew install yarn
```

На Ubuntu просто запустите:

```bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt-get update && sudo apt-get install yarn
```

На Fedora или CentOS просто запустите:

```bash
sudo wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo

sudo yum install yarn
```

Наконец, после установки Yarn нужно будет запустить следующую команду внутри директории `activestorage` для установки зависимостей:

```bash
yarn install
```
