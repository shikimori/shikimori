json.content render(
  partial: 'moderations/anime_video_reports/anime_video_report',
  collection: @collection,
  formats: :html
)

if @collection.size == controller.class::VERSIONS_LIMIT
  json.postloader render(
    'blocks/postloader',
    filter: 'b-log_entry',
    next_url: current_url(page: @page + 1),
    prev_url: @page > 1 ? current_url(page: @page - 1) : nil
  )
end
