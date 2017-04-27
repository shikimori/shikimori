ShikiEditor = require 'views/application/shiki_editor'

(($) ->
  $.fn.extend
    shiki_editor: ->
      @each ->
        $root = $(@)
        return unless $root.hasClass('unprocessed')

        new ShikiEditor($root)
) jQuery
