collection @resources

attribute :id, :created_at

node :description do |entry|
  entry.format
end

child target: :target do |linked|
  if linked
    if linked.kind_of? Anime
      extends 'api/v1/animes/preview'
    else
      extends 'api/v1/mangas/preview'
    end
  end
end
