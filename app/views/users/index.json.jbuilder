json.content render(@users, content_by: :detailed)

if @add_postloader
  json.postloader render('blocks/postloader', filter: 'b-user', url: users_path(page: @page+1, search: params[:search]))
end
