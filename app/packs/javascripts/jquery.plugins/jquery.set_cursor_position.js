$.fn.extend({
  setCursorPosition(pos) {
    const el = $(this).get(0);
    if (!el) { return; }

    let isSelectionDone = false;
    try {
      if (el.setSelectionRange) {
        el.setSelectionRange(pos, pos);
        isSelectionDone = true;
      }
    } catch (error) {}

    if (!isSelectionDone && el.createTextRange) {
      const range = el.createTextRange();
      range.collapse(true);
      range.moveEnd('character', pos);
      range.moveStart('character', pos);
      range.select();
    }
  }
});
