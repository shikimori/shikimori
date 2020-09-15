json.array! @collection.reverse do |entry|
  name = (
    entry.russian if params[:search].present? && params[:search].fix_encoding.contains_russian?
  ) || entry.name

  json.data entry.id
  json.url entry.url
  json.value name
  json.label render(
    partial: 'suggest',
    locals: {
      entry: entry,
      entry_name: name
    },
    formats: :html
  )
end
