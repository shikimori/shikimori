import { LoaderBase } from './loader_base';

export class SafebooruLoader extends LoaderBase {
  _initialize() {
    this.name = 'Safebooru';
    this.baseUrl = 'https://safebooru.org';
  }

  // private methods
  _imagesSourceUrl() {
    return `${this.baseUrl}/index.php` +
      `?page=dapi&s=post&q=index&pid=${this.page - 1}&limit=${this.limit}&tags=${this.tags}`;
  }
}
