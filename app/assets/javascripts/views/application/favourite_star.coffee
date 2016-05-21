class @FavouriteStar extends View
  ADD_CLASS = 'fav-add'
  REMOVE_CLASS = 'fav-remove'

  ADD_METHOD = 'POST'
  REMOVE_METHOD = 'DELETE'

  initialize: (is_favoured) ->
    @add_text = @$root.data 'add_text'
    @remove_text = @$root.data 'remove_text'
    @_update is_favoured

    @on 'ajax:success', @_ajax_success

  _ajax_success: =>
    @_update @root.classList.contains(ADD_CLASS)

  _update: (is_favoured) ->
    if is_favoured
      @$root
        .removeClass(ADD_CLASS)
        .addClass(REMOVE_CLASS)
        .attr
          title: @remove_text
          'original-title': @remove_text
          'data-text': @remove_text
        .data
          method: REMOVE_METHOD

    else
      @$root
        .removeClass(REMOVE_CLASS)
        .addClass(ADD_CLASS)
        .attr
          title: @add_text
          'original-title': @add_text
          'data-text': @add_text
        .data
          method: ADD_METHOD
