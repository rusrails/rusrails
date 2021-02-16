Обзор Active Storage
====================

В этом руководстве описывается, как прикреплять файлы к моделям Active Record.

После прочтения этого руководства вы узнаете:

* Как прикрепить один или несколько файлов к записи.
* Как удалить прикрепленный файл.
* Как создать ссылку на прикрепленный файл.
* Как использовать варианты (variants) для преобразования изображений.
* Как генерировать изображение файла, который не является изображением, например, PDF или видео.
* Как загружать файлы из браузеров прямо в сервисы хранения (storage service), минуя application серверы.
* Как очистить файлы, сохраненные во время тестирования.
* Как реализовать поддержку дополнительных сервисов хранения.

--------------------------------------------------------------------------------------------------------------

Что такое Active Storage?
-------------------------

Active Storage облегчает загрузку файлов в облачные хранилища данных, такие как Amazon S3, Google Cloud Storage или Microsoft Azure Storage, и прикрепляет эти файлы к объектам Active Record. Он поставляется с локальным на основе диска сервисом для разработки и тестирования, и поддерживает отзеркаливание (mirroring) файлов в подчиненных сервисах для резервного копирования и миграций.

Используя Active Storage приложение может преобразовывать изображения при загрузке с помощью [ImageMagick](https://www.imagemagick.org), генерировать изображение файла, который не является изображением, такого, например, как PDF или видео, и извлекать метаданные из произвольных файлов.

## Установка

Active Storage использует две таблицы в базе данных приложения названные `active_storage_blobs` и `active_storage_attachments`. После создания нового приложения (или апгрейда приложения до Rails 5.2), нужно запустить `bin/rails active_storage:install`, чтобы сгенерировать миграцию, которая создает эти таблицы. Используйте `bin/rails db:migrate` для запуска миграций.

WARNING: `active_storage_attachments` это полиморфная соединительная таблица, хранящая имена ваших классов моделей. Если имена ваших классов моделей меняются, необходимо запустить миграцию на эту таблицу, чтобы обновить соответствующие `record_type` новым именем вашего класса модели.

WARNING: Если используются UUID вместо чисел в качестве первичного ключа моделей, необходимо изменить тип столбца `record_id` для таблицы `active_storage_attachments` в соответствующей сгенерированной миграции.

Сервисы Active Storage объявляются в `config/storage.yml`. Для каждого сервиса, используемого в приложении, стоит указать имя и необходимую конфигурацию. В нижеприведенном примере объявляются три сервиса с именами `local`, `test` и `amazon`:

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  bucket: ""
  region: "" # e.g. 'us-east-1'
```

Скажите Active Storage, какой сервис использовать, установив `Rails.application.config.active_storage.service`. Поскольку каждая среда, скорее всего, использует различные сервисы, рекомендуется делать это отдельно для каждого окружения. Чтобы использовать сервис диска из предыдущего примера в среде разработки, нужно добавить следующее в `config/environments/development.rb`:

```ruby
# Хранение файлов локально.
config.active_storage.service = :local
```

Чтобы использовать сервис S3 в production, необходимо добавить следующее в
`config/environments/production.rb`:

```ruby
# Хранить файлы в Amazon S3.
config.active_storage.service = :amazon
```

Чтобы использовать тестовый сервис при тестировании, добавьте следующее в `config/environments/test.rb`:

```ruby
# Хранить загруженные файлы в локальной файловой системе во временной директории.
config.active_storage.service = :test
```

Подробнее о встроенных адаптерах сервиса (например, `Disk` и `S3`) и требуемой конфигурации написано ниже.

NOTE: Конфигурационные файлы, специфичные для среды, имеют приоритет: в production, к примеру, файл `config/storage/production.yml` (если существует) будет иметь приоритет перед файлом `config/storage.yml`.

### Сервис Disk

Объявление сервиса Disk в `config/storage.yml`:

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

### Сервис S3 (Amazon S3 и совместимые с S3 API)

Чтобы подключиться к Amazon S3, объявите сервис S3 в `config/storage.yml`:

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
```

Опционально предоставьте опции клиента и загрузки:

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
  http_open_timeout: 0
  http_read_timeout: 0
  retry_limit: 0
  upload:
    server_side_encryption: "" # 'aws:kms' или 'AES256'
```

TIP: Установите разумные лимиты HTTP timeout и retry в своем приложении. В некоторых сценариях неудачи конфигурация клиента AWS по умолчанию может держать соединение несколько минут, что приведет к очереди из запросов.

Добавьте гем [`aws-sdk-s3`](https://github.com/aws/aws-sdk-ruby) в `Gemfile`:

```ruby
gem "aws-sdk-s3", require: false
```

NOTE: Основные особенности Active Storage требуют следующих прав доступа: `s3:ListBucket`, `s3:PutObject`, `s3:GetObject` и `s3:DeleteObject`. Если есть дополнительные опции загрузки, сконфигурированные также как и настройка ACL, тогда могут потребоваться дополнительные права доступа.

NOTE: Если необходимо использовать переменные среды, стандартные файлы конфигурации SDK, профили, профили экземпляров IAM или роли задач, можно опустить ключи `access_key_id`, `secret_access_key` и `region` в приведенном выше примере. Сервис S3 поддерживает все опции аутентификации, описанные в [документации AWS SDK](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html).

Чтобы подключиться к совместимому с S3 API хранения объектов, такого как DigitalOcean Spaces, предоставьте `endpoint`:

```yaml
digitalocean:
  service: S3
  endpoint: https://nyc3.digitaloceanspaces.com
  access_key_id: ...
  secret_access_key: ...
  # ...и другие опции
```

### Сервис Microsoft Azure Storage

Объявление сервиса Azure Storage в `config/storage.yml`:

```yaml
azure:
  service: AzureStorage
  storage_account_name: ""
  storage_access_key: ""
  container: ""
```

Кроме того, необходимо добавить гем [`azure-storage-blob`](https://github.com/Azure/azure-storage-ruby) в `Gemfile`:

```ruby
gem "azure-storage-blob", require: false
```

### Сервис Google Cloud Storage

Объявление сервиса Google Cloud Storage в `config/storage.yml`:

```yaml
google:
  service: GCS
  credentials: <%= Rails.root.join("path/to/keyfile.json") %>
  project: ""
  bucket: ""
```

Опционально можно предоставить хэш credentials вместо пути к keyfile:

```yaml
google:
  service: GCS
  credentials:
    type: "service_account"
    project_id: ""
    private_key_id: <%= Rails.application.credentials.dig(:gcs, :private_key_id) %>
    private_key: <%= Rails.application.credentials.dig(:gcs, :private_key).dump %>
    client_email: ""
    client_id: ""
    auth_uri: "https://accounts.google.com/o/oauth2/auth"
    token_uri: "https://accounts.google.com/o/oauth2/token"
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs"
    client_x509_cert_url: ""
  project: ""
  bucket: ""
```

Кроме того, необходимо добавить гем [`google-cloud-storage`](https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/master/google-cloud-storage) в `Gemfile`:

```ruby
gem "google-cloud-storage", "~> 1.11", require: false
```

### Сервис Mirror

Существует возможность синхронизировать несколько сервисов, определив сервис отзеркаливания. Сервис отзеркаливания копирует загрузки и удаляет из двух или более подчиненных сервисов.

Сервисы отзеркаливания предназначены для временного использования в течение миграции между сервисами в production. Можно начать отзеркаливание в новый сервис, скопировав существующие файлы со старого сервиса на новый, а затем полностью перейти на новый сервис.

NOTE: Отзеркаливание не атомарно. Возможно, что загрузка будет успешной на основном сервисе и неуспешной на любом из подчиненных сервисов. Перед окончательным переходом на новый сервис, убедитесь, что все файлы были скопированы.

Определим каждый из требуемых сервисов, как описано выше. Будем ссылаться на них с помощью сервиса отзеркаливания.

```yaml
s3_west_coast:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""

s3_east_coast:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""

production:
  service: Mirror
  primary: s3_east_coast
  mirrors:
    - s3_west_coast
```

Хотя все вторичные сервисы получают загрузки, скачивания всегда обрабатываются основным сервисом.

Сервисы отзеркаливания совместимы с прямой загрузкой. Новые файлы загружаются непосредственно в основной сервис. Когда напрямую загруженный файл прикрепляется к записи, в очередь помещается фоновое задание для копирования его во вторичные сервисы.

### Публичный доступ

По умолчанию Active Storage предполагает приватный доступ к сервисам. Это означает генерацию подписанных одноразовых URL для бинарных объектов. Если вы предпочитаете сделать бинарные объекты публично доступными, укажите `public: true` в `config/storage.yml` вашего приложения:

```yaml
gcs: &gcs
  service: GCS
  project: ""

private_gcs:
  <<: *gcs
  credentials: <%= Rails.root.join("path/to/private_keyfile.json") %>
  bucket: ""

public_gcs:
  <<: *gcs
  credentials: <%= Rails.root.join("path/to/public_keyfile.json") %>
  bucket: ""
  public: true
```

Убедитесь, что ваши bucket правильно настроены для публичного доступа. Обратитесь к документации, как разрешить публичное чтение для сервисов хранения [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/block-public-access-bucket.html), [Google Cloud Storage](https://cloud.google.com/storage/docs/access-control/making-data-public#buckets) и [Microsoft Azure](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-manage-access-to-resources#set-container-public-access-level-in-the-azure-portal).

При конвертации существующего приложения на использование `public: true`, убедитесь в обновлении каждого отдельного файла в bucket, чтобы он был публично читаемый до переключения.

Прикрепление файлов к записям
-----------------------------

### `has_one_attached`

Макрос [`has_one_attached`][] устанавливает сопоставление (mapping) один-к-одному между записями и файлами. Каждая запись может содержать один прикрепленный файл.

Например, предположим, что в приложении имеется модель `User`. Если необходимо, чтобы у каждого пользователя был аватар, нужно определить модель `User` следующим образом:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
end
```

Далее можно создать пользователя с аватаром:

```erb
<%= form.file_field :avatar %>
```

```ruby
class SignupController < ApplicationController
  def create
    user = User.create!(user_params)
    session[:user_id] = user.id
    redirect_to root_path
  end

  private
    def user_params
      params.require(:user).permit(:email_address, :password, :avatar)
    end
end
```

Вызов [`avatar.attach`][Attached::One#attach] прикрепляет аватар к существующему пользователю:

```ruby
user.avatar.attach(params[:avatar])
```

Вызов [`avatar.attached?`][Attached::One#attached?] определяет, есть ли у конкретного пользователя аватар:

```ruby
user.avatar.attached?
```

Иногда необходимо переопределить сервис по умолчанию для определенного вложения. Указать сервис для вложения можно с помощью опции `service`:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

Можно настроить определенные варианты для вложения, вызвав метод `variant` на вложенном прикрепляемом объекте:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize: "100x100"
  end
end
```

Вызовите `avatar.variant(:thumb)` для получения варианта thumb аватарки:

```erb
<%= image_tag user.avatar.variant(:thumb) %>
```

[`has_one_attached`]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Model.html#method-i-has_one_attached
[Attached::One#attach]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-attach
[Attached::One#attached?]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-attached-3F

### `has_many_attached`

Макрос [`has_many_attached`][] устанавливает отношение один-ко-многим между записями и файлами. У каждой записи может быть много прикрепленных файлов.

Например, предположим, что в приложении имеется модель `Message`. Если необходимо, чтобы у каждого сообщения было много изображений, нужно определить модель `Message` следующим образом:

```ruby
class Message < ApplicationRecord
  has_many_attached :images
end
```

Далее можно создать сообщение с изображениями:

```ruby
class MessagesController < ApplicationController
  def create
    message = Message.create!(message_params)
    redirect_to message
  end

  private
    def message_params
      params.require(:message).permit(:title, :content, images: [])
    end
end
```

Вызов [`images.attach`][Attached::Many#attach] добавляет новые изображения к существующему сообщению:

```ruby
@message.images.attach(params[:images])
```

Вызов [`images.attached?`][Attached::Many#attached?] определяет, есть ли у конкретного сообщения какие-либо изображения:

```ruby
@message.images.attached?
```

Переопределить сервис по умолчанию можно так же, как и для `has_one_attached`, с помощью опции `service`:

```ruby
class Message < ApplicationRecord
  has_many_attached :images, service: :s3
end
```

Настроить определенные варианты можно так же, как и для `has_one_attached`, вызвав метод `variant` на вложенном прикрепляемом объекте:

```ruby
class Message < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize: "100x100"
  end
end
```

[`has_many_attached`]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Model.html#method-i-has_many_attached
[Attached::Many#attach]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Many.html#method-i-attach
[Attached::Many#attached?]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Many.html#method-i-attached-3F

### Прикрепление объектов File/IO

Иногда необходимо прикрепить файл, который не поступает через HTTP-запрос. Например, может понадобиться прикрепить файл, сгенерированный на диске, или загрузить файл из введенного пользователем URL. Также можно захотеть прикрепить файл фикстур в тесте модели. Чтобы сделать это, предоставьте хэш, содержащий как минимум открытый объект IO и имя файла:

```ruby
@message.image.attach(io: File.open('/path/to/file'), filename: 'file.pdf')
```

Когда это возможно, предоставьте тип содержимого. Active Storage пытается определить тип содержимого файла по его данным. Если он не может этого сделать, он возвращает тип содержимого, которое предоставляется.

```ruby
@message.image.attach(io: File.open('/path/to/file'), filename: 'file.pdf', content_type: 'application/pdf')
```

Можно пропустить определение типа содержимого из данных, передав `identify: false` вместе с `content_type`.

```ruby
@message.image.attach(
  io: File.open('/path/to/file'),
  filename: 'file.pdf',
  content_type: 'application/pdf',
  identify: false
)
```

Если не предоставляется тип содержимого и Active Storage не может автоматически определить тип содержимого файла, по умолчанию используется application/octet-stream.

Удаление прикрепленных файлов
-----------------------------

Чтобы удалить прикрепленный файл из модели, необходимо вызвать [`purge`][Attached::One#purge] на нем. Если приложение использует Active Job, удаление может быть выполнено в фоновом режиме, с помощью вызова [`purge_later`][Attached::One#purge_later]. `purge` удаляет blob и файл из сервиса хранения.

```ruby
# Синхронно уничтожить аватар и фактические файлы ресурса.
user.avatar.purge

# Асинхронно уничтожить связанные модели и фактические файлы ресурса с помощью Active Job.
user.avatar.purge_later
```

[Attached::One#purge]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-purge
[Attached::One#purge_later]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-purge_later

(linking-to-files) Создание ссылок на файлы
-------------------------------------------

Сгенерируем постоянный URL для blob, который указывает на приложение. При доступе возвращается редирект на фактическую конечную точку сервиса. Эта косвенная адресация (indirection) отделяет URL сервиса от фактического, и позволяет, например, отзеркаливание прикрепленных файлов в разных сервисах для высокой доступности. Перенаправление имеет HTTP-прекращение 5 минут.

```ruby
url_for(user.avatar)
```

WARNING: Ссылки, генерируемые ActiveStorage, трудно подобрать, но они все еще публичные по умолчанию. Любой, кто знает URL бинарного объекта, может скачать его, даже если `before_action` в вашем `ApplicationController` требовал входа. Если ваши файлы требуют более высокий уровень защиты, рассмотрите реализацию собственных аутентифицированных [`ActiveStorage::Blobs::RedirectController`](https://github.com/rails/rails/blob/main/activestorage/app/controllers/active_storage/blobs/redirect_controller.rb) и [`ActiveStorage::Representations::RedirectController`](https://github.com/rails/rails/blob/main/activestorage/app/controllers/active_storage/representations/redirect_controller.rb).

Чтобы создать ссылку для скачивания, необходимо использовать хелпер `rails_blob_{path|url}`. С помощью этого хелпера можно установить disposition.

```ruby
rails_blob_path(user.avatar, disposition: "attachment")
```

WARNING: Для предотвращения атак XSS, ActiveStorage принудительно устанавливает заголовок Content-Disposition как "attachment" для некоторых типов файлов. Чтобы изменить это поведение, смотрите доступные конфигурационные опции в [Конфигурирование приложений на Rails](/configuring-rails-applications#configuring-active-storage).

Если необходимо создать ссылку из-за пределов содержимого контроллера/вью (фоновые задания, задания Cron и т.д.), можно получить доступ к `rails_blob_path` следующим образом:

```ruby
Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)
```

Скачивание файлов
-----------------

Иногда необходимо обработать blob после его загрузки - например, чтобы преобразовать его в другой формат. Используйте метод [`download`][Blob#download] на вложении для чтения двоичных данных blob в памяти:

```ruby
binary = user.avatar.download
```

Возможно, может понадобиться загрузить blob в файл на диске, чтобы внешняя программа могла работать с ним (например, антивирусный сканер или транскодер медиа). Используйте метод [`open`][Blob#open] на вложении, чтобы загрузить blob в tempfile на диске:

```ruby
message.video.open do |file|
  system '/path/to/virus/scanner', file.path
  # ...
end
```

Важно знать, что этот файл не доступен в колбэке `after_create`, а только в `after_create_commit`.

[Blob#download]: https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-download
[Blob#open]: https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-open

Анализ файлов
-------------

Active Storage анализирует файлы как только они были загружены, запустив задание в Active Job. Проанализированные файлы будут хранить дополнительную информацию в хэше метаданных, включая `analyzed: true`. Можно проверить, был ли бинарный объект проанализирован, вызвав [`analyzed?`][] на нем.

Анализ изображений предоставляет атрибуты `width` и `height`. Анализ видео предоставляет их же, а также `duration`, `angle` и `display_aspect_ratio`.

Для анализа нужен гем `mini_magick`. Анализ видео также требует библиотеку [FFmpeg](https://www.ffmpeg.org/), которая подключается отдельно.

[`analyzed?`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Analyzable.html#method-i-analyzed-3F

Отображение изображений, видео и PDF
------------------------------------

Active Storage поддерживает представление разных файлов. Можно вызвать [`representation`][] на вложении, чтобы отобразить вариант изображения или предварительный просмотр видео или PDF. До вызова `representation`, проверьте, что вложение может быть представлено, вызвав [`representable?`]. Некоторые форматы файла не могут быть предварительно показаны ActiveStorage из коробки (например, документы Word); если `representable?` возвращает false, можно [оставить ссылку](#linking-to-files) на файл.

```erb
<ul>
  <% @message.files.each do |file| %>
    <li>
      <% if file.representable? %>
        <%= image_tag file.representation(resize_to_limit: [100, 100]) %>
      <% else %>
        <%= link_to rails_blob_path(file, disposition: "attachment") do %>
          <%= image_tag "placeholder.png", alt: "Download file" %>
        <% end %>
      <% end %>
    </li>
  <% end %>
</ul>
```

Внутри `representation` вызывает `variant` для изображений и `preview` для файлов, которые можно просмотреть предварительно. Можно использовать непосредственно эти методы.

[`representable?`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-representable-3F
[`representation`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-representation

### Преобразование изображений

Преобразование изображений позволяет отобразить изображение с выбранным вами разрешением. Чтобы включить варианты, добавьте гем `image_processing` в `Gemfile`:

```ruby
gem 'image_processing'
```

Чтобы создать вариацию изображения, вызовите [`variant`][] на вложении. В метод можно передать любое преобразование, поддерживаемое процессором варианта. Когда браузер обращается к URL варианта, Active Storage будет лениво преобразовывать исходный blob в указанный формат и перенаправлять его к новому месту расположения сервиса.

```erb
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100]) %>
```

Процессором по умолчанию для Active Storage является MiniMagick, но также можно использовать [Vips][]. Чтобы переключиться на Vips, добавьте следующее в `config/application.rb`:

```ruby
config.active_storage.variant_processor = :vips
```

[`variant`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-variant
[Vips]: https://www.rubydoc.info/gems/ruby-vips/Vips/Image

### Предварительный просмотр файлов

Некоторые файлы, который не являются изображениями, могут быть предварительно просмотрены: то есть они могут быть представлены как изображения. Например, видеофайл можно предварительно просмотреть, извлекая его первый кадр. Из коробки Active Storage поддерживает предварительный просмотр видео и документов PDF. Чтобы создать ссылку на лениво генерируемый предварительный просмотр, используйте метод [`preview`][] вложения:

```erb
<%= image_tag message.video.preview(resize_to_limit: [100, 100]) %>
```

Чтобы добавить поддержку другого формата, добавьте собственный previewer. Обратитесь к документации [`ActiveStorage::Preview`][] за подробностями.

WARNING: Для извлечения превью необходимы сторонние приложения, FFmpeg v3.4+ для видео и muPDF для PDF, а на macOS также XQuartz и Poppler. Эти библиотеки не предоставляются Rails. Необходимо установить их самостоятельно, чтобы использовать встроенные средства предварительного просмотра. Перед установкой и использованием стороннего программного обеспечения убедитесь, что понимаете последствия лицензирования этого.

[`preview`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-preview
[`ActiveStorage::Preview`]: https://api.rubyonrails.org/classes/ActiveStorage/Preview.html

Прямые загрузки
---------------

Active Storage со встроенной библиотекой JavaScript поддерживает загрузку прямо от клиента в облако.

### Использование

1. Включите `activestorage.js` в комплект JavaScript приложения.

    Используя файлопровод:

    ```js
    //= require activestorage
    ```

    Используя пакет npm:

    ```js
    import * as ActiveStorage from "@rails/activestorage"
    ActiveStorage.start()
    ```

2. Добавьте `direct_upload: true` в ваше [поле файла](/rails-form-helpers#uploading-files):

    ```erb
    <%= form.file_field :attachments, multiple: true, direct_upload: true %>
    ```

    Или, если не используете `FormBuilder`, добавьте непосредственно атрибут данных:

    ```erb
    <input type=file data-direct-upload-url="<%= rails_direct_uploads_url %>" />
    ```

3. Настройте CORS на сторонних сервисах хранения, чтобы разрешить запросы прямой загрузки.

4. Вот и все! Загрузки начинаются с момента отправки формы.

### Настройка совместного использование ресурсов (CORS)

Чтобы заработала прямая загрузка на сторонний сервис, необходимо настроить сервис, чтобы разрешить запросы с вашего приложения. Примите во внимание документацию по CORS для вашего сервиса:

* [S3](https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html#how-do-i-enable-cors)
* [Google Cloud Storage](https://cloud.google.com/storage/docs/configuring-cors)
* [Azure Storage](https://docs.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services)

Позаботьтесь о разрешении:

* Всех источников, через которые можно получить доступ к вашему приложению
* Метода запроса `PUT`
* Следующих заголовков:
  * `Origin`
  * `Content-Type`
  * `Content-MD5`
  * `Content-Disposition` (кроме Azure Storage)
  * `x-ms-blob-content-disposition` (только для Azure Storage)
  * `x-ms-blob-type` (только для Azure Storage)

Настройка CORS не нужна для сервиса Disk, так как он использует тот же источник.

#### Пример: настройка S3 CORS

```json
[
  {
    "AllowedHeaders": [
      "*"
    ],
    "AllowedMethods": [
      "PUT"
    ],
    "AllowedOrigins": [
      "https://www.example.com"
    ],
    "ExposeHeaders": [
      "Origin",
      "Content-Type",
      "Content-MD5",
      "Content-Disposition"
    ],
    "MaxAgeSeconds": 3600
  }
]
```

#### Пример: настройка Google Cloud Storage CORS

```json
[
  {
    "origin": ["https://www.example.com"],
    "method": ["PUT"],
    "responseHeader": ["Origin", "Content-Type", "Content-MD5", "Content-Disposition"],
    "maxAgeSeconds": 3600
  }
]
```

#### Пример: настройка Azure Storage CORS

```xml
<Cors>
  <CorsRule>
    <AllowedOrigins>https://www.example.com</AllowedOrigins>
    <AllowedMethods>PUT</AllowedMethods>
    <AllowedHeaders>Origin, Content-Type, Content-MD5, x-ms-blob-content-disposition, x-ms-blob-type</AllowedHeaders>
    <MaxAgeInSeconds>3600</MaxAgeInSeconds>
  </CorsRule>
