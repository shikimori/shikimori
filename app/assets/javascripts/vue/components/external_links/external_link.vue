<template lang="pug">
  .b-collection_item
    .delete(
      @click="remove_link(link)"
    )
    .drag-handle
    input(
      name="external_links[][id]"
      type="hidden"
      v-model="link.id"
    )
    input(
      name="external_links[][source]"
      type="hidden"
      v-model="link.source"
    )
    .b-input
      select(
        name="external_links[][kind]"
        v-model="link.kind"
      )
        option(
          v-for="kind_option in kind_options"
          :value="kind_option.last()"
        ) {{ kind_option.first() }}
    .b-input
      input(
        name="external_links[][url]"
        type="text"
        v-model="link.url"
        :placeholder="I18n.t('activerecord.attributes.external_link.url')"
      )
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  props: {
    link: Object,
    kind_options: Array
  },
  computed: {
    ...mapGetters([
    ]),
  },
  methods: {
    ...mapActions([
      'remove_link'
    ])
  }
}
</script>

<style scoped lang="sass">
  .b-input input
    width: 100%

  .b-collection_item:first-child:last-child
    .drag-handle
      display: none
</style>
