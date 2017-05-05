import { Vue } from 'vue/instance'
import Vuex from 'vuex'

Vue.use Vuex

store = new Vuex.Store
  state:
    collection: {}

  actions:
    add_link: (context, value) ->
      context.commit 'ADD_LINK', value

    remove_link: (context, value) ->
      context.commit 'REMOVE_LINK', value

  mutations:
    ADD_LINK: (state, value) ->
      state.collection.links.push value

    REMOVE_LINK: (state, value) ->
      state.collection.links.splice(
        state.collection.links.indexOf(value),
        1
      )

  getters:
    collection: (store) ->
      store.collection

    links: (store) ->
      store.collection.links

    groups: (store) ->
      store.collection.links
        .map (v) -> v.group
        .unique()

    grouped_links: (store) ->
      store.collection.links
        .groupBy (v) -> v.group

  modules: {}

export { store }
