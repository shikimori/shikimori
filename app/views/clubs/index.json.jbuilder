json.content render(partial: 'club', collection: @collection)

if @add_postloader
  json.postloader render('blocks/postloader', url: page_clubs_url(page: @page+1))
end
