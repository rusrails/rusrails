$ ->
  SyntaxHighlighter.autoloader(
    'text plain             /assets/sh/shBrushPlain.js',
    'ruby rails ror rb      /assets/sh/shBrushRuby.js',
    'sql                    /assets/sh/shBrushSql.js',
    'xml xhtml xslt html    /assets/sh/shBrushXml.js'
  )
  SyntaxHighlighter.all()
