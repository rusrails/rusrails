# Расширения для Regexp

### `multiline?`

Метод `multiline?` говорит, имеет ли регулярное выражение установленный флаг `/m`, то есть соответствует ли точка новым строкам.

```ruby
%r{.}.multiline?  # => false
%r{.}m.multiline? # => true

Regexp.new('.').multiline?                    # => false
Regexp.new('.', Regexp::MULTILINE).multiline? # => true
```

Rails использует этот метод в одном месте, в коде маршрутизации. Регулярные выражения Multiline недопустимы для маршрутных требований, и этот флаг облегчает обеспечение этого ограничения.

```ruby
def assign_route_options(segments, defaults, requirements)
  ...
  if requirement.multiline?
    raise ArgumentError, "Regexp multiline option not allowed in routing requirements: #{requirement.inspect}"
  end
  ...
end
```

NOTE: Определено в `active_support/core_ext/regexp.rb`.
