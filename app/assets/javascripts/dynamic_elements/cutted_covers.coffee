recalc_styles = ->
  $('#injectCSSContainer').empty()
  $(".#{DynamicElements.CuttedCovers.CLASS_NAME}").each ->
    $(@).data(DynamicElements.CuttedCovers.CLASS_NAME).inject_css()

set_hanler = ->
  DynamicElements.CuttedCovers.GLOBAL_HANDLER = true
  $(document).on 'resize:debounced orientationchange', recalc_styles

using 'DynamicElements'
class DynamicElements.CuttedCovers extends View
  @PRIOR_ID = 0
  @RATIO =
    #entry: 229.0 / 156.0
    entry: 318.0 / 225.0
    person: 194.0 / 125.0

  @CLASS_NAME = 'd-cutted_covers'
  @GLOBAL_HANDLER = false

  initialize: ->
    @_fetch_poster()
    @collection_id = "cutted_covers_#{@_increment_id()}"
    @ratio_type = @_node_ratio @node

    @inject_css()

    @node.id = @collection_id
    @node.classList.add(DynamicElements.CuttedCovers.CLASS_NAME)
    @$node.data("#{DynamicElements.CuttedCovers.CLASS_NAME}": @)

    set_hanler() unless DynamicElements.CuttedCovers.GLOBAL_HANDLER

  inject_css: =>
    @_fetch_poster() unless $.contains(document.documentElement, @$poster[0])
    height = (@$poster.width() * DynamicElements.CuttedCovers.RATIO[@ratio_type]).round(2)
    width = @$poster.width()

    if width > 0 && height > 0
      $.injectCSS
        "##{@collection_id}":
          '.image-cutter':
            'max-width': width
            'max-height': height

  _increment_id: ->
    DynamicElements.CuttedCovers.PRIOR_ID = DynamicElements.CuttedCovers.PRIOR_ID + 1

  _node_ratio: (node) ->
    @node.attributes['data-ratio_type']?.value || 'entry'

  _fetch_poster: ->
    @$poster = @$ '.b-catalog_entry:first-child .image-decor'
