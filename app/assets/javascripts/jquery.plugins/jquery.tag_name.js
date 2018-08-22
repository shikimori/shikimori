$.fn.extend({
  tagName() {
    return this.get(0).tagName.toLowerCase();
  }
});
