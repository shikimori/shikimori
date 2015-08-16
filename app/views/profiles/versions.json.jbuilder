json.content render(partial: 'versions/version', collection: @collection, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', url: versions_profile_url(page: @page+1))
end
