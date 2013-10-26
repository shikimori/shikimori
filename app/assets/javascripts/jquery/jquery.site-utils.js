(function($){
  $.fn.extend({
    defaultText: function(text) {
      return this.each(function() {
        $(this).bind('blur', function() {
          if (this.value == '') {
            this.value = text;
          }
        }).bind('focus', function() {
          if (this.value == text) {
            this.value = '';
          }
        }).trigger('blur');
      });
    }
  });

  $.fn.tagName = function() {
    return this.get(0).tagName.toLowerCase();
  }

  $.extend({
    getSelectionText: function() {
      if (window.getSelection) {
        selectionTxt = window.getSelection();
      }
      else if (document.getSelection) {
        selectionTxt = document.getSelection();
      }
      else if (document.selection) {
        selectionTxt = document.selection.createRange().text;
      }

      return (selectionTxt.toString() || '').trim();
    }
  });
})(jQuery);
