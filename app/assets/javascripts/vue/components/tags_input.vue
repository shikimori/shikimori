<template lang='pug'>
  .b-input
    label
      | {{ I18n.t('frontend.tags_input.label') }}
      vue-tags-input(
        :add-on-key='[9, 13, 32, 188]'
        placeholder=''
        :tags='tags'
        @tags-changed='syncToInput'
        @before-adding-tag='checkTag'
        v-model='tag'
      )
</template>

<script>
import VueTagsInput from '@johmun/vue-tags-input';

export default {
  name: 'TagsInput',
  components: { VueTagsInput },
  props: {
    input: { type: HTMLInputElement, required: true },
    value: { type: Array, required: true }
  },
  data() {
    return {
      tag: '',
      tags: this.value.map(v => ({ text: v }))
    };
  },
  methods: {
    checkTag({ tag, addTag }) {
      tag.text = tag.text.toLowerCase();
      addTag(tag);
    },
    syncToInput(newTags) {
      this.input.value = newTags.map(v => v.text).join(',');
    }
  }
};
</script>

<style scoped lang='sass'>
@import 'app/assets/stylesheets/mixins/input'

/deep/
  .ti-focus .ti-input
    +input_focus

  .ti-input
    +input
    padding: 1px
</style>
