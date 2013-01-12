# Расширения для Numeric, Integer

Расширения для `Numeric`
------------------------

### Байты

Все числа отвечают на эти методы:

```ruby
bytes
kilobytes
megabytes
gigabytes
terabytes
petabytes
exabytes
```

Они возвращают соответствующее количество байтов, используя конвертирующий множитель 1024:

```ruby
2.kilobytes   # => 2048
3.megabytes   # => 3145728
3.5.gigabytes # => 3758096384
-4.exabytes   # => -4611686018427387904
```

Форма в единственном числе является псевдонимом, поэтому можно написать так:

```ruby
1.megabyte # => 1048576
```

NOTE: Определено в `active_support/core_ext/numeric/bytes.rb`.

### Время

Включает использование вычисления и объявления времени, подобно `45.minutes + 2.hours + 4.years`.

Эти методы используют Time#advance для уточнения вычисления дат с использованием from_now, ago, и т. д., а также для сложения или вычитания их результата из объекта Time. Например:

```ruby
# эквивалент для Time.current.advance(months: 1)
1.month.from_now

# эквивалент для Time.current.advance(years: 2)
2.years.from_now

# эквивалент для Time.current.advance(months: 4, years: 5)
(4.months + 5.years).from_now
```

Хотя эти примеры предоставляют точные вычисления при использовании в примерах выше, следует отметить, что это не так, если перед использованием конвертируется результат методов `months', `years', и т.п.:

```ruby
# эквивалент для 30.days.to_i.from_now
1.month.to_i.from_now

# эквивалент для 365.25.days.to_f.from_now
1.year.to_f.from_now
```

В таких случаях, для точного вычисления даты и времени следует использовать основные классы Ruby [Date](http://ruby-doc.org/stdlib/libdoc/date/rdoc/Date.html) и [Time](http://ruby-doc.org/stdlib/libdoc/time/rdoc/Time.html).

NOTE: Определено в `active_support/core_ext/numeric/time.rb`.

### Форматирование

Влючает форматирование чисел различными способами.

Создает строковое представление числа, как телефонного номера:

```ruby
5551234.to_s(:phone)
# => 555-1234
1235551234.to_s(:phone)
# => 123-555-1234
1235551234.to_s(:phone, area_code: true)
# => (123) 555-1234
1235551234.to_s(:phone, delimiter: " ")
# => 123 555 1234
1235551234.to_s(:phone, area_code: true, extension: 555)
# => (123) 555-1234 x 555
1235551234.to_s(:phone, country_code: 1)
# => `1-123-555-1234
```

Создает строковое представление числа, как валюты:

```ruby
1234567890.50.to_s(:currency)                 # => $1,234,567,890.50
1234567890.506.to_s(:currency)                # => $1,234,567,890.51
1234567890.506.to_s(:currency, precision: 3)  # => $1,234,567,890.506
```

Создает строковое представление числа, как процента:

```ruby
100.to_s(:percentage)
# => 100.000%
100.to_s(:percentage, precision: 0)
# => 100%
1000.to_s(:percentage, delimiter: '.', separator: ',')
# => 1.000,000%
302.24398923423.to_s(:percentage, precision: 5)
# => 302.24399%
```

Создает строковое представление числа с разделенными разрядами:

```ruby
12345678.to_s(:delimited)                     # => 12,345,678
12345678.05.to_s(:delimited)                  # => 12,345,678.05
12345678.to_s(:delimited, delimiter: ".")     # => 12.345.678
12345678.to_s(:delimited, delimiter: ",")     # => 12,345,678
12345678.05.to_s(:delimited, separator: " ")  # => 12,345,678 05
```

Создает строковое представление числа, округленного с точностью:

```ruby
111.2345.to_s(:rounded)                     # => 111.235
111.2345.to_s(:rounded, precision: 2)       # => 111.23
13.to_s(:rounded, precision: 5)             # => 13.00000
389.32314.to_s(:rounded, precision: 0)      # => 389
111.2345.to_s(:rounded, significant: true)  # => 111
```

Создает строковое представление числа, как удобочитаемое количество байт:

```ruby
123.to_s(:human_size)            # => 123 Bytes
1234.to_s(:human_size)           # => 1.21 KB
12345.to_s(:human_size)          # => 12.1 KB
1234567.to_s(:human_size)        # => 1.18 MB
1234567890.to_s(:human_size)     # => 1.15 GB
1234567890123.to_s(:human_size)  # => 1.12 TB
```

Создает строковое представление числа, как удобочитаемое число словами:

```ruby
123.to_s(:human)               # => "123"
1234.to_s(:human)              # => "1.23 Thousand"
12345.to_s(:human)             # => "12.3 Thousand"
1234567.to_s(:human)           # => "1.23 Million"
1234567890.to_s(:human)        # => "1.23 Billion"
1234567890123.to_s(:human)     # => "1.23 Trillion"
1234567890123456.to_s(:human)  # => "1.23 Quadrillion"
```

NOTE: Определено в `active_support/core_ext/numeric/formatting.rb`.

Расширения для `Integer`
------------------------

### `multiple_of?`

Метод `multiple_of?` тестирует, является ли число множителем аргумента:

```ruby
2.multiple_of?(1) # => true
1.multiple_of?(2) # => false
```

NOTE: Определено в `active_support/core_ext/integer/multiple.rb`.

### `ordinal`

Метод `ordinal` возвращает суффикс порядковой строки, соответствующей полученному числу:

```ruby
1.ordinal    # => "st"
2.ordinal    # => "nd"
53.ordinal   # => "rd"
2009.ordinal # => "th"
-21.ordinal  # => "st"
-134.ordinal # => "th"
```

NOTE: Defined in `active_support/core_ext/integer/inflections.rb`.

### `ordinalize`

Метод `ordinalize` возвращает порядковые строки, соответствующие полученному числу. Для сравнения отметьте, что метод `ordinal` возвращает **только** строковый суффикс.

```ruby
1.ordinalize    # => "1st"
2.ordinalize    # => "2nd"
53.ordinalize   # => "53rd"
2009.ordinalize # => "2009th"
-21.ordinalize  # => "-21st"
-134.ordinalize # => "-134th"
```

NOTE: Определено в `active_support/core_ext/integer/inflections.rb`.
