// Плагин для отображения слоя в виде модального окна.
//
// Параметры (хеш с полями):
//
//   trigger
//     селектор элементов, по клику на которые будет появляться модальный слой
//   only_show
//     по клику на триггер только отображать слой, скрывать не надо
//   show
//     колбек, который будет вызван по появлению модального слоя
//     (если задан колбек, то появлять слой надо самостоятельно)
//   hide
//     колбек, который будет вызван по скрытию модального слоя
//     (если задан колбек, то скрывать слой надо самостоятельно)
//
// Также плагин триггерит modal:show и modal:hide эвенты
// по появлению и скрытию модального слоя
(function($) {
  let closeModalOnEsc;
  $.fn.extend({
    showModal(options) {
      return this.each(function() {
        const $modal = $(this);
        let hidden = true;

        const showModal = function() {
          const eventName = hidden ? 'modal:show' : 'modal:hide';
          if ((eventName !== 'modal:hide') || !options.only_show) {
            setTimeout(() => $modal.trigger(eventName, [$(this)]));
            return;
          }
        };

        // клик по триггеру модального слоя
        if (options.trigger.constructor === String) {
          $(document).on('click', options.trigger, showModal);
        } else {
          $(options.trigger).on('click', showModal);
        }

        // показ модального слоя
        $modal.on('modal:show', function(e, $trigger) {
          $modal.data({$trigger});

          hidden = false;

          if (options.show) {
            options.show.apply(this, [e, $trigger]);
          } else {
            $modal.show();
          }

          setTimeout(() => {
            $(window).one('click', tryCloseModal.bind(this, $trigger));
            $(window).one('keydown', closeModalOnEsc.bind(this, $trigger));
          });
        });

        // скрытие модального слоя
        $modal.on('modal:do:hide', function(e) {
          $(this).trigger('modal:hide', [$(this).data('$trigger')]);
        });

        // скрытие модального слоя
        $modal.on('modal:hide', function(e, $trigger) {
          hidden = true;

          if (options.hide) {
            options.hide.apply(this, [e, $trigger]);
          } else {
            $modal.hide();
          }
        });
      });
    }
  });

  // закрывалка модального слоя, когда слой видим,
  // и клик приходится не по слою и не по активатору
  var tryCloseModal = function($trigger, e) {
    const $target = $(e.target);

    const isInsideModal = (e.target === this) || $target.closest(this).length;
    if (isInsideModal || !$target.parents('html').length) {
      $(window).one('click', arguments.callee.bind(this, $trigger));
      return;
    }

    $(this).trigger('modal:hide', [$trigger]);
  };

  // закрывалка модального слоя по Esc
  return closeModalOnEsc = function($trigger, e) {
    if (e.keyCode !== 27) {
      $(window).one('keydown', arguments.callee.bind(this, $trigger));
      return;
    }

    $(this).trigger('modal:hide', [$trigger]);
  };
})(jQuery);
