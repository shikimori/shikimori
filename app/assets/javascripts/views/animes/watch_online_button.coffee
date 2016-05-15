using 'Animes'
class Animes.WathOnlineButton extends View
  WATCH_ONLINE_TEMPLATE = 'templates/animes/watch_online'
  UPLOAD_VIDEOS_TEMPLATE = 'templates/animes/upload_videos'

  initialize: (@options) ->
    @_render() if @options.is_allowed

  _render: ->
    if @options.has_videos
      @$root.html JST[WATCH_ONLINE_TEMPLATE](url: @options.watch_url)

    else if @options.can_upload
      @$root.html JST[UPLOAD_VIDEOS_TEMPLATE](url: @options.upload_url)
