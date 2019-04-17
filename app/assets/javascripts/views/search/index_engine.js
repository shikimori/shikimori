import URI from 'urijs';
import { debounce } from 'throttle-debounce';

import ajaxCacher from 'services/ajax_cacher';
import flash from 'services/flash';

import JST from 'helpers/jst';

export default class IndexEngine {
  constructor() {
    this.isAutocomplete = false;
    this._debouncedSearch = debounce(250, v => this._search(v));
  }

  cancel() {
    this.phrase = '';
  }

  search(phrase) {
    this.phrase = phrase;
  }

  get $content() {
    return $('.b-search-results');
  }

  get phrase() {
    return this._phrase;
  }

  set phrase(value) {
    this._phrase = value;

    if (this.phrase !== undefined) {
      this._showAjax();
      this._debouncedSearch(this.phrase);
    }
  }

  async _search(phrase) {
    const { data, status } = await ajaxCacher.fetch(this._searchUrl(phrase));
    this._hideAjax();

    if (status !== 200) {
      flash.error(I18n.t('frontend.lib.paginated_catalog.please_try_again_later'));
      return;
    }

    if (phrase === this.phrase) {
      this._changeUrl(phrase);
      this._processResponse(data);
    }
  }

  _processResponse(response) {
    let html;

    if (response.content) {
      html = response.content + (response.postloader || '');
    } else {
      html = Object.isEmpty(this.phrase) ?
        '' :
        JST['search/nothing_found']({ isAutocomplete: this.isAutocomplete });
    }

    this.$content.html(html).process(response.JS_EXPORTS);
  }

  _searchUrl(phrase) {
    const uri = URI(window.location.href.replace(/\/page\/\d+/, ''))
      .removeQuery('search');

    if (phrase) {
      return uri.addQuery({ search: phrase });
    }
    return uri;
  }

  _changeUrl(phrase) {
    const url = this._searchUrl(phrase);
    window.history.replaceState({ turbolinks: true, url }, '', url);
  }

  _showAjax() {
    this.$content.addClass('b-ajax');
  }

  _url(url, phrase) {
    const uri = URI(url).removeQuery('search');

    if (phrase) {
      return uri.addQuery({ search: phrase });
    }
    return uri;
  }

  _hideAjax() {
    this.$content.removeClass('b-ajax');
  }
}
