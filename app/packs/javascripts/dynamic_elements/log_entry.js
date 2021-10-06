import delay from 'delay';
import { bind } from 'shiki-decorators';

import ShikiView from '@/views/application/shiki_view';
import BanForm from '@/views/application/ban_form';

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

    this.$root.children('.spoiler.collapse').one('click', this._processDiffs);
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

    $(e.target).attr('href', `${href}?reason=${encodeURIComponent(reason)}`);
  }

  @bind
  _processDiffs() {
    this.$('.field-changes .diff').each(async (_index, node) => {
      const $diff = $(node);
      const { default: DiffMatchPatch } =
        await import(/* webpackChunkName: "diff-match-patch" */ 'diff-match-patch');

      const $diffValue = $diff.find('.value');
      const oldValue = $diffValue.data('old_value');
      const newValue = $diffValue.data('new_value');

      const dmp = new DiffMatchPatch();
      const diff = dmp.diff_main(
        Object.isString(oldValue) ? oldValue : JSON.stringify(oldValue),
        Object.isString(newValue) ? newValue : JSON.stringify(newValue)
      );

      // dmp.Diff_EditCost = 4;
      // dmp.diff_cleanupEfficiency(diff);
      dmp.diff_cleanupSemantic(diff);

      $diffValue.html(
        dmp.diff_prettyHtml(diff).replace(/&para;/g, '')
      );
    });
  }
}
