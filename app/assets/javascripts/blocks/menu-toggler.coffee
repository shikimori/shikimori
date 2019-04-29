$(document).on 'turbolinks:load', ->
  $menu = $('.menu-toggler')
  return unless $menu.exists()

  # переключалка выезжания меню
  $menu.on 'click', ->
    $('.l-page').toggleClass 'menu-expanded'

    #if $('.l-page').hasClass('menu-expanded') && !$('.l-menu').is(':appeared')
      #$.scrollTo $('.l-menu')

  $.detectSwipe.threshold = 150
  $.detectSwipe.preventDefault = false

  $page = $('.l-page')
    .on 'swipeleft', ->
      $page.addClass 'menu-expanded'
    .on 'swiperight', ->
      $page.removeClass 'menu-expanded'
