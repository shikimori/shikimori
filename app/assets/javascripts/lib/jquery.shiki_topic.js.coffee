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
    @editor = new ShikiEditor(@$editor)
    #@$editor_textarea = @$editor.find('textarea')

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

        @editor.cleanup()

    # прочтение комментриев
    @on 'appear', (e, $appeared, by_click) =>
      return unless IS_LOGGED_IN
      $filtered_appeared = ($appeared || $(@)).not -> $(@).data 'disabled'

      $comments = $filtered_appeared.closest('.b-comment')
      $markers = $comments.find('.b-new_marker')

      ids = $comments.map(-> @id).toArray()
      $.ajax
        url: $appeared.data('url')
        type: 'POST'
        data:
          ids: ids.join ","

      $appeared.remove()

      interval = if by_click then 1 else 1500
      $markers.css.bind($markers).delay(interval, opacity: 0)
      $markers.hide.bind($markers).delay(interval + 500)

    # пометка комментариев обзорами/оффтопиками
    @on 'comment:marker', (e, data) =>
      data.affected_ids.each (id) =>
        $comment = @$(".b-comment##{id}")
        $comment.find(".item-#{data.kind}").toggleClass('selected', data.value)
        $comment.find(".b-#{data.kind}_marker").toggle(data.value)
        #$comment.find(".message-#{data.kind}").toggle(!data.value)

    # ответ на комментарий
    @on 'comment:reply', (e, text, is_offtopic) =>
      @editor.reply_comment text, is_offtopic

    # подготовка к подгрузке новых комментов
    @$('.comments-shower').on 'ajax:before', (e, html) ->
      $(@).data href: $(@).data('href-template').replace('SKIP', $(@).data('skip'))

    # подгрузка новых комментов
    @$('.comments-shower').on 'ajax:success', (e, html) =>
      $comments_shower = $(e.target)

      $new_comments = $("<div></div>").html html
      @_filter_present_entries($new_comments)

      $new_comments
        .insertAfter($comments_shower)
        .animated_expand()
        .process()

      if $comments_shower.data 'infinite'
        limit = $comments_shower.data('limit')
        count = $comments_shower.data('count') - limit

        if count > 0
          $comments_shower.data
            skip: $comments_shower.data('skip') + limit
            count: count

          $comments_shower.html "Показать #{p(_.min([limit, count]), 'предыдущий', 'предыдущие', 'предыдущие')} #{_.min [limit, count]} #{p(count, 'комментарий', 'комментария', 'комментариев')}" + (
              if count > limit then "<span class=\"expandable-comments-count\"> (из #{count})</span>" else ""
            )
        else
          $comments_shower.remove()
      else
        $comments_shower.html($comments_shower.data 'html').removeClass('click-loader').hide()
        @$('.comments-hider').show()

  # удаляем уже имеющиеся подгруженные элементы
  _filter_present_entries: ($comments) ->
    filter = 'b-comment'
    present_ids = $(".#{filter}").toArray().map (v) -> v.id

    exclude_selector = present_ids.map (id) ->
        ".#{filter}##{id}"
      .join(',')

    $comments.children().filter(exclude_selector).remove()
