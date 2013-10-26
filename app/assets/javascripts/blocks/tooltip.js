$.tools.tooltip.addEffect("opacity",
  function(done) { // opening animation
    this.getTip().css('opacity', 0).show();
    this.getTip().animate({opacity: 1, top: '-=14'}, 500, 'easeOutCirc', done).show();
  },
  function(done) { // closing animation
    this.getTip().animate({opacity: 0, top: '+=14'}, 250, 'easeInCirc', function()  {
      $(this).hide();
      done.call();
    });
  }
);
var tooltip_options = {
  effect: 'opacity',
  delay: 150,
  predelay: 250,
  position: 'top right',
  defaultTemplate: TOOLTIP_TEMPLATE,
  onBeforeShow: function() {
    this.getTrigger().animate({opacity: 0.6}, 100);
  },
  onBeforeHide: function() {
    this.getTrigger().stop();
    this.getTrigger().animate({opacity: 1}, 100);
  }
};
