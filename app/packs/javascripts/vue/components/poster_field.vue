<template lang='pug'>
label.b-dropzone.block(
  ref='uploaderRef'
  :class="isTwoLinesHint ? 'is-two_lines_hint' : null"
  :data-hint="isTwoLinesHint ? null : 'Перетаскивай сюда картинку размером от 450x700 пикселей;'"
  :data-hint_1="isTwoLinesHint ? '1. Минимальный размер постера 225х350. Постер должен иметь соотношение сторон 9*14 (225х350, 450х700 и т.п.).' : null"
  :data-hint_2="isTwoLinesHint ? '2. Запрещено изменять пропорции исходного изображения посредством сжатия/растягивания. Для соответствия формату 9*14, его нужно обрезать до загрузки на сайт.' : null"
)
  input.hidden(
    type='file'
  )

.sizes.block(
  v-if='currentSrc'
)
.cc-2
  .c-column
    .cropper-container(
      v-show='currentSrc'
    )
      VueCropper(
        ref='vueCropperRef'
        :src='currentSrc'
        :aspect-ratio='aspectRatio'
        :auto-crop-area='1.0'
        :scalable='false'
        :movable='false'
        :rotatable='false'
        :zoomable='false'
        @crop='onCrop'
      )
    .no-image(
      v-if='!currentSrc'
    )
      img(
        :src='missingSrc'
      )
  .c-column
    p.m5
      | На странице аниме постер отображается целиком,
      | в каталоге аниме картинка отображается обрезанная.
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
      | Кроп превью: {{ sizes.width }}x{{ sizes.height }}
      // .b-button.disable-crop(
      //   @click='disableCrop'
      // ) Отключить

    .b-button.clear.m15(
      @click='clear'
    ) Очистить
    .midheadline
      | Превью
    .preview(
      ref='templateRef'
      v-html='previewTemplateHTML'
    )
</template>

<script setup>
import { ref, reactive, watch, onMounted, nextTick } from 'vue';
import { debounce } from 'throttle-debounce';
import VueCropper from '@ballcat/vue-cropper';

import 'cropperjs/dist/cropper.css';

const props = defineProps({
  src: { type: String, required: false, default: '' },
  cropData: { type: Object, required: false, default: () => ({}) },
  posterId: { type: Number, required: false, default: null },
  previewTemplateHTML: { type: String, required: true },
  previewWidth: { type: Number, required: true },
  previewHeight: { type: Number, required: true },
  isTwoLinesHint: { type: Boolean, required: true }
});

const aspectRatio = props.previewWidth / props.previewHeight;
const missingSrc = '/assets/globals/missing/main@2x.png';

const currentSrc = ref(props.src);
const vueCropperRef = ref(null);
const uploaderRef = ref(null);
const templateRef = ref(null);
const isDisabled = ref(false);
const currentPosterId = ref(props.posterId);
const originalImagedataUri = ref(null);

const sizes = reactive({
  naturalWidth: 0,
  naturalHeight: 0,
  width: 0,
  height: 0
});

let isInitialOnCrop = true;
const onCrop = e => {
  // console.log('onCrop');
  const canvasData = vueCropperRef.value.getCanvasData();

  sizes.naturalWidth = Math.round(canvasData.naturalWidth);
  sizes.naturalHeight = Math.round(canvasData.naturalHeight);
  sizes.width = Math.round(e.detail.width);
  sizes.height = Math.round(e.detail.height);

  if (props.cropData && isInitialOnCrop) {
    isInitialOnCrop = false;
    const cropper = vueCropperRef.value.crop();

    // do not pass minCropBoxWidth & minCropBoxHeight into VueCropper props directly cause
    // it causes cropper re-render and thus cropBoxData is reset asynchronously
    cropper.options.minCropBoxWidth = scaleX(props.previewWidth);
    cropper.options.minCropBoxHeight = scaleY(props.previewHeight);
    cropper.limitCropBox(true, true);

    const { height, left, top, width } = props.cropData;
    const { maxHeight, maxWidth } = vueCropperRef.value.crop().cropBoxData;

    // Math.round is necessary because
    // sometimes scaling returns height higher than actual image size is
    // have take MIN because calculated size can be ~0.1-0.9px larger than max allowed size
    // https://shikimori.one/animes/51125-inamori-asuto-no-soccer-kyoushitsu/edit/poster
    const cropWidth = Math.min(Math.round(scaleX(width)), maxWidth);
    const cropHeight = Math.min(Math.round(scaleY(height)), maxHeight);

    vueCropperRef.value.setCropBoxData({
      height: cropHeight,
      left: scaleX(left),
      top: scaleY(top),
      width: cropWidth
    });
  }

  syncPreviewImage();
};

