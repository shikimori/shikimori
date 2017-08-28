page_load 'contests_show', ->
  $('#social_image').hide()
  $root = $('.l-content')

  match_votes = gon.match_votes

  # выбор первого голосования в списке
  debugger
  match_id = $('.match-container').data('id')
  $match = if match_id
    $(".match-link[data-id=#{match_id}]")
  else
    $('.match-link.pending')
      .add($('.match-link.started'))
      .add($('.match-link'))
      .first()
  $match.trigger 'click'

  # голосование загружено
  $root.on 'ajax:success', '.match-container', (e) ->
    $first_member = $('.match-members .match-member').first()
    $.scrollTo $first_member unless $first_member.is(':appeared')

    # подсветка по ховеру курсора
    $('.match-member', e.target).hover ->
      unless $('.match-member.voted', e.target).length
        $('.match-member', e.target).addClass 'unhovered'
        $(@).removeClass('unhovered')
            .addClass 'hovered'
    , ->
      $('.match-member', e.target).removeClass 'hovered unhovered'

    # пометка проголосованным, если это указано
    variant = $('.contest-match', e.target).data 'voted'
    if variant
      $('.refrain', e.target).trigger 'ajax:success'

    $root.process()

  # клик по одному из вариантов голосования
  $root.on 'click', '.match-member img', (e) ->
    return if in_new_tab(e)
    state = $(e.target).closest('.contest-match').data 'state'
    if state == 'started'
      $(e.target).closest('.match-member').callRemote()
    false

  # успешное голосование за один из вариантов
  $root.on 'ajax:before', '.match-member', (e) ->
    $(e.target).find('.b-catalog_entry').yellow_fade()

  $root.on 'ajax:before', '.refrain', (e) ->
    $(e.target).yellow_fade()

  $root.on 'ajax:success', '.match-member, .refrain', (e, data) ->
    # скрываем всё
    $('.help, .refrained, .next, .refrain', $root).hide()
    # убираем помеченное проголосованным
    $('.match-member', $root)
      .removeClass('voted')
      .removeClass('unvoted')

    # это аякс запрос голосования
    if data
      data.ajax = true
    else
    # это просто загруженное голосование
      $vote = $(e.target).closest('.contest-match')
      data =
        ajax: false
        variant: $vote.data 'voted'
        vote_id: $vote.data 'vote_id'

    switch data.variant
      when 'none'
        # показываем, что воздержались
        $('.refrained', $root).show()

      when 'left', 'right'
        # показываем, что проголосовали
        $('.refrain', $root).show()
        $('.help.success', $root).show()
        # помечаем проголосованный вариант
        $(".match-member[data-variant=#{data.variant}]", $root)
          .addClass('voted')
            .siblings('.match-member')
            .addClass('unvoted')

    # помечаем проголосованное голосование
    $link = $(".match-link[data-id=#{data.vote_id}]", $root)
    $link
      .removeClass('pending')
      .removeClass('voted-left')
      .removeClass('voted-right')
      .removeClass('voted-none')
      .addClass("voted-#{data.variant}")

    # не проголосованные голосования
    $vote = $('.match-link.pending', $root).first()

    # если есть
    if $vote.length
      if data.ajax
        # и грузим следующее голосование
        delay(500).then -> $vote.first().trigger 'click'
      else
        # показываем ссылку "перейти дальше"
        $('.next', $root).show()

    # или показываем "спасибо"
    else
      $('.finish', $root).show()
      # и скрываем в верхнем меню иконку
      if data.ajax
        $('.menu .contest[data-count=1]').hide()

  # клик на переход к следующей не проголосованной паре
  $root.on 'click', '.match-container .next', ->
    $('.match-link.pending').first().trigger 'click'

  # переключение между голосованиями
  $root
    .on 'ajax:before', '.match-link', (e, data) ->
      $('.match-container').addClass 'b-ajax'
    .on 'ajax:complete', '.match-link', (e, data) ->
      $('.match-container').removeClass 'b-ajax'

  $root.on 'ajax:success', '.match-link', (e, data) ->
    $('.match-link').removeClass 'active'
    $(e.target).addClass('active')

    $('.match-container').html(data)
      .stop(true, false)
      .trigger('ajax:success')

    page_url = $(e.target).data('page_url')
    if Modernizr.history && page_url
      window.history.replaceState(
        { turbolinks: true, url: page_url },
        '',
        page_url
      )

  # клик переход на следующую пару
  $root.on 'click', '.next-match', ->
    $match = $('.match-link.active')
    $matches = $match.closest('.match-day').parent().find('.match-link').toArray()
    index = $matches.indexOf($match[0]) + 1
    if index >= $matches.length
      index = 0

    $($matches[index]).click()

  # клик переход на предыдущую пару
  $root.on 'click', '.prev-match', ->
    $match = $('.match-link.active')
    $matches = $match.closest('.match-day').parent().find('.match-link').toArray()
    index = $matches.indexOf($match[0]) - 1
    if index < 0
      index = $matches.length - 1

    $($matches[index]).click()
