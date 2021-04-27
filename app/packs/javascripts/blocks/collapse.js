import cookies from 'js-cookie';

$(document).on('click', '.collapse', ({ currentTarget }, custom) => {
  const $node = $(currentTarget);

  const actionText = $node.children('.action').html();
  const isHide = !!actionText.match(/свернуть|спрятать|collapse|hide/);

  $node.toggleClass('triggered', isHide);

  // блок-заглушка, в которую сворачивается контент
  let $placeholder = $node.next();
  if (!$placeholder.hasClass('collapsed')) {
    $placeholder = $placeholder.next();
  }

  // контент, убираемый под спойлер
  let $hideable = $placeholder.next();

  // если в $hideable ничего, значит надо идти на уровень выше и брать next оттуда
  if (!$hideable.exists()) {
    $hideable = $node.parent().next();
  }

  // скрываем не только следующий элемент, но и все последующие с классом collapse-merged
  while ($hideable.last().next().hasClass('collapse-merged')) {
    $hideable = $hideable.add($hideable.last().next());
  }

  // при этом игнорируем то, что имеет класс collapse-ignored
  if ($hideable.length > 1) {
    $hideable = $hideable.filter(':not(.collapse-ignored)');
  }

  if (isHide) {
    $placeholder.show();
    $hideable.hide();
  } else {
    $hideable.show();
    $placeholder.hide();
  }

  // корректный текст для кнопки действия
  $node.children('.action').html(function () {
    const $action = $(this);

    if ($action.hasClass('half-hidden')) {
      if (isHide) {
        $action.hide();
      } else {
        $action.show();
      }
    }

    if (isHide) {
      return $action.html()
        .replace('свернуть', 'развернуть')
        .replace('спрятать', 'показать')
        .replace('hide', 'show')
        .replace('collapse', 'expand');
    }

    return $action.html()
      .replace('развернуть', 'свернуть')
      .replace('показать', 'спрятать')
      .replace('show', 'hide')
      .replace('expand', 'collapse');
  });

  if (!custom) {
    const id = $node.attr('id');
    if (id && (id !== '') && (id.indexOf('-') !== -1)) {
      const name = id.split('-').slice(1).join('-') + ';';
      const collapses = cookies.get('collapses') || '';

      if (isHide && (collapses.indexOf(name) === -1)) {
        cookies.set('collapses', collapses + name, { expires: 730, path: '/' });
      } else if (!isHide && (collapses.indexOf(name) !== -1)) {
        cookies.set('collapses', collapses.replace(name, ''), { expires: 730, path: '/' });
      }
    }
  }

  $placeholder.next().trigger('show');
});

// всем картинкам внутри спойлера надо заново проверить высоту
// $hideable.find('img').addClass 'check-width'

// клик на "свернуть"
$(document).on('click', '.collapsed', ({ currentTarget }) => {
  let $trigger = $(currentTarget).prev();

  if (!$trigger.hasClass('collapse')) {
    $trigger = $trigger.prev();
  }

  $trigger.trigger('click');
});

$(document).on('click', '.hide-expanded', ({ currentTarget }) => {
  $(currentTarget).parent().prev().trigger('click');
});

// клик на содержимое спойлера
$(document).on('click', '.spoiler.target', ({ currentTarget }) => {
  if (!$(currentTarget).hasClass('dashed')) { return; }

  $(currentTarget).hide().prev().show()
    .prev()
    .show();
});
