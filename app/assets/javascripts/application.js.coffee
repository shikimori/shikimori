#= require pages/p-animes_collection
#= require pages/p-recommendations

$ ->
  $(document).trigger 'page:load'

  $.form_navigate
    size: 250
    message: "Вы написали и не сохранили какой-то комментарий! Уверены, что хотите покинуть страницу?"

$(document).on 'page:load', ->
  #$('.notifications.unread_count').tipsy
    #live: true
    #opacity: 1

  # отображение flash сообщений от рельс
  $('p.flash-notice').each (k, v) ->
    $.flash notice: v.innerHTML if v.innerHTML.length

  $('p.flash-alert').each (k, v) ->
    $.flash alert: v.innerHTML if v.innerHTML.length

  # сворачиваение всех нужных блоков "свернуть"
  collapse_collapses $(document)
  process_current_dom()

  if IS_LOGGED_IN && !window.faye_loader
    window.faye_loader = new FayeLoader()
    faye_loader.apply()

$(document).on 'page:fetch', ->
  $('.ajax').css opacity: 0.3

$(document).on 'page:restore', ->
  $('.ajax').css opacity: 1
