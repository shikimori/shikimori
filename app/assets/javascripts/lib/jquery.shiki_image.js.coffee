(($) ->
  $.fn.extend
    shiki_image: ->
      @each ->
        $root = $(@)
        $root.fancybox($.galleryOptions)
        $root.image_editable()
) jQuery
