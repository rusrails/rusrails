# Расширения для Class

### Атрибуты класса

#### `class_attribute`

Метод `class_attribute` объявляет один или более наследуемых атрибутов класса, которые могут быть переопределены на низшем уровне иерархии:

```ruby
class A
  class_attribute :x
end

class B < A; end

class C < B; end

A.x = :a
B.x # => :a
C.x # => :a

B.x = :b
A.x # => :a
C.x # => :b

C.x = :c
A.x # => :a
B.x # => :b
```

Например, `ActionMailer::Base` определяет:

```ruby
class_attribute :default_params
self.default_params = {
  mime_version: "1.0",
  charset: "UTF-8",
  content_type: "text/plain",
  parts_order: [ "text/plain", "text/enriched", "text/html" ]
}.freeze
```

К ним также есть доступ, и они могут быть переопределены на уровне экземпляра:

```ruby
A.x = 1

a1 = A.new
a2 = A.new
a2.x = 2

a1.x # => 1, приходит из A
a2.x # => 2, переопределено в a2
```

Создание райтер-метода экземпляра может быть отключено установлением опции `:instance_writer` в false, как в

```ruby
module ActiveRecord
  class Base
    class_attribute :table_name_prefix, instance_writer: false
    self.table_name_prefix = ""
  end
end
```

В модели такая опция может быть полезной как способ предотвращения массового назначения для установки атрибута.

Создание ридер-метода может быть отключено установлением опции `:instance_reader` в `false`.

```ruby
class A
  class_attribute :x, instance_reader: false
end

A.new.x = 1 # NoMethodError
```

Для удобства `class_attribute` определяет также условие экземпляра, являющееся двойным отрицанием того, что возвращает ридер экземпляра. В вышеописанном примере оно может вызываться `x?`.

Когда `instance_reader` равен `false`, условие экземпляра возвратит `NoMethodError`, как и метод ридера.

NOTE: Определено в `active_support/core_ext/class/attribute.rb`

#### `cattr_reader`, `cattr_writer` и `cattr_accessor`

Макросы `cattr_reader`, `cattr_writer` и `cattr_accessor` являются аналогами их коллег `attr_*`, но для классов. Они инициализируют переменную класса как `nil`, если она уже существует, и создают соответствующие методы класса для доступа к ней:

```ruby
class MysqlAdapter < AbstractAdapter
  # Generates class methods to access @@emulate_booleans.
  cattr_accessor :emulate_booleans
  self.emulate_booleans = true
end
```

Методы экземпляра также создаются для удобства, они всего лишь прокси к атрибуту класса. Таким образом, экземпляры могут менять атрибут класса, но не могут переопределить его, как это происходит в случае с `class_attribute` (смотрите выше). К примеру, задав

```ruby
module ActionView
  class Base
    cattr_accessor :field_error_proc
    @@field_error_proc = Proc.new{ ... }
  end
end
```

мы получим доступ к `field_error_proc` во вьюхах.

Создание ридер-метода экземпляра предотвращается установкой `:instance_reader` в `false` и создание райтер-метода экземпляра предотвращается установкой `:instance_writer` в `false`. Создание обоих методов предотвращается установкой `:instance_accessor` в `false`. Во всех случаях, должно быть не любое ложное значение, а именно `false`:

```ruby
module A
  class B
    # No first_name instance reader is generated.
    cattr_accessor :first_name, instance_reader: false
    # No last_name= instance writer is generated.
    cattr_accessor :last_name, instance_writer: false
    # No surname instance reader or surname= writer is generated.
    cattr_accessor :surname, instance_accessor: false
  end
end
```

В модели может быть полезным установить `:instance_accessor` в `false` как способ предотвращения массового назначения для установки атрибута.

NOTE: Определено в `active_support/core_ext/class/attribute_accessors.rb`.

### Субклассы и потомки

#### `subclasses`

Метод `subclasses` возвращает субклассы получателя:

```ruby
class C; end
C.subclasses # => []

class B < C; end
C.subclasses # => [B]

class A < B; end
C.subclasses # => [B]

class D < C; end
C.subclasses # => [B, D]
```

Порядок, в котором эти классы возвращаются, неопределен.

NOTE: Определено в `active_support/core_ext/class/subclasses.rb`.

#### `descendants`

Метод `descendants` возвращает все классы, которые являются <tt>&lt;</tt> к его получателю:

```ruby
class C; end
C.descendants # => []

class B < C; end
C.descendants # => [B]

class A < B; end
C.descendants # => [B, A]

class D < C; end
C.descendants # => [B, A, D]
```

Порядок, в котором эти классы возвращаются, неопределен.

NOTE: Определено в `active_support/core_ext/class/subclasses.rb`.
