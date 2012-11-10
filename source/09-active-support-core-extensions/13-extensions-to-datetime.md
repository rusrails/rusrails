# Расширения для DateTime

WARNING: `DateTime` не знает о правилах DST (переходов на летнее время) и некоторые из этих методов сталкиваются с крайними случаями, когда переход на и с летнего времени имеет место. К примеру, `seconds_since_midnight` может не возвратить настоящее значение для таких дней.

### Вычисления

NOTE: Все нижеследующие методы определены в `active_support/core_ext/date_time/calculations.rb`.

Класс `DateTime` является подклассом `Date`, поэтому загрузив `active_support/core_ext/date/calculations.rb` вы унаследуете эти методы и их псевдонимы, за исключением того, что они будут всегда возвращать дату и время:

```ruby
yesterday
tomorrow
beginning_of_week (at_beginning_of_week)
end_of_week (at_end_of_week)
monday
sunday
weeks_ago
prev_week (last_week)
next_week
months_ago
months_since
beginning_of_month (at_beginning_of_month)
end_of_month (at_end_of_month)
prev_month (last_month)
next_month
beginning_of_quarter (at_beginning_of_quarter)
end_of_quarter (at_end_of_quarter)
beginning_of_year (at_beginning_of_year)
end_of_year (at_end_of_year)
years_ago
years_since
prev_year (last_year)
next_year
```

Следующие методы переопределены, поэтому **не** нужно загружать `active_support/core_ext/date/calculations.rb` для них:

```ruby
beginning_of_day (midnight, at_midnight, at_beginning_of_day)
end_of_day
ago
since (in)
```

С другой стороны, `advance` и `change` также определяются и поддерживают больше опций, чем было сказано [ранее](/active-support-core-extensions/extensions-to-date#advance).

Следующие методы реализованы только в `active_support/core_ext/date_time/calculations.rb`, так как они имеют смысл только при использовании с экземпляром `DateTime`:

```ruby
beginning_of_hour (at_beginning_of_hour)
end_of_hour
```

#### Именнованные Datetime

##### `DateTime.current`

Active Support определяет `DateTime.current` похожим на `Time.now.to_datetime`, за исключением того, что он учитывает временную зону пользователя, если она определена. Он также определяет условия экземпляра `past?` и `future?` относительно `DateTime.current`.

#### Другие расширения

##### `seconds_since_midnight`

Метод `seconds_since_midnight` возвращает число секунд, прошедших с полуночи:

```ruby
now = DateTime.current     # => Mon, 07 Jun 2010 20:26:36 +0000
now.seconds_since_midnight # => 73596
```

##### `utc`

Метод `utc` выдает те же дату и время получателя, выраженную в UTC.

```ruby
now = DateTime.current # => Mon, 07 Jun 2010 19:27:52 -0400
now.utc                # => Mon, 07 Jun 2010 23:27:52 +0000
```

У этого метода также есть псевдоним `getutc`.

##### `utc?`

Условие `utc?` говорит, имеет ли получатель UTC как его временную зону:

```ruby
now = DateTime.now # => Mon, 07 Jun 2010 19:30:47 -0400
now.utc?           # => false
now.utc.utc?       # => true
```

##### `advance`

Более обычным способом перейти к другим дате и времени является `advance`. Этот метод получает хэш с ключами `:years`, `:months`, `:weeks`, `:days`, `:hours`, `:minutes` и `:seconds`, и возвращает дату и время, передвинутые на столько, на сколько указывают существующие ключи.

```ruby
d = DateTime.current
# => Thu, 05 Aug 2010 11:33:31 +0000
d.advance(:years => 1, :months => 1, :days => 1, :hours => 1, :minutes => 1, :seconds => 1)
# => Tue, 06 Sep 2011 12:34:32 +0000
```

Этот метод сначала вычисляет дату назначения, передавая `:years`, `:months`, `:weeks` и `:days` в `Date#advance`, описанный [ранее](/active-support-core-extensions/extensions-to-date#advance). После этого, он корректирует время, вызвав `since` с количеством секунд, на которое нужно передвинуть. Этот порядок обоснован, другой порядок мог бы дать другие дату и время в некоторых крайних случаях. Применим пример в `Date#advance`, и расширим его, показав обоснованность порядка, применимого к битам времени.

Если сначала передвинуть биты даты (относительный порядок вычисления, показанный ранее), а затем биты времени, мы получим для примера следующее вычисление:

```ruby
d = DateTime.new(2010, 2, 28, 23, 59, 59)
# => Sun, 28 Feb 2010 23:59:59 +0000
d.advance(:months => 1, :seconds => 1)
# => Mon, 29 Mar 2010 00:00:00 +0000
```

но если мы вычисляем обратным способом, результат будет иным:

```ruby
d.advance(:seconds => 1).advance(:months => 1)
# => Thu, 01 Apr 2010 00:00:00 +0000
```

WARNING: Поскольку `DateTime` не знает о переходе на летнее время, можно получить несуществующий момент времени без каких либо предупреждений или ошибок об этом.

#### Изменение компонентов

Метод `change` позволяет получить новые дату и время, которая идентична получателю, за исключением заданных опций, включающих `:year`, `:month`, `:day`, `:hour`, `:min`, `:sec`, `:offset`, `:start`:

```ruby
now = DateTime.current
# => Tue, 08 Jun 2010 01:56:22 +0000
now.change(:year => 2011, :offset => Rational(-6, 24))
# => Wed, 08 Jun 2011 01:56:22 +0600
```

Если часы обнуляются, то минуты и секунды тоже (если у них не заданы значения):

```ruby
now.change(:hour => 0)
# => Tue, 08 Jun 2010 00:00:00 +0000
```

Аналогично, если минуты обнуляются, то секунды тоже(если у них не задано значение):

```ruby
now.change(:min => 0)
# => Tue, 08 Jun 2010 01:00:00 +0000
```

Этот метод нетолерантен к несуществующим датам, если изменение невалидно, вызывается `ArgumentError`:

```ruby
DateTime.current.change(:month => 2, :day => 30)
# => ArgumentError: invalid date
```

#### Длительности

Длительности могут добавляться и вычитаться из даты и времени:

```ruby
now = DateTime.current
# => Mon, 09 Aug 2010 23:15:17 +0000
now ` 1.year
# => Tue, 09 Aug 2011 23:15:17 +0000
now - 1.week
# => Mon, 02 Aug 2010 23:15:17 +0000
```

Это переводится в вызовы `since` или `advance`. Для примера выполним корректный переход во время календарной реформы:

```ruby
DateTime.new(1582, 10, 4, 23) + 1.hour
# => Fri, 15 Oct 1582 00:00:00 +0000
```
