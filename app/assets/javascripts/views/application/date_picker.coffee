class @DatePicker extends View
  INPUT_FORMAT = 'DD.MM.YYYY'

  initialize: ->
    @set moment(@root.value, INPUT_FORMAT), true if @root.value

    new Pikaday
      field: @root
      onSelect: (date) => @set date
      firstDay: 1
      maxDate: new Date()
      i18n: @_i18n()

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
