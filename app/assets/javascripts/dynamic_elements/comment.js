import delay from 'delay';
import { flash } from 'shiki-utils';
import { bind } from 'shiki-decorators';

import ShikiEditable from 'views/application/shiki_editable';
import BanForm from 'views/comments/ban_form';

const I18N_KEY = 'frontend.dynamic_elements.comment';

export default class Comment extends ShikiEditable {
  _type() { return 'comment'; }
  _typeLabel() { return I18n.t(`${I18N_KEY}.type_label`); }

  // similar to hash from JsExports::CommentsExport#serialize
  _defaultModel() {
    return {
      can_destroy: false,
      can_edit: false,
      id: parseInt(this.root.id),
      is_viewed: true,
      user_id: this.$root.data('user_id')
    };
  }

  initialize() {
    // data attribute is set in Comments.Tracker
    this.model = this.$root.data('model') || this._defaultModel();

    if (window.SHIKI_USER.isUserIgnored(this.model.user_id)) {
      // node can be not inserted into DOM yet
      if (this.$root.parent().length) {
        this.$root.remove();
      } else {
        delay().then(() => this.$root.remove());
      }
      return;
    }

    this.$body = this.$('.body');
    this.$moderationForm = this.$('.moderation-ban');

    if (this.model && !this.model.is_viewed) { this._activate_appear_marker(); }
    this.$root.one('mouseover', this._deactivateInaccessibleButtons);
    this.$('.item-mobile').one(this._deactivateInaccessibleButtons);

    if (this.$inner.hasClass('check_height')) {
      const $images = this.$body.find('img');
      if ($images.exists()) {
        // картинки могут быть уменьшены image_normalizer'ом,
        // поэтому делаем с задержкой
        $images.imagesLoaded(() => {
          delay(10).then(() => this._check_height());
        });
      } else {
        this._check_height();
      }
    }

    // ответ на комментарий
    this.$('.item-reply').on('click', e => {
      this.$root.trigger('comment:reply', [{
        id: this.root.id,
        type: this._type(),
        text: this.$root.data('user_nickname'),
        url: `/${this._type()}s/${this.root.id}`
      }, this._isOfftopic()]);
    });

    // edit message
    this.$('.main-controls .item-edit')
      .on('ajax:before', this._shade)
      .on('ajax:complete', this._unshade)
      .on('ajax:success', (e, html, _status, _xhr) => {
        const $form = $(html).process();
        $form.find('.b-shiki_editor, .b-shiki_editor-v2').view()
          .editComment(this.$root, $form);
      });

    // moderation
    this.$('.main-controls .item-moderation').on('click', () => {
      this.$('.main-controls').hide();
      return this.$('.moderation-controls').show();
    });

    this.$('.item-offtopic, .item-summary').on('click', this._markOfftopicOrSummary);

    this.$('.item-spoiler, .item-abuse').on('ajax:before', function(e) {
      const reason = prompt($(this).data('reason-prompt'));

      if (reason === null) {
        return false;
      }
      return $(this).data({ form: {
        reason
      }
      });
    });

    // пометка комментария обзором/оффтопиком
    this.$('.item-summary,.item-offtopic,.item-spoiler,.item-abuse,.b-offtopic_marker,.b-summary_marker').on('ajax:success', (e, data, satus, xhr) => {
      if ('affected_ids' in data && data.affected_ids.length) {
        data.affected_ids.forEach(id => $(`.b-comment#${id}`).view()?.mark(data.kind, data.value));
        flash.notice(markerMessage(data));
      } else {
        flash.notice(I18n.t(`${I18N_KEY}.your_request_will_be_considered`));
      }

      return this.$('.item-moderation-cancel').trigger('click');
    });

    // cancel moderation
    this.$('.moderation-controls .item-moderation-cancel').on('click', () =>
      // @$('.main-controls').show()
      // @$('.moderation-controls').hide()
      this._closeAside()
    );

    // кнопка бана или предупреждения
    this.$('.item-ban').on('ajax:success', (e, html) => {
      const form = new BanForm(html);

      this.$moderationForm.html(form.$root).show();
      this._closeAside();
    });

    // закрытие формы бана
    this.$moderationForm.on('click', '.cancel', () => this.$moderationForm.hide());
    this.$moderationForm.on('ajax:success', 'form', this._moderationSubmit);

    // изменение ответов
    this.on('faye:comment:set_replies', (e, data) => {
      this.$('.b-replies').remove();
      return $(data.replies_html).appendTo(this.$body).process();
    });

    // хештег со ссылкой на комментарий
    this.$('.hash').one('mouseover', function() {
      const $node = $(this);
      return $node
        .attr({ href: $node.data('url') })
        .changeTag('a');
    });
  }

  mark(kind, value) {
    this.$(`.item-${kind}`).toggleClass('selected', value);
    this.$(`.b-${kind}_marker`).toggle(value);
  }

  _isOfftopic() {
    return this.$('.b-offtopic_marker').css('display') !== 'none';
  }

  @bind
  _markOfftopicOrSummary({ currentTarget }) {
    const confirmType = currentTarget.classList.contains('selected') ? 'remove' : 'add';
    $(currentTarget).attr('data-confirm', $(currentTarget).data(`confirm-${confirmType}`));
  }

  @bind
  _moderationSubmit(_e, response) {
    this._replace(response.html);
  }

  @bind
  _deactivateInaccessibleButtons() {
    if (!this.model.can_edit) { this.$('.item-edit').addClass('hidden'); }
    if (!this.model.can_destroy) { this.$('.item-delete').addClass('hidden'); }

    if (window.SHIKI_USER.isModerator) {
      this.$('.moderation-controls .item-abuse').addClass('hidden');
      return this.$('.moderation-controls .item-spoiler').addClass('hidden');
    }
    return this.$('.moderation-controls .item-ban').addClass('hidden');
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
};
