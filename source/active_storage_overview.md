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

Active Storage использует две таблицы в базе данных приложения названные `active_storage_blobs` и `active_storage_attachments`. После апгрейда приложения до Rails 5.2, нужно запустить `rails active_storage:install`, чтобы сгенерировать миграцию, которая создает эти таблицы. Используйте `rails db:migrate` для запуска миграций.

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
```

Скажите Active Storage, какой сервис использовать, установив `Rails.application.config.active_storage.service`. Поскольку каждая среда, скорее всего, использует различные сервисы, рекомендуется делать это отдельно для каждого окружения. Чтобы использовать сервис диска из предыдущего примера в среде разработки, нужно добавить следующее в `config/environments/development.rb`:

```ruby
# Хранение файлов локально.
config.active_storage.service = :local
```

Чтобы использовать сервис Amazon S3 в production, необходимо добавить следующее в
`config/environments/production.rb`:

```ruby
# Хранить файлы в Amazon S3.
config.active_storage.service = :amazon
```

Подробнее о встроенных адаптерах сервиса (например, `Disk` и `S3`) и требуемой конфигурации написано ниже.

### Сервис Disk

Объявление сервиса Disk в `config/storage.yml`:

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

### Сервис Amazon S3

Объявление сервиса S3 в `config/storage.yml`:

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
```

