using 'Animes'
class Animes.WathOnlineButton extends View
  WATCH_ONLINE_TEMPLATE = 'templates/animes/watch_online'
  UPLOAD_VIDEOS_TEMPLATE = 'templates/animes/upload_videos'

  initialize: (@options) ->
    return unless @options.is_allowed
    @total_episodes = @$root.data('total_episodes') || 9999

    @_render()
    @_setup_handlers.delay()

  _render: ->
    if @options.has_videos
      @$root.html JST[WATCH_ONLINE_TEMPLATE](url: @options.watch_url)

    else if @options.can_upload
      @$root.html JST[UPLOAD_VIDEOS_TEMPLATE](url: @options.upload_url)

  _setup_handlers: =>
    @$('.watch-online').on 'click', @_click

  _click: (e) =>
    episode = parseInt($('.b-db_entry .b-user_rate .current-episodes').html())
    watch_episode = if !episode || episode == @total_episodes then 1 else episode + 1

    $link = $(e.target)
    url = $link.attr('href').replace(/\d+$/, watch_episode)

    $link.attr href: url
