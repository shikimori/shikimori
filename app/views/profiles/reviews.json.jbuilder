json.content render(partial: 'topics/topic', collection: @collection, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', filter: 'b-topic', url: reviews_profile_url(page: @page+1))
end
