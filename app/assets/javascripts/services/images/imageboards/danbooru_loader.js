import { LoaderBase } from './loader_base';

export class DanbooruLoader extends LoaderBase {
  _initialize() {
    this.name = 'Danbooru';
    this.baseUrl = 'https://danbooru.donmai.us';
  }

  // private methods
  _buildImages(data) {
    data.forEach(image => {
      if (!image.file_url || !image.preview_url) { return; }

      if (!image.file_url.startsWith('http')) {
        image.file_url = this.baseUrl + image.file_url;
      }

      if (!image.preview_url.startsWith('http')) {
        image.preview_url = this.baseUrl + image.preview_url;
      }
    });

    return super._buildImages(data);
  }
}
