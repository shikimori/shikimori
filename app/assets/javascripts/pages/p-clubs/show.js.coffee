@on 'page:load', 'clubs_show', ->
  $gallery = $('.b-gallery')

  $gallery.gallery
    shiki_upload: $gallery.data('upload')
