using 'Topics'
class Topics.Tracker
  @track: (topics, $root) ->
    topics.each (topic) ->
      new Topics.TrackTopic topic, $root
