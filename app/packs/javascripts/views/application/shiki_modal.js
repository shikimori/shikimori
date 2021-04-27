import View from 'views/application/view';

export default class ShikiModal extends View {
  initialize() {
    this.$modal = $('<div class="b-modal"><div class="inner"></div></div>');

    this.$modal
      .find('.inner')
      .append(this.$root)
      .process();

    this.$modal
      .css('top', $(window).scrollTop());
    this.$modal
      .children()
      .css('top', $(window).scrollTop());

    this.$modal.appendTo(document.body);

    this.checkCancel = this._onKeyPress.bind(this);

    $(window).on('keydown', this.checkCancel);
    this.$modal.on('click', '.cancel', () => this.close());
    this._shade();
  }

  close() {
    $(window).off('keydown', this.checkCancel);
    this.$modal.remove();
    this._unshade();
  }

  _shade() {
    $('.b-shade')
      .addClass('active')
      .on('click', () => this.close());
  }

  _unshade() {
    $('.b-shade')
      .removeClass('active')
      .off('click', () => this.close());
  }

  _onKeyPress(e) {
    if (e.keyCode === 27) {
      this.close();
    }
  }
}
