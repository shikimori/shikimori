attributes :id, :name, :russian

node :image do |entry|
  {
    preview: entry.image.url(:preview),
    short: entry.image.url(:short),
    x96: entry.image.url(:x96),
    x64: entry.image.url(:x64),
  }
end

node :url do |entry|
  character_url entry
end
