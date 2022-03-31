json.array! @collection.reverse do |entry|
  name = (entry.russian if params[:search]&.contains_russian?) || entry.name

  json.data entry.id
  json.value entry.name
  json.label render(
    partial: 'characters/suggest',
    locals: {
      entry: entry,
      entry_name: name,
      url_builder: "#{params[:kind]}_url"
    },
    formats: :html
  )
end
