build_gallery = ->
  item = @items[@index]
  if item.rel && @items.length == 1
    @items = $("a[rel='#{item.rel}']").toArray()
    @index = @items.indexOf(item)

# ссылки на camo в href содержат оригинальный url картинки,
# а в data-href проксированный url картинки
extract_url = (item) ->
  item.src = item.el.data('href') || item.src

$.fn.extend
  magnificRelGallery: ->
    @each ->
      $node = $(@)
      unless $node.data('magnificPopup')
        $node.magnificPopup
          type: 'image'
          closeOnContentClick: true
          # closeBtnInside: false

          gallery:
            enabled: true
            navigateByImgClick: true
            preload: [0, 1]

          callbacks:
            beforeOpen: build_gallery
            elementParse: extract_url

          mainClass: 'mfp-no-margins mfp-img-mobile'
          #mainClass: 'mfp-with-zoom'
          #zoom:
            #enabled: true
            #duration: 300
            #easing: 'ease-in-out'
            #opener: (openerElement) ->
              #if openerElement.is('img') then openerElement else openerElement.find('img')
