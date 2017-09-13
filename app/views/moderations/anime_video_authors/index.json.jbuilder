json.content render(
  partial: 'moderations/anime_video_authors/anime_video_author',
  collection: @collection,
  formats: :html
)

if @add_postloader
  json.postloader render(
    'blocks/postloader',
    next_url: url_for(url_params(page: @page+1))
  )
end
