import getjs from 'get-js';
import URI from 'urijs';

import { mobileDetect } from 'helpers/mobile_detect';

$(document).on('turbolinks:load', async () => {
  if (document.body.id === 'pages_my_target_ad') { return; }
  if (window.ENV !== 'production') { return; }
  if (!mobileDetect.phone() && !mobileDetect.tablet()) { return; }
  if (URI(document.location.href).domain() !== 'shikimori.org') { return; }

  if (window.MRGtag) {
    window.MRGtag.push({});
  } else {
    await getjs('//ad.mail.ru/static/ads-async.js');
    (window.MRGtag = window.MRGtag || []).push({});
  }
});
