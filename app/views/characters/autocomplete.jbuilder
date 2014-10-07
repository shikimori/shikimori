json.array! @collection do |entry|
  json.data entry.id
  json.value entry.name
  json.label render('suggest', entry: entry, url_builder: :character_url)
  json.url character_url(entry)
end
