json.content render(
  partial: 'comments/comment',
  collection: @collection,
  formats: :html
)

json.postloader render(
  'blocks/postloader',
  filter: 'b-comment',
  next_url: summaries_profile_url(page: @page+1)
) if @add_postloader
