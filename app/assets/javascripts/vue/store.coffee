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

    move_link: (context, from_index, to_index) ->
      context.commit 'MOVE_LINK', from_index, to_index

  mutations:
    ADD_LINK: (state, value) ->
      last_in_group = state.collection.links
        .filter (v) -> v.group == value.group
        .last()
      index = state.collection.links.indexOf(last_in_group)
      state.collection.links.splice(index + 1, 0, value)

    REMOVE_LINK: (state, value) ->
      state.collection.links.splice(
        state.collection.links.indexOf(value),
        1
      )

    MOVE_LINK: (state, {from_index, to_index, group_index}) ->
      group = state.collection.links[group_index].group
      from_element = state.collection.links.splice(from_index, 1)[0]

      from_element.group = group unless from_element.group == group
      state.collection.links.splice(to_index, 0, from_element)

  getters:
    autocomplete_url: -> store.autocomplete_url
    collection: (store) -> store.collection
    links: (store) -> store.collection.links
    groups: (store) -> store.collection.links.map((v) -> v.group).unique()
    grouped_links: (store) -> store.collection.links.groupBy((v) -> v.group)

  modules: {}

window.store = store unless process.env.NODE_ENV == 'production'
export { store }
