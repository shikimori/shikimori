json.cache! [:history, @resource, @view.page, I18n.locale, request.format] do
  json.content render(
    partial: 'history',
    locals: { collection: @view.collection },
    formats: :html
  )

  if @view.add_postloader?
    json.postloader render(
      'blocks/postloader',
      next_url: index_profile_user_history_index_url(@resource, page: @view.page+1),
      prev_url: @view.page > 1 ? index_profile_user_history_index_url(@resource, page: @view.page-1) : nil
    )
  end
end
