import delay from 'delay';

$.fn.extend({
  imageEditable() {
    return this.each(function () {
      const $root = $(this);

      // редактирование в мобильной версии
      $('.mobile-edit', $root).on('click', () => {
        $root.toggleClass('mobile-editing');
        return false;
      });

      // удаление
      $('.delete', $root).on('click', () => {
        $root.addClass('deletable');
        return false;
      });

      // отмена удаления
      $('.cancel', $root).on('click', () => {
        $root
          .removeClass('deletable')
          .removeClass('mobile-editing');
        return false;
      });

      // подтверждение удаления
      $('.confirm', $root).on('click', function () {
        if ($(this).data('remote')) {
          $(this).callRemote();
        } else {
          $root
            .removeClass('deletable')
            .addClass('deleted');
        }
        return false;
      });

      // восстановление удалённого
      // $('.restore', $root).on 'click', ->
        // $root.removeClass('deleted')
        // $root.removeClass('mobile-editing')
        // false

      // результат удаления при удалении через аякс-запрос
      $('.confirm', $root).on('ajax:success', async () => {
        $root
          .removeClass('deletable')
          .addClass('deleted');

        const packery = $root.closest('.packery').data('packery');

        if (packery) {
          packery.remove($root[0]);
          await delay(250);
          packery.layout();
        }
      });

      // перемещение влево
      $('.move-left', $root).on('click', () => {
        $root.insertBefore($root.prev());
        return false;
      });

      // перемещение вправо
      return $('.move-right', $root).on('click', () => {
        $root.insertAfter($root.next());
        return false;
      });
    });
  }
});
