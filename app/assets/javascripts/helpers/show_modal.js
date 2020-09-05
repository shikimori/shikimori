import delay from 'delay';

export default function showModal({
  $modal,
  $trigger,
  $outerNode,
  show,
  hide,
  onlyShow,
  isIgnored,
  isHidden
}) {
  let ignoreNextEvent = false;

  function checkHidden() {
    return isHidden ? isHidden() : $modal.css('display') === 'none';
  }

  function toggleModal({ type }) {
    if (type !== 'focus' && isIgnored && isIgnored()) { return; }
    const eventName = checkHidden() || type === 'focus' ?
      'modal:show' :
      'modal:hide';

    if (eventName === 'modal:hide' && onlyShow) { return; }
    if (ignoreNextEvent) { return; }

    $modal.trigger(eventName);

    // to prevent immediately click after focus
    ignoreNextEvent = true;
    delay().then(() => ignoreNextEvent = false);
  }

  function tryCloseModal({ target }) {
    const $target = $(target);
    const isInside = target === ($outerNode || $modal)[0] ||
      $target.closest($outerNode || $modal).length;

    if (isInside || !$target.parents('html').length) { return; }

    $modal.trigger('modal:hide');
  }

  function closeModalOnEsc({ keyCode }) {
    if (keyCode !== 27) {
      return;
    }

    $modal.trigger('modal:hide');
  }

  if ($trigger.constructor === String) {
    $(document).on('mousedown focus', $trigger, toggleModal);
  } else {
    $trigger.on('mousedown focus', toggleModal);
  }

  $modal
    .on('modal:show', () => {
      if (!checkHidden()) { return; }

      if (show) {
        show();
      } else {
        $modal.show();
      }

      delay().then(() => {
        $(document.body).on('click', tryCloseModal);
        $(document.body).on('focus', '*', tryCloseModal);
        $(document.body).on('keydown', closeModalOnEsc);

        $(document).one('turbolinks:before-cache', () => {
          $(document.body).off('click', tryCloseModal);
          $(document.body).off('focus', '*', tryCloseModal);
          $(document.body).off('keydown', closeModalOnEsc);
        });
      });
    })
    .on('modal:hide', () => {
      if (checkHidden()) { return; }

      if (hide) {
        hide();
      } else {
        $modal.hide();
      }

      $(document.body).off('click', tryCloseModal);
      $(document.body).off('focus', '*', tryCloseModal);
      $(document.body).off('keydown', closeModalOnEsc);

      if ($trigger.is(':focus')) {
        $trigger.blur();
      }
    });

  return {
    $modal,
    $trigger,
    $outerNode,
    show() {
      $modal.trigger('modal:show');
    },
    hide() {
      $modal.trigger('modal:hide');
    }
  };
}
