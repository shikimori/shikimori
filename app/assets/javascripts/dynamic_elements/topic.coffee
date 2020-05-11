import delay from 'delay'

import ShikiEditable from 'views/application/shiki_editable'
import ShikiEditor from 'views/application/shiki_editor'
import ShikiGallery from 'views/application/shiki_gallery'

import axios from 'helpers/axios'
import { animatedCollapse, animatedExpand } from 'helpers/animated'

# TODO: move code related to comments to separate class
export default class Topic extends ShikiEditable
  I18N_KEY = 'frontend.dynamic_elements.topic'
  FAYE_EVENTS = [
    'faye:comment:updated'
    'faye:message:updated'
    'faye:comment:deleted'
    'faye:message:deleted'
    'faye:comment:set_replies'
  ]
  SHOW_IGNORED_TOPICS_IN = [
    'topics_show'
    'collections_show'
  ]

  _type: -> 'topic'
  _type_label: -> I18n.t("#{I18N_KEY}.type_label")

  # similar to hash from JsExports::TopicsExport#serialzie
  _default_model: ->
    can_destroy: false
    can_edit: false
    id: parseInt(@root.id)
    is_viewed: true
    user_id: @$root.data('user_id')

  initialize: ->
    # data attribute is set in Topics.Tracker
    @model = @$root.data('model') || @_default_model()

    if window.SHIKI_USER.isUserIgnored(@model.user_id) ||
        window.SHIKI_USER.isTopicIgnored(@model.id)
      if SHOW_IGNORED_TOPICS_IN.includes document.body.id
        @_toggle_ignored true
      else
        # node can be not inserted into DOM yet
        if @$root.parent().length
          @$root.remove()
        else
          delay().then => @$root.remove()
        return

    @$body = @$inner.children('.body')

    @$editor_container = @$('.editor-container')
    @$editor = @$('.b-shiki_editor')

    if window.SHIKI_USER.isSignedIn && window.SHIKI_USER.isDayRegistered && @$editor.length
      @editor = new ShikiEditor(@$editor)
    else
      @$editor.replaceWith(
        "<div class='b-nothing_here'>
          #{I18n.t('frontend.shiki_editor.not_available')}
        </div>"
      )

    @$comments_loader = @$('.comments-loader')
    @$comments_hider = @$('.comments-hider')
    @$comments_collapser = @$('.comments-collapser')
    @$comments_expander = @$('.comments-expander')

    @is_preview = @$root.hasClass('b-topic-preview')
    @is_cosplay = @$root.hasClass('b-cosplay-topic')
    @is_club_page = @$root.hasClass('b-club_page-topic')
    @is_review = @$root.hasClass('b-review-topic')

    @_activate_appear_marker() if @model && !@model.is_viewed
    @_actualize_voting() if @model

    @$inner.one 'mouseover', @_deactivate_inaccessible_buttons
    $('.item-mobile', @$inner).one @_deactivate_inaccessible_buttons

    if @is_preview || @is_club_page
      @$body.imagesLoaded @_check_height
      @_check_height()

    if @is_cosplay && !@is_preview
      new ShikiGallery @$('.b-cosplay_gallery .b-gallery')

    # ответ на топик
    $('.item-reply', @$inner).on 'click', =>
      reply = if @$root.data 'generated'
        ''
      else
        "[entry=#{@$root.attr('id')}]#{@$root.data 'user_nickname'}[/entry], "

      @$root.trigger 'comment:reply', [reply]

    @$editor
      .on 'ajax:success', (e, response) =>
        $new_comment = $(response.html).process(response.JS_EXPORTS)

        @$('.b-comments').find('.b-nothing_here').remove()
        if @$editor.is(':last-child')
          @$('.b-comments').append $new_comment
        else
          @$('.b-comments').prepend $new_comment

        $new_comment.yellowFade()

        @editor.cleanup()
        @_hide_editor()

    $('.item-ignore', @$inner)
      .on 'ajax:before', ->
        $(@).toggleClass 'selected'

      .on 'ajax:success', (e, result) =>
        if result.is_ignored
          window.SHIKI_USER.ignoreTopic result.topic_id
        else
          window.SHIKI_USER.unignoreTopic result.topic_id

        @_toggle_ignored result.is_ignored

    # голосование за/против рецензии
    @$('.footer-vote .vote').on 'ajax:before', (e) =>
      @$inner.find('.footer-vote').addClass 'b-ajax'
      is_yes = $(e.target).hasClass 'yes'

      if is_yes && !@model.voted_yes
        @model.votes_for += 1
        @model.votes_against -= 1 if @model.voted_no
      else if !is_yes && !@model.voted_no
        @model.votes_for -= 1 if @model.voted_yes
        @model.votes_against += 1

      @model.voted_no = !is_yes
      @model.voted_yes = is_yes

      @_actualize_voting()

    @$('.footer-vote .vote').on 'ajax:complete', ->
      $(@).closest('.footer-vote').removeClass 'b-ajax'

    # прочтение комментриев
    @on 'appear', @_appear

    # ответ на комментарий
    @on 'comment:reply', (e, text, is_offtopic) =>
      # @editor is empty for unauthorized user
      if @editor
        @_show_editor()
        @editor.reply_comment text, is_offtopic

    # клик скрытию редактора
    @$('.b-shiki_editor').on 'click', '.hide', @_hide_editor

    # delegated handlers becase it is replaced on postload in
    # inherited classes (FullDialog)
    @on 'clickloaded:before', '.comments-loader', @_before_comments_clickload
    @on 'clickloaded:success', '.comments-loader', @_comments_clickloaded
    @on 'click', '.comments-loader', (e) =>
      unless @$comments_loader.data('dynamic') == 'clickloaded'
        @$comments_loader.addClass('hidden')
        @$('.comments-loaded').each (_index, node) ->
          animatedExpand node
        @$comments_hider.show()

    # hide loaded comments
    @$comments_collapser.on 'click', (e) =>
      @$comments_collapser.addClass('hidden')
      @$comments_loader.addClass('hidden')
      @$comments_expander.show()
      @$('.comments-loaded').each (_index, node) ->
        animatedCollapse node

    # скрытие комментариев
    @$comments_hider.on 'click', =>
      @$comments_hider.hide()
      @$('.comments-loaded').each (_index, node) ->
        animatedCollapse node
      @$comments_expander.show()

    # разворачивание комментариев
    @$comments_expander.on 'click', (e) =>
      @$comments_expander.hide()
      @$('.comments-loaded').each (_index, node) ->
        animatedExpand node

      if @$comments_loader
        @$comments_loader.removeClass('hidden')
        @$comments_collapser.removeClass('hidden')
      else
        @$comments_hider.show()

    # realtime обновления
    # изменение / удаление комментария
    @on FAYE_EVENTS.join(' '), (e, data) =>
      e.stopImmediatePropagation()
      trackable_type = e.type.match(/comment|message/)[0]
      trackable_id = data["#{trackable_type}_id"]

      if e.target == @$root[0]
        @$(".b-#{trackable_type}##{trackable_id}").trigger e.type, data

    # добавление комментария
    @on 'faye:comment:created faye:message:created', (e, data) =>
      e.stopImmediatePropagation()
      trackable_type = e.type.match(/comment|message/)[0]
      trackable_id = data["#{trackable_type}_id"]

      return if @$(".b-#{trackable_type}##{trackable_id}").exists()
      $placeholder = @_faye_placeholder(trackable_id, trackable_type)

      # уведомление о добавленном элементе через faye
      $(document.body).trigger 'faye:added'
      if window.SHIKI_USER.isCommentsAutoLoaded
        if $placeholder.is(':appeared') && !$('textarea:focus').val()
          $placeholder.click()

    # изменение метки комментария
    @on 'faye:comment:marked', (e, data) ->
      e.stopImmediatePropagation()
      $(".b-comment##{data.comment_id}").view().mark(data.mark_kind, data.mark_value)

  # переключение топика в режим игнора/не_игнора
  _toggle_ignored: (is_ignored) ->
    $('.item-ignore', @$inner)
      .toggleClass('selected', is_ignored)
      .data(method: if is_ignored then 'DELETE' else 'POST')
    @$('.b-anime_status_tag.ignored').toggleClass 'hidden', !is_ignored

  # удаляем уже имеющиеся подгруженные элементы
  _filter_present_entries: ($comments) ->
    filter = 'b-comment'
    present_ids = $(".#{filter}", @$root)
      .toArray()
      .map (v) -> v.id
      .filter (v) -> v

    exclude_selector = present_ids.map((id) -> ".#{filter}##{id}").join(',')

    $comments.children().filter(exclude_selector).remove()

  # отображение редактора, если это превью топика
  _show_editor: ->
    if @is_preview && !@$editor_container.is(':visible')
      @$editor_container.show()#animatedExpand()

  # скрытие редактора, если это превью топика
  _hide_editor: =>
    if @is_preview
      @$editor_container.hide()#animatedCollapse()

  # получение плейсхолдера для подгрузки новых комментариев
  _faye_placeholder: (trackable_id, trackable_type) ->
    @$('.b-comments .b-nothing_here').remove()
    $placeholder = @$('.b-comments .faye-loader')

    unless $placeholder.exists()
      $placeholder = $('
        <div class="faye-loader to-process" data-dynamic="clickloaded"></div>
      ')
        .appendTo(@$('.b-comments'))
        .data(ids: [])
        .process()
        .on 'clickloaded:success', (e, data) ->
          $html = $(data.content).process data.JS_EXPORTS
          $placeholder.replaceWith $html

          $html.process()

    if $placeholder.data('ids')?.indexOf(trackable_id) == -1
      $placeholder.data
        ids: $placeholder.data('ids').add(trackable_id)
      $placeholder.data
        'clickloaded-url': "/#{trackable_type}s/chosen/#{$placeholder.data('ids').join ","}"

      num = $placeholder.data('ids').length

      $placeholder.html if trackable_type == 'message'
        p num,
          I18n.t("#{I18N_KEY}.new_message_added.one", count: num),
          I18n.t("#{I18N_KEY}.new_message_added.few", count: num),
          I18n.t("#{I18N_KEY}.new_message_added.many", count: num)
      else
        p num,
          I18n.t("#{I18N_KEY}.new_comment_added.one", count: num),
          I18n.t("#{I18N_KEY}.new_comment_added.few", count: num),
          I18n.t("#{I18N_KEY}.new_comment_added.many", count: num)

    $placeholder

  # handlers
  _appear: (e, $appeared, by_click) ->
    $filtered_appeared = $appeared.not ->
      $(@).data('disabled') || !(
        @classList.contains('b-appear_marker') &&
          @classList.contains('active')
      )
    return unless $filtered_appeared.exists()

    interval = if by_click then 1 else 1500
    $objects = $filtered_appeared.closest('.shiki-object')
    $markers = $objects.find('.b-new_marker.active')
    ids = $objects
      .map ->
        $object = $(@)
        item_type = $object.data('appear_type')
        "#{item_type}-#{@id}"
      .toArray()

    axios.post(
      $markers.data('appear_url'),
      ids: ids.join(',')
    )

    $filtered_appeared.remove()

    if $markers.data('reappear')
      $markers.addClass 'off'
    else
      delay(interval).then ->
        $markers.css(opacity: 0)

        delay(500).then ->
          $markers.hide()
          $markers.removeClass('active')

  _before_comments_clickload: (e) =>
    new_url = @$comments_loader
      .data('clickloaded-url-template')
      .replace('SKIP', @$comments_loader.data('skip'))

    @$comments_loader.data('clickloaded-url': new_url)

  _comments_clickloaded: (e, data) =>
    $new_comments = $("<div class='comments-loaded'></div>").html(data.content)

    @_filter_present_entries($new_comments)

    $new_comments
      .process(data.JS_EXPORTS)
      .insertAfter(@$comments_loader)

    animatedExpand $new_comments[0]

    @_update_comments_loader(data)

  # private functions
  # проверка высоты топика. урезание,
  # если текст слишком длинный (точно такой же код в shiki_comment)
  _check_height: =>
    if @is_review
      image_height = @$('.review-entry_cover img').height()
      read_more_height = 13 + 5 # 5px - read_more offset

      if image_height > 0
        @$('.body-truncated-inner').checkHeight
          max_height: image_height - read_more_height
          collapsed_height: image_height - read_more_height
          expand_html: ''

    else
      @$('.body-inner').checkHeight
        max_height: @MAX_PREVIEW_HEIGHT
        collapsed_height: @COLLAPSED_HEIGHT

  _reload_url: =>
    "/#{@_type()}s/#{@$root.attr 'id'}/reload?is_preview=#{@is_preview}"

  _actualize_voting: ->
    @$inner
      .find('.footer-vote .vote.yes, .user-vote .voted-for')
      .toggleClass('selected', @model.voted_yes)

    @$inner
      .find('.footer-vote .vote.no, .user-vote .voted-against')
      .toggleClass('selected', @model.voted_no)

    if @model.votes_for
      @$inner.find('.votes-for').html("#{@model.votes_for}")

    if @model.votes_against
      @$inner.find('.votes-against').html("#{@model.votes_against}")

  # скрытие действий, на которые у пользователя нет прав
  _deactivate_inaccessible_buttons: =>
    @$inner.find('.item-edit').addClass 'hidden' unless @model.can_edit
    @$inner.find('.item-delete').addClass 'hidden' unless @model.can_destroy

  # data is used in inherited classes (FullDialog)
  _update_comments_loader: (data) ->
    limit = @$comments_loader.data('limit')
    count = @$comments_loader.data('count') - limit

    if count > 0
      @$comments_loader.data
        skip: @$comments_loader.data('skip') + limit
        count: count

      comment_count = Math.min(limit, count)
      comment_word =
        if @$comments_loader.data('only-summaries-shown')
          p comment_count,
            I18n.t("#{I18N_KEY}.summary.one"),
            I18n.t("#{I18N_KEY}.summary.few"),
            I18n.t("#{I18N_KEY}.summary.many")
        else
          p comment_count,
            I18n.t("#{I18N_KEY}.comment.one"),
            I18n.t("#{I18N_KEY}.comment.few"),
            I18n.t("#{I18N_KEY}.comment.many")
      of_total_comments =
        if count > limit
          "#{I18n.t("#{I18N_KEY}.of")} #{count}"
        else
          ''

      load_comments = I18n.t(
        "#{I18N_KEY}.load_comments"
        comment_count: comment_count,
        of_total_comments: of_total_comments,
        comment_word: comment_word
      )

      @$comments_loader.html(load_comments)
      @$comments_collapser.removeClass('hidden')
    else
      @$comments_loader.remove()
      @$comments_loader = null

      @$comments_hider.show()
      @$comments_collapser.remove()
