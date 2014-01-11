class MangaProfileSerializer < MangaSerializer
  attributes :english, :japanese, :synonyms, :kind, :aired_at, :released_at, :volumes, :chapters, :score, :description, :description_html

  has_many :genres
  has_many :publishers
end
