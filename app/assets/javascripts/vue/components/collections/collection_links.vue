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

      .collection-links
        CollectionLink(
          v-for="link in grouped_links[group_name]"
          :key="link.id"
          :link="link"
    )
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import CollectionLink from './collection_link'

export default {
  components: { CollectionLink },
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

.collection-links
  margin-left: 30px
</style>
