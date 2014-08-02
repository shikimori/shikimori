#= require pages/p-animes_collection-index
#= require pages/p-recommendations-index
#= require pages/p-users-index

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

# обработка элементов страницы (инициализация галерей, шрифтов, ссылок)
@process_current_dom = ->
  # нормализуем ширину всех огромных картинок
  $('img.check-width').normalizeImage
    class: "check-width"
    fancybox: $.galleryOptions

  # стена картинок
  $('.wall').shikiWall()

  # редакторы
  $('.shiki-editor').shikiEditor()

  # то, что должно превратиться в ссылки
  $('.linkeable').wrap ->
    $this = $(@)
    $this.removeClass('linkeable').addClass 'linkeable-processed'
    "<a href='#{$this.data 'href'}' title='#{$this.data("title") || $this.html()}' />"

  # блоки, загружаемые аяксом
  $('.postloaded[data-href]').each ->
    $this = $(@)
    return unless $this.is(':visible')
    $this.load $this.data('href'), ->
      $this.trigger 'ajax:success'

    $this.attr 'data-href', null

  # инициализация подгружаемых тултипов
  $('.anime-tooltip').tooltip(ANIME_TOOLTIP_OPTIONS).removeClass 'anime-tooltip'
  $('.bubbled').addClass('bubbled-initialized').removeClass('bubbled').tooltip $.extend(
    offset: [
      -35
      10
    ]
  , tooltip_options)
