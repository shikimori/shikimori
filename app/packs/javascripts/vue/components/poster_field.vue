<template lang='pug'>
label.b-dropzone(
  ref='uploaderRef'
  data-hint='Перетаскивай сюда картинку, размер от 450x700 до 900x1400 пикселей;'
)
  input.hidden(
    type='file'
  )
.cropper-container
  VueCropper(
    v-if='currentSrc'
    ref='vueCropperRef'
    :src='currentSrc'
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

const currentSrc = ref(props.src);
const vueCropperRef = ref(null);
const uploaderRef = ref(null);

onMounted(async () => {
  const { FileUploader } = await import('@/views/file_uploader');

  new FileUploader(uploaderRef.value, {
    autoProceed: false,
    isResetAfterUpload: false,
    maxNumberOfFiles: 1,
    maxFileSize: 1024 * 1024 * 15
  })
    .on('upload:file:added', ({ target }, file) => onFileAdded(target, file));
});

defineExpose({
  toDataURI() {
    return vueCropperRef.value?.getCroppedCanvas()?.toDataURL();
  }
});

function onFileAdded(uploader, uppyFile) {
  currentSrc.value = URL.createObjectURL(uppyFile.data);
  uploader.uppy.reset();
}
</script>

<style scoped lang='sass'>
.cropper-container
  margin-top: 30px
  width: 450px
</style>
