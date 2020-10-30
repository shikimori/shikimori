const DB_ENTRY_URL_REGEXP =
  /\/(?:animes|mangas|characters|people|ranobe|clubs)\/[A-z]*(\d+)([\w-]+)/;

function paramToName(param) {
  return param
    .split('-')
    .filter(v => !Object.isEmpty(v))
    .map(v => v.capitalize())
    .join(' ');
}

const defaultOptions = {
  // autoFill: true,
  cacheLength: 10,
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
    return this.each(function () {
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
        .on('result', function (e, entry) {
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
                id: matches[1],
                name: paramToName(matches[2])
              }]);
              return;
            }
            $node.trigger('autocomplete:text', [this.value]);
          }
        });
    });
  },

  completableVariant() {
    return this.each(function () {
      return $(this)
        .completable()
        .on('autocomplete:success', function (e, entry) {
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
    return this.each(function () {
      const $node = $(this);

      return $node
        .autocomplete('data-autocomplete', {
          ...defaultOptions,
          minChars: 1,
          parse(data) { return data.map(value => ({ value })); },
          formatItem(entry) { return entry.value; },
        })
        .on('result', (_e, entry) => {
          $node.trigger('autocomplete:text', [entry.value]);
        });
    });
  }
});
