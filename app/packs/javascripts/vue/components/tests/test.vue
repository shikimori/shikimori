<template>
  <form>
    <div>{{ isLoading ? `Loading... ${timer}` : 'Loaded!' }}</div>
    <div class='test-label'>
      You wrote: {{ inputData.value ? inputData.value : 'nothing' }}
    </div>
    <TestInput
      v-model='inputData.value'
      v-bind='inputData'
    />
    <button class='b-button'>Submit</button>
    <pre class='b-code-v2'><code>{{ inputData }}</code></pre>
  </form>
</template>

<script setup>
import { reactive, ref } from 'vue';
import delay from 'delay';
import TestInput from './test_input';

const isLoading = ref(true);
const timer = ref(5);

const inputData = reactive({
  name: Math.random().toString(36).replace(/[^a-z]+/g, '').substr(0, 5),
  class: 'xx',
  value: '',
  placeholder: 'Placeholder',
  error: 'zzz'
});

delay(1000).then(async () => {
  timer.value -= 1;
  await delay(1000);
  timer.value -= 1;
  await delay(1000);
  timer.value -= 1;
  await delay(1000);
  timer.value -= 1;
  await delay(1000);
  isLoading.value = false;
});
</script>

<style scoped lang="sass">
form
  display: block

.test-label
  margin-bottom: 5px
</style>
