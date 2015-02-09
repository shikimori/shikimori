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
    @_check_height()

    # прочтение комментриев
    @$('.b-new_marker.active').on 'click', (e) =>
      $markers = $(e.target)
      ids = [@$root.data('message_id')]

      $.ajax
        url: @$root.data('appear_url')
        type: 'POST'
        data:
          ids: ids.join ","

      $markers.removeClass 'active'
      $markers.css.bind($markers).delay(1, opacity: 0)
      $markers.hide.bind($markers).delay(500)

  _type: -> 'dialog'
  _type_label: -> 'Диалог'