<Cors>
```

### События JavaScript прямой загрузки

| Имя события | Цель события | Данные события (`event.detail`) | Описание |
| --- | --- | --- | --- |
| `direct-uploads:start`                 | `<form>`  | None                   | Форма, содержащая файлы для прямой загрузки полей была отправлена. |
| `direct-upload:initialize`             | `<input>` | `{id, file}`           | Вызывается для каждого файла после отправки формы. |
| `direct-upload:start`                  | `<input>` | `{id, file}`           | Прямая загрузка начинается. |
| `direct-upload:before-blob-request`    | `<input>` | `{id, file, xhr}`      | Перед тем, как сделать запрос к приложению для прямой загрузки метаданных. |
| `direct-upload:before-storage-request` | `<input>` | `{id, file, xhr}`      | Перед тем, как сделать запрос на сохранение файла. |
| `direct-upload:progress`               | `<input>` | `{id, file, progress}` | По мере прогресса сохранения файлов. |
| `direct-upload:error`                  | `<input>` | `{id, file, error}`    | Произошла ошибка. Отображается `alert`, если это событие не отменено. |
| `direct-upload:end`                    | `<input>` | `{id, file}`           | Прямая загрузка закончилась. |
| `direct-uploads:end`                   | `<form>`  | None                   | Все прямые загрузки закончились. |

### Пример

Также можно использовать эти события, чтобы показывать ход загрузки.

![direct-uploads](https://user-images.githubusercontent.com/5355/28694528-16e69d0c-72f8-11e7-91a7-c0b8cfc90391.gif)

Чтобы показать загруженные файлы в форме:

```js
// direct_uploads.js

