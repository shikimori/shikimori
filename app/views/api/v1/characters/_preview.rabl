attributes :id, :name, :russian

node :image do |entry|
  {
    original: entry.image.url(:original),
    preview: entry.image.url(:preview),
    x96: entry.image.url(:x96),
    x64: entry.image.url(:x64),
  }
end

node :url do |entry|
  character_url entry
end
