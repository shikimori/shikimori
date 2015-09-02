class @Html5Video extends BaseProcessor
  initialize: ->
    @$node.magnificPopup
      preloader: false
      type: 'webm'
      mainClass: 'mfp-no-margins mfp-img-mobile'
      closeOnContentClick: true

    @_replace_image()

  _replace_image: (attempt=1) ->
    thumbnail = new Image
    thumbnail.src = @$node.data('src')
    thumbnail.srcset = @$node.data('srcset')

    imagesLoaded(thumbnail)
      .on 'done', =>
        @node.src = thumbnail.src
        @node.srcset = thumbnail.srcset
      .on 'fail', =>
        if attempt <= 3
          (=> @_replace_image attempt+1).delay(30000 * (attempt+1))