defineExpose({
  posterId() {
    return currentPosterId.value;
  },
  cropData() {
    const data = vueCropperRef.value.getCropBoxData();

    return {
      height: descaleY(data.height),
      left: descaleX(data.left),
      top: descaleY(data.top),
      width: descaleX(data.width)
    };
  },
  toDataURI() {
    return currentPosterId.value ?
      null :
      originalImagedataUri.value;
      // vueCropperRef.value
      //   .crop()
      //   .clear()
      //   .getCroppedCanvas()
      //   .toDataURL();
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

async function onFileAdded(uploader, uppyFile) {
  currentSrc.value = URL.createObjectURL(uppyFile.data);
  currentPosterId.value = null;
  uploader.uppy.reset();

  originalImagedataUri.value = await new Promise(resolve => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.readAsDataURL(uppyFile.data);
  });
}

function clear() {
  currentSrc.value = '';
  currentPosterId.value = null;
  syncPreviewImage();
}

let isInitialSync = true;
const syncPreviewImage = debounce(100, () => {
  const exportedDataUri = vueCropperRef.value.getCroppedCanvas()?.toDataURL();
  templateRef.value.querySelector('source')?.remove();

  templateRef.value.querySelectorAll('source').forEach(sourceNode => sourceNode.remove());
  templateRef.value.querySelectorAll('img').forEach((imgNode, index) => {
    const isPreviewDerivative = index === 0;
    const isMisshapedImage = sizes.naturalWidth >= sizes.naturalHeight;

    if (!isInitialSync && !isPreviewDerivative) {
      const derivativeNode = templateRef.value.querySelector('.derivative-mini.is-need-rescale');

      if (derivativeNode) {
        derivativeNode.classList.add('is-rescaled');
        derivativeNode.classList.remove('is-need-rescale');
      }
    }

    imgNode.srcset = '';
    imgNode.src = (
      isPreviewDerivative && isMisshapedImage ?
        currentSrc.value :
        exportedDataUri
    ) || missingSrc;
  });
  isInitialSync = false;
});

function disableCrop() {
  isDisabled.value = true;

  vueCropperRef.value.setAspectRatio(0);
  vueCropperRef.value.disable();
}

function enableCrop() {
  isDisabled.value = false;

  vueCropperRef.value.enable();
  vueCropperRef.value.setAspectRatio(aspectRatio);
}

function scaleX(value) {
  return value * ratioX();
}

function descaleX(value) {
  return Math.round(value / ratioX());
}

function scaleY(value) {
  return value * ratioY();
}

function descaleY(value) {
  return Math.round(value / ratioY());
}

function ratioX() {
  const { naturalWidth, width } = vueCropperRef.value.getCanvasData();
  return width / naturalWidth;
}

function ratioY() {
  const { naturalHeight, height } = vueCropperRef.value.getCanvasData();
  return height / naturalHeight;
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

.preview
  display: flex
  gap: 20px

  ::v-deep()
    .derivative-preview img
      width: 160px

    .derivative-mini
      &.is-rescaled
        .rescale-cutter
          display: inline-block
          overflow: hidden
          width: 48px

        img
          width: 53px
          margin-left: -2.5px

      img
        width: 48px
</style>
