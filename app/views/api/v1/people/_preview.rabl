attributes :id, :name

node :image do |entry|
  {
    preview: entry.image.url(:preview),
    x64: entry.image.url(:x64)
  }
end

node :url do |entry|
  person_url entry
end
