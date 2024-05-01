Основы Active Job
=================

Это руководство даст вам все, что нужно, чтобы начать создавать, ставить в очередь и выполнять фоновые задания.

После его прочтения, вы узнаете:

* Как создавать задания.
* Как ставить в очередь задания.
* Как запускать задания в фоне.
* Как асинхронно рассылать письма из вашего приложения.

--------------------------------------------------------------------------------

Что такое Active Job?
---------------------

Active Job - это фреймворк для объявления заданий и их запуска на разных бэкендах для очередей. Эти задания могут быть чем угодно, от регулярно запланированных чисток до списаний с карт или рассылок. Всем, что может быть выделено в небольшие работающие части и запускаться параллельно.

Назначение Active Job
---------------------

Главным является то, что он обеспечивает, что у всех приложений на Rails имеется встроенная инфраструктура для заданий. Затем у нас могут появиться особенности фреймворка или других гемов, созданных на его основе, позволяющие не заботится об отличиях в API между различными исполнителями заданий, такими как Delayed Job и Resque. Подбор бэкенда для очередей станет более оперативной работой. Вы сможете переключаться между ними без необходимости переписывать свои задания.

NOTE: По умолчанию, Rails поставляется с асинхронной реализацией очереди, запускающей задания с помощью пула тредов внутри процесса. Задания будут запущены асинхронно, но любые задания в очереди будут потеряны при перезагрузке.

Создание задания и добавление в очередь
---------------------------------------

Этот раздел предоставляет пошаговое руководство к созданию задания и добавлению его в очередь.

### Создание задания

Active Job предоставляет генератор Rails для создания заданий. Следующая команда создаст задание в `app/jobs` (а также тестовый случай в `test/jobs`):

```bash
$ bin/rails generate job guests_cleanup
invoke  test_unit
create    test/jobs/guests_cleanup_job_test.rb
create  app/jobs/guests_cleanup_job.rb
```

Также можно создать задание, которое будет запущено в определенной очереди:

```bash
$ bin/rails generate job guests_cleanup --queue urgent
```

Если не хотите использовать генератор, можно создать файл очереди в `app/jobs`, просто убедитесь, что он наследуется от `ApplicationJob`.

Вот как выглядит задание:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*guests)
    # Сделать что-нибудь позже
  end
end
```

Отметьте, что можно определить `perform` с любым количеством аргументов.

Если у вас уже есть абстрактный класс, и его имя отличается от `ApplicationJob`, можно передать опцию `--parent`, чтобы обозначить, что вы желаете иной абстрактный класс:

```bash
$ bin/rails generate job process_payment --parent=payment_job
```

```ruby
class ProcessPaymentJob < PaymentJob
  queue_as :default

  def perform(*args)
    # Сделать что-нибудь позже
  end
end
```

### Помещение задания в очередь

Поместите задание в очередь с помощью [`perform_later`][] и, опционально, [`set`][]. Например, так:

```ruby
# Помещенное в очередь задание выполнится, как только освободится система очередей.
GuestsCleanupJob.perform_later guest
```

```ruby
# Помещенное в очередь задание выполнится завтра в полдень.
GuestsCleanupJob.set(wait_until: Date.tomorrow.noon).perform_later(guest)
```

```ruby
# Помещенное в очередь задание выполнится через неделю.
GuestsCleanupJob.set(wait: 1.week).perform_later(guest)
```

```ruby
# `perform_now` и `perform_later` вызывают `perform`, поэтому
# можно передать столько аргументов, сколько определено в последнем.
GuestsCleanupJob.perform_later(guest1, guest2, filter: 'some_filter')
```

Вот и все!

[`perform_later`]: https://api.rubyonrails.org/classes/ActiveJob/Enqueuing/ClassMethods.html#method-i-perform_later
[`set`]: https://api.rubyonrails.org/classes/ActiveJob/Core/ClassMethods.html#method-i-set

### Помещение заданий в очередь группами

Вы можете добавлять несколько заданий в очередь одновременно с помощью метода [`perform_all_later`](https://api.rubyonrails.org/classes/ActiveJob.html#method-c-perform_all_later). Подробнее смотрите [Bulk Enqueuing](#bulk-enqueuing).

Выполнение заданий
------------------

Чтобы поместить задание в очередь и выполнить его в production, необходимо настроить бэкенд для очереди, т.е. нужно решить, какую стороннюю библиотеку для очереди Rails будет использовать. Rails предоставляет только внутрипроцессную систему очереди, хранящую задания в памяти. Если процесс упадет, или машина будет перезагружена, тогда в асинхронном бэкенде по умолчанию все оставшиеся задания будут потеряны. Это может быть нормальным для маленьких приложений или некритичных заданий, но для большей части серьезных приложений нужно подобрать персистентный бэкенд.

### (backends) Бэкенды

У Active Job есть встроенные адаптеры для различных бэкендов очередей (Sidekiq, Resque, Delayed Job и другие). Чтобы получить актуальный список адаптеров, обратитесь к документации API по [`ActiveJob::QueueAdapters`][].

[`ActiveJob::QueueAdapters`]: https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html

### Настройка бэкенда

Настроить бэкенд — это просто с помощью [`config.active_job.queue_adapter`]:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # Убедитесь, что гем адаптера добавлен в Gemfile, и что выполнены
    # инструкции по установке и развертыванию адаптера.
    config.active_job.queue_adapter = :sidekiq
  end
end
```

