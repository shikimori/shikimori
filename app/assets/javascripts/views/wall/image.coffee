using 'Wall'
class Wall.Image
  constructor: ($node) ->
    @$container = $node

    @$image = @$container.find('img')

    # @width = @$image.width() * 1.0
    # @height = @$image.height() * 1.0
    [@width, @height] = @_image_sizes()

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
