import TinyUri from 'tiny-uri';

import { debounce } from 'throttle-debounce';
import { flash } from 'shiki-utils';

import ajaxCacher from '@/services/ajax_cacher';
import View from '@/views/application/view';

import JST from '@/helpers/jst';

export default class CollectionSearch extends View {
  initialize() {
    this.$input = this.$('.field input');
    this.$clear = this.$('.field .clear');

    this.isActive = false;
    this.debouncedSearch = debounce(250, phrase => this._search(phrase));

    this._phrase = this.inputSearchPhrase;

    this.$input.on('change blur paste', () => this._onChange());
    this.$input.on('keyup', e => this._onKeyup(e));
    this.$clear.on('click', () => this._clearPhrase(true));
  }

  get $collection() {
    return this.$('.search-results');
  }

  get inputSearchPhrase() {
    return this.$input.val();
  }

  get phrase() {
    return this._phrase;
  }

  set phrase(value) {
    const trimmedValue = value.trim();
    if (this._phrase.trim() === trimmedValue) { return; }

    const priorPhrase = this._phrase;
    this._phrase = value;

    if (priorPhrase !== undefined) { // it is undefined in constructor
      this._activate();
      this.debouncedSearch(trimmedValue);
    }

    this.$input.toggleClass('has-value', !Object.isEmpty(this._phrase));
  }

  // handlers
  _onKeyup({ keyCode }) {
    if (keyCode === 27) {
      this._cancel();
      return;
    }

    this.phrase = this.inputSearchPhrase;
  }

  _onChange() {
    this.phrase = this.inputSearchPhrase;
  }

  // private functions
  _clearPhrase(isFocus) {
    this.$input
      .val('')
      .trigger('change');

    if (isFocus) {
      this.$input.focus();
    }
  }

  _cancel() {
    if (Object.isEmpty(this.phrase)) {
      this._deactivate();
    } else {
      this._clearPhrase();
    }
  }

  _activate() {
    this._showAjax();
    this.isActive = true;
  }

  _deactivate() {
    this.$input.blur();
    this.isActive = false;
  }

  async _search(phrase) {
    const { data, status } = await ajaxCacher.fetch(this._searchUrl(phrase));
    this._hideAjax();

    if (status !== 200) {
      flash.error(I18n.t('frontend.lib.please_try_again_later'));
      return;
    }

    if (phrase === this.inputSearchPhrase.trim()) {
      this._changeUrl(this._displayUrl(phrase));
      this._processResponse(data);
    }
  }

  _changeUrl(url) {
    window.history.replaceState({ turbolinks: true, url }, '', url);
  }

  _processResponse(response) {
    let html;

    if (response.content) {
      html = response.content + (response.postloader || '');
    } else {
      html = Object.isEmpty(this.phrase) ?
        '' :
        JST['search/nothing_found']({ isAutocomplete: false });
    }

    this.$collection.html(html).process(response.JS_EXPORTS);
  }

  _searchUrl(phrase) {
    return this._url(phrase, 'search');
  }

  _displayUrl(phrase) {
    return this._url(phrase, 'display') ||
      this._url(phrase, 'search');
  }

  _url(phrase, key) {
    const url = this.$root.data(`${key}_url`);
    if (!url) { return null; }

    return new TinyUri(url)
      .query.set('phrase', phrase || null)
      .toString();
  }

  _showAjax() {
    this.$collection.addClass('b-ajax');
  }

  _hideAjax() {
    this.$collection.removeClass('b-ajax');
  }
}
