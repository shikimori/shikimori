class @AuthorizedAction extends View
  @TRANSLATIONS:
    ru:
      authorized_action: "Для этого действия вам необходима регистрация на сайте."
    en:
      authorized_action: "You need to sign in or sign up to perform this action."

  initialize: ->
    @$node.on 'click', (e) ->
      unless USER_SIGNED_IN
        $.alert AuthorizedAction.TRANSLATIONS[LOCALE].authorized_action
        e.stopImmediatePropagation()
        false
