import View from '@/views/application/view';

export default class Switcher extends View {
  initialize() {
    const switcher = this.$root.data('switcher');

    this.on('click', () => {
      $(`.active[data-switcher="${switcher}"]`).removeClass('active');
      this.$root.addClass('active');
    });
  }
}
