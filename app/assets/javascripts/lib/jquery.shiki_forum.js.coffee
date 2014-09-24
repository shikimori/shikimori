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
      else
        console.log 'topic not is not visible'
