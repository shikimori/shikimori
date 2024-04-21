import delay from 'delay';
import capitalize from 'lodash/capitalize';
import isEmpty from 'lodash/isEmpty';

const DB_ENTRY_URL_REGEXP =
  /\/(animes|mangas|characters|people|ranobe|clubs|collections)\/[A-z]*(\d+)([\w-]*)/;

const DB_ENTRY_KIND_REPLACEMENTS = {
  animes: { en: 'Anime', ru: 'Аниме' },
  mangas: { en: 'Manga', ru: 'Манга' },
  characters: { en: 'Character', ru: 'Персонаж' },
  people: { en: 'Person', ru: 'Человек' },
  ranobe: { en: 'Ranobe', ru: 'Ранобэ' },
  clubs: { en: 'Club', ru: 'Клуб' },
  collections: { en: 'Collection', ru: 'Коллекция' }
};

function paramToName([_, kind, id, name]) {
  return name
    .split('-')
    .filter(v => !isEmpty(v))
    .map(v => capitalize(v))
    .join(' ') || `${DB_ENTRY_KIND_REPLACEMENTS[kind][window.LOCALE]}#${id}`;
}

const defaultOptions = {
  // autoFill: true,
  // cacheLength: 10,
  cacheLength: 0,
  delay: 10,
  max: 30,

  matchContains: 1,
  matchSubset: 1,
  minChars: 2,
  dataType: 'JSON',

  $anchor: null,
  selectFirst: false
};

$.fn.extend({
  completable(options = { }) {
    return this.each(function() {
      const $node = $(this);

      return $node
        .autocomplete('data-autocomplete', {
          ...defaultOptions,
          formatItem(entry) {
            return entry.label;
          },
          parse(data) {
            $node.trigger('parse');
            return data.reverse();
          },
          ...options
        })
        .on('result', function(e, entry) {
          if (entry) {
            entry.id = entry.data;

            entry.name = entry.value;
            $node.trigger('autocomplete:success', [entry]);
            return;
          }

          if (this.value) {
            const matches = this.value.match(DB_ENTRY_URL_REGEXP);
            if (matches) {
              $node.trigger('autocomplete:success', [{
                url: this.value,
                id: matches[2],
                name: paramToName(matches)
              }]);
              return;
            }
            $node.trigger('autocomplete:text', [this.value]);
          }
        })
        .on('paste', async ({ originalEvent }) => {
          const url = originalEvent.clipboardData.getData('Text');
          const matches = url.match(DB_ENTRY_URL_REGEXP);

          await delay(100);

          if (matches) {
            const id = matches[2];
            const value = paramToName(matches);

            $node.trigger('autocomplete:receiveData', [[{
              data: id,
              label: `<div class='name'>${value}</div>`,
              value,
              url
            }]]);
          }
        });
    });
  },

  completableVariant() {
    return this.each(function() {
      return $(this)
        .completable()
        .on('autocomplete:success', function(e, entry) {
          const $variants = $(this).parent().find('.variants');
          const variantName = $(this).data('variant_name');
          if ($variants.find(`[value="${entry.id}"]`).exists()) { return; }

          $(
            '<div class="variant">' +
              '<input type="checkbox" name="' + variantName + '" value="' + entry.id + '" checked="true" />' +
              '<a class="b-link" href="' + entry.url + '" class="bubbled">' + entry.name + '</a>' +
            '</div>')
            .appendTo($variants)
            .process();

          this.value = '';
        });
    });
  },

  completablePlain() {
    return this.each(function() {
      const $node = $(this);

      return $node
        .autocomplete('data-autocomplete', {
          ...defaultOptions,
          minChars: 1,
          parse(data) { return data.map(value => ({ value })); },
          formatItem(entry) { return entry.value; }
        })
        .on('result', (_e, entry) => {
          if (entry) {
            $node.trigger('autocomplete:text', [entry.value]);
          }
        });
    });
  }
});
