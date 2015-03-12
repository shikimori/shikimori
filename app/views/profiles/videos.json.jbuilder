json.content render(partial: 'moderation/anime_video_reports/report', collection: @collection, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', url: videos_profile_url(page: @page+1))
end
