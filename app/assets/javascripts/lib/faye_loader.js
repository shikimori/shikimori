// уведомлялка Faye
// назначение класса - слушать Faye и отправлять получившим обновление топикам и разделам события faye:success
function FayeLoader() {
  var client = null;
  var subscriptions = {};
  var FAYE_NODE_REGEXP = /(?:topic|section|user|group)-\d+|myfeed/;

  // подключение к Faye серверу
  var connect = function() {
    port = window.DEVELOP ? ':9292' : '';
    client = new Faye.Client('http://' + location.hostname + port + '/faye-server', {
      timeout: 300,
      retry: 5,
      endpoints: {
        websocket: 'http://' + location.hostname + ':9292/faye-server'
      }
    });
    client.disable('eventsource');
    _log('faye connected');
  }
  // отписка ото всех не актуальных каналов
  var unsubscribe = function(channels) {
    var to_stay = _.keys(channels);
    var to_remove = _.without(_.keys(subscriptions), to_stay);

    _.each(to_remove, function(channel) {
      client.unsubscribe(channel);
      delete subscriptions[channel];

      _log('faye unsubscribed ' + channel);
    });
  }
  // обновление уже существующих каналов
  var update = function(channels) {
    var keys = _.intersect(_.keys(channels), _.keys(subscriptions));
    _.each(keys, function(channel) {
      subscriptions[channel].node =  channels[channel];
    });
  }
  // подписка на ещё не подписанные каналы
  var subscribe = function(channels) {
    var keys = _.without(_.keys(channels), _.keys(subscriptions));

    _.each(keys, function(channel) {
      var subscription = client.subscribe(channel, function(data) {
        //_log('faye subscribe triggered');
        subscriptions[channel].node.trigger('faye:success', data);
      });

      subscriptions[channel] = {
        node: channels[channel],
        channel: subscription
      };

      _log('faye subscribed ' + channel);
    });
  }
  // подписка/отписка на актуальные каналы Faye исходя из контента страницы
  var apply = function(e, data) {
    var $targets = $('.section-block');
    if (!$targets.length) {
      $targets = $('.topic-block');
    }

    if (!client && $targets.length) {
      connect();
    }

    // список актуальных каналов из текущего dom дерева
    var channels = {};
    _.each($targets, function(node,k) {
      var found_channels = _.select(node.className.split(' '), function(v) { return v.match(FAYE_NODE_REGEXP) });
      _.each(found_channels, function(v) {
        var channel = '/' + v.match(FAYE_NODE_REGEXP)[0];
        channels[channel] = $(node);
      });
    });

    unsubscribe(channels);
    update(channels);
    subscribe(channels);
  }

  // привязка подписки/отписки каналов к событиям внешнего мира
  $('.ajax').live('ajax:success postloader:success', apply);

  return {
    apply: apply,
    client: function() {
      return client;
    },
    id: function() {
      return client ? client._clientId : null;
    },
    subscriptions: function() {
      return subscriptions;
    }
  }
}
