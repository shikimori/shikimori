attributes :id, :title, :russian

node :image do |entry|
  entry.image.url :preview
end
