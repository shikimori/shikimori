import axios from '@/utils/axios';

import View from '@/views/application/view';

export default class Postloaded extends View {
  async initialize() {
    const { data } = await axios.get(this.$root.data('postloaded-url'));

    this.$root
      .html(data)
      .removeClass('b-ajax')
      .process()
      .trigger('postloaded:success');
  }
}
