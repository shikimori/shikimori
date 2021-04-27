/* global Ya */

import { bind } from 'shiki-decorators';
import { AdView } from './ad_view';

let state = null;
let pendingAds = [];

const STATE = {
  LOADED: 'loaded',
  LOADING: 'loading'
};

export class YandexAd extends AdView {
  initialize(html, cssClass, adParams) {
    this.html = html;
    this.cssClass = cssClass;
    this.adParams = adParams;

    if (state === STATE.LOADED) {
      this._render();
    } else if (state === STATE.LOADING) {
      this._schedule();
    } else {
      this._loadJs();
    }
  }

  _loadJs() {
    state = STATE.LOADING;
    this._schedule();

    ((w, d, n) => {
      w[n] = w[n] || [];
      w[n].push(() => {
        state = STATE.LOADED;
        pendingAds.forEach(render => render());
        return pendingAds = [];
      });

      const t = d.getElementsByTagName('script')[0];
      const s = d.createElement('script');
      s.type = 'text/javascript';
      s.src = '//an.yandex.ru/system/context.js';
      s.async = true;
      s.onerror = () => { // eslint-disable-line consistent-return
        if ('remove_ad' in window) {
          return window.remove_ad(this.cssClass);
        }
      };
      return t.parentNode.insertBefore(s, t);
    }
    )(window, window.document, 'yandexContextAsyncCallbacks');
  }

  _schedule() {
    return pendingAds.push(this._render);
  }

  @bind
  _render() {
    this._replaceNode();
    return Ya.Context.AdvManager.render(this.adParams);
  }
}
