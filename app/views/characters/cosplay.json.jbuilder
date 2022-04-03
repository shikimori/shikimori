json.content render(
  partial: 'cosplay_galleries/cosplay_gallery',
  collection: @collection,
  locals: {
    with_headline: true
  },
  formats: :html
)

if @add_postloader
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      filter: 'b-cosplay_gallery',
      next_url: cosplay_character_url(@resource, @page + 1)
    },
    formats: :html
  )
end
