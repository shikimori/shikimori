$.fn.extend({
  changeTag(tagName) {
    return this.map(function() {
      const replacement = document.createElement(tagName);

      for (var i = 0; i < this.attributes.length; i +=1 ) {
        const attribute = this.attributes[i];
        let attributeName = attribute.name;
        if (tagName === 'a') {
          if (attributeName === 'data-href') { attributeName = 'href'; }
          if (attributeName === 'data-title') { attributeName = 'title'; }
        }
        replacement.setAttribute(attributeName, attribute.value);
      };

      while (this.childNodes.length) {
        replacement.appendChild(this.childNodes[0]);
      }

      $(this).replaceWith(replacement);
      return replacement;
    });
  }
});
