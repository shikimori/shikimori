# скрытие картинки для share в соц сетях
$('#social_image').hide()

$ ->
  # отображалка новых комментариев
  if IS_LOGGED_IN
    window.comments_notifier = new CommentsNotifier()
    entry_block_a = '.entry-block a'
  else
    entry_block_a = '.entry-block > a > div'

  # выбор первого голосования в списке
  vote_id = $('.match-container').data('id')
  $vote = if vote_id
    $('.match-link[data-id='+vote_id+']')
  else
    $('.match-link.pending').first()

  $vote = $('.match-link').first() unless $vote.length
  $vote.trigger 'click'
  $.hideCursorMessage()

  # показ тултипов результатов
  $('.results .uninitialized-tooltip').tooltip(ANIME_TOOLTIP_OPTIONS)
      .removeClass('uninitialized-tooltip')
  $(entry_block_a).each ->
    $(@).data('no-align', true).tooltip().onBeforeShow().show()
  $(entry_block_a+', .entry-block .entry-tooltip').off 'mouseenter mouseleave'

# голосование загружено
$(document.body).on 'ajax:success', '.match-container', (e) ->
  # подсветка по ховеру курсора
  $('.match-member', e.target).hover ->
    unless $('.match-member.voted', e.target).length
      $('.match-member', e.target).addClass 'unhovered'
      $(@).removeClass('unhovered')
          .addClass 'hovered'
  , ->
    $('.match-member', e.target).removeClass 'hovered unhovered'

  # пометка проголосованным, если это указано
  variant = $('.vote', e.target).data 'voted'
  if variant
    $('.refrain', e.target).trigger 'ajax:success'

  # включение/отключение предложения воздержаться
  if $('.vote', e.target).data('state') == 'started'
    $('.item-content .warning').show()
  else
    $('.item-content .warning').hide()

  process_current_dom()

# клик по одному из вариантов голосования
$(document.body).on 'click', '.match-member img', (e) ->
  return if in_new_tab(e)
  state = $(e.target).closest('.vote').data 'state'
  if state == 'started'
    $(e.target).closest('.match-member').callRemote()
  false

# успешное голосование за один из вариантов
$(document.body).on 'ajax:success', '.match-member, .refrain', (e, data) ->
  $contest = $('.contest')
  # скрываем всё
  $('.help, .refrained, .next, .refrain', $contest).hide()
  # убираем помеченное проголосованным
  $('.match-member', $contest).removeClass 'voted'

  # это аякс запрос голосования
  if data
    data.ajax = true
  else
  # это просто загруженное голосование
    $vote = $(e.target).closest('.vote')
    data =
      ajax: false
      variant: $vote.data 'voted'
      vote_id: $vote.data 'vote_id'

  switch data.variant
    when 'none'
      # показываем, что воздержались
      $('.refrained', $contest).show()

    when 'left', 'right'
      # показываем, что проголосовали
      $('.refrain', $contest).show()
      $('.help.success', $contest).show()
      # помечаем проголосованный вариант
      $('.match-member[data-variant='+data.variant+']', $contest).addClass 'voted'

  # помечаем проголосованное голосование
  $link = $('.match-link[data-id='+data.vote_id+']', $contest)
  $link
    .removeClass('pending')
    .removeClass('voted-left')
    .removeClass('voted-right')
    .removeClass('voted-none')
    .addClass("voted-#{data.variant}")

  # не проголосованные голосования
  $vote = $('.match-link.pending', $contest).first()

  # если есть
  if $vote.length
    if data.ajax
      # и грузим следующее голосование
      _.delay ->
        $vote.first().trigger 'click'
    else
      # показываем ссылку "перейти дальше"
      $('.next', $contest).show()

  # или показываем "спасибо"
  else
    $('.finish', $contest).show()
    # и скрываем в верхнем меню иконку
    if data.ajax
      $('.menu .contest[data-count=1]').hide()

# клик на переход к следующей паре
$(document.body).on 'click', '.match-container .next', ->
  $('.match-link.pending').first().trigger 'click'

# переключение между голосованиями
$(document.body).on 'ajax:before', '.match-link', (e, data) ->
  unless $('.match-container > img').length
    $('.match-container').stop(true, false).animate opacity: 0.3

$(document.body).on 'ajax:success', '.match-link', (e, data) ->
  $('.match-link').removeClass 'active'
  $(e.target).addClass('active')

  $('.match-container').html(data)
      .stop(true, false)
      .trigger('ajax:success')
      .animate opacity: 1
