(($) ->
  $.fn.extend
    shiki_wall: (opts) ->
      @each ->
        $wall = $(@)
        $wall.imagesLoaded ->
          new ShikiWall($wall).mason()
)(jQuery)

wall_id = 0

class @ShikiCluster
  @Vertical = 'vertical'
  @Horizontal = 'horizontal'

class @ShikiWall
  constructor: ($node) ->
    @id = (wall_id+=1)

    @$wall = $node
      .css(width: '', height: '')
      .removeClass('wall')
      .addClass('shiki-wall')

    @max_height = parseInt @$wall.css('max-height')
    @max_width = parseInt @$wall.css('width')

    images = @$wall.children('a').attr(rel: "wall-#{@id}").css(width: '', height: '')
    @images = _(images).map (v) -> new ShikiImage $(v)

    @direction = ShikiCluster.Horizontal
    @margin = 4

  each: (func) -> _(@images).each func
  select: (func) -> _(@images).select func
  map: (func) -> _(@images).map func
  positioned: -> @select (v) -> v.positioned

  mason: ->
    @each (image) => image.normalize @max_width, @max_height
    @each (image) => @_put image, true
    @each (image) => image.apply()

    width = _(@map (v) -> v.left + v.width).max()
    height = _(@map (v) -> v.top + v.height).max()
    @$wall.css
      width: _([width, @max_width]).min()
      height: _([height, @max_height]).min()

  _put: (image, post_process) ->
    left = _([0].concat _(@positioned()).map (v) -> v.left + v.width).max() + @margin
    left = 0 if left == @margin

    top = _([0].concat _(@positioned()).map (v) -> v.top + v.height).max() + @margin
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
      #if @direction == ShikiCluster.Horizontal
        #image.position left, 0
      #else
        #image.position 0, top

    #else
      #image.position left, top

    if @direction == ShikiCluster.Horizontal
      image.position left, 0
    else
      image.position 0, top

    @_flatten()
    @_scale()

  _flatten: ->
    images = @positioned()
    return if images.length == 1

    if @direction == ShikiCluster.Horizontal
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
    images = @positioned()

    if @direction == ShikiCluster.Horizontal
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


class ShikiImage
  constructor: ($node) ->
    @$container = $node

    @$image = @$container.children('img')

    @width = @$image.width() * 1.0
    @height = @$image.height() * 1.0

    @ratio = @width / @height

    @positioned = false
    @left = 0
    @top = 0

  position: (left, top) ->
    @left = left
    @top = top
    @positioned = true

  apply: ->
    @$image.css
      width: @width
      height: @height

    @$container.css
      top: @top
      left: @left

  normalize: (width, height) ->
    if @width > width
      @scale_width width

    else if @height > height
      @scale_height height

  scale_width: (width) ->
    @height *= width / @width
    @width = width

  scale_height: (height) ->
    @width *= height / @height
    @height = height

  scale: (percent) ->
    @width *= percent
    @height *= percent
