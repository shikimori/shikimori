json.content render(
  partial: 'users/user',
  collection: @collection,
  locals: { content_by: :named_avatar },
  formats: :html
)
json.postloader render(
  'blocks/postloader',
  next_url: members_club_url(@resource, page: @page+1)
) if @add_postloader
