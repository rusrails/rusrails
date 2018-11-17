Установка зависимостей для разработки
=====================================

Это руководство раскрывает, как настроить среду для разработки ядра Ruby on Rails.

После прочтения этого руководства, вы узнаете:

* Как настроить свою машину для разработки Rails

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

### Установка дополнительных инструментов и сервисов

Некоторые тесты Rails зависят от дополнительных инструментов, которые необходимо установить перед запуском этих определенных тестов.

Вот список дополнительных зависимостей каждого гема:

* Action Cable зависит от Redis
* Active Record зависит от SQLite3, MySQL и PostgreSQL
* Active Storage зависит от Yarn (дополнительно, Yarn зависит от [Node.js](https://nodejs.org/)), ImageMagick, FFmpeg, muPDF, и на macOS также XQuartz и Poppler.
* Active Support зависит от memcached и Redis
* Railties зависит от runtime окружения JavaScript, например от наличия установленного [Node.js](https://nodejs.org/).

Установите все зависимости, которые необходимы для надлежащего тестирования гема, в который вы будете вносить изменения.

NOTE: Документация Redis отговаривает от установки с помощью пакетных менеджеров, так как они обычно устаревшие. Установка из источника и настройка сервера прямолинейны и хорошо документированы в [документации Redis](https://redis.io/download#installation).

NOTE: Тесты Active Record _обязаны_ проходить как минимум для MySQL, PostgreSQL и SQLite3. Неуловимые различия между различными адаптерами были причинами отклонения многих изменений, которые неплохо выглядели при тестировании только для одного адаптера.

Ниже приведены инструкции, как установить все дополнительные инструменты для различных ОС.

#### macOS

На macOS можно использовать [Homebrew](https://brew.sh/) для установки всех дополнительных инструментов.

Чтобы все установить, запустите

```bash
$ brew bundle
```

Также нужно запустить каждый из установленных сервисов. Чтобы отобразить все доступные сервисы, запустите:

```bash
$ brew services list
```

Затем можно запустить каждый из этих сервисов один за другим подобным образом:

```bash
$ brew services start mysql
```

Замените `mysql` именем того сервиса, который вы хотите запустить.

#### Ubuntu

Чтобы все установить, запустите:

```bash
$ sudo apt-get update
$ sudo apt-get install sqlite3 libsqlite3-dev
    mysql-server libmysqlclient-dev
    postgresql postgresql-client postgresql-contrib libpq-dev
    redis-server memcached imagemagick ffmpeg mupdf mupdf-tools

# Install Yarn
$ curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
$ echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
$ sudo apt-get install yarn
```

#### Fedora или CentOS

Чтобы все установить, запустите:

```bash
$ sudo dnf install sqlite-devel sqlite-libs
    mysql-server mysql-devel
    postgresql-server postgresql-devel
    redis memcached imagemagick ffmpeg mupdf

# Install Yarn
# Используйте эту команду, если у вас нет установленной Node.js
$ curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
# Если у вас есть установленная Node.js, используйте эту команду
$ curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
$ sudo dnf install yarn
```

#### Arch Linux

#### MySQL и PostgreSQL

Чтобы все установить, запустите:

```bash
$ sudo pacman -S sqlite
    mariadb libmariadbclient mariadb-clients
    postgresql postgresql-libs
    redis memcached imagemagick ffmpeg mupdf mupdf-tools poppler
    yarn
$ sudo systemctl start redis
```

NOTE: Если вы запускаете на Arch Linux, MySQL больше не поддерживается, поэтому вам нужно вместо него использовать MariaDB (смотрите [этот анонс](https://www.archlinux.org/news/mariadb-replaces-mysql-in-repositories/)).

#### FreeBSD

Чтобы все установить, запустите:

```bash
# pkg install sqlite3
    mysql80-client mysql80-server
    postgresql11-client postgresql11-server
    memcached imagemagick ffmpeg mupdf
    yarn
# portmaster databases/redis
```

Или установить все с помощью портов (эти пакеты расположены в папке `databases`).

NOTE: Если у вас затруднения при установке MySQL, обратитесь к
[документации MySQL](https://dev.mysql.com/doc/refman/8.0/en/freebsd-installation.html).

### Конфигурация базы данных

Имеется ряд дополнительных шагов, необходимых для конфигурации движка баз данных, требуемых для запуска тестов Active Record.

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

Аутентификация PostgreSQL работает по-другому. Чтобы настроить среду разработки для своего аккаунта на Linux или BSD, просто запустите:

```bash
$ sudo -u postgres createuser --superuser $USER
```

и для macOS:

```bash
$ createuser --superuser $USER
```

Затем нужно создать тестовые базы данных для MySQL и PostgreSQL с помощью:

```bash
$ cd activerecord
$ bundle exec rake db:create
```

NOTE: Вы увидите следующее предупреждение (или локализованное предупреждение) при активации расширения HStore в PostgreSQL 9.1.x или ранее: "WARNING: => is deprecated as an operator".

Можно создать тестовые базы данных для каждого движка базы данных отдельно:

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
$ bundle exec rake db:postgresql:build
```

Можно удалить базы данных с помощью:

```bash
$ cd activerecord
$ bundle exec rake db:drop
```

NOTE: Использование задачи Rake для создания тестовых баз данных позволяет убедиться, что они имеют правильные кодировки и сортировки.

Если вы используете другую базу данных, ищите в файле `activerecord/test/config.yml` или `activerecord/test/config.example.yml` информацию по соединению по умолчанию. Можно отредактировать `activerecord/test/config.yml`, чтобы представить другие учетные данные для вашей машины, если необходимо, но, очевидно, вы не должны отправлять такие изменения обратно в Rails.

### Установка зависимостей JavaScript

Документация Redis отговаривает от установки с помощью пакетных менеджеров, так как они обычно устаревшие. Установка из исходников и запуск сервера просто и хорошо документированы в [документации Redis](https://redis.io/download#installation).

#### Установка Redis из пакетного менеджера

Если вы установили Yarn, необходимо установить зависимости javascript:

```bash
$ cd activestorage
$ yarn install
```

### Установка гема Bundler

Получите последнюю версию [Bundler](https://bundler.io/)

```bash
$ gem install bundler
$ gem update bundler
```

и запустите:

```bash
$ bundle install
```

или:

```bash
$ bundle install --without db
```

если вы не хотите запускать тесты Active Record.

### Вносите вклад в Rails

После того, как вы все настроили, прочитайте, как можно начать [вносить свой вклад](/contributing_to_ruby_on_rails#running-an-application-against-your-local-branch).
