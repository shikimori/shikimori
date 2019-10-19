$(document).on 'turbolinks:load', ->
  $menu = $('.menu-toggler')
  return unless $menu.exists()

  # переключалка выезжания меню
  $menu.on 'click', ->
    $('.l-page').toggleClass 'menu-expanded'
