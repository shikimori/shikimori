import TinyUri from 'tiny-uri';

const TOOLTIP_TEMPLATE = `<div> \
  <div class='tooltip-inner'> \
    <div class='tooltip-arrow'></div> \
    <div class='clearfix'> \
      <div class='close'></div> \
      <div class='tooltip-details'> \
      <div class='ajax-loading' title='${I18n.t('frontend.blocks.tooltip.loading')}' /> \
      </div> \
    </div> \
    <div class='dropshadow-top'></div> \
    <div class='dropshadow-top-right'></div> \
    <div class='dropshadow-right'></div> \
    <div class='dropshadow-bottom-right'></div> \
    <div class='dropshadow-bottom'></div> \
    <div class='dropshadow-bottom-left'></div> \
    <div class='dropshadow-left'></div> \
    <div class='dropshadow-top-left'></div> \
  </div> \
</div>`;

export const COMMON_TOOLTIP_OPTIONS = {
  delay: 150,
  predelay: 250,
  position: 'top right',
  defaultTemplate: TOOLTIP_TEMPLATE,
  onBeforeShow() {
    const $trigger = this.getTrigger();

    // удаляем тултипы у всего внутри
    $trigger.find('[title]').attr({ title: '' });

    const $close = this.getTip().find('.close');
    if (!$close.data('binded')) {
      $close
        .data({ binded: true })
        .on('click', () => this.hide());

      const url = ($trigger.data('href') || $trigger.attr('href') || '')
        .replace(/\/tooltip/, '');

      if (url) {
        this.getTip().find('.link').attr({ href: url });
      }
      if (url.match(/\/genres\//)) {
        this.getTip().find('.link').hide();
      }
    }
  }
};

export const ANIME_TOOLTIP_OPTIONS = {
  ...COMMON_TOOLTIP_OPTIONS,
  offset: [-4, 10, -10],
  position: 'top right',
  predelay: 350,
  ignoreSelector: '.text',
  onBeforeFetch() {
    // добавляем к ссылке minified, если у $trigger нет собственной картинки
    const $trigger = this.getTrigger();
    const $image = $trigger.find('.image-decor img');

    if ($image.exists() && ($image.width() >= 110)) {
      const minifiedTooltipUrl =
        new TinyUri($trigger.data('tooltip_url'))
          .query.set('minified', '1')
          .toString();

      $trigger.data('tooltip_url', minifiedTooltipUrl);

      this.getTip().addClass('minified');
    }
  },
  // fix stale tooltips in case new page is loaded with turbolinks
  onShow() {
    const tooltipPosition = this.getTip().position();

    if (tooltipPosition.top < 20 && tooltipPosition.left < 20) {
      this.getTip().remove();
    }
  }
};
