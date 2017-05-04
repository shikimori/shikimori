<template lang="pug">
  .b-input
    label(
      v-bind:for="id"
    ) Группа
    input(
      type="text"
      value="test"
      name="collection[collection_link][group]"
    )
</template>

<script lang="coffee">
module.exports =
  props: [
    'linked_id'
    'linked_type'
  ]
  data: ->
    console.log @, arguments
    message: "Hello Vue! 2"
</script>

<style scoped>
</style>
