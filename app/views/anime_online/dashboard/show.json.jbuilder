json.content render(
  partial: 'animes/anime',
  collection: @recent_videos,
  locals: {
    cover_title: :none,
    cover_notice: :latest_episode,
    content_by: :block,
    content_text: :none
  },
  formats: :html
)

json.postloader render(
  'blocks/postloader',
  filter: 'b-catalog_entry',
  next_url: anime_dashboard_page_url(page: @page+1)
) if @add_postloader
