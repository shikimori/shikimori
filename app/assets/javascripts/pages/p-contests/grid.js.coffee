pageLoad 'contests_grid', ->
  place_final()
  $(window).on 'resize', place_final

#place_final = ->
  #$final = $('.final')
  #$top = $('.winners .round:last-child .entry.grid')
  #$bottom = $('.losers .round:last-child .entry.grid')

  ## если $bottom - пусто, значит у нас контест без дополнительных раундов
  #if $bottom.length
    #height = $bottom.offset().top - $top.offset().top + 1
  #else
    #$bottom = $('.winners .round:last-child .entry:last-child p:first-child')
    #height = $bottom.offset().top - $top.offset().top - 23

  #$final.css
    #height: height
    #width: 1
    #top: $top.offset().top + $top.outerHeight() / 2 - 1
    #left: $top.offset().left + $top.outerWidth() * 2

  #$entry = $final.find('.entry')
  #$entry.css
    #marginTop: height/2 - $entry.outerHeight()

place_final = ->
  $grid = $('.contest-grid')
  $final = $grid.find('.final')
  $top = $grid.find('.winners .round:last-child .entry:first-child')
  $bottom = $grid.find('.losers .round:last-child .entry:first-child')

  # если $bottom - пусто, значит у нас контест без дополнительных раундов
  if $bottom.length
    height = $bottom.offset().top - $top.offset().top + 1
  else
    $top = $grid.find('.winners .round:last-child .entry:first-child')
    $bottom = $grid.find('.winners .round:last-child .entry:last-child p:first-child')
    height = $bottom.offset().top - $top.offset().top - 23

  $final.css
    height: height
    width: 1
    top: $top.offset().top + $top.outerHeight() - 1
    left: $top.offset().left + $top.outerWidth()

  $entry = $final.find('.entry')
  $entry.css
    marginTop: height/2 - $entry.outerHeight()
