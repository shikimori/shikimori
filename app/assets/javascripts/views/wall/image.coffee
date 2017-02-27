using 'Wall'
class Wall.Image
  constructor: ($node) ->
    @$container = $node

    @$image = @$container.find('img')
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

    @$container.css
      top: @top
      left: @left

    @$container.shiki_image()

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

  _image_sizes: ->
    [
      @$image[0].naturalWidth * 1.0
      @$image[0].naturalHeight * 1.0
    ]
