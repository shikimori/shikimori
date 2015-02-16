(($) ->
  $.fn.extend
    shiki_comment: ->
      @each ->
        $root = $(@)
        return unless $root.hasClass('unprocessed')

        new ShikiComment($root)
) jQuery

class @ShikiComment extends ShikiEditable
  initialize: ($root) ->
    @$body = @$('.body')

    if @$inner.hasClass('check_height')
      $images = @$body.find('img')
      if $images.exists()
        # картинки могут быть уменьшены image_normalizer'ом, поэтому делаем с задержкой
        $images.imagesLoaded => @_check_height.delay(10)
      else
        @_check_height()

    # выделение текста в комментарии
    @$body.on 'mouseup', =>
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
      type = @_type()[0]
      quote = "[quote=#{type}#{ids.join ';'}]#{selected_text}[/quote]\n"

      @$root.trigger 'comment:reply', [quote, @_is_offtopic()]

    # ответ на комментарий
    @$('.item-reply').on 'ajax:success', (e, response) =>
      reply = "[#{response.kind}=#{response.id}]#{response.user}[/#{response.kind}], "
      @$root.trigger 'comment:reply', [reply, @_is_offtopic()]

    # edit message
    @$('.main-controls .item-edit')
      .on 'ajax:before', @_shade
      .on 'ajax:complete', @_unshade
      .on 'ajax:success', (e, html, status, xhr) =>
        $editor = $(html)
        new ShikiEditor($editor).edit_comment(@$root)

    # moderation
    @$('.main-controls .item-moderation').on 'click', =>
      @$('.main-controls').hide()
      @$('.moderation-controls').show()

    # по нажатиям на кнопки закрываем меню в мобильной версии
    @$('.item-quote,.item-reply,.item-edit,.item-review,.item-offtopic').on 'click', =>
      @_close_aside()

    # пометка комментария обзором/оффтопиком
    @$('.item-review,.item-offtopic,.item-spoiler,.item-abuse,.b-offtopic_marker,.b-review_marker').on 'ajax:success', (e, data, satus, xhr) =>
      if 'affected_ids' of data && data.affected_ids.length
        data.affected_ids.each (id) ->
          $(".b-comment##{id}").data('shiki_object').mark(data.kind, data.value)
        $.notice marker_message(data)
      else
        $.notice 'Ваш запрос будет рассмотрен. Домо аригато.'

      @$('.item-moderation-cancel').trigger('click')

    # cancel moderation
    @$('.moderation-controls .item-moderation-cancel').on 'click', =>
      #@$('.main-controls').show()
      #@$('.moderation-controls').hide()
      @_close_aside()

    # кнопка бана или предупреждения
    @$('.item-ban').on 'ajax:success', (e, html) =>
      @$('.moderation-ban').html(html).show()
      @_close_aside()

    # закрытие формы бана
    @$('.moderation-ban').on 'click', '.cancel', =>
      @$('.moderation-ban').hide()

    # сабмит формы бана
    @$('.moderation-ban').on 'ajax:success', 'form', (e, response) =>
      @_replace response.html

  # пометка комментария маркером (оффтопик/отзыв)
  mark: (kind, value) ->
    @$(".item-#{kind}").toggleClass('selected', value)
    @$(".b-#{kind}_marker").toggle(value)

  # оффтопиковый ли данный комментарий
  _is_offtopic: ->
    @$('.b-offtopic_marker').css('display') != 'none'

  _type: -> 'comment'
  _type_label: -> 'Комментарий'

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
