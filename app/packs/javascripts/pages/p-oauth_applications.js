import checkHeight from '@/utils/check_height';

pageLoad(
  'oauth_applications_new',
  'oauth_applications_create',
  'oauth_applications_edit',
  'oauth_applications_update',
  () => {
    $('.oauth_application_redirect_uri .hint .sample').on('click', ({ currentTarget }) => {
      $('.oauth_application_redirect_uri input').val(currentTarget.innerHTML);
    });
  });

pageLoad('oauth_applications_show', () => {
  checkHeight($('.description'), { maxHeight: 200 });
});
