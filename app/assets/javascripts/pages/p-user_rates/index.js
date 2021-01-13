import delay from 'delay';
import Turbolinks from 'turbolinks';
import { flash } from 'shiki-utils';

import { COMMON_TOOLTIP_OPTIONS } from 'helpers/tooltip_options';
import { isMobile } from 'shiki-utils';
import axios from 'helpers/axios';
import { animatedCollapse, animatedExpand } from 'helpers/animated';

import ShikiModal from 'views/application/shiki_modal';
import CatalogFilters from 'views/animes/catalog_filters';

// TODO: этот гигантский файл нуждается в рефакторинге
let listCache = [];
let filterTimer = null;

pageLoad('user_rates_index', () => {
  applyListHandlers($('.l-content'));
  updateListCache();

  // графики
  $('#scores, #types, #ratings')
    .empty()
    .bar({
      noData($chart) {
        const text = I18n.t('frontend.pages.p_user_rates.insufficient_data');
        $chart.html(`<p class='b-nothing_here'>${text}</p>`);
      }
    });

  // фокус по инпуту фильтра по тайтлу
  $('.b-collection_search input').on('focus', () => {
    if (listCache.length) { return; }
    updateListCache();
  });

  // разворачивание свёрнутых блоков при фокусе на инпут
  $('.b-collection_search input').on('focus', () =>
    $('.collapsed').each((_index, node) => {
      if (node.style.display === 'block') {
        $(node).trigger('click');
      }
    })
  );

  // пишут в инпуте фильтра по тайтлу
  $('.b-collection_search input').on('keyup', ({ keyCode }) => {
    if (keyCode === 91 || keyCode === 18 || keyCode === 16 || keyCode === 17) { return; }

    if (filterTimer) {
      clearInterval(filterTimer);
      filterTimer = null;
    }

    filterTimer = setInterval(filterList, 350);
  });

  // сортировка по клику на колонку
  $('.order-control').on('click', ({ currentTarget }) => {
    const $node = $(currentTarget);

    if ($node.hasClass('active')) {
      $('.order-by-ranked').trigger('click');
    } else {
      const type = $node.data('order');
      $(`.orders.anime-params li[data-field='order-by'][data-value='${type}']`).trigger('click');
    }
  });

  // редактирование user_rate posters
  $('.list-groups').on('ajax:before', '.edit-user_rate', ({ currentTarget }) => {
    $(currentTarget).closest('.user_rate').addClass('b-ajax');
  });

  $('.list-groups').on('ajax:success', '.edit-user_rate', ({ currentTarget }, formHtml) => {
    const $poster = $(currentTarget).closest('.user_rate');
    $poster.removeClass('b-ajax');

    const $form = $(formHtml).process();
    const modal = new ShikiModal($form);

    $('.remove', $form).on('ajax:success', () => $poster.remove());
    $form.on('ajax:success', (_e, data) => {
      $poster.children('.text')
        .html(data && data.text_html ? data.text_html : '')
        .process()
        .toggleClass('hidden', Object.isEmpty(data.text_html));

      updateTextInCache(data);
      modal.close();
    });
  });

  // фильтры каталога
  const basePath = document.location.pathname.replace(/(\/list\/(?:anime|manga))(\/.+)?/, '$1');
  new CatalogFilters(basePath, document.location.href, (url => {
    Turbolinks.visit(url, true);
    if ($('.l-page.menu-expanded').exists()) {
      $(document).one('page:change', () => $('.l-page').addClass('menu-expanded'));
    }
  }));
});

// фильтрация списка пользователя
function filterList() {
  clearInterval(filterTimer);
  filterTimer = null;

  // разворачивание свёрнутых элементов
  const filterValue = $('.b-collection_search input').val().toLowerCase();

  listCache.forEach(block => {
    let visible = false;
    let num = 0;

    while (num < block.entries.length) {
      const entry = block.entries[num];
      if (
        (entry.target_name.indexOf(filterValue) !== -1) ||
        (entry.target_russian.indexOf(filterValue) !== -1) ||
        (entry.text.indexOf(filterValue) !== -1)
      ) {
        visible = true;

        if (entry.display !== '') {
          entry.display = '';
          entry.node.style.display = '';
        }
      } else if (entry.display !== 'none') {
        entry.display = 'none';
        entry.node.style.display = 'none';
      }
      num += 1;
    }

    if (block.toggable) {
      block.$container.toggle(visible);
      block.$nothingFound.toggle(!visible);
    }
  });

  $.force_appear();
}

