TOOLTIP_OPTIONS = require 'helpers/tooltip_options'

page_load 'userlist_comparer_show', ->
  $('tr.unprocessed')
    .removeClass('unprocessed')
    .find('a.tooltipped')
    .tooltip Object.add(TOOLTIP_OPTIONS.COMMON_TOOLTIP,
      offset: [
        -95
        10
      ]
      position: 'bottom right'
      opacity: 1
    )
