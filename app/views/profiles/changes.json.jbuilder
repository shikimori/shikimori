json.content render(@collection)

if @add_postloader
  json.postloader render('blocks/postloader', url: changes_profile_url(page: @page+1))
end
