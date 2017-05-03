TrackTopic = require './track_topic'

module.exports = class TopicsTracker
  @track: (JS_EXPORTS, $root) ->
    return if Object.isEmpty(JS_EXPORTS?.topics)

    JS_EXPORTS.topics.forEach (topic) ->
      new TrackTopic topic, $root

    JS_EXPORTS.topics = null
