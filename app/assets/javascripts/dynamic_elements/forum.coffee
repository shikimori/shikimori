import ShikiView from 'views/application/shiki_view'

export default class Forum extends ShikiView
  FAYE_EVENTS = [
    'faye:comment:marked'
    'faye:comment:created'
    'faye:comment:updated'
    'faye:comment:deleted'
    'faye:topic:updated'
    'faye:topic:deleted'
    'faye:comment:set_replies'
  ]

  initialize: ->
    @on FAYE_EVENTS.join(' '), (e, data) =>
      return if window.SHIKI_USER.isTopicIgnored(data.topic_id)
      return if window.SHIKI_USER.isUserIgnored(data.user_id)

      $topic = @$(".b-topic##{data.topic_id}")

      if $topic.exists()
        $topic.trigger e.type, data
      else if e.type == 'faye:comment:created'
        $placeholder = @_faye_placeholder(data.topic_id)

        # уведомление о добавленном элементе через faye
        $(document.body).trigger 'faye:added'

    @on 'faye:topic:created', (e, data) =>
      return if window.SHIKI_USER.isUserIgnored(data.user_id)

      $placeholder = @_faye_placeholder(data.topic_id)
      # уведомление о добавленном элементе через faye
      $(document.body).trigger 'faye:added'

  # получение плейсхолдера для подгрузки новых топиков
  _faye_placeholder: (comment_id) ->
    $placeholder = @$('>.faye-loader')

    unless $placeholder.exists()
      $placeholder = $('
        <div class="faye-loader to-process" data-dynamic="clickloaded"></div>
      ')
        .prependTo(@$root)
        .data(ids: [])
        .process()
        .on 'clickloaded:success', (e, data) ->
          $html = $(data.content).process(data.JS_EXPORTS)
          $placeholder.replaceWith $html

    if $placeholder.data('ids').indexOf(comment_id) == -1
      $placeholder.data
        ids: $placeholder.data('ids').add(comment_id)
      $placeholder.data
        'clickloaded-url': "/topics/chosen/#{$placeholder.data("ids").join ","}"

      num = $placeholder.data('ids').length
      $placeholder.html(
        p num,
          I18n.t('frontend.lib.jquery_shiki_forum.new_topics_added.one', count: num),
          I18n.t('frontend.lib.jquery_shiki_forum.new_topics_added.few', count: num),
          I18n.t('frontend.lib.jquery_shiki_forum.new_topics_added.many', count: num)
      )

    $placeholder
