# уведомлялка Faye
# назначение класса - слушать Faye и отправлять получившим обновление топикам и разделам события faye:success
module.exports = class FayeLoader
  constructor: ->
    @client = null
    @subscriptions = {}

    # привязка подписки/отписки каналов к событиям внешнего мира
    $(document).on 'page:load page:restore ajax:success postloader:success', @apply
    @apply()

  id: ->
    @client?._dispatcher?.clientId

  # подключение к Faye серверу
  connect: ->
    port = (if ENV == 'development' then ':9292' else '')
    hostname = (if ENV == 'development' then 'localhost' else location.hostname)
    @client = new Faye.Client "#{location.protocol}//#{hostname}#{port}/faye-server-new",
      timeout: 300
      retry: 5
      #endpoints:
        #websocket: "#{location.protocol}//#{location.hostname}:9292/faye-server-new"

    #@client.disable 'eventsource'
    console.log 'faye connected'

  # отписка ото всех не актуальных каналов
  unsubscribe: (channels) ->
    to_stay = Object.keys(channels)
    to_remove = Object.keys(@subscriptions).subtract(to_stay)

    to_remove.forEach (channel) =>
      @client.unsubscribe channel
      delete @subscriptions[channel]

      console.log "faye unsubscribed #{channel}"

  # обновление уже существующих каналов
  update: (channels) ->
    keys = Object.intersect(Object.keys(channels), Object.keys(@subscriptions))
    keys.forEach (channel) =>
      @subscriptions[channel].node = channels[channel]

  # подписка на ещё не подписанные каналы
  subscribe: (channels) ->
    keys = Object.keys(channels).subtract Object.keys(@subscriptions)
    keys.forEach (channel) =>
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

  # подписка/отписка на актуальные каналы Faye исходя из контента страницы
  apply: =>
    $targets = $('.b-forum')
    $targets = $('.b-topic') unless $targets.length
    @connect() if !@client && $targets.length

    # список актуальных каналов из текущего dom дерева
    channels = {}
    $targets.each (index, node) ->
      found_channels = $(node).data('faye') || []
      console.warn 'no faye channels found for', node unless found_channels.length || $targets.data('no-faye')

      found_channels.forEach (channel) ->
        channels["/#{channel}"] = $(node)

    @unsubscribe channels
    @update channels
    @subscribe channels
