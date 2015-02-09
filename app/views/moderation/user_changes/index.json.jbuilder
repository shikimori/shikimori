json.content render(partial: 'user_changes/user_change', collection: @processed, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', url: index_moderation_user_changes_url(page: @page+1))
end
