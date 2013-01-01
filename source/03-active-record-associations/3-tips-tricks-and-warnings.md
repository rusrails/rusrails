# Полезные советы и предупреждения

Вот некоторые вещи, которые необходимо знать для эффективного использования связей Active Record в Вашем приложении на Rails:

* Управление кэшированием
* Предотвращение коллизий имен
* Обновление схемы
* Управление областью видимости связей
* Двусторонние связи

### Управление кэшированием

Все методы связи построены вокруг кэширования, которое хранит результаты последних запросов доступными для будущих операций. Кэш является общим для разных методов. Например:

```ruby
customer.orders                 # получаем заказы из базы данных
customer.orders.size            # используем кэшированную копию заказов
customer.orders.empty?          # используем кэшированную копию заказов
```

Но что если вы хотите перезагрузить кэш, так как данные могли быть изменены другой частью приложения? Всего лишь передайте `true` в вызов связи:

```ruby
customer.orders                 # получаем заказы из базы данных
customer.orders.size            # используем кэшированную копию заказов
customer.orders(true).empty?    # отказываемся от кэшированной копии заказов
                                # и снова обращаемся к базе данных
```

### Предотвращение коллизий имен

Вы не свободны в выборе любого имени для своих связей. Поскольку создание связи добавляет метод с таким именем в модель, будет плохой идеей дать связи имя, уже используемое как метод экземпляра `ActiveRecord::Base`. Метод связи тогда переопределит базовый метод, и что-нибудь перестанет работать. Например, `attributes` или `connection` плохие имена для связей.

### Обновление схемы

Связи очень полезные, но не волшебные. Вы ответственны за содержание вашей схемы базы данных в соответствии со связями. На практике это означает две вещи, в зависимости от того, какой тип связей создаете. Для связей `belongs_to` нужно создать внешние ключи, а для связей `has_and_belongs_to_many` нужно создать подходящую соединительную таблицу.

#### Создание внешних ключей для связей `belongs_to`

Когда объявляете связь `belongs_to`, нужно создать внешние ключи, при необходимости. Например, рассмотрим эту модель:

```ruby
class Order < ActiveRecord::Base
  belongs_to :customer
end
```

Это объявление нуждается в создании подходящего внешнего ключа в таблице orders:

```ruby
class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.datetime :order_date
      t.string   :order_number
      t.integer  :customer_id
    end
  end
end
```

Если создаете связь после того, как уже создали модель, лежащую в основе, необходимо не забыть создать миграцию `add_column` для предоставления необходимого внешнего ключа.

#### Создание соединительных таблиц для связей `has_and_belongs_to_many`

Если вы создали связь `has_and_belongs_to_many`, необходимо обязательно создать соединительную таблицу. Если имя соединительной таблицы явно не указано с использованием опции `:join_table`, Active Record создает имя, используя алфавитный порядок имен классов. Поэтому соединение между моделями customer и order по умолчанию даст значение имени таблицы "customers_orders", так как "c" идет перед "o" в алфавитном порядке.

WARNING: Приоритет между именами модели рассчитывается с использованием оператора `<` для `String`. Это означает, что если строки имеют разную длину. и в своей короткой части они равны, тогда более длинная строка рассматривается как большая, по сравнению с короткой. Например, кто-то ожидает, что таблицы "paper_boxes" и "papers" создадут соединительную таблицу "papers_paper_boxes" поскольку имя "paper_boxes" длинее, но фактически будет сгенерирована таблица с именем "paper_boxes_papers" (поскольку знак подчеркивания "_" лексикографически _меньше_, чем "s" в обычной кодировке).

Какое бы ни было имя, вы должны вручную сгенерировать соединительную таблицу в соответствующей миграции. Например, рассмотрим эти связи:

```ruby
class Assembly < ActiveRecord::Base
  has_and_belongs_to_many :parts
end

class Part < ActiveRecord::Base
  has_and_belongs_to_many :assemblies
end
```

Теперь нужно написать миграцию для создания таблицы `assemblies_parts`. Эта таблица должна быть создана без первичного ключа:

```ruby
class CreateAssemblyPartJoinTable < ActiveRecord::Migration
  def change
    create_table :assemblies_parts, id: false do |t|
      t.integer :assembly_id
      t.integer :part_id
    end
  end
end
```

Мы передаем `id: false` в `create_table`, так как эта таблица не представляет модель. Это необходимо, чтобы связь работала правильно. Если вы видите странное поведение в связи `has_and_belongs_to_many`, например, искаженные ID моделей, или исключения в связи с конфликтом ID, скорее всего вы забыли убрать первичный ключ.

### Управление областью видимости связей

По умолчанию связи ищут объекты только в пределах области видимости текущего модуля. Это важно, когда вы объявляете модели Active Record внутри модуля. Например:

```ruby
module MyApplication
  module Business
    class Supplier < ActiveRecord::Base
       has_one :account
    end

    class Account < ActiveRecord::Base
       belongs_to :supplier
    end
  end
end
```

Это будет работать, так как оба класса `Supplier` и `Account` определены в пределах одной области видимости. Но нижеследующее не будет работать, потому что `Supplier` и `Account` определены в разных областях видимости:

```ruby
module MyApplication
  module Business
    class Supplier < ActiveRecord::Base
       has_one :account
    end
  end

  module Billing
    class Account < ActiveRecord::Base
       belongs_to :supplier
    end
  end
end
```

Для связи модели с моделью в другом пространстве имен, необходимо указать полное имя класса в объявлении связи:

```ruby
module MyApplication
  module Business
    class Supplier < ActiveRecord::Base
       has_one :account,
        class_name: "MyApplication::Billing::Account"
    end
  end

  module Billing
    class Account < ActiveRecord::Base
       belongs_to :supplier,
        class_name: "MyApplication::Business::Supplier"
    end
  end
end
```

### Двусторонние связи

Для связей нормально работать в двух направлениях, затребовав объявление в двух различных моделях:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders
end

class Order < ActiveRecord::Base
  belongs_to :customer
end
```

По умолчанию, Active Record не знает о зависимости между этими двумя связями. Это может привести к двум несинхронизированным копиям объекта:

```ruby
c = Customer.first
o = c.orders.first
c.first_name == o.customer.first_name # => true
c.first_name = 'Manny'
c.first_name == o.customer.first_name # => false
```

Это произошло потому, что c и o.customer это два разных представления в памяти одних и тех же данных, и ни одно из них автоматически не обновляется при изменении другого. Active Record предоставляет опцию `:inverse_of`, чтобы вы могли его проинформировать об этих зависимостях:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, inverse_of: :customer
end

class Order < ActiveRecord::Base
  belongs_to :customer, inverse_of: :orders
end
```

С этими изменениями Active Record загрузит только одну копию объекта customer, предотвратив несоответствия и сделав приложение более эффективным:

```ruby
c = Customer.first
o = c.orders.first
c.first_name == o.customer.first_name # => true
c.first_name = 'Manny'
c.first_name == o.customer.first_name # => true
```

Имеется несколько ограничений в поддержке `inverse_of`:

* Они не работают со связями `:through`.
* Они не работают со связями `:polymorphic`.
* Они не работают со связями `:as`.
* Для связей `belongs_to` противоположные связи `has_many` игнорируются.
