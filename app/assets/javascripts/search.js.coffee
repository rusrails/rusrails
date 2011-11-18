$ ->
  text = "Поиск.."
  $("#search").focus ->
    $(this).addClass "active"
    $(this).attr("value", "") if $(this).attr("value") == text

  $("#search").blur ->
    $(this).removeClass("active");
    $(this).attr("value", text) if $(this).attr("value") == ""

  $("#search").blur()
