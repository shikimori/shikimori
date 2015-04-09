(($) ->
  resize_binded = false

  handle_resize = ->
    $galleries = $('.align-posters')
    $galleries.find('.image-cutter').css('max-height', '')
    $galleries.align_posters()

  $.fn.extend
    # выравнивание анимешных и манговых постеров по высоте минимального элемента
    align_posters: ->
      @each ->
        $root = $(@)

        unless resize_binded
          $(document).on 'resize:throttled orientationchange', handle_resize
          resize_binded = true

        columns = $root.data 'columns'

        # при разворачивании спойлеров выше, запускаем ресайз
        # хак для корректной работы галерей аниме внутри спойлеров
        unless $root.data('spoiler_binded')
          $root
            .data(spoiler_binded: true)
            .on('spoiler:opened', => $root.align_posters())

        # разбиваем по группам
        $root.children().toArray().inGroupsOf(columns).each (group) ->
          # определяем высоту самого низкого постера
          min_height_node = group.min (node) ->
            $(node).find('.image-cutter').outerHeight()
          min_height = $(min_height_node).find('.image-cutter').outerHeight()

          # и ставим её для всех постеров ряда
          if min_height > 0
            $(group).find('.image-cutter').css 'max-height', min_height

) jQuery
