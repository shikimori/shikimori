require './image'

using 'Wall'
class Wall.Video extends Wall.Image
  HEIGHT_RATIO =
    other: 1.0
    vk: 0.75417

  constructor: ($node) ->
    @is_vk = $node.hasClass('vk')
    super

  apply: ->
    @$image.css
      width: @width
      # height: @height / @_height_ratio()

    @$node.css
      top: @top
      left: @left
      width: @width
      height: @height

  _image_sizes: ->
    [
      @$image[0].naturalWidth * 1.0
      @$image[0].naturalHeight * 1.0 * @_height_ratio()
    ]

  _height_ratio: ->
    HEIGHT_RATIO[if @is_vk then 'vk' else 'other']
