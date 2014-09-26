(($) ->
  $.fn.extend
    shiki_forum: ->
      @each ->
        $root = $(@)
        return unless $root.hasClass('unprocessed')

        new ShikiForum($root)
) jQuery

class @ShikiForum extends ShikiView
  initialize: ($root) ->
    @on 'faye:comment:created faye:comment:updated faye:comment:deleted', (e, data) =>
      $topic = @$(".b-topic##{data.topic_id}")
      if $topic.exists()
        $topic.trigger e.type, data
      else if e.type == 'faye:comment:created'
        $placeholder = @_faye_placeholder(data.topic_id)

        # уведомление о добавленном элементе через faye
        $(document.body).trigger "faye:added"

    #@on 'faye:topic:created faye:topic:updated faye:topic:deleted', (e, data) =>

    @on 'faye:topic:created', (e, data) =>
      $placeholder = @_faye_placeholder(data.topic_id)
      # уведомление о добавленном элементе через faye
      $(document.body).trigger "faye:added"

  # получение плейсхолдера для подгрузки новых комментариев
  _faye_placeholder: (comment_id) ->
    $placeholder = @$('>.faye-loader')

    unless $placeholder.exists()
      $placeholder = $('<div class="click-loader faye-loader"></div>')
        .prependTo(@$root)
        .data(ids: [])
        .on 'ajax:success', (e, html) ->
          $html = $(html)
          $placeholder.replaceWith $html
          $html.process()

    if $placeholder.data('ids').indexOf(comment_id) == -1
      $placeholder.data
        ids: $placeholder.data('ids').include(comment_id)
      $placeholder.data
        href: "/topics/chosen/#{$placeholder.data("ids").join ","}"

      num = $placeholder.data('ids').length
      $placeholder.html p(num, 'Добавлен ', 'Добавлены ', 'Добавлено ') + num + p(num, ' новый топик', ' новых топика', ' новых топиков')

    $placeholder
