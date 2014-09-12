json.array! @collection do |entry|
  json.data entry.id
  json.value entry.name
  json.label render('suggest', entry: entry)
end
