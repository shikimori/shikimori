@on 'page:load', 'animes_show', 'mangas_show', ->
  $('.b-notice').tipsy gravity: 's'
  $('.c-screenshot').magnific_rel_gallery()

  # сокращение высоты описания
  $('.text').check_height(200)

  # автоподгрузка блока с расширенной инфой об аниме для гостей
  $('.l-content').on 'postloaded:success', '.resources-loader', ->
    $('.c-screenshot').magnific_rel_gallery()

  # клик по загрузке других названий
  $('.other-names.click-loader').on 'ajax:success', (e, data) ->
    $(@).closest('.line').replaceWith data

  (->
    # клик по смотреть онлайн
    $('.watch-online a').on 'click', ->
      episode = parseInt($('.b-user_rate .current-episodes').html())
      total_episodes = parseInt($('.b-user_rate .total-episodes').html()) || 9999
      watch_episode = if !episode || episode == total_episodes then 1 else episode + 1

      $(@).attr href: $(@).attr('href').replace(/\d+$/, watch_episode)
  ).delay()

  # раскрытие свёрнутого блока связанного
  $('.l-content').on 'click', '.related-shower', ->
    $(@).next().children().unwrap()
    $(@).siblings().show()
    $(@).remove()

  # добавление в избранное
  $('.c-actions .fav-add').on 'ajax:success', ->
    $(@).hide().next().show()
  # удаление из избранного
  $('.c-actions .fav-remove').on 'ajax:success', ->
    $(@).hide().prev().show()
  # комментировать
  $('.c-actions .new_comment').on 'click', ->
    $editor = $('.b-form.new_comment textarea')
    $.scrollTo $editor, ->
      $editor.focus()

  # переключение типа комментариев
  $('.entry-comments .link')
    .on 'ajax:before', (e) ->
      $(@)
        .addClass('selected')
        .data(disabled: true)
      $(@)
        .siblings('span')
        .removeClass('selected')
        .data(disabled: false)
      $(@)
        .parents('.entry-comments')
        .find('.comments-container')
        .animate(opacity: 0.3)
    .on 'ajax:success', (e, data) ->
      $container = $(@)
        .parents('.entry-comments')
        .find('.comments-container')
        .animate(opacity: 1)
      $container
        .children(':not(.shiki-editor)')
        .remove()
      $container.append data.content
