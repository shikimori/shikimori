import Uppy from '@uppy/core';
import XHRUpload from '@uppy/xhr-upload';

import flash from 'services/flash';
import View from 'views/application/view';
import csrf from 'helpers/csrf';
import UppyRuLocale from 'vendor/uppy_ru_locale';

// const I18N_KEY = 'frontend.lib.jquery_shiki_file';

export class FileUploader extends View {
  initialize() {
    this.$input = this.$root.find('input[type=file]');
    this.$progress = this.$root.find('.b-upload_progress');

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
      debug: true,
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
      locale: window.LOCALE === 'ru' ? UppyRuLocale : undefined
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
      .on('complete', _result => {
        this.trigger('upload:complete');
      })
      .on('upload-error', (_file, error, _response) => {
        flash.error(error.message);
      })
      .on('restriction-failed', (_file, error) => {
        flash.error(error.message);
        // flash.error(I18n.t(`${I18N_KEY}.too_large_file`));
      });
  }
}
