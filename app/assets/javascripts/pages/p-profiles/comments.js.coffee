@on 'page:load', 'profiles_comments', ->
  $('form.comments-search').on 'submit', ->
    $search = $(@).find('input.search')
    Turbolinks.visit "#{$search.data 'search_url'}/search/#{search_escape $search.val()}"
    false
