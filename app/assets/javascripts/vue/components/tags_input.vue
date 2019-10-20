<template lang='pug'>
  .b-input
    label
      | {{ label }}
      vue-tags-input(
        :add-on-key='addOnKey'
        :separators='separators'
        :autocomplete-items='autocompleteItems'
        :autocomplete-always-open='tags.length < tagsLimit && !!autocompleteItems.length'
        :tags='tags'
        :max-tags='tagsLimit'
        @before-adding-tag='checkTag'
        @tags-changed='syncToInput'
        placeholder=''
        v-model='tag'
      )
    span.hint(
      v-if='hint'
      v-html='hint'
    )
</template>

<script>
import VueTagsInput from '@johmun/vue-tags-input';

export default {
  name: 'TagsInput',
  components: { VueTagsInput },
  props: {
    label: { type: String, required: true },
    hint: { type: String, required: false, default: undefined },
    tagsLimit: { type: Number, required: true },
    autocompleteBasic: { type: Array, required: true },
    autocompleteOther: { type: Array, required: true },
    input: { type: HTMLInputElement, required: true },
    value: { type: Array, required: true },
    isDowncase: { type: Boolean, required: false, default: false }
  },
  data() {
    return {
      tag: '',
      tags: this.value.map(v => ({ text: v }))
    };
  },
  computed: {
    autocompleteItems() {
      return (
        this.tags.length ? this.autocompleteOther : this.autocompleteBasic
      )
        .filter(v => !this.tags.find(tag => tag.text === v))
        .filter(v => (this.tag ? v.startsWith(this.tag) : true))
        .map(v => ({ text: v }));
    },
    separators() {
      return this.tagsLimit > 1 ? [';', ',', ' '] : undefined;
    },
    addOnKey() {
      return this.tagsLimit > 1 ? [9, 13, 32, 188] : undefined;
    }
  },
  methods: {
    checkTag({ tag, addTag }) {
      if (this.isDowncase) {
        tag.text = tag.text.toLowerCase();
      }
      addTag(tag);
    },
    syncToInput(newTags) {
      this.tags = newTags;
      this.input.value = this.tags.map(v => v.text).join(',');
    }
  }
};
</script>

<style scoped lang='sass'>
@import 'app/assets/stylesheets/globals/variables'
@import 'app/assets/stylesheets/mixins/*'

.b-input /deep/
  .ti-autocomplete
    display: none

  .ti-focus
    .ti-input
      +input_focus

    .ti-autocomplete
      display: block

  .ti-input
    +input
    padding: 1px
    max-width: 100% !important
</style>
