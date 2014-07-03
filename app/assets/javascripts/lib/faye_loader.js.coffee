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
        subscriptions[channel].node.trigger 'faye:success', data

      subscriptions[channel] =
        node: channels[channel]
        channel: subscription

      _log "faye subscribed #{channel}"

  # подписка/отписка на актуальные каналы Faye исходя из контента страницы
  apply = (e, data) ->
    $targets = $('.section-block')
    $targets = $('.topic-block')  unless $targets.length
    connect() if not client and $targets.length

    # список актуальных каналов из текущего dom дерева
    channels = {}
    _.each $targets, (node, k) ->
      found_channels = _.select(node.className.split(' '), (v) ->
        v.match FAYE_NODE_REGEXP
      )
      _.each found_channels, (v) ->
        channel = "/" + v.match(FAYE_NODE_REGEXP)[0]
        channels[channel] = $(node)

    unsubscribe channels
    update channels
    subscribe channels

  # привязка подписки/отписки каналов к событиям внешнего мира
  $('.ajax').live 'ajax:success postloader:success', apply

  apply: apply
  client: ->
    client

  id: ->
    (if client then client._clientId else null)

  subscriptions: ->
    subscriptions
