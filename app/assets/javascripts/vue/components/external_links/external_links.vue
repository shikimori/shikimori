<template lang="pug">
  .block
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import ExternalLink from './external_link'
import draggable from 'vuedraggable'

export default {
  components: { ExternalLink, draggable },
  data () {
    return {
    }
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
