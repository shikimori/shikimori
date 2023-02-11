import delay from 'delay';
import { bind } from 'shiki-decorators';

import ShikiView from '@/views/application/shiki_view';
import BanForm from '@/views/application/ban_form';

export default class LogEntry extends ShikiView {
  initialize() {
    this.$inner = this.$node;
    this.$moderation = this.$('.moderation');

    this.$('.reject[data-reason-prompt]', this.$moderation)
      .on('click', this._rejectDialog);

    this.$('.ajax-action', this.$moderation)
      .on('ajax:before', this._shade)
      .on('ajax:complete', this._unshade)
      .on('ajax:success', this._reload);

    this.$('.delete', this.$moderation)
      .on('ajax:before', this._shade)
      .on('ajax:success', this._remove);

    this.$('.ban, .warn', this.$moderation)
      .on('ajax:before', this._prepareForm)
      .on('ajax:before', this._shade)
      .on('ajax:complete', this._unshade)
      .on('ajax:success', this._showForm);

    this.$root.children('.spoiler.collapse').one('click', this._processDiffs);
  }

  @bind
  _prepareForm() {
    this.$moderation.hide();
    this.$('.spoiler.collapse .action').hide();
  }

  @bind
  _showForm(e, html) {
    const $form = this.$('.ban-form');
    $form.html(html).show();

    new BanForm($form);

    if ($(e.target).hasClass('warn')) {
      $form.find('#ban_duration').val('0m');

      if (this.$root.find('.b-spoiler_marker').length) {
        $form.find('#ban_reason').val('спойлеры');
      }
    }

    // закрытие формы бана
    $('.cancel', $form).on('click', this._hideForm);

    // сабмит формы бана пользователю
    $form
      .on('ajax:before', this._shade)
      .on('ajax:complete', this._unshade)
      .on('ajax:success', this._reload);
  }

  @bind
  _hideForm() {
    this.$moderation.show();
    this.$('.spoiler.collapse .action').show();
    this.$('.ban-form').hide().empty();
    this.$('.spoiler.collapse').click();
  }

  @bind
  async _remove() {
    this.$root.hide();
    await delay(10000);

    // remove must be called later becase
    // "b-tooltipped" tooltip wont disappear otherwise
    this.$root.remove();
  }

  @bind
  _rejectDialog(e) {
    const href = $(e.target).data('href');
    const reason = prompt($(e.target).data('reason-prompt'));

    if (reason == null) {
      e.preventDefault();
      e.stopImmediatePropagation();
      return;
    }

    $(e.target).attr('href', `${href}?reason=${encodeURIComponent(reason)}`);
  }

  @bind
  _processDiffs() {
    this.$('.field-changes .diff').each(async (_index, node) => {
      const $diff = $(node);
      const { default: DiffMatchPatch } =
        await import(/* webpackChunkName: "diff-match-patch" */ 'diff-match-patch');

      const $diffValue = $diff.find('.value');
      const oldValue = $diffValue.data('old_value');
      const newValue = $diffValue.data('new_value');

      const dmp = new DiffMatchPatch();
      const diff = dmp.diff_main(
        Object.isString(oldValue) ? oldValue : JSON.stringify(oldValue),
        Object.isString(newValue) ? newValue : JSON.stringify(newValue)
      );

      // dmp.Diff_EditCost = 4;
      // dmp.diff_cleanupEfficiency(diff);
      dmp.diff_cleanupSemantic(diff);

      $diffValue.html(
        dmp.diff_prettyHtml(diff).replace(/&para;/g, '')
      );
    });

    const $externalLinks = this.$('.field-changes.external_links');
    if (!$externalLinks.length) { return; }

    this._processExternalLinks($externalLinks);
  }

  _processExternalLinks($externalLinks) {
    $externalLinks.each((_index, node) => {
      prepareLinks(node).forEach(link => {
        link.node.classList.add(link.state);
      });
    });
  }
}

// https://greasyfork.org/ru/scripts/445617-shiki-links-comparator/code
// Возвращает массив ссылок из элемента .change
function getLinks(block) {
  let links = Array.from( block.getElementsByClassName('b-external_link') );
  return links.map(link => {
    let url = new URL( link.getElementsByTagName('a')[0].href );
    return {
      url: url.href,
      host: url.host,
      path: url.href.replace(url.origin, ''),
      kind: link.classList[1],
      node: link.getElementsByClassName('url')[0]
    }
  });
}

// Возвращает массив уникальных элементов main_arr, при сравнении с add_arr
function getUniqueElements(main_arr, add_arr) {
  return main_arr.filter(el1 => !add_arr.find(el2 => el1.url === el2.url && el1.kind === el2.kind));
}

// Возвращает похожую на link ссылку из array
function getSimilarLink(link, array) {
  return array.find(l => {
    // Если отличается только kind
    if (link.url === l.url) return true;

    // Если совпадает host или kind и при этом pathname одной ссылки содержит pathname другой
    // P.S. Сомнительное решение, возможно, стоит подумать над другим
    if (link.host === l.host || link.kind === l.kind) {
      if ( link.path.includes(l.path) ) return true;
      if ( l.path.includes(link.path) ) return true;
    }

    return false;
  });
}

// Возвращает массив main_arr со state, определённым как add, mod или del
function organizeLinks(main_arr, add_arr, alt_state) {
  return main_arr.map(link => {
    if ( link.url.includes('/NONE') ?? alt_state === 'ins' ) {
      link.state = 'del';
      return link;
    }

    let similar_link = getSimilarLink(link, add_arr);
    link.state = similar_link ? 'mod' : alt_state;
    return link;
  });
}

function prepareLinks(changes_block) {
  let links_container = changes_block.getElementsByClassName('change');
  let before = getLinks(links_container[0]);
  let after = getLinks(links_container[1]);

  let before_unique = getUniqueElements(before, after);
  let after_unique = getUniqueElements(after, before);

  let before_prepared = organizeLinks(before_unique, after_unique, 'del');
  let after_prepared = organizeLinks(after_unique, before_unique, 'ins');

  return before_prepared.concat(after_prepared);
}

