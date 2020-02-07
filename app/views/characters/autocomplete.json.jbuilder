json.array! @collection.reverse do |entry|
  name = (entry.russian if params[:search]&.contains_russian?) || entry.name

  json.data entry.id
  json.value name
  json.label render(
    partial: 'suggest',
    locals: {
      entry: entry,
      entry_name: name,
      url_builder: :character_url
    },
    formats: :html
  )

  json.url character_url(entry)
end
