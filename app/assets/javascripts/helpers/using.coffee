module.exports = window.using = (names) ->
  scope = window
  names.split('.').forEach (name) ->
    scope[name] ||= {}
    scope = scope[name]
