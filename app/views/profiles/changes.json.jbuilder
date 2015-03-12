json.content render(partial: 'user_changes/user_change', collection: @collection, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', url: changes_profile_url(page: @page+1))
end
