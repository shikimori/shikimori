# голосование за обзор
$(".review-block .vote").live "ajax:before", ->
  false if $(@).hasClass("selected")

$(".review-block .vote").live "ajax:success", ->
  $(@).addClass("selected").siblings().removeClass "selected"
