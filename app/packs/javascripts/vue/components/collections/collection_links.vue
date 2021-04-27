<template lang='pug'>
  .block
    .block
      .b-options-floated {{ `${links.length} / ${maxLinks}` }}
      .subheadline {{ I18n.t(`frontend.collections.kind.${collection.kind}`) }}
      .cc-3-flex
        .c-column(
          v-for='(groupName, index) in groups'
        )
          .b-input.group
            .group-headline
              label(
                :for="'group_' + groupName"
              ) {{ I18n.t('activerecord.attributes.collection_link.group') }}
              .move-left.b-js-link(
                v-if='groups.length > 1'
                :class='{ "is-disabled": index === 0 }'
                @click='() => index === 0 ? null : moveGroupLeft(groupName)'
              )
              .move-right.b-js-link(
                v-if='groups.length > 1'
                :class='{ "is-disabled": index === groups.length - 1 }'
                @click='() => index === groups.length - 1 ? null : moveGroupRight(groupName)'
              )
              .add
                .b-js-link(
                  v-if='links.length < maxLinks'
                  @click='addLink({group: groupName})'
                ) {{ I18n.t('frontend.actions.add').toLowerCase() }}
            input(
              :id="'group_' + groupName"
              :value='groupName'
              :data-original_value='groupName'
              :placeholder="I18n.t('frontend.collections.group_name')"
              class='name'
              @blur='onGroupRename'
              @change='onGroupRename'
              @keydown.enter.prevent='onGroupRename'
              type='text'
            )

          draggable.collection_links(
            v-bind='dragOptions'
            @update='onDragUpdate'
            @add='onDragAdd'
          )
            CollectionLink(
              v-for='link in groupedLinks[groupName]'
              :key='link.id || link.key'
              :link='link'
              :autocomplete-url='autocompleteUrl'
            )

        .c-column.new-group(
          v-if='links.length < maxLinks'
        )
          div(
            v-if="Object.isEmpty(groupedLinks[''])"
          )
            .b-button(
              @click='addNewGroup'
            ) {{ I18n.t('frontend.actions.add') }}
          .button-container(
            v-if="!Object.isEmpty(groupedLinks[''])"
          )
            div
              .b-button.disabled {{ I18n.t('frontend.actions.add') }}
            .hint {{ I18n.t('frontend.collections.disabled_add_group_hint') }}

    .block.json
      .subheadline.m5 JSON
      .b-spoiler.unprocessed
        label {{ I18n.t('frontend.collections.json_warning') }}
        .content
          .before
          .inner
            .b-input
              textarea(
                @change='onRefill'
                @keydown.ctrl.enter='onRefill'
                @keydown.meta.enter='onRefill'
                @focus.once='addAutosize'
                v-bind:value='linksJSON'
              )
          .after
</template>

<script>
import { mapGetters, mapActions } from '@/vuex';
import draggable from '@/vuedraggable';
import autosize from 'autosize';

import { flash } from 'shiki-utils';
import CollectionLink from './collection_link';

function listIndex(node, index) {
  return parseInt(node.childNodes[index].getAttribute('data-list_index'));
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
  name: 'CollectionLinks',
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
      'groupedLinks'
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
      'addLink',
      'moveLink',
      'renameGroup',
      'moveGroupLeft',
      'moveGroupRight',
      'refill'
    ]),
    addNewGroup(e) {
      if (e.target !== e.currentTarget) { return; }
      this.addLink({ group: '' });
    },
    onGroupRename(e) {
      this.renameGroup({
        fromName: e.target.getAttribute('data-original_value'),
        toName: e.target.value
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

      const fromIndex = listIndex(e.to, e.oldIndex);
      const toIndex = listIndex(e.to, e.newIndex);

      this.moveLink({
        fromIndex,
        toIndex,
        groupIndex: toIndex
      });
    },
    onDragAdd(e) {
      restoreNode(e);

      const fromIndex = listIndex(e.from, e.oldIndex);
      const isLastColumnPosition = !e.to.childNodes[e.newIndex];
      let toIndex = isLastColumnPosition ?
        listIndex(e.to, e.newIndex - 1) :
        listIndex(e.to, e.newIndex);
      const groupIndex = toIndex;

      const isMoveRight = toIndex > fromIndex;
      const isMoveLeft = toIndex < fromIndex;

      if (isMoveRight && !isLastColumnPosition) {
        toIndex -= 1;
      }
      if (isMoveLeft && isLastColumnPosition) {
        toIndex += 1;
      }

      this.moveLink({
        fromIndex,
        toIndex,
        groupIndex
      });
    }
  }
};
</script>

<style scoped lang='sass'>
@import 'app/assets/stylesheets/globals'
@import 'app/assets/stylesheets/mixins/responsive'

.new-group
  padding-top: 8px

  .button-container
    display: flex

    .hint
      align-self: center
      color: #9da2a8
      font-size: 11px
      line-height: $line_height
      padding-left: 15px

.group-headline
  display: flex
  height: 21px

  label
    display: inline-block
    line-height: inherit
    font-weight: bold

  .move-left,
  .move-right
    border-bottom: none
    align-items: center
    display: flex
    justify-content: center
    width: 16px
    height: 100%

    &.is-disabled
      color: $gray-1
      cursor: default

    &:before
      content: '\e81c'
      font-family: shikimori
      position: absolute

  .move-left
    margin-left: 7px

    &:before
      position: absolute
      transform: rotate(180deg)

      +iphone
        transform: rotate(-90deg)

  .move-right
    &:before
      +iphone
        transform: rotate(90deg)

  .add
    margin-left: auto

    .b-js-link
      font-size: 11px

      &:before
        font-family: shikimori
        position: absolute
        margin-left: -12px
        margin-top: 1px
        content: '+'

.group
  .name
    max-width: 100%

  input
    overflow: hidden
    text-overflow: ellipsis
    white-space: nowrap

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
