// import { debounce } from 'throttle-debounce';

import LocalSearch from './local';

const ITEM_SELECTOR = '.b-db_entry-variant-list_item';

export default class GlobalSearch extends LocalSearch {
  initialize() {
    super.initialize();

    this.currentItem = null;
    this._bindGlobalHotkey();

    this.$collection.on('mousemove', ITEM_SELECTOR, ({ currentTarget }) => {
      // better than mouseover cause it does not trigger after keyboard scroll
      if (this.currentItem !== currentTarget) {
        this._selectItem(currentTarget, false);
      }
    });
  }

  get $collection() {
    return this.$root.find('.search-results');
  }

  get $activeItem() {
    return this.$collection.find(`${ITEM_SELECTOR}.active`);
  }

  // handlers
  _onGlobalEsc(e) {
    if (!this.isActive) { return; }

    e.preventDefault();
    e.stopImmediatePropagation();

    this._cancel();
  }

  _onGlobalDown(e) {
    const { $activeItem } = this;
    const item = $activeItem.length ?
      $activeItem.next()[0] :
      this.$collection.find(ITEM_SELECTOR).first()[0];

    if (this.isActive) {
      e.preventDefault();
      e.stopImmediatePropagation();
    }

    if (item) {
      this._selectItem(item, true);
    }
  }

  _onGlobalUp(e) {
    const { $activeItem } = this;
    const item = $activeItem.prev()[0];

    if (this.isActive) {
      e.preventDefault();
      e.stopImmediatePropagation();
    }

    if (item) {
      this._selectItem(item, true);
    } else {
      this._deselectItems();
    }
  }

  // private functions
  _searchUrl(phrase) {
    return this._url(phrase, 'autocomplete');
  }

  _cancel() {
    if (Object.isEmpty(this.phrase)) {
      this.$input.blur();
    } else {
      this._clearPhrase();
    }
    this._deactivate();
  }

  _activate() {
    if (Object.isEmpty(this.phrase)) {
      this._deactivate();
      return;
    }

    this.$collection.show();
    $('.l-top_menu-v2').addClass('is-global_search');

    super._activate();
  }

  _deactivate() {
    this.$collection
      .empty()
      .hide();
    $('.l-top_menu-v2').removeClass('is-global_search');

    this.isActive = false;
  }

  _showAjax() {
    this.$collection.find('.b-nothing_here').remove();
    super._showAjax();
  }

  _selectItem(node, doScroll) {
    this.currentItem = node;
    this._deselectItems();

    const $node = $(node);
    $node.addClass('active');

    if (doScroll) {
      this._scrollToItem($node);
    }
  }

  _deselectItems() {
    this.$collection.find(ITEM_SELECTOR).removeClass('active');
  }

  _scrollToItem($node) {
    // let didScroll = false;

    const nodeTop = $node.offset().top;
    const nodeHeight = $node.outerHeight();

    const windowTop = window.scrollY || document.documentElement.scrollTop;
    const windowHeight = $(window).height();

    if (nodeTop < windowTop) {
      // didScroll = true;
      if ($node.is(':first-child')) {
        window.scrollTo(0, 0);
      } else {
        window.scrollTo(0, nodeTop - 10);
      }
    } else if (nodeTop + nodeHeight > windowTop + windowHeight) {
      // didScroll = true;
      window.scrollTo(0, windowTop + (nodeTop + nodeHeight) - (windowTop + windowHeight) + 10);
    }

    // NOTE: no need in it after switching from mouseover to mousemove
    // to prevent item selection by mouseover event
    // it could happen if mouse cursor currently is over some item
    // if (didScroll) {
    //   document.body.style.pointerEvents = 'none';

    //   if (!this.debouncedEnableMouseEvents) {
    //     this.debouncedEnableMouseEvents = debounce(250, () => (
    //       document.body.style.pointerEvents = ''
    //     ));
    //   }
    //   this.debouncedEnableMouseEvents();
    // }
  }

  _changeUrl(_url) {}
}
