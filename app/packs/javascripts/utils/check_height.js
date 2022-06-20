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
  const $node = $(node);
  if ($node.hasClass('b-height_shortened')) { return false; }
  if ($node.height() <= options.maxHeight) { return false; }

  const collapsedHeight = options.collapsedHeight ||
    Math.round((options.maxHeight * 2.0) / 3);

  const shadeHtml = options.isNoShade ? '' : '<div class=\'shade\'></div>';
  const placeholderHtml = options.placeholderHeight > 0 ?
    `<div class="placeholder" style="height: ${options.placeholderHeight}px;"></div>` :
    '';
  const expandHtml = (options.expandHtml != null) ?
    options.expandHtml :
    `<div class="expand">${placeholderHtml}<span>` +
      `${I18n.t('frontend.dynamic_elements.check_height.expand')}</span></div>`;

  const marginBottom = parseInt($node.css('margin-bottom'));
  const marginBottomHtml = marginBottom ? ` style="margin-bottom: ${marginBottom}px"` : '';

  const html = '<div class="b-height_shortener"' +
    `${marginBottomHtml}>${shadeHtml}${expandHtml}</div>`;

  $node
    .addClass('b-height_shortened')
    .css({ height: collapsedHeight });

  $(html)
    .insertAfter($node)
    .on('click', e => {
      if ((expandHtml != null) && !expandHtml) { return; }

      $node.removeClass('b-height_shortened');
      animatedExpand($node[0]);

      $(e.currentTarget).remove();
    });

  return true;
}
