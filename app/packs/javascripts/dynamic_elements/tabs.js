import View from '@/views/application/view';

export default class Tabs extends View {
  initialize() {
    this.$tabs = this.$('[data-tab]');
    this.$tabSwitches = this.$('[data-tab-switch]');

    this.$tabSwitches.on('click', ({ currentTarget }) => this._switchTab(currentTarget));
  }

  _switchTab(currentTarget) {
    const tabIndex = this.$tabSwitches.toArray().indexOf(currentTarget);
    const $tab = $(this.$tabs[tabIndex]);

    this.$tabSwitches.removeClass('active');
    currentTarget.classList.add('active');

    this.$tabs.addClass('hidden');
    $tab.removeClass('hidden');

    $tab.process_hidden_content();
  }
}
