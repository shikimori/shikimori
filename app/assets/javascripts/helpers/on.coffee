bindings = require './bindings'

module.exports = window.on = (event, conditions..., callback) ->
  bindings[event].push
    conditions: conditions
    callback: callback
