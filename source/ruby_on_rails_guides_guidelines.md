Рекомендации для руководств по Ruby on Rails
============================================

Это руководство документирует рекомендации по написанию руководств по Ruby on Rails. Это руководство следует самому себе в изящном цикле, являясь примером для самого себя.

После прочтения этого руководства, вы узнаете:

* О соглашениях, используемых в документации Rails.
* Как генерировать руководства локально.

--------------------------------------------------------------------------------

Markdown
--------

Руководства написаны на [GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown). Имеется полная [документация по Markdown](http://daringfireball.net/projects/markdown/syntax), а также [шпаргалка](https://daringfireball.net/projects/markdown/basics).

Пролог
------

Каждое руководство должно начинаться с мотивационного текста сверху (это маленькое введение в голубой области [на официальном сайте](http://guides.rubyonrails.org/index.html)). Пролог должен рассказать читателю, о чем это руководство, и что они изучат. В качестве примера смотрите [Routing Guide](http://guides.rubyonrails.org/routing.html).

Заголовки
---------

Название каждого руководства использует заголовок `h1`; разделы руководства — заголовок `h2`; подразделы используют заголовок `h3`; и так далее. Отметьте, что сгенерированный в HTML результат будет использовать теги заголовков, начиная с `<h2>`.

```markdown
Guide Title
===========

Section
-------

### Sub Section
```

При написании заголовков начинайте с заглавной буквы все слова, кроме предлогов, союзов, внутренних артиклей и форм глагола "to be":

```markdown
#### Assertions and Testing Jobs inside Components
#### Middleware Stack is an Array
#### When are Objects Saved?
```

Используйте форматирования для кода, как в обычном тексте:

```markdown
##### The `:content_type` Option
```

Связывание с API
------------------

Ссылки на API (`api.rubyonrails.org`) обрабатываются генератором руководств следующим образом:

Ссылки, включающие тег релиза, оставляются неизменными. Например

```
https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html
```

не модифицируется.

Пожалуйста, используйте их в заметках о релизе, так как они должны указывать на соответствующую версию, вне зависимости от генерирующейся версии.

Если ссылка не включает тег версии и генерируются руководства edge, домен заменяется на `edgeapi.rubyonrails.org`. Например,

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

становится

```
https://edgeapi.rubyonrails.org/classes/ActionDispatch/Response.html
```

Если ссылка не включает тег релиза, и генерируются руководства релиза, вставляется версия Rails. Например, если генерируются руководства для v5.1.0, ссылка

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

становится

```
https://api.rubyonrails.org/v5.1.0/classes/ActionDispatch/Response.html
```

Пожалуйста, не ссылайтесь на `edgeapi.rubyonrails.org` вручную.

Рекомендации по документированию API
------------------------------------

Эти руководства и API должны быть согласованны и последовательны, насколько возможно. В частности, эти разделы [Рекомендаций по документированию API](/api_documentation_guidelines) также применяются к руководствам:

* [Формулировки](/api_documentation_guidelines#wording)
* [Английский язык](/api_documentation_guidelines#english)
* [Пример кода](/api_documentation_guidelines#example-code)
* [Имена файлов](/api_documentation_guidelines#file-names)
* [Шрифты](/api_documentation_guidelines#fonts)

Руководства в HTML
------------------

До генерации руководств, убедитесь, что используете последнюю версию Bundler в своей системе. Последнюю версию Bundler можно найти [тут](https://rubygems.org/gems/bundler). На момент написания этих строк это v1.17.1.

Чтобы установить последнюю версию Bundler, запустите `gem install bundler`.

### Генерация

Чтобы сгенерировать все руководства, просто сделайте `cd` в директорию `guides`, запустите `bundle install` и выполните:

```bash
$ bundle exec rake guides:generate
```

или

```bash
$ bundle exec rake guides:generate:html
```

Результирующие файлы HTML будут в директории `./output`.

Чтобы обработать `my_guide.md` и ничего, кроме него, используйте переменную среды `ONLY`:

```bash
$ touch my_guide.md
$ bundle exec rake guides:generate ONLY=my_guide
```

По умолчанию неизмененные руководства не обрабатываются, поэтому `ONLY` редко нужна на практике.

Чтобы принудить к обработке всех руководств, передайте `ALL=1`.

Если хотите сгенерировать руководства на языке ином, чем английский, можете держать их в отдельной директории в `source` (то есть `source/es`) и использовать переменную среды `GUIDES_LANGUAGE`:

```bash
$ bundle exec rake guides:generate GUIDES_LANGUAGE=es
```

Если хотите увидеть все переменные окружения, которые могут использоваться генерационным скриптом, просто запустите:

```bash
$ rake
```

### Валидация

Пожалуйста, проверяйте сгенерированный HTML с помощью:

```bash
$ bundle exec rake guides:validate
```

В частности, заголовки имеют ID, сгенерированный на основе их содержания, и это часто ведет к дубликатам.

Руководства для Kindle
----------------------

### Генерация

Чтобы сгенерировать руководства для Kindle, используйте следующую задачу rake:

```bash
$ bundle exec rake guides:generate:kindle
```
