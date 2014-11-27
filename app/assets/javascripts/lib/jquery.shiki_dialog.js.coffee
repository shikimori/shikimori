(($) ->
  $.fn.extend
    shiki_dialog: ->
      @each ->
        $root = $(@)
        return unless $root.hasClass('unprocessed')

        new ShikiDialog($root)
) jQuery

class @ShikiDialog extends ShikiEditable
  initialize: ($root) ->

  _type: -> 'dialog'
  _type_label: -> 'Диалог'
