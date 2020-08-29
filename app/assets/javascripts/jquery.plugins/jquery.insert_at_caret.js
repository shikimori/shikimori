$.fn.extend({
  insertAtCaret(prefix, postfix, filler) {
    return this.each(function() {
      if (document.selection) {
        this.focus();
        const sel = document.selection.createRange();
        sel.text = prefix +
          (((sel.text === '') && filler ? filler : sel.text)) +
          postfix;
        this.focus();
      } else if (
        this.selectionStart ||
        (this.selectionStart === '0') ||
        (this.selectionStart === 0)
      ) {
        const startPos = this.selectionStart;
        const endPos = this.selectionEnd;
        const {
          scrollTop
        } = this;
        let selectedText = this.value.substring(startPos, endPos);
        selectedText = ((selectedText === '') && filler ? filler : selectedText);
        this.value = this.value.substring(0, startPos) +
          prefix + selectedText + postfix +
          this.value.substring(endPos, this.value.length);
        this.focus();
        this.selectionEnd = startPos + prefix.length + selectedText.length + postfix.length;
        this.selectionStart = this.selectionEnd;
        this.scrollTop = scrollTop;
      } else {
        this.value += prefix + postfix;
        this.focus();
      }
      $(this).trigger('change');
    });
  }
});
