<template lang='pug'>
.b-input
  label
    | {{ label }}
    VueTagsInput(
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

<script setup>
import { defineProps, ref, computed } from 'vue';

import VueTagsInput from '@sipec/vue3-tags-input';

const props = defineProps({
  label: { type: String, required: true },
  hint: { type: String, required: false, default: undefined },
  tagsLimit: { type: Number, required: true },
  autocompleteBasic: { type: Array, required: true },
  autocompleteOther: { type: Array, required: true },
  input: { type: HTMLInputElement, required: true },
  value: { type: Array, required: true },
  isDowncase: { type: Boolean, required: false, default: false }
});

let tag = ref('');
let tags = ref(props.value.map(v => ({ text: v })));

const autocompleteItems = computed(() => (
  (
    tags.value.length && props.autocompleteOther.length ?
      props.autocompleteOther :
      props.autocompleteBasic
  )
    .filter(v => !tags.value.find(tag_value => tag_value.text === v))
    .filter(v => (tag.value ? v.startsWith(tag.value) : true))
    .map(v => ({ text: v }))
));

const separators = computed(() => (
  props.tagsLimit > 1 ?
    [';', ',', ' '] :
    undefined
));

const addOnKey = computed(() => (
  props.tagsLimit > 1 ?
    [9, 13, 32, ','] :
    undefined
));

function checkTag({ tag, addTag }) {
  if (props.isDowncase) {
    tag.text = tag.text.toLowerCase();
  }
  addTag(tag);
}

function syncToInput(newTags) {
  tags.value = newTags;
  props.input.value = tags.value.map(v => v.text).join(','); // eslint-disable-line vue/no-mutating-props
}
</script>

<style scoped lang='sass'>
@import 'app/assets/stylesheets/mixins/input'

.b-input /deep/
  .vue-tags-input
    max-width: 100% !important

  .ti-autocomplete
    display: none
    z-index: 31

  .ti-focus
    .ti-input
      +input_focus

    .ti-autocomplete
      display: block

  .ti-input
    +input
    padding: 0 1px
    max-width: 100% !important

    input
      width: 100% !important

  .ti-tag
    font-size: 12px
    margin: 4px 2px

    .ti-icon-close
      transition: opacity 0.25s ease
      opacity: 0.8

      +gte_laptop
        &:hover
          opacity: 1

      &:active
        opacity: 0.6

    .ti-content
      align-items: flex-start

  .ti-new-tag-input-wrapper
    margin: 0
    padding: 0

    .ti-new-tag-input
      +input
      border: none
      padding: 0 7px
</style>
