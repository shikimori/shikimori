<template lang="pug">
  .block
    .cc-3-flex
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
            :original_value="group_name"
            :placeholder="I18n.t(`frontend.collections.group_name`)"
            @input="on_group_rename"
            type="text"
          )

        draggable.collection-links(
          :options="drag_options"
          @update="on_drag_update"
          @add="on_drag_add"
        )
          CollectionLink(
            v-for="link in grouped_links[group_name]"
            :key="link.id || link.key"
            :link="link"
            :link_index="links.indexOf(link)"
          )

      .c-column.new-group
        .b-button(
          @click="add_new_group"
        ) {{ I18n.t('actions.add') }}

</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import CollectionLink from './collection_link'
import draggable from 'vuedraggable'

function list_index(node, index) {
  return parseInt(node.childNodes[index].getAttribute('list_index'))
}
function restore_node(e) {
  removeNode(e.item)
  insertNodeAt(e.from, e.item, e.oldIndex)
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
    add_new_group (e) {
      if (e.target != e.currentTarget) { return }
      this.add_link({group: ''})
    },
    on_group_rename (e) {
      this.rename_group({
        from_name: e.target.getAttribute('original_value'),
        to_name: e.target.value
      })
    },
    on_drag_update (e) {
      restore_node(e)

      let from_index = list_index(e.to, e.oldIndex)
      let to_index = list_index(e.to, e.newIndex)

      this.move_link({
        from_index: from_index,
        to_index: to_index,
        group_index: to_index
      });
    },
    on_drag_add (e) {
      restore_node(e)
      let from_index = list_index(e.from, e.oldIndex)
      let is_last_column_position = !e.to.childNodes[e.newIndex]
      let to_index = is_last_column_position ?
        list_index(e.to, e.newIndex - 1) :
        list_index(e.to, e.newIndex)
      let group_index = to_index;

      let is_move_right = to_index > from_index
      let is_move_left = to_index < from_index

      if (is_move_right && !is_last_column_position) {
        to_index -= 1
      }
      if (is_move_left && is_last_column_position) {
        to_index += 1
      }

      this.move_link({
        from_index: from_index,
        to_index: to_index,
        group_index: group_index
      });
    },
    ...mapActions([
      'add_link',
      'move_link',
      'rename_group'
    ])
  },
  mounted() {
  }
}
</script>

<style scoped lang="sass">
@import app/assets/stylesheets/globals/variables

.new-group
  padding-top: 8px

.group
  label
    display: inline-block

  .add
    float: right
    font-size: 11px
    margin-right: 5px
    margin-top: 6px

    &:before
      font-family: shikimori
      position: absolute
      margin-left: -12px
      margin-top: 1px
      content: '+'

  input
    width: calc(100% - 6px)

.collection-links
  height: 100%
  min-height: 70px

  .b-button
    margin-left: 30px
</style>
