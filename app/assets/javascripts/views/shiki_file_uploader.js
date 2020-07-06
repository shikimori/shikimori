import { bind } from 'decko';
import uEvent from 'uevent';
import isVisible from 'is-visible';

import Uppy from '@uppy/core';
import XHRUpload from '@uppy/xhr-upload';

import flash from 'services/flash';
import csrf from 'helpers/csrf';
import UppyLocaleRu from 'vendor/uppy_locale_ru';

const I18N_KEY = 'frontend.lib.file_uploader';

export class ShikiFileUploader {
  uploadIDs = []
  docLeaveTimer = null

  constructor({ node, input, progressNode }) {
    uEvent.mixin(this);

    this.node = node;

    this.input = input || this.node.querySelector('input[type=file]');
    this.progressNode = progressNode || this.node.querySelector('.b-upload_progress');
    [this.progressBar] = this.progressNode.children;

    this.uppy = this._initUppy();
    this._bindDragEvents();

    if (this.input) {
      this._bindInput();
    }
  }

  @bind
  destroy() {
    document.removeEventListener('drop', this._docDrop);
    document.removeEventListener('dragenter', this._docEnter);
    document.removeEventListener('dragover', this._docOver);
    document.removeEventListener('dragleave', this._docLeave);
  }

  get endpoint() {
    return this.node.getAttribute('data-upload_url');
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
    this.input.addEventListener('change', ({ currentTarget }) => {
      this.addFiles(currentTarget.files);
    });
  }

  _bindDragEvents() {
    document.addEventListener('dragenter', this._docEnter);
    document.addEventListener('dragleave', this._docLeave);
    document.addEventListener('dragover', this._docOver);
    document.addEventListener('drop', this._docDrop);
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

  _addDropArea() {
    if (this.dropNode || !isVisible(this.node)) { return; }

    const height = this.node.offsetHeight;
    const width = this.node.offsetWidth;
    const text = I18n.t(`${I18N_KEY}.drop_pictures_here`);

    this.dropNode = document.createElement('div');
    this.dropNode.setAttribute('data-text', text);
    this.dropNode.setAttribute('class', 'b-dropzone-drag_placeholder allowed');
    this.dropNode.style = [
      `width: ${width}px !important`,
      `height: ${height}px`,
      `line-height: ${Math.max(height, 75)}px`,
      'opacity: 0'
    ].join(';');
    this.dropNode.addEventListener('drop', this._dragDrop);
    this.dropNode.addEventListener('dragenter', () =>
      this.dropNode.classList.add('hovered')
    );
    this.dropNode.addEventListener('dragleave', () =>
      this.dropNode.classList.remove('hovered')
    );

    this.node.parentNode.insertBefore(this.dropNode, this.node);

    requestAnimationFrame(() =>
      this.dropNode.style.opacity = 0.75
    );
  }

  @bind
  _removeDropArea() {
    if (!this.dropNode) { return; }
    const { dropNode } = this;

    this.dropNode = null;

    dropNode.style.opacity = 0;
    setTimeout(() => dropNode.remove(), 350);
  }

  @bind
  _uploadStart(data) {
    this.uploadIDs = this.uploadIDs.concat(data.fileIDs);

    this.progressNode.classList.add('active');
    this.progressBar.style.width = '0%';
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
    this.progressBar.innerText = text;

    const percent = (this.bytesUploaded * 100.0 / this.bytesTotal).round(2);
    this.progressBar.style.width = `${percent}%`;
  }

  @bind
  _uploadSuccess(_file, response) {
    this.trigger('upload:file:success', response.body);
  }

  @bind
  _uploadComplete({ successful }) {
    if (this.filesUploadedCount !== this.uploadIDs.length) { return; }

    this.uploadIDs = [];

    if (successful.length) {
      this.trigger('upload:complete');
    } else {
      this.trigger('upload:failure');
    }

    this.progressNode.classList.remove('active');
    setTimeout(() => this.progressBar.style.width = '0%', 250);
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
    if (!this.dropNode) { return; }

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
    if (!this.dropNode) { return; }

    fixChromeDocEvent(e);
    e.stopPropagation();
    e.preventDefault();

    clearTimeout(this.docLeaveTimer);
    this.docLeaveTimer = null;
  }

  @bind
  _docLeave(e) {
    if (!this.dropNode) { return; }

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
