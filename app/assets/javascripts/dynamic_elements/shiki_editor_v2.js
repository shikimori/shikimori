/* global IS_LOCAL_SHIKI_PACKAGES */
import View from 'views/application/view';
import memoize from 'memoize-decorator';
import csrf from 'helpers/csrf';
import axios from 'helpers/axios';
import { bind } from 'shiki-decorators';

export default class ShikiEditorV2 extends View {
  async initialize() {
    console.log(this.node);
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

  get editorApp() {
    return this.app.$children[0];
  }

  @memoize
  get $form() {
    return this.$node.closest('form');
  }

  editComment($comment, $form) {
    const $initialContent = $comment.children().detach();
    $form.appendTo($comment);

    // отмена редактирования
    this.$('.cancel').on('click', () => {
      $form.remove();
      $comment.append($initialContent);
    });

    // замена комментария после успешного сохранения
    $form.on('ajax:success', (e, response) => (
      $comment.view()._replace(response.html, response.JS_EXPORTS)
    ));
  }

  replyComment(reply, _isOfftopic) {
    if (!this.$node.is(':appeared')) {
      $.scrollTo(this.$node, () => this.replyComment(reply, _isOfftopic));
      return;
    }

    if (reply.constructor === String) {
      this.editorApp.appendText(reply);
    } else if (reply.html) {
      this.editorApp.appendQuote(reply);
    } else {
      this.editorApp.appendReply(reply);
    }
  }

  cleanup() {
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
    const localizationField = document.body.getAttribute('data-localized_names') == 'en' ?
      'name' :
      'russian';

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
          }
        }
      })
    });
  }

  _bindForm() {
    this.$form.on('submit', this.sync);
  }

  _scheduleDestroy() {
    $(document).one('turbolinks:before-cache', this.destroy);
  }

  @bind
  sync() {
    this.input.value = this.editorApp.exportContent();
  }

  @bind
  destroy() {
    this.$form.off('submit', this.sync);

    this.app?.$destroy();
    this.vueNode.remove();

    this.vueNode = document.createElement('div');
    this.vueNode.classList.add('vue-app');
    this.vueNode.classList.add('b-ajax');
    this.node.append(this.vueNode);
  }
}
