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

      # скрываем все кнопки цитаты
      $('.item-quote').hide()

      @$root.data(selected_text: text)
      $quote = @$('.item-quote').css(display: 'inline-block')

      _.delay ->
        $(document).one 'click', ->
          unless $.getSelectionText().length
            $quote.hide()
          else
            _.delay ->
              $quote.hide() unless $.getSelectionText().length
            , 250

    # цитирование комментария
    @$('.item-quote').on 'click', =>
      ids = [@$root.prop('id'), @$root.data('user_id'), @$root.data('user_nickname')]
      selected_text = @$root.data('selected_text')
      quote = "[quote=#{ids.join ';'}]#{selected_text}[/quote]\n"

      @$root.trigger 'comment:reply', [quote, @_is_offtopic()]

    # ответ на комментарий
    @$('.item-reply').on 'ajax:success', (e, response) =>
      reply = "[#{response.kind}=#{response.id}]#{response.user}[/#{response.kind}], "
      @$root.trigger 'comment:reply', [reply, @_is_offtopic()]

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
      @$root.remove.bind(@$root).delay(400)

    # cancel deletion
    @$('.delete-controls .item-delete-cancel').on 'click', =>
      @$('.main-controls').show()
      @$('.delete-controls').hide()

    # по нажатиям на кнопки закрываем меню в мобильной версии
    @$('.item-quote,.item-reply,.item-edit,.item-review,.item-offtopic').on 'click', =>
      @_close_aside()

    # пометка комментария обзором/оффтопиком
    @$('.item-review,.item-offtopic,.b-offtopic_marker,.b-review_marker').on 'ajax:success', (e, data, satus, xhr) =>
      if 'affected_ids' of data && data.affected_ids.length
        @$root.trigger 'comment:marker', [data]
        $.notice marker_message(data)
      else
        $.notice 'Ваш запрос будет рассмотрен. Домо.'

      @$('.item-moderation-cancel').trigger('click')

    # переключение на мобильую версию кнопок кнопок
    @$('.item-mobile').on 'click', =>
      @$root.toggleClass('aside-expanded')
      @$('.item-mobile').toggleClass('selected')

    # moderation
    @$('.main-controls .item-moderation').on 'click', =>
      @$('.main-controls').hide()
      @$('.moderation-controls').show()

    # cancel moderation
    @$('.moderation-controls .item-moderation-cancel').on 'click', =>
      @$('.main-controls').show()
      @$('.moderation-controls').hide()

    # кнопка бана или предупреждения
    @$('.item-ban').on 'ajax:success', (e, html) =>
      @$('.moderation-ban').html(html).show()
      @_close_aside()

    # закрытие формы бана
    @$('.moderation-ban').on 'click', '.form-cancel', =>
      @$('.moderation-ban').hide()

    # сабмит формы бана
    @$('.moderation-ban').on 'ajax:success', 'form', (e, response) =>
      @$root.trigger 'comment:replace', response.html

    @on 'comment:replace', (e, html) =>
      $replaced_comment = $(html)
      @$root.replaceWith($replaced_comment)

      $replaced_comment
        .process()
        .shiki_comment()
        .yellowFade()

  # закрытие кнопок в мобильной версии
  _close_aside: ->
    @$('.item-mobile').click() if @$('.item-mobile').is('.selected')

  # оффтопиковый ли данный комментарий
  _is_offtopic: ->
    @$('.b-offtopic_marker').css('display') != 'none'

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
