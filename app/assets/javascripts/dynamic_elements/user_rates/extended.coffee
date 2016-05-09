using 'DynamicElements.UserRates'
class DynamicElements.UserRates.Extended extends DynamicElements.UserRates.Button
  TEMPLATE = 'templates/user_rates/extended'

  initialize: ->
    @entry = @$root.data('entry')
    super

    # @$('.b-rate').rateable()
    # @$('.note').check_height(125)

    # # по изменению статуса в списке
    # @on 'click', '.edit-trigger', =>
      # if @extended
        # @$root.find('.trigger-arrow').click()
        # false
      # else
        # # закрытие развёрнутого меню
        # @$root.find('.expanded .trigger-arrow').click()

        # if @$('.rate-edit').is(':visible')
          # @$('.rate-edit').find('.cancel').click()
          # false

    # # отмена редактирования user_rate
    # @on 'click', '.cancel', @_cancel_edition

    # # сабмит формы user_rate
    # @on 'ajax:success', '.new_user_rate, .increment, .remove', @_replace_button

    # # завершение редактирования user_rate
    # @on 'ajax:success', '.edit_user_rate', @_replace_button

  # handlers
  _toggle_list: (e) =>
    if e.currentTarget.classList.contains('edit-trigger')
      console.log(e, e.currentTarget)
    else
      super

  _toggle_form: ->
    console.log 'toggle_form'
    false

  # functions
  _render_params: ->
    params = super()
    extended_params = Object.merge(Object.merge({}, params), entry: @entry)
    extended_html = JST[TEMPLATE](extended_params) if @_is_persisted()

    Object.merge(params, extended_html: extended_html)

  # # отмена редактирования user_rate
  # _cancel_edition: =>
    # $show = @$('.rate-show').show()
    # $edit = @$('.rate-edit').hide()

    # @$root.css height: @$('.b-add_to_list').outerHeight(true) + $show.data('height')
    # (=> @$root.css height: '').delay(500)

  # # замена кнопки на новую
  # _replace_button: (e, response) =>
    # $new_root = $(response.html)
      # .data('extended', @extended)
      # .replaceAll(@$root)
      # .user_rate_button()

    # @$catalog_entry = $(".b-catalog_entry.c-#{$new_root.data('target_type').toLowerCase()}##{$new_root.data 'target_id'}")

    # if @$catalog_entry.exists()
      # @$catalog_entry
        # .removeClass(@$catalog_entry.data('rate-status'))
        # .addClass($new_root.data('status'))
        # .data('rate-status': $new_root.data('status'))