Кроме того, необходимо добавить гем [`aws-sdk-s3`](https://github.com/aws/aws-sdk-ruby) в `Gemfile`:

```ruby
gem "aws-sdk-s3", require: false
```

NOTE: Основные особенности Active Storage требуют следующих прав доступа: `s3:ListBucket`, `s3:PutObject`, `s3:GetObject` и `s3:DeleteObject`. Если есть дополнительные опции загрузки, сконфигурированные также как и настройка ACL, тогда могут потребоваться дополнительные права доступа.

NOTE: Если необходимо использовать переменные среды, стандартные файлы конфигурации SDK, профили, профили экземпляров IAM или роли задач, можно опустить ключи `access_key_id`, `secret_access_key` и `region` в приведенном выше примере. Сервис Amazon S3 поддерживает все опции аутентификации, описанные в [документации AWS SDK](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html).

### Сервис Microsoft Azure Storage

Объявление сервиса Azure Storage в `config/storage.yml`:

```yaml
azure:
  service: AzureStorage
  storage_account_name: ""
  storage_access_key: ""
  container: ""
```

Кроме того, необходимо добавить гем [`azure-storage`](https://github.com/Azure/azure-storage-ruby) в `Gemfile`:

```ruby
gem "azure-storage", require: false
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
    private_key: <%= Rails.application.credentials.dig(:gcs, :private_key) %>
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
gem "google-cloud-storage", "~> 1.8", require: false
```

### Сервис Mirror

Существует возможность синхронизировать несколько сервисов, определив сервис mirror. Когда файл загружается или удаляется, это происходит для всех зеркальных (mirrored) сервисов. Зеркальные сервисы могут использоваться для облегчения миграции между сервисами в production. Можно начать отзеркаливание в новый сервис, скопировав существующие файлы со старого сервиса на новый, а затем полностью перейти на новый сервис. Определим каждый из требуемых сервисов, как описано выше, и будем ссылаться на них с помощью зеркального сервиса.

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

NOTE: Файлы отдаются из основного сервиса.

Прикрепление файлов к записям
-----------------------------

### `has_one_attached`

Макрос `has_one_attached` устанавливает сопоставление (mapping) один-к-одному между записями и файлами. Каждая запись может содержать один прикрепленный файл.

Например, предположим, что в приложении имеется модель `User`. Если необходимо, чтобы у каждого пользователя был аватар, нужно определить модель `User` следующим образом:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
end
```

Далее можно создать пользователя с аватаром:

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

Вызов `avatar.attach` прикрепляет аватар к существующему пользователю:

```ruby
Current.user.avatar.attach(params[:avatar])
```

Вызов `avatar.attached?` определяет, есть ли у конкретного пользователя аватар:

```ruby
Current.user.avatar.attached?
```

### `has_many_attached`

Макрос `has_many_attached` устанавливает отношение один-ко-многим между записями и файлами. У каждой записи может быть много прикрепленных файлов.

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

Вызов `images.attach` добавляет новые изображения к существующему сообщению:

```ruby
@message.images.attach(params[:images])
```

Вызов `images.attached?` определяет, есть ли у конкретного сообщения какие-либо изображения:

```ruby
@message.images.attached?
```

Удаление прикрепленных файлов
-----------------------------

Чтобы удалить прикрепленный файл из модели, необходимо вызвать `purge` на нем. Удаление может быть выполнено в фоновом режиме, если приложение использует Active Job. `purge` удаляет blob и файл из сервиса хранения.

```ruby
# Синхронно уничтожить аватар и фактические файлы ресурса.
user.avatar.purge

# Асинхронно уничтожить связанные модели и фактические файлы ресурса с помощью Active Job.
user.avatar.purge_later
```

Создание ссылок на файлы
------------------------

Сгенерируем постоянный URL для blob, который указывает на приложение. При доступе возвращается редирект на фактическую конечную точку сервиса. Эта косвенная адресация (indirection) отделяет публичный URL от фактического, и позволяет, например, отзеркаливание прикрепленных файлов в разных сервисах для высокой доступности. Перенаправление имеет HTTP-прекращение 5 минут.

```ruby
url_for(user.avatar)
```

Чтобы создать ссылку для скачивания, необходимо использовать хелпер `rails_blob_{path|url}`. С помощью этого хелпера можно установить disposition.

```ruby
rails_blob_path(user.avatar, disposition: "attachment")
```

Преобразование изображений
--------------------------

Чтобы создать вариацию изображения, следует вызвать `variant` на Blob.
Также возможно передать любое преобразование, поддерживаемое [MiniMagick](https://github.com/minimagick/minimagick), методу.

Чтобы включить варианты, добавьте `mini_magick` в `Gemfile`:

```ruby
gem 'mini_magick'
```

Когда браузер обращается к URL варианта, Active Storage будет лениво преобразовывать исходный blob в указанный формат и перенаправлять его к новому месту расположения сервиса.

```erb
<%= image_tag user.avatar.variant(resize: "100x100") %>
```

Предварительный просмотр файлов
-------------------------------

Некоторые файлы, который не являются изображениями, могут быть предварительно просмотрены: то есть они могут быть представлены как изображения. Например, видеофайл можно предварительно просмотреть, извлекая его первый кадр. Из коробки Active Storage поддерживает предварительный просмотр видео и документов PDF.

```erb
<ul>
  <% @message.files.each do |file| %>
    <li>
      <%= image_tag file.preview(resize: "100x100>") %>
    </li>
  <% end %>
</ul>
```

WARNING: Для извлечения превью необходимы сторонние приложения, `ffmpeg` для видео и `mutool` для PDF. Эти библиотеки не предоставляются Rails. Необходимо установить их самостоятельно, чтобы использовать встроенные предпросмотрщики. Перед установкой и использованием стороннего программного обеспечения убедитесь, что понимаете последствия лицензирования этого.

Прямые загрузки
---------------

Active Storage со встроенной библиотекой JavaScript поддерживает загрузку прямо от клиента в облако.

### Установка прямой загрузки

1. Включите `activestorage.js` в комплект JavaScript приложения.

    Используя файлопровод:

    ```js
    //= require activestorage

    ```

    Используя пакет npm:

    ```js
    import * as ActiveStorage from "activestorage"
    ActiveStorage.start()
    ```

2. Установите в true значение `direct_upload` поля для загрузки файла.

    ```ruby
    <%= form.file_field :attachments, multiple: true, direct_upload: true %>
    ```
3. Вот и все! Загрузки начинаются с момента отправки формы.

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
      <span class="direct-upload__filename">${file.name}</span>
    </div>
  `)
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
module ActionDispatch
  class IntegrationTest
    def remove_uploaded_files
      FileUtils.rm_rf(Rails.root.join('tmp', 'storage'))
    end

    def after_teardown
      super
      remove_uploaded_files
    end
  end
end
```

Реализация поддержки других облачных сервисов
---------------------------------------------

Если необходимо поддерживать облачный сервис, отличный от имеющихся, необходимо, необходимо реализовать Service. Каждый сервис расширяет [`ActiveStorage::Service`](https://github.com/rails/rails/blob/master/activestorage/lib/active_storage/service.rb), реализуя методы, требуемые для загрузки и скачивания файлов в облако.
