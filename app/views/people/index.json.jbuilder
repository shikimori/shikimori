json.content render(partial: 'people/person', collection: @collection, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', url: search_url(search: params[:search], page: @page+1))
end
