json.array! @collection.reverse do |collection|
  json.data collection.id
  json.value collection.name
  json.label render(
    partial: 'suggest',
    locals: { collection: collection },
    formats: :html
  )
  json.url collection_url(collection)
end
