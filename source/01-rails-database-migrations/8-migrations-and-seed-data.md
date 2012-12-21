# Миграции и сиды

Кто-то использует миграции для добавления данных в базу данных:

```ruby
class AddInitialProducts < ActiveRecord::Migration
  def up
    5.times do |i|
      Product.create(name: "Product ##{i}", description: "A product.")
    end
  end

  def down
    Product.delete_all
  end
end
```

Однако, в Rails есть особенность 'seeds' которая должна быть использована для заполнения базы данных начальными данными. Это действительно простая особенность: просто заполните `db/seeds.rb` некоторым кодом Ruby и запустите `rake db:seed`:

```ruby
5.times do |i|
  Product.create(name: "Product ##{i}", description: "A product.")
end
```

В основном, это более чистый способ настроить базу данных для пустого приложения.
