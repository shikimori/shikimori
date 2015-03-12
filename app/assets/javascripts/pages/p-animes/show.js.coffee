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
      episode = parseInt($('.anime-rate .current-episodes').html())
      total_episodes = parseInt($('.anime-rate .total-episodes').html()) || 9999
      watch_episode = if !episode || episode == total_episodes then 1 else episode + 1

      $(@).attr href: $(@).attr('href').replace(/\d+$/, watch_episode)
  ).delay()

  # раскрытие свёрнутого блока связанного
  $('.l-content').on 'click', '.related-shower', ->
    $(@).next().children().unwrap()
    $(@).siblings().show()
    $(@).remove()

  # добавление в избранное
  $('.icon-actions .fav-add').on 'ajax:success', ->
    $(@).hide().next().show()
  # удаление из избранного
  $('.icon-actions .fav-remove').on 'ajax:success', ->
    $(@).hide().prev().show()
  # комментировать
  $('.icon-actions .new_comment').on 'click', ->
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


  # user ratings
  $rate = $('.anime-rate')
  $('.b-rate', $rate).rateable()

  $rate
    .on 'ajax:before', (e, edit_html) ->
      $rate.addClass 'ajax_request'

    .on 'ajax:success ajax:complete', (e, edit_html) ->
      $rate.removeClass 'ajax_request'

    # клик по добавлению в свой список
    .on 'click', '.add-trigger', ->
      $form = $(@).closest('form')

      $form.find('.user_rate_status input').val $(@).data('status')
      $form.submit()

    # по изменению статуса в списке
    .on 'click', '.edit-trigger', ->
      # закрытие развёрнутого меню
      $rate.find('.expanded .arrow').click()

      if $('.rate-edit', $rate).is(':visible')
        $('.rate-edit', $rate).find('.cancel').click()
        false

    # отмена редактирования user_rate
    .on 'click', '.cancel', ->
      $show = $('.rate-show', $rate).show()
      $edit = $('.rate-edit', $rate).hide()

      $rate.css height: $('.b-add_to_list').outerHeight(true) + $show.data('height')
      (-> $rate.css height: '').delay(500)

    # сабмит формы user_rate
    .on 'ajax:success', '.new_user_rate, .increment, .remove', (e, html) ->
      $rate.html html
      $('.b-rate', $rate).rateable()

    # завершение редактирования user_rate
    .on 'ajax:success', '.edit_user_rate', (e, html) ->
      $rate.html html
      $('.b-rate', $rate).rateable()

    # клик на изменение user_rate - подгрузка и показ формы
    .on 'ajax:success', '.edit-trigger', (e, edit_html) ->
      e.stopImmediatePropagation()

      $show = $('.rate-show', $rate)
      $show
        .data(height: $show.outerHeight(true))
        .hide()

      $edit = $('.rate-edit', $rate)
      $edit.html(edit_html)

      $edit
        .data(height: $edit.outerHeight(true))
        .show()

      $rate.css height: $('.b-add_to_list').outerHeight(true) + $show.data('height')
      (->
        $rate.css height: $('.b-add_to_list').outerHeight(true) + $edit.data('height')
      ).delay()
      (-> $rate.css height: '').delay(500)
