import URI from 'urijs';
import { debounce } from 'throttle-debounce';

import ajaxCacher from 'services/ajax_cacher';
import flash from 'services/flash';

import JST from 'helpers/jst';

export default class AutocompleteEngine {
  constructor(fetchUrl, $content) {
    this.fetchUrl = fetchUrl;
    this.$content = $content;
    this.phrase = undefined;

    this._debouncedSearch = debounce(250, phrase => this._search(phrase));
  }

  cancel() {
    this.phrase = undefined;
  }

  search(phrase) {
    if (this._debouncedSearch === undefined) {
      this._debouncedSearch = debounce(250, v => this._search(v));
    }

    this.phrase = phrase;
  }

  get phrase() {
    return this._phrase;
  }

  set phrase(value) {
    this._phrase = value;

    if (!Object.isEmpty(this._phrase)) {
      this._showAjax();
      this._debouncedSearch(this._phrase);
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
      // this._changeUrl(this._displayUrl(phrase));
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
        JST['search/nothing_found']({ isAutocomplete: true });
    }

    this.$content.html(html).process(response.JS_EXPORTS);
  }

  _searchUrl(phrase) {
    return this._url(this.fetchUrl, phrase);
  }

  _url(url, phrase) {
    const uri = URI(url).removeQuery('search');

    if (phrase) {
      return uri.addQuery({ search: phrase });
    }
    return uri;
  }

  _showAjax() {
    this.$content.addClass('b-ajax');
  }

  _hideAjax() {
    this.$content.removeClass('b-ajax');
  }
}
