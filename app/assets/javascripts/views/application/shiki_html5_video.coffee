export default class ShikiHtml5Video extends View
  VOLUME_KEY = 'video_volume'

  initialize: ->
    @storage = require('js-storage').sessionStorage

    @root.volume = @storage.get(VOLUME_KEY) || 1

    @on 'error', @error
    @on 'click', @click
    @on 'volumechange', @volumechange

  click: =>
    if @root.paused
      @root.play()
    else
      @root.pause()
    false

  volumechange: =>
    @storage.set VOLUME_KEY, @root.volume
