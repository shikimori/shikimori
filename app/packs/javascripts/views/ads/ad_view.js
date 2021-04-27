import cookies from 'js-cookie';
import delay from 'delay';

import View from '@/views/application/view';

const removeAd = function (adClass) {
  console.log(`remove ad ${adClass}`);
  return $(`.${adClass}`).remove();
};

let globalAdState = null;
const AD_STATE = {
  LOADED: 'loaded'
};

const CLOSE_AD_HTML = '<div class=\'close-ad\'></div>';

export class AdView extends View {
  initialize(html, cssClass, adParams) {
    this.html = html;
    this.cssClass = cssClass;
    this.ad_params = adParams;

    if (globalAdState !== AD_STATE.LOADED) {
      this._loadAdHandler();
    }

    return this._replaceNode();
  }

  _loadAdHandler() {
    globalAdState = AD_STATE.LOADED;

    $(window).on('message', e => {
      if (e.originalEvent.data?.type === 'removeAd') {
        removeAd(e.originalEvent.data.adClass);
      }
    });
  }

  _replaceNode() {
    const $close = $(CLOSE_AD_HTML);

    if (cookies.get(`${this.cssClass}_disabled`)) {
      this.$node.remove();
    } else {
      const $ad = $(`<div>${this.html}</div>`)
        .addClass(this.cssClass)
        .append($close);

      this.$node.replaceWith($ad);

      $close.on('click', async () => {
        cookies.set(`${this.cssClass}_disabled`, '1', { expires: 7 });
        $ad.addClass('removing');
        await delay(1000);
        removeAd(this.cssClass);
      });

      // $new_content = $(@html).addClass(@cssClass)

      // $iframe = $new_content.find 'iframe'
      // console.log $new_content.html()

      // $iframe.on 'load', ->
        // iframe = $iframe[0]
        // doc = if iframe.contentDocument
          // iframe.contentDocument
        // else
          // iframe.contentWindow.document

        // delay(3.5 * 1000).then ->
          // unless $('iframe,#placeholder', doc).exists()
            // $new_content.remove()
    }
  }
}
