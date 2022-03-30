json.content render(
  partial: 'users/user',
  collection: @collection,
  locals: {
    content_by: :named_avatar
  },
  formats: :html
)

if @collection.size == controller.class::MEMBERS_LIMIT
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      filter: 'b-user',
      next_url: current_url(page: @page + 1),
      prev_url: @page > 1 ? current_url(page: @page - 1) : nil
    },
    formats: :html
  )
end
