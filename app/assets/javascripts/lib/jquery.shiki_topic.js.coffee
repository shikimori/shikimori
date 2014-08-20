(($) ->
  $.fn.extend
    shiki_topic: ->
      @each ->
        $root = $(@)
        return unless $root.hasClass('unprocessed')

        new ShikiTopic($root)
) jQuery

class @ShikiTopic extends ShikiView
  initialize: ($root) ->
    @$editor = @$('.b-shiki_editor')
    @$editor_textarea = @$editor.find('textarea')

    @$editor
      .on 'ajax:before', (e) ->
        $comment_body = $(@).find('textarea')
        if $comment_body.val().replace(/\n| |\r|\t/g, '') == ''
          $.alert 'Текст комментария не может быть пустым'
          $.hideCursorMessage()
          false

      .on 'ajax:success', (e, response) =>
        $new_comment = $(response.html)

        if @$editor.is(':last-child')
          @$('.b-comments').append $new_comment
        else
          @$('.b-comments').prepend $new_comment

        $new_comment
          .process()
          .shiki_comment()
          .yellowFade()

        @$editor.trigger 'editor:cleanup'

    # пометка комментариев обзорами/оффтопиками
    @on 'comment:marker', (e, data) =>
      data.affected_ids.each (id) =>
        $comment = @$(".b-comment##{id}")
        $comment.find(".item-#{data.kind}").toggleClass('selected', data.value)
        $comment.find(".b-#{data.kind}_marker").toggle(data.value)
        #$comment.find(".message-#{data.kind}").toggle(!data.value)

    # ответ на комментарий
    @on 'comment:reply', (e, quote) =>
      @$editor_textarea
        .val("#{@$editor_textarea.val()}\n#{quote}".replace(/^\n+/, ''))
        .focus()
        .setCursorPosition(@$editor_textarea.val().length)


      ## редактор может быть скрыт, надо показать
      #$('.b-shiki_editor', $container).show()
      #$editor = $('.b-shiki_editor textarea', $container).last()

      ## для Message - полное цитирование, а для Comment вставка только имени комментируемого со ссылкой на коммент
      #if data.id
        #$editor.val $editor.attr('value') + "[#{data.kind}=#{data.id}]#{data.user}[/#{data.kind}], "
      ## data может не быть, например, когда отвечаем на обзор - там ничего не цитируем
      #else if data.body
        #$editor.val "#{$editor.val()}[quote=#{_.compact([data.comment_id, data.user_id, data.user]).join(';')}]#{data.body}[/quote]\n"

      #if data.offtopic
        #$editor
          #.parents('.b-comment')
          #.find('.item-offtopic:not(.selected)')
          #.trigger 'click'

      #$editor.trigger 'update'
      #$editor.focus()
      #$editor.setCursorPosition $editor.attr('value').length
