json.content render(
  partial: 'moderations/bans/ban',
  collection: @collection,
  cached: true,
  formats: :html
)

if @collection.size == controller.class::PER_PAGE
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      next_url: current_url(page: @page + 1),
      prev_url: @page > 1 ? current_url(page: @page - 1) : nil
    },
    formats: :html
  )
end
