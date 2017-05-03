ShikiGallery = require 'views/application/shiki_gallery'

using 'Animes'
module.exports = class Animes.Cosplay extends View
  initialize: ->
    @_init_galleries()
    @on 'postloader:success', @_init_galleries

  _init_galleries: =>
    @$('.b-gallery:not(.processed)').each ->
      new ShikiGallery(@)
      @classList.add 'processed'
