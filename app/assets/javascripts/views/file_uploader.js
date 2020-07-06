import { bind } from 'decko';

import Uppy from '@uppy/core';
import XHRUpload from '@uppy/xhr-upload';
import delay from 'delay';

import flash from 'services/flash';
import View from 'views/application/view';
import csrf from 'helpers/csrf';
import UppyLocaleRu from 'vendor/uppy_locale_ru';

const I18N_KEY = 'frontend.lib.file_uploader';
const globalDragLock = false;

export class FileUploader extends View {
  uploadingFileIDs = []
  docLeaveTimer = null

  initialize() {
    this.$root.removeClass('b-ajax');

    this.$input = this.$root.find('input[type=file]');
    this.$progressContainer = this.$root.find('.b-upload_progress');
    this.$progressBar = this.$progressContainer.children();

    this.uppy = this._initUppy();

    this._bindInput();
    this._bindDragEvents();
    this._scheduleUnbind();
  }

  @bind
  destroy() {
    $(document)
      .off('drop', this._docDrop)
      .off('dragenter', this._docEnter)
      .off('dragover', this._docOver)
      .off('dragleave', this._docLeave);
  }

  get endpoint() {
    return this.$root.data('upload_url');
  }

  get uploadBytesTotal() {
    return this.uploadingFileIDs.sum(id => (
      this.uppy.store.state.files[id].progress.bytesTotal
    ));
  }

  get uploadBytesUploaded() {
    return this.uploadingFileIDs.sum(id => (
      this.uppy.store.state.files[id].progress.bytesUploaded
    ));
  }

  addFiles(files) {
    Array.from(files).forEach(file => {
      try {
        this.uppy.addFile({ name: file.name, type: file.type, data: file });
      } catch (error) {
        this.uppy.log(error);
      }
    });
  }

  _bindInput() {
    this.$input.on('change', ({ currentTarget }) => {
      this.addFiles(currentTarget.files);
    });
  }

  _bindDragEvents() {
    $(document)
      .on('dragenter', this._docEnter)
      .on('dragleave', this._docLeave)
      .on('dragover', this._docOver)
      .on('drop', this._docDrop);
  }

