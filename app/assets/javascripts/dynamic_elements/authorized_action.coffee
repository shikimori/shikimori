import View from 'views/application/view'

using 'DynamicElements'
class DynamicElements.AuthorizedAction extends View
  @I18N_KEY = 'frontend.dynamic_elements.authorized_action'

  initialize: ->
    @$node.on 'click', (e) ->
      if !window.SHIKI_USER.isSignedIn
        $.info I18n.t("#{DynamicElements.AuthorizedAction.I18N_KEY}.register_to_complete_action")
        e.stopImmediatePropagation()
        false
