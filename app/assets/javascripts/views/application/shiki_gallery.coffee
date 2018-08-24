import delay from 'delay'
import Packery from 'packery'

export default class ShikiGallery extends View
  DEPLOY_INTERVAL = 50

  initialize: (options = {}) ->
    @$container = @$('.container')
    $images = $('.b-image', @$container)

    $images.shikiImage()

    @$container.imagesLoaded =>
      @packery = new Packery @$container[0],
        columnWidth: '.grid_sizer'
        containerStyle: null
        gutter: 0
        isAnimated: false
        isResizeBound: false
        itemSelector: '.b-image'
        transitionDuration: if options.imageboard then 0 else '0.25s'

      @$container
        .addClass('packery')
        .data(packery: @packery)

    if options.shiki_upload
      @_add_upload options.shiki_upload_custom

  _add_upload: (is_shiki_upload_custom) ->
    @$container
      .shikiFile
        progress: @$container.prev()

      .on 'upload:success', (e, response) =>
        return if is_shiki_upload_custom
        @_deploy_image response.html, DEPLOY_INTERVAL, 'prepended'

  _deploy_image: (image_node, delay_interval, action) =>
    $image = $(image_node)
      .shikiImage()
      .css(left: -9999)
      .prependTo(@$container)

    delay(delay_interval).then => @packery[action]($image[0])
