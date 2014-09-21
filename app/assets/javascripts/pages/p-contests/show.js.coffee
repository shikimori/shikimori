@on 'page:load', 'contests_show', ->
  $('#social_image').hide()
  $root = $('.l-content')

  # выбор первого голосования в списке
  vote_id = $('.match-container').data('id')
  $vote = if vote_id
    $(".match-link[data-id=#{vote_id}]")
  else
    $('.match-link.pending').first()

  $vote = $('.match-link').first() unless $vote.length
  $vote.trigger 'click'
  #$.hideCursorMessage()

  # голосование загружено
  $root.on 'ajax:success', '.match-container', (e) ->
    $.scrollTo() unless $('.vs').is(':appeared')

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

    # включение/отключение предложения воздержаться
    if $('.contest-match', e.target).data('state') == 'started'
      $('.item-content .warning').show()
    else
      $('.item-content .warning').hide()

    process_current_dom()

  # клик по одному из вариантов голосования
  $root.on 'click', '.match-member img', (e) ->
    return if in_new_tab(e)
    state = $(e.target).closest('.contest-match').data 'state'
    if state == 'started'
      $(e.target).closest('.match-member').callRemote()
    false

  # успешное голосование за один из вариантов
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
        _.delay ->
          $vote.first().trigger 'click'
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
  $root.on 'ajax:before', '.match-link', (e, data) ->
    unless $('.match-container > img').length
      $('.match-container').stop(true, false).animate opacity: 0.3

  $root.on 'ajax:success', '.match-link', (e, data) ->
    $('.match-link').removeClass 'active'
    $(e.target).addClass('active')

    $('.match-container').html(data)
        .stop(true, false)
        .trigger('ajax:success')
        .animate opacity: 1

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
