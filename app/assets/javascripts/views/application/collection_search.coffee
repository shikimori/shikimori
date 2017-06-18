module.exports = class CollectionSearch extends View
  PENDING_REQUEST = 'pending_request'

  initialize: ->
    @cache = {}
    @$collection = @$root.children('.collection')
    @$input = @$('.field input')
    @$clear = @$('.field .clear')

    @debounced_search = debounce 250, @_search
    @current_phrase = @_search_phrase()

    @$clear.toggle !Object.isEmpty(@current_phrase)
    # @$input.focus() if @$input.is(':appeared')

    @$input.on 'change blur keyup paste', @_filter_changed
    @$clear.on 'click', @_clear_phrase


  # handlers
  _filter_changed: (e) =>
    phrase = @_search_phrase()

    if e.keyCode == 27
      if Object.isEmpty(phrase)
        @$input.blur()
      else
        @_clear_phrase()
      return

    return if phrase == @current_phrase

    if phrase.length == 1
      @_hide_ajax()
    else
      @current_phrase = phrase
      @debounced_search()
      @_show_ajax()

      @$clear.toggle !Object.isEmpty(phrase)

  _clear_phrase: =>
    @$input
      .val('')
      .trigger('change')
      .focus()

  # private functions
  _search: =>
    phrase = @_search_phrase()
    return if @cache[phrase] == PENDING_REQUEST

    if phrase.length == 1
      @_hide_ajax()
    else if @cache[phrase]
      @_show_results @cache[phrase]
    else
      axios
        .get(@_search_url(phrase), headers: { 'Accept': 'text/html' })
        .then (response) =>
          @cache[phrase] = response.data
          @_show_results @cache[phrase] if phrase == @_search_phrase()

  _show_results: (response) ->
    @$collection.html(response).process()
    @_hide_ajax()

  _search_phrase: ->
    @$input.val().trim()

  _search_url: (phrase) ->
    URI(@$root.data('search_url')).query(search: phrase)

  _show_ajax: ->
    @$collection.addClass 'b-ajax'

  _hide_ajax: ->
    @$collection.removeClass 'b-ajax'
