json.content render(partial: 'comments/comment', collection: @collection, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', filter: 'b-comment', url: summaries_profile_url(page: @page+1))
end
