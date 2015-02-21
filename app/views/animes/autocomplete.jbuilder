json.array! @collection do |entry|
  name = (entry.russian if params[:search].contains_russian?) || entry.name

  json.data entry.id
  json.value name
  json.label render('suggest', entry: entry, entry_name: name)
  json.url url_for(entry)
end