// кеширование всех строк списка для производительности
function updateListCache() {
  listCache = $('.list-lines, .list-posters')
    .toArray()
    .map(container => {
      const $container = $(container);
      const $nothingFound = $container.next('.nothing-found');
      const entries = $container
        .find('.user_rate')
        .toArray()
        .map(node => {
          const $node = $(node);

          return {
            node,
            target_id: $node.data('target_id'),
            target_name: String($node.data('target_name')).toLowerCase(),
            target_russian: String($node.data('target_russian')).toLowerCase(),
            text: String($node.data('text') || '').toLowerCase(),
            display: node.style.display
          };
        });

      return {
        $container,
        $nothingFound,
        entries,
        toggable: !$container.next('.b-postloader').length
      };
    });
}

// обработчики для списка
function applyListHandlers($root) {
  // хендлер подгрузки очередной страницы
  $('.b-postloader', $root).on('postloader:before', insertNextPage);
  $('.l-content').on('postloader:success', processNextPage);

  // открытие блока с редактирование записи по клику на строку с аниме
  $('tr.editable', $root).on('click', e => {
    const $editForm = $(e.currentTarget).next();
    if (!$editForm.is('.edit-form')) { return; }

    e.stopImmediatePropagation();
    $editForm.find('.cancel').click();
  });

  $('tr.editable', $root).on('ajax:success', ({ currentTarget }, html) => {
    // прочие блоки редактирования скроем
    const $anotherTrEdit = $('tr.edit-form');

    const $tr = $(currentTarget);
    const $trEdit = $(`<tr class='edit-form'>
      <td colspan='${$(currentTarget).children('td').length}'>${html}</td>
    </tr>`)
      .insertAfter(currentTarget);

    const $form = $trEdit.find('form');
    animatedExpand($form[0]);

    if ($anotherTrEdit.exists()) {
      animatedCollapse($anotherTrEdit.find('form')[0])
        .then(() => $anotherTrEdit.remove());
    }

    // отмена редактирования
    $('.cancel', $trEdit).on('click', async () => {
      await animatedCollapse($form[0]);
      $trEdit.remove();
    });

    $form.on('ajax:before', () => $form.addClass('b-ajax'));

    // применение изменений в редактировании
    $form.on('ajax:success', (e, data) => {
      flash.notice(I18n.t('frontend.pages.p_user_rates.changes_saved'));
      $('.cancel', $trEdit).click();

      $('.current-value[data-field=score]', $tr).html(
        String(data.score || '0').replace(/^0$/, '–')
      );
      $('.current-value[data-field=chapters]', $tr).html(data.chapters);
      $('.current-value[data-field=volumes]', $tr).html(data.volumes);
      $('.current-value[data-field=episodes]', $tr).html(data.episodes);

      $('.rate-text', $tr)
        .html(data.text_html ? `<div>${data.text_html}</div>` : '')
        .process();

      if (data.rewatches > 0) {
        const count = data.rewatches;
        const i18nKey = data.target_type === 'Anime' ? 'rewatch' : 'reread';
        const word = p(
          count,
          I18n.t(`frontend.pages.p_user_rates.${i18nKey}.one`),
          I18n.t(`frontend.pages.p_user_rates.${i18nKey}.few`),
          I18n.t(`frontend.pages.p_user_rates.${i18nKey}.many`)
        );

        $('.rewatches', $tr).html(`${count} ${word}`);
      } else {
        $('.rewatches', $tr).html('');
      }

      // обновляем текст в кеше
      return updateTextInCache(data);
    });

    // удаление из списка
    $('.remove', $form).on('ajax:success', async e => {
      e.stopPropagation();

      $('.cancel', $trEdit).click();
      await delay(250);
      $tr.remove();
    });
  });

  $('tr.unprocessed', $root)
    .removeClass('unprocessed')
    .find('a.tooltipped')
    .tooltip(
      Object.add(COMMON_TOOLTIP_OPTIONS, {
        offset: [
          -95,
          10
        ],
        position: 'bottom right',
        opacity: 1
      })
    );

  // изменения оценки/числа просмотренных эпизодов у user_rate lines
  const $trs = $('.list-lines .hoverable').off();
  $trs
    .off()
    .hover(
      ({ currentTarget }) => {
        if (isMobile()) { return; }

        const $currentValue = $('.current-value', currentTarget);
        let $newValue = $('.new-value', currentTarget);

        // если нет элемента, то создаём его
        if (!$newValue.length) {
          let val = parseInt($currentValue.text(), 10);
          if (!val && (val !== 0)) { val = 0; }

          const newValueHtml = $currentValue.data('field') !== 'score' ?
            '<span class="new-value"><input type="text" class="input"/><span class="item-add"></span></span>' :
            '<span class="new-value"><input type="text" class="input"/></span>';

          $newValue = $(newValueHtml)
            .children('input')
            .val(val)
            .data({
              counter: val,
              max: $currentValue.data('max') || 999,
              min: $currentValue.data('min')
            })
            .data({
              field: $currentValue.data('field'),
              action: $currentValue.closest('tr').data('rate_url')
            })
            .parent()
            .insertAfter($currentValue);

          applyNewValueHandlers($newValue);
        }

        $newValue.show();
        $currentValue.hide();
        $('.misc-value', currentTarget).hide();
      },
      ({ currentTarget }) => {
        if (isMobile()) { return; }
        if ($('.new-value input', currentTarget).is(':focus')) { return; }

        $('.new-value', currentTarget).hide();
        $('.current-value', currentTarget).show();
        $('.misc-value', currentTarget).show();
      }
    )
    .on('click', e => {
      if (isMobile()) { return; }
      // клик на плюсик обрабатываем по дефолтному
      if (e.target && (e.target.className === 'item-add')) { return; }

      $(e.currentTarget).trigger('mouseenter');
      $('input', e.currentTarget).focus().select();
      e.stopPropagation();
      e.preventDefault();
    });
}

