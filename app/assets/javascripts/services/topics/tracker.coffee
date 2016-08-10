using 'Topics'
class Topics.Tracker
  @track: (topics, $root) ->
    return if Object.isEmpty(topics)

    topics.each (topic) ->
      new Topics.TrackTopic topic, $root
