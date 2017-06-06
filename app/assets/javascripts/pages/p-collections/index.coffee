CollectionSearch = require 'views/application/collection_search'

page_load 'collections_index', ->
  new CollectionSearch '.b-collection_search'
