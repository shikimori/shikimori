(($) ->
  $.fn.extend
    shiki_modal: ->
      @each ->
        $root = $(@)

        new ShikiModal($root)
) jQuery

class @ShikiModal extends View
  initialize: ($root) ->
    @$shade = $ '#shade'

    @$modal = $root
      .wrap("<div class='inner'></div>").parent()
      .wrap("<div class='b-modal'></div>").parent()
      .appendTo(document.body)

    $(window).on 'keydown', @_key_cancel
    @$modal.on 'click', '.cancel', @close

    @$shade.show()
    @$shade.on 'click', @close

  close: =>
    $(window).off 'keydown', @_key_cancel
    @$shade.off 'click', @close
    @$shade.hide()
    @$modal.remove()

  _key_cancel: (e) =>
    if e.keyCode == 27
      @close()
