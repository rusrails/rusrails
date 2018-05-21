Active Record для PostgreSQL
============================

Данное руководство рассказывает о специфике использования PostgreSQL с Active Record.

После прочтения этого руководства, вы узнаете о том:

* Как использовать типы данных PostgreSQL.
* Как использовать первичные ключи UUID.
* Как реализовать полнотекстовый поиск с помощью PostgreSQL.
* Как возвращать ваши модели Active Record, используя представление базы данных.

--------------------------------------------------------------------------------

Для использования адаптера PostgreSQL необходимо установить как минимум версию 9.1.
Предыдущие версии не поддерживаются.

Для начала работы с PostgreSQL почитайте руководство [Конфигурирование приложений на Rails](/configuring-rails-applications#konfigurirovanie-bazy-dannyh-postgresql).
Там описано как правильно настроить Active Record для PostgreSQL.

Типы данных
-----------

PostgreSQL предлагает достаточное количество специфичных типов данных. Далее представлен список типов, которые поддерживаются адаптером PostgreSQL.

### Двоичные типы данных

* [определение типа](https://postgrespro.ru/docs/postgrespro/current/datatype-binary.html)
* [функции и операторы](https://postgrespro.ru/docs/postgrespro/current/functions-binarystring.html)

```ruby
# db/migrate/20140207133952_create_documents.rb
create_table :documents do |t|
  t.binary 'payload'
end

# app/models/document.rb
class Document < ApplicationRecord
end

# Использование
data = File.read(Rails.root + "tmp/output.pdf")
Document.create payload: data
```

### Массивы

* [определение типа](https://postgrespro.ru/docs/postgrespro/current/arrays.html)
* [функции и операторы](https://postgrespro.ru/docs/postgrespro/current/functions-array.html)

```ruby
# db/migrate/20140207133952_create_books.rb
create_table :books do |t|
  t.string 'title'
  t.string 'tags', array: true
  t.integer 'ratings', array: true
end
add_index :books, :tags, using: 'gin'
add_index :books, :ratings, using: 'gin'

# app/models/book.rb
class Book < ApplicationRecord
end

# Использование
Book.create title: "Brave New World",
            tags: ["fantasy", "fiction"],
            ratings: [4, 5]

## Книги с одним тегом
Book.where("'fantasy' = ANY (tags)")

## Книги с несколькими тегами
Book.where("tags @> ARRAY[?]::varchar[]", ["fantasy", "fiction"])

## Книги с рейтингом 3 и более
Book.where("array_length(ratings, 1) >= 3")
```

### Hstore

* [определение типа](https://postgrespro.ru/docs/postgrespro/current/hstore.html)
* [функции и операторы](https://postgrespro.ru/docs/postgrespro/current/hstore.html#idm45576084647360)

NOTE: Чтобы использовать hstore, необходимо включить расширение `hstore`.

```ruby
# db/migrate/20131009135255_create_profiles.rb
ActiveRecord::Schema.define do
  enable_extension 'hstore' unless extension_enabled?('hstore')
  create_table :profiles do |t|
    t.hstore 'settings'
  end
end

# app/models/profile.rb
class Profile < ApplicationRecord
end

# Использование
Profile.create(settings: { "color" => "blue", "resolution" => "800x600" })

profile = Profile.first
profile.settings # => {"color"=>"blue", "resolution"=>"800x600"}

profile.settings = {"color" => "yellow", "resolution" => "1280x1024"}
profile.save!

Profile.where("settings->'color' = ?", "yellow")
# => #<ActiveRecord::Relation [#<Profile id: 1, settings: {"color"=>"yellow", "resolution"=>"1280x1024"}>]>
```

### JSON и JSONB

* [определение типа](https://postgrespro.ru/docs/postgrespro/current/datatype-json.html)
* [функции и операторы](https://postgrespro.ru/docs/postgrespro/current/functions-json.html)

```ruby
# db/migrate/20131220144913_create_events.rb
# ... для типа данных json:
create_table :events do |t|
  t.json 'payload'
end
# ... или для типа данных jsonb:
create_table :events do |t|
  t.jsonb 'payload'
end

# app/models/event.rb
class Event < ApplicationRecord
end

# Использование
Event.create(payload: { kind: "user_renamed", change: ["jack", "john"]})

event = Event.first
event.payload # => {"kind"=>"user_renamed", "change"=>["jack", "john"]}

## Запрос, основанный на JSON документе
# Оператор -> возвращает исходный JSON тип (который может быть объектом), где ->> возвращает текст
Event.where("payload->>'kind' = ?", "user_renamed")
```

### Диапазонные типы

* [определение типа](https://postgrespro.ru/docs/postgrespro/current/rangetypes.html)
* [функции и операторы](https://postgrespro.ru/docs/postgrespro/current/functions-range.html)

Этот тип преобразуется в Ruby [`Range`](http://www.ruby-doc.org/core-2.2.2/Range.html) объекты.

```ruby
# db/migrate/20130923065404_create_events.rb
create_table :events do |t|
  t.daterange 'duration'
end

# app/models/event.rb
class Event < ApplicationRecord
end

# Использование
Event.create(duration: Date.new(2014, 2, 11)..Date.new(2014, 2, 12))

event = Event.first
event.duration # => Tue, 11 Feb 2014...Thu, 13 Feb 2014

## Все события в заданную дату
Event.where("duration @> ?::date", Date.new(2014, 2, 12))

## Работает с границами диапазона
event = Event.
  select("lower(duration) AS starts_at").
  select("upper(duration) AS ends_at").first

event.starts_at # => Tue, 11 Feb 2014
event.ends_at # => Thu, 13 Feb 2014
```

### Составные типы

* [определение типа](https://postgrespro.ru/docs/postgrespro/current/rowtypes.html)

На данный момент нет специальной поддержки для составных типов. Они преобразуются к обычным текстовым столбцам:

```sql
CREATE TYPE full_address AS
(
  city VARCHAR(90),
  street VARCHAR(90)
);
```

```ruby
# db/migrate/20140207133952_create_contacts.rb
execute <<-SQL
 CREATE TYPE full_address AS
 (
   city VARCHAR(90),
   street VARCHAR(90)
 );
SQL
create_table :contacts do |t|
  t.column :address, :full_address
end

# app/models/contact.rb
class Contact < ApplicationRecord
end

# Использование
Contact.create address: "(Paris,Champs-Élysées)"
contact = Contact.first
contact.address # => "(Paris,Champs-Élysées)"
contact.address = "(Paris,Rue Basse)"
contact.save!
```

### Типы перечислений

* [определение типа](https://postgrespro.ru/docs/postgrespro/current/datatype-enum.html)

На данный момент нет специальной поддержки для типов перечислений. Они преобразуются к обычным текстовым столбцам:

```ruby
# db/migrate/20131220144913_create_articles.rb
def up
  execute <<-SQL
    CREATE TYPE article_status AS ENUM ('draft', 'published');
  SQL
  create_table :articles do |t|
    t.column :status, :article_status
  end
end

# NOTE: Не забываем удалить таблицу перед удалением enum.
def down
  drop_table :articles

  execute <<-SQL
    DROP TYPE article_status;
  SQL
end

# app/models/article.rb
class Article < ApplicationRecord
end

# Использование
Article.create status: "draft"
article = Article.first
article.status # => "draft"

article.status = "published"
article.save!
```

Чтобы добавить новое значение до/после существующего, следует использовать [ALTER TYPE](https://postgrespro.ru/docs/postgrespro/current/sql-altertype.html):

```ruby
# db/migrate/20150720144913_add_new_state_to_articles.rb
# NOTE: ALTER TYPE ... ADD VALUE нельзя выполнить в блоке транзакции, поэтому используется disable_ddl_transaction!
disable_ddl_transaction!

def up
  execute <<-SQL
    ALTER TYPE article_status ADD VALUE IF NOT EXISTS 'archived' AFTER 'published';
  SQL
end
```

NOTE: Значения ENUM сейчас нельзя удалять. Можно прочесть почему [здесь](http://www.postgresql.org/message-id/29F36C7C98AB09499B1A209D48EAA615B7653DBC8A@mail2a.alliedtesting.com).

Hint: Чтобы показать все имеющиеся значения enum, можно выполнить этот запрос в консоле `bin/rails db` или `psql`:

```sql
SELECT n.nspname AS enum_schema,
       t.typname AS enum_name,
       e.enumlabel AS enum_value
  FROM pg_type t
      JOIN pg_enum e ON t.oid = e.enumtypid
      JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
```

### Тип UUID

* [определение типа](https://postgrespro.ru/docs/postgrespro/current/datatype-uuid.html)
* [pgcrypto generator function](https://postgrespro.ru/docs/postgrespro/current/pgcrypto.html#idm45576081674672)
* [uuid-ossp generator functions](https://postgrespro.ru/docs/postgrespro/current/uuid-ossp.html)

NOTE: Для использования uuid необходимо включить расширение `pgcrypto` (только PostgreSQL >= 9.4).

```ruby
# db/migrate/20131220144913_create_revisions.rb
create_table :revisions do |t|
  t.uuid :identifier
end

# app/models/revision.rb
class Revision < ApplicationRecord
end

# Использование
Revision.create identifier: "A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11"

revision = Revision.first
revision.identifier # => "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"
```

Вы можете использовать тип `uuid` для определения ссылок в миграции:

```ruby
# db/migrate/20150418012400_create_blog.rb
enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
create_table :posts, id: :uuid, default: 'gen_random_uuid()'

create_table :comments, id: :uuid, default: 'gen_random_uuid()' do |t|
  # t.belongs_to :post, type: :uuid
  t.references :post, type: :uuid
end

# app/models/post.rb
class Post < ApplicationRecord
  has_many :comments
end

# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :post
end
```

Смотрите [этот раздел](#uuid-primary-keys) для получения более подробной информации об использовании UUID в качестве первичного ключа.

### Битовые строки

* [определение типа](https://postgrespro.ru/docs/postgrespro/current/datatype-bit.html)
* [функции и операторы](https://postgrespro.ru/docs/postgrespro/current/functions-bitstring.html)

```ruby
# db/migrate/20131220144913_create_users.rb
create_table :users, force: true do |t|
  t.column :settings, "bit(8)"
end

# app/models/user.rb
class User < ApplicationRecord
end

# Использование
User.create settings: "01010011"
user = User.first
user.settings # => "01010011"
user.settings = "0xAF"
user.settings # => 10101111
user.save!
```

### Типы, описывающие сетевые адреса

* [определение типа](https://postgrespro.ru/docs/postgrespro/current/datatype-net-types.html)

Типы `inet` и `cidr` преобразуются в Ruby [`IPAddr`](http://www.ruby-doc.org/stdlib-2.2.2/libdoc/ipaddr/rdoc/IPAddr.html) объекты.
Тип `macaddr` преобразуется в обычный текст.

```ruby
# db/migrate/20140508144913_create_devices.rb
create_table(:devices, force: true) do |t|
  t.inet 'ip'
  t.cidr 'network'
  t.macaddr 'address'
end

# app/models/device.rb
class Device < ApplicationRecord
end

# Использование
macbook = Device.create(ip: "192.168.1.12",
                        network: "192.168.2.0/24",
                        address: "32:01:16:6d:05:ef")

macbook.ip
# => #<IPAddr: IPv4:192.168.1.12/255.255.255.255>

macbook.network
# => #<IPAddr: IPv4:192.168.2.0/255.255.255.0>

macbook.address
# => "32:01:16:6d:05:ef"
```

### Геометрические типы

* [определение типа](https://postgrespro.ru/docs/postgrespro/current/datatype-geometric.html)

Все геометрические типы, за исключением `points` преобразуются в обычный текст.
А тип `point` соответствует массиву, содержащему координаты `x` и `y`.

(uuid-primary-keys) Первичные ключи UUID
----------------------------------------

NOTE: Для генерации случайных UUIDs необходимо включить расширение `pgcrypto` (только PostgreSQL >= 9.4) или `uuid-ossp`.

```ruby
# db/migrate/20131220144913_create_devices.rb
enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
create_table :devices, id: :uuid, default: 'gen_random_uuid()' do |t|
  t.string :kind
end

# app/models/device.rb
class Device < ApplicationRecord
end

# Использование
device = Device.create
device.id # => "814865cd-5a1d-4771-9306-4268f188fe9e"
```

NOTE: Предполагается, что используется `gen_random_uuid()` (из `uuid-pgcrypto`) при отсутствии опции `:default`, переданной в `create_table`.

Полнотекстовый поиск
--------------------

```ruby
# db/migrate/20131220144913_create_documents.rb
create_table :documents do |t|
  t.string 'title'
  t.string 'body'
end

add_index :documents, "to_tsvector('english', title || ' ' || body)", using: :gin, name: 'documents_idx'

# app/models/document.rb
class Document < ApplicationRecord
end

# Использование
Document.create(title: "Cats and Dogs", body: "are nice!")

## Все документы совпадающие с 'cat & dog'
Document.where("to_tsvector('english', title || ' ' || body) @@ to_tsquery(?)",
                 "cat & dog")
```

Представление базы данных
-------------------------

* [view creation](https://postgrespro.ru/docs/postgrespro/current/sql-createview.html)

Представим, что нам нужно работать со старой базой данных, содержащей следующую таблицу:

```
rails_pg_guide=# \d "TBL_ART"
                                        Table "public.TBL_ART"
   Column   |            Type             |                         Modifiers
------------+-----------------------------+------------------------------------------------------------
 INT_ID     | integer                     | not null default nextval('"TBL_ART_INT_ID_seq"'::regclass)
 STR_TITLE  | character varying           |
 STR_STAT   | character varying           | default 'draft'::character varying
 DT_PUBL_AT | timestamp without time zone |
 BL_ARCH    | boolean                     | default false
Indexes:
    "TBL_ART_pkey" PRIMARY KEY, btree ("INT_ID")
```

Данная таблица не соответствует общепринятым Rails соглашениям.
Т.к. простые представление PostgreSQL обновляются по умолчанию, то можно обернуть их следующим образом:

```ruby
# db/migrate/20131220144913_create_articles_view.rb
execute <<-SQL
CREATE VIEW articles AS
  SELECT "INT_ID" AS id,
         "STR_TITLE" AS title,
         "STR_STAT" AS status,
         "DT_PUBL_AT" AS published_at,
         "BL_ARCH" AS archived
  FROM "TBL_ART"
  WHERE "BL_ARCH" = 'f'
  SQL

# app/models/article.rb
class Article < ApplicationRecord
  self.primary_key = "id"
  def archive!
    update_attribute :archived, true
  end
end

# Использование
first = Article.create! title: "Winter is coming",
                        status: "published",
                        published_at: 1.year.ago
second = Article.create! title: "Brace yourself",
                         status: "draft",
                         published_at: 1.month.ago

Article.count # => 2
first.archive!
Article.count # => 1
```

NOTE: Это приложение обслуживает только не архивированные `Articles`. Представление также допускает условия, при которых можно напрямую исключать архивные `Articles`.
