import uEvent from 'uevent';
import { Base64 } from 'js-base64';

import axios from '@/helpers/axios';

export class LoaderBase {
  FETCH_EVENT = 'loader:fetch';

  constructor(tag, forbiddenTags) {
    uEvent.mixin(this);

    this.tag = tag;
    this.forbiddenTags = forbiddenTags;

    this.page = 1;
    this.limit = 100;
    this.isFinished = false;
    this.isLoading = false;

    if (window.ENV === 'development') {
      this.camoBaseUrl = 'https://camo-v3.shikimori.one';
    } else {
      this.camoBaseUrl = window.CAMO_URL;
    }

    this._initialize();
  }

  // public methods
  fetch() {
    this.isLoading = true;

    axios
      .get(this._shikiLoadUrl())
      .catch(() => this._fetchFail())
      .then(response => this._fetchSuccess(response?.data || []));
  }

  // handlers
  _fetchSuccess(data) {
    const images = this._xhrToImages(data);
    this.page += 1;
    this.isLoading = false;

    console.log(this.name, `fetched: ${images.length}`, `is_finished: ${this.isFinished}`);

    this.trigger(this.FETCH_EVENT, images);
  }

  _fetchFail() {
    this.isLoading = false;
    console.warn('fetch failure');
  }

  // private methods
  _xhrToImages(data) {
    const images = this._buildImages(data);

    if (images.length !== this.limit) {
      this.isFinished = true;
    }

    return this._censor(images).reverse();
  }

  _buildImages(rawData) {
    const data = Object.isObject(rawData) ? [rawData] : rawData;

    return data
      .exclude(image => !image.file_url || !image.preview_url)
      .map(image => {
        const filename = this._filename(image);

        return {
          id: image.id,
          md5: image.md5,
          tags: image.tags,
          rating: image.rating,
          original_url: this._imageUrl(image.file_url, filename),
          preview_url: this._previewUrl(image.preview_url, filename)
        };
      });
  }

  _censor(images) {
    if (!this.forbiddenTags) { return images; }

    return images
      .filter(image =>
        !(this.forbiddenTags.test(image.tags) || (image.rating === 'e'))
      );
  }

  _shikiLoadUrl() {
    return `/imageboards/${Base64.encode(this._imagesSourceUrl())}` +
      `?tag=${this.tag}&page=${this.page}&imageboard=${this.name.toLowerCase()}`;
  }

  _imagesSourceUrl() {
    return `${this.baseUrl}/post/index.json?page=${this.page}&limit=${this.limit}&tags=${this.tag}`;
  }

  _camoUrl(imageUrl, filename) {
    return this.camoBaseUrl + `?filename=${filename}&url=${imageUrl}`;
  }

  _imageUrl(imageUrl, filename) {
    return this._camoUrl(this._ensureProtocol(imageUrl), filename);
  }

  _previewUrl(previewUrl, filename) {
    return this._imageUrl(previewUrl, filename);
  }

  _ensureProtocol(url) {
    if (url.match(/^\/\//)) {
      return `https:${url}`;
    }
    return url;
  }

  _filename(image) {
    const extension = `.${image.file_url.replace(/.*\./, '')}`;

    return [this.tag, `${image.width}x${image.height}`, image.author, image.id]
      .join('_')
      .replace(/^_/, '')
      .replace(/ /g, '__')
      .replace(/$/, extension);
  }
}
