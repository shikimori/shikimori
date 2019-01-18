<template lang='pug'>
  .block
    input(
      type='hidden'
      :name='`${resource_type.toLowerCase()}[${field}][]`'
      v-if='is_empty'
    )
    .b-nothing_here(
      v-if='!collection.length'
    )
      | {{ I18n.t('frontend.' + field + '.nothing_here') }}
    draggable.block(
      :options='drag_options'
      v-model='collection'
      v-if='collection.length'
    )
      .b-collection_item(
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
            :name="`${resource_type.toLowerCase()}[${field}][]`"
            :placeholder="I18n.t('frontend.' + field + '.name')"
            @keydown.enter="submit"
            @keydown.8='removeEmpty(entry)'
            @keydown.esc='removeEmpty(entry)'
            :data-autocomplete='autocomplete_url'
            :data-collection_index='index'
          )

    .b-button(
      @click="add"
    ) {{ I18n.t('actions.add') }}
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import draggable from 'vuedraggable'
import delay from 'delay';

export default {
  components: { draggable },
  props: {
    field: String,
    resource_type: String,
    entry_type: String,
    entry_id: Number,
    autocomplete_url: String
  },
  data() {
    return {
      drag_options: {
        group: 'synonyms',
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
  mounted() {
    this.$nextTick(() => { this.autocomplete() });
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
        e.preventDefault()
        this.add()
      }
    },
    removeEmpty(entry) {
      if (Object.isEmpty(entry.name) &&
          this.$store.state.collection.length > 1
      ) {
        this.remove(entry)
        this.focusLast()
      }
    },
    async focusLast() {
      // do not use this.$nextTick. it passes "backspace" event to focused input
      await delay();
      $('input', this.$el).last().focus();
    },
    autocomplete() {
      if (!this.autocomplete_url) { return; }

      $('input', this.$el)
        .filter((index, node) => !$(node).data('autocomplete-enabled'))
        .data('autocomplete-enabled', true)
        .completable()
        .on('autocomplete:success', (e, { value }) => {
          this.collection[($(e.currentTarget).data('collection_index'))].name = value;
        });
    }
  }
}
</script>

<style scoped lang='sass'>
  .b-nothing_here
    margin-bottom: 15px

  .b-collection_item
    .delete
      top: 3px

    .drag-handle
      top: 3px
      left: 53px

    &:first-child:last-child
      .drag-handle
        display: none

      .b-input
        margin-left: 0

    .b-input
      margin-left: 25px
</style>
