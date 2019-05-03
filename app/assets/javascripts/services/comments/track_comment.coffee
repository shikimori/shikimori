$with = require('helpers/with').default

module.exports = class TrackComment
  constructor: (comment, $root) ->
    $with(@_selector(comment), $root)
      .data(model: comment)

  _selector: (comment) ->
    ".b-comment##{comment.id}"
