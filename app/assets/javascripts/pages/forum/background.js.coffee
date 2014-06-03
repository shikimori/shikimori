init_gallery = ->
  # gallery
  $('.gallery-body').makeSliderable
    $controls: $('.welcome-gallery .control')
    direction: 'vertical'
    easing: 'easeOutExpo'
    onslide: ($control, $slide) ->
      $control.addClass('selected').siblings().removeClass 'selected'
      $slide.find('.image').show()

  $('.slide:first-child .image').show() if location.hash is ""

  # gallery element hover
  $('.entry').hover (->
    $(@).find('.image .img').stop(true, false).animate
      opacity: 0.5
    , 250
    $(@).children('.title').stop(true, false).animate
      top: (224 - $(@).children('.title').height()) + 'px'
    , 250
  ), ->
    $(@).find('.image .img').stop(true, false).animate
      opacity: 1
    , 250
    $(@).children('.title').stop(true, false).animate
      top: '234px'
    , 250

$ ->
  $gallery_loader = $('.welcome-gallery-loader')

  if $gallery_loader.length
    if is_mobile()
      $gallery_loader.remove()
    else
      $gallery_loader.load $gallery_loader.data('remote'), -> init_gallery()
  else
    init_gallery()

  $new_topic_button = $('.section-new')
  $controls = $('.forum-nav .control')
  $header = $('.forum-nav .title')
  $ajax = $('.ajax')
  $sticked_topics = $('.forum-nav .sticked-topics')
  $local_block = $('.local-menu-block')
  $site_block = $('.site-menu-block')
  $ajax.on 'ajax:success', (e, data) ->
    unless data.section
      $new_topic_button.hide()
      return

    # отображение нужного блока меню - или глобального, или локального
    if data.local_menu_block
      $local_block.html data.local_menu_block
      $local_block.show().trigger 'init'
      $site_block.hide()
    else if data.no_ajax and not $local_block.is(':empty')
      $local_block.show().trigger 'init'
      $site_block.hide()
    else
      $local_block.hide()
      $site_block.show()
      if is_mobile()
        $site_block.parents('.menu-right').remove()
      else
        $site_block.load $site_block.data('remote') if $site_block.children('.ajax-loading').length

    # скрытие кнопки создания нового топика
    if data.section is 'all' or data.section is 'f' or data.section is 'g' or data.section is 'r'
      $new_topic_button.hide()
    else
      $new_topic_button.show()

    # кнопке создания топика прописываем урл текущего раздела
    $new_topic_button.attr href: data.new_topic_url if $new_topic_button.length and data.new_topic_url

    # прописка присланных прикреплённых топиков
    $sticked_topics.html data.sticked_topics

    # проброска события на обработчик текущего раздела
    $ajax.data 'action', data.action
    $ajax.trigger data.action + ':success', [data]

    # прокрутка наверх при необходимости
    $.scrollTo $header unless $header.is(':appeared')

  # треггер хендлера текущего раздела
  $ajax.trigger 'ajax:success', [
    action: $ajax.data('action')
    section: location.pathname.replace(/\/(\w+)(\/.*)?/, '$1').replace('/', 'all')
    no_ajax: true
  ]
  # лого в шапке будет с rel=history
  $('.logo').parent().attr rel: 'history'
  # менюшки новостей и обзоров тоже
  $('.main-menu .rel').attr rel: 'history'

# инициализация локального блока
$('.local-menu-block').live 'init', ->
  $this = $(@).find('.menu-topics-block')

  # подгрузка контента истории
  history_load_triggered = false
  $('.history', $this).hover ->
    return if history_load_triggered
    history_load_triggered = true

    $.getJSON $(@).attr('data-remote'), (data) ->
      for id of data
        $tooltip = $('.tooltip-details', "#history-entry-#{id}-tooltip")
        continue  unless $tooltip.length
        unless data[id].length
          $("#history-entry-#{id}-tooltip").children().remove()
        else
          $tooltip.html _.map(data[id], (v, k) ->
            "<a href='#{v.link}' rel='nofollow'>#{v.title}</a>"
          ).join('<br />')

  # тултипы истории
  $('.person-tooltip', $this).tooltip
    offset: [-48, -28]
    place_to_left: true
    position: 'top right'
    relative: true
