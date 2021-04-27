import ShikiView from 'views/application/shiki_view';

const FAYE_EVENTS = [
  'faye:comment:marked',
  'faye:comment:created',
  'faye:comment:updated',
  'faye:comment:deleted',
  'faye:topic:updated',
  'faye:topic:deleted',
  'faye:comment:set_replies'
];

export default class Forum extends ShikiView {
  initialize() {
    this.on(FAYE_EVENTS.join(' '), (e, data) => {
      if (window.SHIKI_USER.isTopicIgnored(data.topic_id)) { return; }
      if (window.SHIKI_USER.isUserIgnored(data.user_id)) { return; }

      const $topic = this.$(`.b-topic#${data.topic_id}`);

      if ($topic.exists()) {
        $topic.trigger(e.type, data);
      } else if (e.type === 'faye:comment:created') {
        this._fayePlaceholder(data.topic_id);
        // уведомление о добавленном элементе через faye
        $(document.body).trigger('faye:added');
      }
    });

    this.on('faye:topic:created', (e, data) => {
      if (window.SHIKI_USER.isUserIgnored(data.user_id)) { return; }

      this._fayePlaceholder(data.topic_id);
      // уведомление о добавленном элементе через faye
      $(document.body).trigger('faye:added');
    });
  }

  // получение плейсхолдера для подгрузки новых топиков
  _fayePlaceholder(commentId) {
    let $placeholder = this.$('>.faye-loader');

    if (!$placeholder.exists()) {
      $placeholder = $('<div class="faye-loader to-process" data-dynamic="clickloaded"></div>')
        .prependTo(this.$root)
        .data({ ids: [] })
        .process()
        .on('clickloaded:success', (e, data) => {
          const $html = $(data.content).process(data.JS_EXPORTS);
          $placeholder.replaceWith($html);
        });
    }

    if ($placeholder.data('ids')?.indexOf(commentId) === -1) {
      const ids = $placeholder.data('ids').add(commentId);

      $placeholder.data({
        ids,
        'clickloaded-url': `/topics/chosen/${ids.join(',')}`
      });

      const num = $placeholder.data('ids').length;
      $placeholder.html(
        p(
          num,
          I18n.t('frontend.lib.jquery_shiki_forum.new_topics_added.one', { count: num }),
          I18n.t('frontend.lib.jquery_shiki_forum.new_topics_added.few', { count: num }),
          I18n.t('frontend.lib.jquery_shiki_forum.new_topics_added.many', { count: num })
        )
      );
    }
  }
}
