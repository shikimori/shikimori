Faye = require 'faye'
require 'jquery.idle/vanilla.idle'

# уведомлялка Faye
# назначение класса - слушать Faye и отправлять получившим обновление топикам и разделам события faye:success
module.exports = class FayeLoader
  WORLD_CHANGED_EVENTS = [
    'page:load'
    'page:restore'
    'ajax:success'
    'postloader:success'
  ]
  INACTIVITY_INTERVAL = 10 * 60 * 1000

  constructor: ->
    @client = null
    @subscriptions = {}

    @_apply()

    # refresh subscruptions when something is changed in outside world
    $(document).on WORLD_CHANGED_EVENTS.join(' '), @_apply
    # disconnect faye after 10 minutes of user inactivity
    idle(
      onIdle: =>
        if @client
          console.log "faye disconnect on idle"
          @_disconnect()
      onActive: =>
        unless @client
          console.log "faye connect on active"
          @_connect()
          @_apply()
      idle: INACTIVITY_INTERVAL
    ).start()

  id: ->
    @client?._dispatcher?.clientId

  # подписка/отписка на актуальные каналы Faye исходя из контента страницы
  _apply: =>
    $targets = $('.b-forum')
    $targets = $('.b-topic') unless $targets.length
    @_connect() if !@client && $targets.length

    # список актуальных каналов из текущего dom дерева
    channels = {}
    $targets.each (index, node) ->
      faye_channels = $(node).data('faye')
      if faye_channels != false && Object.isEmpty(faye_channels)
        console.warn 'no faye channels found for', node

      if faye_channels
        faye_channels.forEach (channel) ->
          channels["/#{channel}"] = $(node)

    @_unsubscribe channels
    @_update channels
    @_subscribe channels

  # подключение к Faye серверу
  _connect: ->
    port = if ENV == 'development' then ':9292' else ''
    # hostname = (if ENV == 'development' then 'localhost' else location.hostname)
    hostname = location.hostname

    @client = new Faye.Client "#{location.protocol}//#{hostname}#{port}/faye-server-v5",
      timeout: 300
      retry: 5
      # endpoints:
        # websocket: "#{location.protocol}//#{location.hostname}#{port}/faye-server-v5"

    #@client.disable 'eventsource'
    @client.disable('websocket') if $.cookie('faye-disable-websocket')
    # console.log 'faye connected'

  _disconnect: ->
    @client.disconnect()
    @client = null
    @subscriptions = {}

  # отписка ото всех не актуальных каналов
  _unsubscribe: (channels) ->
    to_stay = Object.keys(channels)
    to_remove = Object.keys(@subscriptions).subtract(to_stay)

    to_remove.forEach (channel) =>
      @client.unsubscribe channel
      delete @subscriptions[channel]

      console.log "faye unsubscribed #{channel}"

  # обновление уже существующих каналов
  _update: (channels) ->
    Object.keys(channels)
      .intersect(Object.keys(@subscriptions))
      .forEach (channel) =>
        @subscriptions[channel].node = channels[channel]

  # подписка на ещё не подписанные каналы
  _subscribe: (channels) ->
    Object.keys(channels)
      .subtract(Object.keys(@subscriptions))
      .forEach (channel) =>
        subscription = @client.subscribe channel, (data) =>
          # это колбек, в котором мы получили уведомление от faye
          console.log ['faye:received', channel, data]
          # сообщения от самого себя не принимаем
          return if data.publisher_faye_id == @id()

          @subscriptions[channel].node.trigger "faye:#{data.event}", data

        @subscriptions[channel] =
          node: channels[channel]
          channel: subscription

        console.log "faye subscribed #{channel}"
