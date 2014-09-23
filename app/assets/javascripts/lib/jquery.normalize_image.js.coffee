(($) ->
  # почему-то без задержки не работает
  check_image = ($image, options) ->
    $link = $image.parent()

    image_width = $image[0].naturalWidth || $image.width()
    image_height = $image[0].naturalHeight || $image.height()

    if image_width > 300 && !$image.attr('width') && !$image.attr('height')
      normalization_class = if image_width > image_height then 'normalized_width' else 'normalized_height' 
      $image.addClass(normalization_class)

    if $link.tagName() == 'a' && $link.attr('href').match(/\.(png|jpg|jpeg|bmp|gif)$/i)
      $link.fancybox(options.fancybox)

    if options.append_marker && !$link.children('.marker').exists()
      $link.append "<span class='marker'>#{image_width}x#{image_height}</span>"

  $.fn.extend normalize_image: (options) ->
    @each ->
      $image = $(@)
      $image.imagesLoaded ->
        check_image.delay 0, $image, options
) jQuery
