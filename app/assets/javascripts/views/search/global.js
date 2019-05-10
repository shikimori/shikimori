import Turbolinks from 'turbolinks';
import URI from 'urijs';
import delay from 'delay';
import { bind } from 'decko';

import View from 'views/application/view';

import AutocompleteEngine from './autocomplete_engine';
import IndexEngine from './index_engine';

import globalHandler from 'helpers/global_handler';
import JST from 'helpers/jst';

const VARIANT_SELECTOR = '.b-db_entry-variant-list_item';
const ITEM_SELECTOR = `${VARIANT_SELECTOR}, .search-mode`;

export default class GlobalSearch extends View {
  isActive = false

  initialize() {
    this.$input = this.$('.field input');

    this.phrase = this.inputSearchPhrase;
    this.currentMode = this.hasIndex ? 'index' : this.$root.data('default-mode') || 'anime';

    globalHandler.on('slash', this._onGlobalSlash);

    this.$input
      .on('focus', () => this._activate())
      .on('change blur paste keyup', () => this.phrase = this.inputSearchPhrase)
      .on('blur', this._onBlur);

    this.$('.field .clear')
      .on('click', () => this._clearPhrase(true));

    this.$content
      .on('mousedown', '.search-mode', ({ currentTarget }) => {
        this._selectItem(currentTarget);
      })
      .on('mouseup', '.search-mode', () => {
        this.$input.focus();
      })
      .on('focus mousemove', VARIANT_SELECTOR, ({ currentTarget }) => {
        // prefer mousemove over mouseover cause it does not trigger after keyboard scroll
        if (this.currentItem !== currentTarget) {
          this._selectItem(currentTarget, false);
        }
      });
  }

  get hasIndex() {
    return !!$('.b-search-results').length;
  }

  get currentMode() {
    return this._currentMode;
  }

  get isIndexMode() {
    return this.currentMode === 'index';
  }

  set currentMode(value) {
    this._currentMode = value;

    if (this.isIndexMode) {
      this.searchEngine = new IndexEngine();
    } else {
      this.searchEngine = new AutocompleteEngine(
        this.$node.data(`autocomplete_${this.currentMode}_url`),
        this.$content
      );
    }
  }

  get $content() {
    return this.$root.find('.search-results');
  }

  get $activeItem() {
    return this.$content.find(ITEM_SELECTOR).filter('.active');
  }

  get isSearching() {
    return !Object.isEmpty(this.phrase);
  }

  get phrase() {
    return this._phrase;
  }

  set phrase(value) {
    const trimmedValue = value.trim();
    const priorPhrase = this._phrase;

    if (this._phrase === trimmedValue) { return; }

    this._phrase = trimmedValue;
    if (this.$input[0].value !== value) {
      this.$input[0].value = value;
    }

    this.$input.toggleClass('has-value', !Object.isEmpty(this.phrase));

    if (priorPhrase === undefined) { return; }

    if (this.phrase) { // it is undefined in constructor
      this.searchEngine.search(this.phrase);
    } else {
      this.searchEngine.cancel();
      this._renderModes();
    }

    this._toggleGlobalSearch();
  }

  get inputSearchPhrase() {
    return this.$input.val().trim();
  }

  cancel() {
    this._deactivate();
  }

  // private functions
  _activate() {
    if (this.isActive) { return; }

    this.isActive = true;
    this._toggleGlobalSearch();

    this._renderModes();

    globalHandler
      .on('enter', this._onEnter)
      .on('up', this._onMoveUp)
      .on('down', this._onMoveDown)
      .on('esc', this._onEsc)
      .on('focus', this._tryCloseOnFocus);
  }

  @bind
  _deactivate() {
    if (!this.isActive) { return; }

    this.isActive = false;
    this._toggleGlobalSearch();

    if (this.$input.is(':focus')) {
      this.$input.blur();
    }

    globalHandler
      .off('enter', this._onEnter)
      .off('esc', this._onEsc)
      .off('up', this._onMoveUp)
      .off('down', this._onMoveDown)
      .off('focus', this._tryCloseOnFocus);
  }

  _renderModes() {
    this.$content.html(
      JST['search/options']({
        currentMode: this.currentMode,
        hasIndex: this.hasIndex
      })
    );
  }

