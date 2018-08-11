class RelatedAnime < ApplicationRecord
  belongs_to :source,
    class_name: Anime.name,
    optional: true, # because it can imported from MAL for non existing anime
    touch: true
  belongs_to :anime, touch: true, optional: true
  belongs_to :manga, touch: true, optional: true
end
