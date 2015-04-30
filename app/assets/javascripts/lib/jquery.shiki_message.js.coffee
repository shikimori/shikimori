(($) ->
  $.fn.extend
    shiki_message: ->
      @each ->
        $root = $(@)
        return unless $root.hasClass('unprocessed')

        new ShikiMessage($root)
) jQuery

class @ShikiMessage extends ShikiComment
  _type: -> 'message'
  _type_label: -> 'Сообщение'

  initialize: ($root) ->
    super $root
