module.exports = class TrackComment
  MARK = 'not-tracked'

  constructor: (comment, $root) ->
    $with(".#{MARK}#{@_selector comment}", $root)
      .removeClass(MARK)
      .data(model: comment)

  _selector: (comment) ->
    ".b-comment##{comment.id}"
