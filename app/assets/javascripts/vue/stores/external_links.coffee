{ Vue, Vuex } = require('vue/instance')

uniq_id = 987654321
new_id = -> uniq_id += 1

module.exports = new Vuex.Store
  state:
    external_links: []

  actions:
    reorder: (context, value) -> context.commit 'REORDER', value
    add_link: (context, value) -> context.commit 'ADD_LINK', value
    remove_link: (context, data) -> context.commit 'REMOVE_LINK', data

  mutations:
    REORDER: (state, reordered_external_links) ->
      state.external_links = reordered_external_links

    ADD_LINK: (state, link_data) ->
      state.external_links.push link_data

    REMOVE_LINK: (state, link) ->
      state.external_links.splice(
        state.external_links.indexOf(link),
        1
      )

  getters:
    external_links: (store) -> store.external_links

  modules: {}
