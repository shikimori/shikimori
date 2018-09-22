import flash from 'services/flash'

import View from 'views/application/view'
import AuthorizedAction from './authorized_action'

export default class WeekRegisteredAction extends View
  I18N_KEY = 'frontend.dynamic_elements.week_registered_action'

  initialize: ->
    @$node.on 'click', (e) ->
      if !window.SHIKI_USER.isSignedIn
        flash.info I18n.t("#{AuthorizedAction.I18N_KEY}.register_to_complete_action")
        e.stopImmediatePropagation()
        false

      else if !window.SHIKI_USER.isWeekRegistered
        flash.info I18n.t("#{I18N_KEY}.action_will_be_available")
        e.stopImmediatePropagation()
        false
