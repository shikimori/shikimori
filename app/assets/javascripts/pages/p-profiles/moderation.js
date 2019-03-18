import delay from 'delay';
import Turbolinks from 'turbolinks';

import BanForm from 'views/comments/ban_form';
import flash from 'services/flash';

pageLoad('profiles_moderation', () => {
  $('.b-form.new_ban').on('ajax:success', async () => {
    flash.info(I18n.t('frontend.pages.p_profiles.page_is_reloading'));
    await delay(500);

    Turbolinks.visit(document.location.href, true);
  });

  new BanForm($('.b-form.new_ban'));

  $('.ban-time').livetime();
});
