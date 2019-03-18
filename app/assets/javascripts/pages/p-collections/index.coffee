import CollectionSearch from 'views/application/collection_search'

page_load 'collections_index', ->
  return if !$('.b-search').length # collections moderation page
  new CollectionSearch '.b-search'
