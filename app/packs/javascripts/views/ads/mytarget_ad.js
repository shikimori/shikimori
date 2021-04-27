import { bind } from 'shiki-decorators';
import getjs from 'get-js';

import { AdView } from './ad_view';

let state = null;
const pendingAds = [];

const STATE = {
  LOADED: 'loaded',
  LOADING: 'loading'
};

export class MytargetAd extends AdView {
  initialize(html, cssClass) {
    this.html = html;
    this.cssClass = cssClass;

    if (state === STATE.LOADED) {
      this._render();
    } else if (state === STATE.LOADING) {
      this._schedule();
    } else if (state === null) {
      this._loadJs();
    }
  }

  _loadJs() {
    state = STATE.LOADING;

    getjs('//ad.mail.ru/static/ads-async.js').then(() => {
      state = STATE.LOADED;
      pendingAds.forEach(render => render());
      this._render();
    });
  }

  _schedule() {
    pendingAds.push(this._render);
  }

  @bind
  _render() {
    this._replaceNode();
    (window.MRGtag = window.MRGtag || []).push({});
  }
}
