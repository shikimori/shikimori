<template lang="pug">
  .block
    input(
      type="hidden"
      :name="`${resource_type.toLowerCase()}[synonyms][]`"
      v-if="is_empty"
    )
    .b-nothing_here(
      v-if="!collection.length"
    )
      | {{ I18n.t('frontend.synonyms.nothing_here') }}
    draggable.block(
      :options="drag_options"
      v-model="collection"
      v-if="collection.length"
    )
      .b-collection_item(
        v-for="synonym in collection"
      )
        .delete(
          @click="remove(synonym)"
        )
        .drag-handle
        .b-input
          input(
            type="text"
            v-model="synonym.name"
            :name="`${resource_type.toLowerCase()}[synonyms][]`"
            :placeholder="I18n.t('frontend.synonyms.name')"
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
  methods: {
    add() {
      this.$store.dispatch('add', { name: '' })
      this.$nextTick(() => {
        $('input', this.$el).last().focus()
      })
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
