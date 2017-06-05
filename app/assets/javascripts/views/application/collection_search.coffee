module.exports = class CollectionSearch extends View
  PENDING_REQUEST = 'pending_request'

  initialize: ->
    @cache = {}
    @$collection = @$ '.collection'
    @$input = @$('.field input')

    @debounced_search = debounce 250, @_search

    @$input.on 'change blur keyup paste', @_filter_keyup

  # handlers
  _filter_keyup: (e) =>
    return if e.keyCode == 91 || e.keyCode == 18 || e.keyCode == 16 || e.keyCode == 17
    @debounced_search()

    @_show_ajax()

  # private functions
  _search: =>
    phrase = @_search_phrase()
    return if @cache[phrase] == PENDING_REQUEST

    if @cache[phrase]
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
