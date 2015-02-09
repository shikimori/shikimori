json.content render(partial: 'moderation/anime_video_reports/report', collection: @processed, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', url: page_moderation_anime_video_reports_url(page: @page+1))
end
