using 'Images'
class Images.PreloadedGallery extends View
  IMAGES_PER_FETCH = 12
  TEMPLATE = 'templates/images/image'

  APPEAR_MARKER_HTML =
    '<p class="ajax-loading vk-like b-appear_marker active" ' +
      'data-appear-top-offset="900"></p>'

  DEPLOY_INTERVAL = 100

  initialize: ->
    @can_upload = @$root.data 'can_upload'
    @can_destroy = @$root.data 'can_destroy'
    @rel = @$root.data 'rel'
    @can_load = true

    @$container = @$('.container')

    @$root.gallery
      shiki_upload: @$root.data('can_upload')
    @packery = @$root.packery

    @loader = @_build_loader()
    @loader.on Images.Loader.FETCH_EVENT, @_images_load

    @_appear_marker()
    @_fetch()

  # handlers
  _images_load: (images, is_finished) =>
    images_html = images.map (image) =>
      JST[TEMPLATE](image: image, rel: @rel, can_destroy: @can_destroy)

    $batch = $(images_html.join(''))
    $batch.imagesLoaded @_deploy_batch

    @$appear_marker.remove() if is_finished

  # private functions
  _build_loader: ->
    images = @$root.data 'images'
    new Images.Loader images

  _appear_marker: ->
    @$appear_marker = $(APPEAR_MARKER_HTML).insertAfter @$container
    @$appear_marker.on 'appear', @_fetch

  _fetch: (e) =>
    console.log 'fetch', @can_load

    if @can_load
      @loader.fetch(IMAGES_PER_FETCH)
      @_stop_postload()

  _start_postload: =>
    @can_load = true
    @_fetch() if @$appear_marker.is(':appeared')
    $.force_appear()

  _stop_postload: ->
    @can_load = false

  _deploy_batch: (images) =>
    images.elements.each @_deploy_image
    # recheck postloader appearence after all images are deployed
    @_start_postload.delay((images.elements.length + 1) * DEPLOY_INTERVAL)

  _deploy_image: (image, index) =>
    $image = $(image)
      .shiki_image()
      .css(bottom: 9999)

    @packery
      .bind(@$container, 'appended', $image)
      .delay(index * DEPLOY_INTERVAL)

    @$container.append($image)
