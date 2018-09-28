json.content render(
  partial: 'log',
  collection: @collection,
  formats: :html
)

if @collection.size == @limit
  json.postloader render(
    'blocks/postloader',
    next_url: current_url(page: @page + 1),
    prev_url: @page > 1 ? current_url(page: @page - 1) : nil
  )
end
