page_load 'contests_show', ->
  # $root = $('.l-content')

  if $('.contest.started').length
    new Contests.Round $('.contest.started'), gon.votes

  # # клик по одному из вариантов голосования
  # $root.on 'click', '.match-member img', (e) ->
    # return if in_new_tab(e)
    # state = $(e.target).closest('.contest-match').data 'state'
    # if state == 'started'
      # $(e.target).closest('.match-member').callRemote()
    # false

  # # успешное голосование за один из вариантов
  # $root.on 'ajax:before', '.match-member', (e) ->
    # $(e.target).find('.b-catalog_entry').yellow_fade()

  # $root.on 'ajax:before', '.refrain', (e) ->
    # $(e.target).yellow_fade()

  # $root.on 'ajax:success', '.match-member, .refrain', (e, data) ->
    # # скрываем всё
    # $('.help, .refrained, .next, .refrain', $root).hide()
    # # убираем помеченное проголосованным
    # $('.match-member', $root)
      # .removeClass('voted')
      # .removeClass('unvoted')

    # # это аякс запрос голосования
    # if data
      # data.ajax = true
    # else
    # # это просто загруженное голосование
      # $vote = $(e.target).closest('.contest-match')
      # data =
        # ajax: false
        # variant: $vote.data 'voted'
        # vote_id: $vote.data 'vote_id'

    # switch data.variant
      # when 'none'
        # # показываем, что воздержались
        # $('.refrained', $root).show()

      # when 'left', 'right'
        # # показываем, что проголосовали
        # $('.refrain', $root).show()
        # $('.help.success', $root).show()
        # # помечаем проголосованный вариант
        # $(".match-member[data-variant=#{data.variant}]", $root)
          # .addClass('voted')
            # .siblings('.match-member')
            # .addClass('unvoted')

    # # помечаем проголосованное голосование
    # $link = $(".match-link[data-id=#{data.vote_id}]", $root)
    # $link
      # .removeClass('pending')
      # .removeClass('voted-left')
      # .removeClass('voted-right')
      # .removeClass('voted-none')
      # .addClass("voted-#{data.variant}")

    # # не проголосованные голосования
    # $vote = $('.match-link.pending', $root).first()

    # # если есть
    # if $vote.length
      # if data.ajax
        # # и грузим следующее голосование
        # delay(500).then -> $vote.first().trigger 'click'
      # else
        # # показываем ссылку "перейти дальше"
        # $('.next', $root).show()

    # # или показываем "спасибо"
    # else
      # $('.finish', $root).show()
      # # и скрываем в верхнем меню иконку
      # if data.ajax
        # $('.menu .contest[data-count=1]').hide()

  # # клик на переход к следующей не проголосованной паре
  # $root.on 'click', '.match-container .next', ->
    # $('.match-link.pending').first().trigger 'click'

  # # клик переход на следующую пару
  # $root.on 'click', '.next-match', ->
    # $match = $('.match-link.active')
    # $matches = $match.closest('.match-day').parent().find('.match-link').toArray()
    # index = $matches.indexOf($match[0]) + 1
    # if index >= $matches.length
      # index = 0

    # $($matches[index]).click()

  # # клик переход на предыдущую пару
  # $root.on 'click', '.prev-match', ->
    # $match = $('.match-link.active')
    # $matches = $match.closest('.match-day').parent().find('.match-link').toArray()
    # index = $matches.indexOf($match[0]) - 1
    # if index < 0
      # index = $matches.length - 1

    # $($matches[index]).click()
