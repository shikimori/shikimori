<template lang="pug">
  .collection-link
    .delete(
      @click="remove_link(link)"
    )
    input(
      v-if="link.id"
      type="hidden"
      v-model="link.id"
      name="collection[collection_link][id]"
    )
    input(
      type="hidden"
      v-model="link.linked_id"
      v-if="link.linked_id"
      name="collection[collection_link][linked_id]"
    )
    input(
      type="hidden"
      v-model="link.linked_type"
      v-if="link.linked_id"
      name="collection[collection_link][linked_type]"
    )
    input(
      type="hidden"
      v-model="link.group"
      name="collection[collection_link][group]"
    )
    .b-input.new-record(
      v-if="!link.linked_id"
    )
      label
        | {{ I18n.t(`frontend.collections.add.${collection.kind}`) }}
        input(
          type="text"
          :placeholder="I18n.t(`frontend.collections.autocomplete.${collection.kind}`)"
          :data-autocomplete="collection.autocomplete_url"
        )
    .persisted(
      v-if="link.linked_id"
    )
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
          name="collection[collection_link][text]"
          rows="1"
        )
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  props: {
    link: Object
  },
  computed: {
    ...mapGetters([
      'collection'
    ])
  },
  methods: {
    ...mapActions([
      'remove_link'
    ])
  }
}
</script>

<style scoped lang="sass">
@import app/assets/stylesheets/globals/variables

.collection-link
  margin-bottom: 15px
  position: relative

  &:last-child
    margin-bottom: 0

  .delete
    color: #123
    cursor: pointer
    margin-left: -30px
    margin-top: -1px
    position: absolute
    text-align: center
    width: 30px
    top: 0

    &:before
      content: 'x'
      font-family: shikimori
      font-size: 15px

    &:hover
      color: $link-hover

    &:active
      color: $link-active

  textarea
    height: auto

  textarea, .b-input input[type=text]
    width: 100%
</style>
