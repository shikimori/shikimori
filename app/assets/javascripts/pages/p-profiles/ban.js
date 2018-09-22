import delay from 'delay';
import Turbolinks from 'turbolinks';

import flash from 'services/flash';

page_load('profiles_ban', () => {
  $('.b-form.new_ban').on('ajax:success', async () => {
    flash.info(I18n.t('frontend.pages.p_profiles.page_is_reloading'));
    await delay(500);

    Turbolinks.visit(document.location.href, true);
  });

  $('.ban-time').livetime();
});
