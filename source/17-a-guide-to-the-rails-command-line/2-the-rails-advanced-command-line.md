# Продвинутая командная строка Rails

Более продвинутое использование командной строки сфокусировано на полезных (даже иногда удивляющих) опциях утилит, и подгонке утилит к вашим потребностям и особенностям рабочего процесса. Сейчас мы перечислим трюки из рукава Rails.

### Rails с базами данными и SCM

При создании нового приложения на Rails, можно выбрать, какой тип базы данных и какой тип системы управления исходным кодом (SCM) собирается использовать ваше приложение. Это сэкономит вам несколько минут и, конечно, несколько строк.

Давайте посмотрим, что могут сделать для нас опции `--git` и `--database=postgresql`:

```bash
$ mkdir gitapp
$ cd gitapp
$ git init
Initialized empty Git repository in .git/
$ rails new . --git --database=postgresql
      exists
      create  app/controllers
      create  app/helpers
...
...
      create  tmp/cache
      create  tmp/pids
      create  Rakefile
add 'Rakefile'
      create  README.rdoc
add 'README.rdoc'
      create  app/controllers/application_controller.rb
add 'app/controllers/application_controller.rb'
      create  app/helpers/application_helper.rb
...
      create  log/test.log
add 'log/test.log'
```

Мы создали директорию **gitapp** и инициализировали пустой репозиторий перед тем, как Rails добавил бы созданные им файлы в наш репозиторий. Давайте взглянем, что он нам поместил в конфигурацию базы данных:

```bash
$ cat config/database.yml
# PostgreSQL. Versions 8.2 and up are supported.
#
# Install the pg driver:
#   gem install pg
# On OS X with Homebrew:
#   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
# On OS X with MacPorts:
#   gem install pg -- --with-pg-config=/opt/local/lib/postgresql84/bin/pg_config
# On Windows:
#   gem install pg
#       Choose the win32 build.
#       Install PostgreSQL and put its /bin directory on your path.
#
# Configure Using Gemfile
# gem 'pg'
#
development:
  adapter: postgresql
  encoding: unicode
  database: gitapp_development
  pool: 5
  username: gitapp
  password:
...
...
```

Она также создала несколько строчек в нашей конфигурации database.yml, соответствующих нашему выбору PostgreSQL как базы данных. Единственная хитрость с использованием опции SCM состоит в том, что сначала нужно создать директорию для приложения, затем инициализировать ваш SCM, и лишь затем можно запустить команду `rails new` для создания основы вашего приложения.
