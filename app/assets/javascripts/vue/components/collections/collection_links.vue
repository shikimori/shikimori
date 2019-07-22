<template lang='pug'>
  .block
    .block
      .b-options-floated {{ `${links.length} / ${maxLinks}` }}
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
                v-if="links.length < maxLinks"
                @click="add_link({group: group_name})"
              ) {{ I18n.t('actions.add').toLowerCase() }}
            input(
              :id="'group_' + group_name"
              :value="group_name"
              :data-original_value="group_name"
              :placeholder="I18n.t('frontend.collections.group_name')"
              @blur="onGroupRename"
              @change="onGroupRename"
              @keydown.enter.prevent="onGroupRename"
              type="text"
            )

          draggable.collection_links(
            :options="dragOptions"
            @update="onDragUpdate"
            @add="onDragAdd"
          )
            CollectionLink(
              v-for="link in grouped_links[group_name]"
              :key="link.id || link.key"
              :link="link"
              :autocomplete_url="autocompleteUrl"
            )

        .c-column.new-group(
          v-if="links.length < maxLinks"
        )
          div(
            v-if="Object.isEmpty(grouped_links[''])"
          )
            .b-button(
              @click="addNewGroup"
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
                @change="onRefill"
                @keydown.ctrl.enter="onRefill"
                @keydown.meta.enter="onRefill"
                @focus.once="addAutosize"
                v-bind:value="linksJSON"
              )
          .after
</template>

<script>
import { mapGetters, mapActions } from 'vuex';
import draggable from 'vuedraggable';
import autosize from 'autosize';

import flash from 'services/flash';
import CollectionLink from './collection_link';

function listIndex(node, index) {
  return parseInt(node.childNodes[index].getAttribute('data-listIndex'));
}
function restoreNode(e) {
  removeNode(e.item);
  insertNodeAt(e.from, e.item, e.oldIndex);
}
function removeNode(node) {
  node.parentElement.removeChild(node);
}
function insertNodeAt(fatherNode, node, position) {
  if (position < fatherNode.children.length) {
    fatherNode.insertBefore(node, fatherNode.children[position]);
  } else {
    fatherNode.appendChild(node);
  }
}

export default {
  components: { CollectionLink, draggable },
  props: {
    maxLinks: { type: Number, required: true },
    autocompleteUrl: { type: String, required: true }
  },
  data: () => ({
    dragOptions: {
      group: 'collection_links',
      handle: '.drag-handle'
    }
  }),
  computed: {
    ...mapGetters([
      'collection',
      'links',
      'groups',
      'grouped_links'
    ]),
    linksJSON() {
      return JSON.stringify(this.links);
    }
  },
  mounted() {
    this.$nextTick(() => {
      $('.json', this.$el).process();
    });
  },
  methods: {
    ...mapActions([
      'add_link',
      'move_link',
      'rename_group',
      'refill'
    ]),
    addNewGroup(e) {
      if (e.target != e.currentTarget) { return; }
      this.add_link({ group: '' });
    },
    onGroupRename(e) {
      this.rename_group({
        from_name: e.target.getAttribute('data-original_value'),
        to_name: e.target.value
      });
    },
    onRefill({ target }) {
      let json;
      try {
        json = JSON.parse(target.value);
      } catch (e) {
        flash.error(e.toString());
      }

      if (json) {
        this.refill(json);
      }
    },
    addAutosize({ target }) {
      autosize(target);
    },
    onDragUpdate(e) {
      restoreNode(e);

      let from_index = listIndex(e.to, e.oldIndex);
      let to_index = listIndex(e.to, e.newIndex);

      this.move_link({
        from_index: from_index,
        to_index: to_index,
        group_index: to_index
      });
    },
    onDragAdd(e) {
      restoreNode(e);

      let from_index = listIndex(e.from, e.oldIndex);
      let is_last_column_position = !e.to.childNodes[e.newIndex];
      let to_index = is_last_column_position ?
        listIndex(e.to, e.newIndex - 1) :
        listIndex(e.to, e.newIndex);
      let group_index = to_index;

      let is_move_right = to_index > from_index;
      let is_move_left = to_index < from_index;

      if (is_move_right && !is_last_column_position) {
        to_index -= 1;
      }
      if (is_move_left && is_last_column_position) {
        to_index += 1;
      }

      this.move_link({
        from_index: from_index,
        to_index: to_index,
        group_index: group_index
      });
    }
  }
};
</script>

<style scoped lang="sass">
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
    // line-height: $line_height
    line-height: 1.65
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
