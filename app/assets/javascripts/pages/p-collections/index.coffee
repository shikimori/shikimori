import CollectionSearch from 'views/application/collection_search'

pageLoad 'collections_index', ->
  return if !$('.b-search').length # collections moderation page
  new CollectionSearch '.b-search'
