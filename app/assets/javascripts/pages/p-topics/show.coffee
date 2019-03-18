import imagesLoaded from 'imagesloaded'

pageLoad 'topics_show', ->
  $stars = $('.body-inner .review-stars')

  if $stars.length
    $first_image =  $('.body-inner img.b-poster').first()

    $first_image.imagesLoaded ->
      if $first_image.offset().top == $stars.offset().top + $stars.outerHeight()
        $first_image.addClass 'review-poster'
