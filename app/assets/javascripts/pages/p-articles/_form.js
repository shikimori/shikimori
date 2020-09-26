import { initTagsApp, initVideo, initWall, initForm } from '../p-topics/_extended_form';

pageLoad('articles_new', 'articles_edit', 'articles_create', 'articles_update', () => {
  const $form = $('.b-form.edit_article, .b-form.new_article');
  const $wall = $form.find('.b-shiki_wall');

  const $video = initVideo('article', $form, $wall);
  initWall($form, $wall);
  initTagsApp('article');
  initForm('article', $form, $wall, $video);
});
