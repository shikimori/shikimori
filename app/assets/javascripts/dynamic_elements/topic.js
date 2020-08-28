import delay from 'delay';
import { bind } from 'shiki-decorators';

import ShikiEditable from 'views/application/shiki_editable';
import ShikiEditor from 'views/shiki_editor';
import { ShikiGallery } from 'views/application/shiki_gallery';

import axios from 'helpers/axios';
import { animatedCollapse, animatedExpand } from 'helpers/animated';

const I18N_KEY = 'frontend.dynamic_elements.topic';
const FAYE_EVENTS = [
  'faye:comment:updated',
  'faye:message:updated',
  'faye:comment:deleted',
  'faye:message:deleted',
  'faye:comment:set_replies'
];
const SHOW_IGNORED_TOPICS_IN = [
  'topics_show',
  'collections_show'
];

// TODO: move code related to comments to separate class
export default class Topic extends ShikiEditable {
  _type() { return 'topic'; }
  _type_label() { // eslint-disable-line camelcase
    return I18n.t(`${I18N_KEY}.type_label`);
  }

  // similar to hash from JsExports::TopicsExport#serialize
  _default_model() { // eslint-disable-line camelcase
    return {
      can_destroy: false,
      can_edit: false,
      id: parseInt(this.root.id),
      is_viewed: true,
      user_id: this.$root.data('user_id')
    };
  }

