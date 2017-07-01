using 'Animes'
class Animes.WathOnlineButton extends View
  TEMPLATE_PATH = 'animes/watch_online_button'

  initialize: (@options) ->
    return unless @options.is_allowed
    @total_episodes = @$root.data('total_episodes') || 9999

    @_render()
    delay().then => @_setup_handlers()

  _render: ->
    if @options.is_licensed
      @$root.html JST["#{TEMPLATE_PATH}/licensed"]()

    else if @options.is_censored
      @$root.html JST["#{TEMPLATE_PATH}/censored"]()

    else if @options.has_videos
      @$root.html JST["#{TEMPLATE_PATH}/watch"](url: @options.watch_url)

    else
      @$root.html JST["#{TEMPLATE_PATH}/upload"](url: @options.upload_url)

  _setup_handlers: =>
    @$('.watch-online').on 'click', @_click

  _click: (e) =>
    episode = parseInt($('.b-db_entry .b-user_rate .current-episodes').html())
    watch_episode = if !episode || episode == @total_episodes then 1 else episode + 1

    $link = $(e.target)
    url = $link.attr('href').replace(/\d+$/, watch_episode)

    $link.attr href: url
