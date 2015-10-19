TRANSLATIONS =
  ru:
    authorized_action: "Для этого действия вам необходима регистрация на сайте."
  en:
    authorized_action: "You need to sign in or sign up to perform this action."

class @AuthorizedAction extends View
  initialize: ->
    @$node.on 'click', (e) ->
      unless USER_SIGNED_IN
        $.alert TRANSLATIONS[LOCALE].authorized_action
        e.stopImmediatePropagation()
        false
