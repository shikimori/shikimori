json.content render(
  partial: 'moderations/anime_video_authors/anime_video_author',
  collection: @collection,
  locals: { anime: @anime },
  formats: :html
)

if @add_postloader
  json.postloader render(
    'blocks/postloader',
    next_url: current_url(page: @page + 1)
  )
end
