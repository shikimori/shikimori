CollectionSearch = require 'views/application/collection_search'

page_load 'users_index', ->
  new CollectionSearch '.b-collection_search'
