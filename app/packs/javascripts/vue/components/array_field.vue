<template lang='pug'>
.block_m
  input(
    type='hidden'
    :name='emptyInputName || `${resourceType.toLowerCase()}[${field}][]`'
    v-if='isEmpty'
  )
  .b-nothing_here(
    v-if='!collection.length'
  )
    | {{ I18n.t('frontend.' + field + '.nothing_here') }}
  draggable.block(
    v-if='collection.length'
    v-model='collection'
    item-key='element => element.key'
    v-bind='dragOptions'
  )
    template(#item="{element}")
      .b-collection_item.single-line
        .delete(
          @click='remove(element.key)'
        )
        .drag-handle
        .b-input
          input(
            type='text'
            :value='element.value'
            :name="inputName || `${resourceType.toLowerCase()}[${field}][]`"
            :placeholder="I18n.t('frontend.' + field + '.name')"
            @input='update({ key: element.key, value: $event.target.value })'
            @keydown.enter='submit'
            @keydown.backspace='removeEmpty(element)'
            @keydown.esc='removeEmpty(element)'
            :data-autocomplete='autocompleteUrl'
            :data-item_key='element.key'
          )
  .b-button(
    @click='add'
  ) {{ I18n.t('frontend.actions.add') }}
</template>

<script>
import { mapGetters, mapState, mapActions } from 'vuex';
import draggable from 'vuedraggable';
import delay from 'delay';

const PLAIN_AUTOCOMPLETE_TYPE = 'plain';

export default {
  name: 'ArrayField',
  components: { draggable },
  props: {
    field: { type: String, required: true },
    inputName: { type: String, required: false, default: undefined },
    emptyInputName: { type: String, required: false, default: undefined },
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
  async mounted() {
    await this.$nextTick();
    this.autocomplete();
  },
  methods: {
    ...mapActions(['remove', 'update']),
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
      if (Object.isEmpty(entry.value) && this.collection.length > 1) {
        this.remove(entry.key);
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
          const key = $(e.currentTarget).data('item_key');
          this.update({ key, value });
        });
    },
    autocompleteDefault($node) {
      $node
        .completable()
        .on('autocomplete:success', (e, { value }) => {
          const key = $(e.currentTarget).data('item_key');
          this.update({ key, value });
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
