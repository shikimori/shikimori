object @resource
cache

attributes :id, :russian, :name, :rating, :kind, :aired_at, :released_at, :episodes, :score, :description

node :image do |v|
  {
    preview: v.image.url(:preview),
    original: v.image.url(:original),
  }
end

child(:genres) {|v| extends 'api/genres/show' }
child(:studios) {|v| extends 'api/studios/show' }

node(:url) {|v| anime_url v }
