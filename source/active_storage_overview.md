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

Используя Active Storage приложение может преобразовывать изображения или генерировать изображение файла, который не является изображением, такого, например, как PDF или видео, и извлекать метаданные из произвольных файлов.

### Требования

Разные особенности Active Storage зависят от стороннего программного обеспечения, которое Rails не устанавливает, и которое должно быть установлено отдельно:

* [ImageMagick](https://imagemagick.org/index.php) или [libvips](https://github.com/libvips/libvips) v8.6+ для анализа и трансформаций изображений
* [ffmpeg](http://ffmpeg.org/) v3.4+ для анализа видео/аудио и предпросмотра видео
* [poppler](https://poppler.freedesktop.org/) или [muPDF](https://mupdf.com/) для предпросмотра PDF

Анализ и преобразования изображений также требуют гем `image_processing`. Раскомментируйте его в своем `Gemfile`, или добавьте:

```ruby
gem "image_processing", ">= 1.2"
```

TIP: По сравнению с libvips, ImageMagick более известный и распространенный. Однако, libvips может быть [до 10 раз быстрее и потреблять 1/10 памяти](https://github.com/libvips/libvips/wiki/Speed-and-memory-use). Для файлов JPEG это может быть еще более улучшено, с помощью замены `libjpeg-dev` на `libjpeg-turbo-dev`, который [в 2-7 раз быстрее](https://libjpeg-turbo.org/About/Performance).

WARNING: Перед установкой и использованием сторонних программ, убедитесь, что вы понимаете лицензионные последствия этого. В частности, MuPDF лицензирован по AGPL и требует коммерческую лицензию в определенных случаях.

## Установка

Active Storage использует три таблицы в базе данных приложения названные `active_storage_blobs`, `active_storage_variant_records` и `active_storage_attachments`. После создания нового приложения (или апгрейда приложения до Rails 5.2), нужно запустить `bin/rails active_storage:install`, чтобы сгенерировать миграцию, которая создает эти таблицы. Используйте `bin/rails db:migrate` для запуска миграций.

WARNING: `active_storage_attachments` это полиморфная соединительная таблица, хранящая имена ваших классов моделей. Если имена ваших классов моделей меняются, необходимо запустить миграцию на эту таблицу, чтобы обновить соответствующие `record_type` новым именем вашего класса модели.

WARNING: Если используются UUID вместо чисел в качестве первичного ключа моделей, необходимо изменить тип столбцов `active_storage_attachments.record_id` и `active_storage_variant_records.id` в соответствующей сгенерированной миграции.

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

Рекомендовано использовать `Rails.env` в имени bucket, чтобы в будущем снизить риск случайного уничтожения данных production.

```yaml
amazon:
  service: S3
  # ...
  bucket: your_own_bucket-<%= Rails.env %>

google:
  service: GCS
  # ...
  bucket: your_own_bucket-<%= Rails.env %>

azure:
  service: AzureStorage
  # ...
  container: your_container_name-<%= Rails.env %>
```

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

NOTE: Основные особенности Active Storage требуют следующих прав доступа: `s3:ListBucket`, `s3:PutObject`, `s3:GetObject` и `s3:DeleteObject`. [Публичный доступ](#public-access) дополнительно требует `s3:PutObjectAcl`. Если есть дополнительные опции загрузки, сконфигурированные также как и настройка ACL, тогда могут потребоваться дополнительные права доступа.

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

Есть множество других доступных опций. Их можно посмотреть в документации [клиента AWS S3](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#initialize-instance_method).

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

Опционально предоставьте метаданные Cache-Control для установки на загруженных файлах:

```yaml
google:
  service: GCS
  ...
  cache_control: "public, max-age=3600"
```

Опционально используйте [IAM](https://cloud.google.com/storage/docs/access-control/signed-urls#signing-iam) вместо `credentials` при подписании URL. Это полезно, если вы аутентифицируете ваше приложение GKE с помощью Workload Identity, подробности смотрите в [этом блоге Google Cloud](https://cloud.google.com/blog/products/containers-kubernetes/introducing-workload-identity-better-authentication-for-your-gke-applications).

```yaml
google:
  service: GCS
  ...
  iam: true
```

Опционально используйте определенный GSA при подписании URL. При использовании IAM, [сервер метаданных](https://cloud.google.com/compute/docs/storing-retrieving-metadata) свяжется для получения GSA email, но этот сервер метаданных не всегда присутствует (например, локальные тесты), и вы не хотите использовать GSA по умолчанию.

```yaml
google:
  service: GCS
  ...
  iam: true
  gsa_email: "foobar@baz.iam.gserviceaccount.com"
```

Добавьте гем [`google-cloud-storage`](https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/master/google-cloud-storage) в `Gemfile`:

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

### (public-access) Публичный доступ

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

Убедитесь, что ваши bucket правильно настроены для публичного доступа. Обратитесь к документации, как разрешить публичное чтение для сервисов хранения [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/block-public-access-bucket.html), [Google Cloud Storage](https://cloud.google.com/storage/docs/access-control/making-data-public#buckets) и [Microsoft Azure](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-manage-access-to-resources#set-container-public-access-level-in-the-azure-portal). Amazon S3 дополнительно требует имеющегося разрешения `s3:PutObjectAcl`.

При конвертации существующего приложения на использование `public: true`, убедитесь в обновлении каждого отдельного файла в bucket, чтобы он был публично читаемый до переключения.

Прикрепление файлов к записям
-----------------------------

### `has_one_attached`

Макрос [`has_one_attached`][] устанавливает сопоставление (mapping) один-к-одному между записями и файлами. Каждая запись может содержать один прикрепленный файл.

Например, предположим, что в приложении имеется модель `User`. Если необходимо, чтобы у каждого пользователя был аватар, определите модель `User` так:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
end
```

или, если используете Rails 6.0+, можно запустить команду генератора модели наподобие:

```ruby
bin/rails generate model User avatar:attachment
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

Например, предположим, что в приложении имеется модель `Message`. Если необходимо, чтобы у каждого сообщения было много изображений, определите модель `Message` так:

```ruby
class Message < ApplicationRecord
  has_many_attached :images
end
```

или, если используете Rails 6.0+, можно запустить команду генератора модели наподобие:

```ruby
bin/rails generate model Message images:attachments
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
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf')
```

Когда это возможно, предоставьте тип содержимого. Active Storage пытается определить тип содержимого файла по его данным. Если он не может этого сделать, он возвращает тип содержимого, которое предоставляется.

```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf', content_type: 'application/pdf')
```

Можно пропустить определение типа содержимого из данных, передав `identify: false` вместе с `content_type`.

```ruby
@message.images.attach(
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

(Serving Files) Раздача файлов
------------------------------

Active Storage поддерживает два способа раздачи файлов: перенаправление и прокси.

WARNING: Все контроллеры Active Storage по умолчанию доступны публично. Сгенерированные URL трудно угадать, но они постоянные по определению. Если ваши файлы требуют более высокий уровень защиты, рассмотрите реализацию [аутентифицированных контроллеров](#authenticated-controllers).

### Режим перенаправления

Чтобы сгенерировать постоянный URL для бинарного объекта, можно передать этот объект в хелпер вью [`url_for`][ActionView::RoutingUrlFor#url_for]. Это создаст URL с [`signed_id`][ActiveStorage::Blob#signed_id] бинарного объекта, который направляет в [`RedirectController`][ActiveStorage::Blobs::RedirectController] для бинарного объекта.

[ActiveStorage::Blobs::RedirectController]: https://github.com/rails/rails/blob/main/activestorage/app/controllers/active_storage/blobs/redirect_controller.rb

```ruby
url_for(user.avatar)
# => /rails/active_storage/blobs/:signed_id/my-avatar.png
```

`RedirectController` перенаправляет на фактическую конечную точку сервиса.  Эта косвенная адресация (indirection) отделяет URL сервиса от фактического, и позволяет, например, отзеркаливание прикрепленных файлов в разных сервисах для высокой доступности. Перенаправление имеет HTTP-прекращение 5 минут.

Чтобы создать ссылку для скачивания, необходимо использовать хелпер `rails_blob_{path|url}`. С помощью этого хелпера можно установить disposition.

```ruby
rails_blob_path(user.avatar, disposition: "attachment")
```

WARNING: Для предотвращения атак XSS, Active Storage принудительно устанавливает заголовок Content-Disposition как "attachment" для некоторых типов файлов. Чтобы изменить это поведение, смотрите доступные конфигурационные опции в [Конфигурирование приложений на Rails](/configuring-rails-applications#configuring-active-storage).

Если необходимо создать ссылку из-за пределов содержимого контроллера/вью (фоновые задания, задания Cron и т.д.), можно получить доступ к `rails_blob_path` следующим образом:

```ruby
Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)
```

[ActionView::RoutingUrlFor#url_for]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[ActiveStorage::Blob#signed_id]: https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-signed_id

### (proxy-mode) Режим прокси

Опционально файлы могут проксированы вместо этого. Это означает, что серверы вашего приложения будут скачивать данные файла из сервиса хранения в отклик на запросы. Это может быть полезным для раздачи файлов из CDN.

Можно настроить Active Storage для использования проксирования по умолчанию:

```ruby
# config/initializers/active_storage.rb
Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy
```

Или, если хотите явно проксировать определенные вложения, есть хелперы URL, которые можно использовать в форме `rails_storage_proxy_path` и `rails_storage_proxy_url`.

```erb
<%= image_tag rails_storage_proxy_path(@user.avatar) %>
```

#### Помещение CDN перед Active Storage

Кроме этого чтобы использовать CDN для вложений Active Storage, необходимо сгенерировать URL с режимом прокси, чтобы они раздавались вашим приложением, и CDN закэширует вложение без каких-либо дополнительных настроек. Это работает из коробки, так как контроллер прокси Active Storage по умолчанию устанавливает заголовок HTTP, указывающий CDN закэшировать отклик.

Также следует убедиться, что сгенерированные URL используют хост CDN, а не хост приложения. Есть несколько способов достичь этого, но в основном это затрагивает изменение вашего файла `config/routes.rb`, чтобы вы могли сгенерировать правильные URL для вложений и их вариаций. Для примера, можно добавить это:

```ruby
# config/routes.rb
direct :cdn_image do |model, options|
  if model.respond_to?(:signed_id)
    route_for(
      :rails_service_blob_proxy,
      model.signed_id,
      model.filename,
      options.merge(host: ENV['CDN_HOST'])
    )
  else
    signed_blob_id = model.blob.signed_id
    variation_key  = model.variation.key
    filename       = model.blob.filename

    route_for(
      :rails_blob_representation_proxy,
      signed_blob_id,
      variation_key,
      filename,
      options.merge(host: ENV['CDN_HOST'])
    )
  end
end
```

и затем генерировать маршруты следующим образом:

```erb
<%= cdn_image_url(user.avatar.variant(resize_to_limit: [128, 128])) %>
```

### (Authenticated Controllers) Аутентифицированные контроллеры

Все контроллеры Active Storage по умолчанию публично доступны. Сгенерированные URL используют [`signed_id`][ActiveStorage::Blob#signed_id], который трудно угадываемый, но всегда одинаковый. Любой, кто узнает URL бинарного объекта, сможет получить к нему доступ, даже если `before_action` в вашем `ApplicationController` в ином случае требовал бы входа. Если ваши файлы требуют более высокий уровень защиты, можно реализовать собственные аутентифицированные контроллеры, основанные на [`ActiveStorage::Blobs::RedirectController`][], [`ActiveStorage::Blobs::ProxyController`][], [`ActiveStorage::Representations::RedirectController`][] и
[`ActiveStorage::Representations::ProxyController`][]

Чтобы разрешить аккаунту доступ только к своему логотипу, можно сделать следующее:

```ruby
# config/routes.rb
resource :account do
  resource :logo
end
```

```ruby
# app/controllers/logos_controller.rb
class LogosController < ApplicationController
  # Through ApplicationController:
  # include Authenticate, SetCurrentAccount

  def show
    redirect_to Current.account.logo.url
  end
end
```

```erb
<%= image_tag account_logo_path %>
```

И затем можно отключить маршруты Active Storage по умолчанию с помощью:

```ruby
config.active_storage.draw_routes = false
```

чтобы предотвратить доступ к файлам с помощью публично доступных URL.

[`ActiveStorage::Blobs::RedirectController`]: https://github.com/rails/rails/blob/main/activestorage/app/controllers/active_storage/blobs/redirect_controller.rb
[`ActiveStorage::Blobs::ProxyController`]: https://github.com/rails/rails/blob/main/activestorage/app/controllers/active_storage/blobs/proxy_controller.rb
[`ActiveStorage::Representations::RedirectController`]: https://github.com/rails/rails/blob/main/activestorage/app/controllers/active_storage/representations/redirect_controller.rb
[`ActiveStorage::Representations::ProxyController`]: https://github.com/rails/rails/blob/main/activestorage/app/controllers/active_storage/representations/proxy_controller.rb

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

Анализ изображений предоставляет атрибуты `width` и `height`. Анализ видео предоставляет их же, а также `duration`, `angle`, `display_aspect_ratio` и булевы значения `video` и `audio` для обозначения наличия этих каналов. Анализ аудио предоставляет атрибуты `duration` и `bit_rate`.

[`analyzed?`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Analyzable.html#method-i-analyzed-3F

Отображение изображений, видео и PDF
------------------------------------

Active Storage поддерживает представление разных файлов. Можно вызвать [`representation`][] на вложении, чтобы отобразить вариант изображения или предварительный просмотр видео или PDF. До вызова `representation`, проверьте, что вложение может быть представлено, вызвав [`representable?`]. Некоторые форматы файла не могут быть предварительно показаны Active Storage из коробки (например, документы Word); если `representable?` возвращает false, можно [оставить ссылку](#serving-files) на файл.

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

### Ленивая vs немедленная загрузка

По умолчанию Active Storage will обрабатывает представления лениво. Этот код:

```ruby
image_tag file.representation(resize_to_limit: [100, 100])
```

Создаст тег `<img>` с `src`, указывающим на [`ActiveStorage::Representations::RedirectController`][]. Браузер сделает запрос к этому контроллеру, который вернет перенаправление `302` на файл на удаленном сервисе (или в [режиме прокси](#proxy-mode) возвратит содержимое файла). Ленивая загрузка файла позволяет работать особенностям, таким как [одноразовые URL](#public-access), без замедления загрузки изначальной страницы.

Это прекрасно работает в большинстве случаев.

Если хотите немедленно сгенерировать URL для изображений, можно вызвать `.processed.url`:

```ruby
image_tag file.representation(resize_to_limit: [100, 100]).processed.url
```

Отслеживание вариантов Active Storage улучшает производительность этого, сохраняя запись в базе данных, если запрашиваемое представление уже было обработано ранее. Таким образом, вышеприведенных код сделает вызов API к удаленному сервису (например, S3) только единожды, и как только вариант сохранится, будет использовать его. Отслеживание вариантов запускается автоматически, но может быть отключено с помощью `config.active_storage.track_variants`.

Если вы рендерите множество изображений на странице, вышеприведенный пример может привести к N+1 запросам, загружающим все записи вариантов. Чтобы избежать этих  N+1 запросов, используйте именованные скоупы на [`ActiveStorage::Attachment`][].

```ruby
message.images.with_all_variant_records.each do |file|
  image_tag file.representation(resize_to_limit: [100, 100]).processed.url
end
```

[`ActiveStorage::Representations::RedirectController`]: https://api.rubyonrails.org/classes/ActiveStorage/Representations/RedirectController.html
[`ActiveStorage::Attachment`]: https://api.rubyonrails.org/classes/ActiveStorage/Attachment.html

### Преобразование изображений

Преобразование изображений позволяет отобразить изображение с выбранным вами разрешением.

Чтобы создать вариацию изображения, вызовите [`variant`][] на вложении. В метод можно передать любое преобразование, поддерживаемое процессором варианта. Когда браузер обращается к URL варианта, Active Storage будет лениво преобразовывать исходный blob в указанный формат и перенаправлять его к новому месту расположения сервиса.

```erb
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100]) %>
```

Процессором по умолчанию для Active Storage является MiniMagick, но также можно использовать [Vips][]. Чтобы переключиться на Vips, добавьте следующее в `config/application.rb`:

```ruby
config.active_storage.variant_processor = :vips
```

Эти два процессора не полностью совместимы, поэтому при миграции существующего приложения, использующего MiniMagick, на Vips, нужно сделать несколько изменений при использовании специфичных опций форматирования:

```rhtml
<!-- MiniMagick -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, sampling_factor: "4:2:0", strip: true, interlace: "JPEG", colorspace: "sRGB", quality: 0) %>

<!-- Vips -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, saver: { subsample_mode: "on", strip: true, interlace: true, quality: 80 }) %>
```

[`variant`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-variant
[Vips]: https://www.rubydoc.info/gems/ruby-vips/Vips/Image

### Предварительный просмотр файлов

Некоторые файлы, который не являются изображениями, могут быть предварительно просмотрены: то есть они могут быть представлены как изображения. Например, видеофайл можно предварительно просмотреть, извлекая его первый кадр. Из коробки Active Storage поддерживает предварительный просмотр видео и документов PDF. Чтобы создать ссылку на лениво генерируемый предварительный просмотр, используйте метод [`preview`][] вложения:

```erb
<%= image_tag message.video.preview(resize_to_limit: [100, 100]) %>
```

Чтобы добавить поддержку другого формата, добавьте собственный previewer. Обратитесь к документации [`ActiveStorage::Preview`][] за подробностями.

[`preview`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-preview
[`ActiveStorage::Preview`]: https://api.rubyonrails.org/classes/ActiveStorage/Preview.html

(direct-uploads) Прямые загрузки
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
  * `Cache-Control` (для GCS, только если установлена `cache_control`)

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
</Cors>
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

NOTE: Использование [прямых загрузок](#direct-uploads) иногда может привести к тому, что загруженный файл никогда не будет прикреплен к записи. Рассмотрите [очистку неприкрепленных загрузок](#purging-unattached-uploads).

Тестирование
------------

Используйте [`fixture_file_upload`][] для тестирования загрузки файла в интеграционном тесте или тесте контроллера. Rails обрабатывает файлы так же, как и любые другие параметры.

```ruby
class SignupController < ActionDispatch::IntegrationTest
  test "can sign up" do
    post signup_path, params: {
      name: "David",
      avatar: fixture_file_upload("david.png", "image/png")
    }

    user = User.order(:created_at).last
    assert user.avatar.attached?
  end
end
```

[`fixture_file_upload`]: https://api.rubyonrails.org/classes/ActionDispatch/TestProcess/FixtureFile.html

### (discarding-files-created-during-tests) Очистка файлов созданных во время тестов

#### Системные тесты

Системные тесты очищают тестовые данные, откатывая транзакцию. Поскольку `destroy` никогда не вызывается на объекте, прикрепленные файлы никогда не очищаются. Если необходимо очистить файлы, можно сделать это в колбэке `after_teardown`. Выполнение этого здесь гарантирует, что все соединения, созданные во время теста, будут завершены и не будет получено сообщение об ошибке из Active Storage, в котором говорится, что он не может найти файл.

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # ...
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
  # ...
end
```

Если используете [параллельные тесты][/a-guide-to-testing-rails-applications#parallel-testing] и `DiskService`, следует настроить каждый процесс для использования своей папки для Active Storage. Таким образом, колбэк `teardown` удалит только файлы из тестов, релевантных процессу.

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # ...
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
end
```

Если системные тесты проверяют удаление модели с прикрепленными файлами, и используется Active Job, необходимо установить тестовую среду для использования встроенного адаптера очереди, поэтому задание на `purge` выполняется немедленно, а не когда-нибудь потом.

```ruby
# Использование встроенной обработки задания, чтобы все произошло немедленно
config.active_job.queue_adapter = :inline
```

#### Интеграционные тесты

Подобно системным тестам, файлы, загруженные во время интеграционных тестов, не будут автоматически очищены. Если необходимо очистить файлы, можно сделать это в колбэке `teardown`.

```ruby
class ActionDispatch::IntegrationTest
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
end
```

Если используете [параллельные тесты][/a-guide-to-testing-rails-applications#parallel-testing] и `DiskService`, следует настроить каждый процесс для использования своей папки для Active Storage. Таким образом, колбэк `teardown` удалит только файлы из тестов, релевантных процессу.

```ruby
class ActionDispatch::IntegrationTest
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
end
```

### Добавление вложений в фикстуры

Можно добавлять вложения в существующие [фикстуры][/a-guide-to-testing-rails-applications#the-low-down-on-fixtures]. Сначала нужно создать отдельный сервис хранения:

```yml
# config/storage.yml
test_fixtures:
  service: Disk
  root: <%= Rails.root.join("tmp/storage_fixtures") %>
```

Это сообщит Active Storage, куда "загружать" файлы фикстур, поэтому это должна быть временная директория. Сделав ее директорией, отличной от обычного сервиса `test`, можно отделить файлы фикстур от файлов, загруженных в течение теста.

Затем создайте файлы фикстур для классов Active Storage:

```yml
# active_storage/attachments.yml
david_avatar:
  name: avatar
  record: david (User)
  blob: david_avatar_blob
```

```yml
# active_storage/blobs.yml
david_avatar_blob: <%= ActiveStorage::FixtureSet.blob filename: "david.png", service_name: "test_fixtures" %>
```

Затем поместите файл в директорию фикстур (путь по умолчанию `test/fixtures/files`) со соответствующим именем. Подробности смотрите в документации по [`ActiveStorage::FixtureSet`][].

Как только все настроено, можно получить доступ к вложениям в ваших тестах:

```ruby
class UserTest < ActiveSupport::TestCase
  def test_avatar
    avatar = users(:david).avatar

    assert avatar.attached?
    assert_not_nil avatar.download
    assert_equal 1000, avatar.byte_size
  end
end
```

#### Очистка фикстур

Хотя файлы, загруженные в тестах, очищаются [в конце каждого теста](#discarding-files-created-during-tests), файлы фикстур нужно очищать всего лишь раз: когда завершатся все ваши тесты.

Если используете параллельные тесты, вызывайте `parallelize_teardown`:

```ruby
class ActiveSupport::TestCase
  # ...
  parallelize_teardown do |i|
    FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
   end
  # ...
end
```

Если не запускаете параллельные тесты, используйте `Minitest.after_run` или эквивалент для вашего тестового фреймворка (например, `after(:suite)` для RSpec):

```ruby
# test_helper.rb

Minitest.after_run do
  FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
end
```

[`ActiveStorage::FixtureSet`]: https://api.rubyonrails.org/classes/ActiveStorage/FixtureSet.html

Реализация поддержки других облачных сервисов
---------------------------------------------

Если необходимо поддерживать облачный сервис, отличный от имеющихся, необходимо реализовать Service. Каждый сервис расширяет [`ActiveStorage::Service`](https://github.com/rails/rails/blob/main/activestorage/lib/active_storage/service.rb), реализуя методы, требуемые для загрузки и скачивания файлов в облако.

(Purging Unattached Uploads) Очистка неприкрепленных загрузок
-------------------------------------------------------------

Бывают случаи, когда файл загружен, но никогда не прикреплен к записи. Это может произойти при использовании [прямых загрузок](#direct-uploads). Можно запросить неприкрепленные записи с помощью [скоупа unattached](https://github.com/rails/rails/blob/8ef5bd9ced351162b673904a0b77c7034ca2bc20/activestorage/app/models/active_storage/lob.rb#L49). Ниже пример с помощью [пользовательской задачи rake](/a-guide-to-the-rails-command-line#custom-rake-tasks).

```ruby
namespace :active_storage do
  desc "Purges unattached Active Storage blobs. Run regularly."
  task purge_unattached: :environment do
    ActiveStorage::Blob.unattached.where("active_storage_blobs.created_at <= ?", 2.days.ago).find_each(&:purge_later)
  end
end
```

WARNING: Запрос, сгенерированный `ActiveStorage::Blob.unattached`, может быть медленным и потенциально разрушительным для приложений с большими базами данных.
