(($) ->
  build_gallery = ->
    item = @items[@index]
    if item.rel && @items.length == 1
      @items = $("a[rel='#{item.rel}']").toArray()
      @index = @items.indexOf(item)

  $.fn.extend
    magnific_rel_gallery: ->
      @each ->
        $node = $(@)
        unless $node.data('magnificPopup')
          $node.magnificPopup
            type: 'image'
            closeOnContentClick: true

            gallery:
              enabled: true
              navigateByImgClick: true
              preload: [0,1]

            callbacks:
              beforeOpen: build_gallery

            mainClass: 'mfp-no-margins mfp-img-mobile'
            #mainClass: 'mfp-with-zoom'
            #zoom:
              #enabled: true
              #duration: 300
              #easing: 'ease-in-out'
              #opener: (openerElement) ->
                #if openerElement.is('img') then openerElement else openerElement.find('img')
) jQuery
