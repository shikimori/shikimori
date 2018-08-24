import View from 'views/application/view'

export default class TextAnnotated extends View
  initialize: ->
    texts = @$node.data('texts')
    return if Object.isEmpty(texts)

    Object.forEach texts, @_add_text

  _add_text: (text, id) =>
    @$(".b-catalog_entry##{id} .image-decor").each (_index, node) ->
      $(node).append("<div class='text'>#{text}</div>")
