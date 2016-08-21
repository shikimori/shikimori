@on 'page:load', 'dashboards_show', ->
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

  (->
    $('.cc-news').imagesLoaded ->
      $user_news = $('.c-news_topics')
      $generated_news = $('.c-generated_news')

      align_blocks $user_news, $generated_news
  ).delay 500

align_blocks = ($user_news, $generated_news) ->
  $topics = $generated_news.find('.b-topic')

  height = $user_news.outerHeight()

  if $topics.length && height < $generated_news.outerHeight()
    $topics.last().remove()
    align_blocks $user_news, $generated_news
