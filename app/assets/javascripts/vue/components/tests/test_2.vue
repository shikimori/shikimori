<template lang="pug">
  .form-group
    input(
      type="text"
      class="form-control"
      :class="input_data.append"
      v-model="input_data.value"
      :placeholder="input_data.placeholder"
      :name="input_data.name"
      :id="input_data.name"
    )
    label(
      :for="input_data.name"
      generated="true"
      class="error"
      v-if="input_data.error"
    ) error: {{ input_data.error }}
  </div>
</template>

<script>
  export default {
    props: {
      input_data: Object
    }
  }
</script>
