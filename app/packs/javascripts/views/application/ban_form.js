import View from './view';

export default class BanForm extends View {
  initialize() {
    this.$root.on('click', '[data-reason]', this._click);
  }

  _click({ currentTarget }) {
    $(currentTarget)
      .closest('.b-form')
      .find('[name="ban[reason]"]')
      .val($(currentTarget).data('reason'));

    $('.hide-to-spoiler')
      .prop('checked', !!$(currentTarget).data('spoilered-reason'))
      .trigger('change');
  }
}
