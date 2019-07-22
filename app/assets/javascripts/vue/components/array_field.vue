<template lang='pug'>
  .block
    input(
      type='hidden'
      :name='`${resourceType.toLowerCase()}[${field}][]`'
      v-if='isEmpty'
    )
    .b-nothing_here(
      v-if='!collection.length'
    )
      | {{ I18n.t('frontend.' + field + '.nothing_here') }}
    draggable.block(
      :options='dragOptions'
      v-model='collection'
      v-if='collection.length'
    )
      .b-collection_item.single-line(
        v-for='(entry, index) in collection'
      )
        .delete(
          @click='remove(entry)'
        )
        .drag-handle
        .b-input
          input(
            type='text'
            v-model='entry.name'
            :name="`${resourceType.toLowerCase()}[${field}][]`"
            :placeholder="I18n.t('frontend.' + field + '.name')"
            @keydown.enter="submit"
            @keydown.8='removeEmpty(entry)'
            @keydown.esc='removeEmpty(entry)'
            :data-autocomplete='autocompleteUrl'
            :data-collection_index='index'
          )

    .b-button(
      @click="add"
    ) {{ I18n.t('actions.add') }}
</template>

<script>
import { mapGetters, mapActions } from 'vuex';
import draggable from 'vuedraggable';
import delay from 'delay';

export default {
  name: 'ArrayField',
  components: { draggable },
  props: {
    field: { type: String, required: true },
    resourceType: { type: String, required: true },
    autocompleteUrl: { type: String, required: true }
  },
  data: () => ({
    dragOptions: {
      group: 'synonyms',
      handle: '.drag-handle'
    }
  }),
  computed: {
    ...mapGetters([
      'isEmpty'
    ]),
    collection: {
      get() {
        return this.$store.state.collection;
      },
      set(items) {
        this.$store.dispatch('replace', items);
      }
    }
  },
  mounted() {
    this.$nextTick(() => { this.autocomplete(); });
  },
  methods: {
    ...mapActions([
      'remove'
    ]),
    async add() {
      this.$store.dispatch('add', { name: '' });
      await this.focusLast();
      this.autocomplete();
    },
    submit(e) {
      // can be submitted by press enter in autocomplete select
      if ($('.ac_results').is(':visible')) {
        return;
      }

      if (!e.metaKey && !e.ctrlKey) {
        e.preventDefault();
        this.add();
      }
    },
    removeEmpty(entry) {
      if (Object.isEmpty(entry.name) &&
          this.$store.state.collection.length > 1
      ) {
        this.remove(entry);
        this.focusLast();
      }
    },
    async focusLast() {
      // do not use this.$nextTick. it passes "backspace" event to focused input
      await delay();
      $('input', this.$el).last().focus();
    },
    autocomplete() {
      if (!this.autocompleteUrl) { return; }

      $('input', this.$el)
        .filter((index, node) => !$(node).data('autocomplete-enabled'))
        .data('autocomplete-enabled', true)
        .completable()
        .on('autocomplete:success', (e, { value }) => {
          this.collection[($(e.currentTarget).data('collection_index'))].name = value;
        });
    }
  }
};
</script>

<style scoped lang='sass'>
  .b-nothing_here
    margin-bottom: 15px
</style>
