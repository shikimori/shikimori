<template lang="pug">
  .collection-link(
    :data-linked_id="link.linked_id"
    :data-group="link.group"
    :data-list_index='links.indexOf(link)'
  )
    | {{ link.id }}
    .delete(
      @click="remove_link(link)"
    )
    .drag-handle(
      v-if="link.linked_id"
    )
    .b-input.new-record(
      v-if="!link.linked_id"
    )
      label
        //| {{ I18n.t(`frontend.collections.add.${collection.kind}`) }}
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
      a.b-link.bubbled(
        :href="link.url"
      ) {{ link.name }}
      .b-input
        //label(
        //  :for="'link_text_' + link.id"
        //) {{ I18n.t('activerecord.attributes.collection_link.text') }}
        textarea(
          :id="'link_text_' + link.id"
          :placeholder="I18n.t('activerecord.attributes.collection_link.text')"
          name="collection[links][][text]"
          rows="1"
          v-model="link.text"
          @focus.once="add_autosize"
        )
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import autosize from 'autosize'

function highlight(selector) {
  let $node = $(selector)

  if (!$node.is(':appeared')) {
    $.scrollTo($node, () => $node.yellow_fade())
  } else {
    $node.yellow_fade()
  }
}

export default {
  props: {
    link: Object,
    link_index: Number
  },
  computed: {
    ...mapGetters([
      'autocomplete_url',
      'collection',
      'links'
    ])
  },
  methods: {
    assign(new_link) {
      this.replace_link({link: this.link, new_link: new_link})

      this.$nextTick(() => {
        highlight(
          '.collection-link' +
            `[data-linked_id=${new_link.linked_id}]` +
            `[data-group=${new_link.group}]`
        )
      })
    },
    add_autosize({target}) {
      autosize(target)
    },
    ...mapActions([
      'replace_link',
      'remove_link'
    ])
  },
  mounted() {
    this.$nextTick(() => {
      $(this.$el).process()

      if (!this.link.linked_id) {
        $('input', this.$el)
          .completable()
          .focus()
          .on('autocomplete:success', (e, {id, name, url}) => {
            this.assign({
              group: this.link.group,
              linked_id: parseInt(id),
              name: name,
              url: url
            })
          })
      }
    })
  }
}
</script>

<style scoped lang="sass">
@import app/assets/stylesheets/globals/variables

.collection-link
  margin-bottom: 15px
  padding: 1px 6px 1px 31px
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
    top: 1px

    &:before
      content: 'x'

  .drag-handle
    color: $gray
    top: 24px

    &:before
      content: 'm'

  textarea
    height: auto

  textarea, input
    width: 100%
    line-height: $line-height
</style>
