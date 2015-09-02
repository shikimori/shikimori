class @Html5Video extends BaseProcessor
  initialize: ->
    @$node.magnificPopup
      preloader: false
      type: 'webm'
      mainClass: 'mfp-no-margins mfp-img-mobile'
      closeOnContentClick: true

    thumbnail = new Image
    thumbnail.src = @$node.data('src')
    thumbnail.srcset = @$node.data('srcset')

    imagesLoaded(thumbnail).on 'done', =>
      @node.src = thumbnail.src
      @node.srcset = thumbnail.srcset
