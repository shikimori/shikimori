Packery = require 'packery'

pageLoad 'translations_show', ->
  new Packery $('.translations')[0],
    itemSelector : '.animes'
