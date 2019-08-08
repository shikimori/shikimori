import { bind } from 'decko';
import ShikiView from 'views/application/shiki_view';
import axios from 'helpers/axios';

export default class Clickloaded extends ShikiView {
  initialize() {
    this.$root.on('click', this._load);
  }

  @bind
  async _load() {
    if (this.$root.data('locked')) { return; }

    this.$root.data({ locked: true });
    // this.$root.trigger('ajax:before');

    this.$root
      .data({ html: this.$root.html() })
      .html(`<div class='ajax-loading vk-like' title='${I18n.t('frontend.blocks.click_loader.loading')}' />`);

    const { data } = await axios.get(this.$root.data('clickloaded-url'));

    this.$root.data({ locked: false });
    this.$root.trigger('clickloaded:success', [data]);
  }
}
