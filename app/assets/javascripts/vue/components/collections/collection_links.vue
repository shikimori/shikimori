<template lang="pug">
  .block
    .block
      .b-options-floated {{ `${links.length} / ${max_links}` }}
      .subheadline.m10 {{ I18n.t(`frontend.collections.kind.${collection.kind}`) }}
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
                v-if="links.length < max_links"
                @click="add_link({group: group_name})"
              ) {{ I18n.t('actions.add').toLowerCase() }}
            input(
              :id="'group_' + group_name"
              :value="group_name"
              :data-original_value="group_name"
              :placeholder="I18n.t('frontend.collections.group_name')"
              @blur="on_group_rename"
              @change="on_group_rename"
              @keydown.enter.prevent="on_group_rename"
              type="text"
            )

          draggable.collection_links(
            :options="drag_options"
            @update="on_drag_update"
            @add="on_drag_add"
          )
            CollectionLink(
              v-for="link in grouped_links[group_name]"
              :key="link.id || link.key"
              :link="link"
              :autocomplete_url="autocomplete_url"
            )

        .c-column.new-group(
          v-if="links.length < max_links"
        )
          div(
            v-if="Object.isEmpty(grouped_links[''])"
          )
            .b-button(
              @click="add_new_group"
            ) {{ I18n.t('actions.add') }}
          div(
            v-if="!Object.isEmpty(grouped_links[''])"
          )
            .button-container
              .b-button.disabled {{ I18n.t('actions.add') }}
            .hint {{ I18n.t('frontend.collections.disabled_add_group_hint') }}

    .block.json
      .subheadline JSON
      .b-spoiler.unprocessed
        label {{ I18n.t('frontend.collections.json_warning') }}
        .content
          .before
          .inner
            .b-input
              textarea(
                @change="on_refill"
                @keydown.ctrl.enter="on_refill"
                @keydown.meta.enter="on_refill"
                @focus.once="add_autosize"
                v-bind:value="links_json"
              )
          .after

</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import draggable from 'vuedraggable'
import autosize from 'autosize'

import flash from 'services/flash'
import CollectionLink from './collection_link'

function list_index(node, index) {
  return parseInt(node.childNodes[index].getAttribute('data-list_index'))
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
  props: {
    max_links: Number,
    autocomplete_url: String
  },
  data () {
    return {
      drag_options: {
        group: 'collection_links',
        handle: '.drag-handle'
      }
    }
  },
  computed: {
    links_json() {
      return JSON.stringify(this.links)
    },
    ...mapGetters([
      'collection',
      'links',
      'groups',
      'grouped_links',
    ]),
  },
  methods: {
    add_new_group(e) {
      if (e.target != e.currentTarget) { return }
      this.add_link({group: ''})
    },
    on_group_rename(e) {
      this.rename_group({
        from_name: e.target.getAttribute('data-original_value'),
        to_name: e.target.value
      })
    },
    on_refill({target}) {
      let json;
      try {
        json = JSON.parse(target.value);
      } catch(e) {
        flash.error(e.toString())
      }

      if (json) {
        this.refill(json)
      }
    },
    add_autosize({target}) {
      autosize(target)
    },
    on_drag_update(e) {
      restore_node(e)

      let from_index = list_index(e.to, e.oldIndex)
      let to_index = list_index(e.to, e.newIndex)

      this.move_link({
        from_index: from_index,
        to_index: to_index,
        group_index: to_index
      });
    },
    on_drag_add(e) {
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
      'rename_group',
      'refill'
    ])
  },
  mounted() {
    this.$nextTick(() => {
      $('.json', this.$el).process()
    })
  }
}
</script>

<style scoped lang="sass">
  @import "app/assets/stylesheets/globals/variables"
  .new-group
    padding-top: 8px

    .button-container
      display: table-cell
      margin-top: -8px
      vertical-align: middle

    .hint
      color: #9da2a8
      display: table-cell
      font-size: 11px
      line-height: $line_height
      vertical-align: middle
      padding-left: 15px

  .group
    label
      display: inline-block
      font-weight: bold

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
      overflow: hidden
      text-overflow: ellipsis
      white-space: nowrap
      width: calc(100% - 6px)

  .collection_links
    height: 100%
    min-height: 70px

    .b-button
      margin-left: 30px

  .json
    .b-spoiler
      .before
        display: inline-block
        margin-bottom: 4px

      .after
        padding: 0

      .b-input
        line-height: 0

      textarea
        font-family: monospace, courier
        font-size: 11px
        min-height: 98px
</style>
