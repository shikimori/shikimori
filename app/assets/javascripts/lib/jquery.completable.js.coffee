(($) ->
  $.fn.extend
    completable: ($anchor) ->
      @each ->
        $element = $(@)

        $element
          .on 'result', (e, entry) ->
            if entry
              entry.id = entry.data
              entry.name = entry.value
              $element.trigger 'autocomplete:success', [entry]
            else if @value
              $element.trigger 'autocomplete:text', [@value]

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

    completable_variant: ->
      @each ->
        $(@)
          .completable()
          .on 'autocomplete:success', (e, entry) ->
            $variants = $(@).parent().find('.variants')
            variant_name = $(@).data('variant_name')
            return if $variants.find("[value=\"#{entry.id}\"]").exists()

            $entry = $(
              '<div class="variant">' +
                '<input type="checkbox" name="'+variant_name+'" value="'+entry.id+'" checked="true" />' +
                '<a class="b-link" href="'+entry.url+'" class="bubbled">'+entry.name+'</a>' +
              '</div>')
              .appendTo($variants)
              .process()

            @value = ''
) jQuery
