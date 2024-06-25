$(function() {
  $("a[rel=popover]").popover();
  $(".tooltip").tooltip();
  $("a[rel=tooltip]").tooltip();
  $(".alert").alert();

  $('.index-popover').popover({
    html: true,
    placement: 'bottom',
    content: $('.index-popover-content').html(),
    template: '<div class="popover index-content" role="tooltip"><div class="popover-arrow"></div><div class="popover-body popover-content"></div></div>'
  });

  $('.index-popover').click(function() { return false; });

  $(".to_top_panel").hide();
  $(function() {
    $(window).scroll(function() {
      if ($(this).scrollTop() > 900) {
        $(".to_top_panel").fadeIn(1000);
      }
    });
    $(".to_top_panel").click(function() {
      $('body').animate({scrollTop:0}, '1000');
    });
  });
});
