import { Vue, Vuex } from 'vue/instance'

uniq_id = 987654321
new_id = -> uniq_id += 1

# store for simple collection of items
module.exports = new Vuex.Store
  state:
    collection: []

  actions:
    replace: (context, value) -> context.commit 'REPLACE', value
    add: (context, value) -> context.commit 'ADD', value
    remove: (context, data) -> context.commit 'REMOVE', data

  mutations:
    REPLACE: (state, new_collection) ->
      state.collection = new_collection

    ADD: (state, item_data) ->
      state.collection.push Object.add(item_data, key: new_id())

    REMOVE: (state, item) ->
      state.collection.splice(
        state.collection.indexOf(item),
        1
      )

  getters:
    collection: (store) -> store.collection
    is_empty: (store) ->
      store.collection.every (item) ->
        Object.isEmpty(item.url) &&
          Object.isEmpty(item.name) &&
          Object.isEmpty(item.name)

  modules: {}
