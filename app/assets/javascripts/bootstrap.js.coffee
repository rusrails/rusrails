jQuery ->
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()
  $(".alert").alert()

  $('.index-popover').popover
    html: true
    placement: 'bottom'
    content: $('.index-popover-content').html()
    template: '<div class="popover index-content"><div class="arrow"></div><h3 class="popover-title"></h3><div class="popover-content"></div></div>'
