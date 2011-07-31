$(function() {
  SyntaxHighlighter.autoloader(
    'text plain             /javascripts/shBrushPlain.js',
    'ruby rails ror rb      /javascripts/shBrushRuby.js',
    'sql                    /javascripts/shBrushSql.js',
    'xml xhtml xslt html    /javascripts/shBrushXml.js'
  );
  SyntaxHighlighter.all();
  
  var text = "Поиск..";
  $("#search").focus(function() {
    $(this).addClass("active");
    if($(this).attr("value") == text) $(this).attr("value", "");
  });
  $("#search").blur(function() {
    $(this).removeClass("active");
    if($(this).attr("value") == "") $(this).attr("value", text);
  });
  $("#search").blur();

  $('#category_filter_form #section_id').change(function(){
    $('#category_filter_form').submit()
  });
});
