$.fn.extend
  changeTag: (tag_name) ->
    @map ->
      replacement = document.createElement tag_name

      for attribute in @attributes
        attribute_name = attribute.name
        if tag_name == 'a'
          attribute_name = 'href' if attribute_name == 'data-href'
          attribute_name = 'title' if attribute_name == 'data-title'
        replacement.setAttribute attribute_name, attribute.value

      while @childNodes.length
        replacement.appendChild @childNodes[0]

      $(@).replaceWith replacement
      replacement
