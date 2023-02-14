<template lang='pug'>
.b-collection_item
  .delete(
    @click='remove(link.key)'
  )
  .drag-handle
  input(
    type='hidden'
    v-model='link.entry_id'
    :name="fieldName('entry_id')"
  )
  input(
    type='hidden'
    v-model='link.entry_type'
    :name="fieldName('entry_type')"
  )
  input(
    type='hidden'
    v-model='link.created_at'
    :name="fieldName('created_at')"
  )
  input(
    type='hidden'
    v-model='link.updated_at'
    :name="fieldName('updated_at')"
  )
  input(
    type='hidden'
    v-model='link.imported_at'
    :name="fieldName('imported_at')"
  )
  input(
    type='hidden'
    v-model='link.source'
    :name="fieldName('source')"
  )
  .b-input.select
    select(
      :value='link.kind'
      :name="fieldName('kind')"
      @input='updateField("kind", $event.target.value)'
    )
      optgroup(
        :label='I18n.t("frontend.external_links.groups.links")'
      )
        option(
          v-for='kindOption in kindOptionsLinks'
          :value='kindOption.last()'
        ) {{ kindOption.first() }}
      optgroup(
        :label='I18n.t("frontend.external_links.groups.watch_online")'
      )
        option(
          v-for='kindOption in kindOptionsWatchOnline'
          :value='kindOption.last()'
        ) {{ kindOption.first() }}
  .b-input
    input(
      ref='inputRef'
      type='text'
      :value='link.url'
      :name="fieldName('url')"
      :placeholder="I18n.t('activerecord.attributes.external_link.url')"
      @input='updateField("url", $event.target.value)'
      @keydown.enter='submit'
      @keydown.backspace='removeEmpty(link)'
      @keydown.esc='removeEmpty(link)'
    )
    span.hint.warn(
      v-if='isYoutubeKind'
    )
      | {{ I18n.t('frontend.external_links.warn.youtube') }}
    span.hint.warn(
      v-else-if='isYoutubeChannelKind'
    )
      | {{ I18n.t('frontend.external_links.warn.youtube_channel') }}
    span.hint.warn(
      v-else-if='isWatchOnlineKind'
    )
      | {{ I18n.t('frontend.external_links.warn.watch_online') }}
</template>

<script setup>
import { computed } from 'vue';
import { useStore } from 'vuex';

const props = defineProps({
  link: { type: Object, required: true },
  kindOptions: { type: Array, required: true },
  resourceType: { type: String, required: true },
  entryType: { type: String, required: true },
  entryId: { type: Number, required: true },
  watchOnlineKinds: { type: Array, required: true }
});

const store = useStore();
const emit = defineEmits(['add:next', 'focus:last']);

// onMounted(async () => {
//   await nextTick();
//   $('input', this.$el).focus();
//   });

const collection = computed(() => store.state.collection);
const isYoutubeKind = computed(() => props.link.kind === 'youtube');
const isYoutubeChannelKind = computed(() => (
  props.link.kind === 'youtube_channel'
));
const isWatchOnlineKind = computed(() => (
  props.watchOnlineKinds.includes(props.link.kind)
));
const kindOptionsLinks = computed(() => (
  props.kindOptions.filter(v => !props.watchOnlineKinds.includes(v[1]))
));
const kindOptionsWatchOnline = computed(() => (
  props.kindOptions.filter(v => props.watchOnlineKinds.includes(v[1]))
));

function fieldName(name) {
  if (!Object.isEmpty(props.link.url)) {
    return `${props.resourceType.toLowerCase()}[external_links][][${name}]`;
  }
  return '';
}

function updateField(field, value) {
  store.dispatch('update', {
    ...props.link,
    [field]: value
  });
}

function submit(e) {
  if (!e.metaKey && !e.ctrlKey) {
    e.preventDefault();
    emit('add:next');
  }
}

function removeEmpty(link) {
  if (Object.isEmpty(link.url) && collection.value.length > 1) {
    store.dispatch('remove', link.key);
    emit('focus:last');
  }
}

defineExpose({
  focus() {
  }
});
</script>

<style scoped lang='sass'>
.b-collection_item
  &:first-child:last-child
    .drag-handle
      display: none

  .b-input
    margin-bottom: 2px

    &.select
      margin-bottom: 5px

    .hint.warn
      margin-top: 3px
      color: #fc575e

  .drag-handle
    margin-top: 3px
</style>
