# Настройка Form Builder

Как ранее упоминалось, объект, который передается от `form_for` и `fields_for`, - это экземпляр FormBuilder (или его подкласса). Form builder инкапсулирует представление элементов формы для отдельного объекта. Хотя, конечно, можно писать хелперы для своих форм обычным способом, вы также можете объявить подкласс FormBuilder и добавить хелперы туда. Например

```erb
<%= form_for @person do |f| %>
  <%= text_field_with_label f, :first_name %>
<% end %>
```

может быть заменено этим

```erb
<%= form_for @person, builder: LabellingFormBuilder do |f| %>
  <%= f.text_field :first_name %>
<% end %>
```

через определение класса LabellingFormBuilder подобным образом:

```ruby
class LabellingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options={})
    label(attribute) + super
  end
end
```

Если это используется часто, можно определить хелпер `labeled_form_for` который автоматически определяет опцию `builder: LabellingFormBuilder`.

Form builder также определяет, что произойдет, если вы сделаете

```erb
<%= render partial: f %>
```

Если `f` - это экземпляр FormBuilder, тогда это отрендерит партиал `form`, установив объект партиала как form builder. Если form builder класса LabellingFormBuilder, тогда вместо этого будет отрендерен партиал `labelling_form`.
