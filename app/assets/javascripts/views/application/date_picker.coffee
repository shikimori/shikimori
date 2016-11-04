class @DatePicker extends View
  INPUT_FORMAT = 'DD.MM.YYYY'

  initialize: ->
    initial_value = @root.value

    new Pikaday
      field: @root
      onSelect: (date) => @set date
      firstDay: 1
      maxDate: new Date()
      i18n: @_i18n()

    # устанавливает после создания Pikaday, т.к. плагин перетирает значение
    # инпута и ставит дату в своём собственном форматировании,
    # а не в INPUT_FORMAT
    @set initial_value, true if initial_value

    @$root
      .on 'keypress', (e) =>
        @$root.trigger 'date:picked' if e.keyCode == 13

  set: (value, silent) ->
    input_value = moment(value).format(INPUT_FORMAT) if value
    @root.value = input_value
    @$root.trigger 'date:picked' unless silent

  _i18n: ->
    months        : moment.months(),
    weekdays      : moment.weekdays(),
    weekdaysShort : moment.weekdaysShort()