Также можно настроить бэкенд для отдельного задания:

```ruby
class GuestsCleanupJob < ApplicationJob
  self.queue_adapter = :resque
  # ...
end

# Теперь ваше задание будет использовать `resque` в качестве адаптера бэкенда очереди,
# переопределяя тот, что был настроен в `config.active_job.queue_adapter`.
```

[`config.active_job.queue_adapter`]: /configuring#config-active-job-queue-adapter

### Запуск бэкенда

Поскольку задания запускаются параллельно с вашим Rails приложением, большинство библиотек для работы с очередями требуют запуска специфичного для библиотеки сервиса очередей (помимо старта Rails приложения) для обработки заданий. Обратитесь к документации по библиотеке за инструкциями по запуску бэкенда очереди.

Вот неполный список документации:

- [Sidekiq](https://github.com/mperham/sidekiq/wiki/Active-Job)
- [Resque](https://github.com/resque/resque/wiki/ActiveJob)
- [Sneakers](https://github.com/jondot/sneakers/wiki/How-To:-Rails-Background-Jobs-with-ActiveJob)
- [Sucker Punch](https://github.com/brandonhilkert/sucker_punch#active-job)
- [Queue Classic](https://github.com/QueueClassic/queue_classic#active-job)
- [Delayed Job](https://github.com/collectiveidea/delayed_job#active-job)
- [Que](https://github.com/que-rb/que#additional-rails-specific-setup)
- [Good Job](https://github.com/bensheldon/good_job#readme)
- [Solid Queue](https://github.com/rails/solid_queue?tab=readme-ov-file#solid-queue)

Очереди
-------

Большая часть адаптеров поддерживает несколько очередей. С помощью Active Job можно запланировать, что задание будет выполнено в определенной очереди, с помощью [`queue_as`][]:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end
```

Можно задать префикс для имени очереди для всех заданий с помощью [`config.active_job.queue_name_prefix`][] в `application.rb`:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end

# Теперь ваше задание запустится в очереди production_low_priority в среде
# production и в staging_low_priority в среде staging
```

Также можно настроить префикс на уровне задания.

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  self.queue_name_prefix = nil
  # ...
end

# Теперь очередь задания не будет иметь префикс, переопределяя то,
# что было настроено в `config.active_job.queue_name_prefix`.
```

Разделитель префикса имени очереди по умолчанию '\_'. Его можно изменить, установив [`config.active_job.queue_name_delimiter`][] в `application.rb`:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
    config.active_job.queue_name_delimiter = '.'
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end

# Теперь ваше задание запустится в очереди production.low_priority в среде
# production и в staging.low_priority в среде staging
```

Чтобы контролировать очередь на уровне задания, можно передать блок в `queue_as`. Блок будет выполнен в контексте задания (таким образом, у него будет доступ к `self.arguments`), и он должен вернуть имя очереди:

```ruby
class ProcessVideoJob < ApplicationJob
  queue_as do
    video = self.arguments.first
    if video.owner.premium?
      :premium_videojobs
    else
      :videojobs
    end
  end

  def perform(video)
    # Делаем обработку видео
  end
end
```

```ruby
ProcessVideoJob.perform_later(Video.last)
```

Если хотите больше контроля, в какой очереди задание будет запущено, можно передать опцию `:queue` в `set`:

```ruby
MyJob.set(queue: :another_queue).perform_later(record)
```

NOTE: Убедитесь, что ваш бэкенд для очередей "слушает" имя вашей очереди. Для некоторых бэкендов необходимо указать очереди, которые нужно слушать.

[`config.active_job.queue_name_delimiter`]: /configuring#config-active-job-queue-name-delimiter
[`config.active_job.queue_name_prefix`]: /configuring#config-active-job-queue-name-prefix
[`queue_as`]: https://api.rubyonrails.org/classes/ActiveJob/QueueName/ClassMethods.html#method-i-queue_as

Приоритет
---------

Некоторые адаптеры поддерживают приоритеты на уровне заданий. Это позволяет устанавливать приоритетность выполнения заданий относительно друг друга внутри очереди или во всех очередях.

Вы можете запланировать выполнение задания с определенным приоритетом с помощью [`queue_with_priority`][].

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_with_priority 10
  # ...
end
```

Обратите внимание, что это не будет работать с адаптерами, которые не поддерживают приоритеты.

Аналогично `queue_as`, вы можете передать блок в `queue_with_priority` для его выполнения в контексте задания:

```ruby
class ProcessVideoJob < ApplicationJob
  queue_with_priority do
    video = self.arguments.first
    if video.owner.premium?
      0
    else
      10
    end
  end

  def perform(video)
    # Обработка видео
  end
end
```

```ruby
ProcessVideoJob.perform_later(Video.last)
```

Можно передать опцию `:priority` в `set`:

```ruby
MyJob.set(priority: 50).perform_later(record)
```

[`queue_with_priority`]: https://api.rubyonrails.org/classes/ActiveJob/QueuePriority/ClassMethods.html#method-i-queue_with_priority

Колбэки
-------

Active Job предоставляет хуки для включения логики на протяжение жизненного цикла задания. Подобно другим колбэкам в Rails, можно реализовывать колбэки как обычные методы и использовать макрос-метод класса, чтобы зарегистрировать их в качестве колбэков:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  around_perform :around_cleanup

  def perform
    # Отложенное задание
  end

  private
    def around_cleanup
      # Делаем что-то перед perform
      yield
      # Делаем что-то после perform
    end
end
```

Макрос-методы класса также могут принимать блок. Рассмотрите возможность использования этого макроса, если код внутри блока настолько короток, что он помещается в одну строчку. Например, можно отправлять показатели для каждого помещенного в очередь задания.

```ruby
class ApplicationJob < ActiveJob::Base
  before_enqueue { |job| $statsd.increment "#{job.class.name.underscore}.enqueue" }
end
```

### Доступные колбэки

* [`before_enqueue`][]
* [`around_enqueue`][]
* [`after_enqueue`][]
* [`before_perform`][]
* [`around_perform`][]
* [`after_perform`][]

[`before_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_enqueue
[`around_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_enqueue
[`after_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_enqueue
[`before_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_perform
[`around_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_perform
[`after_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_perform

Имейте в виду, что при добавлении заданий в очередь группами с помощью `perform_all_later`, колбэки, такие как `around_enqueue`, не будут вызываться для отдельных заданий. Подробнее в [Колбэки массового добавления в очередь](#bulk-enqueue-callbacks).

(bulk-enqueuing) Массовое добавление в очередь
----------------------------------------------

Вы можете добавить несколько заданий в очередь одновременно с помощью метода [`perform_all_later`](https://api.rubyonrails.org/classes/ActiveJob.html#method-c-perform_all_later). Массовое добавление в очередь сокращает количество обращений к хранилищу данных очереди (например, Redis или базе данных), что делает эту операцию более производительной по сравнению с добавлением тех же заданий по отдельности.

`perform_all_later` - это высокоуровневый API в Active Job. Он принимает в качестве аргументов экземпляры уже созданных заданий (обратите внимание, что это отличается от `perform_later`). `perform_all_later` вызывает `perform` внутри себя. Аргументы, переданные в `new`, будут переданы в `perform`, когда он будет вызван.

Вот пример вызова `perform_all_later` с экземплярами `GuestCleanupJob`:

```ruby
# Создание заданий для передачи в `perform_all_later`.
# Аргументы в `new` передадутся в `perform`
guest_cleanup_jobs = Guest.all.map { |guest| GuestsCleanupJob.new(guest) }

# Добавит в очередь отдельное задание для каждого экземпляра  `GuestCleanupJob`
ActiveJob.perform_all_later(guest_cleanup_jobs)

# Также можно использовать метод `set` для настройки опций перед массовым добавлением в очередь.
guest_cleanup_jobs = Guest.all.map { |guest| GuestsCleanupJob.new(guest).set(wait: 1.day) }

ActiveJob.perform_all_later(guest_cleanup_jobs)
```

`perform_all_later` ведёт журнал количества успешно поставленных в очередь задач. Например, если `Guest.all.map` выше вернул 3 `guest_cleanup_jobs`, он бы записал в журнал: `Enqueued 3 jobs to Async (3 GuestsCleanupJob)` (при условии, что все были поставлены).

Возвращаемое значение `perform_all_later` равно `nil`. Обратите внимание, что это отличается от `perform_later`, который возвращает экземпляр класса поставленной в очередь задачи.

### Постановка в очередь нескольких классов ActiveJob

С помощью `perform_all_later` также можно ставить в очередь экземпляры разных классов ActiveJob в одном вызове. Например:

```ruby
class ExportDataJob < ApplicationJob
  def perform(*args)
    # Экспорт данных
  end
end

class NotifyGuestsJob < ApplicationJob
  def perform(*guests)
    # Рассылка гостям
  end
end

# Инициализируем экземпляры заданий
cleanup_job = GuestsCleanupJob.new(guest)
export_job = ExportDataJob.new(data)
notify_job = NotifyGuestsJob.new(guest)

# Добавляем в очередь экземпляры заданий из нескольких классов за раз
ActiveJob.perform_all_later(cleanup_job, export_job, notify_job)
```

### (bulk-enqueue-callbacks) Колбэки массового добавления в очередь

При массовой постановке задач в очередь с помощью `perform_all_later` колбэки, такие как `around_enqueue`, не будут вызываться для отдельных задач. Это поведение согласуется с другими методами массовых операций Active Record. Поскольку колбэки выполняются для отдельных задач, они не могут использовать преимущества массового характера этого метода.

Однако метод `perform_all_later` вызывает событие [`enqueue_all.active_job`](/active-support-instrumentation#enqueue-all-active-job), на которое вы можете подписаться с помощью `ActiveSupport::Notifications`.

Метод [`successfully_enqueued?`](https://api.rubyonrails.org/classes/ActiveJob/Core.html#method-i-successfully_enqueued-3F) можно использовать, чтобы узнать, была ли определенная задача успешно поставлена в очередь.

### Поддержка бэкенда очереди

Для `perform_all_later` массовая постановка в очередь должна поддерживаться [бэкендом очереди](#backends)

Например, Sidekiq имеет метод `push_bulk`, который может отправить большое количество задач в Redis и предотвратить сетевую задержку при каждом запросе. GoodJob также поддерживает массовую постановку в очередь с помощью метода `GoodJob::Bulk.enqueue`. Новый бэкенд очереди [`Solid Queue`](https://github.com/rails/solid_queue/pull/93) также добавил поддержку массовой постановки в очередь.

Если бэкенд очереди *не* поддерживает массовую постановку в очередь, `perform_all_later` будет ставить задачи в очередь по одной.

Action Mailer
-------------

Одним из обычных заданий в современном веб-приложении является рассылка писем за пределами цикла запроса-отклика, чтобы пользователь не ждал. Active Job интегрируется с Action Mailer, поэтому рассылать письма асинхронно очень просто:

```ruby
# Если хотите отправить письмо сейчас, используйте #deliver_now
UserMailer.welcome(@user).deliver_now

# Если хотите отправить письмо через Active Job, используйте #deliver_later
UserMailer.welcome(@user).deliver_later
```

NOTE: Использование асинхронной очереди из задач Rake (например, для отправки электронной почты с помощью `.deliver_later`), как правило, не будет работать, потому что Rake, вероятно, завершится, в результате чего пул тредов внутри процесса будет удален до того, как любой/все из `.deliver_later` писем будут обработаны. Чтобы избежать этой проблемы, используйте `.deliver_now` или запустите персистентную очередь в development режиме.

Интернационализация
-------------------

Каждое задание использует настройку `I18n.locale` при создании. Это полезно, если вы отправляете письма асинхронно:

```ruby
I18n.locale = :eo

UserMailer.welcome(@user).deliver_later # Email будет локализован в Эсперанто.
```

Поддерживаемые типы аргументов
------------------------------

ActiveJob по умолчанию поддерживает следующие типы аргументов:

- Базовые типы (`NilClass`, `String`, `Integer`, `Float`, `BigDecimal`, `TrueClass`, `FalseClass`)
- `Symbol`
- `Date`
- `Time`
- `DateTime`
- `ActiveSupport::TimeWithZone`
- `ActiveSupport::Duration`
- `Hash` (Ключи должны быть типа `String` или `Symbol`)
- `ActiveSupport::HashWithIndifferentAccess`
- `Array`
- `Range`
- `Module`
- `Class`

### GlobalID

Active Job поддерживает [GlobalID](https://github.com/rails/globalid/blob/main/README.md) для параметров. Это позволяет передавать объекты Active Record в ваши задания, вместо пар класс/id, которые нужно затем десериализовать вручную. Раньше задания выглядели так:

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable_class, trashable_id, depth)
    trashable = trashable_class.constantize.find(trashable_id)
    trashable.cleanup(depth)
  end
end
```

Теперь можно просто сделать так:

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

Это работает с любым классом, в который подмешан `GlobalID::Identification`, который по умолчанию был подмешан в классы Active Record.

### Сериализаторы

Можно расширить список поддерживаемых типов для аргументов. Для этого необходимо определить свой собственный сериализатор.

```ruby
# app/serializers/money_serializer.rb
class MoneySerializer < ActiveJob::Serializers::ObjectSerializer
  # Проверяем, должен ли argument быть сериализован с использованием этого сериализатора.
  def serialize?(argument)
    argument.is_a? Money
  end

  # Преобразование объекта к более простому представителю, используя поддерживаемые типы объектов.
  # Рекомендуемым представителем является хэш с определенным ключом. Ключи могут быть только базового типа.
  # Необходимо вызвать `super`, чтобы добавить собственный тип сериализатора в хэш.
  def serialize(money)
    super(
      "amount" => money.amount,
      "currency" => money.currency
    )
  end

  # Преобразование сериализованного значения в надлежащий объект.
  def deserialize(hash)
    Money.new(hash["amount"], hash["currency"])
  end
end
```

и добавить этот сериализатор в список:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

Отметьте, что автозагрузка перезагружаемого кода в течение инициализации не поддерживается. Поэтому рекомендуется настраивать сериализаторы, чтобы они загружались лишь однажды, то есть изменяя `config/application.rb` таким образом:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.autoload_once_paths << Rails.root.join('app', 'serializers')
  end
end
```

Исключения
----------

Исключения, вызванные в течение исполнения задания, могут быть обработаны с помощью [`rescue_from`][]:

```ruby

class GuestsCleanupJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    # Сделать что-то с этим исключением
  end

  def perform
    # Отложенное задание
  end
end
```

Если исключение от задания не будет поймано, тогда задание будет помечено как "неудачное".

[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from

### Повторная отправка или отмена неудачных заданий

Неудачное задание не будет повторено, если не настроено обратное.

Возможно повторить отправку или отменить неудачное задание, с помощью [`retry_on`] или [`discard_on`], соответственно. Например:

```ruby
class RemoteServiceJob < ApplicationJob
  retry_on CustomAppException # по умолчанию, ожидание: 3 сек., попыток: 5

  discard_on ActiveJob::DeserializationError

  def perform(*args)
    # Может быть вызвано CustomAppException или ActiveJob::DeserializationError
  end
end
```

[`discard_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-discard_on
[`retry_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on

### Десериализация

GlobalID позволяет сериализовать полностью объекты Active Record, переданные в `#perform`.

Если переданная запись была удалена после того, как задание было помещено в очередь, но до того, как метод `#perform` был вызван, Active Job вызовет исключение [`ActiveJob::DeserializationError`][].

[`ActiveJob::DeserializationError`]: https://api.rubyonrails.org/classes/ActiveJob/DeserializationError.html

Тестирование заданий
--------------------

Подробные инструкции о том, как тестировать ваши задания, можно найти в руководстве [Тестирование приложений на Rails](testing#jobs-testing).

Отладка
-------

Если вам нужна помощь в том, чтобы понять, откуда берутся задания, вы можете включить [подробное логирование](/debugging-rails-applications#verbose-enqueue-logs).

If you need help figuring out where jobs are coming from, you can enable [verbose logging](debugging_rails_applications.html#verbose-enqueue-logs).