  _scheduleUnbind() {
    $(document).one('turbolinks:before-cache', this.destroy);
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
    })
      .use(XHRUpload, {
        endpoint: this.endpoint,
        fieldName: 'image',
        headers: csrf().headers
      })
      // https://uppy.io/docs/uppy/#file-added
      .on('upload', this._uploadStart)
      .on('upload-success', this._uploadSuccess)
      .on('upload-progress', this._uploadProgress)
      .on('complete', this._uploadComplete)
      .on('upload-error', this._uploadError)
      .on('restriction-failed', (_file, error) => {
        flash.error(error.message);
      });
  }

  async _addDropArea() {
    if (this.$dropArea || !this.$root.is(':visible')) { return; }

    const height = this.$root.outerHeight();
    const width = this.$root.outerWidth();
    const text =
      globalDragLock ?
        I18n.t(`${I18N_KEY}.wait_till_loaded`) :
        I18n.t(`${I18N_KEY}.drop_pictures_here`);

    const cls = globalDragLock ? 'disallowed' : 'allowed';

    this.$dropArea = $(`<div data-text='${text}' class='b-dropzone-drag_placeholder ${cls}'
style='width:${width}px!important;height:${height}px;line-height:${Math.max(height, 75)}px;'></div>`)
      .css({ opacity: 0 })
      .on('drop', this._dragDrop)
      .on('dragenter', () => this.$dropArea.addClass('hovered'))
      .on('dragleave', () => this.$dropArea.removeClass('hovered'))
      .insertBefore(this.$root);

    await delay();
    this.$dropArea.css({ opacity: 0.75 });
  }

  @bind
  async _removeDropArea() {
    if (!this.$dropArea) { return; }
    const { $dropArea } = this;

    this.$dropArea = null;

    $dropArea.css({ opacity: 0 });
    await delay(350);
    $dropArea.remove();
  }

  @bind
  _uploadStart(data) {
    this.uploadingFileIDs = data.fileIDs;

    this.$progressContainer.addClass('active');
    this.$progressBar.css('width', '0%');
  }

  @bind
  _uploadProgress(file, _progress) {
    if (this.uploadingFile !== file) {
      this.uploadingFile = file;

      const filename = file.name;
      const filesize = Math.ceil(file.size / 10) / 100;

      this.$progressBar.html(
        I18n.t(`${I18N_KEY}.loading_file`, {
          filename,
          filesize
        })
      );
    }
    const percent = (this.uploadBytesUploaded * 100.0 / this.uploadBytesTotal).round(2);
    this.$progressBar.css('width', `${percent}%`);
  }

  @bind
  _uploadSuccess(_file, response) {
    this.trigger('upload:file:success', response.body);
  }

  @bind
  async _uploadComplete({ successful }) {
    this.uploadingFileIDs = [];

    if (successful.length) {
      this.trigger('upload:complete');
    } else {
      this.trigger('upload:failure');
    }

    this.$progressContainer.removeClass('active');
    await delay(250);
    this.$progressBar.css('width', '0%');
  }

  @bind
  _uploadError(file, error, _response) {
    let message;

    if (error.message === 'Upload error') {
      message = this.uppy.i18n('failedToUpload', { file: file.name });
    } else {
      message = error.message; // eslint-disable-line
    }

    flash.error(message);
  }

  @bind
  _dragDrop(e) {
    e.preventDefault();
    e.stopPropagation();

    this.addFiles(e.dataTransfer.files);
    this._docLeave();
  }
  //
  // _dragEnter(e) {
  //   // console.log('_dragEnter')
  //   if (notFiles(e)) {
  //     return;
  //   }
  //
  //   clearTimeout(this.docLeaveTimer);
  //   e.preventDefault();
  //   opts._dragEnter.call(this, e);
  // }
  //
  // _dragOver(e) {
  //   fixChromeDocEvent(e);
  //
  //   if (notFiles(e)) {
  //     return;
  //   }
  //
  //   clearTimeout(this.docLeaveTimer);
  //   e.preventDefault();
  //   opts._docOver.call(this, e);
  //   opts._dragOver.call(this, e);
  // }
  //
  // _dragLeave(e) {
  //   // console.log('_dragLeave')
  //   clearTimeout(this.docLeaveTimer);
  //   opts._dragLeave.call(this, e);
  //   e.stopPropagation();
  // }

  @bind
  _docDrop(e) {
    if (!this.$dropArea) { return; }

    e.stopPropagation();
    e.preventDefault();

    this._docLeave();
  }

  @bind
  _docEnter(e) {
    if (notFiles(e)) { return; }

    e.stopPropagation();
    e.preventDefault();

    this._addDropArea();

    clearTimeout(this.docLeaveTimer);
  }

  @bind
  _docOver(e) {
    if (!this.$dropArea) { return; }

    fixChromeDocEvent(e);
    e.stopPropagation();
    e.preventDefault();

    clearTimeout(this.docLeaveTimer);
    this.docLeaveTimer = null;
  }

  @bind
  _docLeave(e) {
    if (!this.$dropArea) { return; }

    if (e) {
      e.stopPropagation();
      e.preventDefault();

      this.docLeaveTimer = setTimeout(this._removeDropArea, 200);
    } else {
      this._removeDropArea();
    }
  }
}

function fixChromeDocEvent(e) {
  // Makes it possible to drag files from chrome's download bar
  // http://stackoverflow.com/questions/19526430/drag-and-drop-file-uploads-from-chrome-downloads-bar
  // Try is required to prevent bug in Internet Explorer 11 (SCRIPT65535 exception)
  let efct;
  try { efct = e.dataTransfer.effectAllowed; } catch (_error) {} // eslint-disable-line
  e.dataTransfer.dropEffect = efct === 'move' || efct === 'linkMove' ? 'move' : 'copy';
}

function notFiles(e) {
  if (e.dataTransfer && e.dataTransfer.types && e.dataTransfer.types.length) {
    for (let i = 0; i < e.dataTransfer.types.length; i += 1) {
      if (e.dataTransfer.types[i].toLowerCase() === 'files') {
        return false;
      }
    }
  }
  return true;
}
