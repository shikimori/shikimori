import { bind } from 'decko';
import ShikiView from 'views/application/shiki_view';
import axios from 'helpers/axios';

export default class Clickloaded extends ShikiView {
  isLoading = false;

  initialize() {
    this.$root.on('click', this.fetch);
  }

  @bind
  async fetch() {
    if (this.isLoading) { return; }
    this.isLoading = true;
    const html = this.$root.html();

    this.$root.trigger('clickloaded:before');

    this.$root.html(
      `<div
        class='ajax-loading vk-like'
        title='${I18n.t('frontend.blocks.click_loader.loading')}'
      />`
    );

    const { data } = await axios.get(this.$root.data('clickloaded-url'));

    this.$root.html(html);
    this.$root.trigger('clickloaded:success', [data]);
    this.isLoading = false;
  }
}
