$(document).on 'page:load', ->
  # переключалка выезжания меню
  $('.menu-toggler').on 'click', ->
    console.log 'toggle'
    $('.l-page').toggleClass 'menu-expanded'

    if $('.l-page').hasClass('menu-expanded') && !$('.l-menu').is(':appeared')
      $.scrollTo $('.l-menu')
