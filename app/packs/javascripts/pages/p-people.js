import checkHeight from '@/utils/check_height';

pageLoad('people_show', async () => {
  checkHeight($('.c-info-left .b-entry-info'), { maxHeight: 101, isNoShade: true });
  checkHeight($('.c-info-right .b-entry-info'), { maxHeight: 101, isNoShade: true });

  // комментировать
  $('.b-subposter-actions .new_comment').on('click', () => {
    $('.shiki_editor-selector').view().focus();
  });

  const { FavoriteStar } =
    await import(/* webpackChunkName: "db_entries_show" */ '@/views/db_entries/favorite_star');

  Object.keys(gon.is_favoured).forEach(role => {
    if (gon.person_role[role] || gon.is_favoured[role]) {
      const $button = $(`.b-subposter-actions .fav-add[data-kind='${role}']`);

      $button.show();
      new FavoriteStar($button, gon.is_favoured[role]);
    }
  });
});
