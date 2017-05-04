<template lang="pug">
  #app
    p {{ message }}
</template>

<script lang="coffee">
module.exports =
  data: ->
    console.log @
    message: "Hello Vue! 2"
</script>

<style scoped>
</style>
