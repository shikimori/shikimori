<template>
  <div class='b-input'>
    <input
      :id='inputData.name'
      v-model='inputData.value'
      type='text'
      class='form-control'
      autofocus
      :class='inputData.append'
      :placeholder='inputData.placeholder'
      :name='inputData.name'
    >
    <label
      v-if='inputData.error'
      :for='inputData.name'
      generated
      class='error'
    >
      error: {{ inputData.error }}
    </label>
  </div>
</template>

<script>
export default {
  name: 'TestInput',
  props: {
    inputData: { type: Object, required: true }
  }
};
</script>
