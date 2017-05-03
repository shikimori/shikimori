Packery = require 'packery'

(($) ->
  $.fn.extend
    image_editable: ->
      @each ->
        $root = $(@)

        # редактирование в мобильной версии
        $('.mobile-edit', $root).on 'click', ->
          $root.toggleClass('mobile-editing')
          false

        # удаление
        $('.delete', $root).on 'click', ->
          $root.addClass('deletable')
          false

        # отмена удаления
        $('.cancel', $root).on 'click', ->
          $root
            .removeClass('deletable')
            .removeClass('mobile-editing')
          false

        # подтверждение удаления
        $('.confirm', $root).on 'click', ->
          if $(@).data('remote')
            $(@).callRemote()
          else
            $root
              .removeClass('deletable')
              .addClass('deleted')
          false

        # восстановление удалённого
        #$('.restore', $root).on 'click', ->
          #$root.removeClass('deleted')
          #$root.removeClass('mobile-editing')
          #false

        # результат удаления при удалении через аякс-запрос
        $('.confirm', $root).on 'ajax:success', ->
          $root
            .removeClass('deletable')
            .addClass('deleted')

          packery = $root.closest('.packery').data('packery')
          if packery
            packery.remove $root[0]
            delay(250).then -> packery.layout()

        # перемещение влево
        $('.move-left', $root).on 'click', ->
          $root.insertBefore $root.prev()
          $root.removeClass('mobile-editing')
          false

        # перемещение вправо
        $('.move-right', $root).on 'click', ->
          $root.insertAfter $root.next()
          $root.removeClass('mobile-editing')
          false
  ) jQuery
