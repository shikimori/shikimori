<template lang="pug">
  .block
    draggable.block(
      :options="drag_options"
      v-model="external_links"
    )
      ExternalLink(
        v-for="link in external_links"
        :key="link.id || link.key"
        :link="link"
        :kind_options="kind_options"
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
    kind_options: Array
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
        id: ''
      })
    }
  }
}
</script>

<style scoped lang="sass">
</style>
