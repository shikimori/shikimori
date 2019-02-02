json.array! @collection do |entry|
  name = (entry.russian if params[:search]&.contains_russian?) || entry.name

  json.data entry.id
  json.value name
  json.label render 'suggest',
    entry: entry,
    entry_name: name,
    url_builder: :character_url

  json.url character_url(entry)
end
