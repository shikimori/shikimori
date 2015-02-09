json.content render(@collection)

if @add_postloader
  json.postloader render('blocks/postloader', filter: 'b-message', url: index_profile_messages_url(@resource, messages_type: @messages_type, page: @page+1))
end
