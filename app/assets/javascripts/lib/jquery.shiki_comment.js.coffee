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
class @ShikiComment
  constructor: ($root) ->
    @$root = $root
    @$root.removeClass('unprocessed')

    $block = (node) ->
      $(node).closest('.b-comment')

    $('.b-shiki_editor').on 'ajax:before', (e) ->
      $this = $(@)
      $comment_body = $this.find('textarea')
      if $comment_body.attr('value').replace(/\n| |\r|\t/g, '') is ''
        $.flash alert: 'Текст сообщения не может быть пустым'
        $.hideCursorMessage()
        false

    .on 'ajax:success', (e, data, status, xhr) ->
      debugger
      #$this = $(@)

      ## отменяем флаги оффтопика и обзора на редакторе
      #$('.item-offtopic, .item-review', $this).removeClass('selected')
      #$('#comment_offtopic, #comment_review', $this).val('0')

      ## при наличии флага dont-add-comments коменты не добавляем
      #return if $this.data('do-not-add-comments')
      #$('.ajax, .slide > .selected').one 'comment:added', ->
        #$comments = $this.parents('.comments')
        #return if $(@).data('ignore-comment-added')
        #$comment = $(data.html)
        #$prior_comment = $(".comment-#{data.id}")
        #if $prior_comment.length and $prior_comment.find('textarea').length
          #$prior_comment.replaceWith $comment
        #else
          #$container = $('.b-comments', $comments)
          #if $container.hasClass('bottom-add')
            #$comment.insertBefore $container.children().last()
          #else
            #$comment.insertAfter $container.children().first()

        #$comment.yellowFade(true)
        #$comment_body = $this.find('.comment_body')
        #$comment_body.val('').trigger('update').trigger('blur')

      #if $('.pagination').length
        #$('.ajax, .slide > .selected').add($this)
          #.trigger('comment:success', data)
      #else
        #$('.ajax, .slide > .selected').add($this)
          #.trigger('comment:added', data)

    # выделение текста в комментарии
    $('.body', @$root).on 'mouseup', =>
      text = $.getSelectionText()
      return unless text.length

      # скрываем все остальные кнопки цитаты
      $('.item-quote').hide()

      # и показываем в текущем комментарии
      $quote = @$root
        .find('.item-quote')
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
    $('.item-quote', @$root).on 'click', ->
      $comment = $(@).closest('.b-comment')
      $comment.find('.item-reply').trigger 'ajax:success',
        comment_id: $comment.data('id')
        user: $comment.find('.name-date a').html()
        user_id: $comment.find('.name-date a').data('user_id')
        body: $(@).data('quote')
        offtopic: $comment.find('.b-offtopic_marker').css('display') isnt 'none'

    # ответ на обзор
    $('.review-block .content .item-reply').live 'click', (e) ->
      $(@).trigger 'ajax:success', [e, {}]

    # ответ на комментарий
    $('.b-comment .item-reply').live 'ajax:success', (e, data, satus, xhr) ->
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
    $('.main-controls .item-edit', @$root).on 'ajax:success', (e, data, status, xhr) ->
      new ShikiEditor($(data)).edit_comment($root)

    # deletion
    $('.main-controls .item-delete', @$root).on 'click', ->
      $('.main-controls', $root).hide()
      $('.delete-controls', $root).show()

    # confirm deletion
    $('.delete-controls .item-delete-confirm', @$root).on 'ajax:loading', (e, data, status, xhr) ->
      $.hideCursorMessage()

      $form = $(@).parents('.b-comments').find('form')
      $root.css(minHeight: '0px').animate
        height: '0px'
      , =>
        $root.remove()
        # Аааа нафига это, я забыл и теперь не понимаю!
        $('.ajax').add($form).trigger 'comment:deleted', data

    # cancel deletion
    $('.delete-controls .item-delete-cancel', @$root).on 'click', ->
      $('.main-controls', $root).show()
      $('.delete-controls', $root).hide()

    # moderation
    $('.main-controls .item-moderation', @$root).on 'click', ->
      $('.main-controls', $root).hide()
      $('.moderation-controls', $root).show()

    # cancel moderation
    $('.moderation-controls .item-moderation-cancel', @$root).on 'click', ->
      $('.main-controls', $root).show()
      $('.moderation-controls', $root).hide()

    # пометка комментария обзором/оффтопиком
    $('.item-review, .item-offtopic, .b-offtopic_marker, .b-review_marker, .item-spoiler, .item-abuse').live 'ajax:success', (e, data, satus, xhr) ->
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

      $(@)
        .closest('.b-comment')
        .find('.item-moderation-cancel')
        .trigger('click')

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

    # переключение на мобильую версию
    @$root.on 'click', '.item-mobile', =>
      $(@)
        .toggleClass('selected')
        .parent()
        .toggleClass('mobile')
