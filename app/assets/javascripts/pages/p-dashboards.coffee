getjs = require('get-js')

page_load 'dashboards_show', ->
  $('.user_list .switch').on 'click', ->
    $(@)
      .closest('.list-type')
      .toggleClass('hidden')
        .siblings('.list-type')
        .toggleClass('hidden')

  $('.c-content .options .option').on 'click', ->
    $(@)
      .addClass('selected')
        .siblings()
        .removeClass('selected')

    $('.c-content .slides .slide')
      .eq($(@).index())
      .removeClass('hidden')
        .siblings()
        .addClass('hidden')

  delay(500).then ->
    $('.cc-news').imagesLoaded ->
      $user_news = $('.c-news_topics')
      $generated_news = $('.c-generated_news')

      align_blocks $user_news, $generated_news

  delay(1000).then ->
    if 'VK' of window
      vk_widget()
    else
      getjs('//vk.com/js/api/openapi.js?146').then(vk_widget)

  delay(1500).then ->
    $node = $('.y-sponsored')
    if $node.children().length
      $node.addClass 'block'

align_blocks = ($user_news, $generated_news) ->
  $topics = $generated_news.find('.b-topic')

  height = $user_news.outerHeight()

  if $topics.length && height < $generated_news.outerHeight()
    $topics.last().remove()
    align_blocks $user_news, $generated_news

vk_widget = ->
  $node = $('#vk_groups').addClass('block')

  VK.Widgets.Group(
    'vk_groups',
    {
      mode: 4,
      width: $node.width(),
      height: '500'
    },
    9273458
  )
