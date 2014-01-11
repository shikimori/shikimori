class CharacterProfileSerializer < CharacterSerializer
  attributes :altname, :japanese, :description, :description, :description_html

  has_many :seyu
  has_many :animes
  has_many :mangas
end
