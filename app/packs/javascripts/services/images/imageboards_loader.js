import { StaticLoader } from './static_loader';
import { SafebooruLoader } from './imageboards/safebooru_loader';
import { DanbooruLoader } from './imageboards/danbooru_loader';
import { YandereLoader } from './imageboards/yandere_loader';
import { KonachanLoader } from './imageboards/konachan_loader';

const FORBIDDEN_TAGS = [
  'comic', 'cum', 'fellatio', 'pussy', 'penis', 'sex', 'pussy_juice', 'nude',
  'nipples', 'spread_legs', 'flat_color', 'micro_bikini', 'monochrome',
  'bottomless', 'censored', 'meme', 'dakimakura', 'undressing',
  'lowres', 'plump', 'cameltoe', 'bandaid_on_pussy', 'bandaids_on_nipples',
  'oral', 'footjob', 'erect_nipples\\b.*\\bpanties', 'breasts\\b.*\\btopless',
  'crotch_zipper', 'bdsm', 'side-tie_panties', 'anal', 'masturbation',
  'panty_pull', 'loli', 'print_panties'
];

const LOADERS = [
  SafebooruLoader,
  DanbooruLoader,
  YandereLoader,
  KonachanLoader
];

export class ImageboardsLoader extends StaticLoader {
  _initialize() {
    this.tag = this.cache;
    this.cache = {};

    this.forbiddenTags =
      new RegExp(FORBIDDEN_TAGS.map(v => `\\b${v}\\b`).join('|'));

    this.cache = [];
    this.hashes = {};
    this.awaitingLoad = false;

    this.loaders = LOADERS.map(LoaderKlass => (
      new LoaderKlass(this.tag + ' rating:safe', this.forbiddenTags)
    ));
    this.loaders.forEach(loader => {
      loader.on(loader.FETCH_EVENT, (_e, images) => this._loaderFetch(images));
    });
  }

  // public methods
  fetch() {
    if (this.cache.length) {
      this._emitFromCache();
    } else {
      this.awaitingLoad = true;
      this._vacantLoaders().forEach(loader => loader.fetch());
    }
  }

  isFinished() {
    return (this.cache.length === 0) &&
      this.loaders.every(loader => loader.isFinished);
  }

  // callbacks
  // loader returned images
  _loaderFetch(images) {
    images
      .filter(image => (!(image.md5 in this.hashes)))
      .forEach(image => {
        this.hashes[image.md5] = true;
        this.cache.push(image);
      });

    if (this.awaitingLoad) {
      this.awaitingLoad = false;
      this._emitFromCache();
    }
  }

  // private methods
  _vacantLoaders() {
    return this.loaders.filter(loader => !loader.is_loading && !loader.isFinished);
  }
}
