/**
 * @file
 * <p>tipsy, facebook style tooltips for jquery.</p>
 * <p>Forked and updated from original.</p>
 *
 * @see {@link https://github.com/Rykus0/tipsy}
 * @version 1.0.0b
 * @author Jason Frame <jason@onehackoranother.com>
 * @copyright 2008-2010 Jason Frame <jason@onehackoranother.com>
 * @license MIT
 * https://github.com/jaz303/tipsy
 */

(function($) {

    function maybeCall(thing, ctx) {
        return (typeof thing === 'function') ? (thing.call(ctx)) : thing;
    };

    function isElementInDOM(ele) {
      while (ele = ele.parentNode) {
        if (ele === document) return true;
      }
      return false;
    };

    function Tipsy(element, options) {
        this.$element = $(element);
        this.options = options;
        this.enabled = true;
        this.fixTitle();
    };

    Tipsy.prototype = {
        show: function() {
            var title = this.getTitle();
            var me    = this;

            var calculatePosition = function(self){
                var tp;
                // var pos = self.$element[0].getBoundingClientRect();
                var pos = $.extend({}, self.$element.offset(), {
                    width: self.$element[0].offsetWidth,
                    height: self.$element[0].offsetHeight
                });

                var actualWidth  = $tip[0].offsetWidth;
                var actualHeight = $tip[0].offsetHeight;

                switch (gravity.charAt(0)) {
                    case 'n':
                        tp = {top: pos.top + pos.height + self.options.offset, left: pos.left + pos.width / 2 - actualWidth / 2};
                        break;
                    case 's':
                        tp = {top: pos.top - actualHeight - self.options.offset, left: pos.left + pos.width / 2 - actualWidth / 2};
                        break;
                    case 'e':
                        tp = {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left - actualWidth - self.options.offset};
                        break;
                    case 'w':
                        tp = {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left + pos.width + self.options.offset};
                        break;
                }

                if (gravity.length === 2) {
                    if (gravity.charAt(1) === 'a') {
                        var autoDir = '';
                        if (tp.left < 0) {
                            autoDir = 'w';
                        } else if ( tp.left + actualWidth > $(window).width() + $(document).scrollLeft() ) {
                            autoDir = 'e';
                        }
                        gravity = gravity.charAt(0) + autoDir;
                    }

                    // NOTE: 15 here corresponds to 3 * arrow size (border-width on the arrow in CSS)
                    // Or more accurately, outer padding + (2 * arrow size)
                    if (gravity.charAt(1) === 'w') {
                        tp.left = pos.left + pos.width / 2 - 15;
                    } else if (gravity.charAt(1) === 'e') {
                        tp.left = pos.left + pos.width / 2 - actualWidth + 15;
                    }
                }

                // If the tooltip is kicked off the left of the screen, it won't resize automatically.
                if( tp.left < 0 ){
                    // TODO: '15' is for the arrow... put this in a variable/calculation
                    // reduce width by amount offscreen. remember: tp.left is negative
                    tp.width = actualWidth + tp.left - self.options.offset - 15;
                    tp.left  = 0;
                }

                return tp;
            };

            if (title && this.enabled) {
                var $tip = this.tip();
                var gravity = maybeCall(this.options.gravity, this.$element[0]);

                $tip.find('.tipsy-inner')[this.options.html ? 'html' : 'text'](title);
                $tip[0].className = 'tipsy'; // reset classname in case of dynamic gravity
                $tip.remove().css({top: 0, left: 0, visibility: 'hidden', display: 'block'}).prependTo(document.body);

                if (this.options.className) {
                    $tip.addClass(maybeCall(this.options.className, this.$element[0]));
                }

                // If there are any images, adjust position after they load
                $tip.find('.tipsy-inner img').on('load', function(){
                    $tip.css(calculatePosition(me));
                })

                // Need to recalculate once it is in position because dimensions may have changed
                $tip.css(calculatePosition(this)).css(calculatePosition(this)).addClass('tipsy-' + gravity);
                $tip.find('.tipsy-arrow')[0].className = 'tipsy-arrow tipsy-arrow-' + gravity.charAt(0);

                if (this.options.fade) {
                    $tip.stop().css({opacity: 0, display: 'block', visibility: 'visible'}).animate({opacity: this.options.opacity});
                } else {
                    $tip.css({visibility: 'visible', opacity: this.options.opacity});
                }
            }
        },

        hide: function() {
            if (this.options.fade) {
                this.tip().stop().fadeOut(function() { $(this).remove(); });
            } else {
                this.tip().remove();
            }
        },

        fixTitle: function() {
            var $e = this.$element;
            var id = maybeCall(this.options.id, this.$element[0]);

            // Remove title attribute to prevent system tooltips and store value in data-title
            if ($e.attr('title') || typeof($e.attr('data-title')) !== 'string') {
                $e.attr('data-title', $e.attr('title') || '').removeAttr('title');
            }

            // add aria-describedby pointing to the tooltip's id
            $e.attr('aria-describedby', id);

            // if it doesn't already have a tabindex, force the trigger element into the tab cycle
            // to make it keyboard accessible with tabindex=0. this automatically makes elements
            // that are not normally keyboard accessible (div or span) that have been tipsy-fied
            // also operable with the keyboard.
            if ($e.attr('tabindex') === undefined) {
                $e.attr('tabindex', 0);
            }
        },

        getTitle: function() {
            var title;
            var $e = this.$element;
            var o  = this.options;

            this.fixTitle();

            if (typeof o.title === 'string') {
                title = $e.attr(o.title === 'title' ? 'data-title' : o.title);
            } else if (typeof o.title === 'function') {
                title = o.title.call($e[0]);
            }

            title = ('' + title).replace(/(^\s*|\s*$)/, "");

            return title || o.fallback;
        },

        tip: function() {
            var id = maybeCall(this.options.id, this.$element[0]);

            if (!this.$tip) {
                // generate tooltip, with appropriate ARIA role and an 'id' (can be set in options),
                // so it can be targetted by aria-describedby in the trigger element
                this.$tip = $('<div class="tipsy" id="'+id+'" role="tooltip"></div>').html('<div class="tipsy-arrow"></div><div class="tipsy-inner"></div>');
                this.$tip.data('tipsy-pointee', this.$element[0]);
            }
            return this.$tip;
        },

        validate: function() {
            if (!this.$element[0].parentNode) {
                this.hide();
                this.$element = null;
                this.options = null;
            }
        },

        enable: function() { this.enabled = true; },
        disable: function() { this.enabled = false; },
        toggleEnabled: function() { this.enabled = !this.enabled; }
    };

    /**
     * @memberof jQuery
     * @alias tipsy
     */
    $.fn.tipsy = function(options) {
        var $this = this;

        if (options === true) {
            return this.data('tipsy');
        } else if (typeof options === 'string') {
            var tipsy = this.data('tipsy');
            if (tipsy) tipsy[options]();
            return this;
        }

        options = $.extend({}, $.fn.tipsy.defaults, options);

        function get(ele) {
            var tipsy = $.data(ele, 'tipsy');
            if (!tipsy) {
                tipsy = new Tipsy(ele, $.fn.tipsy.elementOptions(ele, options));
                $.data(ele, 'tipsy', tipsy);
            }
            return tipsy;
        }

        function enter(e) {
            var tipsy = get(this);

            leaveAll(); // Close all other open tooltips first

            e.stopPropagation();

            tipsy.hoverState = 'in';

            if (options.delayIn === 0) {
                tipsy.show();
            } else {
                tipsy.fixTitle();
                setTimeout(function() { if (tipsy.hoverState === 'in') tipsy.show(); }, options.delayIn);
            }
        }

        function leave() {
            var tipsy = get(this);

            tipsy.hoverState = 'out';

            if (options.delayOut === 0) {
                tipsy.hide();
            } else {
                setTimeout(function() { if (tipsy.hoverState === 'out') tipsy.hide(); }, options.delayOut);
            }
        }

        function leaveAll(){
            $this.each(function(){
                leave.call(this);
            });
        }

        // Initialize any on-page tooltips
        // Tooltips added later (options.live) will be initialized on first activation
        this.each(function(){
            get(this);
        });

        if (options.trigger !== 'manual') {
            var eventIn  = 'touchstart focus';
            var eventOut = 'touchmove touchcancel blur';

            if (options.trigger !== 'focus') {
                eventIn  += ' mouseenter';
                eventOut += ' mouseleave';
            }

            if (options.live) {
              $(this.context).on(eventIn, this.selector, enter).on(eventOut, this.selector, leave);
            } else {
              this.on(eventIn, enter).on(eventOut, leave);
            }

            $(this.context).on('touchstart orientationchange', leaveAll);
            $('*').on('scroll', leaveAll);
        }

        return this;

    };

    $.fn.tipsy.defaults = {
        className: null,
        id: 'tipsy',
        delayIn: 0,
        delayOut: 0,
        fade: false,
        fallback: '',
        gravity: 'n',
        html: false,
        live: false,
        offset: 0,
        opacity: 1,
        title: 'title',
        trigger: 'interactive'
    };

    $.fn.tipsy.revalidate = function() {
      $('.tipsy').each(function() {
        var pointee = $.data(this, 'tipsy-pointee');
        if (!pointee || !isElementInDOM(pointee)) {
          $(this).remove();
        }
      });
    };

    /**
     * Overwrite this method to provide options on a per-element basis.
     * For example, you could store the gravity in a 'tipsy-gravity' attribute:
     * return $.extend({}, options, {gravity: $(ele).attr('tipsy-gravity') || 'n' });
     * (remember - do not modify 'options' in place!)
     */
    $.fn.tipsy.elementOptions = function(ele, options) {
        return $.metadata ? $.extend({}, options, $(ele).metadata()) : options;
    };

    $.fn.tipsy.autoNS = function() {
        return $(this).offset().top > ($(document).scrollTop() + $(window).height() / 2) ? 's' : 'n';
    };

    $.fn.tipsy.autoWE = function() {
        return $(this).offset().left > ($(document).scrollLeft() + $(window).width() / 2) ? 'e' : 'w';
    };

    /**
     * yields a closure of the supplied parameters, producing a function that takes
     * no arguments and is suitable for use as an autogravity function like so:
     *
     * @param margin (int) - distance from the viewable region edge that an
     *        element should be before setting its tooltip's gravity to be away
     *        from that edge.
     * @param prefer (string, e.g. 'n', 'sw', 'w') - the direction to prefer
     *        if there are no viewable region edges effecting the tooltip's
     *        gravity. It will try to vary from this minimally, for example,
     *        if 'sw' is preferred and an element is near the right viewable
     *        region edge, but not the top edge, it will set the gravity for
     *        that element's tooltip to be 'se', preserving the southern
     *        component.
     */
     $.fn.tipsy.autoBounds = function(margin, prefer) {
        return function() {
            var dir = {ns: prefer[0], ew: (prefer.length > 1 ? prefer[1] : false)},
                boundTop = $(document).scrollTop() + margin,
                boundLeft = $(document).scrollLeft() + margin,
                $this = $(this);

            if ($this.offset().top < boundTop) dir.ns = 'n';
            if ($this.offset().left < boundLeft) dir.ew = 'w';
            if ($(window).width() + $(document).scrollLeft() - $this.offset().left < margin) dir.ew = 'e';
            if ($(window).height() + $(document).scrollTop() - $this.offset().top < margin) dir.ns = 's';

            return dir.ns + (dir.ew ? dir.ew : '');
        }
    };

})(jQuery);
