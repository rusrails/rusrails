# Настройка Action Mailer

Следующие конфигурационные опции лучше всего делать в одном из файлов среды разработки (environment.rb, production.rb, и т.д...)

| Конфигурация            | Описание |
| ----------------------- | -------- |
| `template_root`         | Определяет основу, от которой будут делаться ссылки на шаблоны.|
| `logger`                | logger исользуется для создания информации на ходу, если возможно. Можно установить как `nil` для отсутствия логирования. Совместим как с `Logger` в Ruby, так и с логером `Log4r`.|
| `smtp_settings`         | Позволяет подробную настройку для метода доставки `:smtp`:<ul><li>`:address` - Позволяет использовать удаленный почтовый сервер. Просто измените его изначальное значение "localhost".</li><li>`:port`  - В случае, если ваш почтовый сервер не работает с 25 портом, можете изменить его.</li><li>`:domain` - Если необходимо определить домен HELO, это можно сделать здесь.</li><li>`:user_name` - Если почтовый сервер требует аутентификацию, установите имя пользователя этой настройкой.</li><li>`:password` - Если почтовый сервер требует аутентификацию, установите пароль этой настройкой. </li><li>`:authentication` - Если почтовый сервер требует аутентификацию, здесь нужно определить тип аутентификации. Это один из символов `:plain`, `:login`, `:cram_md5`.</li><li>`:enable_starttls_auto` - Установите его в `false` если есть проблема с сертификатом сервера, которую вы не можете решить.</li></ul>|
| `sendmail_settings`     | Позволяет переопределить опции для метода доставки `:sendmail`.<ul><li>`:location` - Расположение исполняемого sendmail. По умолчанию `/usr/sbin/sendmail`.</li><li>`:arguments` - Аргументы командной строки. По умолчанию `-i -t`.</li></ul>|
| `raise_delivery_errors` | Должны ли быть вызваны ошибки, если email не может быть доставлен. Это работает, если внешний сервер email настроен на немедленную доставку.|
| `delivery_method`       | Определяет метод доставки. Возможные значения `:smtp` (по умолчанию), `:sendmail`, `:file` и `:test`.|
| `perform_deliveries`    | Определяет, должны ли методы deliver_* фактически выполняться. По умолчанию должны, но это можно отключить для функционального тестирования.|
| `deliveries`            | Содержит массив всех электронных писем, отправленных через Action Mailer с помощью delivery_method :test. Очень полезно для юнит- и функционального тестирования.|
| `default_options`       | Позволит вам установить значения по умолчанию для опций метода `mail` (`:from`, `:reply_to` и т.д.).|

### Пример настройки Action Mailer

Примером может быть добавление следующего в подходящий файл `config/environments/$RAILS_ENV.rb`:

```ruby
config.action_mailer.delivery_method = :sendmail
# Defaults to:
# config.action_mailer.sendmail_settings = {
#   location: '/usr/sbin/sendmail',
#   arguments: '-i -t'
# }
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_options = {from: 'no-replay@example.org'}
```

### Настройка Action Mailer для GMail

Action Mailer теперь использует гем Mail, теперь это сделать просто, нужно добавить в файл `config/environments/$RAILS_ENV.rb`:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
+  port:                 587,
+  domain:               'baci.lindsaar.net',
+  user_name:            '<username>',
+  password:             '<password>',
+  authentication:       'plain',
+  enable_starttls_auto: true  }
```
