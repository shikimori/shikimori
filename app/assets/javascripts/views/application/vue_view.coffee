module.exports = class VueView extends View
  constructor: (node, arg1, arg2, arg3) ->
    @_initialize node

    require.ensure [], =>
      @Vue = require 'vue/dist/vue.js'
      @app = new @Vue @initialize(arg1, arg2, arg3)
      @_after_initialize()
