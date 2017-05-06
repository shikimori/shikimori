<template lang="pug">
  .cc-3
    .c-column(
      v-for='group_name in groups'
    )
      .b-input.group
        div
          label(
            :for="'group_' + group_name"
          ) {{ I18n.t('activerecord.attributes.collection_link.group') }}
          .add.b-js-link(
            @click="add_link({group: group_name})"
          ) {{ I18n.t('actions.add').toLowerCase() }}
        input(
          :id="'group_' + group_name"
          :value="group_name"
          type="text"
        )

      draggable.collection-links(
        :options="drag_options"
        @update="drag_update"
        @add="drag_add"
      )
        CollectionLink(
          v-for="link in grouped_links[group_name]"
          :key="link.id"
          :link="link"
          :link_index="links.indexOf(link)"
        )
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import CollectionLink from './collection_link'
import draggable from '../../plugins/vuedraggable-patched'

function list_index(node, index) {
  return parseInt(node.childNodes[index].getAttribute('list_index'))
}
function removeNode(node) {
  node.parentElement.removeChild(node)
}
function insertNodeAt(fatherNode, node, position) {
  if (position < fatherNode.children.length) {
    fatherNode.insertBefore(node, fatherNode.children[position])
  } else {
    fatherNode.appendChild(node)
  }
}

export default {
  components: { CollectionLink, draggable },
  data () {
    return {
      drag_options: {
        group: 'collection_links',
        handle: '.drag-handle'
      }
    }
  },
  computed: {
    ...mapGetters([
      'links',
      'groups',
      'grouped_links'
    ]),
  },
  methods: {
    drag_update (e) {
      removeNode(e.item)
      insertNodeAt(e.from, e.item, e.oldIndex)

      let from_index = list_index(e.to, e.oldIndex)
      let to_index = list_index(e.to, e.newIndex)

      this.move_link({from_index: from_index, to_index: to_index});
    },
    drag_add (e) {
    },
    ...mapActions([
      'add_link',
      'move_link'
    ])
  }
}
</script>

<style scoped lang="sass">
.group
  label
    display: inline-block

  .add
    margin-left: 6px

  input
    width: calc(100% - 6px)

.collection-links
  min-height: 70px
</style>
