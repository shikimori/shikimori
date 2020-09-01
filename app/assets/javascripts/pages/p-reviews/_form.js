pageLoad('reviews_new', 'reviews_edit', 'reviews_create', 'reviews_update', () => {
  $('.b-rate').rateable();
  $('.b-shiki_editor')
    .on('preview:params', function () {
      return {
        body: $(this).view().$textarea.val(),
        target_id: $('#review_target_id').val(),
        target_type: $('#review_target_type').val()
      };
    });
});
