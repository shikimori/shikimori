import { LoaderBase } from './loader_base';

export class KonachanLoader extends LoaderBase {
  _initialize() {
    this.name = 'Konachan';
    this.baseUrl = 'https://konachan.com';
  }
}
