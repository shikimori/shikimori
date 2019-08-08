import ShikiView from 'views/application/shiki_view';
import axios from 'helpers/axios';

export default class Postloaded extends ShikiView {
  async initialize() {
    const { data } = await axios.get(this.$root.data('postloaded-url'));

    this.$root
      .html(data)
      .removeClass('b-ajax')
      .process()
      .trigger('postloaded:success');
  }
}
