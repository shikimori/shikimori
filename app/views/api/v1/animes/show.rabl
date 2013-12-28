object @resource

extends 'api/v1/animes/preview'

attributes :rating, :english, :japanese, :synonyms, :kind, :aired_at, :released_at, :episodes, :episodes_aired, :score, :description, :description_html

child :genres do
  extends 'api/v1/genres/show'
end

child :studios do
  extends 'api/v1/studios/show'
end
