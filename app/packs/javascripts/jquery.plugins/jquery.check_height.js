import { animatedExpand } from '@/helpers/animated';

$.fn.extend({
  // options:
  //   maxHeight - высота блока, при превышении которой будет свёртка
  //   withoutShade - добавлять ли тень
  //   collapsedHeight - высота свёрнутого блока
  //   expandHtml - html для блока "развернуть"
  checkHeight(options = {}) {
    const maxHeight = options.maxHeight || 450;
    const withoutShade = (options.withoutShade != null) ? options.withoutShade : false;
    const collapsedHeight = options.collapsedHeight || Math.round((maxHeight * 2.0) / 3);
    const shadeHtml = withoutShade ? '' : '<div class=\'shade\'></div>';
    const expandHtml = (options.expandHtml != null) ?
      options.expandHtml :
      '<div class=\'expand\'><span>' +
        `${I18n.t('frontend.dynamic_elements.check_height.expand')}</span></div>`;

    return this.each(function() {
      const $root = $(this);

      if (($root.height() > maxHeight) && !$root.hasClass('shortened')) {
        const marginBottom = parseInt($root.css('margin-bottom'));
        const html = '<div class=\'b-height_shortener\' ' +
          `style='margin-bottom: ${marginBottom}px'>${shadeHtml}${expandHtml}</div>`;

        $root
          .addClass('shortened')
          .css({ height: collapsedHeight });

        $(html)
          .insertAfter($root)
          .on('click', e => {
            if ((expandHtml != null) && !expandHtml) { return; }

            $root.removeClass('shortened');
            animatedExpand($root[0]);

            $(e.currentTarget).remove();
          });
      }
    });
  }
});
