import ShikiView from 'views/application/shiki_view';

export default class Tabs extends ShikiView {
  initialize() {
    this.$tabs = this.$('[data-tab]');
    this.$tab_switches = this.$('[data-tab-switch]');

    this.$tab_switches.on('click', ({ currentTarget }) => this._switchTab(currentTarget));
  }

  _switchTab(currentTarget) {
    const tabIndex = this.$tab_switches.toArray().indexOf(currentTarget);

    this.$tab_switches.removeClass('active');
    currentTarget.classList.add('active');

    this.$tabs.addClass('hidden');
    this.$tabs[tabIndex].classList.remove('hidden');
  }
}
