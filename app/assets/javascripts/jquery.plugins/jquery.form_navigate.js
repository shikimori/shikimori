if (window.history && window.history.navigationMode) {
  window.history.navigationMode = 'compatible';
}

$.extend({
  formNavigate(options) {
    $(document.body).on('change paste keypress', 'textarea', ({ currentTarget }) => {
      $(currentTarget).data('navigate_check_required', true);
    });

    $(document.body).on('submit', 'form', ({ currentTarget }) => {
      $(currentTarget)
        .find('textarea')
        .data('navigate_check_required', false);
    });

    $(window).on('beforeunload turbolinks:before-visit', e => {
      let hasUnsavedChanges = false;

      $('textarea:visible').each((_index, node) => {
        const $node = $(node);
        if (!$node.data('navigate_check_required')) { return; }

        $node.data('navigate_check_required', false);

        if (node.value.length > options.size) {
          hasUnsavedChanges = true;
        }
      });

      if (hasUnsavedChanges && !window.confirm(options.message)) {
        e.preventDefault();
      }
    });
  }
});
