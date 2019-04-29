import delay from 'delay'
import View from 'views/application/view'

recalc_styles = ->
  $('#injectCSSContainer').empty()
  $(".#{CuttedCovers.CLASS_NAME}").each ->
    $(@).data(CuttedCovers.CLASS_NAME)?.inject_css()

set_hanler = ->
  CuttedCovers.GLOBAL_HANDLER = true
  $(document).on 'resize:debounced orientationchange', recalc_styles

export default class CuttedCovers extends View
  @PRIOR_ID = 0
  @RATIO =
    #entry: 229.0 / 156.0
    entry: 318.0 / 225.0
    person: 350.0 / 225.0
    character: 350.0 / 225.0

  @CLASS_NAME = 'd-cutted_covers'
  @GLOBAL_HANDLER = false

  initialize: ->
    # $.process иногда выполняется ДО вставки в DOM, а этот код должен быть
    # выполнен, когда уже @root вставлен в DOM. поэтому delay
    delay().then =>
      @_fetch_poster()
      @collection_id = "cutted_covers_#{@_increment_id()}"
      @ratio_value = CuttedCovers.RATIO[@_node_ratio(@node)] || CuttedCovers.RATIO.entry

      @inject_css()

      @node.id = @collection_id
      @node.classList.add(CuttedCovers.CLASS_NAME)
      @$node.data("#{CuttedCovers.CLASS_NAME}": @)

      set_hanler() unless CuttedCovers.GLOBAL_HANDLER

  inject_css: =>
    @_fetch_poster() unless $.contains(document.documentElement, @$poster[0])
    height = (@$poster.width() * @ratio_value).round(2)
    width = @$poster.width()

    if width > 0 && height > 0
      $.injectCSS
        "##{@collection_id}":
          '.image-cutter':
            'max-width': width
            'max-height': height

  _increment_id: ->
    CuttedCovers.PRIOR_ID = CuttedCovers.PRIOR_ID + 1

  _node_ratio: (node) ->
    @node.attributes['data-ratio_type']?.value

  _fetch_poster: ->
    @$poster = @$ '.b-catalog_entry:first-child .image-decor'
