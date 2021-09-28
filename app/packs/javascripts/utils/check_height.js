import { animatedExpand } from './animated';

export default function checkHeight(
  node,
  options = {
    maxHeight: 450,
    isNoShade: false,
    collapsedHeight: null,
    placeholderHeight: 0
  }
) {
  const collapsedHeight = options.collapsedHeight ||
    Math.round((options.maxHeight * 2.0) / 3);

  const shadeHtml = options.isNoShade ? '' : '<div class=\'shade\'></div>';
  const placeholderHtml = options.placeholderHeight > 0 ?
    `<div class='placeholder' style='height: ${options.placeholderHeight}px;'></div>` :
    '';
  const expandHtml = (options.expandHtml != null) ?
    options.expandHtml :
    `<div class='expand'>${placeholderHtml}<span>` +
      `${I18n.t('frontend.dynamic_elements.check_height.expand')}</span></div>`;

  const $node = $(node);

  if (($node.height() > options.maxHeight) && !$node.hasClass('shortened')) {
    const marginBottom = parseInt($node.css('margin-bottom'));
    const html = '<div class=\'b-height_shortener\' ' +
      `style='margin-bottom: ${marginBottom}px'>${shadeHtml}${expandHtml}</div>`;

    $node
      .addClass('shortened')
      .css({ height: collapsedHeight });

    $(html)
      .insertAfter($node)
      .on('click', e => {
        if ((expandHtml != null) && !expandHtml) { return; }

        $node.removeClass('shortened');
        animatedExpand($node[0]);

        $(e.currentTarget).remove();
      });
  }
}

