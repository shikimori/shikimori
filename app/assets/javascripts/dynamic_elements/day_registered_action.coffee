using 'DynamicElements'
class DynamicElements.DayRegisteredAction extends View
  I18N_KEY = 'dynamic_elements.day_registered_action'

  initialize: ->
    @$node.on 'click', (e) ->
      if !USER_SIGNED_IN
        $.info t("#{DynamicElements.AuthorizedAction.I18N_KEY}.register_to_complete_action")
        e.stopImmediatePropagation()
        false

      else if !DAY_REGISTERED
        $.info t("#{I18N_KEY}.action_will_be_available")
        e.stopImmediatePropagation()
        false
