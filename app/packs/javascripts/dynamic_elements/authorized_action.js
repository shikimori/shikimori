import { bind } from 'shiki-decorators';
import { flash } from 'shiki-utils';

import View from '@/views/application/view';

export const I18N_KEY = 'frontend.dynamic_elements.authorized_action';
export class AuthorizedAction extends View {
  initialize() {
    this.$node.on('click', this.onClick);
  }

  @bind
  onClick(e) {
    if (!window.SHIKI_USER.isSignedIn) {
      flash.info(I18n.t(`${I18N_KEY}.register_to_complete_action`));
      e.stopImmediatePropagation();
      e.preventDefault();
    }
  }
}
