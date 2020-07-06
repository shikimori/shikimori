import { bind } from 'decko';

import Uppy from '@uppy/core';
import XHRUpload from '@uppy/xhr-upload';
import delay from 'delay';

import flash from 'services/flash';
import View from 'views/application/view';
import csrf from 'helpers/csrf';
import UppyLocaleRu from 'vendor/uppy_locale_ru';

const I18N_KEY = 'frontend.lib.file_uploader';

export class FileUploader extends View {
  uploadIDs = []
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
    document.removeEventListener('drop', this._docDrop);
    document.removeEventListener('dragenter', this._docEnter);
    document.removeEventListener('dragover', this._docOver);
    document.removeEventListener('dragleave', this._docLeave);
  }

  get endpoint() {
    return this.$root.data('upload_url');
  }

  get filesUploadedCount() {
    return this.uploadIDs.sum(id => (
      this.uppy.store.state.files[id].progress.uploadComplete ? 1 : 0
    ));
  }

  get bytesTotal() {
    return this.uploadIDs.sum(id => (
      this.uppy.store.state.files[id].progress.bytesTotal
    ));
  }

  get bytesUploaded() {
    return this.uploadIDs.sum(id => (
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
    document.addEventListener('dragenter', this._docEnter);
    document.addEventListener('dragleave', this._docLeave);
    document.addEventListener('dragover', this._docOver);
    document.addEventListener('drop', this._docDrop);
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
    const text = I18n.t(`${I18N_KEY}.drop_pictures_here`);

    this.$dropArea = $(`<div data-text='${text}' class='b-dropzone-drag_placeholder allowed'
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
    this.uploadIDs = this.uploadIDs.concat(data.fileIDs);

    this.$progressContainer.addClass('active');
    this.$progressBar.css('width', '0%');
  }

  @bind
  _uploadProgress(file, _progress) {
    let text;

    if (this.uploadIDs.length === 1) {
      text = I18n.t(`${I18N_KEY}.uploading_file`, {
        filename: file.name,
        filesize: Math.ceil(file.size / 1024)
      });
    } else {
      text = I18n.t(`${I18N_KEY}.uploading_files`, {
        uploadedCount: this.filesUploadedCount,
        totalCount: this.uploadIDs.length,
        kbUploaded: Math.ceil(this.bytesUploaded / 1024),
        kbTotal: Math.ceil(this.bytesTotal / 1024)
      });
    }
    this.$progressBar.html(text);

    const percent = (this.bytesUploaded * 100.0 / this.bytesTotal).round(2);
    this.$progressBar.css('width', `${percent}%`);
  }

  @bind
  _uploadSuccess(_file, response) {
    this.trigger('upload:file:success', response.body);
  }

  @bind
  async _uploadComplete({ successful }) {
    this.uploadIDs = [];

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
    // e.stopPropagation();

    this.addFiles(e.dataTransfer.files);
    this._docLeave();
  }

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
