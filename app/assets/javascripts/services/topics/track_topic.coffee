using 'Topics'
class Topics.TrackTopic
  MARK = 'not-tracked'

  constructor: (topic, $root) ->
    $root.find(".#{MARK}#{@_selector topic}")
      .removeClass(MARK)
      .data(entry_data: topic)

  _selector: (topic) ->
    ".b-topic##{topic.id}"
