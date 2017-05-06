<template lang="pug">
  .collection-link
    .delete(
      @click="remove_link(link)"
    )
    .drag-handle
    .b-input.new-record(
      v-if="!link.linked_id"
    )
      div {{ link_index }}&nbsp;
      label
        | {{ I18n.t(`frontend.collections.add.${collection.kind}`) }}
        input(
          type="text"
          :placeholder="I18n.t(`frontend.collections.autocomplete.${collection.kind}`)"
          :data-autocomplete="autocomplete_url"
        )
    .persisted(
      v-if="link.linked_id"
    )
      input(
        v-if="link.id"
        type="hidden"
        v-model="link.id"
        name="collection[links][][id]"
      )
      input(
        type="hidden"
        v-model="link.linked_id"
        v-if="link.linked_id"
        name="collection[links][][linked_id]"
      )
      input(
        type="hidden"
        v-model="link.group"
        name="collection[links][][group]"
      )
      // | {{ link_index }}&nbsp;
      a.b-link.bubbled(
        :href="link.url"
      ) {{ link.name }}
      .b-input
        label(
          :for="'link_text_' + link.id"
        ) {{ I18n.t('activerecord.attributes.collection_link.text') }}
        textarea(
          :id="'link_text_' + link.id"
          v-model="link.text"
          name="collection[links][][text]"
          rows="1"
        )
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  props: {
    link: Object,
    link_index: Number
  },
  computed: {
    ...mapGetters([
      'autocomplete_url',
      'collection'
    ])
  },
  methods: {
    ...mapActions([
      'remove_link'
    ])
  },
  //mounted () {
    //this.$nextTick(() => {
      //console.log('mounted next tick')
    //})
  //}
}
</script>

<style scoped lang="sass">
@import app/assets/stylesheets/globals/variables

.collection-link
  padding: 1px 6px 1px 31px
  margin-bottom: 15px
  position: relative

  &:last-child
    margin-bottom: 0

  // &.sortable-chosen
  &.sortable-ghost
    border: 1px dashed $gray-1
    opacity: 0.6
    padding: 0 5px 0 30px

    .drag-handle
      color: $gray !important

    .delete, .drag-handle
      margin-top: -2px

  &.sortable-drag
    opacity: 1

    .drag-handle
      color: $link-active !important

  .delete, .drag-handle
    cursor: pointer
    margin-left: -30px
    margin-top: -1px
    position: absolute
    text-align: center
    width: 30px

    &:before
      font-family: shikimori
      font-size: 15px

    &:hover
      color: $link-hover

    &:active
      color: $link-active

  .delete
    color: #123
    top: 0

    &:before
      content: 'x'

  .drag-handle
    color: $gray
    top: 21px

    &:before
      content: 'm'

  textarea
    height: auto

  textarea, input
    width: 100%
</style>
