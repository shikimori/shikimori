import URI from 'urijs';
import { debounce } from 'throttle-debounce';

import ajaxCacher from 'services/ajax_cacher';
import flash from 'services/flash';
import View from 'views/application/view';

import JST from 'helpers/jst';

export default class CollectionSearch extends View {
  initialize() {
    this.$input = this.$('.field input');
    this.$clear = this.$('.field .clear');

    this.debouncedSearch = debounce(250, () => this._search());
    this.currentPhrase = this._searchPhrase();

    this.$clear.toggleClass('active', !Object.isEmpty(this.currentPhrase));
    // @$input.focus() if @$input.is(':appeared')

    this.$input.on('change blur keyup paste', e => this._onChange(e));
    this.$clear.on('click', () => this._clearPhrase());
  }

  get $collection() {
    return $('.b-search-results');
  }

  // handlers
  _onChange({ keyCode }) {
    const phrase = this._searchPhrase();

    if (keyCode === 27) {
      if (Object.isEmpty(phrase)) {
        this.$input.blur();
      } else {
        this._clearPhrase();
      }
      return;
    }

    if (phrase === this.currentPhrase) { return; }

    this.currentPhrase = phrase;
    this.debouncedSearch();
    this._showAjax();

    this.$clear.toggleClass('active', !Object.isEmpty(phrase));
  }

  _clearPhrase() {
    this.$input
      .val('')
      .trigger('change')
      .focus();
  }

  // private functions
  async _search() {
    const phrase = this._searchPhrase();

    const { data, status } = await ajaxCacher.fetch(this._searchUrl(phrase));
    this._hideAjax();

    if (status !== 200) {
      flash.error(I18n.t('frontend.lib.paginated_catalog.please_try_again_later'));
      return;
    }

    if (phrase === this._searchPhrase()) {
      this._showResults(data, this._displayUrl(phrase));
    }
  }

  _showResults(response, url) {
    window.history.replaceState({ turbolinks: true, url }, '', url);

    this._processResponse(response);
    this._hideAjax();
  }

  _processResponse(response) {
    let html;

    if (response.content) {
      html = response.content + (response.postloader || '');
    } else {
      html = JST['search/nothing_found']();
    }

    this.$collection.html(html).process(response.JS_EXPORTS);
  }

  _searchPhrase() {
    return this.$input.val().trim();
  }

  _searchUrl(phrase) {
    return this._url(phrase, 'search');
  }

  _displayUrl(phrase) {
    return this._url(phrase, 'display') || this._url(phrase, 'search');
  }

  _url(phrase, key) {
    const url = this.$root.data(`${key}_url`);
    if (!url) { return null; }

    const uri = URI(url).removeQuery('search');

    if (phrase) {
      return uri.addQuery({ search: phrase });
    }
    return uri;
  }

  _showAjax() {
    this.$collection.addClass('b-ajax');
  }

  _hideAjax() {
    this.$collection.removeClass('b-ajax');
  }
}
