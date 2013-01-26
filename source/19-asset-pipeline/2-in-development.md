# В development

В режиме development ресурсы отдаются как отдельные файлы в порядке, в котором они определены в файле манифеста.

Этот манифест `app/assets/javascripts/application.js`:

```js
//= require core
//= require projects
//= require tickets
</plain>

сгенерирует этот HTML:

```html
<script src="/assets/core.js?body=1"></script>
<script src="/assets/projects.js?body=1"></script>
<script src="/assets/tickets.js?body=1"></script>
```

Параметр `body` требуется Sprockets.

### Отключение отладки

Можно отключить режим отладки, обновив `config/environments/development.rb`, вставив:

```ruby
config.assets.debug = false
```

Когда режим отладки отключен, Sprockets соединяет все файлы и запускает необходимые препроцессоры. С отключенным режимом отладки вышеуказанный манифест создаст:

```html
<script src="/assets/application.js"></script>
```

Ресурсы компилируются и кэшируются при первом запросе после запуска сервера. Sprockets устанавливает HTTP заголовок `must-revalidate` Cache-Control для уменьшения нагрузки на последующие запросы - на них браузер получает отклик 304 (Not Modified).

Если какой-либо из файлов в манифесте изменился между запросами, сервер возвращает новый скомпилированный файл.

Режим отладки также может быть включен в методе хелпера Rails:

```erb
<%= stylesheet_link_tag "application", debug: true %>
<%= javascript_include_tag "application", debug: true %>
```

Опция `:debug` излишняя, если режим отладки включен.

Потенциально можно включить сжатие в режиме development в качестве проверки на нормальность и отключать его по требованию, когда необходимо для отладки.
