$.fn.extend({
  view(value) {
    if (value) {
      return this.data('view_object', value);
    }

    return this.data('view_object');
  }
});
