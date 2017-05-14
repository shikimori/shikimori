import { Vue } from 'vue/instance'
import Vuex from 'vuex'

Vue.use Vuex

uniq_id = 987654321
new_id = -> uniq_id += 1

has_duplicate = (links, link) ->
  links.some (v) ->
    v != link &&
      v.linked_id == link.linked_id &&
      v.group == link.group

no_links_to_fill = (links, group) ->
  links.none (v) ->
    v.group == group && !v.linked_id

store = new Vuex.Store
  state:
    collection: {}
    autocomplete_url: ''
    node_env: ''
    max_links: 0

  actions:
    fill_link: (context, {link, changes}) ->
      context.commit 'FILL_LINK', {link, changes}

      if has_duplicate(context.state.collection.links, link)
        context.commit 'REMOVE_LINK', link

      if no_links_to_fill(context.state.collection.links, link.group)
        context.commit 'ADD_LINK', { group: link.group }

    add_link: (context, data) -> context.commit 'ADD_LINK', data
    remove_link: (context, data) -> context.commit 'REMOVE_LINK', data
    move_link: (context, data) -> context.commit 'MOVE_LINK', data
    rename_group: (context, data) -> context.commit 'RENAME_GROUP', data

  mutations:
    ADD_LINK: (state, link_data) ->
      link = Object.add link_data, {
          group: null
          linked_id: null
          name: null
          text: null
          url: null
          key: new_id()
        }, resolve: false

      return if link.linked_id && has_duplicate(state.collection.links, link)

      last_in_group = state.collection.links
        .filter (v) -> v.group == link.group
        .last()
      index = state.collection.links.indexOf(last_in_group)

      if index != -1
        state.collection.links.splice(index + 1, 0, link)
      else
        state.collection.links.push link

    REMOVE_LINK: (state, link) ->
      state.collection.links.splice(
        state.collection.links.indexOf(link),
        1
      )

    MOVE_LINK: (state, {from_index, to_index, group_index}) ->
      group = state.collection.links[group_index].group
      from_element = state.collection.links.splice(from_index, 1)[0]

      from_element.group = group unless from_element.group == group

      unless has_duplicate(state.collection.links,from_element)
        state.collection.links.splice(to_index, 0, from_element)

    RENAME_GROUP: (state, {from_name, to_name}) ->
      state.collection.links.forEach (link) ->
        link.group = to_name if link.group == from_name

    FILL_LINK: (state, {link, changes}) ->
      Object.forEach changes, (value, key) ->
        link[key] = value

  getters:
    autocomplete_url: (store) -> store.autocomplete_url
    collection: (store) -> store.collection
    links: (store) -> store.collection.links
    groups: (store) -> store.collection.links.map((v) -> v.group).unique()
    grouped_links: (store) -> store.collection.links.groupBy((v) -> v.group)
    node_env: (store) -> store.node_env
    max_links: (store) -> store.max_links

  modules: {}

window.store = store unless process.env.NODE_ENV == 'production'
export { store }
