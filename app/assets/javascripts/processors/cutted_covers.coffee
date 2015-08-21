class @CuttedCovers extends BaseProcessor
  PRIOR_ID = 0
  RATIO =
    entry: 229.0 / 156.0
    person: 194.0 / 125.0

  CLASS_NAME = 'd-cutted_covers'
  GLOBAL_HANDLER = false

  recalc_styles = ->
    $('.d-cutted_covers').each ->
      $(@).data(CLASS_NAME).inject_css()

  bind_hanler = ->
    GLOBAL_HANDLER = true
    $(document).on 'resize:debounced orientationchange', recalc_styles

  initialize: ->
    #@$poster = @$ '.b-catalog_entry:first-child .cover img'
    @$poster = @$ '.b-catalog_entry:first-child .image-decor'
    @collection_id = "cutted_covers_#{@_increment_id()}"
    @ratio_type = @_node_ratio @node

    #@$poster.imagesLoaded @inject_css
    @inject_css()

    @node.id = @collection_id
    @node.classList.add(CLASS_NAME)
    @$node.data("#{CLASS_NAME}": @)

    bind_hanler() unless GLOBAL_HANDLER

  inject_css: =>
    $.injectCSS(
      "##{@collection_id}": {
        '.image-cutter': {
          'max-width': @$poster.width()
          'max-height': (@$poster.width() * RATIO[@ratio_type]).round(2)
        }
      }
    )

  _increment_id: ->
    PRIOR_ID = PRIOR_ID + 1

  _node_ratio: (node) ->
    @node.attributes['data-ratio_type']?.value || 'entry'
