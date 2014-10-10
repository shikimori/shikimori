$(function() {
  var $pagination = $('.pagination.with-cache:first');
  if ($pagination.length) {
    AjaxCacher.enable();
  }
  var links = _.map($pagination.find('.link-next:not(.disabled),.link-prev:not(.disabled)'),
                    function(v,k) {
                      return v.href;
                    });
  for (var i in links) {
    AjaxCacher.cache(links[i]);
  }
});
function page_change(rollback) {
  if (!('$input' in arguments.callee && arguments.callee.$input)) {
    return;
  }
  var $input = arguments.callee.$input;
  var value = $input.attr('value');
  if (rollback != true && value == parseInt(value) && value != arguments.callee.prior_value && parseInt(value) <= arguments.callee.total_value) {
    var $link = $('.link-next:not(.disabled),.link-prev:not(.disabled)');
    $link.attr('href', $link.attr('href').replace(/\/\d+$/, '/'+value));
    $link.first().trigger('click');
    $input.parent().html($input.attr('value'));
  } else {
    $input.parent().html(arguments.callee.prior_value);
  }
  arguments.callee.$input = null;
}

$('.no-hover').click(function(e) {
  var $this = $(this).find('.link-current');
  if ($this.has('input').length) {
    return;
  }
  page_change.prior_value = parseInt($this.html());
  page_change.total_value = parseInt($('.link-total').html())

  $this.html('<input type="text" value="'+page_change.prior_value+'"/>');

  page_change.$input = $this.children()
    .bind('blur', page_change)
    .bind('keydown', function(e) {
      if (e.keyCode == 38) {
        this.value = parseInt(this.value) + 1;
      } else if (e.keyCode == 40 && parseInt(this.value) > 1) {
        this.value = parseInt(this.value) - 1;
      } else if (e.keyCode == 27) {
        page_change(true);
      }
    })
    .bind('keypress', function(e) {
      if (e.keyCode == 13) {
        page_change();
      }
    })
    .bind('mousewheel', function(e) {
      if (e.originalEvent.wheelDelta && e.originalEvent.wheelDelta > 0 && parseInt(this.value) < page_change.total_value) {
        this.value = parseInt(this.value) + 1;
      } else if (e.originalEvent.wheelDelta && parseInt(this.value) > 1) {
        this.value = parseInt(this.value) - 1;
      }
      return false;
    })
    .focus();
});
$('.pagination').hover(function() {}, page_change);
