import ShikiEditor from 'views/application/shiki_editor';

pageLoad(
  'oauth_applications_new',
  'oauth_applications_create',
  'oauth_applications_edit',
  'oauth_applications_update',
  () => {
    $('.oauth_application_redirect_uri .hint .sample').on('click', (_index, node) => {
      $('.oauth_application_redirect_uri input').val(node.innerHTML);
    });

    $('.b-shiki_editor').each((_editorIndex, editorNode) =>
      new ShikiEditor(editorNode)
    );
  });
