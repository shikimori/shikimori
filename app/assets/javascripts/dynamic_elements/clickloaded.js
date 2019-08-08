import { bind } from 'decko';
import ShikiView from 'views/application/shiki_view';
import axios from 'helpers/axios';

export default class Clickloaded extends ShikiView {
  isLoading = false;

  initialize() {
    this.$root.on('click', this._load);
  }

  @bind
  async _load() {
    if (this.isLoading) { return; }
    this.isLoading = true;

    this.$root.trigger('clickloaded:before');

    this.$root
      .data({ html: this.$root.html() })
      .html(`<div class='ajax-loading vk-like' title='${I18n.t('frontend.blocks.click_loader.loading')}' />`);

    const { data } = await axios.get(this.$root.data('clickloaded-url'));

    this.$root.trigger('clickloaded:success', [data]);
    this.isLoading = false;
  }
}
