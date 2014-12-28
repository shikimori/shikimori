json.content render(partial: 'club', collection: @collection, locals: { content_by: :detailed })

if @add_postloader
  json.postloader render('blocks/postloader', filter: 'b-club', url: page_clubs_url(page: @page+1))
end
