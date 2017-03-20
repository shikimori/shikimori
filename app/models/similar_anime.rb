class SimilarAnime < ApplicationRecord
  belongs_to :src, class_name: Anime.name, foreign_key: :src_id, touch: true
  belongs_to :dst, class_name: Anime.name, foreign_key: :dst_id, touch: true
end
