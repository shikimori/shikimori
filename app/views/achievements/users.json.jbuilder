json.content render(
  partial: 'users/user',
  collection: @users,
  locals: { content_by: :named_avatar },
  formats: :html
)

if @users.size == controller.class::USERS_PER_PAGE
  json.postloader render(
    'blocks/postloader',
    filter: 'b-user',
    next_url: current_url(page: @page + 1),
    prev_url: @page > 1 ? current_url(page: @page - 1) : nil
  )
end
