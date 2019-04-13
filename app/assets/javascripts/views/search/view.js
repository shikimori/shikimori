import View from 'views/application/view';

// import GlobalSearch from './global';
// import CollectionSearch from './collection';

export default class SearchView extends View {
  initialize() {
    this.$input = this.$('.field input');

    this.phrase = this.inputSearchPhrase;

    // new GlobalSearch(this.$node);
    this._bindGlobalHotkey();

    this.$input
      .on('focus', () => this._activate())
      .on('change blur paste keyup', () => this.phrase = this.inputSearchPhrase);

    this.$('.field .clear')
      .on('click', () => this._clearPhrase(true));
  }

  get inputSearchPhrase() {
    return this.$input.val().trim();
  }

  get phrase() {
    return this._phrase;
  }

  set phrase(value) {
    const trimmedValue = value.trim();
    // const priorPhrase = this._phrase;

    if (this._phrase === trimmedValue) { return; }

    this._phrase = trimmedValue;
    if (this.$input[0].value !== value) {
      this.$input[0].value = value;
    }

    // if (priorPhrase !== undefined) { // it is undefined in constructor
    //   this._activate();
    //   this.debouncedSearch(this._phrase);
    // }

    this.$input.toggleClass('has-value', !Object.isEmpty(this._phrase));
  }

  // private functions
  _activate() {
    $('.l-top_menu-v2').addClass('is-global_search');
  }

  _deactivate() {
    $('.l-top_menu-v2').removeClass('is-global_search');
    this.$input.blur();
  }

  _cancel() {
    if (Object.isEmpty(this.phrase)) {
      this._deactivate();
    } else {
      this._clearPhrase();
    }
  }

  _clearPhrase(isFocus) {
    this.phrase = '';

    if (isFocus) {
      this.$input.focus();
    }
  }

  // global hotkeys
  _bindGlobalHotkey() {
    this.globalKeyupHandler = this._onGlobalKeyup.bind(this);
    this.globalKeydownHandler = this._onGlobalKeydown.bind(this);

    $(document).on('keyup', this.globalKeyupHandler);
    $(document).on('keydown', this.globalKeydownHandler);

    $(document).one('turbolinks:before-cache', () => {
      $(document).off('keyup', this.globalKeyupHandler);
      $(document).off('keydown', this.globalKeydownHandler);
    });
  }

  _onGlobalKeyup(e) {
    if (e.keyCode === 27) {
      this._onGlobalEsc(e);
    } else if (e.keyCode === 47 || e.keyCode === 191) {
      this._onGlobalSlash(e);
    }
  }

  _onGlobalKeydown(e) {
    if (e.keyCode === 40) {
      this._onGlobalDown(e);
    } else if (e.keyCode === 38) {
      this._onGlobalUp(e);
    }
  }

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

  _onGlobalEsc(e) {
    e.preventDefault();
    e.stopImmediatePropagation();

    this._cancel();
  }
}
