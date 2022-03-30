json.content render(
  partial: 'coubs/coub',
  collection: @results.coubs,
  locals: {
    match_tags: @anime.coub_tags
  },
  formats: :html
)

if @results.iterator
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      filter: 'b-coub',
      next_url: current_url(iterator: @results.iterator, checksum: @results.checksum)
    },
    formats: :html
  )
end
