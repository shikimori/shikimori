json.content render(partial: 'moderations/collections/collection', collection: @processed, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', next_url: moderations_collections_url(page: @page+1))
end
