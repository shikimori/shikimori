import flash from 'services/flash'
import View from 'views/application/view'

export default class AuthorizedAction extends View
  @I18N_KEY = 'frontend.dynamic_elements.authorized_action'

  initialize: ->
    @$node.on 'click', (e) ->
      if !window.SHIKI_USER.isSignedIn
        flash.info I18n.t("#{AuthorizedAction.I18N_KEY}.register_to_complete_action")
        e.stopImmediatePropagation()
        false
