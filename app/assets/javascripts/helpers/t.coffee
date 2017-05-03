module.exports = window.t = (phrase, options) ->
  console?.warn 'This method is deprecated. Use I18n.t instead'
  I18n.t phrase, options
