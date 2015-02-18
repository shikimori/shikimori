json.content render(@collection)

if @add_postloader
  json.postloader render('blocks/postloader', filter: 'b-cosplay_gallery', url: @resource.cosplay_url(@page+1))
end