addEventListener("direct-upload:initialize", event => {
  const { target, detail } = event
  const { id, file } = detail
  target.insertAdjacentHTML("beforebegin", `
    <div id="direct-upload-${id}" class="direct-upload direct-upload--pending">
      <div id="direct-upload-progress-${id}" class="direct-upload__progress" style="width: 0%"></div>
      <span class="direct-upload__filename"></span>
    </div>
  `)
  target.previousElementSibling.querySelector(`.direct-upload__filename`).textContent = file.name
})

addEventListener("direct-upload:start", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.remove("direct-upload--pending")
})

addEventListener("direct-upload:progress", event => {
  const { id, progress } = event.detail
  const progressElement = document.getElementById(`direct-upload-progress-${id}`)
  progressElement.style.width = `${progress}%`
})

addEventListener("direct-upload:error", event => {
  event.preventDefault()
  const { id, error } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add("direct-upload--error")
  element.setAttribute("title", error)
})

addEventListener("direct-upload:end", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add("direct-upload--complete")
})
```

Добавление стилей:

```css
/* direct_uploads.css */

.direct-upload {
  display: inline-block;
  position: relative;
  padding: 2px 4px;
  margin: 0 3px 3px 0;
  border: 1px solid rgba(0, 0, 0, 0.3);
  border-radius: 3px;
  font-size: 11px;
  line-height: 13px;
}

