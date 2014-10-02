(function($){
  $.fn.extend({
    completable: function(default_text, success_callback, $anchor) {
      return this.each(function() {
        var $element = $(this);
        if (default_text) {
          $element.defaultText(default_text);
        }

        $element.on('result', success_callback); //TODO: deprecated. удалить.
        $element.on('result', function(e, id, text, label) {
          $element.trigger('autocomplete:success', [id, text, label]);
        });

        $element.autocomplete('data-autocomplete', {
          //autoFill: true,
          cacheLength: 10,
          delay: 10,
          formatItem: function(entry) {
            return entry.label;
          },
          matchContains: 1,
          matchSubset: 1,
          minChars: 2,
          dataType: 'JSON',
          parse: function(data) {
            $element.trigger('parse');
            return data.reverse();
          },
          $anchor: $anchor,
          selectFirst: false
        });
      });
    }
  });
})(jQuery);
