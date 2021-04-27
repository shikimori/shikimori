import { bind } from 'shiki-decorators';
import { flash } from 'shiki-utils';

import View from 'views/application/view';
import * as AuthorizedAction from './authorized_action';

const I18N_KEY = 'frontend.dynamic_elements.day_registered_action';

export default class DayRegisteredAction extends View {
  initialize() {
    this.$node.on('click', this.onClick);
  }

  @bind
  onClick(e) {
    if (!window.SHIKI_USER.isSignedIn) {
      flash.info(I18n.t(`${AuthorizedAction.I18N_KEY}.register_to_complete_action`));
      e.stopImmediatePropagation();
      e.preventDefault();
    } else if (!window.SHIKI_USER.isDayRegistered) {
      flash.info(I18n.t(`${I18N_KEY}.action_will_be_available`));
      e.stopImmediatePropagation();
      e.preventDefault();
    }
  }
}
