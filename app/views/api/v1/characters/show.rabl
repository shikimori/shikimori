object @resource

extends 'api/v1/characters/preview'

attributes :altname, :japanese, :description
node :description_html do |character|
  BbCodeService.instance.format_comment character.description
end

child seyu: :seyu do
  extends 'api/v1/people/preview'
end

child :animes do
  extends 'api/v1/animes/preview'
end

child :mangas do
  extends 'api/v1/animes/preview'
end
