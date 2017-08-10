<template lang="pug">
  .block
    input(
      type="hidden"
      name="poll_variants[]"
      v-if="is_empty"
    )
    .b-nothing_here(
      v-if="!collection.length"
    )
      | {{ I18n.t('frontend.poll_variants.nothing_here') }}
    draggable.block(
      :options="drag_options"
      v-model="collection"
      v-if="collection.length"
    )
      .b-collection_item(
        v-for="poll_variant in collection"
      )
        .delete(
          @click="remove(poll_variant)"
        )
        .drag-handle
        .b-input
          input(
            type="text"
            name="poll_variants[]"
            v-model="poll_variant.text"
            :placeholder="I18n.t('frontend.poll_variants.text')"
            @keydown.enter.prevent="add"
            @keydown.8="remove_empty(poll_variant)"
            @keydown.esc="remove_empty(poll_variant)"
          )

    .b-button(
      @click="add"
    ) {{ I18n.t('actions.add') }}
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import draggable from 'vuedraggable'

export default {
  components: { draggable },
  props: {
    resource_type: String,
    entry_type: String,
    entry_id: Number
  },
  data() {
    return {
      drag_options: {
        group: 'poll_variants',
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
      this.$store.dispatch('add', { text: '' })
      this.focus_last()
    },
    remove_empty(poll_variant) {
      if (Object.isEmpty(poll_variant.name) && this.$store.state.collection.length > 1) {
        this.remove(poll_variant)
        this.focus_last()
      }
    },
    focus_last() {
      // do not use this.$nextTick. it passes "backspace" event to focused input
      delay().then(() => $('input', this.$el).last().focus())
    },
    ...mapActions([
      'remove'
    ])
  }
}
</script>

<style scoped lang="sass">
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
      margin-left: 25px
</style>
