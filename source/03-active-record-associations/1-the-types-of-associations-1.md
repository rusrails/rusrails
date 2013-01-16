# Типы связей (часть первая)

В Rails _связи_ - это соединения между двумя моделями Active Record. Связи реализовываются с использованием макро-вызовов (macro-style calls), и таким образом вы можете декларативно добавлять возможности для своих моделей. Например, объявляя, что одна модель принадлежит (`belongs_to`) другой, вы указываете Rails сохранять информацию о первичном-внешнем ключах между экземплярами двух моделей, а также получаете несколько полезных методов, добавленных в модель. Rails поддерживает шесть типов связей:

* `belongs_to`
* `has_one`
* `has_many`
* `has_many :through`
* `has_one :through`
* `has_and_belongs_to_many`

После прочтения всего этого руководства, вы научитесь объявлять и использовать различные формы связей. Но сначала следует быстро ознакомиться с ситуациями, когда применим каждый тип связи.

### Связь `belongs_to`

Связь `belongs_to` устанавливает соединение один-к-одному с другой моделью, когда один экземпляр  объявляющей модели "принадлежит" одному экземпляру другой модели. Например, если в приложении есть покупатели и заказы, и один заказ может быть связан только с одним покупателем, нужно объявить модель order следующим образом:

```ruby
class Order < ActiveRecord::Base
  belongs_to :customer
end
```

![Диаграмма для связи belongs_to](/assets/guides/belongs_to.png)

NOTE: связи `belongs_to` _обязаны_ использовать единственное число. Если использовать множественное число в вышеприведенном примере для связи`customer` в модели `Order`, вам будет сообщено "uninitialized constant Order::Customers". Это так, потому что Rails автоматически получает имя класса из имени связи. Если в имени связи неправильно использовано число, то получаемый класс также будет неправильного числа.

Соответствующая миграция может выглядеть так:

```ruby
class CreateOrders < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :name
      t.timestamps
    end

    create_table :orders do |t|
      t.belongs_to :customer
      t.datetime :order_date
      t.timestamps
    end
  end
end
```

### Связь `has_one`

Связь `has_one` также устанавливает соединение один-к-одному с другой моделью, но в несколько ином смысле (и с другими последствиями). Эта связь показывает, что каждый экземпляр модели содержит или обладает одним экземпляром другой модели. Например, если каждый поставщик имеет только один аккаунт, можете объявить модель supplier подобно этому:

```ruby
class Supplier < ActiveRecord::Base
  has_one :account
end
```

![Диаграмма для связи has_one](/assets/guides/has_one.png)

Соответствующая миграция может выглядеть так:

```ruby
class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end
  end
end
```

### Связь `has_many`

Связь `has_many` указывает на соединение один-ко-многим с другой моделью. Эта связь часто бывает на "другой стороне" связи `belongs_to`. Эта связь указывает на то, что каждый экземпляр модели имеет ноль или более экземпляров другой модели. Например, в приложении, содержащем покупателей и заказы, модель customer может быть объявлена следующим образом:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders
end
```

NOTE: Имя другой модели указывается во множественном числе при объявлении связи `has_many`.

![Диаграмма для связи has_many](/assets/guides/has_many.png)

Соответствующая миграция может выглядеть так:

```ruby
class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :name
      t.timestamps
    end

    create_table :orders do |t|
      t.belongs_to :customer
      t.datetime :order_date
      t.timestamps
    end
  end
end
```

### Связь `has_many :through`

Связь `has_many :through` часто используется для настройки соединения многие-ко-многим с другой моделью. Эта связь указывает, что объявляющая модель может соответствовать нулю или более экземплярам другой модели _через_ третью модель. Например, рассмотрим поликлинику, где пациентам (patients) дают направления (appointments) к врачам (physicians). Соответствующие объявления связей будут выглядеть следующим образом:

```ruby
class Physician < ActiveRecord::Base
  has_many :appointments
  has_many :patients, through: :appointments
end

class Appointment < ActiveRecord::Base
  belongs_to :physician
  belongs_to :patient
end

class Patient < ActiveRecord::Base
  has_many :appointments
  has_many :patients, through: :appointments
end
```

![Диаграмма для связи has_many :through](/assets/guides/has_many_through.png)

Соответствующая миграция может выглядеть так:

```ruby
class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :physicians do |t|
      t.string :name
      t.timestamps
    end

    create_table :patients do |t|
      t.string :name
      t.timestamps
    end

    create_table :appointments do |t|
      t.belongs_to :physician
      t.belongs_to :patient
      t.datetime :appointment_date
      t.timestamps
    end
  end
end
```

Коллекция соединительных моделей может управляться с помощью API. Например, если вы присвоите:

```ruby
physician.patients = patients
```

будет создана новая соединительная модель для вновь связанных объектов, и если некоторые из них закончатся, их строки будут удалены.

WARNING: Автоматическое удаление соединительных моделей прямое, ни один из колбэков на уничтожение не включается.

Связь `has_many :through` также полезна для настройки "ярлыков" через вложенные связи `has_many`. Например, если документ имеет много секций, а секция имеет много параграфов, иногда хочется получить просто коллекцию всех параграфов в документе. Это можно настроить следующим образом:

```ruby
class Document < ActiveRecord::Base
  has_many :sections
  has_many :paragraphs, through: :sections
end

class Section < ActiveRecord::Base
  belongs_to :document
  has_many :paragraphs
end

class Paragraph < ActiveRecord::Base
  belongs_to :section
end
```

С определенным `through: :sections` Rails теперь понимает:

```ruby
@document.paragraphs
```

### Связь `has_one :through`

Связь `has_one :through` настраивает соединение один-к-одному с другой моделью. Эта связь показывает, что объявляющая модель может быть связана с одним экземпляром другой модели _через_ третью модель. Например, если каждый поставщик имеет один аккаунт, и каждый аккаунт связан с одной историей аккаунта, тогда модели могут выглядеть так:

```ruby
class Supplier < ActiveRecord::Base
  has_one :account
  has_one :account_history, through: :account
end

class Account < ActiveRecord::Base
  belongs_to :supplier
  has_one :account_history
end

class AccountHistory < ActiveRecord::Base
  belongs_to :account
end
```

![Диаграмма для связи has_one :through](/assets/guides/has_one_through.png)

Соответствующая миграция может выглядеть так:

```ruby
class CreateAccountHistories < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end

    create_table :account_histories do |t|
      t.belongs_to :account
      t.integer :credit_rating
      t.timestamps
    end
  end
end
```

### Связь `has_and_belongs_to_many`

Связь `has_and_belongs_to_many` создает прямое соединение многие-ко-многим с другой моделью, без промежуточной модели. Например, если ваше приложение включает узлы (assemblies) и детали (parts), где каждый узел имеет много деталей, и каждая деталь встречается во многих узлах, модели можно объявить таким образом:

```ruby
class Assembly < ActiveRecord::Base
  has_and_belongs_to_many :parts
end

class Part < ActiveRecord::Base
  has_and_belongs_to_many :assemblies
end
```

![Диаграмма для связи has_and_belongs_to_many](/assets/guides/habtm.png)

Соответствующая миграция может выглядеть так:

```ruby
class CreateAssembliesAndParts < ActiveRecord::Migration
  def change
    create_table :assemblies do |t|
      t.string :name
      t.timestamps
    end

    create_table :parts do |t|
      t.string :part_number
      t.timestamps
    end

    create_table :assemblies_parts do |t|
      t.belongs_to :assembly
      t.belongs_to :part
    end
  end
end
```