.direct-upload--pending {
  opacity: 0.6;
}

.direct-upload__progress {
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  opacity: 0.2;
  background: #0076ff;
  transition: width 120ms ease-out, opacity 60ms 60ms ease-in;
  transform: translate3d(0, 0, 0);
}

.direct-upload--complete .direct-upload__progress {
  opacity: 0.4;
}

.direct-upload--error {
  border-color: red;
}

input[type=file][data-direct-upload-url][disabled] {
  display: none;
}
```

### Интеграция с библиотеками или фреймворками

Если необходимо использовать особенность прямой загрузки из фреймворка JavaScript или необходима интеграция собственных решений перетаскивания (drag-and-drop), для этой цели можно использовать класс `DirectUpload`. Получив файл из выбранной библиотеки, создайте экземпляр DirectUpload и вызовите его метод create. Этот метод принимает колбэк для вызова, когда загрузка завершена.

```js
import { DirectUpload } from "@rails/activestorage"

const input = document.querySelector('input[type=file]')

// Привязка к сбрасыванию (drop) файла - используйте ondrop на родительском элементе или используйте библиотеку, такую как Dropzone
const onDrop = (event) => {
  event.preventDefault()
  const files = event.dataTransfer.files;
  Array.from(files).forEach(file => uploadFile(file))
}

