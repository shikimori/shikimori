let uniqId = 987654321;
const newId = () => uniqId += 1;

const hasDuplicate = (links, link) =>
  links.some(v =>
    (v !== link) &&
      (v.linked_id === link.linked_id) &&
      (v.group === link.group)
  );

const noLinksToFill = (links, group) =>
  links.none(v => (v.group === group) && !v.linked_id);

module.exports = {
  state: {
    collection: {}
  },

  getters: {
    collection(store) { return store.collection; },
    links(store) { return store.collection.links; },
    groups(store) { return store.collection.links.map(v => v.group).unique(); },
    groupedLinks(store) { return store.collection.links.groupBy(v => v.group); }
  },

  actions: {
    fillLink(context, { link, changes }) {
      context.commit('FILL_LINK', { link, changes });

      if (hasDuplicate(context.state.collection.links, link)) {
        context.commit('REMOVE_LINK', link);
      }

      if (noLinksToFill(context.state.collection.links, link.group)) {
        context.commit('ADD_LINK', { group: link.group });
      }
    },

    addLink(context, data) { context.commit('ADD_LINK', data); },
    removeLink(context, data) { context.commit('REMOVE_LINK', data); },
    moveLink(context, data) { context.commit('MOVE_LINK', data); },
    renameGroup(context, data) { context.commit('RENAME_GROUP', data); },
    refill(context, data) { context.commit('REFILL', data); }
  },

  mutations: {
    ADD_LINK(state, linkData) {
      const link = Object.add(linkData, {
        group: null,
        linked_id: null,
        name: null,
        text: '',
        url: null,
        key: newId()
      }, { resolve: false });

      if (link.linked_id && hasDuplicate(state.collection.links, link)) { return; }

      const lastInGroup = state.collection.links
        .filter(v => v.group === link.group)
        .last();
      const index = state.collection.links.indexOf(lastInGroup);

      if (index !== -1) {
        state.collection.links.splice(index + 1, 0, link);
      } else {
        state.collection.links.push(link);
      }
    },

    REMOVE_LINK(state, link) {
      state.collection.links.splice(
        state.collection.links.indexOf(link),
        1
      );
    },

    MOVE_LINK(state, { fromIndex, toIndex, groupIndex }) {
      const { group } = state.collection.links[groupIndex];
      const fromElement = state.collection.links.splice(fromIndex, 1)[0];

      if (fromElement.group !== group) { fromElement.group = group; }

      if (!hasDuplicate(state.collection.links, fromElement)) {
        state.collection.links.splice(toIndex, 0, fromElement);
      }
    },

    RENAME_GROUP(state, { fromName, toName }) {
      state.collection.links.forEach(link => {
        if (link.group === fromName) {
          link.group = toName;
        }
      });
    },

    FILL_LINK(state, { link, changes }) {
      Object.forEach(changes, (value, key) => link[key] = value);
    },

    REFILL(state, data) {
      state.collection.links = data;
    }
  },

  modules: {}
};
