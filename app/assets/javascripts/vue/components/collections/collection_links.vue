<template lang="pug">
  .cc-3
    .c-column(
      v-for='group_name in groups'
    )
      .b-input.group
        div
          label(
            :for="'group_' + group_name"
          ) {{ I18n.t('activerecord.attributes.collection_link.group') }}
          .add.b-js-link(
            @click="add_link({group: group_name})"
          ) {{ I18n.t('actions.add').toLowerCase() }}
        input(
          :id="'group_' + group_name"
          :value="group_name"
          type="text"
        )

      draggable.collection-links(
        v-model='$store.state.collection.links'
        :options="drag_options"
      )
        CollectionLink(
          v-for="link in grouped_links[group_name]"
          :key="link.id"
          :link="link"
        )
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import CollectionLink from './collection_link'
import draggable from '../../plugins/vuedraggable-patched'

export default {
  components: { CollectionLink, draggable },
  data () {
    return {
      drag_options: {
        group: 'collection_links',
        handle: '.drag-handle'
      }
    }
  },
  computed: {
    ...mapGetters([
      'links',
      'groups',
      'grouped_links'
    ]),
  },
  methods: {
    ...mapActions([
      'add_link'
    ])
  }
}
</script>

<style scoped lang="sass">
.group
  label
    display: inline-block

  .add
    margin-left: 6px

  input
    width: calc(100% - 6px)

.collection-links
  min-height: 70px
</style>
