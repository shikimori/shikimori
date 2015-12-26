json.content render(
  partial: 'topics/topic',
  collection: @collection,
  as: :view,
  formats: :html
)

if @add_postloader
  json.postloader render(
    'blocks/postloader',
    filter: 'b-topic',
    next_url: reviews_profile_url(page: @page+1)
  )
end
