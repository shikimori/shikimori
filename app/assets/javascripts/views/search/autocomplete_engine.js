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
        JST['search/nothing_found']();
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

  // initialize() {
  //   super.initialize();

  //   this.currentItem = null;
  //   this._bindGlobalHotkey();

  //   this.$content.on('mousemove', ITEM_SELECTOR, ({ currentTarget }) => {
  //     // better than mouseover cause it does not trigger after keyboard scroll
  //     if (this.currentItem !== currentTarget) {
  //       this._selectItem(currentTarget, false);
  //     }
  //   });
  // }

  // get $content() {
  //   return this.$root.find('.search-results');
  // }

  // get $activeItem() {
  //   return this.$content.find(`${ITEM_SELECTOR}.active`);
  // }

  // // handlers
  // _onGlobalEsc(e) {
  //   if (!this.isActive) { return; }

  //   e.preventDefault();
  //   e.stopImmediatePropagation();

  //   this._cancel();
  // }

  // _onGlobalDown(e) {
  //   const { $activeItem } = this;
  //   const item = $activeItem.length ?
  //     $activeItem.next()[0] :
  //     this.$content.find(ITEM_SELECTOR).first()[0];

  //   if (this.isActive) {
  //     e.preventDefault();
  //     e.stopImmediatePropagation();
  //   }

  //   if (item) {
  //     this._selectItem(item, true);
  //   }
  // }

  // _onGlobalUp(e) {
  //   const { $activeItem } = this;
  //   const item = $activeItem.prev()[0];

  //   if (this.isActive) {
  //     e.preventDefault();
  //     e.stopImmediatePropagation();
  //   }

  //   if (item) {
  //     this._selectItem(item, true);
  //   } else {
  //     this._deselectItems();
  //   }
  // }

  // // private functions
  // _searchUrl(phrase) {
  //   return this._url(phrase, 'autocomplete');
  // }

  // _cancel() {
  //   if (Object.isEmpty(this.phrase)) {
  //     this.$input.blur();
  //   } else {
  //     this._clearPhrase();
  //   }
  //   this._deactivate();
  // }

  // _activate() {
  //   if (Object.isEmpty(this.phrase)) {
  //     this._deactivate();
  //     return;
  //   }

  //   this.$content.show();
  //   $('.l-top_menu-v2').addClass('is-global_search');

  //   super._activate();
  // }

  // _deactivate() {
  //   this.$content
  //     .empty()
  //     .hide();
  //   $('.l-top_menu-v2').removeClass('is-global_search');

  //   this.isActive = false;
  // }

  // _showAjax() {
  //   this.$content.find('.b-nothing_here').remove();
  //   super._showAjax();
  // }

  // _selectItem(node, doScroll) {
  //   this.currentItem = node;
  //   this._deselectItems();

  //   const $node = $(node);
  //   $node.addClass('active');

  //   if (doScroll) {
  //     this._scrollToItem($node);
  //   }
  // }

  // _deselectItems() {
  //   this.$content.find(ITEM_SELECTOR).removeClass('active');
  // }

  // _scrollToItem($node) {
  //   // let didScroll = false;

  //   const nodeTop = $node.offset().top;
  //   const nodeHeight = $node.outerHeight();

  //   const windowTop = window.scrollY || document.documentElement.scrollTop;
  //   const windowHeight = $(window).height();

  //   if (nodeTop < windowTop) {
  //     // didScroll = true;
  //     if ($node.is(':first-child')) {
  //       window.scrollTo(0, 0);
  //     } else {
  //       window.scrollTo(0, nodeTop - 10);
  //     }
  //   } else if (nodeTop + nodeHeight > windowTop + windowHeight) {
  //     // didScroll = true;
  //     window.scrollTo(0, windowTop + (nodeTop + nodeHeight) - (windowTop + windowHeight) + 10);
  //   }

  //   // NOTE: no need in it after switching from mouseover to mousemove
  //   // to prevent item selection by mouseover event
  //   // it could happen if mouse cursor currently is over some item
  //   // if (didScroll) {
  //   //   document.body.style.pointerEvents = 'none';

  //   //   if (!this.debouncedEnableMouseEvents) {
  //   //     this.debouncedEnableMouseEvents = debounce(250, () => (
  //   //       document.body.style.pointerEvents = ''
  //   //     ));
  //   //   }
  //   //   this.debouncedEnableMouseEvents();
  //   // }
  // }

  // _changeUrl(_url) {}
}
