import delay from 'delay';

$.fn.extend({
  imageEditable() {
    return this.each(function () {
      const $node = $(this);

      if ($node.data('imageEditable')) { return; }
      $node.data('imageEditable', true);

      // редактирование в мобильной версии
      $('.mobile-edit', $node).on('click', () => {
        $node.toggleClass('mobile-editing');
        return false;
      });

      // удаление
      $('.delete', $node).on('click', () => {
        $node.addClass('deletable');
        return false;
      });

      // отмена удаления
      $('.cancel', $node).on('click', () => {
        $node
          .removeClass('deletable')
          .removeClass('mobile-editing');
        return false;
      });

      // подтверждение удаления
      $('.confirm', $node).on('click', function () {
        if ($(this).data('remote')) {
          $(this).callRemote();
        } else {
          $node
            .removeClass('deletable')
            .addClass('deleted');
        }
        return false;
      });

      // восстановление удалённого
      // $('.restore', $node).on 'click', ->
        // $node.removeClass('deleted')
        // $node.removeClass('mobile-editing')
        // false

      // результат удаления при удалении через аякс-запрос
      $('.confirm', $node).on('ajax:before', async () => {
        $node
          .removeClass('deletable')
          .addClass('deleted');

        const packery = $node.closest('.packery').data('packery');

        if (packery) {
          packery.remove($node[0]);
          await delay(250);
          packery.layout();
        }
      });

      // перемещение влево
      $('.move-left', $node).on('click', () => {
        $node.insertBefore($node.prev());
        return false;
      });

      // перемещение вправо
      $('.move-right', $node).on('click', () => {
        $node.insertAfter($node.next());
        return false;
      });
    });
  }
});
