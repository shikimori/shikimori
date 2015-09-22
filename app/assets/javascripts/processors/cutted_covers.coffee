class @CuttedCovers extends View
  @PRIOR_ID = 0
  @RATIO =
    #entry: 229.0 / 156.0
    entry: 318.0 / 225.0
    person: 194.0 / 125.0

  @CLASS_NAME = 'd-cutted_covers'
  @GLOBAL_HANDLER = false

  recalc_styles = ->
    $('#injectCSSContainer').empty()
    $('.d-cutted_covers').each ->
      $(@).data(CuttedCovers.CLASS_NAME).inject_css()

  bind_hanler = ->
    CuttedCovers.GLOBAL_HANDLER = true
    $(document).on 'resize:debounced orientationchange', recalc_styles

  initialize: ->
    @_fetch_poster()
    @collection_id = "cutted_covers_#{@_increment_id()}"
    @ratio_type = @_node_ratio @node

    @inject_css()

    @node.id = @collection_id
    @node.classList.add(CuttedCovers.CLASS_NAME)
    @$node.data("#{CuttedCovers.CLASS_NAME}": @)

    bind_hanler() unless CuttedCovers.GLOBAL_HANDLER

  inject_css: =>
    @_fetch_poster() unless $.contains(document.documentElement, @$poster[0])

    $.injectCSS(
      "##{@collection_id}": {
        '.image-cutter': {
          'max-width': @$poster.width()
          'max-height': (@$poster.width() * CuttedCovers.RATIO[@ratio_type]).round(2)
        }
      }
    )

  _increment_id: ->
    CuttedCovers.PRIOR_ID = CuttedCovers.PRIOR_ID + 1

  _node_ratio: (node) ->
    @node.attributes['data-ratio_type']?.value || 'entry'

  _fetch_poster: ->
    @$poster = @$ '.b-catalog_entry:first-child .image-decor'
