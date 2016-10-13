@on 'page:load', 'clubs_images', ->
  $gallery = $('.b-gallery')

  $gallery.gallery
    shiki_upload: $gallery.data('upload')
