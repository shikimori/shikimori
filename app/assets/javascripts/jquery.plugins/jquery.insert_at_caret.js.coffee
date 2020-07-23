$.fn.extend
  insertAtCaret: (prefix, postfix, filler) ->
    @each (i) ->
      if document.selection
        @focus()
        sel = document.selection.createRange()
        sel.text = prefix + ((if sel.text is '' and filler then filler else sel.text)) + postfix
        @focus()
      else if @selectionStart or @selectionStart is '0' or @selectionStart is 0
        startPos = @selectionStart
        endPos = @selectionEnd
        scrollTop = @scrollTop
        selectedText = @value.substring(startPos, endPos)
        selectedText = (if selectedText is '' and filler then filler else selectedText)
        @value = @value.substring(0, startPos) + prefix + selectedText + postfix + @value.substring(endPos, @value.length)
        @focus()
        @selectionEnd = @selectionStart = startPos + prefix.length + selectedText.length + postfix.length
        @scrollTop = scrollTop
      else
        @value += prefix + postfix
        @focus()
      $(@).trigger('change')
