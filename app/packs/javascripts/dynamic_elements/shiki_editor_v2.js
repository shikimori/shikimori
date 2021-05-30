/* global IS_LOCAL_SHIKI_PACKAGES */
import delay from 'delay';
import pDefer from 'p-defer';
import { bind, memoize } from 'shiki-decorators';
import { flash } from 'shiki-utils';

import View from '@/views/application/view';

import csrf from '@/helpers/csrf';
import axios from '@/helpers/axios';

const VUE_PENDING_CLASS = 'vue-node'
const VUE_INITIALIZED_CLASS = 'vue-node-initialized'

export default class ShikiEditorV2 extends View {
  initialization = pDefer()
  processedInitialContent = null
  isPendingSubmit = false
  editorApp = null

  async initialize() {
    await this._buildEditor();
    this.initialization.resolve();

    this._processCache();
  }

  @memoize
  get $form() {
    return this.$node.closest('form');
  }

  @memoize
  get isSessionStorageAvailable() {
    // if (window.ENV === 'development') {
    //   console.log(['editor', this, 'key', this.cacheKey, this.node]);
    // }

    // return window.ENV === 'development' && typeof(sessionStorage) !== 'undefined';
    return typeof(sessionStorage) !== 'undefined';
  }

  @memoize
  get cacheKey() {
    const cacheKey = this.node.getAttribute('data-cache_key');
    const fieldName = this.node.getAttribute('data-field_name');

    if (!cacheKey) { return null; }

    return fieldName ? `${cacheKey}/${fieldName}` : cacheKey;
  }

  get editorContent() {
    return this.editorApp.exportContent();
  }

  // added for compatibility with shiki-editor-v1
  // used in
  //  combineDescription(
  //    $('.shiki_editor-selector[data-field_name$="description_ru_text]"]', $form).view().text,
  //    $('[name$="description_ru_source]"]', $form).val()
  //  )
  get text() { return this.editorContent; }

  async _buildEditor() {
    this.vueNode = this.node.querySelector(`.${VUE_PENDING_CLASS}`);
    this.input = this.node.querySelector('input');
    this.appPlaceholder = this.node.querySelector('.app-placeholder')

    if (!this.vueNode) {
      this._rebuildNodes();
    }

    const [
      { createApp, h },
      { ShikiEditorApp },
      { default: ShikiUploader },
      { ShikiRequest }
    ] = await Promise.all([
      import(/* webpackChunkName: "vue" */ 'vue'),
      import(/* webpackChunkName: "shiki-editor" */
        'shiki-editor'
        // '../../../../../shiki-editor'
      ),
      import('shiki-uploader'),
      import('shiki-utils')
    ]);

    this.app = this._buildApp(
      { createApp, h },
      ShikiEditorApp,
      ShikiUploader,
      ShikiRequest
    );
    this.vueNode = this.app.$el;

    this._bindForm();
    this._scheduleDestroy();
  }

  _rebuildNodes() {
    this.node.querySelector(`.${VUE_INITIALIZED_CLASS}`)?.remove();

    this.appPlaceholder.classList.remove('hidden');

    this.vueNode = document.createElement('div');
    this.vueNode.classList.add(VUE_PENDING_CLASS);
    this.node.insertBefore(this.vueNode, this.node.querySelector('footer'));
  }

  replyComment(reply, isOfftopic) {
    if (!this.$node.is(':appeared')) {
      $.scrollTo(this.$node, () => this.replyComment(reply, isOfftopic));
      return;
    }

    if (reply.constructor === String) {
      this.editorApp.appendText(reply);
    } else if (reply.html) {
      this.editorApp.appendQuote(reply);
    } else if (this._isNoReply(reply)) {
      this.editorApp.appendReply(reply);
    } else {
      this.editorApp.focus();
    }

    if (isOfftopic) {
      this._markOfftopic(true);
    }
  }

  focus() {
    if (!$(this.editorApp.$el).is(':appeared')) {
      $.scrollTo(this.editorApp.$el);
    }

    this.editorApp.focus();
  }

  async cleanup() {
    this._markOfftopic(false);
    this._markReview(false);

    this.editorApp.clearContent();
  }

  _initialContent() {
    return this.input.value;
  }

  async _processCache() {
    if (!this.isSessionStorageAvailable) { return; }

    await delay(10);
    this.processedInitialContent = this.editorContent;

    const cachedValue = this._readCacheValue()
    if (cachedValue && cachedValue !== this.processedInitialContent) {
      this.editorApp.setUnsavedContent(cachedValue);
    }
  }

  _buildShikiUploader(ShikiUploader) {
    return new ShikiUploader({
      locale: window.LOCALE,
      xhrEndpoint: '/api/user_images?linked_type=Comment',
      xhrHeaders: () => csrf().headers
    });
  }

