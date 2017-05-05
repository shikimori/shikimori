<template lang="pug">
  .collection_links
    //input(
      type="button"
      value="add"
      @click="add_collection_link({})"

    .collection_link(
      v-for='collection_link in collection_links'
    )
      input(
        v-if="collection_link.id"
        type="hidden"
        v-model="collection_link.id"
        name="collection[collection_link][id]"
      )
      input(
        type="hidden"
        v-model="collection_link.linked_id"
        v-if="collection_link.linked_id"
        name="collection[collection_link][linked_id]"
      )
      input(
        type="hidden"
        v-model="collection_link.linked_type"
        v-if="collection_link.linked_id"
        name="collection[collection_link][linked_type]"
      )
      .b-input
        label(
          :for="'collection_collection_link_group_' + collection_link.id"
        ) {{ I18n.t('activerecord.attributes.collection_link.group') }}
        input(
          :id="'collection_collection_link_group_' + collection_link.id"
          type="text"
          v-model="collection_link.group"
          name="collection[collection_link][group]"
        )
        div
          a.b-link.bubbled(
            :href="collection_link.url"
          ) {{ collection_link.name }}
      .b-input
        label(
          :for="'collection_collection_link_text_' + collection_link.id"
        ) {{ I18n.t('activerecord.attributes.collection_link.text') }}
        textarea(
          :id="'collection_collection_link_text_' + collection_link.id"
          v-model="collection_link.text"
          name="collection[collection_link][text]"
          rows="2"
        )

    // collection_link(
      v-for='(collection_link, index) in collection_links'
      v-bind:item="collection_link"
      v-bind:key="collection_link.id"
</template>

<script>
  import { mapGetters, mapActions } from 'vuex'

  export default {
    computed: mapGetters([
      'collection_links'
    ]),
    methods: {
      ...mapActions([
        'add_collection_link'
      ])
    }
  }
</script>

<style scoped lang="sass">
  .collection_link
    margin-bottom: 15px
    margin-left: 30px

  textarea
    height: auto

  textarea, .b-input[type=text]
    width: 375px
</style>
