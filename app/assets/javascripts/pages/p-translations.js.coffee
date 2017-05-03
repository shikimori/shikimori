Packery = require 'packery'

page_load 'translations_show', ->
  new Packery $('.translations')[0],
    itemSelector : '.animes'
