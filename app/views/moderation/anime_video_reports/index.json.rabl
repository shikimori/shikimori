object nil

node :content do
  render_to_string(partial: 'moderation/anime_video_reports/report', collection: @processed, formats: :html, layout: false) +
    (@add_postloader ?
      render_to_string(partial: 'site/postloader', locals: { url: page_moderation_anime_video_reports_url(page: @page+1, format: :json) }, formats: :html, layout: false) :
      '')
end