  initialize() {
    // data attribute is set in Topics.Tracker
    this.model = this.$root.data('model') || this._default_model();

    if (window.SHIKI_USER.isUserIgnored(this.model.user_id) ||
        window.SHIKI_USER.isTopicIgnored(this.model.id)) {
      if (SHOW_IGNORED_TOPICS_IN.includes(document.body.id)) {
        this._toggle_ignored(true);
      } else {
        // node can be not inserted into DOM yet
        if (this.$root.parent().length) {
          this.$root.remove();
        } else {
          delay().then(() => this.$root.remove());
        }
        return;
      }
    }

    this.$body = this.$inner.children('.body');

    this.$editor_container = this.$('.editor-container');
    this.$editor = this.$('.b-shiki_editor');

    if (window.SHIKI_USER.isSignedIn && window.SHIKI_USER.isDayRegistered && this.$editor.length) {
      this.editor = new ShikiEditor(this.$editor);
    } else {
      this.$editor.replaceWith(
        `<div class='b-nothing_here'> \
${I18n.t('frontend.shiki_editor.not_available')} \
</div>`
      );
    }

    this.$comments_loader = this.$('.comments-loader');
    this.$comments_hider = this.$('.comments-hider');
    this.$comments_collapser = this.$('.comments-collapser');
    this.$comments_expander = this.$('.comments-expander');

    this.is_preview = this.$root.hasClass('b-topic-preview');
    this.is_cosplay = this.$root.hasClass('b-cosplay-topic');
    this.is_club_page = this.$root.hasClass('b-club_page-topic');
    this.is_review = this.$root.hasClass('b-review-topic');

    if (this.model && !this.model.is_viewed) { this._activate_appear_marker(); }
    if (this.model) { this._actualize_voting(); }

    this.$inner.one('mouseover', this._deactivate_inaccessible_buttons);
    $('.item-mobile', this.$inner).one(this._deactivate_inaccessible_buttons);

    if (this.is_preview || this.is_club_page) {
      this.$body.imagesLoaded(this._check_height);
      this._check_height();
    }

    if (this.is_cosplay && !this.is_preview) {
      new ShikiGallery(this.$('.b-cosplay_gallery .b-gallery'));
    }

    // ответ на топик
    $('.item-reply', this.$inner).on('click', () => {
      const reply = this.$root.data('generated') ?
        '' :
        `[entry=${this.$root.attr('id')}]${this.$root.data('user_nickname')}[/entry], `;

      return this.$root.trigger('comment:reply', [reply]);
    });

    this.$editor
      .on('ajax:success', (e, response) => {
        const $new_comment = $(response.html).process(response.JS_EXPORTS);

        this.$('.b-comments').find('.b-nothing_here').remove();
        if (this.$editor.is(':last-child')) {
          this.$('.b-comments').append($new_comment);
        } else {
          this.$('.b-comments').prepend($new_comment);
        }

        $new_comment.yellowFade();

        this.editor.cleanup();
        return this._hide_editor();
      });

    $('.item-ignore', this.$inner)
      .on('ajax:before', function () {
        return $(this).toggleClass('selected');
      }).on('ajax:success', (e, result) => {
        if (result.is_ignored) {
          window.SHIKI_USER.ignoreTopic(result.topic_id);
        } else {
          window.SHIKI_USER.unignoreTopic(result.topic_id);
        }

        return this._toggle_ignored(result.is_ignored);
      });

    // голосование за/против рецензии
    this.$('.footer-vote .vote').on('ajax:before', e => {
      this.$inner.find('.footer-vote').addClass('b-ajax');
      const is_yes = $(e.target).hasClass('yes');

      if (is_yes && !this.model.voted_yes) {
        this.model.votes_for += 1;
        if (this.model.voted_no) { this.model.votes_against -= 1; }
      } else if (!is_yes && !this.model.voted_no) {
        if (this.model.voted_yes) { this.model.votes_for -= 1; }
        this.model.votes_against += 1;
      }

      this.model.voted_no = !is_yes;
      this.model.voted_yes = is_yes;

      return this._actualize_voting();
    });

    this.$('.footer-vote .vote').on('ajax:complete', function () {
      return $(this).closest('.footer-vote').removeClass('b-ajax');
    });

    // прочтение комментриев
    this.on('appear', this._appear);

    // ответ на комментарий
    this.on('comment:reply', (e, text, is_offtopic) => {
      // @editor is empty for unauthorized user
      if (this.editor) {
        this._show_editor();
        return this.editor.replyComment(text, is_offtopic);
      }
    });

    // клик скрытию редактора
    this.$('.b-shiki_editor').on('click', '.hide', this._hide_editor);

    // delegated handlers becase it is replaced on postload in
    // inherited classes (FullDialog)
    this.on('clickloaded:before', '.comments-loader', this._before_comments_clickload);
    this.on('clickloaded:success', '.comments-loader', this._comments_clickloaded);
    this.on('click', '.comments-loader', e => {
      if (this.$comments_loader.data('dynamic') !== 'clickloaded') {
        this.$comments_loader.addClass('hidden');
        this.$('.comments-loaded').each((_index, node) => animatedExpand(node));
        return this.$comments_hider.show();
      }
    });

    // hide loaded comments
    this.$comments_collapser.on('click', e => {
      this.$comments_collapser.addClass('hidden');
      this.$comments_loader.addClass('hidden');
      this.$comments_expander.show();
      return this.$('.comments-loaded').each((_index, node) => animatedCollapse(node));
    });

    // скрытие комментариев
    this.$comments_hider.on('click', () => {
      this.$comments_hider.hide();
      this.$('.comments-loaded').each((_index, node) => animatedCollapse(node));
      return this.$comments_expander.show();
    });

    // разворачивание комментариев
    this.$comments_expander.on('click', e => {
      this.$comments_expander.hide();
      this.$('.comments-loaded').each((_index, node) => animatedExpand(node));

      if (this.$comments_loader) {
        this.$comments_loader.removeClass('hidden');
        return this.$comments_collapser.removeClass('hidden');
      }
      return this.$comments_hider.show();
    });

    // realtime обновления
    // изменение / удаление комментария
    this.on(FAYE_EVENTS.join(' '), (e, data) => {
      e.stopImmediatePropagation();
      const trackable_type = e.type.match(/comment|message/)[0];
      const trackable_id = data[`${trackable_type}_id`];

      if (e.target === this.$root[0]) {
        return this.$(`.b-${trackable_type}#${trackable_id}`).trigger(e.type, data);
      }
    });

    // добавление комментария
    this.on('faye:comment:created faye:message:created', (e, data) => {
      e.stopImmediatePropagation();
      const trackable_type = e.type.match(/comment|message/)[0];
      const trackable_id = data[`${trackable_type}_id`];

      if (this.$(`.b-${trackable_type}#${trackable_id}`).exists()) { return; }
      const $placeholder = this._faye_placeholder(trackable_id, trackable_type);

      // уведомление о добавленном элементе через faye
      $(document.body).trigger('faye:added');
      if (window.SHIKI_USER.isCommentsAutoLoaded) {
        if ($placeholder.is(':appeared') && !$('textarea:focus').val()) {
          return $placeholder.click();
        }
      }
    });

    // изменение метки комментария
    return this.on('faye:comment:marked', (e, data) => {
      e.stopImmediatePropagation();
      return $(`.b-comment#${data.comment_id}`).view().mark(data.mark_kind, data.mark_value);
    });
  }

