import { LoaderBase } from './loader_base';

export class YandereLoader extends LoaderBase {
  _initialize() {
    this.name = 'Yandere';
    this.baseUrl = 'https://yande.re';
  }
}
