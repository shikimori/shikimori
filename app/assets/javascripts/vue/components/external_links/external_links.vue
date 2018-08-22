<template lang="pug">
  .block
    input(
      type="hidden"
      :name="`${resource_type.toLowerCase()}[external_links][]`"
      v-if="is_empty"
    )
    .b-nothing_here(
      v-if="!collection.length"
    )
      | {{ I18n.t('frontend.external_links.nothing_here') }}
    draggable.block(
      :options="drag_options"
      v-model="collection"
      v-if="collection.length"
    )
      ExternalLink(
        v-for="link in collection"
        @add_next="add"
        @focusLast="focusLast"
        :key="link.id || link.key"
        :link="link"
        :kind_options="kind_options"
        :resource_type="resource_type"
        :entry_type="entry_type"
        :entry_id="entry_id"
      )
    .b-button(
      @click="add"
    ) {{ I18n.t('actions.add') }}
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import ExternalLink from './external_link'
import draggable from 'vuedraggable'
import delay from 'delay';

export default {
  components: { ExternalLink, draggable },
  props: {
    kind_options: Array,
    resource_type: String,
    entry_type: String,
    entry_id: Number
  },
  data() {
    return {
      drag_options: {
        group: 'external_links',
        handle: '.drag-handle'
      }
    }
  },
  computed: {
    collection: {
      get() {
        return this.$store.state.collection
      },
      set(items) {
        this.$store.dispatch('replace', items)
      }
    },
    ...mapGetters([
      'is_empty'
    ]),
  },
  methods: {
    add() {
      this.$store.dispatch('add', {
        kind: this.kind_options.first().last(),
        source: 'shikimori',
        url: '',
        id: '',
        entry_id: this.entry_id,
        entry_type: this.entry_type
      })
    },
    async focusLast() {
      // do not use this.$nextTick. it passes "backspace" event to focused input
      await delay();
      $('input', this.$el).last().focus();
    }
  }
}
</script>

<style scoped lang="sass">
  .b-nothing_here
    margin-bottom: 15px
</style>
