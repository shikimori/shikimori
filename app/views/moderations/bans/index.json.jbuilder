json.content render(
  partial: 'moderations/bans/ban',
  collection: @collection,
  formats: :html
)

if @collection.size == controller.class::LIMIT
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      next_url: current_url(page: @page + 1),
      prev_url: @page > 1 ? current_url(page: @page - 1) : nil
    },
    formats: :html
  )
end
