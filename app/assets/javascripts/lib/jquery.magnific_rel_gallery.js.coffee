(($) ->
  $.fn.extend
    magnific_rel_gallery: ->
      @each ->
        $(@).magnificPopup
          type: 'image'
          closeOnContentClick: true

          gallery:
            enabled: true

          callbacks:
            beforeOpen: ->
              item = @items[@index]
              if item.rel && @items.length == 1
                @items = $("a[rel='#{item.rel}']").toArray()
                @index = @items.indexOf(item)

          mainClass: 'mfp-no-margins mfp-with-zoom'
          zoom:
            enabled: true
            duration: 300
            easing: 'ease-in-out'
            opener: (openerElement) ->
              if openerElement.is('img') then openerElement else openerElement.find('img')
) jQuery
