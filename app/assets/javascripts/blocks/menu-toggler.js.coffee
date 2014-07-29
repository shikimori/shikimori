$ ->
  $('.menu-toggler').on 'click', ->
    $('.l-page').toggleClass 'menu-expanded'

    if $('.l-page').hasClass('menu-expanded') && !$('.l-menu').is(':appeared')
      $.scrollTo $('.l-menu')
