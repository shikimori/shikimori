<template>
  <form>
    <div class='test-label'>
      You wrote: {{ inputData.value != '' ? inputData.value : 'nothing' }}
    </div>
    <TestInput
      :input-data='inputData'
    />
    <button class='b-button'>Submit</button>
  </form>
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
