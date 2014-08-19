class @ShikiView
  constructor: ($root) ->
    @$root = $root
    @$root.removeClass('unprocessed')

    @initialize(@$root)

  on: ->
    @$root.on.apply(@$root, arguments)

  $: (selector) ->
    $(selector, @$root)
