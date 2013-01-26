# Формы к внешним ресурсам

Если необходимо передать через post некоторые данные внешнему ресурсу, было бы здорово создать форму, используя хелперы форм rails. Но иногда этому ресурсу необходимо передать `authenticity_token`. Это можно осуществить, передав параметр `:authenticity_token => 'your_external_token'` в опциях `form_tag`:

```erb
<%= form_tag 'http://farfar.away/form', :authenticity_token => 'external_token') do %>
  Form contents
<% end %>
```

Иногда при отправке данных внешнему ресурсу, такому как платежный шлюз, поля, которые можно использовать в форме, ограничены внешним API. В этом случае вам может захотеться вообще не создавать скрытое поле `authenticity_token`. Для этого нужно всего лишь передать `false` в опцию `:authenticity_token`:

```erb
<%= form_tag 'http://farfar.away/form', :authenticity_token => false) do %>
  Form contents
<% end %>
```

Та же техника доступна и для `form_for`:

```erb
<%= form_for @invoice, :url => external_url, :authenticity_token => 'external_token' do |f|
  Form contents
<% end %>
```

Или, если не хотите создавать поле `authenticity_token`:

```erb
<%= form_for @invoice, :url => external_url, :authenticity_token => false do |f|
  Form contents
<% end %>
```
