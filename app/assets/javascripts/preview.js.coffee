$ ->
  $('#preview_link').click ->
    $.get $(this).attr('href'), {text: $('#say_text').val()}, (data) ->
      $('#preview').html data
    false
