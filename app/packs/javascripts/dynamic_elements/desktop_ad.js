import View from 'views/application/view';
import { AdView } from 'views/ads/ad_view';
import { YandexAd } from 'views/ads/yandex_ad';
import { MytargetAd } from 'views/ads/mytarget_ad';

import { mobileDetect, isTablet, isPhone } from 'shiki-utils';

export default class DesktopAd extends View {
  initialize() {
    const provider = this.$node.data('ad_provider');
    const html = this.$node.data('ad_html');
    const cssClass = this.$node.data('ad_css_class');
    const adParams = this.$node.data('ad_params');
    const platform = this.$node.data('platform');

    if (!this._platformMatched(platform)) { return; }

    if (provider === 'yandex_direct') {
      new YandexAd(this.$node, html, cssClass, adParams);
    } if (provider === 'mytarget') {
      new MytargetAd(this.$node, html, cssClass, adParams);
    } else {
      new AdView(this.$node, html, cssClass, adParams);
    }
  }

  _platformMatched(platform) {
    if (platform === 'desktop') {
      return isTablet() || !isPhone();
    }
    return mobileDetect.phone || mobileDetect.tablet;
  }
}
