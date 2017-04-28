module.exports = class TrackTopic
  MARK = 'not-tracked'

  constructor: (topic, $root) ->
    $with(".#{MARK}#{@_selector topic}", $root)
      .removeClass(MARK)
      .data(model: topic)

  _selector: (topic) ->
    ".b-topic##{topic.id}"
