# общий класс для комментария, топика, редактора
class @ShikiView
  MAX_PREVIEW_HEIGHT: 450
  COLLAPSED_HEIGHT: 150

  constructor: ($root) ->
    @_initialize($root)
    @initialize(@$root)

  on: ->
    @$root.on.apply(@$root, arguments)

  trigger: ->
    @$root.trigger.apply(@$root, arguments)

  $: (selector) ->
    $(selector, @$root)

  # внутренняя инициализация
  _initialize: ($root) ->
    @$root = $root
    @$root.removeClass('unprocessed')
    @$root.data shiki_object: @
    @$inner = @$('>.inner')
    return unless @$inner.exists()

  # проверка высоты комментария. урезание, если текст слишком длинный (точно такой же код в shiki_topic)
  _check_height: =>
    if OPTIONS.comments_auto_collapsed
      @$inner.check_height @MAX_PREVIEW_HEIGHT, false, @COLLAPSED_HEIGHT

  _shade: =>
    @$root.addClass 'ajax_request'

  _unshade: =>
    @$root.removeClass 'ajax_request'
