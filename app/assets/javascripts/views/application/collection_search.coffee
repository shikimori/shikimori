import URI from 'urijs'
import { debounce } from 'throttle-debounce'

export default class CollectionSearch extends View
  PENDING_REQUEST = 'pending_request'

  initialize: ->
    @cache = {}
    @$collection = @$root.find('.searchable-collection')
    console.warn('not found .searchable-collection') unless @$collection.length

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
      @_show_results @cache[phrase], @_search_url(phrase)
    else
      axios.get(@_search_url(phrase)).then (response) =>
        @cache[phrase] = response.data
        if phrase == @_search_phrase()
          @_show_results @cache[phrase], @_search_url(phrase)

  _show_results: (response, search_url) ->
    @_process_response(response, search_url)

    @_hide_ajax()

    if Modernizr.history
      window.history.replaceState(
        { turbolinks: true, url: search_url },
        '',
        search_url
      )

  _process_response: (response, search_url) ->
    html =
      if response.content
        response.content + (response.postloader || '')
      else
        JST['search/nothing_found']()

    @$collection.html(html).process()

  _search_phrase: ->
    @$input.val().trim()

  _search_url: (phrase) ->
    uri = URI @$root.data('search_url')

    if phrase
      uri.query(search: phrase)
    else
      uri.removeQuery('search')

  _show_ajax: ->
    @$collection.addClass 'b-ajax'

  _hide_ajax: ->
    @$collection.removeClass 'b-ajax'
