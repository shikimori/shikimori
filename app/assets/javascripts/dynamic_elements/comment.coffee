import delay from 'delay'
import { flash } from 'shiki-utils'

import ShikiEditable from 'views/application/shiki_editable'
import BanForm from 'views/comments/ban_form'

I18N_KEY = 'frontend.dynamic_elements.comment'

export default class Comment extends ShikiEditable
  _type: -> 'comment'
  _type_label: -> I18n.t("#{I18N_KEY}.type_label")

  # similar to hash from JsExports::CommentsExport#serialize
  _default_model: ->
    can_destroy: false
    can_edit: false
    id: parseInt(@root.id)
    is_viewed: true
    user_id: @$root.data('user_id')

  initialize: ->
    # data attribute is set in Comments.Tracker
    @model = @$root.data('model') || @_default_model()

    if window.SHIKI_USER.isUserIgnored(@model.user_id)
      # node can be not inserted into DOM yet
      if @$root.parent().length
        @$root.remove()
      else
        delay().then => @$root.remove()
      return

    @$body = @$('.body')

    @_activate_appear_marker() if @model && !@model.is_viewed
    @$root.one 'mouseover', @_deactivate_inaccessible_buttons
    @$('.item-mobile').one @_deactivate_inaccessible_buttons

    if @$inner.hasClass('check_height')
      $images = @$body.find('img')
      if $images.exists()
        # картинки могут быть уменьшены image_normalizer'ом,
        # поэтому делаем с задержкой
        $images.imagesLoaded =>
          delay(10).then => @_check_height()
      else
        @_check_height()

    # ответ на комментарий
    @$('.item-reply').on 'click', (e) =>
      @$root.trigger 'comment:reply', [{
        id: @root.id,
        type: @_type(),
        text: @$root.data('user_nickname')
        url: "/#{@_type()}s/#{@root.id}"
      }, @_is_offtopic()]

    # edit message
    @$('.main-controls .item-edit')
      .on 'ajax:before', @_shade
      .on 'ajax:complete', @_unshade
      .on 'ajax:success', (e, html, status, xhr) =>
        $form = $(html).process()
        $form.find('.b-shiki_editor, .b-shiki_editor-v2').view()
          .editComment(@$root, $form)

    # moderation
    @$('.main-controls .item-moderation').on 'click', =>
      @$('.main-controls').hide()
      @$('.moderation-controls').show()

    @$('.item-offtopic, .item-summary').on 'click', (e) ->
      confirm_type = if @classList.contains('selected') then 'remove' else 'add'
      $(@).attr 'data-confirm', $(@).data("confirm-#{confirm_type}")

    @$('.item-spoiler, .item-abuse').on 'ajax:before', (e) ->
      reason = prompt $(@).data('reason-prompt')

      if reason == null
        false
      else
        $(@).data form:
          reason: reason

    # пометка комментария обзором/оффтопиком
    @$('.item-summary,.item-offtopic,.item-spoiler,.item-abuse,.b-offtopic_marker,.b-summary_marker').on 'ajax:success', (e, data, satus, xhr) =>
      if 'affected_ids' of data && data.affected_ids.length
        data.affected_ids.forEach (id) ->
          $(".b-comment##{id}").view()?.mark(data.kind, data.value)
        flash.notice marker_message(data)
      else
        flash.notice I18n.t("#{I18N_KEY}.your_request_will_be_considered")

      @$('.item-moderation-cancel').trigger('click')

    # cancel moderation
    @$('.moderation-controls .item-moderation-cancel').on 'click', =>
      #@$('.main-controls').show()
      #@$('.moderation-controls').hide()
      @_close_aside()

    # кнопка бана или предупреждения
    @$('.item-ban').on 'ajax:success', (e, html) =>
      form = new BanForm(html)

      @$('.moderation-ban').html(form.$root).show()
      @_close_aside()

    # закрытие формы бана
    @$('.moderation-ban').on 'click', '.cancel', =>
      @$('.moderation-ban').hide()

    # сабмит формы бана
    @$('.moderation-ban').on 'ajax:success', 'form', (e, response) =>
      @_replace response.html

    # изменение ответов
    @on 'faye:comment:set_replies', (e, data) =>
      @$('.b-replies').remove()
      $(data.replies_html).appendTo(@$body).process()

    # хештег со ссылкой на комментарий
    @$('.hash').one 'mouseover', ->
      $node = $(@)
      $node
        .attr(href: $node.data('url'))
        .changeTag('a')

  # пометка комментария маркером (оффтопик/отзыв)
  mark: (kind, value) ->
    @$(".item-#{kind}").toggleClass('selected', value)
    @$(".b-#{kind}_marker").toggle(value)

  # оффтопиковый ли данный комментарий
  _is_offtopic: ->
    @$('.b-offtopic_marker').css('display') != 'none'

  # скрытие действий, на которые у пользователя нет прав
  _deactivate_inaccessible_buttons: =>
    @$('.item-edit').addClass 'hidden' unless @model.can_edit
    @$('.item-delete').addClass 'hidden' unless @model.can_destroy

    if window.SHIKI_USER.isModerator
      @$('.moderation-controls .item-abuse').addClass 'hidden'
      @$('.moderation-controls .item-spoiler').addClass 'hidden'
    else
      @$('.moderation-controls .item-ban').addClass 'hidden'

# текст сообщения, отображаемый при изменении маркера
marker_message = (data) ->
  if data.value
    if data.kind == 'offtopic'
      if data.affected_ids.length > 1
        flash.notice I18n.t("#{I18N_KEY}.comments_marked_as_offtopic")
      else
        flash.notice I18n.t("#{I18N_KEY}.comment_marked_as_offtopic")
    else
      flash.notice I18n.t("#{I18N_KEY}.comment_marked_as_summary")

  else
    if data.kind == 'offtopic'
      flash.notice I18n.t("#{I18N_KEY}.comment_not_marked_as_offtopic")
    else
      flash.notice I18n.t("#{I18N_KEY}.comment_not_marked_as_summary")
