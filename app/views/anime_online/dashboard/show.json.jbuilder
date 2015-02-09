json.content render(partial: 'animes/anime', collection: @recent_videos, locals: { cover_title: :none, cover_notice: :latest_episode, content_by: :block }, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', filter: 'b-catalog_entry', url: anime_dashboard_page_url(page: @page+1))
end
