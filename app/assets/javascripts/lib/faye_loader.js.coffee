# уведомлялка Faye
# назначение класса - слушать Faye и отправлять получившим обновление топикам и разделам события faye:success
@FayeLoader = ->
  client = null
  subscriptions = {}
  FAYE_NODE_REGEXP = /(?:topic|section|user|group)-\d+|myfeed/

  # подключение к Faye серверу
  connect = ->
    port = (if window.DEVELOP then ':9292' else '')
    client = new Faye.Client("http://#{location.hostname}#{port}/faye-server",
      timeout: 300
      retry: 5
      endpoints:
        websocket: "http://#{location.hostname}:9292/faye-server"
    )
    #client.disable 'eventsource'
    _log 'faye connected'

  # отписка ото всех не актуальных каналов
  unsubscribe = (channels) ->
    to_stay = _.keys(channels)
    to_remove = _.without(_.keys(subscriptions), to_stay)

    _.each to_remove, (channel) ->
      client.unsubscribe channel
      delete subscriptions[channel]

      _log "faye unsubscribed #{channel}"

  # обновление уже существующих каналов
  update = (channels) ->
    keys = _.intersect(_.keys(channels), _.keys(subscriptions))
    _.each keys, (channel) ->
      subscriptions[channel].node = channels[channel]

  # подписка на ещё не подписанные каналы
  subscribe = (channels) ->
    keys = _.without(_.keys(channels), _.keys(subscriptions))
    _.each keys, (channel) ->

      subscription = client.subscribe channel, (data) ->
        # это колбек, в котором мы получили уведомление от faye
        _log ['faye:received', data]
        # сообщения от самого себя не принимаем
        return if data.publisher_faye_id == client._clientId

        # TODO: выпилить это. временный костыль на время beta с изменённым протоколом faye
        if data.event != 'deleted' && data.event != 'updated' && data.event != 'created'
          data.event = data.event.replace(/.*:/, '')

        subscriptions[channel].node.trigger 'faye:success', data

      subscriptions[channel] =
        node: channels[channel]
        channel: subscription

      _log "faye subscribed #{channel}"

  # подписка/отписка на актуальные каналы Faye исходя из контента страницы
  apply = (e, data) ->
    $targets = $('.b-topics')
    $targets = $('.b-topic') unless $targets.length
    connect() if !client && $targets.length

    # список актуальных каналов из текущего dom дерева
    channels = {}
    $targets.each (index, node) ->
      found_channels = $(node).data('faye') || []
      console.warn 'no faye channels found for', node unless found_channels.length

      found_channels.each (channel) ->
        channels["/#{channel}"] = $(node)

    unsubscribe channels
    update channels
    subscribe channels

  # привязка подписки/отписки каналов к событиям внешнего мира
  $(document).on 'page:load page:restore ajax:success postloader:success', apply

  apply()

  apply: apply
  client: ->
    client

  id: ->
    (if client then client._clientId else null)

  subscriptions: ->
    subscriptions
