<template lang="pug">
  .block
    input(
      type="hidden"
      :name="`${entry_type}[external_links][]`"
      v-if="no_links"
    )
    .b-nothing_here(
      v-if="!external_links.length"
    )
      | {{ I18n.t('frontend.external_links.nothing_here') }}
    draggable.block(
      :options="drag_options"
      v-model="external_links"
      v-if="external_links.length"
    )
      ExternalLink(
        v-for="link in external_links"
        :key="link.id || link.key"
        :link="link"
        :kind_options="kind_options"
        :entry_type="entry_type"
        :entry_id="entry_id"
      )
    .b-button(
      @click="add_link"
    ) {{ I18n.t('actions.add') }}
</template>

<script>
import ExternalLink from './external_link'
import draggable from 'vuedraggable'

export default {
  components: { ExternalLink, draggable },
  props: {
    kind_options: Array,
    entry_type: String,
    entry_id: Number
  },
  data () {
    return {
      drag_options: {
        group: 'external_links',
        handle: '.drag-handle'
      }
    }
  },
  computed: {
    external_links: {
      get() {
        return this.$store.state.external_links
      },
      set(value) {
        this.$store.dispatch('reorder', value)
      }
    }
  },
  methods: {
    add_link() {
      this.$store.dispatch('add_link', {
        kind: this.kind_options.first().last(),
        source: 'shikimori',
        url: '',
        id: '',
        entry_id: this.entry_id,
        entry_type: this.entry_type
      })
    },
    no_links() {
      return this.external_links.every((link) => Object.isEmpty(link.url))
    }
  }
}
</script>

<style scoped lang="sass">
  .b-nothing_here
    margin-bottom: 15px
</style>
