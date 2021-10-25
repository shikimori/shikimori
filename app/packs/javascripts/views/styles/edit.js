import { debounce } from 'throttle-debounce';
import cookies from 'js-cookie';

import axios from '@/utils/axios';

import View from '@/views/application/view';
import { PredefinedCheckbox } from './predefined_checkbox';
import { PageBackgroundColor } from './page_background_color';
import { BodyBackground } from './body_background';

const PAGE_BORDER_REGEXP = /\/\* AUTO=page_border \*\/ .*[\r\n]?/;
const STICKY_MENU_REGEXP = /\/\* AUTO=sticky_menu \*\/ .*[\r\n]?/;

export class EditStyles extends View {
  async initialize() {
    this.cssCache = {};

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

    await this._importComponents();

    this.editor = this._initEditor(this.CodeMirror);
    // @editor.on 'cut', @_debouncedSync
    // @editor.on 'paste', @_debouncedSync
    this.editor.on('change', this._debouncedSync);

    this.components = [
      new PageBackgroundColor(this.$('.page_background_color')),
      new PredefinedCheckbox(this.$('.page_border'), PAGE_BORDER_REGEXP),
      new PredefinedCheckbox(this.$('.sticky_menu'), STICKY_MENU_REGEXP),
      new BodyBackground(this.$('.body_background'))
    ];

    this._syncComponents();
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

  async _importComponents() {
    const { default: CodeMirror } = await import(/* webpackChunkName: "codemirror" */ 'codemirror');
    const { default: md5 } = await import(/* webpackChunkName: "codemirror5" */ 'blueimp-md5');

    await Promise.all([
      import(/* webpackChunkName: "coremirror" */ 'codemirror/addon/hint/show-hint'),
      import(/* webpackChunkName: "coremirror" */ 'codemirror/addon/hint/css-hint'),
      import(/* webpackChunkName: "coremirror" */ 'codemirror/addon/display/fullscreen'),
      import(/* webpackChunkName: "coremirror" */ 'codemirror/addon/dialog/dialog'),
      import(/* webpackChunkName: "coremirror" */ 'codemirror/addon/search/searchcursor'),
      import(/* webpackChunkName: "coremirror" */ 'codemirror/addon/search/search'),
      import(/* webpackChunkName: "coremirror" */ 'codemirror/addon/scroll/annotatescrollbar'),
      import(/* webpackChunkName: "coremirror" */ 'codemirror/addon/search/matchesonscrollbar'),
      import(/* webpackChunkName: "coremirror" */ 'codemirror/addon/search/jump-to-line')
    ]);

    this.md5 = md5;
    this.CodeMirror = CodeMirror;
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
    let isExpanded = cookies.get('expanded-styles') === '1';

    if (newValue !== undefined) {
      isExpanded = newValue;
      cookies.set('expanded-styles', isExpanded ? '1' : '0', { expires: 730, path: '/' });
    }

    this.$root.toggleClass('expanded', isExpanded);
    this.$('.style_css .editor-expand').toggleClass('active', !isExpanded);
    this.$('.style_css .editor-collapse').toggleClass('active', isExpanded);
  }
}
