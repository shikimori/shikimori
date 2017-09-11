json.content render(
  partial: 'moderations/anime_video_reports/anime_video_report',
  collection: @processed,
  formats: :html
)

if @add_postloader
  json.postloader render(
    'blocks/postloader',
    next_url: moderations_anime_video_reports_url(page: @page+1, created_on: params[:created_on])
  )
end
