<template lang='pug'>
  .b-input
    label
      | {{ I18n.t('frontend.tags_input.label') }}
      vue-tags-input(
        :add-on-key='[9, 13, 32, 188]'
        :separators='[";", ",", " "]'
        :autocomplete-items='autocompleteItems'
        :autocomplete-always-open='!!autocompleteItems.length'
        :tags='tags'
        @before-adding-tag='checkTag'
        @tags-changed='syncToInput'
        placeholder=''
        v-model='tag'
      )
    span.hint Заменяет "Раздел". Пока заполнять нужно и теги, и раздел. Через несколько дней раздел исчезнет и останутся только теги
</template>

<script>
import VueTagsInput from '@johmun/vue-tags-input';

export default {
  name: 'TagsInput',
  components: { VueTagsInput },
  props: {
    autocompleteBasic: { type: Array, required: true },
    autocompleteOther: { type: Array, required: true },
    input: { type: HTMLInputElement, required: true },
    value: { type: Array, required: true }
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
        .map(v => ({ text: v }));
    }
  },
  methods: {
    checkTag({ tag, addTag }) {
      tag.text = tag.text.toLowerCase();
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
@import 'app/assets/stylesheets/mixins/input'

/deep/
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
