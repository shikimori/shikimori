using 'DynamicElements'
class DynamicElements.AbuseRequest extends ShikiView
  initialize: ->
    @$moderation = @$ '.moderation'

    @$('.take, .deny', @$moderation)
      .on 'ajax:before', @_shade
      .on 'ajax:success', @_reload

    @$('.ban, .warn', @$moderation)
      .on 'ajax:before', @_prepare_form
      .on 'ajax:success', @_show_form

  _prepare_form: =>
    @$moderation.hide()
    @$('.spoiler.collapse .action').hide()

  _show_form: (e, html) =>
    $form = @$('.ban-form')
    $form.html(html).show()

    if $(e.target).hasClass 'warn'
      $form.find('#ban_duration').val '0m'

      if @$root.find('.b-spoiler_marker').length
        $form.find('#ban_reason').val 'спойлеры'

    # закрытие формы бана
    $('.cancel', $form).on 'click', @_hide_form

    # сабмит формы бана пользователю
    $form
      .on 'ajax:before', @_shade
      .on 'ajax:success', @_reload

  _hide_form: =>
    @$moderation.show()
    @$('.spoiler.collapse .action').show()
    @$('.ban-form').hide().empty()
    @$('.spoiler.collapse').click()
