json.content render(partial: 'history', locals: { collection: @collection }, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', next_url: index_profile_user_history_index_url(@resource, page: @page+1), next_url: index_profile_user_history_index_url(@resource, page: @page+1), prev_url: @page > 1 ? index_profile_user_history_index_url(@resource, page: @page-1) : nil)
end
