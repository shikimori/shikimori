using 'Wall'
class Wall.Cluster
  @MARGIN = 4

  constructor: (@images) ->

  mason: (@top, @max_width, @max_height) ->
    @images.each (image) => image.normalize @max_width, @max_height
    @images.each (image) => @_put image, true
    @images.each (image) => image.apply()

  width: ->
    (@images.map (v) -> v.left + v.width).max() || 0

  height: ->
    (@images.map (v) -> v.top + v.height).max() || 0

  _positioned: ->
    @images.filter (v) -> v.positioned

  _put: (image, post_process) ->
    left = (@_positioned().map (v) -> v.left + v.width).max()

    if left
      left += Wall.Cluster.MARGIN
    else
      left = 0

    image.position left, @top

    @_flatten()
    @_scale()

  _flatten: ->
    images = @_positioned()
    return if images.length == 1

    heights = images.map (v) -> v.height
    min_height = heights.min()

    if min_height != heights.max()
      images.each (image) ->
        image.scale_height min_height
        image.positioned = false
        true # не убирать до замены на forEach

      images.each (image) =>
        @_put image, false

  _scale: (image, delta_x, delta_y) ->
    images = @_positioned()

    current_width = images.reduce (memo, v) =>
        memo + v.width + Wall.Cluster.MARGIN
      , 0.0

    if current_width > @max_width
      images.each (image) =>
        image.scale @max_width / current_width
        image.positioned = false
        true # не убирать до замены на forEach

      images.each (image) =>
        @_put image, false
