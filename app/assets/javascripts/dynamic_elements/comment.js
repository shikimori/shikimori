import delay from 'delay';
import { flash } from 'shiki-utils';
import { bind } from 'shiki-decorators';

import ShikiEditable from 'views/application/shiki_editable';
import BanForm from 'views/comments/ban_form';

const I18N_KEY = 'frontend.dynamic_elements.comment';

export default class Comment extends ShikiEditable {
  _type() { return 'comment'; }
  _type_label() { return I18n.t(`${I18N_KEY}.type_label`); }

  // similar to hash from JsExports::CommentsExport#serialize
  _default_model() {
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
    this.model = this.$root.data('model') || this._default_model();

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

    if (this.model && !this.model.is_viewed) { this._activate_appear_marker(); }
    this.$root.one('mouseover', this._deactivate_inaccessible_buttons);
    this.$('.item-mobile').one(this._deactivate_inaccessible_buttons);

    if (this.$inner.hasClass('check_height')) {
      const $images = this.$body.find('img');
      if ($images.exists()) {
        // картинки могут быть уменьшены image_normalizer'ом,
        // поэтому делаем с задержкой
        $images.imagesLoaded(() => {
          return delay(10).then(() => this._check_height());
        });
      } else {
        this._check_height();
      }
    }

    // ответ на комментарий
    this.$('.item-reply').on('click', e => {
      return this.$root.trigger('comment:reply', [{
        id: this.root.id,
        type: this._type(),
        text: this.$root.data('user_nickname'),
        url: `/${this._type()}s/${this.root.id}`
      }, this._is_offtopic()]);
  });

    // edit message
    this.$('.main-controls .item-edit')
      .on('ajax:before', this._shade)
      .on('ajax:complete', this._unshade)
      .on('ajax:success', (e, html, status, xhr) => {
        const $form = $(html).process();
        return $form.find('.b-shiki_editor, .b-shiki_editor-v2').view()
          .editComment(this.$root, $form);
    });

    // moderation
    this.$('.main-controls .item-moderation').on('click', () => {
      this.$('.main-controls').hide();
      return this.$('.moderation-controls').show();
    });

    this.$('.item-offtopic, .item-summary').on('click', function(e) {
      const confirm_type = this.classList.contains('selected') ? 'remove' : 'add';
      return $(this).attr('data-confirm', $(this).data(`confirm-${confirm_type}`));
    });

    this.$('.item-spoiler, .item-abuse').on('ajax:before', function(e) {
      const reason = prompt($(this).data('reason-prompt'));

      if (reason === null) {
        return false;
      } else {
        return $(this).data({form: {
          reason
        }
        });
      }
    });

    // пометка комментария обзором/оффтопиком
    this.$('.item-summary,.item-offtopic,.item-spoiler,.item-abuse,.b-offtopic_marker,.b-summary_marker').on('ajax:success', (e, data, satus, xhr) => {
      if ('affected_ids' in data && data.affected_ids.length) {
        data.affected_ids.forEach(id => $(`.b-comment#${id}`).view()?.mark(data.kind, data.value));
        flash.notice(marker_message(data));
      } else {
        flash.notice(I18n.t(`${I18N_KEY}.your_request_will_be_considered`));
      }

      return this.$('.item-moderation-cancel').trigger('click');
    });

    // cancel moderation
    this.$('.moderation-controls .item-moderation-cancel').on('click', () => {
      //@$('.main-controls').show()
      //@$('.moderation-controls').hide()
      return this._close_aside();
    });

    // кнопка бана или предупреждения
    this.$('.item-ban').on('ajax:success', (e, html) => {
      const form = new BanForm(html);

      this.$('.moderation-ban').html(form.$root).show();
      return this._close_aside();
    });

    // закрытие формы бана
    this.$('.moderation-ban').on('click', '.cancel', () => {
      return this.$('.moderation-ban').hide();
    });

    // сабмит формы бана
    this.$('.moderation-ban').on('ajax:success', 'form', (e, response) => {
      return this._replace(response.html);
    });

    // изменение ответов
    this.on('faye:comment:set_replies', (e, data) => {
      this.$('.b-replies').remove();
      return $(data.replies_html).appendTo(this.$body).process();
    });

    // хештег со ссылкой на комментарий
    return this.$('.hash').one('mouseover', function() {
      const $node = $(this);
      return $node
        .attr({href: $node.data('url')})
        .changeTag('a');
    });
  }

  mark(kind, value) {
    this.$(`.item-${kind}`).toggleClass('selected', value);
    return this.$(`.b-${kind}_marker`).toggle(value);
  }

  _is_offtopic() {
    return this.$('.b-offtopic_marker').css('display') !== 'none';
  }

  @bind
  _deactivate_inaccessible_buttons() {
    if (!this.model.can_edit) { this.$('.item-edit').addClass('hidden'); }
    if (!this.model.can_destroy) { this.$('.item-delete').addClass('hidden'); }

    if (window.SHIKI_USER.isModerator) {
      this.$('.moderation-controls .item-abuse').addClass('hidden');
      return this.$('.moderation-controls .item-spoiler').addClass('hidden');
    } else {
      return this.$('.moderation-controls .item-ban').addClass('hidden');
    }
  }
}

// текст сообщения, отображаемый при изменении маркера
var marker_message = function(data) {
  if (data.value) {
    if (data.kind === 'offtopic') {
      if (data.affected_ids.length > 1) {
        return flash.notice(I18n.t(`${I18N_KEY}.comments_marked_as_offtopic`));
      } else {
        return flash.notice(I18n.t(`${I18N_KEY}.comment_marked_as_offtopic`));
      }
    } else {
      return flash.notice(I18n.t(`${I18N_KEY}.comment_marked_as_summary`));
    }

  } else {
    if (data.kind === 'offtopic') {
      return flash.notice(I18n.t(`${I18N_KEY}.comment_not_marked_as_offtopic`));
    } else {
      return flash.notice(I18n.t(`${I18N_KEY}.comment_not_marked_as_summary`));
    }
  }
};
