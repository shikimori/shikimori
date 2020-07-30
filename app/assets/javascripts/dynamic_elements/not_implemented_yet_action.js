import { bind } from 'shiki-decorators';
import { flash } from 'shiki-utils';

import View from 'views/application/view';

const I18N_KEY = 'frontend.dynamic_elements.not_implemented_yet_action';

export default class NotImplementedYetAction extends View {
  initialize() {
    this.$node.on('click', this.onClick);
  }

  @bind
  onClick(e) {
    flash.info(I18n.t(I18N_KEY));
    e.stopImmediatePropagation();
    e.preventDefault();
  }
}
