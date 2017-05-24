<template lang="pug">
  .b-collection_item
    .delete(
      @click="remove_link(link)"
    )
    .drag-handle
    input(
      type="hidden"
      v-model="link.entry_id"
      :name="field_name('entry_id')"
    )
    input(
      type="hidden"
      v-model="link.entry_type"
      :name="field_name('entry_type')"
    )
    input(
      type="hidden"
      v-model="link.created_at"
      :name="field_name('created_at')"
    )
    input(
      type="hidden"
      v-model="link.updated_at"
      :name="field_name('updated_at')"
    )
    input(
      type="hidden"
      v-model="link.imported_at"
      :name="field_name('imported_at')"
    )
    input(
      type="hidden"
      v-model="link.source"
      :name="field_name('source')"
    )
    .b-input
      select(
        v-model="link.kind"
        :name="field_name('kind')"
      )
        option(
          v-for="kind_option in kind_options"
          :value="kind_option.last()"
        ) {{ kind_option.first() }}
    .b-input
      input(
        type="text"
        v-model="link.url"
        :name="field_name('url')"
        :placeholder="I18n.t('activerecord.attributes.external_link.url')"
      )
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  props: {
    link: Object,
    kind_options: Array,
    entry_type: String,
    entry_id: Number
  },
  computed: {
    ...mapGetters([
    ]),
  },
  methods: {
    field_name(name) {
      if (!Object.isEmpty(this.link.url)) {
        return `${this.entry_type}[external_links][][${name.toLowerCase()}]`
      } else {
        return ''
      }
    },
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
