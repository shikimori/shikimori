/* global IS_LOCAL_SHIKI_PACKAGES */
import delay from 'delay';
import memoize from 'memoize-decorator';
import pDefer from 'p-defer';
import { bind } from 'shiki-decorators';
import { flash } from 'shiki-utils';

import View from 'views/application/view';

import csrf from 'helpers/csrf';
import axios from 'helpers/axios';

export default class ShikiEditorV2 extends View {
  initialization = pDefer()

  async initialize() {
    await this._buildEditor();
    window.editor = this;
    this.initialization.resolve();
  }

  get editorApp() {
    return this.app.$children[0];
  }

  @memoize
  get $form() {
    return this.$node.closest('form');
  }

  async _buildEditor() {
    this.vueNode = this.node.querySelector('.vue-app');
    this.input = this.node.querySelector('input');

    const [
      { Vue },
      { ShikiEditorApp },
      { default: ShikiUploader },
      { ShikiRequest }
    ] = await Promise.all([
      import(/* webpackChunkName: "vue" */ 'vue/instance'),
      import(/* webpackChunkName: "shiki-editor" */
        IS_LOCAL_SHIKI_PACKAGES ?
          'packages/shiki-editor' :
          'shiki-editor'
      ),
      import(
        IS_LOCAL_SHIKI_PACKAGES ?
          'packages/shiki-uploader' :
          'shiki-uploader'
      ),
      import(
        IS_LOCAL_SHIKI_PACKAGES ?
          'packages/shiki-utils' :
          'shiki-utils'
      )
    ]);

    this.app = this._buildApp(Vue, ShikiEditorApp, ShikiUploader, ShikiRequest);
    this.vueNode = this.app.$el;

    this._bindForm();
    this._scheduleDestroy();
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
    } else {
      this.editorApp.appendReply(reply);
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

  _buildShikiUploader(ShikiUploader) {
    return new ShikiUploader({
      locale: window.LOCALE,
      xhrEndpoint: '/api/user_images?linked_type=Comment',
      xhrHeaders: () => csrf().headers
    });
  }

  _buildApp(Vue, ShikiEditorApp, ShikiUploader, ShikiRequest) {
    const shikiUploader = this._buildShikiUploader(ShikiUploader);
    const shikiRequest = new ShikiRequest(window.location.origin, axios);
    const localizationField = document.body.getAttribute('data-localized_names') === 'en' ?
      'name' :
      'russian';

    const { $form } = this;

    return new Vue({
      el: this.vueNode,
      components: { ShikiEditorApp },
      mounted() {
        if ($('.l-top_menu-v2').css('position') === 'sticky') {
          this.$children[0].isMenuBarOffset = true;
        }
      },
      render: createElement => createElement(ShikiEditorApp, {
        props: {
          vue: Vue,
          shikiUploader,
          shikiRequest,
          globalSearch: window.globalSearch,
          content: this.input.value,
          localizationField
        },
        on: {
          preview({ node, JS_EXPORTS }) {
            $(node).process(JS_EXPORTS);
          },
          submit() {
            $form.submit();
          }
        }
      })
    });
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
  }

  _markOfftopic(isOfftopic) {
    this.$form.find('input[name$="[is_offtopic]"]').val(isOfftopic ? 'true' : 'false');
    this.$('.b-offtopic_marker').toggleClass('off', !isOfftopic);
  }

  _markReview(isReview) {
    this.$form.find('input[name$="[is_summary]"]').val(isReview ? 'true' : 'false');
    this.$('.b-summary_marker').toggleClass('off', !isReview);
  }

  @bind
  _formSubmit() {
    this.input.value = this.editorApp.exportContent();
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

    this.$form.off('submit', this._formSubmit);
    this.$form.off('ajax:before', this._formAjaxBefore);
    this.$form.off('ajax:complete', this._formAjaxComplete);
    this.$form.off('ajax:success', this._formAjaxSuccess);

    this.app?.$destroy();
    this.vueNode.remove();

    this.vueNode = document.createElement('div');
    this.vueNode.classList.add('vue-app');
    this.vueNode.classList.add('b-ajax');
    this.node.insertBefore(this.vueNode, this.node.querySelector('footer'));
  }
}
