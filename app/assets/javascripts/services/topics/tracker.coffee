using 'Topics'
class Topics.Tracker
  @track: (JS_EXPORTS, $root) ->
    return if Object.isEmpty(JS_EXPORTS?.topics)

    JS_EXPORTS.topics.forEach (topic) ->
      new Topics.TrackTopic topic, $root

    JS_EXPORTS.topics = null
