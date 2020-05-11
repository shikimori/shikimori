let uniqId = 987654321;
const newId = () => uniqId += 1;

// store for simple collection of items
module.exports = {
  state: {
    collection: []
  },

  actions: {
    replace({ commit }, value) { commit('REPLACE', value); },
    add({ commit }, value) { commit('ADD', value); },
    remove({ commit }, data) { commit('REMOVE', data); },
  },

  mutations: {
    REPLACE(state, newCollection) {
      state.collection = newCollection;
    },

    ADD(state, itemData) {
      state.collection.push(Object.add(itemData, { key: newId() }));
    },

    REMOVE(state, item) {
      state.collection.splice(state.collection.indexOf(item), 1);
    }
  },

  getters: {
    collection(store) { return store.collection; },
    isEmpty(store) {
      return store.collection.every(item =>
        Object.isEmpty(item.url) && Object.isEmpty(item.value) && Object.isEmpty(item.name)
      );
    }
  },

  modules: {}
};
