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

    # пометка комментария обзором/оффтопиком
    #@on 'ajax:success', '.item-review,.item-offtopic,.b-offtopic_marker,.b-review_marker,.item-spoiler,.item-abuse', (e, data, satus, xhr) =>

