page_load 'animes_show', 'mangas_show', ->
  $('.b-notice').tipsy gravity: 's'
  $('.c-screenshot').magnific_rel_gallery()

  # сокращение высоты описания
  $('.text').check_height max_height: 200

  new FavouriteStar $('.c-actions .fav-add'), is_favoured
  new Animes.WathOnlineButton $('.watch-online-placeholer'), watch_online

  $new_review = $('.new_review')
  if SHIKI_USER.is_signed_in
    new_review_url = $new_review
      .attr('href').replace(/%5Buser_id%5D=(\d+|ID)/, "%5Buser_id%5D=#{SHIKI_USER.id}")
    $new_review.attr href: new_review_url
  else
    $new_review.hide()

  # автоподгрузка блока с расширенной инфой об аниме для гостей
  $('.l-content').on 'postloaded:success', '.resources-loader', ->
    $('.c-screenshot').magnific_rel_gallery()

  # клик по загрузке других названий
  $('.other-names.click-loader').on 'ajax:success', (e, data) ->
    $(@).closest('.line').replaceWith data

  # раскрытие свёрнутого блока связанного
  $('.l-content').on 'click', '.related-shower', ->
    $(@).next().children().unwrap()
    $(@).siblings().show()
    $(@).remove()

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
