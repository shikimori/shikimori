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
      v-bind='dragOptions'
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
            v-model='entry.value'
            :name="`${resourceType.toLowerCase()}[${field}][]`"
            :placeholder="I18n.t('frontend.' + field + '.name')"
            @keydown.enter='submit'
            @keydown.8='removeEmpty(entry)'
            @keydown.esc='removeEmpty(entry)'
            :data-autocomplete='autocompleteUrl'
            :data-collection_index='index'
          )

    .b-button(
      @click="add"
    ) {{ I18n.t('frontend.actions.add') }}
</template>

<script>
import { mapGetters, mapActions } from 'vuex';
import draggable from 'vuedraggable';
import delay from 'delay';

const PLAIN_AUTOCOMPLETE_TYPE = 'plain';

export default {
  name: 'ArrayField',
  components: { draggable },
  props: {
    field: { type: String, required: true },
    resourceType: { type: String, required: true },
    autocompleteUrl: { type: String, required: false, default: undefined },
    autocompleteType: { type: String, required: false, default: undefined }
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
  async mounted() {
    await this.$nextTick();
    this.autocomplete();
  },
  methods: {
    ...mapActions([
      'remove'
    ]),
    async add() {
      this.$store.dispatch('add', { value: '' });
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
      if (Object.isEmpty(entry.value) &&
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

      const $inputs = $('input', this.$el)
        .filter((index, node) => !$(node).data('autocomplete-enabled'))
        .data('autocomplete-enabled', true);

      switch (this.autocompleteType) {
        case PLAIN_AUTOCOMPLETE_TYPE:
          this.autocompletePlain($inputs);
          break;

        default:
          this.autocompleteDefault($inputs);
      }
    },
    autocompletePlain($node) {
      $node
        .completablePlain()
        .on('autocomplete:text', (e, value) => {
          this.collection[($(e.currentTarget).data('collection_index'))].value = value;
        });
    },
    autocompleteDefault($node) {
      $node
        .completable()
        .on('autocomplete:success', (e, { value }) => {
          this.collection[($(e.currentTarget).data('collection_index'))].value = value;
        });
    },
    cleanup() {
      this.$store.dispatch('cleanup');
    }
  }
};
</script>

<style scoped lang='sass'>
  .b-nothing_here
    margin-bottom: 15px
</style>
