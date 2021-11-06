import TinyUri from 'tiny-uri';
import { debounce } from 'throttle-debounce';
import pDefer from 'p-defer';
import { flash } from 'shiki-utils';

import ajaxCacher from '@/services/ajax_cacher';

import JST from '@/utils/jst';

export default class IndexEngine {
  constructor() {
    this.searchDeferred = undefined;
    this.isAutocomplete = false;
    this.debouncedSearch = debounce(250, v => this._search(v));
  }

  cancel() {
    this.phrase = '';
  }

  search(phrase) {
    this.phrase = phrase;
    return this.searchDeferred.promise;
  }

  get $content() {
    return $('.b-search-results');
  }

  get phrase() {
    return this._phrase;
  }

  set phrase(value) {
    this._phrase = value;
    this._buildSearchPromise();

    if (this.phrase !== undefined) {
      this._showAjax();

      if (Object.isEmpty(this.phrase)) {
        this._search(this.phrase);
      } else {
        this.debouncedSearch(this.phrase);
      }
    } else {
      this._resolveSearchPromise();
    }
  }

  async _search(phrase) {
    const { data, status } = await ajaxCacher.fetch(this._searchUrl(phrase));

    if (status !== 200 && status !== 451) { // 451: age_restricted
      flash.error(I18n.t('frontend.lib.please_try_again_later'));
      this._hideAjax();
      this._resolveSearchPromise();
      return;
    }

    if (phrase === this.phrase) {
      this._changeUrl(phrase);
      this._processResponse(data);
    }
    this._hideAjax();
    this._resolveSearchPromise();
  }

  _processResponse(response) {
    this.$content
      .html(this._responseToHtml(response))
      .process(response.JS_EXPORTS);
  }

  _responseToHtml(response) {
    if (response.content) {
      return response.content + (response.postloader || '');
    }

    return (
      Object.isEmpty(this.phrase) ?
        '' :
        JST['search/nothing_found']({ isAutocomplete: this.isAutocomplete })
    );
  }

  _searchUrl(phrase) {
    return new TinyUri(window.location.href.replace(/\/page\/\d+/, ''))
      .query.set('search', phrase || null)
      .toString();
  }

  _changeUrl(phrase) {
    const url = this._searchUrl(phrase);
    window.history.replaceState({ turbolinks: true, url }, '', url);
  }

  _url(url, phrase) {
    return new TinyUri(url)
      .query.set('search', phrase || null)
      .toString();
  }

  _showAjax() {
    this.$content.addClass('b-ajax');
  }

  _hideAjax() {
    this.$content.removeClass('b-ajax');
  }

  _buildSearchPromise() {
    this.searchDeferred = pDefer();
  }

  _resolveSearchPromise() {
    if (this.searchDeferred) {
      this.searchDeferred.resolve();
      this.searchDeferred = undefined;
    }
  }
}