  _clearPhrase(isFocus) {
    this.phrase = '';

    if (isFocus) {
      this.$input.focus();
    }
  }

  _selectItem(node, doScroll) {
    this._deselectItems();

    if (this.isSearching) {
      this.currentItem = node;
    } else {
      this.currentMode = $(node).data('mode');
    }

    node.setAttribute('tabindex', 0);
    node.classList.add('active');

    // switch focus if another variant is already focused
    const focusedNode = this.$content.find(`${VARIANT_SELECTOR}:focus`)[0];
    if (focusedNode && focusedNode !== node) {
      $(node).focus();
    }

    if (doScroll) {
      this._scrollToItem($(node));
    }
  }

  _deselectItems() {
    const node = this.$activeItem[0];

    if (node) {
      node.setAttribute('tabindex', -1);
      node.classList.remove('active');
    }
  }

  _scrollToItem($node) {
    const nodeTop = $node.offset().top;
    const nodeHeight = $node.outerHeight();

    const windowTop = window.scrollY || document.documentElement.scrollTop;
    const windowHeight = $(window).height();

    if (nodeTop < windowTop) {
      if ($node.is(':first-child')) {
        window.scrollTo(0, 0);
      } else {
        window.scrollTo(0, nodeTop - 10);
      }
    } else if (nodeTop + nodeHeight > windowTop + windowHeight) {
      window.scrollTo(0, windowTop + (nodeTop + nodeHeight) - (windowTop + windowHeight) + 10);
    }
  }

  @bind
  async _onBlur() {
    if (!this.isIndexMode) { return; }

    await delay();
    if (!this.$input.is(':focus') && !this.$activeItem.is(':focus')) {
      this._deactivate();
    }
  }

  _toggleGlobalSearch() {
    const isShade = this.isActive && (
      !this.isIndexMode ||
        (this.isIndexMode && Object.isEmpty(this.phrase))
    );

    $('.l-top_menu-v2')
      .toggleClass('is-search-focus', this.isActive)
      .toggleClass('is-search-shade', isShade);

    $('.b-shade').off('click', this._deactivate);
    if (isShade) {
      $('.b-shade').on('click', this._deactivate);
    }
  }

  @bind
  _onGlobalSlash(e) {
    const target = e.target || e.srcElement;
    const isIgnored = target.isContentEditable ||
      target.tagName === 'INPUT' ||
      target.tagName === 'SELECT' ||
      target.tagName === 'TEXTAREA';

    if (isIgnored) { return; }

    e.preventDefault();
    e.stopImmediatePropagation();

    this.$input.focus();
    this.$input[0].setSelectionRange(0, this.$input[0].value.length);
  }

  @bind
  _onEnter(e) {
    e.preventDefault();
    e.stopImmediatePropagation();

    if (this.isIndexMode) { return; }
    if (!this.phrase.trim()) { return; }

    let url;

    if (this.$activeItem.length) {
      url = this.$activeItem.find('.name .b-link').attr('href');
    } else {
      url =
        URI(this.$node.data(`search_${this.currentMode}_url`))
          .removeQuery('search')
          .addQuery({ search: this.phrase });
    }

    Turbolinks.visit(url);
  }

  @bind
  _onEsc(e) {
    e.preventDefault();
    e.stopImmediatePropagation();

    this.cancel();
  }

  @bind
  _onMoveUp(e) {
    const { $activeItem } = this;
    const item = $activeItem.prev()[0];

    if (this.isActive) {
      e.preventDefault();
      e.stopImmediatePropagation();
    }

    if (item) {
      this._selectItem(item, true);
    } else if (this.isSearching) {
      this._deselectItems();
      this.$input.focus();
    }
  }

  @bind
  _onMoveDown(e) {
    const { $activeItem } = this;
    const item = $activeItem.length ?
      $activeItem.next()[0] :
      this.$content.find(ITEM_SELECTOR).first()[0];

    if (this.isActive) {
      e.preventDefault();
      e.stopImmediatePropagation();
    }

    if (item) {
      this._selectItem(item, true);
    }
  }

  @bind
  _tryCloseOnFocus({ target }) {
    const $target = $(target);
    const isInside = target === this.root || $target.closest(this.$root).length;

    if (isInside || !$target.parents('html').length) { return; }

    this._deactivate();
  }
}
