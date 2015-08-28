class @AuthorizedAction extends BaseProcessor
  @PHRASE =
    ru: "Для этого действия вам необходима регистрация на сайте."
    en: "You need to sign in or sign up to perform this action."

  initialize: ->
    @$node.on 'click', (e) ->
      unless USER_SIGNED_IN
        $.alert AuthorizedAction.PHRASE[LOCALE]
        e.stopImmediatePropagation()
        false
