@on 'page:load', 'translations_show', ->
  $('.translations').packery
    itemSelector : '.animes'
