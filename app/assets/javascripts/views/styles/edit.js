import { debounce } from 'throttle-debounce';

import axios from 'helpers/axios';

import View from 'views/application/view';
import PageBackgroundColor from './page_background_color';
import PageBorder from './page_border';
import BodyBackground from './body_background';

export default class EditStyles extends View {
  cssCache = {}

  initialize() {
    this.$form = this.$('.edit_style');
    this.$preview = this.$('.preview');

    this._loading();
    this._toggleExpand();

    this._debouncedPreview = debounce(500, () => this.preview());
    this._debouncedSync = debounce(500, () => this.sync());

    this.$form.on('ajax:before', () => this._loading());
    this.$form.on('ajax:complete', () => this._loaded());

    this.$root.on('component:update', (e, regexp, replacement) =>
      this._componentUpdated(regexp, replacement)
    );

    this.$('.style_css .editor-expand').on('click', () => this._toggleExpand(true));
    this.$('.style_css .editor-collapse').on('click', () => this._toggleExpand(false));

    require.ensure([], require => {
      const CodeMirror = require('codemirror');

      require('codemirror/addon/hint/show-hint.js');
      require('codemirror/addon/hint/css-hint.js');

      require('codemirror/addon/display/fullscreen.js');
      require('codemirror/addon/dialog/dialog.js');
      require('codemirror/addon/search/searchcursor.js');
      require('codemirror/addon/search/search.js');
      require('codemirror/addon/scroll/annotatescrollbar.js');
      require('codemirror/addon/search/matchesonscrollbar.js');
      require('codemirror/addon/search/jump-to-line.js');

      this.md5 = require('blueimp-md5');

      this.editor = this._initEditor(CodeMirror);
      // @editor.on 'cut', @_debouncedSync
      // @editor.on 'paste', @_debouncedSync
      this.editor.on('change', this._debouncedSync);

      this.components = [
        new PageBackgroundColor(this.$('.page_background_color')),
        new PageBorder(this.$('.page_border')),
        new BodyBackground(this.$('.body_background'))
      ];

      this._syncComponents();
    });
  }

  preview() {
    const css = this.editor.getValue().trim();
    const hash = this.md5(css);

    if (this.cssCache[hash]) {
      this._replaceCustomCss(this.cssCache[hash]);
    } else {
      this.$preview.show();
      this._fetchPreview(css, hash);
    }
  }

  sync() {
    this.$('#style_css').val(this.editor.getValue());
    this.preview();
    this._syncComponents();
  }

  _loading() {
    this.$form.find('.editor-container').addClass('b-ajax');
  }

  _loaded() {
    this.$form.find('.editor-container').removeClass('b-ajax');
  }

  _initEditor(CodeMirror) {
    this._loaded();

    return CodeMirror.fromTextArea(this.$('#style_css')[0], {
      mode: 'css',
      theme: 'solarized light',
      lineNumbers: true,
      styleActiveLine: true,
      matchBrackets: true,
      lineWrapping: true,
      extraKeys: {
        F11: this._switchFullScreen,
        'Ctrl-F11': this._switchFullScreen,
        'Cmd-F11': this._switchFullScreen,
        Esc(editor) {
          if (editor.getOption('fullScreen')) {
            editor.setOption('fullScreen', false);
          }
        }
      }
    });
  }

  _syncComponents() {
    const css = this.editor.getValue();

    this.components.forEach(component => {
      component.update(css);
      return true;
    });
  }

  _componentUpdated(regexp, replacement) {
    const css = this.editor.getValue();
    const fixedReplacement = replacement ? replacement + '\n' : '';

    if (css.match(regexp)) {
      this.editor.setValue(css.replace(regexp, fixedReplacement).trim(), 1);
    } else if (replacement) {
      this.editor.setValue((fixedReplacement + css).trim(), 1);
    }

    this._debouncedPreview();
  }

  async _fetchPreview(css, hash) {
    const { data } = await axios
      .post(this.$preview.data('url'), { style: { css } })
      .catch(() => ({ data: null }));

    this.$preview.hide();

    if (data) {
      this.cssCache[hash] = data.compiled_css;
      this._replaceCustomCss(data.compiled_css);
    }
  }

  _replaceCustomCss(compiledCss) {
    const customCssId = this.$root.data('custom_css_id');
    $(`#${customCssId}`).html(compiledCss);
  }

  _switchFullScreen(editor) {
    const isFullScreen = editor.getOption('fullScreen');

    editor.setOption('fullScreen', !isFullScreen);
    $('.l-top_menu-v2').toggleClass('is-fullscreen-mode', !isFullScreen);
  }

  _toggleExpand(newValue) {
    let isExpanded = $.cookie('expanded-styles') === '1';

    if (newValue !== undefined) {
      isExpanded = newValue;
      $.cookie('expanded-styles', isExpanded ? '1' : '0', { expires: 730, path: '/' });
    }

    this.$root.toggleClass('expanded', isExpanded);
    this.$('.style_css .editor-expand').toggleClass('active', !isExpanded);
    this.$('.style_css .editor-collapse').toggleClass('active', isExpanded);
  }
}
