<template lang="pug">
  .block
    .block(
      v-if="!links.length"
    )
      .b-button(
        @click="add_new_group"
      ) {{ I18n.t('actions.add') }}

    .cc-3-flex(
      v-if="links.length"
    )
      .c-column(
        v-for='group_name in groups'
      )
        .b-input.group
          div
            label(
              :for="'group_' + group_name"
            ) {{ I18n.t('activerecord.attributes.collection_link.group') }}
            .add(
              @click="add_link({group: group_name})"
            )
          input(
            :id="'group_' + group_name"
            :value="group_name"
            :original_value="group_name"
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
            :key="link.id"
            :link="link"
            :link_index="links.indexOf(link)"
          )

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

.group
  label
    display: inline-block

  .add
    color: #123
    cursor: pointer
    display: inline-block
    font-family: shikimori
    margin-left: 6px
    vertical-align: middle

    &:before
      content: '+'

    &:hover
      color: $link-hover

    &:active
      color: $link-active

  input
    width: calc(100% - 6px)

@media only screen and (min-width: $ipad_max+1)
  .c-column
    max-width: 30.66667%

.collection-links
  height: 100%
  min-height: 70px

  .b-button
    margin-left: 30px

</style>
