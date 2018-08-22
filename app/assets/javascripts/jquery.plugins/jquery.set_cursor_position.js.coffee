$.fn.extend
  setCursorPosition: (pos) ->
    el = $(@).get(0)
    return unless el

    sel_done = false
    try
      if el.setSelectionRange
        el.setSelectionRange pos, pos
        sel_done = true

    if !sel_done && el.createTextRange
      range = el.createTextRange()
      range.collapse true
      range.moveEnd 'character', pos
      range.moveStart 'character', pos
      range.select()
