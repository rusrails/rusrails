Active Record для PostgreSQL
============================

Данное руководство рассказывает о специфике использования PostgreSQL с Active Record.

После прочтения этого руководства, вы узнаете о том:

* Как использовать типы данных PostgreSQL.
* Как использовать первичные UUID ключи.
* Как сделать поиск по всему тексту, используя PostgreSQL.
* Как возвращать ваши модели Active Record, используя представление базы данных.

--------------------------------------------------------------------------------

Для использования адаптера PostgreSQL вам необходимо как минимум использовать установленную версию 8.2.
Предыдущие версии не поддерживаются.


Для начала работы с PostgreSQL взгляните на
[Конфигурирование приложений на Rails](/configuring-rails-applications#konfigurirovanie-bazy-dannyh-postgresql).
Там описано как правильно настроить Active Record для PostgreSQL.

Типы данных (Datatypes)
---------

PostgreSQL предлагает достаточное количество специфичных типов данных. Далее представлен список типов, которые поддерживаются адаптером PostgreSQL.

### Bytea

* [Определение типа](http://www.postgresql.org/docs/current/static/datatype-binary.html)
* [Функции и операторы](http://www.postgresql.org/docs/current/static/functions-binarystring.html)

```ruby
# db/migrate/20140207133952_create_documents.rb
create_table :documents do |t|
  t.binary 'payload'
end

# app/models/document.rb
class Document < ActiveRecord::Base
end

# Использование
data = File.read(Rails.root + "tmp/output.pdf")
Document.create payload: data
```

### Массив (Array)

* [Определение типа](http://www.postgresql.org/docs/current/static/arrays.html)
* [Функции и операторы](http://www.postgresql.org/docs/current/static/functions-array.html)

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
class Book < ActiveRecord::Base
end

# Использование
Book.create title: "Brave New World",
            tags: ["fantasy", "fiction"],
            ratings: [4, 5]

## Книги с одним тегом
Book.where("'fantasy' = ANY (tags)")

## Книги с несколькими тегами
Book.where("tags @> ARRAY[?]::varchar[]", ["fantasy", "fiction"])

## Книги с рейтином больше 3
Book.where("array_length(ratings, 1) >= 3")
```

### Hstore

* [Определение типа](http://www.postgresql.org/docs/current/static/hstore.html)

NOTE: вам необходимо включить расширение `hstore` для использования hstore.

```ruby
# db/migrate/20131009135255_create_profiles.rb
ActiveRecord::Schema.define do
  enable_extension 'hstore' unless extension_enabled?('hstore')
  create_table :profiles do |t|
    t.hstore 'settings'
  end
end

# app/models/profile.rb
class Profile < ActiveRecord::Base
end

# Использование
Profile.create(settings: { "color" => "blue", "resolution" => "800x600" })

profile = Profile.first
profile.settings # => {"color"=>"blue", "resolution"=>"800x600"}

profile.settings = {"color" => "yellow", "resolution" => "1280x1024"}
profile.save!
```

### JSON

* [Определение типа](http://www.postgresql.org/docs/current/static/datatype-json.html)
* [Функции и операторы](http://www.postgresql.org/docs/current/static/functions-json.html)

```ruby
# db/migrate/20131220144913_create_events.rb
create_table :events do |t|
  t.json 'payload'
end

# app/models/event.rb
class Event < ActiveRecord::Base
end

# Использование
Event.create(payload: { kind: "user_renamed", change: ["jack", "john"]})

event = Event.first
event.payload # => {"kind"=>"user_renamed", "change"=>["jack", "john"]}

## Запрос, основанный на JSON документе
# Оператор -> возвращает исходный JSON тип (который может быть объектом), где ->> возвращает текст
Event.where("payload->>'kind' = ?", "user_renamed")
```

### Диапазон (Range Types)

* [Определение типа](http://www.postgresql.org/docs/current/static/rangetypes.html)
* [Функции и операторы](http://www.postgresql.org/docs/current/static/functions-range.html)

Данный тип преобразуется в Ruby [`Range`](http://www.ruby-doc.org/core-2.2.2/Range.html) объекты.

```ruby
# db/migrate/20130923065404_create_events.rb
create_table :events do |t|
  t.daterange 'duration'
end

# app/models/event.rb
class Event < ActiveRecord::Base
end

# Использование
Event.create(duration: Date.new(2014, 2, 11)..Date.new(2014, 2, 12))

event = Event.first
event.duration # => Tue, 11 Feb 2014...Thu, 13 Feb 2014

## Все события в данную дату
Event.where("duration @> ?::date", Date.new(2014, 2, 12))

## Работает с цепочкой связей
event = Event.
  select("lower(duration) AS starts_at").
  select("upper(duration) AS ends_at").first

event.starts_at # => Tue, 11 Feb 2014
event.ends_at # => Thu, 13 Feb 2014
```

### Составной тип (Composite Types)

* [Определение типа](http://www.postgresql.org/docs/current/static/rowtypes.html)

На данный момент нет специальной поддержки для составных типов. Они преобразуются к нормальным текстовым столбцам:

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
class Contact < ActiveRecord::Base
end

# Использование
Contact.create address: "(Paris,Champs-Élysées)"
contact = Contact.first
contact.address # => "(Paris,Champs-Élysées)"
contact.address = "(Paris,Rue Basse)"
contact.save!
```

### Перечисляемые типы (Enumerated Types)

* [Определение типа](http://www.postgresql.org/docs/current/static/datatype-enum.html)

На данный момент нет специальной поддержки для перечисляемых типов. Они преобразуются к нормальным текстовым столбцам:

```ruby
# db/migrate/20131220144913_create_articles.rb
execute <<-SQL
  CREATE TYPE article_status AS ENUM ('draft', 'published');
SQL
create_table :articles do |t|
  t.column :status, :article_status
end

# app/models/article.rb
class Article < ActiveRecord::Base
end

# Использование
Article.create status: "draft"
article = Article.first
article.status # => "draft"

article.status = "published"
article.save!
```

### UUID

* [Определение типа](http://www.postgresql.org/docs/current/static/datatype-uuid.html)
* [pgcrypto generator function](http://www.postgresql.org/docs/current/static/pgcrypto.html#AEN159361)
* [uuid-ossp generator functions](http://www.postgresql.org/docs/current/static/uuid-ossp.html)

NOTE: Вам необходимо включить `pgcrypto` (только PostgreSQL >= 9.4) расширение для использования uuid.

```ruby
# db/migrate/20131220144913_create_revisions.rb
create_table :revisions do |t|
  t.uuid :identifier
end

# app/models/revision.rb
class Revision < ActiveRecord::Base
end

# Использование
Revision.create identifier: "A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11"

revision = Revision.first
revision.identifier # => "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"
```

Вы можете использовать `uuid` тип для определения ссылок в миграции:

```ruby
# db/migrate/20150418012400_create_blog.rb
enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
create_table :posts, id: :uuid, default: 'gen_random_uuid()'

create_table :comments, id: :uuid, default: 'gen_random_uuid()' do |t|
  # t.belongs_to :post, type: :uuid
  t.references :post, type: :uuid
end

# app/models/post.rb
class Post < ActiveRecord::Base
  has_many :comments
end

# app/models/comment.rb
class Comment < ActiveRecord::Base
  belongs_to :post
end
```

Смотрите [эту секцию](#uuid-primary-keys) с более подробными деталями, как использовать UUIDs как первичного ключа.

### Битовая строка (Bit String Types)

* [Определение типа](http://www.postgresql.org/docs/current/static/datatype-bit.html)
* [Функции и операторы](http://www.postgresql.org/docs/current/static/functions-bitstring.html)

```ruby
# db/migrate/20131220144913_create_users.rb
create_table :users, force: true do |t|
  t.column :settings, "bit(8)"
end

# app/models/device.rb
class User < ActiveRecord::Base
end

# Использование
User.create settings: "01010011"
user = User.first
user.settings # => "01010011"
user.settings = "0xAF"
user.settings # => 10101111
user.save!
```

### Адреса в сети (Network Address Types)

* [Определение типа](http://www.postgresql.org/docs/current/static/datatype-net-types.html)

Типы `inet` и `cidr` типы преобразуются в Ruby объекты
[`IPAddr`](http://www.ruby-doc.org/stdlib-2.2.2/libdoc/ipaddr/rdoc/IPAddr.html)
Тип `macaddr` преобразуется в нормальный текст.

```ruby
# db/migrate/20140508144913_create_devices.rb
create_table(:devices, force: true) do |t|
  t.inet 'ip'
  t.cidr 'network'
  t.macaddr 'address'
end

# app/models/device.rb
class Device < ActiveRecord::Base
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

### Геометрический тип данных (Geometric Types)

* [Определение типа](http://www.postgresql.org/docs/current/static/datatype-geometric.html)

Все геометрические типы данных, за исключением `points` преобразуются в нормальный текст.
А `point` тип соответствует массиву, содержащему координаты `x` и `y`.

(uuid-primary-keys) UUID первичные ключи
--------------------

NOTE: вам необходимо включить `pgcrypto` (только PostgreSQL >= 9.4) или `uuid-ossp` расширение для генерации случайных UUIDs.

```ruby
# db/migrate/20131220144913_create_devices.rb
enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
create_table :devices, id: :uuid, default: 'gen_random_uuid()' do |t|
  t.string :kind
end

# app/models/device.rb
class Device < ActiveRecord::Base
end

# Использование
device = Device.create
device.id # => "814865cd-5a1d-4771-9306-4268f188fe9e"
```

NOTE: `uuid_generate_v4()` (from `uuid-ossp`) is assumed if no `:default` option was passed to `create_table`.

NOTE: `uuid_generate_v4()` (из `uuid-ossp`) предполагает, что при отсутствии опции `:default` передается в `create_table`.

Поиск по всему тексту
---------------------

```ruby
# db/migrate/20131220144913_create_documents.rb
create_table :documents do |t|
  t.string 'title'
  t.string 'body'
end

execute "CREATE INDEX documents_idx ON documents USING gin(to_tsvector('english', title || ' ' || body));"

# app/models/document.rb
class Document < ActiveRecord::Base
end

# Использование
Document.create(title: "Cats and Dogs", body: "are nice!")

## Все документы совпадающие с 'cat & dog'
Document.where("to_tsvector('english', title || ' ' || body) @@ to_tsquery(?)",
                 "cat & dog")
```

Представление базы данных
------------------

* [view creation](http://www.postgresql.org/docs/current/static/sql-createview.html)

Представим, что вам надо работать со старой базой данных, содержащей следующую таблицу:

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

Данная таблица не следует общепринятым Rails соглашениям.
Т.к. простые представление PostgreSQL обновляются по умолчанию, то мы можем их обернуть, как дальше:

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
class Article < ActiveRecord::Base
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

Article.count # => 1
first.archive!
Article.count # => 2
```

NOTE: Данное приложение описывает `Articles` не в архиве. Представление также работают с состояниями, так что мы можем исключить `Articles`, которые в архиве, напрямую.
