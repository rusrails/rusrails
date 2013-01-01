# Запуск EXPLAIN

Можно запустить EXPLAIN на запросах, вызываемых в relations. Например,

```ruby
User.where(id: 1).joins(:posts).explain
```

может выдать в MySQL.

```
EXPLAIN for: SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`id` = 1
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------------+
| id | select_type | table | type  | possible_keys | key     | key_len | ref   | rows | Extra       |
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------------+
|  1 | SIMPLE      | users | const | PRIMARY       | PRIMARY | 4       | const |    1 |             |
|  1 | SIMPLE      | posts | ALL   | NULL          | NULL    | NULL    | NULL  |    1 | Using where |
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------------+
2 rows in set (0.00 sec)
```

Active Record применяет красивое форматирование, эмулирующее оболочку одной из баз данных. Таким образом, запуск того же запроса в адаптере PostgreSQL выдаст вместо этого

```
EXPLAIN for: SELECT "users".* FROM "users" INNER JOIN "posts" ON "posts"."user_id" = "users"."id" WHERE "users"."id" = 1
                                  QUERY PLAN
------------------------------------------------------------------------------
 Nested Loop Left Join  (cost=0.00..37.24 rows=8 width=0)
   Join Filter: (posts.user_id = users.id)
   ->  Index Scan using users_pkey on users  (cost=0.00..8.27 rows=1 width=4)
         Index Cond: (id = 1)
   ->  Seq Scan on posts  (cost=0.00..28.88 rows=8 width=4)
         Filter: (posts.user_id = 1)
(6 rows)
```

Нетерпеливая загрузка может вызвать более одного запроса за раз, и некоторые запросы могут нуждаться в результате предыдущих. Поэтому `explain` фактически запускает запрос, а затем узнает о дальнейших планах по запросам. Например,

```ruby
User.where(id: 1).includes(:posts).explain
```

выдаст в MySQL.

```
EXPLAIN for: SELECT `users`.* FROM `users`  WHERE `users`.`id` = 1
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------+
| id | select_type | table | type  | possible_keys | key     | key_len | ref   | rows | Extra |
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------+
|  1 | SIMPLE      | users | const | PRIMARY       | PRIMARY | 4       | const |    1 |       |
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------+
1 row in set (0.00 sec)

EXPLAIN for: SELECT `posts`.* FROM `posts`  WHERE `posts`.`user_id` IN (1)
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows | Extra       |
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
|  1 | SIMPLE      | posts | ALL  | NULL          | NULL | NULL    | NULL |    1 | Using where |
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
1 row in set (0.00 sec)
```

### Автоматический EXPLAIN

Active Record способен запускать EXPLAIN автоматически для медленных запросов и логировать его результат. Эта возможность управляется конфигурационным параметром

```ruby
config.active_record.auto_explain_threshold_in_seconds
```

Если установить число, то у любого запроса, превышающего заданное количество секунд, будет автоматически включен и залогирован EXPLAIN. В случае с relations, порог сравнивается с общим временем, необходимым для извлечения записей. Таким образом, relation рассматривается как рабочая единица, вне зависимости от того, что применение нетерпеливой загрузки может вызвать несколько запросов за раз.

Порог `nil` отключает автоматические EXPLAIN-ы.

Порог по умолчанию в режиме development 0.5 секунды, и `nil` в режимах test и production.

INFO. Автоматический EXPLAIN становится отключенным, если у Active Record нет логгера, независимо от значения порога.

#### Отключение автоматического EXPLAIN

Автоматический EXPLAIN может быть выборочно приглушен с помощью `ActiveRecord::Base.silence_auto_explain`:

```ruby
ActiveRecord::Base.silence_auto_explain do
  # здесь не будет включаться автоматический EXPLAIN
end
```

Это полезно для запросов, о которых вы знаете, что они медленные, но правильные, наподобие тяжеловесных отчетов в административном интерфейсе.

Как следует из имени, `silence_auto_explain` only приглушает только автоматические EXPLAIN-ы. Явный вызов `ActiveRecord::Relation#explain` запустится.

### Интерпретация EXPLAIN

Интерпретация результатов EXPLAIN находится за рамками этого руководства. Может быть полезной следующая информация:

* SQLite3: [EXPLAIN QUERY PLAN](http://www.sqlite.org/eqp.html)

* MySQL: [EXPLAIN Output Format](http://dev.mysql.com/doc/refman/5.6/en/explain-output.html)

* PostgreSQL: [Using EXPLAIN](http://www.postgresql.org/docs/current/static/using-explain.html)
