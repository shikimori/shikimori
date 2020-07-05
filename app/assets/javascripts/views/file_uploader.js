import Uppy from '@uppy/core';
import XHRUpload from '@uppy/xhr-upload';
import delay from 'delay';

import flash from 'services/flash';
import View from 'views/application/view';
import csrf from 'helpers/csrf';
import UppyLocaleRu from 'vendor/uppy_locale_ru';

// const I18N_KEY = 'frontend.lib.jquery_shiki_file';

export class FileUploader extends View {
  initialize() {
    this.$input = this.$root.find('input[type=file]');
    this.$progressContainer = this.$root.find('.b-upload_progress');
    this.$progressBar = this.$progressContainer.children();

    this.uppy = this._initUppy();

    this.$input.on('change', ({ currentTarget }) => {
      Array.from(currentTarget.files).forEach(file => (
        this.uppy.addFile({
          name: file.name,
          type: file.type,
          data: file
        })
      ));
    });
  }

  get endpoint() {
    return this.$root.data('upload_url');
  }

  _initUppy() {
    return Uppy({
      // id: 'uppy',
      autoProceed: true,
      allowMultipleUploads: true,
      // debug: true,
      restrictions: {
        maxFileSize: 1024 * 1024 * 4,
        maxNumberOfFiles: 150,
        minNumberOfFiles: null,
        allowedFileTypes: ['image/jpg', 'image/jpeg', 'image/png']
      },
      // meta: {},
      // onBeforeFileAdded: (currentFile, _files) => {
      //   console.log('onBeforeFileAdded', currentFile);
      //   return currentFile;
      // },
      // onBeforeUpload: _files => {
      //   console.log('onBeforeUpload');
      // },
      locale: window.LOCALE === 'ru' ? UppyLocaleRu : undefined
      // store: new DefaultStore(),
      // logger: justErrorsLogger
    })
      .use(XHRUpload, {
        endpoint: this.endpoint,
        fieldName: 'image',
        headers: csrf().headers
      })
      // uppy.use(ProgressBar, {
      //   target: '.UploadForm',
      //   fixed: false,
      //   hideAfterFinish: true
      // })
      .on('upload-success', (_file, response) => {
        this.trigger('upload:file:success', response.body);
      })
      .on('upload-progress', (file, progress) => {
        // file: { id, name, type, ... }
        // progress: { uploader, bytesUploaded, bytesTotal }
        console.log(file.id, progress.bytesUploaded, progress.bytesTotal);
      })
      .on('reset-progress', () => {
      })
      .on('complete', ({ successful }) => {
        this._hideProgress();

        if (successful.length) {
          this.trigger('upload:complete');
        } else {
          this.trigger('upload:failure');
        }
      })
      .on('upload-error', (file, error, _response) => {
        let message;

        if (error.message === 'Upload error') {
          message = this.uppy.i18n('failedToUpload', { file: file.name });
        } else {
          message = error.message; // eslint-disable-line
        }

        flash.error(message);
      })
      .on('restriction-failed', (_file, error) => {
        flash.error(error.message);
      });
  }

  async _hideProgress() {
    this.$progressContainer.removeClass('active');
    await delay(250);
    this.$progressBar.width('0%');
  }
}
