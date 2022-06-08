Установка зависимостей для разработки
=====================================

Это руководство раскрывает, как настроить среду для разработки ядра Ruby on Rails.

После прочтения этого руководства, вы узнаете:

* Как настроить свою машину для разработки Rails

--------------------------------------------------------------------------------

Другие способы настроить вашу среду
-----------------------------------

Если вы не хотите настраивать Rails для разработки на локальной машине, можно использовать Codespaces, плагин VS Code Remote или rails-dev-box. Больше об этих опциях можно прочитать [здесь](/contributing_to_ruby_on_rails#setting-up-a-development-environment).

Локальная разработка
--------------------

Если хотите разрабатывать Ruby on Rails локально на своей машине, выполните следующие шаги.

### Установите Git

Ruby on Rails использует Git для контроля кода. На [домашней странице Git](https://git-scm.com/) есть инструкции по установке. Также есть ряд онлайн ресурсов, которые помогут познакомиться с Git.

### Клонируйте репозиторий Ruby on Rails

Перейдите в папку, в которую вы хотите скачать исходный код Ruby on Rails (он создаст свою собственную поддиректорию `rails`), и запустите:

```bash
$ git clone https://github.com/rails/rails.git
$ cd rails
```

### Установка дополнительных инструментов и сервисов

Некоторые тесты Rails зависят от дополнительных инструментов, которые необходимо установить перед запуском этих определенных тестов.

Вот список дополнительных зависимостей каждого гема:

* Action Cable зависит от Redis
* Active Record зависит от SQLite3, MySQL и PostgreSQL
* Active Storage зависит от Yarn (дополнительно, Yarn зависит от [Node.js](https://nodejs.org/)), ImageMagick, libvips, FFmpeg, muPDF, Poppler, а на macOS также XQuartz.
* Active Support зависит от memcached и Redis
* Railties зависит от runtime окружения JavaScript, например от наличия установленного [Node.js](https://nodejs.org/).

Установите все зависимости, которые необходимы для надлежащего тестирования гема, в который вы будете вносить изменения. Как установить эти сервисы для macOS, Ubuntu, Fedora/CentOS, Arch Linux и FreeBSD, рассказано ниже.

NOTE: Документация Redis отговаривает от установки с помощью пакетных менеджеров, так как они обычно устаревшие. Установка из источника и настройка сервера прямолинейны и хорошо документированы в [документации Redis](https://redis.io/download#installation).

NOTE: Тесты Active Record _обязаны_ проходить как минимум для MySQL, PostgreSQL и SQLite3. Ваш патч будет отвергнут, если он был протестирован только для единственного адаптера, если только изменение и тесты не специфичные для адаптера.

Ниже приведены инструкции, как установить все дополнительные инструменты для различных операционных систем.

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

##### Потенциальные проблемы

Этот раздел описывает некоторые потенциальные проблемы, с которыми вы можете столкнуться при использовании нативных расширений macOS, в частности при установке гема mysql2 при локальной разработке. Эта документация является предметом для изменения, и может быть некорректной, если Apple внесет изменения в среду разработки для Rails.

Чтобы скомпилировать гем `mysql2` на macOS, нужно сделать следующее:

1) Установить `openssl@1.1` (не `openssl@3`)
2) Скомпилировать Ruby с `openssl@1.1`
3) Установить флаги компилятора в конфигурации bundle для `mysql2`.

Если установлены оба `openssl@1.1` и `openssl@3`, нужно сообщить Ruby использовать `openssl@1.1`, для того, чтобы Rails установил `mysql2`.

В вашем `.bash_profile` установите `PATH` и `RUBY_CONFIGURE_OPTS` указывающим на `openssl@1.1`:

```
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
```

В `~/.bundle/config` установите следующее для `mysql2`. Убедитесь, что удалили все другие вхождения для `BUNDLE_BUILD__MYSQL2`:

```
BUNDLE_BUILD__MYSQL2: "--with-ldflags=-L/usr/local/opt/openssl@1.1/lib --with-cppflags=-L/usr/local/opt/openssl@1.1/include"
```

Установив эти флажки до установки Ruby и установки Rails, вы сможете получить работающую локальную среду разработки на macOS.

#### Ubuntu

Чтобы все установить, запустите:

```bash
$ sudo apt-get update
$ sudo apt-get install sqlite3 libsqlite3-dev mysql-server libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils

# Install Yarn
$ curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
$ echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
$ sudo apt-get install yarn
```

#### Fedora или CentOS

Чтобы все установить, запустите:

```bash
$ sudo dnf install sqlite-devel sqlite-libs mysql-server mysql-devel postgresql-server postgresql-devel redis memcached imagemagick ffmpeg mupdf libxml2-devel vips poppler-utils

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
$ sudo pacman -S sqlite mariadb libmariadbclient mariadb-clients postgresql postgresql-libs redis memcached imagemagick ffmpeg mupdf mupdf-tools poppler yarn libxml2 libvips poppler
$ sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
$ sudo systemctl start redis mariadb memcached
```

NOTE: Если вы запускаете на Arch Linux, MySQL больше не поддерживается, поэтому вам нужно вместо него использовать MariaDB (смотрите [этот анонс](https://www.archlinux.org/news/mariadb-replaces-mysql-in-repositories/)).

#### FreeBSD

Чтобы все установить, запустите:

```bash
$ sudo pkg install sqlite3 mysql80-client mysql80-server postgresql11-client postgresql11-server memcached imagemagick6 ffmpeg mupdf yarn libxml2 vips poppler-utils
# portmaster databases/redis
```

Или установить все с помощью портов (эти пакеты расположены в папке `databases`).

NOTE: Если у вас проблемы при установке MySQL, обратитесь к [документации MySQL](https://dev.mysql.com/doc/refman/en/freebsd-installation.html).

### Конфигурация базы данных

Имеется ряд дополнительных шагов, необходимых для конфигурации движка баз данных, требуемых для запуска тестов Active Record.

Аутентификация PostgreSQL работает по-другому. Чтобы настроить среду разработки для своего аккаунта на Linux или BSD, просто запустите:

```bash
$ sudo -u postgres createuser --superuser $USER
```

и для macOS:

```bash
$ createuser --superuser $USER
```

MySQL создаст пользователей при создании баз данных. Задача предполагает, что ваш пользователь `root` без пароля.

Затем нужно создать тестовые базы данных для MySQL и PostgreSQL с помощью:

```bash
$ bundle exec rake db:create
```

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

Если вы используете другую базу данных, ищите в файле `activerecord/test/config.yml` или `activerecord/test/config.example.yml` информацию по соединению по умолчанию. Можно отредактировать `activerecord/test/config.yml`, чтобы представить другие учетные данные для вашей машины, но, очевидно, вы не должны отправлять такие изменения обратно в Rails.

### Установка зависимостей JavaScript

Документация Redis отговаривает от установки с помощью пакетных менеджеров, так как они обычно устаревшие. Установка из исходников и запуск сервера просто и хорошо документированы в [документации Redis](https://redis.io/download#installation).

#### Установка Redis из пакетного менеджера

Если вы установили Yarn, необходимо установить зависимости JavaScript:

```bash
$ cd activestorage
$ yarn install
```

### Установка зависимостей гемов

Гемы устанавливаются с помощью [Bundler](https://bundler.io/), который поставляется вместе с Ruby.

Чтобы установить Gemfile для Rails, запустите:

```bash
$ bundle install
```

Если вы не хотите запускать тесты Active Record, можно запустить:

```bash
$ bundle install --without db
```

### Вносите вклад в Rails

После того, как вы все настроили, прочитайте, как можно начать [вносить свой вклад](/contributing_to_ruby_on_rails#running-an-application-against-your-local-branch).
