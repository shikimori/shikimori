using 'UserRates'
class UserRates.ButtonForm extends View
  initialize: ->
    # клик на изменение user_rate - подгрузка и показ формы
    @on 'ajax:success', '.edit-trigger', @_show_edition_form

  # показ формы редактирования
  _show_edition_form: (e, response_html) =>
    e.stopImmediatePropagation()

    $show = @$('.rate-show')
    $show
      .data(height: $show.outerHeight(true))
      .hide()

    $edit = @$('.rate-edit')
    $edit.html(response_html)

    $edit
      .data(height: $edit.outerHeight(true))
      .show()

    # по первому фокусу на редактор включаем elastic
    $edit.find('textarea').one 'focus', -> $(@).elastic.bind($(@)).delay()

    @$root.css height: @$('.b-add_to_list').outerHeight(true) + $show.data('height')
    (=>
      @$root.css height: @$('.b-add_to_list').outerHeight(true) + $edit.data('height')
    ).delay()
    (=> @$root.css height: '').delay(500)
