<template lang='pug'>
  .block
    input(
      type='hidden'
      :name="`${resourceType.toLowerCase()}[external_links][]`"
      v-if='isEmpty'
    )
    .b-nothing_here(
      v-if="!collection.length"
    )
      | {{ I18n.t('frontend.external_links.nothing_here') }}
    draggable.block(
      v-bind='dragOptions'
      v-model='collection'
      v-if='collection.length'
    )
      ExternalLink(
        v-for='link in collection'
        @add_next='add'
        @focusLast='focusLast'
        :key='link.id || link.key'
        :link='link'
        :kind-options='kindOptions'
        :resource-type='resourceType'
        :entry-type='entryType'
        :entry-id='entryId'
        :watch-online-kinds='watchOnlineKinds'
      )
    .b-button(
      @click='add'
    ) {{ I18n.t('frontend.actions.add') }}
</template>

<script>
import { mapGetters, mapState } from 'vuex';

import ExternalLink from './external_link';
import draggable from 'vuedraggable';
import delay from 'delay';

export default {
  name: 'ExternalLinks',
  components: { ExternalLink, draggable },
  props: {
    kindOptions: { type: Array, required: true },
    resourceType: { type: String, required: true },
    entryType: { type: String, required: true },
    entryId: { type: Number, required: true },
    watchOnlineKinds: { type: Array, required: true }
  },
  data: () => ({
    dragOptions: {
      group: 'external_links',
      handle: '.drag-handle'
    }
  }),
  computed: {
    ...mapState({ items: 'collection' }),
    ...mapGetters(['isEmpty']),
    collection: {
      get() {
        return this.items;
      },
      set(items) {
        this.$store.dispatch('replace', items);
      }
    }
  },
  methods: {
    add() {
      this.$store.dispatch('add', {
        kind: this.kindOptions.first().last(),
        source: 'shikimori',
        url: '',
        id: '',
        entry_id: this.entryId,
        entry_type: this.entryType
      });
    },
    async focusLast() {
      // do not use this.$nextTick. it passes "backspace" event to focused input
      await delay();
      $('input', this.$el).last().focus();
    }
  }
};
</script>

<style scoped lang='sass'>
  .b-nothing_here
    margin-bottom: 15px
</style>
