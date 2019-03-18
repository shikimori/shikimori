FavouriteStar = require 'views/application/favourite_star'

pageLoad 'animes_show', 'mangas_show', 'ranobe_show', ->
  $('.b-notice').tipsy gravity: 's'
  $('.c-screenshot').magnificRelGallery()

  # сокращение высоты описания
  $('.text').checkHeight max_height: 200

  new FavouriteStar $('.c-actions .fav-add'), gon.is_favoured
  new Animes.WathOnlineButton $('.watch-online-placeholer'), gon.watch_online

  $new_review = $('.new_review')
  if window.SHIKI_USER.isSignedIn
    new_review_url = $new_review
      .attr('href').replace(/%5Buser_id%5D=(\d+|ID)/, "%5Buser_id%5D=#{window.SHIKI_USER.id}")
    $new_review.attr href: new_review_url
  else
    $new_review.hide()

  # автоподгрузка блока с расширенной инфой об аниме для гостей
  $('.l-content').on 'postloaded:success', '.resources-loader', ->
    $('.c-screenshot').magnificRelGallery()

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
