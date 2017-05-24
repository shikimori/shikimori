<template lang="pug">
  .external-link(
  )
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  props: {
    external_link: Object,
    link_index: Number
  },
  computed: {
    ...mapGetters([
    ]),
  },
  methods: {
    ...mapActions([
    ])
  }
}
</script>

<style scoped lang="sass">
</style>