  // переключение топика в режим игнора/не_игнора
  _toggle_ignored(is_ignored) {
    $('.item-ignore', this.$inner)
      .toggleClass('selected', is_ignored)
      .data({ method: is_ignored ? 'DELETE' : 'POST' });
    return this.$('.b-anime_status_tag.ignored').toggleClass('hidden', !is_ignored);
  }

  // удаляем уже имеющиеся подгруженные элементы
  _filter_present_entries($comments) {
    const filter = 'b-comment';
    const present_ids = $(`.${filter}`, this.$root)
      .toArray()
      .map(v => v.id)
      .filter(v => v);

    const exclude_selector = present_ids.map(id => `.${filter}#${id}`).join(',');

    return $comments.children().filter(exclude_selector).remove();
  }

  // отображение редактора, если это превью топика
  _show_editor() {
    if (this.is_preview && !this.$editor_container.is(':visible')) {
      return this.$editor_container.show();// animatedExpand()
    }
  }

  // скрытие редактора, если это превью топика
  @bind
  _hide_editor() {
    if (this.is_preview) {
      return this.$editor_container.hide();// animatedCollapse()
    }
  }

  // получение плейсхолдера для подгрузки новых комментариев
  _faye_placeholder(trackable_id, trackable_type) {
    this.$('.b-comments .b-nothing_here').remove();
    let $placeholder = this.$('.b-comments .faye-loader');

    if (!$placeholder.exists()) {
      $placeholder = $('\
<div class="faye-loader to-process" data-dynamic="clickloaded"></div>\
')
        .appendTo(this.$('.b-comments'))
        .data({ ids: [] })
        .process()
        .on('clickloaded:success', (e, data) => {
          const $html = $(data.content).process(data.JS_EXPORTS);
          $placeholder.replaceWith($html);

          return $html.process();
        });
    }

    if (__guard__($placeholder.data('ids'), x => x.indexOf(trackable_id)) === -1) {
      $placeholder.data({
        ids: $placeholder.data('ids').add(trackable_id) });
      $placeholder.data({
        'clickloaded-url': `/${trackable_type}s/chosen/${$placeholder.data('ids').join(',')}` });

      const num = $placeholder.data('ids').length;

      $placeholder.html(trackable_type === 'message' ?
        p(num,
          I18n.t(`${I18N_KEY}.new_message_added.one`, { count: num }),
          I18n.t(`${I18N_KEY}.new_message_added.few`, { count: num }),
          I18n.t(`${I18N_KEY}.new_message_added.many`, { count: num })) :
        p(num,
          I18n.t(`${I18N_KEY}.new_comment_added.one`, { count: num }),
          I18n.t(`${I18N_KEY}.new_comment_added.few`, { count: num }),
          I18n.t(`${I18N_KEY}.new_comment_added.many`, { count: num }))
      );
    }

    return $placeholder;
  }

  // handlers
  _appear(e, $appeared, by_click) {
    const $filtered_appeared = $appeared.not(function () {
      return $(this).data('disabled') || !(
        this.classList.contains('b-appear_marker') &&
          this.classList.contains('active')
      );
    });
    if (!$filtered_appeared.exists()) { return; }

    const interval = by_click ? 1 : 1500;
    const $objects = $filtered_appeared.closest('.shiki-object');
    const $markers = $objects.find('.b-new_marker.active');
    const ids = $objects
      .map(function () {
        const $object = $(this);
        const item_type = $object.data('appear_type');
        return `${item_type}-${this.id}`;
      }).toArray();

    axios.post(
      $markers.data('appear_url'),
      { ids: ids.join(',') }
    );

    $filtered_appeared.remove();

    if ($markers.data('reappear')) {
      return $markers.addClass('off');
    }
    return delay(interval).then(() => {
      $markers.css({ opacity: 0 });

      return delay(500).then(() => {
        $markers.hide();
        return $markers.removeClass('active');
      });
    });
  }

