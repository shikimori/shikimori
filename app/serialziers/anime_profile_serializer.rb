class AnimeProfileSerializer < AnimeSerializer
  attributes :rating, :english, :japanese, :synonyms, :kind, :aired_at, :released_at, :episodes, :episodes_aired, :score, :description, :description_html

  has_many :genres
  has_many :studios
end
