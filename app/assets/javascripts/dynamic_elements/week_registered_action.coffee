# TODO: refactor to i18n-js
TRANSLATIONS =
  ru:
    authorized_action: "Действие станет доступно через неделю после регистрации."
  en:
    authorized_action: "Action will be available one week after registering."

using 'DynamicElements'
class DynamicElements.WeekRegisteredAction extends View
  initialize: ->
    @$node.on 'click', (e) ->
      if !USER_SIGNED_IN
        $.alert AuthorizedAction.TRANSLATIONS[LOCALE].authorized_action
        e.stopImmediatePropagation()
        false

      else if !WEEK_REGISTERED
        $.alert TRANSLATIONS[LOCALE].authorized_action
        e.stopImmediatePropagation()
        false
