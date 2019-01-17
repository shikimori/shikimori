import LoaderBase from './loader_base';

export default class SafebooruLoader extends LoaderBase {
  _initialize() {
    this.name = 'Safebooru';
    this.base_url = 'http://safebooru.org';
  }

  // private methods
  _images_source_url() {
    return `${this.base_url}/index.php` +
      `?page=dapi&s=post&q=index&pid=${this.page - 1}&limit=${this.limit}&tags=${this.tags}`;
  }
}
