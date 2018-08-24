import View from 'views/application/view'

using 'Wall'
class Wall.Image extends View
  initialize: ->
    @$image = @$node.find('img')
    [@width, @height] = @_image_sizes()
    [@original_width, @original_height] = [@width, @height]
    @ratio = @width / @height

    @reset()

  reset: ->
    @positioned = false
    @left = 0
    @top = 0
    [@width, @height] = [@original_width, @original_height]

  position: (left, top) ->
    @left = left
    @top = top
    @positioned = true

  apply: ->
    @$image.css
      width: @width
      height: @height

    @$node.css
      top: @top
      left: @left

    @$node.shikiImage()

  normalize: (width, height) ->
    @scale_width width if @width > width
    @scale_height height if @height > height

  scale_width: (width) ->
    @height *= width / @width
    @width = width

  scale_height: (height) ->
    @width *= height / @height
    @height = height

  scale: (percent) ->
    @width *= percent
    @height *= percent

  weight: ->
    @ratio.round(1)
    # (1 / @ratio).round(1)

  _image_sizes: ->
    [
      @$image[0].naturalWidth * 1.0
      @$image[0].naturalHeight * 1.0
    ]
