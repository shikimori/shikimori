json.content render(partial: 'dialog', collection: @collection)

if @add_postloader
  json.postloader render('blocks/postloader', filter: 'b-dialog', url: index_profile_dialogs_url(@resource, page: @page+1))
end
