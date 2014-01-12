attributes :id, :name, :filtered_name, :real?

node :image do |entry|
  entry.image.url
end
