/* global IS_LOCAL_SHIKI_PACKAGES */
import View from 'views/application/view';
// import memoize from 'memoize-decorator';
import csrf from 'helpers/csrf';
import axios from 'helpers/axios';
import { bind } from 'shiki-decorators';

export default class ShikiEditorV2 extends View {
  async initialize() {
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

    const shikiUploader = new ShikiUploader({
      locale: window.LOCALE,
      xhrEndpoint: '/api/user_images?linked_type=Comment',
      xhrHeaders: () => csrf().headers
    });

    const shikiRequest = new ShikiRequest(window.location.origin, axios);

    this.app = new Vue({
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
          content: this.input.value
        },
        on: {
          preview(node) {
            $(node).process();
          }
        }
      })
    });
    this.vueNode = this.app.$el;
    $(document).one('turbolinks:before-cache', this.destroy);
  }

  get editorApp() {
    return this.app.$children[0];
  }

  @bind
  destroy() {
    this.app?.$destroy();
    this.vueNode.remove();

    this.vueNode = document.createElement('div');
    this.vueNode.classList.add('vue-app');
    this.vueNode.classList.add('b-ajax');
    this.node.append(this.vueNode);
  }
}
