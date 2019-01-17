import LoaderBase from './loader_base';

export default class KonachanLoader extends LoaderBase {
  _initialize() {
    this.name = 'Konachan';
    this.base_url = 'http://konachan.com';
  }
}
