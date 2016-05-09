using 'DynamicElements'
class DynamicElements.DayRegisteredAction extends View
  I18N_KEY = 'frontend.dynamic_elements.day_registered_action'

  initialize: ->
    @$node.on 'click', (e) ->
      if !USER_SIGNED_IN
        $.info t(DynamicElements.AuthorizedAction.I18N_KEY)
        e.stopImmediatePropagation()
        false

      else if !DAY_REGISTERED
        $.info t(I18N_KEY)
        e.stopImmediatePropagation()
        false
