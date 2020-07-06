import uEvent from 'uevent';

export class StaticLoader {
  FETCH_EVENT = 'loader:fetch';

  constructor(batchSize, cache) {
    uEvent.mixin(this);

    this.batchSize = batchSize;
    this.cache = cache;


    this._initialize();
  }

  // public methods
  _initialize() {
  }

  fetch() {
    this._emitFromCache();
  }

  isFinished() {
    return this.cache.length === 0;
  }

  // private methods
  _emitFromCache() {
    this.trigger(this.FETCH_EVENT, this.cache.splice(0, this.batchSize));
  }
}
