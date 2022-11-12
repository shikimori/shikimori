<template lang='pug'>
VueCropper(
  ref='vueCropperRef'
  :src='src'
  :aspect-ratio='225/350'
  :auto-crop-area='1.0'
)
</template>

<script setup>
import { ref, onMounted } from 'vue';
import VueCropper from '@ballcat/vue-cropper';
import 'cropperjs/dist/cropper.css';

const props = defineProps({
  src: { type: String, required: false, default: null }
});
const vueCropperRef = ref(null);

// vueCropperRef.value.getCroppedCanvas().toDataURL()
// vueCropperRef.value.getCroppedCanvas().toBlob()

defineExpose({
  toDataURI() {
    return vueCropperRef.value.getCroppedCanvas().toDataURL();
  }
});
</script>

<style scoped lang='sass'>
</style>
