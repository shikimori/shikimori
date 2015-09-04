json.content render(partial: 'moderations/anime_video_reports/report', collection: @processed, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', url: page_moderations_anime_video_reports_url(page: @page+1))
end
