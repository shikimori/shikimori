# почему-то без задержки не работает
check_image = ($image, options) ->
  $container = $image.parent()
  $container = $container.parent() while $container.hasClass('spoiler') || $container.css('display') == 'inline'

  image_width = $image.width()
  container_width = $container.innerWidth()

  if image_width && container_width && image_width > container_width
    $image.css width: $container.innerWidth() - 7

    $image.wrap "<a href='#{$image.attr 'src'}'></a>" unless $image.parent().tagName() == 'a'
    $image.parent().fancybox options.fancybox

  else
    if $image.parent().tagName() == 'a' && $image.parent().attr('href').match(/\.(png|jpg|jpeg|bmp|gif)$/i)
      $image.parent().fancybox options.fancybox

  $image.removeClass options['class']

(($) ->
  $.fn.extend normalizeImage: (options) ->
    @each ->
      $this = $(@)
      if $this.width() > 0
        check_image $this, options

      else
        $this.load ->
          _.delay ->
            check_image $this, options
) jQuery
