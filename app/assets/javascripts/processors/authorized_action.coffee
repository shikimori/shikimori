class @AuthorizedAction extends BaseProcessor
  @PHRASE =
    ru: "Для этого действия вам необходимо войти на сайт или зарегистрироваться."
    en: "You need to sign in or sign up to perform this action."

  initialize: ->
    @$node.on 'click', (e) ->
      unless USER_SIGNED_IN
        $.alert AuthorizedAction.PHRASE[LOCALE]
        e.stopImmediatePropagation()
        false
