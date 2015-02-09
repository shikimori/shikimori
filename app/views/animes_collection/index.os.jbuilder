json.array! [
  params[:search],
  @entries.map(&:name),
  @entries.map {|v| url_for(v) }
]
