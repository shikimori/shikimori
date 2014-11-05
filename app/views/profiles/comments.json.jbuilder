json.content render(@comments)

if @add_postloader
  json.postloader render('blocks/postloader', filter: 'b-comment', url: comments_profile_url(page: @page+1, search: params[:search]))
end
