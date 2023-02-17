collection = params[:is_pending] == '1' ? @view.pending : @view.processed

json.content render(
  partial: 'moderations/collections/collection',
  collection: collection,
  formats: :html
)

if collection.next_page?
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      filter: 'b-log_entry',
      next_url: current_url(page: @page + 1),
      prev_url: @page > 1 ? current_url(page: @page - 1) : nil
    },
    formats: :html
  )
end
