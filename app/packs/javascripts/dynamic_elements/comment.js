import delay from 'delay';
import { flash, isPhone } from 'shiki-utils';
import { bind } from 'shiki-decorators';

import ShikiEditable from '@/views/application/shiki_editable';
import { loadImagesFinally, imagePromiseFinally } from '@/utils/load_image';

const I18N_KEY = 'frontend.dynamic_elements.comment';

export default class Comment extends ShikiEditable {
  initialize() {
    const mobileOffset = isPhone() ? -25 : 0;
    this.CHECK_HEIGHT_PLACEHOLDER_HEIGHT = 140 + mobileOffset;

    // data attribute is set in Comments.Tracker
    this.model = this.$node.data('model') || this.defaultModel;

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
    if (this.model && !this.model.is_viewed) { this._activateAppearMarker(); }
    this._scheduleCheckHeight();

    this.$('.hash').one('mouseover', this._replaceHashWithLink);
  }

  // similar to hash from JsExports::CommentsExport#serialize
  get defaultModel() {
    return {
      can_destroy: false,
      can_edit: false,
      id: parseInt(this.node.id),
      is_viewed: true,
      user_id: this.$node.data('user_id')
    };
  }
  get type() { return 'comment'; }
  get typeLabel() { return I18n.t(`${I18N_KEY}.type_label`); }

  _bindAbuseRequestControls() {
    super._bindAbuseRequestControls();
    this.$('.item-offtopic').on('click', this._markOfftopic);
  }

  _bindFaye() {
    super._bindFaye();
    this.on('faye:comment:set_replies', this._fayeSetReplies);
    this.on('faye:comment:converted', this._fayeConverted);
  }

  mark(kind, value) {
    this.$(`.item-${kind}`).toggleClass('selected', value);
    this.$(`.b-${kind}_marker`).toggle(value);
  }

  _isOfftopic() {
    return this.$('.b-offtopic_marker').css('display') !== 'none';
  }

  @bind
  _processAbuseRequest(e, data) {
    if ('affected_ids' in data && data.affected_ids.length) {
      data.affected_ids.forEach(id => (
        $(`.b-comment#${id}`).view()?.mark(data.kind, data.value)
      ));
      flash.notice(markerMessage(data));
      super._processAbuseRequest(e, data, false)
    } else {
      super._processAbuseRequest(e, data)
    }
  }

  @bind
  _markOfftopic({ currentTarget }) {
    const confirmType = currentTarget.classList.contains('selected') ?
      'remove' :
      'add';

    $(currentTarget).attr(
      'data-confirm',
      $(currentTarget).data(`confirm-${confirmType}`)
    );
  }

  @bind
  _fayeSetReplies(_e, data) {
    this.$('.b-replies').remove();
    $(data.replies_html).appendTo(this.$body).process();
  }

  @bind
  _fayeConverted(_e, data) {
    const message = I18n.t('frontend.shiki_editable.comment_converted', {
      url: `/reviews/${data.review_id}`
    });

    this._replace(
      `<div class='b-comment-info b-${this.type}'><span>${message}</span>` +
      `<a class='b-user16' href='/${data.actor}'><img src='${data.actor_avatar}' ` +
      `srcset='${data.actor_avatar_2x} 2x' /><span>${data.actor}</span></a></div>`
    );

    return false; // очень важно! иначе эвенты зациклятся из-за такого же обработчика в родителе
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
  let messageKey = I18n.t('not_marked_as_summary');

  if (data.value) {
    if (data.kind === 'offtopic') {
      if (data.affected_ids.length > 1) {
        messageKey = 'multiple_marked_as_offtopic';
      } else {
        messageKey = 'marked_as_offtopic';
      }
    } else {
      messageKey = 'marked_as_summary';
    }
  } else if (data.kind === 'offtopic') {
    messageKey = 'not_marked_as_offtopic';
  }

  return flash.notice(
    I18n.t(`${I18N_KEY}.${messageKey}`)
  );
}
