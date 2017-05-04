<template lang="pug">
  .collection_links
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
          v-bind:for="collection_link.id"
        ) {{ I18n.t('activerecord.attributes.collection_link.group') }}
        input(
          type="text"
          v-model="collection_link.group"
          name="collection[collection_link][group]"
        )
        div
          a.b-link.bubbled(
            :href="collection_link.url"
          ) {{ collection_link.name }}

    // collection_link(
      v-for='(collection_link, index) in collection_links'
      v-bind:item="collection_link"
      v-bind:key="collection_link.id"
    // )
</template>

<script lang="coffee">
module.exports =
  computed:
    collection_links: -> @$store.getters.collection_links

  #ready: ->
    #z=arguments
    #debugger
</script>

<style scoped lang="sass">
  .collection_link
    margin-bottom: 15px
</style>
