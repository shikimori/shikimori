<template>
  <form>
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
import TestInput from './test_input';
import { reactive } from 'vue';

const inputData = reactive({
  name: Math.random().toString(36).replace(/[^a-z]+/g, '').substr(0, 5),
  class: 'xx',
  value: '',
  placeholder: 'Placeholder',
  error: 'zzz'
});
</script>

<style scoped lang="sass">
form
  display: block

.test-label
  margin-bottom: 5px
</style>
