json.content render(
  partial: 'topics/topic',
  collection: @collection,
  as: :topic_view,
  formats: :html
)

if @add_postloader
  json.postloader render(
    'blocks/postloader',
    filter: 'b-topic',
    next_url: summaries_profile_url(page: @page+1)
  )
end
