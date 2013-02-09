$ ->
  $("#search").focus ->
    $(this).addClass "active"

  $("#search").blur ->
    $(this).removeClass "active"
