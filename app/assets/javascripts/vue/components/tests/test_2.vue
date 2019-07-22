<template lang="pug">
  .b-input
    input(
      type="text"
      class="form-control"
      autofocus
      :class="inputData.append"
      v-model="inputData.value"
      :placeholder="inputData.placeholder"
      :name="inputData.name"
      :id="inputData.name"
    )
    label(
      :for="inputData.name"
      generated="true"
      class="error"
      v-if="inputData.error"
    ) error: {{ inputData.error }}
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
