using 'DynamicElements'
class DynamicElements.WeekRegisteredAction extends View
  I18N_KEY = 'frontend.dynamic_elements.week_registered_action'

  initialize: ->
    @$node.on 'click', (e) ->
      if !SHIKI_USER.isSignedIn
        $.info I18n.t("#{DynamicElements.AuthorizedAction.I18N_KEY}.register_to_complete_action")
        e.stopImmediatePropagation()
        false

      else if !SHIKI_USER.is_week_registered
        $.info I18n.t("#{I18N_KEY}.action_will_be_available")
        e.stopImmediatePropagation()
        false