function applyNewValueHandlers($newValue) {
  // обработчики для инпутов листа
  $('input', $newValue)
    .off()
    .on('blur', ({ currentTarget }) => {
      const input = currentTarget;
      const $input = $(input);

      $input.parent().parent().trigger('mouseleave');

      if (input.value < 0) {
        input.value = 0;
      }
      if ((parseInt(input.value, 10) || 0) === (parseInt($input.data('counter'), 10) || 0)) {
        return;
      }

      const $value = $input.parent().parent().find('.current-value');
      const priorValue = $value.html();

      $input.data('counter', input.value);
      $value.html(
        ($input.data('counter') === '0' ? '&ndash;' : $input.data('counter'))
      );

      axios
        .patch($input.data('action'), { user_rate: { [$input.data('field')]: input.value } })
        .catch(() => {
          $value.html(priorValue);
          flash.error(I18n.t('frontend.pages.p_user_rates.error_occurred'));
        });
    })
    .on('mousewheel', e => {
      const input = e.currentTarget;
      const $input = $(input);

      if (!$input.is(':focus')) { return; }

      e.preventDefault();

      if (e.originalEvent.wheelDelta && (e.originalEvent.wheelDelta > 0)) {
        input.value = Math.min(
          (parseInt(input.value, 10) + 1) || 0,
          parseInt($input.data('max'), 10)
        );
      } else if (e.originalEvent.wheelDelta) {
        input.value = Math.max(
          (parseInt(input.value, 10) - 1) || 0,
          parseInt($input.data('min'), 10)
        );
      }
    })
    .on('keydown', ({ currentTarget, keyCode }) => {
      const input = currentTarget;
      const $input = $(input);

      if (keyCode === 38) {
        input.value = Math.min(
          (parseInt(input.value, 10) + 1) || 0,
          parseInt($input.data('max'), 10)
        );
      } if (keyCode === 40) {
        input.value = Math.max(
          (parseInt(input.value, 10) - 1) || 0,
          parseInt($input.data('min'), 10)
        );
      } if (keyCode === 27) {
        input.value = $input.data('counter');
        $input.blur();
      }
    })
    .on('keypress', e => {
      if (e.keyCode === 13) {
        $(e.currentTarget).blur();
        e.stopPropagation();
      }
    });

  // обработчик для плюсика у числа эпизодов/глав
  $('.item-add', $newValue).on('click', async e => {
    const $input = $(e.currentTarget).prev();

    e.stopPropagation();
    e.preventDefault();

    $input
      .val(parseInt($input.val(), 10) + 1)
      .blur();
    $input.closest('td').trigger('mouseover');
  });
}

// подгрузка очередной страницы списка
function insertNextPage(e, $data) {
  const $header = $data.find('header:first');
  const $presentHeader = $(`header.${$header.attr('class')}`);

  // при подгрузке могут быть 2 случая:
  // 1. подгружается совершенно новый блок, и тогда $header будет пустым
  // 2. погружается дальнейший контент уже существующего блока, и тогда...

  if ($presentHeader.exists()) {
    // # присоединяем к уже существующим сущностям новые
    const $entries = $header.next().children();

    $entries
      .detach()
      .process() // very improtant. or else tooltips wont be displayed
      .appendTo($presentHeader.next());
    applyListHandlers($entries);

    $header.next().remove();
    $header.remove();
  }

  applyListHandlers($data);
}

function processNextPage() {
  updateListCache();
  if (!Object.isEmpty($('.b-collection_search input').val())) {
    filterList();
  }
  $.force_appear();
}

function updateTextInCache(data) {
  listCache.forEach(cacheBlock => {
    const cacheEntry = cacheBlock.entries.find(row => row.target_id === data.target_id);

    if (cacheEntry) {
      cacheEntry.text = data.text;
    }
  });
}
