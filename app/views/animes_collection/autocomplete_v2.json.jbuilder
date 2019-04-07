json.array! @collection do |entry|
  name = (
    entry.russian if params[:search].present? && params[:search].fix_encoding.contains_russian?
  ) || entry.name

  json.id entry.id
  json.name name
  json.url url_for(entry)
end
