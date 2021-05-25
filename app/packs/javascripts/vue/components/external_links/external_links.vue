<template lang='pug'>
.block_m
  input(
    type='hidden'
    :name="`${resourceType.toLowerCase()}[external_links][]`"
    v-if='isEmpty'
  )
  .b-nothing_here(
    v-if='!collection.length'
  )
    | {{ I18n.t('frontend.external_links.nothing_here') }}
  draggable.block(
    v-if='collection.length'
    v-model='collection'
    item-key='element => element.id || element.key'
    v-bind='dragOptions'
  )
    template(#item="{element}")
      ExternalLink(
        :link='element'
        :kind-options='kindOptions'
        :resource-type='resourceType'
        :entry-type='entryType'
        :entry-id='entryId'
        :watch-online-kinds='watchOnlineKinds'
        @add:next='add'
        @focusLast='focusLast'
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
