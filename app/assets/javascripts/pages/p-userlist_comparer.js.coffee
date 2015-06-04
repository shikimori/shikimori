@on 'page:load', 'userlist_comparer_show', ->
  $('tr.unprocessed')
    .removeClass('unprocessed')
    .find('a.tooltipped')
    .tooltip $.extend($.extend({}, tooltip_options),
      offset: [
        -95
        10
      ]
      position: 'bottom right'
      opacity: 1
    )
