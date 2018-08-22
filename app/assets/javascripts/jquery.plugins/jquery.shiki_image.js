$.fn.extend({
  shikiImage() {
    return this.each(function () {
      return $(this)
        .magnificRelGallery()
        .imageEditable();
    });
  }
});
