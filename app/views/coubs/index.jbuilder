json.content ''
json.content render(
  partial: 'coubs/coub',
  collection: @results.coubs,
  formats: :html
)

if @results.iterator
  json.postloader render(
    'blocks/postloader',
    filter: 'b-coub',
    next_url: current_url(iterator: @results.iterator)
  )
end
