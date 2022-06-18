Active Record для PostgreSQL
============================

Данное руководство рассказывает о специфике использования PostgreSQL с Active Record.

После прочтения этого руководства, вы узнаете о том:

* Как использовать типы данных PostgreSQL.
* Как использовать первичные ключи UUID.
* Как использовать отложенные внешние ключи.
* Как реализовать полнотекстовый поиск с помощью PostgreSQL.
* Как возвращать ваши модели Active Record, используя представление базы данных.

--------------------------------------------------------------------------------

Для использования адаптера PostgreSQL необходимо установить как минимум версию 9.3.
Предыдущие версии не поддерживаются.

Для начала работы с PostgreSQL почитайте руководство [Конфигурирование приложений на Rails](/configuring#konfigurirovanie-bazy-dannyh-postgresql).
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
```

```ruby
# app/models/document.rb
class Document < ApplicationRecord
end
```

```ruby
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
```

```ruby
# app/models/book.rb
class Book < ApplicationRecord
end
```

```ruby
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
class CreateProfiles < ActiveRecord::Migration[7.0]
  enable_extension 'hstore' unless extension_enabled?('hstore')
  create_table :profiles do |t|
    t.hstore 'settings'
  end
end
```

```ruby
# app/models/profile.rb
class Profile < ApplicationRecord
end
```

```irb
irb> Profile.create(settings: { "color" => "blue", "resolution" => "800x600" })

irb> profile = Profile.first
irb> profile.settings
=> {"color"=>"blue", "resolution"=>"800x600"}

irb> profile.settings = {"color" => "yellow", "resolution" => "1280x1024"}
irb> profile.save!

irb> Profile.where("settings->'color' = ?", "yellow")
=> #<ActiveRecord::Relation [#<Profile id: 1, settings: {"color"=>"yellow", "resolution"=>"1280x1024"}>]>
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
```

```ruby
# app/models/event.rb
class Event < ApplicationRecord
end
```

```irb
irb> Event.create(payload: { kind: "user_renamed", change: ["jack", "john"]})

irb> event = Event.first
irb> event.payload
=> {"kind"=>"user_renamed", "change"=>["jack", "john"]}

## Запрос, основанный на JSON документе
# Оператор -> возвращает исходный JSON тип (который может быть объектом), где ->> возвращает текст
irb> Event.where("payload->>'kind' = ?", "user_renamed")
```

### Диапазонные типы

* [определение типа](https://postgrespro.ru/docs/postgrespro/current/rangetypes.html)
* [функции и операторы](https://postgrespro.ru/docs/postgrespro/current/functions-range.html)

Этот тип преобразуется в Ruby [`Range`](https://ruby-doc.org/core-2.7.0/Range.html) объекты.

```ruby
# db/migrate/20130923065404_create_events.rb
create_table :events do |t|
  t.daterange 'duration'
end
```

```ruby
# app/models/event.rb
class Event < ApplicationRecord
end
```

```irb
irb> Event.create(duration: Date.new(2014, 2, 11)..Date.new(2014, 2, 12))

irb> event = Event.first
irb> event.duration
=> Tue, 11 Feb 2014...Thu, 13 Feb 2014

## Все события в заданную дату
irb> Event.where("duration @> ?::date", Date.new(2014, 2, 12))

## Работает с границами диапазона
irb> event = Event.select("lower(duration) AS starts_at").select("upper(duration) AS ends_at").first

irb> event.starts_at
=> Tue, 11 Feb 2014
irb> event.ends_at
=> Thu, 13 Feb 2014
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
```

```ruby
# app/models/contact.rb
class Contact < ApplicationRecord
end
```

```irb
irb> Contact.create address: "(Paris,Champs-Élysées)"
irb> contact = Contact.first
irb> contact.address
=> "(Paris,Champs-Élysées)"
irb> contact.address = "(Paris,Rue Basse)"
irb> contact.save!
```

### Типы перечислений

* [определение типа](https://postgrespro.ru/docs/postgrespro/current/datatype-enum.html)

Тип может быть соотнесен как обычный текстовый столбец, или [`ActiveRecord::Enum`](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html).

На данный момент нет специальной поддержки для типов перечислений. Они преобразуются к обычным текстовым столбцам:

```ruby
# db/migrate/20131220144913_create_articles.rb
def up
  create_enum :article_status, ["draft", "published"]

  create_table :articles do |t|
    t.enum :status, enum_type: :article_status, default: "draft", null: false
  end
end

# Нет встроенной поддержки удаления enum, но это можно сделать вручную.
# Сначала следует удалить любую таблицу, которая зависит от него.
def down
  drop_table :articles

  execute <<-SQL
    DROP TYPE article_status;
  SQL
end
```

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  enum status: {
    draft: "draft", published: "published"
  }, _prefix: true
end
```

```irb
irb> Article.create status: "draft"
irb> article = Article.first
irb> article.status_draft!
irb> article.status
=> "draft"

irb> article.status_published?
=> false
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

NOTE: Значения enum нельзя удалять. Можно прочесть почему [здесь](http://www.postgresql.org/message-id/29F36C7C98AB09499B1A209D48EAA615B7653DBC8A@mail2a.alliedtesting.com).

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
* [функция генератора pgcrypto](https://www.postgresql.org/docs/current/static/pgcrypto.html)
* [функции генератора uuid-ossp](https://postgrespro.ru/docs/postgrespro/current/uuid-ossp.html)

NOTE: Для использования uuid необходимо включить расширение `pgcrypto` (только PostgreSQL >= 9.4).

```ruby
# db/migrate/20131220144913_create_revisions.rb
create_table :revisions do |t|
  t.uuid :identifier
end
```

```ruby
# app/models/revision.rb
class Revision < ApplicationRecord
end
```

```irb
irb> Revision.create identifier: "A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11"

irb> revision = Revision.first
irb> revision.identifier
=> "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"
```

Вы можете использовать тип `uuid` для определения ссылок в миграции:

```ruby
# db/migrate/20150418012400_create_blog.rb
enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
create_table :posts, id: :uuid

create_table :comments, id: :uuid do |t|
  # t.belongs_to :post, type: :uuid
  t.references :post, type: :uuid
end
```

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  has_many :comments
end
```

```ruby
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
```

```ruby
# app/models/user.rb
class User < ApplicationRecord
end
```

```irb
irb> User.create settings: "01010011"
irb> user = User.first
irb> user.settings
=> "01010011"
irb> user.settings = "0xAF"
irb> user.settings
=> "10101111"
irb> user.save!
```

### Типы, описывающие сетевые адреса

* [определение типа](https://postgrespro.ru/docs/postgrespro/current/datatype-net-types.html)

Типы `inet` и `cidr` преобразуются в Ruby [`IPAddr`](https://ruby-doc.org/stdlib-2.7.0/libdoc/ipaddr/rdoc/IPAddr.html) объекты. Тип `macaddr` преобразуется в обычный текст.

```ruby
# db/migrate/20140508144913_create_devices.rb
create_table(:devices, force: true) do |t|
  t.inet 'ip'
  t.cidr 'network'
  t.macaddr 'address'
end
```

```ruby
# app/models/device.rb
class Device < ApplicationRecord
end
```

```irb
irb> macbook = Device.create(ip: "192.168.1.12", network: "192.168.2.0/24", address: "32:01:16:6d:05:ef")

irb> macbook.ip
=> #<IPAddr: IPv4:192.168.1.12/255.255.255.255>

irb> macbook.network
=> #<IPAddr: IPv4:192.168.2.0/255.255.255.0>

irb> macbook.address
=> "32:01:16:6d:05:ef"
```

### Геометрические типы

* [определение типа](https://postgrespro.ru/docs/postgrespro/current/datatype-geometric.html)

Все геометрические типы, за исключением `points` преобразуются в обычный текст.
А тип `point` соответствует массиву, содержащему координаты `x` и `y`.

### Интервал

* [определение типа](https://www.postgresql.org/docs/current/static/datatype-datetime.html#DATATYPE-INTERVAL-INPUT)
* [функции и операторы](https://www.postgresql.org/docs/current/static/functions-datetime.html)

Этот тип преобразуется в объекты [`ActiveSupport::Duration`](https://api.rubyonrails.org/classes/ActiveSupport/Duration.html).

```ruby
# db/migrate/20200120000000_create_events.rb
create_table :events do |t|
  t.interval 'duration'
end
```

```ruby
# app/models/event.rb
class Event < ApplicationRecord
end
```

```irb
irb> Event.create(duration: 2.days)

irb> event = Event.first
irb> event.duration
=> 2 days
```

(uuid-primary-keys) Первичные ключи UUID
----------------------------------------

NOTE: Для генерации случайных UUIDs необходимо включить расширение `pgcrypto` (только PostgreSQL >= 9.4) или `uuid-ossp`.

```ruby
# db/migrate/20131220144913_create_devices.rb
enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
create_table :devices, id: :uuid do |t|
  t.string :kind
end
```

```ruby
# app/models/device.rb
class Device < ApplicationRecord
end
```

```ruby
irb> device = Device.create
irb> device.id
=> "814865cd-5a1d-4771-9306-4268f188fe9e"
```

NOTE: Предполагается, что используется `gen_random_uuid()` (из `uuid-pgcrypto`) при отсутствии опции `:default`, переданной в `create_table`.

Генерируемые столбцы
--------------------

NOTE: Генерируемые столбцы поддерживаются, начиная с 12.0 версии PostgreSQL.

```ruby
# db/migrate/20131220144913_create_users.rb
create_table :users do |t|
  t.string :name
  t.virtual :name_upcased, type: :string, as: 'upper(name)', stored: true
end

# app/models/user.rb
class User < ApplicationRecord
end

# Usage
user = User.create(name: 'John')
User.last.name_upcased # => "JOHN"
```

Отложенные внешние ключи
------------------------

* [ограничения внешнего ключа таблицы](https://www.postgresql.org/docs/current/sql-set-constraints.html)

По умолчанию ограничения таблицы в PostgreSQL проверяются немедленно после каждого выражения. Она намеренно не разрешает создавать записи, когда связанная запись еще не находится в связанной таблице. Впрочем, эту проверку целостности возможно запустить позднее, когда подтверждаются транзакции, добавив `DEFERRABLE` к определению внешнего ключа. Чтобы отложить все проверки по умолчанию, можно установить `DEFERRABLE INITIALLY DEFERRED`. Rails представляет эту особенность PostgreSQL, добавляя ключ `:deferrable` к опциям `foreign_key` в методах `add_reference` и `add_foreign_key`.

Примером этого является создание циклических зависимостей в транзакции, даже если у вас уже есть созданные внешние ключи:

```ruby
add_reference :person, :alias, foreign_key: { deferrable: :deferred }
add_reference :alias, :person, foreign_key: { deferrable: :deferred }
```

Если ссылка была создана с помощью опции `foreign_key: true`, следующая транзакция упала бы при запуске первого выражения `INSERT`. Хотя она не упадет, когда установлена опция `deferrable: :deferred`.

```ruby
ActiveRecord::Base.connection.transaction do
  person = Person.create(id: SecureRandom.uuid, alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

Опции `:deferrable` также можно установить `true` или `:immediate`, которые приводят к одному и тому же результату. Обе опции сохраняют поведение внешних ключей по умолчанию, но позволяют вручную отложить проверки с помощью `SET CONSTRAINTS ALL DEFERRED` внутри транзакции. Это вызовет, что внешние ключи будут проверены при подтверждении транзакции:

```ruby
ActiveRecord::Base.transaction do
  ActiveRecord::Base.connection.execute("SET CONSTRAINTS ALL DEFERRED")
  person = Person.create(alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

По умолчанию `:deferrable` равен `false`, и ограничение всегда проверяется немедленно.

Полнотекстовый поиск
--------------------

```ruby
# db/migrate/20131220144913_create_documents.rb
create_table :documents do |t|
  t.string :title
  t.string :body
end

add_index :documents, "to_tsvector('english', title || ' ' || body)", using: :gin, name: 'documents_idx'
```

```ruby
# app/models/document.rb
class Document < ApplicationRecord
end
```

```ruby
# Использование
Document.create(title: "Cats and Dogs", body: "are nice!")

## Все документы совпадающие с 'cat & dog'
Document.where("to_tsvector('english', title || ' ' || body) @@ to_tsquery(?)",
                 "cat & dog")
```

Опционально можно хранить вектор как автоматически сгенерированный столбец (начиная с PostgreSQL 12.0):

```ruby
# db/migrate/20131220144913_create_documents.rb
create_table :documents do |t|
  t.string :title
  t.string :body

  t.virtual :textsearchable_index_col,
            type: :tsvector, as: "to_tsvector('english', title || ' ' || body)", stored: true
end

add_index :documents, :textsearchable_index_col, using: :gin, name: 'documents_idx'

# Использование
Document.create(title: "Cats and Dogs", body: "are nice!")

## все документы, соответствующие 'cat & dog'
Document.where("textsearchable_index_col @@ to_tsquery(?)", "cat & dog")
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
```

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  self.primary_key = "id"
  def archive!
    update_attribute :archived, true
  end
end
```

```irb
irb> first = Article.create! title: "Winter is coming", status: "published", published_at: 1.year.ago
irb> second = Article.create! title: "Brace yourself", status: "draft", published_at: 1.month.ago

irb> Article.count
=> 2
irb> first.archive!
irb> Article.count
=> 1
```

NOTE: Это приложение обслуживает только не архивированные `Articles`. Представление также допускает условия, при которых можно напрямую исключать архивные `Articles`.

Выгрузки структуры
------------------

Если ваш `config.active_record.schema_format` это `:sql`, Rails вызовет `pg_dump` для генерации выгрузки структуры.

Можно использовать `ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags` для конфигурации `pg_dump`. Например, чтобы исключить комментарии из выгрузки структуры, добавьте следующее в инициализатор:

```ruby
ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = ['--no-comments']
```
