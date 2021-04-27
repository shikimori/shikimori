import Vue from 'vue';
import Vuex from 'vuex';

Vue.config.productionTip = false;
// Vue.config.devtools = false;

Vue.prototype.I18n = I18n;

// Vue = require('vue/instance').Vue
// Vuex = require('vuex')

Vue.use(Vuex);

export { Vue, Vuex };
