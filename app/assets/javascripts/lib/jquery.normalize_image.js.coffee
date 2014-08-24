(($) ->
  # почему-то без задержки не работает
  check_image = ($image, options) ->
    $link = $image.parent()

    image_width = $image[0].naturalWidth || $image.width()
    image_height = $image[0].naturalHeight || $image.height()

    $image.addClass if image_width > image_height then 'normalized_width' else 'normalized_height' if image_width > 300

    if $link.tagName() == 'a' && $link.attr('href').match(/\.(png|jpg|jpeg|bmp|gif)$/i)
      $link.fancybox(options.fancybox)

    if options.remove_for_link
      $link.removeClass options.class
    else
      $image.removeClass options.class

    if options.append_marker && !$link.children('.marker').exists()
      $link.append "<span class='marker'>#{image_width}x#{image_height}</span>"

  $.fn.extend normalize_image: (options) ->
    @each ->
      $image = $(@)
      $image.imagesLoaded ->
        check_image.delay 0, $image, options
) jQuery
