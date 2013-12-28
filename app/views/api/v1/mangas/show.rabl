object @resource

extends 'api/v1/mangas/preview'

attributes :english, :japanese, :synonyms, :kind, :aired_at, :released_at, :volumes, :chapters, :score, :description, :description_html

child :genres do
  extends 'api/v1/genres/show'
end

child :publishers do
  extends 'api/v1/publishers/show'
end
