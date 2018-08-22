class SimilarAnime < ApplicationRecord
  belongs_to :src,
    class_name: Anime.name,
    foreign_key: :src_id,
    optional: true, # because it can imported from MAL for non existing anime
    touch: true
  belongs_to :dst,
    class_name: Anime.name,
    foreign_key: :dst_id,
    optional: true, # because it can imported from MAL for non existing anime
    touch: true
end
