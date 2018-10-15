import URI from 'urijs'
import delay from 'delay'

import ShikiView from 'views/application/shiki_view'
import BanForm from 'views/comments/ban_form'

export default class LogEntry extends ShikiView
  initialize: ->
    @$moderation = @$ '.moderation'

    @$('.reject[data-reason-prompt]', @$moderation).on 'click', @_reject_dialog

    @$('.ajax-action', @$moderation)
      .on 'ajax:before', @_shade
      .on 'ajax:success', @_reload

    @$('.delete', @$moderation)
      .on 'ajax:before', @_shade
      .on 'ajax:success', @_remove

    @$('.ban, .warn', @$moderation)
      .on 'ajax:before', @_prepare_form
      .on 'ajax:before', @_shade
      .on 'ajax:complete', @_unshade
      .on 'ajax:success', @_show_form

  _prepare_form: =>
    @$moderation.hide()
    @$('.spoiler.collapse .action').hide()

  _show_form: (e, html) =>
    $form = @$('.ban-form')
    $form.html(html).show()

    new BanForm($form)

    if $(e.target).hasClass 'warn'
      $form.find('#ban_duration').val '0m'

      if @$root.find('.b-spoiler_marker').length
        $form.find('#ban_reason').val 'спойлеры'

    # закрытие формы бана
    $('.cancel', $form).on 'click', @_hide_form

    # сабмит формы бана пользователю
    $form
      .on 'ajax:before', @_shade
      .on 'ajax:complete', @_unshade
      .on 'ajax:success', @_reload

  _hide_form: =>
    @$moderation.show()
    @$('.spoiler.collapse .action').show()
    @$('.ban-form').hide().empty()
    @$('.spoiler.collapse').click()

  _remove: =>
    @$root.hide()
    delay(10000).then =>
      # remove must be called later becase
      # "b-tooltipped" tooltip wont disappear otherwise
      @$root.remove()

  _reject_dialog: (e) ->
    href = $(e.target).data('href')
    reason = prompt $(e.target).data('reason-prompt')

    if reason == null
      false
    else
      $(e.target).attr href: "#{href}?reason=#{encodeURIComponent reason}"
