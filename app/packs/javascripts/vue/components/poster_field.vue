<template lang='pug'>
label.b-dropzone.block(
  ref='uploaderRef'
  data-hint='Перетаскивай сюда картинку размером от 450x700 до 900x1400 пикселей;'
)
  input.hidden(
    type='file'
  )

.sizes.block
  p(
    v-if='sizes.naturalWidth'
  ) Размер: {{ sizes.naturalWidth }}x{{ sizes.naturalHeight }}
  p(
    v-if='sizes.naturalWidth !== sizes.width'
  ) Кроп: {{ sizes.width }}x{{ sizes.height }}

.cropper-container(
  v-show='currentSrc'
)
  VueCropper(
    ref='vueCropperRef'
    :src='currentSrc'
    :aspect-ratio='225/350'
    :auto-crop-area='1.0'
    @crop='onCrop'
  )
</template>

<script setup>
import { ref, reactive, watch, onMounted } from 'vue';
import VueCropper from '@ballcat/vue-cropper';
import 'cropperjs/dist/cropper.css';

const props = defineProps({
  src: { type: String, required: false, default: '' }
});

const currentSrc = ref(props.src);
const vueCropperRef = ref(null);
const uploaderRef = ref(null);

const sizes = reactive({
  naturalWidth: 0,
  naturalHeight: 0,
  width: 0,
  height: 0
});

const onCrop = e => {
  const canvasData = vueCropperRef.value.getCanvasData();

  sizes.naturalWidth = Math.ceil(canvasData.naturalWidth);
  sizes.naturalHeight = Math.ceil(canvasData.naturalHeight);
  sizes.width = Math.ceil(e.detail.width);
  sizes.height = Math.ceil(e.detail.height);
};

defineExpose({
  toDataURI() {
    return vueCropperRef.value?.getCroppedCanvas()?.toDataURL();
  }
});

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

function onFileAdded(uploader, uppyFile) {
  currentSrc.value = URL.createObjectURL(uppyFile.data);
  uploader.uppy.reset();
}
</script>

<style scoped lang='sass'>
.sizes
  font-size: 14px

.cropper-container
  width: 450px
</style>
