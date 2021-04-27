pageLoad('clubs_edit', async () => {
  // links page
  if ($('.edit-page.links').exists()) {
    $('.anime-suggest').completableVariant();
    $('.manga-suggest').completableVariant();
    $('.ranobe-suggest').completableVariant();
    $('.character-suggest').completableVariant();
    $('.club-suggest').completableVariant();
    $('.collection-suggest').completableVariant();
  }

  // members page
  if ($('.edit-page.members').exists()) {
    $('.moderator-suggest').completableVariant();
    $('.admin-suggest').completableVariant();
    $('.kick-suggest').completableVariant();
    $('.ban-suggest').completableVariant();
  }

  // styles page
  if ($('.edit-page.styles').exists()) {
    const { EditStyles } =
      await import(/* webpackChunkName: "edit_styles" */ 'views/styles/edit');

    new EditStyles('.b-edit_styles');
  }
});
