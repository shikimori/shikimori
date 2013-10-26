# desktop menu
$ ->
  $triggers = $('.main-menu .submenu').parent()
  $triggers.each ->
    $trigger = $(@)
    $menu = $trigger.children('.submenu').show()
    height = $menu.height()
    borderBottomWidth = parseInt $menu.css('borderBottomWidth')
    $menu.css
      height: 0
      borderBottomWidth: 0

    $trigger.hover_delayed ->
      $menu.css
        height: height
        borderBottomWidth: borderBottomWidth

    , ->
      $menu.css
        height: 0
        borderBottomWidth: 0

    , $menu.data('duration') || 150

# mobile menu
$('.mobile-menu-toggler').click ->
  $('.main-menu .menu-items').toggleClass('active')
      .siblings()
      .removeClass 'active'

$('.mobile-search-toggler').click ->
  $('.main-menu .menu-search').toggleClass('active')
      .siblings()
      .removeClass 'active'

#$('.mobile-sign-in-toggler').click ->
  #$('.usernav').trigger 'click'

$('.submenu-toggler').click ->
  $(@).toggleClass 'active'
  $(@).next().toggleClass 'active'
