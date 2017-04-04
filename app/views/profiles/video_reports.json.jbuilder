json.content render(
  partial: 'moderations/anime_video_reports/anime_video_report',
  collection: @collection,
  formats: :html
)

if @add_postloader
  json.postloader render('blocks/postloader', next_url: video_reports_profile_url(page: @page+1))
end
