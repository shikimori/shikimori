<template lang="pug">
  form
    .test-label You wrote: {{inputData.value != '' ? inputData.value : 'nothing'}}
    TestInput(
      :input-data="inputData"
    )
    button.b-button Submit
</template>

<script>
import TestInput from './test_2';

export default {
  name: 'Test',
  components: { TestInput },
  data: () => ({
    inputData: {
      name: Math.random().toString(36).replace(/[^a-z]+/g, '').substr(0, 5),
      append: '',
      value: '',
      placeholder: '',
      error: 'zz'
    }
  })
};
</script>

<style scoped lang="sass">
form
  display: block

.test-label
  margin-bottom: 5px
</style>
