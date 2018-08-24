import moment from 'moment'
import View from 'views/application/view'

export default class DatePicker extends View
  INPUT_FORMAT = 'YYYY-MM-DD'

  initialize: ->
    @init_promise = require.ensure [], (require) =>
      @_init_picker require('pikaday')

  set: (value, silent) ->
    @init_promise.then =>
      input_value = moment(value).format(INPUT_FORMAT) if value
      @root.value = input_value
      @$root.trigger 'date:picked' unless silent

  _init_picker: (Pikaday) ->
    new Pikaday
      field: @root
      onSelect: (date) => @set date
      firstDay: 1
      maxDate: new Date()
      i18n: @_i18n()

    # устанавливает после создания Pikaday, т.к. плагин перетирает значение
    # инпута и ставит дату в своём собственном форматировании,
    # а не в INPUT_FORMAT
    initial_value = moment(@root.value).toDate() if @root.value
    @set initial_value, true if initial_value

    @$root
      .on 'keypress', (e) =>
        @$root.trigger 'date:picked' if e.keyCode == 13

  _i18n: ->
    months        : moment.months(),
    weekdays      : moment.weekdays(),
    weekdaysShort : moment.weekdaysShort()
