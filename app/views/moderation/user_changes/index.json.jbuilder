json.content render(@processed, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', url: moderation_users_changes_url(page: @page+1))
end
