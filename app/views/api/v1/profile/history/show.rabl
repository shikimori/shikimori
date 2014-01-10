collection @resources

attribute :id, :created_at
attribute format: :description

child target: :target do |linked|
  if linked
    if linked.kind_of? Anime
      extends 'api/v1/animes/preview'
    else
      extends 'api/v1/mangas/preview'
    end
  end
end
