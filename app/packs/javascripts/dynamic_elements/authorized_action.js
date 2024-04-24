import { bind } from 'shiki-decorators';
import { flash } from 'shiki-utils';

import View from '@/views/application/view';
import I18n from '@/utils/i18n';

export const I18N_KEY = 'frontend.dynamic_elements.authorized_action';
export class AuthorizedAction extends View {
  initialize() {
    this.$node.on('click', this.onClick);
  }

  @bind
  onClick(e) {
    if (!window.SHIKI_USER.isSignedIn) {
      flash.info(I18n.t(`${I18N_KEY}.register_to_complete_action`), { escapeMarkup: false });
      e.stopImmediatePropagation();
      e.preventDefault();
    }
  }
}
