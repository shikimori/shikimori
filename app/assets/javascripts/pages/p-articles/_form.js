import { initTagsApp, initVideo, initWall, initForm } from '../p-topics/_news_form';

pageLoad('articles_new', 'articles_edit', 'articles_create', 'articles_update', () => {
  const $form = $('.b-form.edit_article, .b-form.new_article');

  $('.b-shiki_editor.unprocessed').shikiEditor();

  const $wall = initWall($form);
  const $video = initVideo('article', $form, $wall);
  initTagsApp('article');
  initForm('topic', $form, $wall, $video);
});
