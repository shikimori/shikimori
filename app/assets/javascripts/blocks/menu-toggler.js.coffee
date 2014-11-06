$(document).on 'page:load', ->
  $menu = $('.menu-toggler')
  return unless $menu.exists()

  # переключалка выезжания меню
  $menu.on 'click', ->
    $('.l-page').toggleClass 'menu-expanded'

    #if $('.l-page').hasClass('menu-expanded') && !$('.l-menu').is(':appeared')
      #$.scrollTo $('.l-menu')

  $('.l-page').hammer()
    .on 'swipeleft', ->
      $('.l-page').addClass 'menu-expanded'
    .on 'swiperight', ->
      $('.l-page').removeClass 'menu-expanded'
