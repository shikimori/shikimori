(($) ->
  $.fn.extend
    shiki_image: ->
      @each ->
        $root = $(@)
        $root.fancybox($.galleryOptions)

        $('.delete', $root).on 'click', ->
          $root.addClass('deletable')
          false

        $('.cancel', $root).on 'click', ->
          $root.removeClass('deletable')
          false

        $('.confirm', $root).on 'click', ->
          $(@).callRemote()
          false

        $('.confirm', $root).on 'ajax:success', ->
          $packery = $root.closest('.packery')
          $packery.packery('remove', $root)
          $packery.packery.bind($packery).delay(250)

) jQuery
