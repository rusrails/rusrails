Заметки о релизе Ruby on Rails 5.1
==================================

Ключевые новинки в Rails 5.1:

* Поддержка Yarn
* Опциональная поддержка Webpack
* jQuery больше не является зависимостью по умолчанию
* Системные тесты
* Шифруемые секреты
* Параметризованные рассыльщики
* Направленные и вычисляемые маршруты
* Объединение form_for и form_tag в form_with

Эти заметки о релизе покрывают только основные изменения. Чтобы узнать о других обновлениях, различных исправлениях программных ошибок и изменениях, обратитесь к логам изменений или к [списку коммитов](https://github.com/rails/rails/commits/5-1-stable) в главном репозитории Rails на GitHub.

--------------------------------------------------------------------------------

Апгрейд до Rails 5.1
--------------------

Прежде чем апгрейдить существующее приложение, было бы хорошо иметь перед этим покрытие тестами. Также, до попытки обновиться до Rails 5.1, необходимо сначала произвести апгрейд до Rails 5.0 и убедиться, что приложение все еще выполняется так, как нужно. Список вещей, которые нужно выполнить для апгрейда доступен в руководстве [Апгрейд Ruby on Rails](/upgrading-ruby-on-rails#upgrading-from-rails-5-0-to-rails-5-1).

Основные особенности
--------------------

### Поддержка Yarn

[Pull Request](https://github.com/rails/rails/pull/26836)

Rails 5.1 позволяет управлять зависимостями JavaScript из NPM с помощью Yarn. Это облегчает использование библиотек, таких как React, VueJS и любых других из мира NPM. Поддержка Yarn интегрирована с файлопроводом, поэтому все зависимости будут без проблем работать с приложением Rails 5.1.

### Опциональная поддержка Webpack

[Pull Request](https://github.com/rails/rails/pull/27288)

Приложения Rails можно интегрировать с [Webpack](https://webpack.js.org/), пакетированием ассетов JavaScript, используя новый стандартный гем [Webpacker](https://github.com/rails/webpacker). Укажите флажок `--webpack` при генерации новых приложений, чтобы включить интеграцию с Webpack.

Она полностью совместима с файлопроводом, который можно продолжать использовать для картинок, шрифтов, звуков и других ассетов. Можно даже оставить некоторый код JavaScript, управляемый файлопроводом, а остальной код обрабатывать через Webpack. Все это управляется с помощью Yarn, который включен по умолчанию.

### jQuery больше не является зависимостью по умолчанию

[Pull Request](https://github.com/rails/rails/pull/27113)

jQuery требовался по умолчанию в ранних версиях Rails для предоставления особенностей, таких как `data-remote`, `data-confirm` и других частей, предлагаемых Unobtrusive JavaScript в Rails. Он больше не требуется, так как UJS был переписан с использованием чистого JavaScript. Этот код теперь находится внутри Action View как `rails-ujs`.

При необходимости все еще можно использовать jQuery, но он больше не требуется по умолчанию.

### Системные тесты

[Pull Request](https://github.com/rails/rails/pull/26703)

Rails 5.1 имеет встроенную поддержку для написания тестов Capybara в форме системных тестов. Больше не нужно беспокоиться о настройке Capybara и стратегиях очистки базы данных для таких тестов. Rails 5.1 предоставляет обертку для запусков тестов в Chrome с дополнительными особенностями, такими как скриншоты при падении.

### Шифруемые секреты

[Pull Request](https://github.com/rails/rails/pull/28038)

Сейчас Rails позволяет управлять секретами приложения безопасным образом, наподобие гема [sekrets](https://github.com/ahoward/sekrets).

Запустите `bin/rails secrets:setup` для настройки нового зашифрованного файла с секретами. Это также сгенерирует мастер-ключ, который должен храниться вне репозитория. Тогда сами секреты могут безопасно добавляться в систему контроля версий в зашифрованной форме.

Секреты будут дешифрованы в production с помощью ключа, либо хранящегося в переменной окружения `RAILS_MASTER_KEY`, либо в файле с ключом.

### Параметризованные рассыльщики

[Pull Request](https://github.com/rails/rails/pull/27825)

Позволяют определить общие параметры, используемые всеми методами в классе рассыльщика, для переменных экземпляра, заголовков и других общих настроек.

``` ruby
class InvitationsMailer < ApplicationMailer
  before_action { @inviter, @invitee = params[:inviter], params[:invitee] }
  before_action { @account = params[:inviter].account }

  def account_invitation
    mail subject: "#{@inviter.name} invited you to their Basecamp (#{@account.name})"
  end
end

InvitationsMailer.with(inviter: person_a, invitee: person_b)
                 .account_invitation.deliver_later
```

### Направленные и вычисляемые маршруты

[Pull Request](https://github.com/rails/rails/pull/23138)

Rails 5.1 добавляет в DSL роутинга два новых метода, `resolve` и `direct`. Метод `resolve` позволяет настроить полиморфное сопоставление моделей.

``` ruby
resource :basket

resolve("Basket") { [:basket] }
```

``` erb
<%= form_for @basket do |form| %>
  <!-- basket form -->
<% end %>
```

Это сгенерирует одиночный URL `/basket` вместо обычного `/baskets/:id`.

Метод `direct` позволяет создавать хелперы для произвольного URL.

``` ruby
direct(:homepage) { "http://www.rubyonrails.org" }

>> homepage_url
=> "http://www.rubyonrails.org"
```

Возвращаемое из блока значение должно быть валидным аргументом для метода `url_for`. Поэтому можно передать валидные строковый URL, Hash, Array, экземпляр Active Model или класс Active Model.

``` ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```

### Объединение form_for и form_tag в form_with

[Pull Request](https://github.com/rails/rails/pull/26976)

До Rails 5.1 было два интерфейса для обработки форм HTML: `form_for` для экземпляров моделей и `form_tag` для произвольных URL.

Rails 5.1 объединяет оба этих интерфейса с помощью `form_with` и может генерировать теги формы, основанные на URL, скоупах или моделях.

Используя просто URL:

``` erb
<%= form_with url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Сгенерирует %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="title">
</form>
```

Добавление скоупа добавляет префикс для имен полей ввода:

``` erb
<%= form_with scope: :post, url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Сгенерирует %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

URL и скоуп на основе используемой модели:

``` erb
<%= form_with model: Post.new do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Сгенерирует %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

Существующая модель создает форму для обновления и заполняет значения для полей:

``` erb
<%= form_with model: Post.first do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Сгенерирует %>

<form action="/posts/1" method="post" data-remote="true">
  <input type="hidden" name="_method" value="patch">
  <input type="text" name="post[title]" value="<the title of the post>">
</form>
```

Несовместимости
---------------

Следующие изменения могут потребовать немедленных действий после апгрейде.

### Транзакционные тесты с несколькими соединениями

Сейчас транзакционные тесты оборачивают все соединения Active Record в транзакции базы данных.

Когда тест порождает дополнительные треды, и эти треды получают соединения с базой данных, то эти соединения теперь обрабатываются по-особенному:

Тредам достается единственное соединение, которое находится посреди управляемой транзакции. Это позволяет убедиться, что все треды видят базу данных в одном и том же состоянии, игнорируя внешнюю транзакцию. Раньше такие дополнительные соединения были неспособны видеть, к примеру, строки фикстур.

Когда тред входит во вложенную транзакцию, он временно получает эксклюзивное использование этого соединения для поддержки изоляции.

Если ваши тесты сейчас полагаются на получение отдельного, внетранзакционного соединения для порождаемого треда, вам необходимо переключиться на более явное управление соединением.

Если ваши тесты порождают треды, и эти треды взаимодействуют, в то же время используя явные соединения с базой данных, то это может вызвать дедлок (deadlock).

Самым простым способом отказаться от подобного нового поведения является отключение транзакционных тестов для всех тестовых случаев, которые оно затрагивает.

Railties
--------

За подробностями обратитесь к [Changelog][railties].

### Удалено

*   Удалена устаревшая `config.static_cache_control`.
    ([commit](https://github.com/rails/rails/commit/c861decd44198f8d7d774ee6a74194d1ac1a5a13))

*   Удалена устаревшая `config.serve_static_files`.
    ([commit](https://github.com/rails/rails/commit/0129ca2eeb6d5b2ea8c6e6be38eeb770fe45f1fa))

*   Удален устаревший файл `rails/rack/debugger`.
    ([commit](https://github.com/rails/rails/commit/7563bf7b46e6f04e160d664e284a33052f9804b8))

*   Удалены устаревшие задачи: `rails:update`, `rails:template`, `rails:template:copy`, `rails:update:configs` и `rails:update:bin`.
    ([commit](https://github.com/rails/rails/commit/f7782812f7e727178e4a743aa2874c078b722eef))

*   Удалена устаревшая переменная среды `CONTROLLER` для задачи `routes`.
    ([commit](https://github.com/rails/rails/commit/f9ed83321ac1d1902578a0aacdfe55d3db754219))

*   Удалена опция -j (--javascript) для команды `rails new`.
    ([Pull Request](https://github.com/rails/rails/pull/28546))

### Значимые изменения

*   Добавлена общий раздел в `config/secrets.yml`, которая будет загружена для всех сред.
    ([commit](https://github.com/rails/rails/commit/e530534265d2c32b5c5f772e81cb9002dcf5e9cf))

*   Конфигурационный файл `config/secrets.yml` теперь загружается со всеми ключами в качестве символов.
    ([Pull Request](https://github.com/rails/rails/pull/26929))

*   Убран jquery-rails из стека по умолчанию. rails-ujs, который теперь встроен в Action View, включен в качестве адаптера UJS по умолчанию.
    ([Pull Request](https://github.com/rails/rails/pull/27113))

*   Добавлена поддержка Yarn для новых приложений с помощью бинстаба yarn и package.json.
    ([Pull Request](https://github.com/rails/rails/pull/26836))

*   В новых приложениях добавлена поддержка Webpack с помощью опции `--webpack`, которая делегируется в гем rails/webpacker.
    ([Pull Request](https://github.com/rails/rails/pull/27288))

*   При генерации нового приложения инициализируется репозиторий Git, если не предоставлена опция `--skip-git`.
    ([Pull Request](https://github.com/rails/rails/pull/27632))

*   Добавлены зашифрованные секреты в `config/secrets.yml.enc`.
    ([Pull Request](https://github.com/rails/rails/pull/28038))

*   Отображается имя класса railtie в `rails initializers`.
    ([Pull Request](https://github.com/rails/rails/pull/25257))

Action Cable
-----------

За подробностями обратитесь к [Changelog][action-cable].

### Значимые изменения

*   Добавлена поддержка `channel_prefix` к Redis и событийным адаптерам Redis в `cable.yml`, чтобы избежать коллизии имен при использовании одного и того же сервера Redis с несколькими приложениями.
    ([Pull Request](https://github.com/rails/rails/pull/27425))

*   Для данных трансляции добавлен хук `ActiveSupport::Notifications`.
    ([Pull Request](https://github.com/rails/rails/pull/24988))

Action Pack
-----------

За подробностями обратитесь к [Changelog][action-pack].

### Удалено

*   Удалена поддержка аргументов, не являющихся ключами, в `#process`, `#get`, `#post`, `#patch`, `#put`, `#delete` и `#head` для классов `ActionDispatch::IntegrationTest` и `ActionController::TestCase`.
    ([Commit](https://github.com/rails/rails/commit/98b8309569a326910a723f521911e54994b112fb),
    [Commit](https://github.com/rails/rails/commit/de9542acd56f60d281465a59eac11e15ca8b3323))

*   Удалены устаревшие `ActionDispatch::Callbacks.to_prepare` и `ActionDispatch::Callbacks.to_cleanup`.
    ([Commit](https://github.com/rails/rails/commit/3f2b7d60a52ffb2ad2d4fcf889c06b631db1946b))

*   Удалены устаревшие методы, относящиеся к фильтрам контроллера.
    ([Commit](https://github.com/rails/rails/commit/d7be30e8babf5e37a891522869e7b0191b79b757))

*   Удалена устаревшая поддержка `:text` и `:nothing` в `render`.
    ([Commit](https://github.com/rails/rails/commit/79a5ea9eadb4d43b62afacedc0706cbe88c54496), 
    [Commit](https://github.com/rails/rails/commit/57e1c99a280bdc1b324936a690350320a1cd8111))

*   Удалена устаревшая поддержка для вызова метода `HashWithIndifferentAccess` на `ActionController::Parameters`.
    ([Commit](https://github.com/rails/rails/pull/26746/commits/7093ceb480ad6a0a91b511832dad4c6a86981b93))

### Устарело

*   Устарел `config.action_controller.raise_on_unfiltered_parameters`. Он ничего не делает в Rails 5.1.
    ([Commit](https://github.com/rails/rails/commit/c6640fb62b10db26004a998d2ece98baede509e5))

### Значимые изменения

*   Добавлены методы `direct` и `resolve` в DSL роутинга.
    ([Pull Request](https://github.com/rails/rails/pull/23138))

*   Добавлен новый класс `ActionDispatch::SystemTestCase` для написания системных тестов вашего приложения.
    ([Pull Request](https://github.com/rails/rails/pull/26703))

Action View
-------------

За подробностями обратитесь к [Changelog][action-view].

### Удалено

*   Удален устаревший `#original_exception` в `ActionView::Template::Error`.
    ([commit](https://github.com/rails/rails/commit/b9ba263e5aaa151808df058f5babfed016a1879f))

*   Удалена неправильно названная опция `encode_special_chars` из `strip_tags`.
    ([Pull Request](https://github.com/rails/rails/pull/28061))

### Устарело

*   Устаревший обработчик ERB Erubis заменен в пользу Erubi.
    ([Pull Request](https://github.com/rails/rails/pull/27757))

### Значимые изменения

*   Обработчик raw шаблонов (обработчик шаблонов по умолчанию в Rails 5) теперь выводит HTML-безопасные строки.
    ([commit](https://github.com/rails/rails/commit/1de0df86695f8fa2eeae6b8b46f9b53decfa6ec8))

*   Изменены `datetime_field` и `datetime_field_tag`, чтобы они генерировали поле `datetime-local`.
    ([Pull Request](https://github.com/rails/rails/pull/28061))

*   Новый синтаксис в стиле Builder для тегов HTML (`tag.div`, `tag.br` и т.д.)
    ([Pull Request](https://github.com/rails/rails/pull/25543))

*   Добавлен `form_with`, объединяющий использование `form_tag` и `form_for`.
    ([Pull Request](https://github.com/rails/rails/pull/26976))

*   Добавлена опция `check_parameters` в `current_page?`.
    ([Pull Request](https://github.com/rails/rails/pull/27549))

Action Mailer
-------------

За подробностями обратитесь к [Changelog][action-mailer].

### Значимые изменения

*   Разрешена установка произвольного типа содержимого, когда включены прикрепленные файлы и тело установлено как встроенное.
    ([Pull Request](https://github.com/rails/rails/pull/27227))

*   Разрешена передача lambda в качестве значений в метод `default`.
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   Добавлена поддержка параметризованного вызова рассыльщиков для совместного использования предварительных (before) фильтров и значений по умолчанию различными экшнами рассыльщика.
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   Входящие аргументы передаются в экшн рассыльщика в событии `process.action_mailer` в ключе `args`.
    ([Pull Request](https://github.com/rails/rails/pull/27900))

Active Record
-------------

За подробностями обратитесь к [Changelog][active-record].

### Удалено

*   Удалена поддержка одновременной передачи аргументов и блока в `ActiveRecord::QueryMethods#select`.
    ([Commit](https://github.com/rails/rails/commit/4fc3366d9d99a0eb19e45ad2bf38534efbf8c8ce))

*   Удалены устаревшие скоупы i18n `activerecord.errors.messages.restrict_dependent_destroy.one` и `activerecord.errors.messages.restrict_dependent_destroy.many`.
    ([Commit](https://github.com/rails/rails/commit/00e3973a311))

*   Удален устаревший аргумент принудительной перезагрузки для методов чтения одиночной и множественной связи.
    ([Commit](https://github.com/rails/rails/commit/09cac8c67af))

*   Удалена устаревшая поддержка передачи столбца в `#quote`.
    ([Commit](https://github.com/rails/rails/commit/e646bad5b7c))

*   Удалены устаревшие аргументы `name` из `#tables`.
    ([Commit](https://github.com/rails/rails/commit/d5be101dd02214468a27b6839ffe338cfe8ef5f3))

*   Удалено устаревшее поведение `#tables`, и `#table_exists?`, которое возвращало таблицы и представления, чтобы теперь возвращало только таблицы, но не представления.
    ([Commit](https://github.com/rails/rails/commit/5973a984c369a63720c2ac18b71012b8347479a8))

*   Удален устаревший аргумент `original_exception` в `ActiveRecord::StatementInvalid#initialize` и `ActiveRecord::StatementInvalid#original_exception`.
    ([Commit](https://github.com/rails/rails/commit/bc6c5df4699d3f6b4a61dd12328f9e0f1bd6cf46))

*   Удалена устаревшая поддержка передачи класса в качестве значения в запрос.
    ([Commit](https://github.com/rails/rails/commit/b4664864c972463c7437ad983832d2582186e886))

*   Удалена устаревшая поддержка запросов с использованием запятых в LIMIT.
    ([Commit](https://github.com/rails/rails/commit/fc3e67964753fb5166ccbd2030d7382e1976f393))

*   Удален устаревший параметр `conditions` из `#destroy_all`.
    ([Commit](https://github.com/rails/rails/commit/d31a6d1384cd740c8518d0bf695b550d2a3a4e9b))

*   Удален устаревший параметр `conditions` из `#delete_all`.
    ([Commit](https://github.com/rails/rails/pull/27503/commits/e7381d289e4f8751dcec9553dcb4d32153bd922b))

*   Удален устаревший метод `#load_schema_for` в пользу `#load_schema`.
    ([Commit](https://github.com/rails/rails/commit/419e06b56c3b0229f0c72d3e4cdf59d34d8e5545))

*   Удалена устаревшая конфигурация `#raise_in_transactional_callbacks`.
    ([Commit](https://github.com/rails/rails/commit/8029f779b8a1dd9848fee0b7967c2e0849bf6e07))

*   Удалена устаревшая конфигурация `#use_transactional_fixtures`.
    ([Commit](https://github.com/rails/rails/commit/3955218dc163f61c932ee80af525e7cd440514b3))

### Устарело

*   Устаревший флажок `error_on_ignored_order_or_limit` заменен в пользу `error_on_ignored_order`.
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   Устаревший `sanitize_conditions` заменен в пользу `sanitize_sql`.
    ([Pull Request](https://github.com/rails/rails/pull/25999))

*   Устарел `supports_migrations?` в адаптерах соединения.
    ([Pull Request](https://github.com/rails/rails/pull/28172))

*   Устарел `Migrator.schema_migrations_table_name`, вместо него используйте `SchemaMigration.table_name`.
    ([Pull Request](https://github.com/rails/rails/pull/28351))

*   Устарело использование `#quoted_id` в квотировании и приведении типов.
    ([Pull Request](https://github.com/rails/rails/pull/27962))

*   Устарела передача аргумента `default` в `#index_name_exists?`.
    ([Pull Request](https://github.com/rails/rails/pull/26930))

### Значимые изменения

*   Изменены первичные ключи по умолчанию на BIGINT.
    ([Pull Request](https://github.com/rails/rails/pull/26266))

*   Поддержка виртуальных/генерированных столбцов для MySQL 5.7.5+ и MariaDB 5.2.0+.
    ([Commit](https://github.com/rails/rails/commit/65bf1c60053e727835e06392d27a2fb49665484c))

*   Добавлена поддержка лимитов в обработке пакетами.
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   Транзакционные тесты теперь оборачивают все соединения Active Record в транзакцию базы данных.
    ([Pull Request](https://github.com/rails/rails/pull/28726))

*   По умолчанию опускаются комментарии в выводе команды `mysqldump`.
    ([Pull Request](https://github.com/rails/rails/pull/23301))

*   Починен `ActiveRecord::Relation#count`, чтобы использовался `Enumerable#count` из Ruby для подсчета записей, когда передан блок, вместо игнорирования переданного блока.
    ([Pull Request](https://github.com/rails/rails/pull/24203))

*   Передача флажка `"-v ON_ERROR_STOP=1"` команде `psql` не подавляет ошибки SQL.
    ([Pull Request](https://github.com/rails/rails/pull/24773))

*   Добавлен `ActiveRecord::Base.connection_pool.stat`.
    ([Pull Request](https://github.com/rails/rails/pull/26988))

*   Наследование непосредственно от `ActiveRecord::Migration` вызывает ошибку. Необходимо указывать версию Rails, для которой была написана миграция.
    ([Commit](https://github.com/rails/rails/commit/249f71a22ab21c03915da5606a063d321f04d4d3))

*   Вызывается ошибка, когда у связи `through` имеется избыточное имя противоположной связи.
    ([Commit](https://github.com/rails/rails/commit/0944182ad7ed70d99b078b22426cbf844edd3f61))

Active Model
------------

За подробностями обратитесь к [Changelog][active-model].

### Удалено

*   Удалены устаревшие методы в `ActiveModel::Errors`.
    ([commit](https://github.com/rails/rails/commit/9de6457ab0767ebab7f2c8bc583420fda072e2bd))

*   Удалена устаревшая опция `:tokenizer` в валидаторе длины.
    ([commit](https://github.com/rails/rails/commit/6a78e0ecd6122a6b1be9a95e6c4e21e10e429513))

*   Удалено устаревшее поведение, прерывающее колбэки, когда возвращаемое значение равно false.
    ([commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### Значимые изменения

*   Оригинальная строка, назначенная атрибуту модели, больше не замораживается неправильно.
    ([Pull Request](https://github.com/rails/rails/pull/28729))

Active Job
-----------

За подробностями обратитесь к [Changelog][active-job].

### Удалено

*   Удалена устаревшая поддержка передачи класса адаптера в `.queue_adapter`.
    ([commit](https://github.com/rails/rails/commit/d1fc0a5eb286600abf8505516897b96c2f1ef3f6))

*   Удален устаревший `#original_exception` в `ActiveJob::DeserializationError`.
    ([commit](https://github.com/rails/rails/commit/d861a1fcf8401a173876489d8cee1ede1cecde3b))

### Значимые изменения

*   Добавлена декларативная обработка исключений с помощью `ActiveJob::Base.retry_on` и `ActiveJob::Base.discard_on`.
    ([Pull Request](https://github.com/rails/rails/pull/25991))

*   После того, как все попытки провалятся, передается экземпляр задания, поэтому у вас будет доступ к таким вещам, как `job.arguments`, для реализации собственной логики.
    ([commit](https://github.com/rails/rails/commit/a1e4c197cb12fef66530a2edfaeda75566088d1f))

Active Support
--------------

За подробностями обратитесь к [Changelog][active-support].

### Удалено

*   Удален класс `ActiveSupport::Concurrency::Latch`.
    ([Commit](https://github.com/rails/rails/commit/0d7bd2031b4054fbdeab0a00dd58b1b08fb7fea6))

*   Удалена `halt_callback_chains_on_return_false`.
    ([Commit](https://github.com/rails/rails/commit/4e63ce53fc25c3bc15c5ebf54bab54fa847ee02a))

*   Удалено устаревшее поведение, прерывающее колбэки, когда возвращаемое значение равно false.
    ([Commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### Устарело

*   Верхнеуровневый класс `HashWithIndifferentAccess` устарел в пользу `ActiveSupport::HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/28157))

*   Устарела передача строк в опции условий `:if` и `:unless` для методов `set_callback` и `skip_callback`.
    ([Commit](https://github.com/rails/rails/commit/0952552))

### Значимые изменения

*   Починен парсинг продолжительности и перемещения во времени, теперь он более последователен при смене DST.
    ([Commit](https://github.com/rails/rails/commit/8931916f4a1c1d8e70c06063ba63928c5c7eab1e),
    [Pull Request](https://github.com/rails/rails/pull/26597))

*   Unicode обновлен до версии 9.0.0.
    ([Pull Request](https://github.com/rails/rails/pull/27822))

*   Добавлены Duration#before и #after в качестве псевдонимов для #ago и #since.
    ([Pull Request](https://github.com/rails/rails/pull/27721))

*   Добавлен `Module#delegate_missing_to` для делегирования вызовов метода, не определенного для текущего объекта, на прокси-объект.
    ([Pull Request](https://github.com/rails/rails/pull/23930))

*   Добавлен `Date#all_day`, возвращающий интервал, представляющий целый день для текущих даты и времени.
    ([Pull Request](https://github.com/rails/rails/pull/24930))

*   Представлены методы `assert_changes` и `assert_no_changes` для тестов.
    ([Pull Request](https://github.com/rails/rails/pull/25393))

*   Методы `travel` и `travel_to` теперь вызывают ошибку на вложенных вызовах.
    ([Pull Request](https://github.com/rails/rails/pull/24890))

*   Обновлен `DateTime#change` для поддержки usec и nsec.
    ([Pull Request](https://github.com/rails/rails/pull/28242))

Благодарности
-------------

Взгляните [на полный список контрибьюторов Rails](http://contributors.rubyonrails.org/), на людей, которые потратили много часов, сделав Rails стабильнее и надёжнее. Спасибо им всем.

[railties]:       https://github.com/rails/rails/blob/5-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-1-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-1-stable/activesupport/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-1-stable/activejob/CHANGELOG.md
