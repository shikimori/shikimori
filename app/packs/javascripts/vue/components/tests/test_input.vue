<template inherit-attrs='false'>
  <div class='b-input'>
    <input
      :id='name'
      :value='modelValue'
      type='text'
      class='form-control'
      autofocus
      :class='$attrs.class'
      :placeholder='placeholder'
      :name='name'
      @input='$emit("update:modelValue", $event.target.value)'
    >
    <label
      v-if='error'
      :for='name'
      generated
      class='error'
    >
      error: {{ error }}
    </label>
  </div>
</template>

<script setup>
defineProps({
  modelValue: { type: [String, Number], required: false, default: '' },
  name: { type: String, required: true },
  error: { type: String, required: false, default: '' },
  placeholder: { type: String, required: false, default: '' }
});

defineEmits(['update:modelValue']);
</script>
