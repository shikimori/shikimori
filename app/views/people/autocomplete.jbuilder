json.array! @collection do |entry|
  json.data entry.id
  json.value entry.name
  json.label render('characters/suggest', entry: entry, url_builder: "#{params[:kind]}_url")
end