// Привязка к обычному выбору файла
input.addEventListener('change', (event) => {
  Array.from(input.files).forEach(file => uploadFile(file))
  // можно очистить выбранные файлы из поля ввода
  input.value = null
})

const uploadFile = (file) => {
  // форма требует file_field direct_upload: true, который предоставляет data-direct-upload-url
  const url = input.dataset.directUploadUrl
  const upload = new DirectUpload(file, url)

  upload.create((error, blob) => {
    if (error) {
      // Обрабатываем ошибку
    } else {
      // Добавьте соответствующим образом названное скрытое поле в форму со значением blob.signed_id, чтобы идентификаторы blob были переданы в обычном потоке загрузки
      const hiddenField = document.createElement('input')
      hiddenField.setAttribute("type", "hidden");
      hiddenField.setAttribute("value", blob.signed_id);
      hiddenField.name = input.name
      document.querySelector('form').appendChild(hiddenField)
    }
  })
}
```

Если необходимо отслеживать ход загрузки файла, можно передать третий параметр в конструктор `DirectUpload`. Во время загрузки DirectUpload вызовет метод `directUploadWillStoreFileWithXHR` объекта. Затем можно привязать свой собственный обработчик прогресса на XHR.

```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url) {
    this.upload = new DirectUpload(this.file, this.url, this)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // Обрабатываем ошибку
      } else {
        // Добавьте соответствующим образом названное скрытое поле в форму со значением of blob.signed_id
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Используйте event.loaded и event.total, чтобы обновить индикатор процесса
  }
}
```

Очистка файлов сохраненных во время системных тестов
----------------------------------------------------

Системные тесты очищают тестовые данные, откатывая транзакцию. Поскольку уничтожение никогда не вызывается на объекте, прикрепленные файлы никогда не очищаются. Если необходимо очистить файлы, можно сделать это в колбэке `after_teardown`. Выполнение этого здесь гарантирует, что все соединения, созданные во время теста, будут завершены и не будет получено сообщение об ошибке из Active Storage, в котором говорится, что он не может найти файл.

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  def remove_uploaded_files
    FileUtils.rm_rf("#{Rails.root}/storage_test")
  end

  def after_teardown
    super
    remove_uploaded_files
  end
end
```

