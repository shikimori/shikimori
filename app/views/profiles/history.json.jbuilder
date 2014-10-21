json.content render(partial: 'history', locals: { collection: @collection }, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', url: history_profile_url(@user, page: @page+1), next_url: history_profile_url(@user, page: @page+1), prev_url: @page > 1 ? history_profile_url(@user, page: @page-1) : nil)
end
