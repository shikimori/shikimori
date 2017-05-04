Vue = require 'vue/dist/vue.js'
Vuex = require 'vuex/dist/vuex.js'

Vue.use Vuex
Vue.prototype.I18n = I18n

module.exports = { Vue, Vuex }
