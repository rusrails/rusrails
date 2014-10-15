jQuery ->
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()
  $(".alert").alert()

  $('.index-popover').popover
    html: true
    placement: 'bottom'
    content: $('.index-popover-content').html()
    template: '<div class="popover index-content"><div class="arrow"></div><div class="popover-content"></div></div>'

  $('.index-popover').click -> false

  $(".to_top_panel").hide()
  $ ->
    $(window).scroll ->
      if $(this).scrollTop() > 900
        $(".to_top_panel").fadeIn(1000)
    $(".to_top_panel").click -> $('body').animate({scrollTop:0}, '1000')
