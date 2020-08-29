$.fn.extend({
  rateable() {
    return this.each(function() {
      const $stars = $('.stars-container', this);
      const $hover = $('.hover', this);
      const $hoverableTrigger = $('.hoverable-trigger', this);

      const $score = $('.score', this);
      const $scoreValue = $('.score-value', this);
      const $scoreNotice = $('.score-notice', this);

      const notices = $(this).data('notices');
      const inputSelector = $(this).data('input_selector');
      const isWithInput = !!inputSelector;

      let scoreInitial = parseInt($scoreValue.text()) || 0;
      let scoreNew = null;

      $hoverableTrigger
        .on('mousemove', e => {
          const offset = $(e.target).offset().left;
          const scoreRaw = ((e.clientX - offset) * 10.0) / $stars.width();
          scoreNew = scoreRaw > 0.5 ? [Math.floor(scoreRaw) + 1, 10].min() : 0;

          $scoreNotice
            .html(notices[scoreNew] || '&nbsp;');
          $hover
            .attr('class', `${withoutScore($hover)} score-${scoreNew}`);
          $scoreValue
            .html(scoreNew)
            .attr('class', `${withoutScore($scoreValue)} score-${scoreNew}`);
        })
        .on('mouseover', _e => {
          $score.addClass('hovered');
        })
        .on('mouseout', _e => {
          $score.removeClass('hovered');
          $scoreNotice
            .html(notices[scoreInitial] || '&nbsp;');
          $hover
            .attr('class', withoutScore($hover));
          $score
            .attr('class', `${withoutScore($score)} score-${scoreInitial}`);
          $scoreValue
            .attr('class', `${withoutScore($scoreValue)} score-${scoreInitial}`)
            .html(scoreInitial);
        })
        .on('click', ({ currentTarget }) => {
          if (isWithInput) {
            scoreInitial = scoreNew;
            $(currentTarget).trigger('mouseout');
            $(currentTarget).closest('form').find(inputSelector).val(scoreNew);
          }

          $(currentTarget).trigger('rate:change', scoreNew);
        });
    });
  }
});

function withoutScore($node) {
  return $node.attr('class').replace(/\s?score-\d+/, '');
}
