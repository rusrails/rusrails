# Расширения для Proc

### `bind`

Как известно, в Ruby имеется класс `UnboundMethod`, экземпляры которого являются методами с неопределенной принадлежностью (без self). Метод `Module#instance_method` возвращает несвязанный метод, например:

```ruby
Hash.instance_method(:delete) # => #<UnboundMethod: Hash#delete>
```

Несвязанный метод нельзя вызвать как есть, необходимо сначала связать его с объектом с помощью `bind`:

```ruby
clear = Hash.instance_method(:clear)
clear.bind({:a => 1}).call # => {}
```

Active Support определяет `Proc#bind` с аналогичным назначением:

```ruby
Proc.new { size }.bind([]).call # => 0
```

Как видите, это вызывается и привязывается к аргументу, возвращаемое значение действительно `Method`.

NOTE: Для этого `Proc#bind` фактически создает метод внутри. Если вдруг увидите метод со странным именем, подобным `__bind_1256598120_237302`, в трассировке стека, знайте откуда это взялось.

Action Pack использует эту хитрость в `rescue_from`, к примеру, который принимает имя метода, а также proc в качестве колбэков для заданного избавляемого исключения. Они должны вызваться в любом случае, поэтому связанный метод возвращается от `handler_for_rescue`, вот сокращенный код вызова:

```ruby
def handler_for_rescue(exception)
  _, rescuer = Array(rescue_handlers).reverse.detect do |klass_name, handler|
    ...
  end

  case rescuer
  when Symbol
    method(rescuer)
  when Proc
    rescuer.bind(self)
  end
end
```

NOTE: Определено в `active_support/core_ext/proc.rb`.
