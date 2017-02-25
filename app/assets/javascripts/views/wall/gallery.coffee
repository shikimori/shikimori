wall_id = 0

using 'Wall'
class Wall.Gallery extends View
  VERTICAL = 'vertical'
  HORIZONTAL = 'horizontal'

  initialize: ->
    Wall.Gallery.last_id ||= 0
    Wall.Gallery.last_id += 1
    @id = Wall.Gallery.last_id

    @$root.imagesLoaded =>
      @_prepare()
      @_mason()

  _prepare: ->
    @$node.css
      width: ''
      height: ''

    @max_height = parseInt @$node.css('max-height')
    @max_width = parseInt @$node.css('width')

    $images = @$node
      .children('a, .b-video')
      .attr(rel: "wall-#{@id}")
      .css(width: '', height: '')
    $images.children().removeClass 'check-width'

    @images = $images.toArray().map (v) ->
      if v.classList.contains('b-video')
        new Wall.Video $(v)
      else
        new Wall.Image $(v)

    @direction = HORIZONTAL
    @margin = 4

  _each: (func) -> @images.each func
  _filter: (func) -> @images.filter func
  _map: (func) -> @images.map func
  _positioned: -> @_filter (v) -> v.positioned

  _mason: ->
    @_each (image) => image.normalize @max_width, @max_height
    @_each (image) => @_put image, true
    @_each (image) => image.apply()

    width = (@_map (v) -> v.left + v.width).max() || 0
    height = (@_map (v) -> v.top + v.height).max() || 0

    @$node.css
      width: ([width, @max_width]).min()
      height: ([height, @max_height]).min()

  _put: (image, post_process) ->
    left = _([0].concat _(@_positioned()).map (v) -> v.left + v.width).max() + @margin
    left = 0 if left == @margin

    top = _([0].concat _(@_positioned()).map (v) -> v.top + v.height).max() + @margin
    top = 0 if top == @margin

    #delta_x = _.max [left + image.width - @max_width, 0]
    #delta_y = _.max [top + image.height - @max_height, 0]

    #if delta_x && !delta_y
      #throw 'not implemented yet'
      #image.position 0, top

    #else if !delta_x && delta_y
      #throw 'not implemented yet'
      #image.position left, 0

    #else if delta_x && delta_y
      #if @direction == HORIZONTAL
        #image.position left, 0
      #else
        #image.position 0, top

    #else
      #image.position left, top

    if @direction == HORIZONTAL
      image.position left, 0
    else
      image.position 0, top

    @_flatten()
    @_scale()

  _flatten: ->
    images = @_positioned()
    return if images.length == 1

    if @direction == HORIZONTAL
      heights = _(images).map (v) -> v.height
      min = _(heights).min()
      if min != _(heights).max()
        _(images).each (image) ->
          image.scale_height min
          image.positioned = false

        _(images).each (image) =>
          @_put image, false

    else
      throw 'not implemented yet'

  _scale: (image, delta_x, delta_y) ->
    images = @_positioned()

    if @direction == HORIZONTAL
      current_width = _(images).reduce (memo, v) =>
          memo + v.width + @margin
        , 0.0

      if current_width > @max_width
        _(images).each (image) =>
          image.scale @max_width / current_width
          image.positioned = false

        _(images).each (image) =>
          @_put image, false

    else
      throw 'not implemented yet'

