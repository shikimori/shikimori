(($) ->
  $.fn.extend
    shiki_image: ->
      @each ->
        $(@)
          .magnific_rel_gallery()
          .image_editable()
) jQuery