Если системные тесты проверяют удаление модели с прикрепленными файлами, и используется Active Job, необходимо установить тестовую среду для использования встроенного адаптера очереди, поэтому задание на `purge` выполняется немедленно, а не когда-нибудь потом.

Также можно использовать отдельное определение сервиса для тестовой среды, чтобы тесты не удаляли файлы, созданные во время разработки.

```ruby
# Использование встроенной обработки задания, чтобы все произошло немедленно
config.active_job.queue_adapter = :inline

# Отдельное хранилище файлов в тестовой среде
config.active_storage.service = :local_test
```

Отбрасывание (удаление) файлов, сохраненных во время интеграционных тестов
--------------------------------------------------------------------------

Подобно системным тестам, файлы, загруженные во время интеграционных тестов, не будут автоматически очищены. Если необходимо очистить файлы, можно сделать это в колбэке `after_teardown`. Выполнение этого здесь гарантирует, что все созданные во время теста соединения будут завершены и не будет получено сообщение об ошибке из Active Storage, в котором говорится, что невозможно найти файл.

```ruby
module RemoveUploadedFiles
  def after_teardown
    super
    remove_uploaded_files
  end

  private

  def remove_uploaded_files
    FileUtils.rm_rf(Rails.root.join('tmp', 'storage'))
  end
end

module ActionDispatch
  class IntegrationTest
    prepend RemoveUploadedFiles
  end
end
```

Реализация поддержки других облачных сервисов
---------------------------------------------

Если необходимо поддерживать облачный сервис, отличный от имеющихся, необходимо реализовать Service. Каждый сервис расширяет [`ActiveStorage::Service`](https://github.com/rails/rails/blob/main/activestorage/lib/active_storage/service.rb), реализуя методы, требуемые для загрузки и скачивания файлов в облако.
