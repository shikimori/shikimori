json.array! [
  params[:search],
  @view.collection.map(&:name),
  @view.collection.map { |v| url_for(v) }
]
