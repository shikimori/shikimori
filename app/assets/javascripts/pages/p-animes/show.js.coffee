@on 'page:load', 'animes_show', 'mangas_show', ->
  $('.rating.notice').tipsy gravity: 's'
  $('.status-date.notice').tipsy gravity: 's'
  $('.b-screenshot').fancybox $.galleryOptions

  # rating
  $('.scores').makeRateble round_values: false

  # клик по загрузке других названий
  $('.other-names.click-loader').on 'ajax:success', (e, data) ->
    $(@).parents('p').replaceWith data

  # клик по смотреть онлайн
  $('.watch-online a').on 'click', ->
    episode = parseInt($('.menu-rate-block .current-episodes').html())
    total_episodes = parseInt($('.menu-rate-block .total-episodes').html()) || 9999
    watch_episode = if !episode || episode == total_episodes then 1 else episode + 1

    $(@).attr href: $(@).attr('href').replace(/\d+$/, watch_episode)

  # раскрытие свёрнутого блока связанного
  $('.l-content').on 'click', '.related-shower', ->
    $(@).next().children().unwrap()
    $(@).siblings().show()
    $(@).remove()

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
  $scores_user = $('.anime-rate .scores-user')
  $scores_user.makeRateble() if $scores_user.is(':visible')

  $('.anime-rate')
    # клик по добавлению в свой список
    .on 'click', '.add-to-list', ->
      $form = $(@).closest('form')

      $form.find('.user_rate_status input').val $(@).data('status')
      $form.submit()

    # клик по раскрытию вариантов добавления в список
    .on 'click', '.expand-options', ->
      $(@).toggleClass 'selected'

      $options = $('.anime-rate .expanded-options')

      unless $options.data 'height'
        $options
          .data height: $options.height()
          .css(height: 0)
          .show()

      (=>
        if $(@).hasClass 'selected'
          $options.css height: $options.data('height')
          $('.anime-rate .add-to-list:not(.option)').hide()
        else
          $options.css height: 0
          $('.anime-rate .add-to-list:not(.option)').show()
      ).delay()

    # отмена редактирования user_rate
    .on 'click', '.cancel', ->
      $show = $('.anime-rate .rate-show').show()
      $edit = $('.anime-rate .rate-edit').hide()

      $('.anime-rate .rate-container').css
        height: $show.data('height')

    # сабмит формы user_rate
    .on 'ajax:success', '.new_user_rate, .increment, .remove', (e, html) ->
      $('.anime-rate').html html
      $('.anime-rate .scores-user').makeRateble()

    # завершение редактирования user_rate
    .on 'ajax:success', '.edit_user_rate', (e, html) ->
      $('.anime-rate .rate-show').replaceWith($(html).find('.rate-show'))
      $('.anime-rate .rate-show').data height: $('.anime-rate .rate-show').height()
      $('.anime-rate .scores-user').makeRateble()

      $('.anime-rate .cancel').click()

    # клик на изменение user_rate - подгрузка и показ формы
    .on 'ajax:success', '.item-edit', (e, edit_html) ->
      $show = $('.anime-rate .rate-show')
      $show
        .data(height: $show.height())
        .hide()

      $edit = $('.anime-rate .rate-edit')
      $edit
        .html(edit_html)
        .data(height: $edit.height())
        .show()

      $('.anime-rate .rate-container').css height: $show.data('height')
      (-> $('.anime-rate .rate-container').css height: $edit.data('height')).delay()

