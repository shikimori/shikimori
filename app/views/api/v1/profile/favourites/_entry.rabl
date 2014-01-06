attributes :id, :name, :russian

node :image do |entry|
  entry.image.url :x64
end

node :url do |entry|
  url_for entry
end
