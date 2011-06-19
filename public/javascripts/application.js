$(function() {
  SyntaxHighlighter.autoloader(
    'text plain             /javascripts/shBrushPlain.js',
    'ruby rails ror rb      /javascripts/shBrushRuby.js',
    'sql                    /javascripts/shBrushSql.js',
    'xml xhtml xslt html    /javascripts/shBrushXml.js'
  );
  SyntaxHighlighter.all();
});
