import View from 'views/application/view'

export default class ShikiModal extends View
  initialize: ->
    @$modal = $("<div class='b-modal'><div class='inner'></div></div>")

    @$modal.find('.inner').append @$root
    @$modal.css top: $(window).scrollTop()
    @$modal.children().css top: $(window).scrollTop()

    @$modal.appendTo(document.body)

    $(window).on 'keydown', @_key_cancel
    @$modal.on 'click', '.cancel', @close
    @_shade()

  close: =>
    $(window).off 'keydown', @_key_cancel
    @$modal.remove()
    @_unshade()

  _shade: ->
    $('.b-shade')
      .addClass('active')
      .on('click', @close)

  _unshade: ->
    $('.b-shade')
      .removeClass('active')
      .off('click', @close)

  _key_cancel: (e) =>
    if e.keyCode == 27
      @close()
