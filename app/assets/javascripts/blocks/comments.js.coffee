$block = (node) ->
  $(node).closest '.comment-block'

# add/edit comment form
$('.shiki-editor form').live('ajax:before', (e) ->
  $this = $(@)
  $comment_body = $this.find('textarea')
  if $comment_body.attr('value').replace(/\n| |\r|\t/g, "") is ""
    $.flash alert: 'Текст сообщения не может быть пустым'
    $.hideCursorMessage()
    false
).live 'ajax:success', (e, data, status, xhr) ->
  $this = $(@)

  # отменяем флаги оффтопика и обзора на редакторе
  $('.item-offtopic, .item-review', $this).removeClass 'selected'
  $('#comment_offtopic, #comment_review', $this).val '0'

  # при наличии флага dont-add-comments коменты не добавляем
  return if $this.data('do-not-add-comments')
  $('.ajax, .slide > .selected').one 'comment:added', ->
    $comments = $this.parents('.comments')
    return if $(@).data('ignore-comment-added')
    $comment = $(data.html)
    $prior_comment = $(".comment-#{data.id}")
    if $prior_comment.length and $prior_comment.find('textarea').length
      $prior_comment.replaceWith $comment
    else
      $container = $('.comments-container', $comments)
      if $container.hasClass('bottom-add')
        $comment.insertBefore $container.children().last()
      else
        $comment.insertAfter $container.children().first()
    $comment.yellowFade true
    $comment_body = $this.find('.comment_body')
    $comment_body.attr('value', '').trigger('update').trigger 'blur'

  if $('.pagination').length
    $('.ajax, .slide > .selected').add($this).trigger 'comment:success', data
  else
    $('.ajax, .slide > .selected').add($this).trigger 'comment:added', data


# выделение текста в комментарии
$('.entry-container .description, .comment-block .body').live 'mouseup', ->
  text = $.getSelectionText()
  return unless text.length

  # скрываем все остальные кнопки цитаты
  $('.item-quote').hide()

  # и показываем в текущем комментарии
  $quote = $(@).parents('.entry-container, .comment-block')
      .find('.item-quote')
      .data(quote: text)
      .css(display: 'inline-block')

  _.delay ->
    $(document).one 'click', ->
      unless $.getSelectionText().length
        $quote.hide()
      else
        _.delay ->
          $quote.hide()  unless $.getSelectionText().length
        , 250

# цитирование комментария
$('.comment-block .item-quote').live 'click', ->
  $comment = $(@).parents('.comment-block')
  $comment.find('.item-reply').trigger 'ajax:success',
    comment_id: $comment.data('id')
    user: $comment.find('.name-date a').html()
    user_id: $comment.find('.name-date a').data('user_id')
    body: $(@).data('quote')
    offtopic: $comment.find('.offtopic-marker').css('display') isnt 'none'

# ответ на обзор
$('.review-block .content .item-reply').live 'click', (e) ->
  $(@).trigger 'ajax:success', [e, {}]

# ответ на комментарий
$('.topic-block .content .item-reply, .comment-block .item-reply').live 'ajax:success', (e, data, satus, xhr) ->
  $container = $(@).parents '.comments-container'
  $container = $(@).parents '.topic-block' unless $container.length

  # редактор может быть скрыт, надо показать
  $('.shiki-editor', $container).show()
  $editor = $('.shiki-editor textarea', $container).last()

  # для Message - полное цитирование, а для Comment вставка только имени комментируемого со ссылкой на коммент
  if data.id
    $editor.attr 'value', $editor.attr('value') + "[#{data.kind}=#{data.id}]#{data.user}[/#{data.kind}], "
  # data может не быть, например, когда отвечаем на обзор - там ничего не цитируем
  else
    if data.body
      $editor.attr 'value', $editor.attr('value') + "[quote=#{_.compact([data.comment_id, data.user_id, data.user]).join(';')}]#{data.body}[/quote]\n"

  if data.offtopic
    $editor
      .parents('.comment-block')
      .find('.item-offtopic:not(.selected)')
      .trigger 'click'

  $editor.trigger 'update'
  $editor.focus()
  $editor.setCursorPosition $editor.attr('value').length

# edit message
$('.comment-block .main-controls .item-edit').live 'ajax:success', (e, data, status, xhr) ->
  $replacement = $(data)
  $block(@).replaceWith $replacement
  $replacement.shikiEditor().addClass($block(@).attr('class').match(/comment-\d+/)[0]).show()
  $replacement.find('textarea').focus()

# deletion
$('.main-controls .item-delete').live 'click', ->
  $('.main-controls', $block(@)).hide()
  $('.delete-controls', $block(@)).show()

# confirm deletion
$('.delete-controls .item-delete-confirm').live 'ajax:loading', (e, data, status, xhr) ->
  $.hideCursorMessage()

  $form = $(@).parents('.comments-container').find('form')
  $block(@).css(minHeight: '0px').animate
    height: '0px'
  , =>
    $block(@).remove()
    # Аааа нафига это, я забыл и теперь не понимаю!
    $('.ajax').add($form).trigger 'comment:deleted', data

# cancel deletion
$('.delete-controls .item-delete-cancel').live 'click', ->
  $('.main-controls', $block(@)).show()
  $('.delete-controls', $block(@)).hide()

# moderation
$('.main-controls .item-moderation').live 'click', ->
  $('.main-controls', $block(@)).hide()
  $('.moderation-controls', $block(@)).show()
# cancel moderation
$('.moderation-controls .item-moderation-cancel').live 'click', ->
  $('.main-controls', $block(@)).show()
  $('.moderation-controls', $block(@)).hide()

# пометка комментария обзором/оффтопиком
$('.item-review, .item-offtopic, .offtopic-marker, .review-marker, .item-spoiler, .item-abuse').live 'ajax:success', (e, data, satus, xhr) ->
  if 'affected_ids' of data and data.affected_ids.length
    _.each data.affected_ids, (id) ->
      $comment = $(".comment-#{id}")
      $comment.find(".item-#{data.kind}").toggleClass 'selected', data.value
      $comment.find(".#{data.kind}-marker").toggle data.value
      $comment.find(".message-#{data.kind}").toggle !data.value

    if data.value
      if data.kind == 'offtopic'
        if data.affected_ids.length > 1
          $.flash notice: 'Комментарии помечены оффтопиком'
        else
          $.flash notice: 'Комментарий помечен оффтопиком'
      else
        $.flash notice: 'Комментарий помечен отзывом'
    else
      if data.kind == 'offtopic'
        $.flash notice: 'Метка оффтопика снята'
      else
        $.flash notice: 'Метка отзыва снята'
  else
    $.flash notice: 'Ваш запрос будет рассмотрен. Домо.'
  $(@).closest('.comment-block').find('.item-moderation-cancel').trigger('click')

# кнопка бана или предупреждения
$(document).on 'ajax:success', '.item-ban', (e, html) ->
  $('.moderation-ban', $block(@)).html html
  $('.item-moderation-cancel', $block(@)).trigger 'click'

# закрытие формы бана
$(document).on 'click', '.moderation-ban .form-cancel', ->
  $(@).closest('.moderation-ban').empty()

# сабмит формы бана
$(document).on 'ajax:success', '.moderation-ban form', (e, data) ->
  $block(@).html data.comment_html
  $(@).closest('.moderation-ban').empty()

# переключение на мобильую версию
$(document).on 'click', '.item-mobile', ->
  $(@).toggleClass('selected')
      .parent()
      .toggleClass('mobile')
