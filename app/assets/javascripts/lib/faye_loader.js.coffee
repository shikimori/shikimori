# уведомлялка Faye
# назначение класса - слушать Faye и отправлять получившим обновление топикам и разделам события faye:success
class @FayeLoader
  constructor: ->
    @client = null
    @subscriptions = {}

    # привязка подписки/отписки каналов к событиям внешнего мира
    $(document).on 'page:load page:restore ajax:success postloader:success', @apply
    @apply()

  id: ->
    (if @client then @client._clientId else null)

  # подключение к Faye серверу
  connect: ->
    port = (if window.DEVELOP then ':9292' else '')
    @client = new Faye.Client "http://#{location.hostname}#{port}/faye-server",
      timeout: 300
      retry: 5
      #endpoints:
        #websocket: "http://#{location.hostname}:9292/faye-server"

    #client.disable 'eventsource'
    _log 'faye connected'

  # отписка ото всех не актуальных каналов
  unsubscribe: (channels) ->
    to_stay = Object.keys(channels)
    to_remove = _.without(Object.keys(@subscriptions), to_stay)

    to_remove.each (channel) =>
      @client.unsubscribe channel
      delete @subscriptions[channel]

      _log "faye unsubscribed #{channel}"

  # обновление уже существующих каналов
  update: (channels) ->
    keys = _.intersect(Object.keys(channels), Object.keys(@subscriptions))
    keys.each (channel) =>
      @subscriptions[channel].node = channels[channel]

  # подписка на ещё не подписанные каналы
  subscribe: (channels) ->
    keys = _.without(Object.keys(channels), Object.keys(@subscriptions))
    keys.each (channel) =>
      subscription = @client.subscribe channel, (data) =>
        # это колбек, в котором мы получили уведомление от faye
        _log ['faye:received', channel, data]
        # сообщения от самого себя не принимаем
        return if data.publisher_faye_id == @id()

        @subscriptions[channel].node.trigger "faye:#{data.event}", data

      @subscriptions[channel] =
        node: channels[channel]
        channel: subscription

      _log "faye subscribed #{channel}"

  # подписка/отписка на актуальные каналы Faye исходя из контента страницы
  apply: (e, data) =>
    $targets = $('.b-forum')
    $targets = $('.b-topic') unless $targets.length
    @connect() if !@client && $targets.length

    # список актуальных каналов из текущего dom дерева
    channels = {}
    $targets.each (index, node) ->
      found_channels = $(node).data('faye') || []
      _warn 'no faye channels found for', node unless found_channels.length || $targets.data('no-faye')

      found_channels.each (channel) ->
        channels["/#{channel}"] = $(node)

    @unsubscribe channels
    @update channels
    @subscribe channels
