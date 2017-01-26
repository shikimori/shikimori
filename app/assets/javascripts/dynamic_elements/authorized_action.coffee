using 'DynamicElements'
class DynamicElements.AuthorizedAction extends View
  @I18N_KEY = 'dynamic_elements.authorized_action'

  initialize: ->
    @$node.on 'click', (e) ->
      if !USER_SIGNED_IN
        $.info t("#{DynamicElements.AuthorizedAction.I18N_KEY}.register_to_complete_action")
        e.stopImmediatePropagation()
        false
