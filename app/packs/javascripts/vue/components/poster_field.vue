<template lang='pug'>
label.b-dropzone.block(
  ref='uploaderRef'
  data-hint='Перетаскивай сюда картинку размером от 450x700 пикселей;'
)
  input.hidden(
    type='file'
  )

.sizes.block(
  v-if='currentSrc'
)
  p(
    v-if='sizes.naturalWidth'
  ) Картинка: {{ sizes.naturalWidth }}x{{ sizes.naturalHeight }}
  // p(
  //   v-if='isDisabled'
  // )
  //   | Кроп: отключено
  //   .b-button.enable-crop(
  //     @click='enableCrop'
  //   ) Включить
  p(
    v-if='sizes.naturalWidth !== sizes.width || sizes.naturalHeight !== sizes.height'
  )
    | Кроп превьюшки: {{ sizes.width }}x{{ sizes.height }}
    // .b-button.disable-crop(
    //   @click='disableCrop'
    // ) Отключить

  .b-button.clear(
    @click='clear'
  ) Очистить

.cropper-container(
  v-show='currentSrc'
)
  VueCropper(
    ref='vueCropperRef'
    :src='currentSrc'
    :aspect-ratio='DEFAULT_ASPECT_RATIO'
    :auto-crop-area='1.0'
    @crop='onCrop'
  )
.no-image(
  v-if='!currentSrc'
)
  img(
    src='/assets/globals/missing_original.jpg'
  )
</template>

<script setup>
import { ref, reactive, watch, onMounted, nextTick } from 'vue';
import VueCropper from '@ballcat/vue-cropper';
import 'cropperjs/dist/cropper.css';

const props = defineProps({
  src: { type: String, required: false, default: '' },
  cropData: { type: Object, required: false, default: () => ({}) }
});

const DEFAULT_ASPECT_RATIO = 225/350;

const currentSrc = ref(props.src);
const vueCropperRef = ref(null);
const uploaderRef = ref(null);
const isDisabled = ref(false);

const sizes = reactive({
  naturalWidth: 0,
  naturalHeight: 0,
  width: 0,
  height: 0
});

let isInitialOnCrop = true;
const onCrop = e => {
  const canvasData = vueCropperRef.value.getCanvasData();

  sizes.naturalWidth = Math.ceil(canvasData.naturalWidth);
  sizes.naturalHeight = Math.ceil(canvasData.naturalHeight);
  sizes.width = Math.ceil(e.detail.width);
  sizes.height = Math.ceil(e.detail.height);

  if (props.cropData && isInitialOnCrop) {
    isInitialOnCrop = false;
    vueCropperRef.value.setCropBoxData(props.cropData);
  }
};

defineExpose({
  cropData() {
    const data = vueCropperRef.value.getCropBoxData();

    return {
      height: Math.round(data.height),
      left: Math.round(data.left),
      top: Math.round(data.top),
      width: Math.round(data.width)
    };
  },
  toDataURI() {
    return vueCropperRef.value
      .crop()
      .clear()
      .getCroppedCanvas()
      .toDataURL();
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

function clear() {
  currentSrc.value = '';
}
function disableCrop() {
  isDisabled.value = true;

  vueCropperRef.value.setAspectRatio(0);
  vueCropperRef.value.disable();
}

function enableCrop() {
  isDisabled.value = false;

  vueCropperRef.value.enable();
  vueCropperRef.value.setAspectRatio(DEFAULT_ASPECT_RATIO);
}
</script>

<style scoped lang='sass'>
.sizes
  font-size: 14px

.clear
  margin-top: 8px

.enable-crop,
.disable-crop
  margin-left: 8px

.cropper-container
  max-width: 100%
  width: 450px

::v-deep(.cropper-disabled)
  .cropper-view-box
    outline-color: rgba(#a630ff, 0.75)

  .cropper-line
    background-color: #a630ff

  .cropper-point
    background-color: #8e00fa
</style>
