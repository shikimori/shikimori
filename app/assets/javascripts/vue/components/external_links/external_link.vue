<template lang="pug">
  .b-collection_item
    .delete(
      @click="remove(link)"
    )
    .drag-handle
    input(
      type="hidden"
      v-model="link.entry_id"
      :name="fieldName('entry_id')"
    )
    input(
      type="hidden"
      v-model="link.entry_type"
      :name="fieldName('entry_type')"
    )
    input(
      type="hidden"
      v-model="link.created_at"
      :name="fieldName('created_at')"
    )
    input(
      type="hidden"
      v-model="link.updated_at"
      :name="fieldName('updated_at')"
    )
    input(
      type="hidden"
      v-model="link.imported_at"
      :name="fieldName('imported_at')"
    )
    input(
      type="hidden"
      v-model="link.source"
      :name="fieldName('source')"
    )
    .b-input.select
      select(
        v-model="link.kind"
        :name="fieldName('kind')"
      )
        option(
          v-for="kind_option in kind_options"
          :value="kind_option.last()"
        ) {{ kind_option.first() }}
    .b-input
      input(
        type="text"
        v-model="link.url"
        :name="fieldName('url')"
        :placeholder="I18n.t('activerecord.attributes.external_link.url')"
        @keydown.enter="submit"
        @keydown.8="removeEmpty(link)"
        @keydown.esc="removeEmpty(link)"
      )
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  props: {
    link: Object,
    kind_options: Array,
    resource_type: String,
    entry_type: String,
    entry_id: Number
  },
  computed: {
    ...mapGetters([
    ]),
  },
  methods: {
    fieldName(name) {
      if (!Object.isEmpty(this.link.url)) {
        return `${this.resource_type.toLowerCase()}[external_links][][${name}]`
      } else {
        return ''
      }
    },
    submit(e) {
      if (!e.metaKey && !e.ctrlKey) {
        e.preventDefault()
        this.$emit('add_next')
      }
    },
    removeEmpty(link) {
      if (Object.isEmpty(link.url) && this.$store.state.collection.length > 1) {
        this.remove(link)
        this.$emit('focusLast')
      }
    },
    ...mapActions([
      'remove'
    ])
  },
  mounted() {
    this.$nextTick(() => {
      $('input', this.$el).focus()
    })
  }
}
</script>

<style scoped lang="sass">
  .b-collection_item
    &:first-child:last-child
      .drag-handle
        display: none

    .b-input
      margin-bottom: 2px

      &.select
        margin-bottom: 5px

      input
        width: 100%

    .drag-handle
      margin-top: 3px
</style>
