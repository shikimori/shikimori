import delay from 'delay';
import { bind } from 'decko';

import ShikiView from 'views/application/shiki_view';
import BanForm from 'views/comments/ban_form';

export default class LogEntry extends ShikiView {
  initialize() {
    this.$moderation = this.$('.moderation');

    this.$('.reject[data-reason-prompt]', this.$moderation)
      .on('click', this._rejectDialog);

    this.$('.ajax-action', this.$moderation)
      .on('ajax:before', this._shade)
      .on('ajax:success', this._reload);

    this.$('.delete', this.$moderation)
      .on('ajax:before', this._shade)
      .on('ajax:success', this._remove);

    this.$('.ban, .warn', this.$moderation)
      .on('ajax:before', this._prepareForm)
      .on('ajax:before', this._shade)
      .on('ajax:complete', this._unshade)
      .on('ajax:success', this._showForm);
  }

  @bind
  _prepareForm() {
    this.$moderation.hide();
    this.$('.spoiler.collapse .action').hide();
  }

  @bind
  _showForm(e, html) {
    const $form = this.$('.ban-form');
    $form.html(html).show();

    new BanForm($form);

    if ($(e.target).hasClass('warn')) {
      $form.find('#ban_duration').val('0m');

      if (this.$root.find('.b-spoiler_marker').length) {
        $form.find('#ban_reason').val('спойлеры');
      }
    }

    // закрытие формы бана
    $('.cancel', $form).on('click', this._hideForm);

    // сабмит формы бана пользователю
    $form
      .on('ajax:before', this._shade)
      .on('ajax:complete', this._unshade)
      .on('ajax:success', this._reload);
  }

  @bind
  _hideForm() {
    this.$moderation.show();
    this.$('.spoiler.collapse .action').show();
    this.$('.ban-form').hide().empty();
    this.$('.spoiler.collapse').click();
  }

  @bind
  async _remove() {
    this.$root.hide();
    await delay(10000);

    // remove must be called later becase
    // "b-tooltipped" tooltip wont disappear otherwise
    this.$root.remove();
  }

  @bind
  _rejectDialog(e) {
    const href = $(e.target).data('href');
    const reason = prompt($(e.target).data('reason-prompt'));

    if (reason == null) {
      e.preventDefault();
      e.stopImmediatePropagation();
      return;
    }

    $(e.target).attr({ href: `${href}?reason=${encodeURIComponent(reason)}` });
  }
}
