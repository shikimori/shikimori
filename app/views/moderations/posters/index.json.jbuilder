json.content render(
  partial: 'moderations/posters/poster',
  collection: @collection,
  formats: :html
)

if @collection.next_page?
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      next_url: current_url(page: @collection.next_page),
      prev_url: (
        current_url(page: @collection.prev_page) if @collection.prev_page?
      )
    },
    formats: :html
  )
end
