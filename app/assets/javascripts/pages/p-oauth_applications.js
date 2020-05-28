import ShikiEditor from 'views/shiki_editor/index';

pageLoad(
  'oauth_applications_new',
  'oauth_applications_create',
  'oauth_applications_edit',
  'oauth_applications_update',
  () => {
    $('.oauth_application_redirect_uri .hint .sample').on('click', ({ currentTarget }) => {
      $('.oauth_application_redirect_uri input').val(currentTarget.innerHTML);
    });

    $('.b-shiki_editor').each((_editorIndex, editorNode) =>
      new ShikiEditor(editorNode)
    );
  });

pageLoad('oauth_applications_show', () => {
  $('.description').checkHeight({ max_height: 200 });
});
