# общий класс для комментария, топика, редактора
class @ShikiView extends View
  MAX_PREVIEW_HEIGHT: 450
  COLLAPSED_HEIGHT: 150

  # внутренняя инициализация
  _initialize: ($root) ->
    super $root
    @$root.removeClass('unprocessed')
    @$root.data shiki_object: @
    @$inner = @$('>.inner')
    return unless @$inner.exists()

  # проверка высоты комментария. урезание, если текст слишком длинный (точно такой же код в shiki_topic)
  _check_height: =>
    if OPTIONS.comments_auto_collapsed
      @$inner.check_height @MAX_PREVIEW_HEIGHT, false, @COLLAPSED_HEIGHT
