if @collection
  json.content render(
    partial: 'users/user',
    collection: @collection,
    locals: { content_by: :detailed },
    formats: :html
  )

  if @add_postloader
    json.postloader render(
      'blocks/postloader',
      filter: 'b-user',
      next_url: users_path(page: @page+1, search: params[:search])
    )
  end
end
