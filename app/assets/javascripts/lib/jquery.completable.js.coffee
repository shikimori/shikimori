(($) ->
  $.fn.extend completable: (default_text, success_callback, $anchor) ->
    @each ->
      $element = $(@)
      if default_text
        $element.defaultText default_text

      $element
        .on 'result', (e, entry) ->
          if entry
            entry.id = entry.data
            entry.name = entry.value
            $element.trigger 'autocomplete:success', [entry]

        .autocomplete 'data-autocomplete',
          #autoFill: true,
          cacheLength: 10
          delay: 10
          formatItem: (entry) ->
            entry.label

          matchContains: 1
          matchSubset: 1
          minChars: 2
          dataType: 'JSON'
          parse: (data) ->
            $element.trigger 'parse'
            data.reverse()

          $anchor: $anchor
          selectFirst: false

) jQuery
