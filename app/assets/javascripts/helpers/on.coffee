bindings = require './bindings'

window.on = (event, conditions..., callback) ->
  bindings[event].push
    conditions: conditions
    callback: callback

window.page_load = (conditions..., callback) ->
  bindings['page:load'].push
    conditions: conditions
    callback: callback

window.page_restore = (conditions..., callback) ->
  bindings['page:restore'].push
    conditions: conditions
    callback: callback

module.exports =
  on: window.on
  page_load: window.page_load
