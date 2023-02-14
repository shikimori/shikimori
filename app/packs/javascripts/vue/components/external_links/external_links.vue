<template lang='pug'>
.block_m(ref='rootRef')
  input(
    type='hidden'
    :name="`${resourceType.toLowerCase()}[external_links][]`"
    v-if='isEmpty'
  )
  .b-nothing_here(
    v-if='!collection.length'
  )
    | {{ I18n.t('frontend.external_links.nothing_here') }}
  draggable.block(
    v-if='collection.length'
    v-model='collection'
    item-key='element => element.id || element.key'
    v-bind='dragOptions'
  )
    template(#item="{element}")
      ExternalLink(
        :link='element'
        :kind-options='kindOptions'
        :resource-type='resourceType'
        :entry-type='entryType'
        :entry-id='entryId'
        :watch-online-kinds='watchOnlineKinds'
        @link:create='createLink()'
        @link:remove='removeLink'
      )
  .b-button(
    @click='createLink()'
  ) {{ I18n.t('frontend.actions.add') }}
</template>

<script setup>
import { ref, computed, nextTick } from 'vue';
import { useStore } from 'vuex';

import ExternalLink from './external_link';
import draggable from 'vuedraggable';
import delay from 'delay';

const props = defineProps({
  kindOptions: { type: Array, required: true },
  resourceType: { type: String, required: true },
  entryType: { type: String, required: true },
  entryId: { type: Number, required: true },
  watchOnlineKinds: { type: Array, required: true }
});

const store = useStore();
const rootRef = ref(null);

const dragOptions = {
  group: 'external_links',
  handle: '.drag-handle'
};

const isEmpty = computed(() => store.getters.isEmpty);
const collection = computed({
  get() {
    return store.state.collection;
  },
  set(value) {
    store.dispatch('replace', value);
  }
});

function createLink(
  kind = props.kindOptions.first().last(),
  url = ''
) {
  store.dispatch('add', {
    kind,
    url,
    source: 'shikimori',
    id: '',
    entry_id: props.entryId,
    entry_type: props.entryType
  });
  focusLast();
}

function removeLink({ key, isFocus }) {
  store.dispatch('remove', key);

  if (isFocus) {
    focusLast();
  }
}

async function focusLast() {
  await Promise.all([delay(), nextTick()]);
  const inputs = rootRef.value.querySelectorAll('input');
  inputs[inputs.length - 1].focus();
}

defineExpose({
  async cleanupLink({ kind, url }) {
    const isWikipedia = kind === 'wikipedia';
    const wikipediaPrefix = url.replace(/(wikipedia.org\/).*/, '$1');
    const nullifiedUrl = isWikipedia ? wikipediaPrefix + 'NONE' : 'NONE';

    let matchedByKindInputs = Array
      .from(rootRef.value.querySelectorAll(`input[data-kind="${kind}"]`));
    if (isWikipedia) {
      matchedByKindInputs = matchedByKindInputs.filter(input => (
        input.value.startsWith(wikipediaPrefix)
      ));
    }
    const matchedByValueInput = matchedByKindInputs
      .find(node => node.value === nullifiedUrl);

    if (matchedByKindInputs.length === 1 && !matchedByValueInput) {
      const matchedLink = collection.value.find(link => (
        link.kind === kind && (!isWikipedia || link.url.startsWith(wikipediaPrefix))
      ));
      nullifyLink(matchedLink, nullifiedUrl, matchedByKindInputs[0]);

    } else if (matchedByValueInput) {
      matchedByValueInput.focus();

    } else {
      createLink(kind, nullifiedUrl);
    }
  }
});

async function nullifyLink(link, url, input) {
  store.dispatch('update', { ...link, url });
  await Promise.all([delay(), nextTick()]);
  input.focus();
}
</script>

<style scoped lang='sass'>
.b-nothing_here
  margin-bottom: 15px
</style>
