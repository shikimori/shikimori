using 'DynamicElements'
class DynamicElements.UserRateForm extends DynamicElements.UserRate
  I18N_STATUS_KEY = 'activerecord.attributes.user_rate.statuses'

  initialize: ->
    super
    # @button_only = @$root.data('button_only')

    # @$('.b-rate').rateable()
    # @$('.note').check_height(125)

    # # по изменению статуса в списке
    # @on 'click', '.edit-trigger', =>
      # if @button_only
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

  # functions

  # # отмена редактирования user_rate
  # _cancel_edition: =>
    # $show = @$('.rate-show').show()
    # $edit = @$('.rate-edit').hide()

    # @$root.css height: @$('.b-add_to_list').outerHeight(true) + $show.data('height')
    # (=> @$root.css height: '').delay(500)

  # # замена кнопки на новую
  # _replace_button: (e, response) =>
    # $new_root = $(response.html)
      # .data('button_only', @button_only)
      # .replaceAll(@$root)
      # .user_rate_button()

    # @$catalog_entry = $(".b-catalog_entry.c-#{$new_root.data('target_type').toLowerCase()}##{$new_root.data 'target_id'}")

    # if @$catalog_entry.exists()
      # @$catalog_entry
        # .removeClass(@$catalog_entry.data('rate-status'))
        # .addClass($new_root.data('status'))
        # .data('rate-status': $new_root.data('status'))
