TRANSLATIONS =
  ru:
    authorized_action: "Действие станет доступно через сутки после регистрации."
  en:
    authorized_action: "Action will be available one day after registering."

using 'DynamicElements'
class DynamicElements.DayRegisteredAction extends View
  initialize: ->
    @$node.on 'click', (e) ->
      if !USER_SIGNED_IN
        $.alert AuthorizedAction.TRANSLATIONS[LOCALE].authorized_action
        e.stopImmediatePropagation()
        false

      else if !DAY_REGISTERED
        $.alert TRANSLATIONS[LOCALE].authorized_action
        e.stopImmediatePropagation()
        false
