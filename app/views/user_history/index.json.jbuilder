json.cache! [:history, @resource, @view.page, @profile_view.own_profile?, :v4] do
  json.content render(
    partial: 'history',
    locals: { collection: @view.collection, user: @user },
    formats: :html
  )

  if @view.add_postloader?
    json.postloader render(
      'blocks/postloader',
      next_url: current_url(page: @view.page + 1),
      prev_url: @view.page > 1 ? current_url(page: @view.page - 1) : nil
    )
  end
end
