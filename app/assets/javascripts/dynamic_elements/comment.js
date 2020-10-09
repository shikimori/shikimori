import delay from 'delay';
import { flash } from 'shiki-utils';
import { bind } from 'shiki-decorators';

import ShikiEditable from 'views/application/shiki_editable';
import BanForm from 'views/comments/ban_form';

const I18N_KEY = 'frontend.dynamic_elements.comment';

const AJAX_BUTTONS = [
  '.item-summary',
  '.item-offtopic',
  '.item-spoiler',
  '.item-abuse',
  '.b-offtopic_marker',
  '.b-summary_marker'
];

export default class Comment extends ShikiEditable {
  _type() { return 'comment'; }
  _typeLabel() { return I18n.t(`${I18N_KEY}.type_label`); }

  // similar to hash from JsExports::CommentsExport#serialize
  _defaultModel() {
    return {
      can_destroy: false,
      can_edit: false,
      id: parseInt(this.node.id),
      is_viewed: true,
      user_id: this.$node.data('user_id')
    };
  }

  initialize() {
    // data attribute is set in Comments.Tracker
    this.model = this.$node.data('model') || this._defaultModel();

    if (window.SHIKI_USER.isUserIgnored(this.model.user_id)) {
      // node can be not inserted into DOM yet
      if (this.$node.parent().length) {
        this.$node.remove();
      } else {
        delay().then(() => this.$node.remove());
      }
      return;
    }

    this.$body = this.$('.body');
    this.$moderationForm = this.$('.moderation-ban');

    if (this.model && !this.model.is_viewed) {
      this._activateAppearMarker();
    }

    if (this.$inner.hasClass('check_height')) {
      const $images = this.$body.find('img');

      if ($images.exists()) {
        // картинки могут быть уменьшены image_normalizer'ом, поэтому делаем с задержкой
        $images.imagesLoaded(() => {
          delay(10).then(() => this._checkHeight());
        });
      } else {
        this._checkHeight();
      }
    }

    this.$node.one('mouseover', this._deactivateInaccessibleButtons);
    this.$('.item-mobile').one(this._deactivateInaccessibleButtons);
    this.$('.item-reply').on('click', this._commentReply);

    this.$('.main-controls .item-edit')
      .on('ajax:before', this._shade)
      .on('ajax:complete', this._unshade)
      .on('ajax:success', this._edit);

    this.$('.item-offtopic, .item-summary').on('click', this._markOfftopicOrSummary);
    this.$('.item-spoiler, .item-abuse').on('ajax:before', this._markSpoilerOrAbuse);

    this.$(AJAX_BUTTONS.join(',')).on('ajax:success', this._processAjaxControlRequest);

    this.$('.main-controls .item-moderation').on('click', this._showModrationControls);
    this.$('.moderation-controls .item-moderation-cancel')
      .on('click', this._hideModerationControls);

    this.$('.item-ban').on('ajax:success', this._showModerationForm);
    this.$moderationForm.on('click', '.cancel', this._hideModerationForm);
    this.$moderationForm.on('ajax:success', 'form', this._processModerationRequest);

    this.on('faye:comment:set_replies', this._fayeSetReplies);

    this.$('.hash').one('mouseover', this._replaceHashWithLink);
  }

  mark(kind, value) {
    this.$(`.item-${kind}`).toggleClass('selected', value);
    this.$(`.b-${kind}_marker`).toggle(value);
  }

  _isOfftopic() {
    return this.$('.b-offtopic_marker').css('display') !== 'none';
  }

  @bind
  _edit(_e, html, _status, _xhr) {
    const $form = $(html).process();

    $form.find('.b-shiki_editor, .b-shiki_editor-v2').view()
      .editComment(this.$node, $form);
  }

  @bind
  _commentReply() {
    const reply = {
      id: this.node.id,
      type: this._type(),
      text: this.$node.data('user_nickname'),
      url: `/${this._type()}s/${this.node.id}`
    };

    this.$node.trigger('comment:reply', [reply, this._isOfftopic()]);
  }

  @bind
  _markOfftopicOrSummary({ currentTarget }) {
    const confirmType = currentTarget.classList.contains('selected') ?
      'remove' :
      'add';

    $(currentTarget).attr(
      'data-confirm',
      $(currentTarget).data(`confirm-${confirmType}`)
    );
  }

  @bind
  _markSpoilerOrAbuse({ currentTarget }) {
    const reason = prompt($(currentTarget).data('reason-prompt'));

    // return value grabbed by triggerAndReturn in rauils_ujs
    if (reason == null) { return false; }

    $(currentTarget).data({ form: { reason } });
    return true;
  }

  @bind
  _showModrationControls() {
    this.$('.main-controls').hide();
    this.$('.moderation-controls').show();
  }

  @bind
  _hideModerationControls() {
    this._closeAside();
  }

  @bind
  _showModerationForm(e, html) {
    const form = new BanForm(html);

    this.$moderationForm.html(form.$root).show();
    this._closeAside();
  }

  @bind
  _hideModerationForm() {
    this.$moderationForm.hide();
  }

  @bind
  _processModerationRequest(_e, response) {
    this._replace(response.html);
  }

  @bind
  _processAjaxControlRequest(_e, data) {
    if ('affected_ids' in data && data.affected_ids.length) {
      data.affected_ids.forEach(id => (
        $(`.b-comment#${id}`).view()?.mark(data.kind, data.value)
      ));
      flash.notice(markerMessage(data));
    } else {
      flash.notice(I18n.t(`${I18N_KEY}.your_request_will_be_considered`));
    }

    this._hideModerationControls();
  }

  @bind
  _fayeSetReplies(_e, data) {
    this.$('.b-replies').remove();
    $(data.replies_html).appendTo(this.$body).process();
  }

  @bind
  _deactivateInaccessibleButtons() {
    if (!this.model.can_edit) { this.$('.item-edit').addClass('hidden'); }
    if (!this.model.can_destroy) { this.$('.item-delete').addClass('hidden'); }

    if (window.SHIKI_USER.isModerator) {
      this.$('.moderation-controls .item-abuse').addClass('hidden');
      this.$('.moderation-controls .item-spoiler').addClass('hidden');
    } else {
      this.$('.moderation-controls .item-ban').addClass('hidden');
    }
  }

  @bind
  _replaceHashWithLink({ currentTarget }) {
    const $node = $(currentTarget);

    $node
      .attr('href', $node.data('url'))
      .changeTag('a');
  }
}

function markerMessage(data) {
  if (data.value) {
    if (data.kind === 'offtopic') {
      if (data.affected_ids.length > 1) {
        return flash.notice(I18n.t(`${I18N_KEY}.comments_marked_as_offtopic`));
      }
      return flash.notice(I18n.t(`${I18N_KEY}.comment_marked_as_offtopic`));
    }
    return flash.notice(I18n.t(`${I18N_KEY}.comment_marked_as_summary`));
  }
  if (data.kind === 'offtopic') {
    return flash.notice(I18n.t(`${I18N_KEY}.comment_not_marked_as_offtopic`));
  }
  return flash.notice(I18n.t(`${I18N_KEY}.comment_not_marked_as_summary`));
}
