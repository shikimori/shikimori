using 'DynamicElements'
class DynamicElements.DayRegisteredAction extends View
  I18N_KEY = 'frontend.dynamic_elements.day_registered_action'

  initialize: ->
    @$node.on 'click', (e) ->
      if !USER_SIGNED_IN
        $.info I18n.t("#{DynamicElements.AuthorizedAction.I18N_KEY}.register_to_complete_action")
        e.stopImmediatePropagation()
        false

      else if !DAY_REGISTERED
        $.info I18n.t("#{I18N_KEY}.action_will_be_available")
        e.stopImmediatePropagation()
        false
