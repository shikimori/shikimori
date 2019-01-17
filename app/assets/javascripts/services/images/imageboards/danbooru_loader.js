import LoaderBase from './loader_base';

export default class DanbooruLoader extends LoaderBase {
  _initialize() {
    this.name = 'Danbooru';
    this.base_url = 'http://danbooru.donmai.us';
  }

  // private methods
  _build_images(xhr_images) {
    xhr_images.forEach(image => {
      if (!image.file_url || !image.preview_url) { return; }

      image.file_url =
        image.file_url.startsWith('http') ?
          image.file_url
        :
          this.base_url + image.file_url;

      image.preview_url =
        image.preview_url.startsWith('http') ?
          image.preview_url
        :
          this.base_url + image.preview_url;
    });

    return super._build_images(xhr_images);
  }
}
