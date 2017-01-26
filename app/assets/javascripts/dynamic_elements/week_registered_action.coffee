using 'DynamicElements'
class DynamicElements.WeekRegisteredAction extends View
  I18N_KEY = 'dynamic_elements.week_registered_action'

  initialize: ->
    @$node.on 'click', (e) ->
      if !USER_SIGNED_IN
        $.info t("#{DynamicElements.AuthorizedAction.I18N_KEY}.register_to_complete_action")
        e.stopImmediatePropagation()
        false

      else if !WEEK_REGISTERED
        $.info t("#{I18N_KEY}.action_will_be_available")
        e.stopImmediatePropagation()
        false
