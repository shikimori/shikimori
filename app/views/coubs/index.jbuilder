json.content render(
  partial: 'coubs/coub',
  collection: @results.coubs,
  locals: { match_tags: @anime.coub_tags },
  formats: :html
)

if @results.iterator
  json.postloader render(
    'blocks/postloader',
    filter: 'b-coub',
    next_url: current_url(iterator: @results.encrypted_iterator)
  )
end
