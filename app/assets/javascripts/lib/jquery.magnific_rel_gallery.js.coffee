(($) ->
  $.fn.extend
    magnific_rel_gallery: ->
      @each ->
        $(@).magnificPopup
          type: 'image'
          gallery:
            enabled: true
          callbacks:
            beforeOpen: ->
              item = @items[@index]
              if item.rel && @items.length == 1
                @items = $("a[rel='#{item.rel}']").toArray()
                @index = @items.indexOf(item)

                #@items.each (item,index) =>
                  #@parseEl index
) jQuery
