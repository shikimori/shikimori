$with = require('helpers/with').default

module.exports = class TrackTopic
  constructor: (topic, $root) ->
    $with(@_selector(topic), $root)
      .data(model: topic)

  _selector: (topic) ->
    ".b-topic##{topic.id}"