  @bind
  _before_comments_clickload(e) {
    const new_url = this.$comments_loader
      .data('clickloaded-url-template')
      .replace('SKIP', this.$comments_loader.data('skip'));

    return this.$comments_loader.data({ 'clickloaded-url': new_url });
  }

  @bind
  _comments_clickloaded(e, data) {
    const $new_comments = $('<div class=\'comments-loaded\'></div>').html(data.content);

    this._filter_present_entries($new_comments);

    $new_comments
      .process(data.JS_EXPORTS)
      .insertAfter(this.$comments_loader);

    animatedExpand($new_comments[0]);

    return this._update_comments_loader(data);
  }

  // private functions
  // проверка высоты топика. урезание,
  // если текст слишком длинный (точно такой же код в shiki_comment)
  @bind
  _check_height() {
    if (this.is_review) {
      const image_height = this.$('.review-entry_cover img').height();
      const read_more_height = 13 + 5; // 5px - read_more offset

      if (image_height > 0) {
        return this.$('.body-truncated-inner').checkHeight({
          max_height: image_height - read_more_height,
          collapsed_height: image_height - read_more_height,
          expand_html: ''
        });
      }
    } else {
      return this.$('.body-inner').checkHeight({
        max_height: this.MAX_PREVIEW_HEIGHT,
        collapsed_height: this.COLLAPSED_HEIGHT
      });
    }
  }

  @bind
  _reload_url() {
    return `/${this._type()}s/${this.$root.attr('id')}/reload?is_preview=${this.is_preview}`;
  }

  _actualize_voting() {
    this.$inner
      .find('.footer-vote .vote.yes, .user-vote .voted-for')
      .toggleClass('selected', this.model.voted_yes);

    this.$inner
      .find('.footer-vote .vote.no, .user-vote .voted-against')
      .toggleClass('selected', this.model.voted_no);

    if (this.model.votes_for) {
      this.$inner.find('.votes-for').html(`${this.model.votes_for}`);
    }

    if (this.model.votes_against) {
      return this.$inner.find('.votes-against').html(`${this.model.votes_against}`);
    }
  }

  // скрытие действий, на которые у пользователя нет прав
  @bind
  _deactivate_inaccessible_buttons() {
    if (!this.model.can_edit) { this.$inner.find('.item-edit').addClass('hidden'); }
    if (!this.model.can_destroy) { return this.$inner.find('.item-delete').addClass('hidden'); }
  }

  // data is used in inherited classes (FullDialog)
  _update_comments_loader(data) {
    const limit = this.$comments_loader.data('limit');
    const count = this.$comments_loader.data('count') - limit;

    if (count > 0) {
      this.$comments_loader.data({
        skip: this.$comments_loader.data('skip') + limit,
        count
      });

      const comment_count = Math.min(limit, count);
      const comment_word =
        this.$comments_loader.data('only-summaries-shown') ?
          p(comment_count,
            I18n.t(`${I18N_KEY}.summary.one`),
            I18n.t(`${I18N_KEY}.summary.few`),
            I18n.t(`${I18N_KEY}.summary.many`)) :
          p(comment_count,
            I18n.t(`${I18N_KEY}.comment.one`),
            I18n.t(`${I18N_KEY}.comment.few`),
            I18n.t(`${I18N_KEY}.comment.many`));
      const of_total_comments =
        count > limit ?
          `${I18n.t(`${I18N_KEY}.of`)} ${count}` :
          '';

      const load_comments = I18n.t(
        `${I18N_KEY}.load_comments`, {
          comment_count,
          of_total_comments,
          comment_word
        }
      );

      this.$comments_loader.html(load_comments);
      return this.$comments_collapser.removeClass('hidden');
    }
    this.$comments_loader.remove();
    this.$comments_loader = null;

    this.$comments_hider.show();
    return this.$comments_collapser.remove();
  }
}

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}
