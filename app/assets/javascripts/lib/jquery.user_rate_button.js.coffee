(($) ->
  $.fn.extend user_rate_button: (options={}) ->
    @each ->
      $root = $(@)
      return unless $root.hasClass('unprocessed')

      new UserRateButton($root)

) jQuery

class @UserRateButton extends ShikiView
  initialize: ->
    @button_only = @$root.data('button_only')

    @$('.b-rate').rateable()

    # клик по раскрытию вариантов добавления в список
    @on 'click', '.trigger-arrow', @toggle_list
    # клик по добавлению в свой список
    @on 'click', '.add-trigger', ->
      $form = $(@).closest('form')

      $form.find('.user_rate_status input').val $(@).data('status')
      $form.submit()

    # по изменению статуса в списке
    @on 'click', '.edit-trigger', =>
      if @button_only
        @$root.find('.trigger-arrow').click()
        false
      else
        # закрытие развёрнутого меню
        @$root.find('.expanded .trigger-arrow').click()

        if @$('.rate-edit').is(':visible')
          @$('.rate-edit').find('.cancel').click()
          false

    @on 'ajax:before', (e) =>
      if USER_SIGNED_IN
        @$root.addClass 'ajax_request'
      else
        $.info @$root.data('unauthorized')
        false

    @on 'ajax:success ajax:complete', (e, edit_html) =>
      @$root.removeClass 'ajax_request'

    # отмена редактирования user_rate
    @on 'click', '.cancel', @cancel_edition

    # сабмит формы user_rate
    @on 'ajax:success', '.new_user_rate, .increment, .remove', (e, html) =>
      @$root.html html
      @$('.b-rate').rateable()

    # завершение редактирования user_rate
    @on 'ajax:success', '.edit_user_rate', (e, html) =>
      @$root.html html
      @$('.b-rate').rateable()

    # клик на изменение user_rate - подгрузка и показ формы
    @on 'ajax:success', '.edit-trigger', @show_edition_form

  # раскрытие/сворачивание списка
  toggle_list: =>
    @$('.b-add_to_list').toggleClass('expanded')

    unless @$('.expanded-options').data 'height'
      @$('.expanded-options')
        .data(height: @$('.expanded-options').height())
        .css(height: 0)
        .show()

    (=>
      if @$('.b-add_to_list').hasClass 'expanded'
        @$('.expanded-options').css height: @$('.expanded-options').data('height')
      else
        @$('.expanded-options').css height: 0
    ).delay()

  # отмена редактирования user_rate
  cancel_edition: =>
    $show = @$('.rate-show').show()
    $edit = @$('.rate-edit').hide()

    @$root.css height: @$('.b-add_to_list').outerHeight(true) + $show.data('height')
    (=> @$root.css height: '').delay(500)

  # показ формы редактирования
  show_edition_form: (e, edit_html) =>
    e.stopImmediatePropagation()

    $show = @$('.rate-show')
    $show
      .data(height: $show.outerHeight(true))
      .hide()

    $edit = @$('.rate-edit')
    $edit.html(edit_html)

    $edit
      .data(height: $edit.outerHeight(true))
      .show()

    @$root.css height: @$('.b-add_to_list').outerHeight(true) + $show.data('height')
    (=>
      @$root.css height: @$('.b-add_to_list').outerHeight(true) + $edit.data('height')
    ).delay()
    (=> @$root.css height: '').delay(500)
