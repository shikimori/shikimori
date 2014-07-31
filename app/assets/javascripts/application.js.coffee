#= require pages/p-animes_collection

$ ->
  $(document).trigger 'page:load'

$(document).on 'page:fetch', ->
  $('.ajax').css opacity: 0.3

$(document).on 'page:restore', ->
  $('.ajax').css opacity: 1
