Vuex = require('./instance').Vuex

module.exports = new Vuex.Store
  state:
    collection_links: []

  actions:
    add_collection_link: (context, value) ->
      context.commit 'ADD_COLLECTION_LINK', value

  mutations:
    ADD_COLLECTION_LINK: (state, value) ->
      state.collection_links.push value

  getters:
    collection_links: (store) -> store.collection_links

  modules: {}