  _buildApp({ createApp, h }, ShikiEditorApp, ShikiUploader, ShikiRequest) {
    const shikiUploader = this._buildShikiUploader(ShikiUploader);
    const shikiRequest = new ShikiRequest(window.location.origin, axios);
    const localizationField = document.body.getAttribute('data-localized_names') === 'en' ?
      'name' :
      'russian';

    const { $form, appPlaceholder } = this;

    const app = createApp({
      components: { ShikiEditorApp },
      mounted() {
        appPlaceholder.classList.add('hidden');

        // if ($('.l-top_menu-v2').css('position') === 'sticky') {
        //   this.$children[0].isMenuBarOffset = true;
        // }
      },
      beforeUnmount() {
        appPlaceholder.classList.remove('hidden');
      },
      render: () => h(ShikiEditorApp, {
        shikiUploader,
        shikiRequest,
        globalSearch: window.globalSearch,
        content: this._initialContent(),
        localizationField,
        previewParams: this.$node.data('preview_params'),
        class: VUE_INITIALIZED_CLASS,
        onPreview({ node, JS_EXPORTS }) {
          $(node).process(JS_EXPORTS);
        },
        onSubmit() {
          $form.submit();
        },
        ref: el => this.editorApp = el
      })
    });
    app.config.globalProperties.I18n = I18n;
    app.mount(this.vueNode);

    return app;
  }

  _bindForm() {
    this.$form
      .on('submit', this._formSubmit)
      .on('ajax:before', this._formAjaxBefore)
      .on('ajax:complete', this._formAjaxComplete)
      .on('ajax:success', this._formAjaxSuccess);

    this.$('.b-offtopic_marker').on('click', this._onMarkOfftopic);
    this.$('.b-summary_marker').on('click', this._onMarkReview);
  }

  _scheduleDestroy() {
    $(document).one('turbolinks:before-cache', this.destroy);
    $(window).one('beforeunload', this.destroy);
  }

  _markOfftopic(isOfftopic) {
    this.$form.find('input[name$="[is_offtopic]"]').val(isOfftopic ? 'true' : 'false');
    this.$('.b-offtopic_marker').toggleClass('off', !isOfftopic);
  }

  _markReview(isReview) {
    this.$form.find('input[name$="[is_summary]"]').val(isReview ? 'true' : 'false');
    this.$('.b-summary_marker').toggleClass('off', !isReview);
  }

  _readCacheValue() {
    return this.cacheKey && this.isSessionStorageAvailable ?
      (window.sessionStorage.getItem(this.cacheKey) || '') :
      '';
  }

  _writeCacheValue(value) {
    const trimmedValue = value?.trim();

    if (!trimmedValue) {
      if (this.editorApp.unsavedContent) { return; }
      return this._clearCacheValue();
    }

    if (this.cacheKey && this.isSessionStorageAvailable) {
      if (trimmedValue !== this.processedInitialContent) {
        window.sessionStorage.setItem(this.cacheKey, trimmedValue);
      }
    }
  }

  _clearCacheValue() {
    if (this.cacheKey && this.isSessionStorageAvailable) {
      window.sessionStorage.removeItem(this.cacheKey);
    }
  }

  _isNoReply(reply) {
    return !this.editorContent.endsWith(`[${reply.type}=${reply.id};${reply.userId}],`);
  }

  @bind
  _formSubmit() {
    this.input.value = this.editorContent;
    this.isPendingSubmit = true;
  }

  @bind
  _formAjaxBefore() {
    if (this.input.value.replace(/\n| |\r|\t/g, '')) {
      this.$node.addClass('b-ajax');
      return true;
    }

    flash.error(I18n.t('frontend.shiki_editor.text_cant_be_blank'));
    return false;
  }

  @bind
  _formAjaxComplete() {
    this.$node.removeClass('b-ajax');
  }

  @bind
  async _formAjaxSuccess() {
    await delay();

    this.input.value = '';
    this.editorApp.setContent('');
    this._clearCacheValue();

    if ($(this.editorApp.$el).is(':visible')) {
      this.focus();
    }
  }

  @bind
  _onMarkOfftopic() {
    this._markOfftopic(
      this.$('.b-offtopic_marker').hasClass('off')
    );
  }

  @bind
  _onMarkReview() {
    this._markReview(
      this.$('.b-summary_marker').hasClass('off')
    );
  }

  @bind
  destroy() {
    $(document).off('turbolinks:before-cache', this.destroy);
    $(window).off('beforeunload', this.destroy);

    this.$form.off('submit', this._formSubmit);
    this.$form.off('ajax:before', this._formAjaxBefore);
    this.$form.off('ajax:complete', this._formAjaxComplete);
    this.$form.off('ajax:success', this._formAjaxSuccess);

    if (!this.app) { return; }

    if (this.isPendingSubmit) {
      this._clearCacheValue();
    } else {
      this._writeCacheValue(this.editorContent);
    }
  }
}
