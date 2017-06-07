if @collection
  json.content render(
    partial: 'users/user',
    collection: @collection,
    locals: { content_by: :detailed },
    formats: :html
  )

  if @collection.next_page?
    json.postloader render(
      'blocks/postloader',
      filter: 'b-user',
      next_url: users_url(page: @collection.next_page, search: params[:search]),
      prev_url: (users_url(page: @collection.prev_page, search: params[:search]) if @collection.prev_page?)
    )
  end
end
