import Turbolinks from 'turbolinks'

pageLoad 'profiles_comments', ->
  $('form.comments-search').on 'submit', ->
    $search = $(@).find('input.search')
    Turbolinks.visit "#{$search.data 'search_url'}?search=#{$search.val()}"
    false
