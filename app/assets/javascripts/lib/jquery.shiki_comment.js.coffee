(($) ->
  $.fn.extend
    shiki_comment: ->
      @each ->
        $root = $(@)
        return unless $root.hasClass('unprocessed')

        new ShikiComment($root)
) jQuery

# TODO: в кнструктор перенесён весь старый код
# надо отрефакторить. подумать над view бекбона.
# сделал бы сразу, но не уверен, что не будет тормозить
class @ShikiComment extends ShikiView
  initialize: ($root) ->
    # выделение текста в комментарии
    @$('.body').on 'mouseup', =>
      text = $.getSelectionText()
      return unless text

      # скрываем все остальные кнопки цитаты
      $('.item-quote').hide()

      # и показываем в текущем комментарии
      $quote = @$('.item-quote')
        .data(quote: text)
        .css(display: 'inline-block')

      _.delay ->
        $(document).one 'click', ->
          unless $.getSelectionText().length
            $quote.hide()
          else
            _.delay ->
              $quote.hide() unless $.getSelectionText().length
            , 250

    # цитирование комментария
    @$('.item-quote').on 'click', ->
      $comment = $(@).closest('.b-comment')
      $comment.find('.item-reply').trigger 'ajax:success',
        comment_id: $comment.data('id')
        user: $comment.find('.name-date a').html()
        user_id: $comment.find('.name-date a').data('user_id')
        body: $(@).data('quote')
        offtopic: $comment.find('.b-offtopic_marker').css('display') isnt 'none'

    # ответ на обзор
    #@$('.review-block .content .item-reply').live 'click', (e) ->
      #$(@).trigger 'ajax:success', [e, {}]

    # ответ на комментарий
    @$('.item-reply').on 'ajax:success', (e, data, satus, xhr) ->
      $container = $(@).parents '.b-comments'
      $container = $(@).parents '.topic-block' unless $container.length

      # редактор может быть скрыт, надо показать
      $('.b-shiki_editor', $container).show()
      $editor = $('.b-shiki_editor textarea', $container).last()

      # для Message - полное цитирование, а для Comment вставка только имени комментируемого со ссылкой на коммент
      if data.id
        $editor.val $editor.attr('value') + "[#{data.kind}=#{data.id}]#{data.user}[/#{data.kind}], "
      # data может не быть, например, когда отвечаем на обзор - там ничего не цитируем
      else if data.body
        $editor.val "#{$editor.val()}[quote=#{_.compact([data.comment_id, data.user_id, data.user]).join(';')}]#{data.body}[/quote]\n"

      if data.offtopic
        $editor
          .parents('.b-comment')
          .find('.item-offtopic:not(.selected)')
          .trigger 'click'

      $editor.trigger 'update'
      $editor.focus()
      $editor.setCursorPosition $editor.attr('value').length

    # edit message
    @$('.main-controls .item-edit').on 'ajax:success', (e, html, status, xhr) =>
      $editor = $(html)
      new ShikiEditor($editor).edit_comment(@$root)

    # deletion
    @$('.main-controls .item-delete').on 'click', =>
      @$('.main-controls').hide()
      @$('.delete-controls').show()

    # confirm deletion
    @$('.delete-controls .item-delete-confirm').on 'ajax:loading', (e, data, status, xhr) =>
      $.hideCursorMessage()
      @$root.addClass('deleted')
      @$root.remove.bind(@$root).delay(300)

    # cancel deletion
    @$('.delete-controls .item-delete-cancel').on 'click', =>
      @$('.main-controls').show()
      @$('.delete-controls').hide()

    # moderation
    @$('.main-controls .item-moderation').on 'click', =>
      @$('.main-controls').hide()
      @$('.moderation-controls').show()

    # cancel moderation
    @$('.moderation-controls .item-moderation-cancel').on 'click', =>
      @$('.main-controls').show()
      @$('.moderation-controls').hide()

    # пометка комментария обзором/оффтопиком
    @$('.item-review, .item-offtopic, .b-offtopic_marker, .b-review_marker, .item-spoiler, .item-abuse').on 'ajax:success', (e, data, satus, xhr) =>
      if 'affected_ids' of data && data.affected_ids
        data.affected_ids.each (id) ->
          $comment = $(".b-comment##{id}")
          $comment.find(".item-#{data.kind}").toggleClass('selected', data.value)
          $comment.find(".b-#{data.kind}_marker").toggle(data.value)
          #$comment.find(".message-#{data.kind}").toggle(!data.value)

        $.notice marker_message(data)
      else
        $.notice 'Ваш запрос будет рассмотрен. Домо.'

      @$('.item-moderation-cancel').trigger('click')

    # переключение на мобильую версию
    @$('.item-mobile').on 'click', =>
      $(@)
        .toggleClass('selected')
        .parent()
        .toggleClass('mobile')

    # кнопка бана или предупреждения
    @$root.on 'ajax:success', '.item-ban', (e, html) ->
      $('.moderation-ban', $root).html(html)
      $('.item-moderation-cancel', $root).trigger('click')

    # закрытие формы бана
    @$root.on 'click', '.moderation-ban .form-cancel', ->
      $(@).closest('.moderation-ban').empty()

    # сабмит формы бана
    @$root.on 'ajax:success', '.moderation-ban form', (e, data) ->
      $root.html(data.comment_html)
      $(@).closest('.moderation-ban').empty()


# текст сообщения, отображаемый при изменении маркера
marker_message = (data) ->
  if data.value
    if data.kind == 'offtopic'
      if data.affected_ids.length > 1
        $.notice 'Комментарии помечены оффтопиком'
      else
        $.notice 'Комментарий помечен оффтопиком'
    else
      $.notice 'Комментарий помечен отзывом'
  else
    if data.kind == 'offtopic'
      $.notice 'Метка оффтопика снята'
    else
      $.notice 'Метка отзыва снята'
